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
            //Db.ConnectToServer();
        }

        private void UserButton_Click(object sender, RoutedEventArgs e)
        {
            //if (conn == null)
            //{
            //    if (Db.ConnectToServer())
            //    {
            //        ViewUserList viewUserList = new ViewUserList();
            //        NavigationService.Navigate(viewUserList);
            //    }
            //}
            //else
            //{
            //    ViewUserList viewUserList = new ViewUserList();
            //    NavigationService.Navigate(viewUserList);
            //}
            ViewUserList viewUserList = new ViewUserList();
            NavigationService.Navigate(viewUserList);
        }

        private void RoleButton_Click(object sender, RoutedEventArgs e)
        {
            //if (conn == null)
            //{
            //    if (Db.ConnectToServer())
            //    {
            //        ViewRoleList viewRoleList = new ViewRoleList();
            //        NavigationService.Navigate(viewRoleList);
            //    }
            //}
            //else
            //{
            //    ViewRoleList viewRoleList = new ViewRoleList();
            //    NavigationService.Navigate(viewRoleList);
            //}
            ViewRoleList viewRoleList = new ViewRoleList();
            NavigationService.Navigate(viewRoleList);
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                // Disconnect from the server & reset the connection credentials
                Db.Disconnect();
                Db.ConnectionUsername = "";
                Db.ConnectionPassword = "";
                mainWindow.MainFrame.Navigate(new Dashboard());
            }
        }
    }
}
