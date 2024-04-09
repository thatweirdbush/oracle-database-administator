using System;
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
        OracleConnection conn;

        private UserInfo selectedUserInfo;

        public string selectedUserName { get; set; }

        public ViewPrivilegesOfUser(UserInfo userInfo)
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
                    UpdatePrivUserGrid();
                }
                else
                {
                    MessageBox.Show("Failed to open connection.");
                }
            }

            catch (Exception ex)
            {
                MessageBox.Show("Connection error: " + ex.Message);
            }
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
                MessageBox.Show("Error: " + ex.Message);
            }
        }

        private void PrivUserDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            
        }

        private void BackViewUserButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.User.ViewUserList());
            }
        }

        private void TestPrivUserButton_Click(object sender, RoutedEventArgs e)
        {

        }

        private void GrantUserButton_Click(object sender, RoutedEventArgs e)
        {

        }

        private void RevokePriUserButton_Click(object sender, RoutedEventArgs e)
        {

        }
    }
}
