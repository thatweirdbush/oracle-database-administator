﻿using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.Entity.Core.Common.CommandTrees.ExpressionBuilder;
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
    /// Interaction logic for TestPrivileges.xaml
    /// </summary>
    public partial class TestPrivileges : Page
    {

        OracleConnection NewConnection ;

        private UserInfo selectedUserInfo;
        public string selectedUserName { get; set; }

        public string currentUserID { get; set; }


        string table_name = "";
        string delete_query = "";


        public TestPrivileges(UserInfo userInfo)
        {
            InitializeComponent();
            selectedUserInfo = userInfo;
            selectedUserName = selectedUserInfo.UserName;

            string NewConnStr = AlternateConnectionString(selectedUserName);

            NewConnection = new OracleConnection(NewConnStr);

            NewConnection.Open();

            currentUserID = USER(NewConnection);

            SelectedUserTextBlock.DataContext = this;
            CurrentUserTextBlock.DataContext = this;
        }

        private void Page_Unloaded(object sender, RoutedEventArgs e)
        {
            if (NewConnection != null)
            {
                NewConnection.Dispose();
                NewConnection = null;
            }
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                if (NewConnection.State == System.Data.ConnectionState.Open)
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
        
        // Hàm thay đổi connection theo selected User_name => trả về string
        private String AlternateConnectionString(String user)
        {
            String connectionString = "DATA SOURCE=localhost:1521/XE;PERSIST SECURITY INFO=True;USER ID="+user+" ;PASSWORD=" + user;

            return connectionString;
        }

        private String USER(OracleConnection connection)
        {
            String user = "";
            try
            {
                string query = "SELECT USER FROM dual";
                using (OracleCommand command = new OracleCommand(query, connection))
                {
                    object result = command.ExecuteScalar();
                    if (result != null)
                    {
                        user = result.ToString();
                    }

                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
            return user;
        }

        private void UpdatePrivUserGrid()
        {
            try
            {
                string query = "SELECT" +
                    "    TABLE_NAME," +
                    "    NULL AS COLUMN_NAME," +
                    "    PRIVILEGE " +
                    "FROM SYS.ALL_TAB_PRIVS " +
                    "WHERE GRANTEE = '" + selectedUserName + "' " +
                    "UNION ALL " +
                    "SELECT" +
                    "   TABLE_NAME," +
                    "   COLUMN_NAME," +
                    "   PRIVILEGE " +
                    "FROM SYS.all_col_privs " +
                    "WHERE GRANTEE = '" + selectedUserName + "'";

                using (OracleCommand command = new OracleCommand(query, NewConnection))
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

        private void BackViewPrivUserButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.User.ViewPrivilegesOfUser(selectedUserInfo));
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
                    string query = "";


                    if (priv == "SELECT")
                    {
                        MessageBox.Show(priv);
                        query += " SELECT * FROM SYS." + table_name;

                        using (OracleCommand command = new OracleCommand(query, NewConnection))
                        {
                            using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                            {
                                DataTable dataTable = new DataTable();
                                adapter.Fill(dataTable);
                                ResultViewDataGrid.ItemsSource = dataTable.DefaultView;
                            }
                        }
                    } 
                    else if (priv == "INSERT")
                    {

                    }
                    else if (priv == "UPDATE")
                    {

                    }
                    else if (priv == "DELETE")
                    {
                        if (delete_query != "")
                        {
                            using (OracleCommand command = new OracleCommand(delete_query, NewConnection))
                            {
                                MessageBox.Show("Executed \'Delete\' successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);

                                using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                                {
                                    DataTable dataTable = new DataTable();
                                    adapter.Fill(dataTable);
                                    ResultViewDataGrid.ItemsSource = dataTable.DefaultView;
                                }
                            }
                        }

                        query = " SELECT * FROM SYS." + table_name;
                        using (OracleCommand command = new OracleCommand(query, NewConnection))
                        {
                            using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                            {
                                DataTable dataTable = new DataTable();
                                adapter.Fill(dataTable);
                                ResultViewDataGrid.ItemsSource = dataTable.DefaultView;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void ColumnTableDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void ResultViewDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            DataRowView selectedRow = (DataRowView)ResultViewDataGrid.SelectedItem;
            if (selectedRow != null)
            {
                string condition = "";

                // Lấy danh sách các cột trong DataGrid
                foreach (DataGridColumn column in ResultViewDataGrid.Columns)
                {
                    // Lấy tên của cột
                    string columnName = column.Header.ToString();

                    if (columnName == "NGSINH")
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

                delete_query = string.Format("DELETE FROM SYS.{0} WHERE {1}", table_name, condition);
                //MessageBox.Show(delete_query, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }           
        }

        private void PrivUserDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                DataRowView row_priv = (DataRowView)PrivUserDataGrid.SelectedItem;
                //DataRowView row_col = (DataRowView)ResultViewDataGrid.SelectedItem;
                if (row_priv != null)
                {
                    table_name = row_priv["TABLE_NAME"].ToString();
                    string column_str = row_priv["COLUMN_NAME"].ToString();
                    string priv = row_priv["PRIVILEGE"].ToString();
                    string query = "";


                    if (priv == "SELECT")
                    {
                        query += " SELECT * FROM SYS." + table_name;

                        using (OracleCommand command = new OracleCommand(query, NewConnection))
                        {
                            using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                            {
                                DataTable dataTable = new DataTable();
                                adapter.Fill(dataTable);
                                ResultViewDataGrid.ItemsSource = dataTable.DefaultView;
                            }
                        }
                    }
                    else if (priv == "INSERT")
                    {

                    }
                    else if (priv == "UPDATE")
                    {

                    }
                    else if (priv == "DELETE")
                    {
                        query += "SELECT * FROM SYS." + table_name;
                        using (OracleCommand command = new OracleCommand(query, NewConnection))
                        {
                            using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                            {
                                DataTable dataTable = new DataTable();
                                adapter.Fill(dataTable);
                                ResultViewDataGrid.ItemsSource = dataTable.DefaultView;
                            }
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
