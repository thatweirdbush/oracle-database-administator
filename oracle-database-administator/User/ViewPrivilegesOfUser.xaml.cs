﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
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
using Oracle.ManagedDataAccess.Client;

namespace oracle_database_administator.User
{
    /// <summary>
    /// Interaction logic for ViewPrivilegesOfUser.xaml
    /// </summary>
    public partial class ViewPrivilegesOfUser : Page
    {
        OracleConnection conn = Database.Instance.Connection;

        private UserInfo selectedUserInfo;

        public string currentUserID { get; set; }

        public string selectedUserName { get; set; }

        public ViewPrivilegesOfUser(UserInfo userInfo)
        {
            InitializeComponent();
            selectedUserInfo = userInfo;
            selectedUserName = selectedUserInfo.UserName;
            currentUserID = Database.Instance.CurrentUser;
            DataContext = this;
        }

        private void Page_Unloaded(object sender, RoutedEventArgs e)
        {
            
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            UpdatePrivUserGrid();
        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Dashboard());
            }
        }

        private void UpdatePrivUserGrid()
        {
            try
            {
                string query = "SELECT" +
                    "    GRANTOR," +
                    "    GRANTEE," +
                    "    TABLE_SCHEMA," +
                    "    TABLE_NAME," +
                    "    NULL AS COLUMN_NAME," +
                    "    PRIVILEGE," +
                    "    GRANTABLE," +
                    "    HIERARCHY," +
                    "    COMMON," +
                    "    TYPE," +
                    "    INHERITED " +
                    "FROM ALL_TAB_PRIVS " +
                    "WHERE GRANTEE = '" + selectedUserName + "' " +
                    "UNION ALL " +
                    "SELECT" +
                    "    GRANTOR," +
                    "    GRANTEE," +
                    "    TABLE_SCHEMA," +
                    "    TABLE_NAME," +
                    "    COLUMN_NAME," +
                    "    PRIVILEGE," +
                    "    GRANTABLE," +
                    "    NULL AS HIERARCHY," +
                    "    COMMON," +
                    "    NULL AS TYPE," +
                    "    INHERITED " +
                    "FROM all_col_privs " +
                    "WHERE GRANTEE = '" + selectedUserName + "'";

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

        private void PrivUserDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.User.ViewUserList());
            }
        }

        private void TestPrivUserButton_Click(object sender, RoutedEventArgs e)
        {
            // Tạo một instance của cửa sổ nhập mật khẩu
            PasswordWindow passwordWindow = new PasswordWindow();

            // Hiển thị cửa sổ nhập mật khẩu và chờ cho đến khi nó được đóng
            bool? result = passwordWindow.ShowDialog();

            // Kiểm tra xem cửa sổ nhập mật khẩu đã đóng hay không
            if (result == true)
            {
                // Lấy mật khẩu từ cửa sổ nhập mật khẩu
                string password = passwordWindow.Password;

                TestPrivileges testPrivileges = new TestPrivileges(selectedUserInfo, password);
                if (!testPrivileges.currentUserID.Equals(""))
                {
                    NavigationService.Navigate(testPrivileges);
                }
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
                else
                {
                    MessageBox.Show("Please select a user.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
            catch (Exception ex) 
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
    }
}
