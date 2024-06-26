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
using oracle_database_administator;

namespace oracle_database_administator.Role
{
    /// <summary>
    /// Interaction logic for TestPrivileges.xaml
    /// </summary>
    public partial class TestPrivileges : Page
    {
        OracleConnection alternate_user_connection = Database.Instance.Connection;
        Database Db = Database.Instance;
        private Role selectedRole;
        public string selectedRoleName{ get; set; }
        public string selectedUsername { get; set; }
        public string selectedPassWord { get; set; }
        public string currentUserID { get; set; }

        private string editedColumn = "";
        string table_name = "";
        string delete_query = "";
        string update_query = "";
        string insert_query = "";
        string condition = "";

        public TestPrivileges(Role role, string username, string password)
        {
            InitializeComponent();
            selectedRole = role;
            selectedRoleName = selectedRole.RoleName;
            selectedUsername = username;
            selectedPassWord = password;

            // Create alternate connection
            // SYS connection still exists
            alternate_user_connection = Database.Instance.AlternateConnection(selectedUsername, selectedPassWord);
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

        private void ResultViewDataGrid_CellEditEnding(object sender, DataGridCellEditEndingEventArgs e)
        {
            try
            {
                DataRowView row_priv = (DataRowView)PrivUserDataGrid.SelectedItem;
                if (row_priv != null)
                {
                    string priv = row_priv["PRIVILEGE"].ToString();
                    string priv_col = row_priv["COLUMN_NAME"].ToString();
                    string table_name = row_priv["TABLE_NAME"].ToString();

                    //Lấy cột được chỉnh sửa
                    editedColumn = e.Column.Header.ToString();

                    //Lấy giá trị mới
                    string newValue = (e.EditingElement as TextBox)?.Text; // Sử dụng ?. để tránh lỗi nếu không phải TextBox

                    if (priv == "UPDATE")
                    {
                        if (priv_col == editedColumn || priv_col == "")
                        {
                            update_query = editedColumn + " = '" + newValue + "'";
                            update_query = $"UPDATE {Database.ADMIN_SCHEMA}{table_name} SET {update_query} WHERE {condition}";
                            //MessageBox.Show(update_query, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                        else
                        {
                            MessageBox.Show($"UPDATE permission DENIED on {editedColumn} column.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                    }
                    else if (priv == "INSERT")
                    {
                        insert_query += $"'{newValue}',";
                    }
                }
            }
            catch (Exception ex) {
                MessageBox.Show("Error: " + ex.Message);
            }
        }

        private void UpdatePrivUserGrid()
        {
            PrivUserDataGrid.ItemsSource = Db.UpdateDataView(Db.PRIVS_SIMPLIFY, selectedRoleName);
        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
        {
            if (alternate_user_connection != null)
            {
                Database.Instance.Disconnect();
            }
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new SystemDashboard());
            }
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (alternate_user_connection != null)
            {
                Database.Instance.Disconnect();
            }
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new ViewPrivilegesOfRole(selectedRole));
            }
        }

        private void ExecuteButtonButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                DataRowView row_priv = (DataRowView)PrivUserDataGrid.SelectedItem;
                DataRowView row_col = (DataRowView)ResultViewDataGrid.SelectedItem;

                if (row_priv != null)
                {
                    table_name = row_priv["TABLE_NAME"].ToString();
                    string column_str = row_priv["COLUMN_NAME"].ToString();
                    string priv = row_priv["PRIVILEGE"].ToString();

                    if (priv == "SELECT")
                    {
                        ResultViewDataGrid.ItemsSource = Db.GetAnyTable($"{Database.ADMIN_SCHEMA}{table_name}");
                    }
                    else if (priv == "INSERT")
                    {
                        if (insert_query != "")
                        {
                            // Loại bỏ dấu phẩy cuối cùng
                            insert_query = insert_query.Remove(insert_query.Length - 1);

                            // Đóng câu truy vấn
                            insert_query += ")";

                            using (OracleCommand command = new OracleCommand(insert_query, alternate_user_connection))
                            {
                                int rowSelected = command.ExecuteNonQuery();

                                if (rowSelected == 1)
                                {
                                    MessageBox.Show("Executed \'Insert\' successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                }
                                else
                                {
                                    MessageBox.Show("Failed to execute \'Insert\'!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                }
                            }
                            ResultViewDataGrid.ItemsSource = Db.GetAnyTable($"{Database.ADMIN_SCHEMA}{Database.DEFAULT_PREFIX_VIEW}{table_name}");
                        }
                    }
                    else if (priv == "UPDATE")
                    {
                        if (update_query != "")
                        {
                            using (OracleCommand command = new OracleCommand(update_query, alternate_user_connection))
                            {
                                int rowSelected = command.ExecuteNonQuery();

                                if (rowSelected == 1)
                                {
                                    MessageBox.Show("Executed \'Update\' successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                }
                                else
                                {
                                    MessageBox.Show("Failed to execute \'Update\'!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                }
                            }
                        }
                        ResultViewDataGrid.ItemsSource = Db.GetAnyTable($"{Database.ADMIN_SCHEMA}{table_name}");
                    }
                    else if (priv == "DELETE")
                    {
                        if (delete_query != "")
                        {
                            using (OracleCommand command = new OracleCommand(delete_query, alternate_user_connection))
                            {
                                int rowSelected = command.ExecuteNonQuery();

                                if (rowSelected == 1)
                                {
                                    MessageBox.Show("Executed \'Delete\' successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                }
                                else
                                {
                                    MessageBox.Show("Failed to execute \'Delete\'!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                }
                            }
                        }
                        ResultViewDataGrid.ItemsSource = Db.GetAnyTable($"{Database.ADMIN_SCHEMA}{table_name}");
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void ResultViewDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                DataRowView row_priv = (DataRowView)PrivUserDataGrid.SelectedItem;
                if (row_priv != null)
                {
                    string priv = row_priv["PRIVILEGE"].ToString();

                    if (priv != "INSERT")
                    {
                        condition = "";
                        DataRowView selectedRow = (DataRowView)ResultViewDataGrid.SelectedItem;

                        if (selectedRow != null)
                        {
                            // Lấy danh sách các cột trong DataGrid
                            foreach (DataGridColumn column in ResultViewDataGrid.Columns)
                            {
                                // Lấy tên của cột
                                string columnName = column.Header.ToString();

                                /// <WARNING>
                                /// TODO: FIX DATETIME EXCEPTION
                                /// </WARNING>
                                if (columnName == "NGSINH" || columnName == "NGAYGUI")
                                {
                                    continue;
                                }

                                // Lấy dữ liệu từ cột được chọn
                                object cellValue = ((DataRowView)ResultViewDataGrid.SelectedItem)[columnName];

                                // Kiểm tra giá trị của cột có null không trước khi thêm vào điều kiện
                                if (cellValue != null)
                                {
                                    // Nối chuỗi vào điều kiện
                                    if (!string.IsNullOrEmpty(condition))
                                    {
                                        condition += " AND ";
                                    }
                                    condition += $"{columnName} = '{cellValue}'";
                                }
                            }
                            delete_query = $"DELETE FROM {Database.ADMIN_SCHEMA}{table_name} WHERE {condition}";
                        }
                    }
                }
            }
            catch (Exception)
            {
                //MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void PrivUserDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                DataRowView row_priv = (DataRowView)PrivUserDataGrid.SelectedItem;
                if (row_priv != null)
                {
                    table_name = row_priv["TABLE_NAME"].ToString();
                    string column_str = row_priv["COLUMN_NAME"].ToString();
                    string priv = row_priv["PRIVILEGE"].ToString();

                    if (priv == "SELECT")
                    {
                        // Reset result table
                        ResultViewDataGrid.ItemsSource = null;
                    }
                    else if (priv == "INSERT")
                    {
                        /// <NOTE>
                        /// Reason to put false condition '1=0' is because
                        /// we want to get the structure of the table when inserting
                        /// after inserting, we can get select data later
                        /// <NOTE>
                        string false_condition = "1=0";
                        ResultViewDataGrid.ItemsSource = Db.GetAnyTable($"{Database.ADMIN_SCHEMA}{Database.DEFAULT_PREFIX_VIEW}{table_name}", false_condition);
                        insert_query = $"INSERT INTO {Database.ADMIN_SCHEMA}{table_name} (";

                        // Lặp qua tất cả các cột trong DataGrid
                        foreach (DataGridColumn column in ResultViewDataGrid.Columns)
                        {
                            // Lấy tên cột
                            string columnName = column.Header.ToString();

                            /// <WARNING>
                            /// TODO: FIX DATETIME EXCEPTION
                            /// </WARNING>
                            if (columnName == "NGSINH" || columnName == "NGAYGUI")
                            {
                                continue;
                            }
                            // Thêm tên cột vào câu truy vấn INSERT
                            insert_query += columnName + ",";
                        }
                        // Loại bỏ dấu phẩy cuối cùng
                        insert_query = insert_query.Remove(insert_query.Length - 1);

                        // Thêm phần VALUES vào câu truy vấn
                        insert_query += ") VALUES (";
                    }
                    else
                    {
                        ResultViewDataGrid.ItemsSource = Db.GetAnyTable($"{Database.ADMIN_SCHEMA}{table_name}");
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
