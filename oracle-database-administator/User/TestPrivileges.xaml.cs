using Oracle.ManagedDataAccess.Client;
using System;
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
    /// Interaction logic for TestPrivileges.xaml
    /// </summary>
    public partial class TestPrivileges : Page
    {

        OracleConnection NewConnection ;

        private UserInfo selectedUserInfo;
        public string selectedUserName { get; set; }

        public string currentUserID { get; set; }

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
                DataRowView row = (DataRowView)PrivUserDataGrid.SelectedItem;
                if (row != null)
                {
                    string table_name = row["TABLE_NAME"].ToString();
                    string column_str = row["COLUMN_NAME"].ToString();
                    string priv = row["PRIVILEGE"].ToString();
                    string query = "";


                    if (priv == "SELECT")
                    {
                        MessageBox.Show(priv);
                        query += " SELECT * FROM SYS." + table_name;
                    } 
                    else if (priv == "INSERT")
                    {

                    }
                    else if (priv == "UPDATE")
                    {

                    }
                    else if (priv == "DELETE")
                    {

                    }

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

        }

        private void PrivUserDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
    }
}
