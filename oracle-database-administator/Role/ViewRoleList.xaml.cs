using Oracle.ManagedDataAccess.Client;
using oracle_database_administator.User;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace oracle_database_administator.Role
{
    /// <summary>
    /// Interaction logic for ViewRoleList.xaml
    /// </summary>
    public partial class ViewRoleList : Page
    {
        OracleConnection conn = Database.Instance.Connection;

        public string currentUserID { get; set; }

        public ViewRoleList()
        {
            InitializeComponent();
            Database.Instance.IsSelectable = true;           
            currentUserID = Database.Instance.CurrentUser;
            DataContext = this;
        }

        private void UpdateRoleGrid()
        {
            try
            {
                string query = "SELECT ROLE, ROLE_ID FROM SYS.DBA_ROLES";
                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        RoleDataGrid.ItemsSource = dataTable.DefaultView;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void UpdateUserPrivilegesGrid()
        {
            try
            {
                string query = "SELECT * FROM DBA_ROLE_PRIVS";
                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        RoleDataGrid.ItemsSource = dataTable.DefaultView;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Dashboard());
            }
        }

        private void Page_Unloaded(object sender, RoutedEventArgs e)
        {

        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            UpdateRoleGrid();
        }

        private void InsertButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string roleName = RoleNameTextBox.Text;

                string query = @"BEGIN
                            EXECUTE IMMEDIATE 'ALTER SESSION SET ""_ORACLE_SCRIPT"" = TRUE';
                            EXECUTE IMMEDIATE 'CREATE ROLE " + roleName + "';" +
                            " END;";

                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    int rowSelected = command.ExecuteNonQuery();

                    if (rowSelected == -1)
                    {
                        MessageBox.Show("Create role successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        Database.Instance.IsSelectable = true;
                        UpdateRoleGrid();
                    }
                    else
                    {
                        MessageBox.Show("Cannot create role!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Create error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void DeleteButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (Database.Instance.IsSelectable)
                {
                    string roleName = RoleNameTextBox.Text;
                    RoleNameTextBox.Text = string.Empty;

                    if (!string.IsNullOrEmpty(roleName))
                    {
                        try
                        {
                            string query = @"BEGIN
                            EXECUTE IMMEDIATE 'ALTER SESSION SET ""_ORACLE_SCRIPT"" = TRUE';
                            EXECUTE IMMEDIATE 'DROP ROLE " + roleName + "';" +
                                " END;";

                            using (OracleCommand command = new OracleCommand(query, conn))
                            {
                                int rowSelected = command.ExecuteNonQuery();

                                if (rowSelected == -1)
                                {
                                    MessageBox.Show("Drop role successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                    UpdateRoleGrid();
                                }
                                else
                                {
                                    MessageBox.Show("Cannot drop role!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                    }
                    else
                    {
                        MessageBox.Show("No role selected!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Drop error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                if (Database.Instance.IsSelectable)
                    mainWindow.MainFrame.Navigate(new oracle_database_administator.Dashboard());
                else
                    mainWindow.MainFrame.Navigate(new oracle_database_administator.Role.ViewRoleList());
            }
        }

        private void RolesUserButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (Database.Instance.IsSelectable)
                {
                    for (int col = 0; col < 2; col++)
                    {
                        RoleDataGrid.Columns[col].Visibility = Visibility.Collapsed;
                    }
                    for (int col = 2; col < 9; col++)
                    {
                        RoleDataGrid.Columns[col].Visibility = Visibility.Visible;
                    }
                }

                InsertRoleButton.Visibility = Visibility.Collapsed;
                DeleteRoleButton.Visibility = Visibility.Collapsed;
                RoleUserButton.Visibility = Visibility.Collapsed;
                EditRoleLabel.Visibility = Visibility.Collapsed;
                UsernameGrid.Visibility = Visibility.Visible;

                UpdateUserPrivilegesGrid();
                Database.Instance.IsSelectable = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void PrivilegesRoleButton_Click(object sender, RoutedEventArgs e)
        {
            if (RoleDataGrid.SelectedItem != null)
            {
                // Lấy dữ liệu từ dòng được chọn
                DataRowView selectedRole = (DataRowView)RoleDataGrid.SelectedItem;
                Role selectedRoleInfo;
                if (Database.Instance.IsSelectable)
                {
                    // Tạo một đối tượng chứa thông tin của role được chọn
                    selectedRoleInfo = new Role(selectedRole["ROLE"].ToString());
                }
                else
                {
                    // Tạo một đối tượng chứa thông tin của role được chọn
                    selectedRoleInfo = new Role(selectedRole["GRANTEE"].ToString());
                }

                // Chuyển sang trang mới và truyền thông tin về role được chọn qua trang mới
                ViewPrivilegesOfRole privilegesPage = new ViewPrivilegesOfRole(selectedRoleInfo);
                NavigationService.Navigate(privilegesPage);
            }
            else
            {
                MessageBox.Show("A role is required!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void GrantRoleButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string roleName = RoleNameTextBox.Text;
                string userName = UserNameTextBox.Text;

                string query = @"BEGIN
                            EXECUTE IMMEDIATE 'ALTER SESSION SET ""_ORACLE_SCRIPT"" = TRUE';
                            EXECUTE IMMEDIATE 'GRANT " + roleName + " TO " + userName + "';" +
                            " END;";

                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    int rowSelected = command.ExecuteNonQuery();

                    if (rowSelected == -1)
                    {
                        MessageBox.Show("Grant role successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        UpdateUserPrivilegesGrid();
                    }
                    else
                    {
                        MessageBox.Show("Cannot grant role!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Grant error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void RevokeRoleButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string roleName = RoleNameTextBox.Text;
                string userName = UserNameTextBox.Text;

                string query = "REVOKE " + roleName + " FROM " + userName ;

                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    int rowSelected = command.ExecuteNonQuery();

                    if (rowSelected == -1)
                    {
                        MessageBox.Show("Revoke role successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        UpdateUserPrivilegesGrid();
                    }
                    else
                    {
                        MessageBox.Show("Cannot revoke role!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Revoke error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void RoleDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                if (Database.Instance.IsSelectable)
                {
                    if (RoleDataGrid.SelectedItem != null)
                    {
                        DataRowView row = (DataRowView)RoleDataGrid.SelectedItem;
                        if (row != null)
                        {
                            RoleNameTextBox.Text = row["ROLE"].ToString();
                        }
                    }
                }
                else
                {
                    if (RoleDataGrid.SelectedItem != null)
                    {
                        DataRowView row = (DataRowView)RoleDataGrid.SelectedItem;
                        if (row != null)
                        {
                            RoleNameTextBox.Text = row["GRANTED_ROLE"].ToString();
                            UserNameTextBox.Text = row["GRANTEE"].ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
    }
}
