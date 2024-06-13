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

namespace oracle_database_administator.SecurityAdmin
{
    /// <summary>
    /// Interaction logic for SecurityAdminDashboard.xaml
    /// </summary>
    public partial class SecurityAdminDashboard : Page
    {
        private OracleConnection conn = Database.Instance.Connection;
        private Database Db = Database.Instance;

        public SecurityAdminDashboard()
        {
            InitializeComponent();
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
        }

        private void ButtonSystemLog_Click(object sender, RoutedEventArgs e)
        {
            SystemLog systemLog = new SystemLog();
            NavigationService.Navigate(systemLog);
        }

        private void ButtonBackupRecovery_Click(object sender, RoutedEventArgs e)
        {
            BackupAndRecovery backupAndRecovery = new BackupAndRecovery();
            NavigationService.Navigate(backupAndRecovery);
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                Db.ClearUpConnection();
                mainWindow.MainFrame.Navigate(new Dashboard());
            }
        }
    }
}
