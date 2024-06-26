﻿using Oracle.ManagedDataAccess.Client;
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
        Database Db = Database.Instance;

        private Role selectedRole;
        public string selectedRoleName { get; set; }
        public string currentUserID { get; set; }

        public ViewPrivilegesOfRole(Role role)
        {
            InitializeComponent();
            selectedRole = role;
            selectedRoleName = selectedRole.RoleName;
            currentUserID = Database.Instance.CurrentUser;
            DataContext = this;
        }     

        // Sử dụng sự kiện Unloaded để đảm bảo rằng kết nối được đóng khi chuyển khỏi Page
        private void Page_Unloaded(object sender, RoutedEventArgs e)
        {

        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            UpdatePrivRoleGrid();
        }

        /// <WARNING>
        /// TODO: SELECT PRIVILEGES FROM USER'S GRANTED ROLES
        /// </WARNING>
        private void UpdatePrivRoleGrid()
        {
            PrivUserDataGrid.ItemsSource = Db.UpdateDataView(Db.PRIVS, selectedRoleName);
        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new SystemDashboard());
            }
        }

        private void PrivUserDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new ViewRoleList());
            }
        }

        private void TestPrivUserButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // Gán role hiện tại cho user mặc định `TEST_USER`
                string username = "TEST_USER";
                string password = "123";
                string query = "GRANT " + selectedRoleName + " TO " + username;

                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    int rowSelected = command.ExecuteNonQuery();

                    if (rowSelected == -1)
                    {
                        //MessageBox.Show($"Granted {selectedRoleName} to {username} successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        MessageBox.Show($"Default test user: {username}", "Successfully Connected", MessageBoxButton.OK, MessageBoxImage.Information);
                      
                        // Truyền mật khẩu sang trang hoặc lớp khác
                        if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
                        {
                            mainWindow.MainFrame.Navigate(new TestPrivileges(selectedRole, username, password));
                        }
                    }
                    else
                    {
                        MessageBox.Show($"Failed to grant {selectedRoleName} to {username}.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void EditPrivButton_Click(object sender, RoutedEventArgs e)
        {
            GrantPrivOnTable grantPrivOnTabPage = new GrantPrivOnTable(selectedRole);
            NavigationService.Navigate(grantPrivOnTabPage);
        }
    }
}
