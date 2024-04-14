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

namespace oracle_database_administator
{
    /// <summary>
    /// Interaction logic for Dashboard.xaml
    /// </summary>
    public partial class Dashboard : Page
    {  
        public Dashboard()
        {
            InitializeComponent();

        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            if (Database.Instance.ConnectionPassword != "")
                return;

            PasswordWindow passwordWindow = new PasswordWindow();
            bool? result = passwordWindow.ShowDialog();

            if (result == true)
            {
                string password = passwordWindow.Password;
                Database.Instance.ConnectionPassword = password;
            }
        }

        private void UserButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.User.ViewUserList());
            }
        }

        private void RoleButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Role.ViewRoleList());
            }
        }
    }
}
