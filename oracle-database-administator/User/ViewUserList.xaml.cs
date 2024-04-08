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
    /// Interaction logic for ViewUserList.xaml
    /// </summary>
    public partial class ViewUserList : Page
    {
        OracleConnection conn;
        string conStr = @"DATA SOURCE=localhost:1521/XE;DBA PRIVILEGE=SYSDBA;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD=244466666";

        public ViewUserList()
        {
            InitializeComponent();
            conn = new OracleConnection(conStr);

            try
            {
                conn.Open();
                if (conn.State == System.Data.ConnectionState.Open)
                {
                    MessageBox.Show("Connection opened succesfully!");
                    UpdateGrid();

                    //conn.Close();
                    //MessageBox.Show("Connection closed.");
                }
                else
                {
                    MessageBox.Show("Close connection failed.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Connection error: " + ex.Message);
            }
        }

        private void UpdateGrid()
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
                        DataGrid.ItemsSource = dataTable.DefaultView;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message);
            }
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                int employeeID = Convert.ToInt32(IDTextBox.Text);
                string firstName = FirstNameTextBox.Text;
                string lastName = LastNameTextBox.Text;
                string email = EmailTextBox.Text;

                string query = "INSERT INTO SYS.TEST_EMPLOYEES (employee_id, first_name, last_name, email) VALUES (:employee_id, :first_name, :last_name, :email)";

                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    command.Parameters.Add(new OracleParameter(":employee_id", employeeID));
                    command.Parameters.Add(new OracleParameter(":first_name", firstName));
                    command.Parameters.Add(new OracleParameter(":last_name", lastName));
                    command.Parameters.Add(new OracleParameter(":email", email));

                    int rowsInserted = command.ExecuteNonQuery();

                    if (rowsInserted > 0)
                    {
                        MessageBox.Show("Inserted succesfully!");
                        UpdateGrid();
                    }
                    else
                    {
                        MessageBox.Show("No data changes.");
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Insert Error: " + ex.Message);
            }
        }
    }
}
