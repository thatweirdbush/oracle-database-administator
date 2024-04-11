using Oracle.ManagedDataAccess.Client;
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
    /// 


    public partial class GrantPrivOnTable : Page
    {

        OracleConnection conn;

        private UserInfo selectedUserInfo;

        public string selectedUserName { get; set; }

        public GrantPrivOnTable(UserInfo userInfo)
        {
            InitializeComponent();
            selectedUserInfo = userInfo;
            selectedUserName = selectedUserInfo.UserName;
            DataContext = this;
        }

        private void Page_Unloaded(object sender, RoutedEventArgs e)
        {
            if (conn != null)
            {
                conn.Dispose();
            }
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            conn = Database.Instance.Connection;
            try
            {
                if (conn.State == System.Data.ConnectionState.Open)
                {
                    Console.WriteLine("Connection opened successfully!");
                    UpdateTablerGrid();
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

        private void UpdateTablerGrid()
        {
            try
            {
                string query = "SELECT TABLE_NAME FROM DBA_TABLES WHERE OWNER = \'C##ADMIN\'";
                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        TableDataGrid.ItemsSource = dataTable.DefaultView;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void UpdatePrivUserGrid()
        {
            try
            {
                //string query1 = "SELECT * FROM ALL_TAB_PRIVS WHERE GRANTEE = '" + selectedUserName + "'";

                string query = "SELECT " +
                    "   COALESCE(t1.table_name, c.table_name) AS table_name, " +
                    "   c.column_name, " +
                    "   t1.privilege, " +
                    "   t1.GRANTABLE " +
                    "FROM  " +
                    "   ALL_TAB_PRIVS t1 " +
                    "FULL OUTER JOIN dba_col_privs c " +
                    "   ON t1.table_name = c.table_name AND t1.GRANTEE = c.GRANTEE " +
                    "WHERE " +
                    "   t1.GRANTEE = '" + selectedUserName +"' " +
                    "   OR c.GRANTEE = '" + selectedUserName + "'";

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

        private String SelectItemsListBox()
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

        public string EncloseInParentheses(string input)
        {
            return "(" + input + ")";
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
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Dashboard());
            }
        }

        private void GrantUserButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string tableName = txtTableName.Text;
                string colName = EncloseInParentheses(txtColumnName.Text);
                string privileges = SelectItemsListBox();
                string withGrantOptionString = (myCheckBoxGrantOption.IsChecked == true) ? " WITH GRANT OPTION" : "";
                string columnNameString = (colName != "()") ? colName : "";
                string query = "";

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
 
                // Check if there is no column selected
                if(columnNameString == "")
                {
                    query = "GRANT " + privileges + " ON " + tableName + " TO " + selectedUserName + withGrantOptionString;
                }
                // Check if required privileges are contained
                else if ((IsOnlyContains(privileges, "UPDATE") || IsOnlyContains(privileges, "SELECT, UPDATE") || IsOnlyContains(privileges, "UPDATE, SELECT")))
                {
                    query = "GRANT " + privileges + columnNameString + " ON " + tableName + " TO " + selectedUserName + withGrantOptionString;
                }
                else
                {
                    MessageBox.Show("No permission to grant " + privileges + " on column " + colName + ".\nPlease select other privileges.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    return;
                }

                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    int rowSelected = command.ExecuteNonQuery();

                    if (rowSelected == -1)
                    {
                        MessageBox.Show("Grant privilege successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        UpdatePrivUserGrid();
                    }
                    else
                    {
                        MessageBox.Show("Failed to grant this privilege!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }
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

                    if (privilege == "")
                    {
                        privilege = "UPDATE";
                    }
                    string query = "REVOKE " + privilege + " ON " + tableName + " FROM " + selectedUserName;

                    using (OracleCommand command = new OracleCommand(query, conn))
                    {
                        int rowSelected = command.ExecuteNonQuery();

                        if (rowSelected == -1)
                        {
                            MessageBox.Show("Revoke privilege successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                            UpdatePrivUserGrid();
                        }
                        else
                        {
                            MessageBox.Show("Failed to revoke this privilege!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
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

        private void BackViewPrivUserButton_Click(object sender, RoutedEventArgs e)
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

                    string query = "Select column_name from user_tab_columns WHERE TABLE_NAME = '" + row["TABLE_NAME"].ToString() + "'";
                    using (OracleCommand command = new OracleCommand(query, conn))
                    {
                        using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                        {
                            DataTable dataTable = new DataTable();
                            adapter.Fill(dataTable);
                            ColumnTableDataGrid.ItemsSource = dataTable.DefaultView;
                        }
                    }

                }
            }
            catch(Exception ex)
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
