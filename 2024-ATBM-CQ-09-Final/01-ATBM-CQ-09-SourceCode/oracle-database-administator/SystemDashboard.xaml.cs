using Oracle.ManagedDataAccess.Client;
using oracle_database_administator.Role;
using oracle_database_administator.User;
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

namespace oracle_database_administator
{
    /// <summary>
    /// Interaction logic for SystemDashboard.xaml
    /// </summary>
    public partial class SystemDashboard : Page
    {
        private OracleConnection conn = Database.Instance.Connection;
        private Database Db = Database.Instance;

        public SystemDashboard()
        {
            InitializeComponent();
        }       

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
        }

        private void UserButton_Click(object sender, RoutedEventArgs e)
        {
            ViewUserList viewUserList = new ViewUserList();
            NavigationService.Navigate(viewUserList);
        }

        private void RoleButton_Click(object sender, RoutedEventArgs e)
        {
            ViewRoleList viewRoleList = new ViewRoleList();
            NavigationService.Navigate(viewRoleList);
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            // Open Confirmation Dialog
            MessageBoxResult result = MessageBox.Show("Are you sure you want to logout?", "Logout", MessageBoxButton.YesNo, MessageBoxImage.Question);
            if (result == MessageBoxResult.No)
            {
                return;
            }
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                Db.ClearUpConnection();
                mainWindow.MainFrame.Navigate(new Dashboard());
            }
        }
    }
}
