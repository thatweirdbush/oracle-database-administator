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
    /// Interaction logic for TestPrivileges.xaml
    /// </summary>
    public partial class TestPrivileges : Page
    {

        //OracleConnection NewConnection ;
        OracleConnection alternate_user_connection = Database.Instance.Connection;
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
            selectedRole= role;
            selectedRoleName = selectedRole.RoleName;
            selectedUsername = username;
            selectedPassWord = password;
            alternate_user_connection = Database.Instance.AlternateConnection(selectedUsername, selectedPassWord);
            currentUserID = Database.Instance.CurrentUser;
            DataContext = this;
        }

        private void Page_Unloaded(object sender, RoutedEventArgs e)
        {
            //if (alternate_user_connection != null)
            //{
            //    alternate_user_connection.Dispose();
            //    alternate_user_connection = null;
            //}
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
                    String newValue = (e.EditingElement as TextBox)?.Text; // Sử dụng ?. để tránh lỗi nếu không phải TextBox

                    if (priv == "UPDATE")
                    {
                        if (priv_col == editedColumn || priv_col == "")
                        {
                            update_query = editedColumn + " = '" + newValue + "'";

                            update_query = string.Format("UPDATE SYS.{0} SET {1} WHERE {2}", table_name, update_query, condition);
                            MessageBox.Show(update_query, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                        else
                        {
                            MessageBox.Show($"\'Update\' permission DENIED on {editedColumn} column.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                    }
                    else if (priv == "INSERT")
                    {
                        insert_query += $"'{newValue}',";
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
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
                    "WHERE GRANTEE = '" + selectedRoleName + "' " +
                    "UNION ALL " +
                    "SELECT" +
                    "   TABLE_NAME," +
                    "   COLUMN_NAME," +
                    "   PRIVILEGE " +
                    "FROM SYS.all_col_privs " +
                    "WHERE GRANTEE = '" + selectedRoleName + "'";

                using (OracleCommand command = new OracleCommand(query, alternate_user_connection))
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

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Role.ViewPrivilegesOfRole(selectedRole));
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
                        query += " SELECT * FROM SYS." + table_name;

                        using (OracleCommand command = new OracleCommand(query, alternate_user_connection))
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
                            query = " SELECT * FROM SYS.UV_" + table_name;
                            using (OracleCommand command = new OracleCommand(query, alternate_user_connection))
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

                        query = " SELECT * FROM SYS." + table_name;
                        using (OracleCommand command = new OracleCommand(query, alternate_user_connection))
                        {
                            using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                            {
                                DataTable dataTable = new DataTable();
                                adapter.Fill(dataTable);
                                ResultViewDataGrid.ItemsSource = dataTable.DefaultView;
                            }
                        }
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

                        query = " SELECT * FROM SYS." + table_name;
                        using (OracleCommand command = new OracleCommand(query, alternate_user_connection))
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

                                if (columnName == "NGAYSINH" || columnName == "NGAYLAP")
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
                    string query = "";

                    if (priv != "SELECT" && priv != "INSERT")
                    {
                        query += " SELECT * FROM SYS." + table_name;

                        using (OracleCommand command = new OracleCommand(query, alternate_user_connection))
                        {
                            using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                            {
                                DataTable dataTable = new DataTable();
                                adapter.Fill(dataTable);
                                ResultViewDataGrid.ItemsSource = dataTable.DefaultView;
                            }
                        }
                    }

                    if (priv == "INSERT")
                    {
                        query += " SELECT * FROM SYS.UV_" + table_name + " WHERE 1=0";

                        using (OracleCommand command = new OracleCommand(query, alternate_user_connection))
                        {
                            using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                            {
                                DataTable dataTable = new DataTable();
                                adapter.Fill(dataTable);
                                ResultViewDataGrid.ItemsSource = dataTable.DefaultView;
                            }
                        }
                        insert_query = "INSERT INTO SYS." + table_name + " (";

                        // Lặp qua tất cả các cột trong DataGrid
                        foreach (DataGridColumn column in ResultViewDataGrid.Columns)
                        {
                            // Lấy tên cột
                            string columnName = column.Header.ToString();
                            if (columnName == "NGAYSINH" || columnName == "NGAYLAP")
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
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
    }
}
