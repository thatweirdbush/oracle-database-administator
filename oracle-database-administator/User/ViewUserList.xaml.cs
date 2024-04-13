﻿using Oracle.ManagedDataAccess.Client;
using System;
using System.CodeDom.Compiler;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
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

namespace oracle_database_administator.User
{
    /// <summary>
    /// Interaction logic for ViewUserList.xaml
    /// </summary>
    public partial class ViewUserList : Page
    {
        OracleConnection conn = Database.Instance.Connection;

        private bool dataGridSelectionEnabled = true;

        public string currentUserID { get; set; }

        public ViewUserList()
        {
            InitializeComponent();
            currentUserID = Database.Instance.CurrentUser;
            DataContext = this;
        }

        private void ModeVisible_UserDataGrid(bool dataGridSelectionEnabled)
        {
            if (dataGridSelectionEnabled)
            {
                for (int col = 0; col < 2; col++)
                {
                    UserDataGrid.Columns[col].Visibility = Visibility.Collapsed; 
                }
                for (int col = 2; col < 9; col++) { 
                    UserDataGrid.Columns[col].Visibility = Visibility.Visible;
                }
            }
            else
            {
                for (int col = 0; col < 2; col++)
                {
                    UserDataGrid.Columns[col].Visibility = Visibility.Visible;
                }
                for (int col = 2; col < 9; col++)
                {
                    UserDataGrid.Columns[col].Visibility = Visibility.Collapsed;
                }
            }
        }

        private void UpdateUserGrid()
        {
            try
            {
                string query = "SELECT * FROM SYS.ALL_USERS";
                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        UserDataGrid.ItemsSource = dataTable.DefaultView;
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
                mainWindow.MainFrame.Navigate(new Dashboard());
            }
        }
      
        // Sử dụng sự kiện Unloaded để đảm bảo rằng kết nối được đóng khi chuyển khỏi Page
        private void Page_Unloaded(object sender, RoutedEventArgs e)  {
            
        }

        private void Page_Loaded(object sender, RoutedEventArgs e) {
            UpdateUserGrid();
        }

        private void InsertButton_Click(object sender, RoutedEventArgs e){
            try
            {
                if (!string.IsNullOrEmpty(txtUserName.Text))
                {
                    ModeVisible_UserDataGrid(false);

                    string userName = txtUserName.Text;
                    string passWord = txtPassword.Text;

                    string query = @"BEGIN
                            EXECUTE IMMEDIATE 'ALTER SESSION SET ""_ORACLE_SCRIPT"" = TRUE';
                            EXECUTE IMMEDIATE 'create user " + userName + " identified by " + passWord + "'; " +
                            "EXECUTE IMMEDIATE 'GRANT CONNECT TO " + userName + "'; " + 
                                " END;";

                    using (OracleCommand command = new OracleCommand(query, conn))
                    {
                        int rowSelected = command.ExecuteNonQuery();

                        if (rowSelected == -1)
                        {
                            MessageBox.Show("Create user successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                            dataGridSelectionEnabled = true;
                            UpdateUserGrid();
                        }
                        else
                        {
                            MessageBox.Show("Cannot create user!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
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
                if (dataGridSelectionEnabled)
                {
                    string userName = txtUserName.Text;
                    txtUserName.Text = string.Empty;

                    if (!string.IsNullOrEmpty(userName))
                    {
                        // Kiểm tra xem username có phải là "SYS" không
                        if (userName.IndexOf("SYS", StringComparison.OrdinalIgnoreCase) != -1)
                        {
                            MessageBox.Show("No permission to delete this user.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                            return; // Không thực hiện tiếp các bước sau khi kiểm tra
                        }
                        string query = @"BEGIN
                            EXECUTE IMMEDIATE 'ALTER SESSION SET ""_ORACLE_SCRIPT"" = TRUE';
                            EXECUTE IMMEDIATE 'drop user " + userName + "';" +
                            " END;";

                        using (OracleCommand command = new OracleCommand(query, conn))
                        {
                            int rowSelected = command.ExecuteNonQuery();


                            if (rowSelected == -1)
                            {
                                MessageBox.Show("Drop user successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                UpdateUserGrid();
                            }
                            else
                            {
                                MessageBox.Show("Cannot drop user!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                            }
                        }
                    }
                    else
                    {
                        MessageBox.Show("No user selected!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
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
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null && dataGridSelectionEnabled == true)
            {
                mainWindow.MainFrame.Navigate(new Dashboard());
            }
            else if (Application.Current.MainWindow is MainWindow mainWindow2 && mainWindow2.MainFrame != null && dataGridSelectionEnabled == false)
            {
                mainWindow2.MainFrame.Navigate(new ViewUserList());
            }
        }

        private void RolesUserButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                DeleteUserButton.Visibility = Visibility.Collapsed;
                RoleUserButton.Visibility = Visibility.Collapsed;
                ModeVisible_UserDataGrid(dataGridSelectionEnabled);

                string query = "SELECT * FROM SYS.DBA_ROLE_PRIVS";
                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        UserDataGrid.ItemsSource = dataTable.DefaultView;
                    }
                }
                dataGridSelectionEnabled = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void PriUserButton_Click(object sender, RoutedEventArgs e)
        {
            if (UserDataGrid.SelectedItem != null)
            {
                // Lấy dữ liệu từ dòng được chọn
                DataRowView selectedUser = (DataRowView)UserDataGrid.SelectedItem;
                UserInfo selectedUserInfo;
                if (dataGridSelectionEnabled)
                {
                    selectedUserInfo = new UserInfo(selectedUser["USERNAME"].ToString());
                }
                else
                {
                    selectedUserInfo = new UserInfo(selectedUser["GRANTEE"].ToString());
                }
                ViewPrivilegesOfUser privilegesPage = new ViewPrivilegesOfUser(selectedUserInfo);
                NavigationService.Navigate(privilegesPage);
            }
            else
            {
                MessageBox.Show("Please select a user.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void UserDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                if (dataGridSelectionEnabled)
                {
                    if (UserDataGrid.SelectedItem != null)
                    {
                        DataRowView row = (DataRowView)UserDataGrid.SelectedItem;
                        if (row != null)
                        {
                            txtUserName.Text = row["USERNAME"].ToString();
                        }
                    }
                }
                else
                {
                    if (UserDataGrid.SelectedItem != null)
                    {
                        DataRowView row = (DataRowView)UserDataGrid.SelectedItem;
                        if (row != null)
                        {
                            txtUserName.Text = row["GRANTEE"].ToString();
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
