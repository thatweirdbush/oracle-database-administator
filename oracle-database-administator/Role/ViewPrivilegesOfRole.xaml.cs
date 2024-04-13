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
    /// Interaction logic for ViewPrivilegesOfRole.xaml
    /// </summary>
    public partial class ViewPrivilegesOfRole : Page
    {
        OracleConnection conn = Database.Instance.Connection;

        private UserInfo selectedUserInfo;
        public string selectedUserName { get; set; }
        public string currentUserID { get; set; }

        public ViewPrivilegesOfRole(UserInfo userInfo)
        {
            InitializeComponent();
            selectedUserInfo = userInfo;
            selectedUserName = selectedUserInfo.UserName;
            currentUserID = Database.Instance.CurrentUser;
            DataContext = this;
        }     

        // Sử dụng sự kiện Unloaded để đảm bảo rằng kết nối được đóng khi chuyển khỏi Page
        private void Page_Unloaded(object sender, RoutedEventArgs e)
        {

        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                if (conn.State == System.Data.ConnectionState.Open)
                {
                    Console.WriteLine("Connection opened successfully!");

                    UpdatePrivUserGrid();
                }
                else
                {
                    MessageBox.Show("Failed to open connection.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }

            catch (Exception ex)
            {
                MessageBox.Show("Connection error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void UpdatePrivUserGrid()
        {
            try
            {
                string query = "SELECT * FROM ALL_TAB_PRIVS WHERE GRANTEE = '" + selectedUserName + "'";
                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        PrivUserDataGrid.ItemsSource = dataTable.DefaultView;
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

        private void PrivUserDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void BackViewUserButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Role.ViewRoleList());
            }
        }

        private void TestPrivUserButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Role.TestPrivileges(selectedUserInfo));
            }
        }

        private void EditPrivButton_Click(object sender, RoutedEventArgs e)
        {
            GrantPrivOnTable grantPrivOnTabPage = new GrantPrivOnTable(selectedUserInfo);
            NavigationService.Navigate(grantPrivOnTabPage);
        }

        private void RevokePriUserButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (PrivUserDataGrid.SelectedItem != null)
                {
                    DataRowView selectedUser = (DataRowView)PrivUserDataGrid.SelectedItem;

                    string tableName = selectedUser["TABLE_NAME"].ToString();
                    string privilege = selectedUser["PRIVILEGE"].ToString();

                    try
                    {
                        string query = "REVOKE " + privilege + " ON " + tableName + " FROM " + selectedUserName;

                        using (OracleCommand command = new OracleCommand(query, conn))
                        {
                            int rowSelected = command.ExecuteNonQuery();


                            if (rowSelected == -1)
                            {
                                MessageBox.Show("Drop user successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                UpdatePrivUserGrid();
                            }
                            else
                            {
                                MessageBox.Show("Cannot revoke privilege of user!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
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
                    MessageBox.Show("A role is required!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
    }
}
