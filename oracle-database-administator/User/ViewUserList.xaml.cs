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
    /// Interaction logic for ViewUserList.xaml
    /// </summary>
    public partial class ViewUserList : Page
    {
        OracleConnection conn;

        public ViewUserList()
        {
            InitializeComponent();
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
                MessageBox.Show("Error: " + ex.Message);
            }
        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Dashboard());
            }
        }
      
        // Sử dụng sự kiện Unloaded để đảm bảo rằng kết nối được đóng khi chuyển khỏi Page
        private void Page_Unloaded(object sender, RoutedEventArgs e)  {
            if (conn != null)
            {
                conn.Dispose();
            }
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            conn = Database.Instance.Connection;
            try {
                if (conn.State == System.Data.ConnectionState.Open)
                {
                    Console.WriteLine("Connection opened successfully!");
                    UpdateGrid();
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

        private void InsertButton_Click(object sender, RoutedEventArgs e){
            try
            {
             string userName = txtUserName.Text;
                string passWord = txtPassword.Text;

                string query = @"BEGIN
                            EXECUTE IMMEDIATE 'ALTER SESSION SET ""_ORACLE_SCRIPT"" = TRUE';
                            EXECUTE IMMEDIATE 'create user " + userName + " identified by " + passWord + "';" +
                            " END;";


                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    //command.Parameters.Add(new OracleParameter(":username", OracleDbType.Varchar2)).Value = userName;
                    //command.Parameters.Add(new OracleParameter(":password", OracleDbType.Varchar2)).Value = passWord;

                    int rowSelected = command.ExecuteNonQuery();


                    if (rowSelected == -1)
                    {
                        MessageBox.Show("Create user successfully!");
                        UpdateUserGrid();
                    }
                    else
                    {
                        MessageBox.Show("Cannot create user!");
                    }
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show("Create error: " + ex.Message);
            }
        }

        private void DeleteButton_Click(object sender, RoutedEventArgs e)
        {

        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Dashboard());
            }
        }

        private void RolesUserButton_Click(object sender, RoutedEventArgs e)
        {

        }

        private void PriUserButton_Click(object sender, RoutedEventArgs e)
        {

        }
    }
}
