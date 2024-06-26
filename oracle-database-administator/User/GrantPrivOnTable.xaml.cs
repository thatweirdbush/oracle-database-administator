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

namespace oracle_database_administator.User
{
    /// <summary>
    /// Interaction logic for GrantPrivOnTable.xaml
    /// </summary>

    public partial class GrantPrivOnTable : Page
    {

        OracleConnection conn = Database.Instance.Connection;
        Database Db = Database.Instance;
        private User selectedUserInfo;

        public string currentUserID { get; set; }

        public string selectedUserName { get; set; }

        public GrantPrivOnTable(User userInfo)
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
            UpdateTablerGrid();
            UpdatePrivUserGrid();
        }

        private void UpdateTablerGrid()
        {
            TableDataGrid.ItemsSource = Db.UpdateDataView(Db.TABLES, Database.DEFAULT_PREFIX);
        }

        private void UpdatePrivUserGrid()
        {
            PrivUserDataGrid.ItemsSource = Db.UpdateDataView(Db.PRIVS_SIMPLIFY, selectedUserName);
        }

        private string SelectItemsListBox()
        {
            List<string> selectedItems = new List<string>();

            // Duyệt qua từng mục trong ListBox
            foreach (var item in myListBox.Items)
            {
                // Kiểm tra xem mục có được chọn không
                ListBoxItem listBoxItem = (ListBoxItem)item;
                if (listBoxItem.IsSelected)
                {
                    // Nếu mục được chọn, thêm nội dung của mục đó vào danh sách
                    selectedItems.Add(listBoxItem.Content.ToString());
                }
            }
            // Gán danh sách các mục được chọn vào chuỗi temp, phân tách bằng dấu phẩy
            string temp = string.Join(", ", selectedItems);
            return temp;
        }

        public bool IsOnlyContains(string originalString, string subString)
        {
            if (originalString != null && subString != null)
            {
                // Sử dụng phương thức Equals để so sánh hai chuỗi
                return originalString.Equals(subString);
            }
            return false;
        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new SystemDashboard());
            }
        }

        private void GrantUserButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string tableName = txtTableName.Text;
                string colName = txtColumnName.Text;
                string privileges = SelectItemsListBox();
                string withGrantOptionString = (myCheckBoxGrantOption.IsChecked == true) ? " WITH GRANT OPTION " : null;

                // Check null privilege & table name selection
                if (privileges == "")
                {
                    MessageBox.Show("Select a privilege.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }
                if (tableName == "")
                {
                    MessageBox.Show("Select a table.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }
                if (colName != "" && !IsOnlyContains(privileges, "UPDATE") && !IsOnlyContains(privileges, "SELECT, UPDATE") && !IsOnlyContains(privileges, "UPDATE, SELECT")){
                    MessageBox.Show("No permission to grant " + privileges + " on column " + colName + ".\nPlease select other privileges.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }

                // Start granting privileges
                int status = Db.GrantPrivilege(privileges, selectedUserName, withGrantOptionString, tableName, colName);

                // If INSERT privilege is granted, automatically grant SELECT privilege on view with corresponding table name
                if (privileges.Contains("INSERT"))
                {
                    Db.GrantPrivilege("SELECT", selectedUserName, null, $"{Database.ADMIN_SCHEMA}{Database.DEFAULT_PREFIX_VIEW}{tableName}");
                }

                // Show notification when grant privilege successfully
                if (status == -1)
                {
                    MessageBox.Show("Grant privilege successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    UpdatePrivUserGrid();
                }
                else
                {
                    MessageBox.Show("Failed to grant this privilege!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                }            
                
                myListBox.SelectedItems.Clear();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
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

                    // Start revoking privileges
                    int status = Db.RevokePrivilege(privilege, selectedUserName, tableName);

                    // Show notification when grant privilege successfully
                    if (status == -1)
                    {
                        MessageBox.Show("Revoke privilege successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        UpdatePrivUserGrid();
                    }
                    else
                    {
                        MessageBox.Show("Failed to revoke this privilege!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }
                else
                {
                    MessageBox.Show("Select a privilege.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.User.ViewPrivilegesOfUser(selectedUserInfo));
            }
        }

        private void TableDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                DataRowView row = (DataRowView)TableDataGrid.SelectedItem;
                if (row != null)
                {
                    txtTableName.Text = row["TABLE_NAME"].ToString();
                    txtColumnName.Text = null;

                    ColumnTableDataGrid.ItemsSource = Db.UpdateDataView(Db.TABLE_COLUMNS, txtTableName.Text);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void ColumnTableDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                DataRowView row = (DataRowView)ColumnTableDataGrid.SelectedItem;
                if (row != null)
                {
                    txtColumnName.Text = row["COLUMN_NAME"].ToString();
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
    }
}
