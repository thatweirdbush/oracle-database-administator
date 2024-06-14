using Oracle.ManagedDataAccess.Client;
using oracle_database_administator.Class;
using System;
using System.Collections.Generic;
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
    /// Interaction logic for SystemLog.xaml
    /// </summary>
    public partial class SystemLog : Page
    {
        private MainViewModel MainViewModel = MainViewModel.Instance;
        private Database Db = Database.Instance;

        public SystemLog()
        {
            InitializeComponent();
            DataContext = this;
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            ButtonStdAudit_Click(null, null);
        }

        private void HideAllElements()
        {
            Grid_StandardAudit.Visibility = Visibility.Hidden;
            Grid_FGA.Visibility = Visibility.Hidden;
            Grid_AuditObjects.Visibility = Visibility.Hidden;
        }

        private void LogoutButton_Click(object sender, RoutedEventArgs e)
        {
            // Open a Confirmation dialog
            MessageBoxResult result = MessageBox.Show("Are you sure you want to exit?", "Exit", MessageBoxButton.YesNo, MessageBoxImage.Question);
            if (result == MessageBoxResult.No)
                return;

            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                // Disconnect from the server & reset the connection credentials
                Db.Disconnect();
                Db.ConnectionUsername = "";
                Db.ConnectionPassword = "";
                mainWindow.MainFrame.Navigate(new Dashboard());
            }
        }

        private void ButtonStdAudit_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_StandardAudit.Visibility = Visibility.Visible;
            Table_StandardAudit.ItemsSource = MainViewModel.StandardAudits;
        }

        private void ButtonFGA_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_FGA.Visibility = Visibility.Visible;
            Table_FGA.ItemsSource = MainViewModel.FGAs;
        }

        private void ButtonAuditObject_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AuditObjects.Visibility = Visibility.Visible;
            Table_AuditObjects.ItemsSource = MainViewModel.AuditObjects;
        }

        private void Table_StandardAudit_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_FGA_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
    }
}
