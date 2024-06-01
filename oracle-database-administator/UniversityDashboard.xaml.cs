using Oracle.ManagedDataAccess.Client;
using oracle_database_administator.Role;
using oracle_database_administator.User;
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

namespace oracle_database_administator
{
    /// <summary>
    /// Interaction logic for UniversityDashboard.xaml
    /// </summary>
    public partial class UniversityDashboard : Page
    {
        OracleConnection conn;

        public UniversityDashboard()
        {
            InitializeComponent();
        }

        private bool ConnectToServer()
        {
            // Nếu đã kết nối rồi thì không cần kết nối lại
            if (Database.Instance.ConnectionPassword != "")
            {
                conn = Database.Instance.Connection;
                return true;
            }

            bool windowClosed = false;
            while (!windowClosed)
            {
                PasswordWindow passwordWindow = new PasswordWindow();
                bool? result = passwordWindow.ShowDialog();

                // Xử lý trường hợp người dùng nhập mật khẩu
                if (result == true)
                {
                    Database.Instance.ConnectionUsername = passwordWindow.Username;
                    Database.Instance.ConnectionPassword = passwordWindow.Password;

                    conn = Database.Instance.Connection;
                    if (conn != null)
                    {
                        Console.WriteLine("Connection opened successfully!");
                        break;
                    }
                    else
                    {
                        Database.Instance.ConnectionPassword = "";
                        return false;
                    }
                }
                else
                {
                    // Xử lý trường hợp người dùng đóng cửa sổ
                    windowClosed = true;
                    return false;
                }
            }
            return true;
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            ConnectToServer();
        }

        private void UserButton_Click(object sender, RoutedEventArgs e)
        {
            if (conn == null)
            {
                if (ConnectToServer())
                {
                    ViewUserList viewUserList = new ViewUserList();
                    NavigationService.Navigate(viewUserList);
                }
            }
            else
            {
                ViewUserList viewUserList = new ViewUserList();
                NavigationService.Navigate(viewUserList);
            }
        }

        private void RoleButton_Click(object sender, RoutedEventArgs e)
        {
            if (conn == null)
            {
                if (ConnectToServer())
                {
                    ViewRoleList viewRoleList = new ViewRoleList();
                    NavigationService.Navigate(viewRoleList);
                }
            }
            else
            {
                ViewRoleList viewRoleList = new ViewRoleList();
                NavigationService.Navigate(viewRoleList);
            }
        }

        /// <summary>
        /// Back to Dashboard and delete current connection
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                Database.Instance.ConnectionPassword = "";
                Database.Instance.ConnectionUsername = "";
                Database.Instance.Disconnect();
                mainWindow.MainFrame.Navigate(new Dashboard());
            }
        }
    }
}
