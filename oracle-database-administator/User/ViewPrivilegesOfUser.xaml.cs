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
        OracleConnection conn = Database.Instance.Connection;
        Database Db = Database.Instance;

        private UserInfo selectedUserInfo;

        public string currentUserID { get; set; }

        public string selectedUserName { get; set; }

        public ViewPrivilegesOfUser(UserInfo userInfo)
        {
            InitializeComponent();
            selectedUserInfo = userInfo;
            selectedUserName = selectedUserInfo.UserName;
            currentUserID = Database.Instance.CurrentUser;

            DataContext = this;
        }

        private void Page_Unloaded(object sender, RoutedEventArgs e)
        {
            
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            UpdatePrivUserGrid();

        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Dashboard());
            }
        }

        /// <WARNING>
        /// TODO: SELECT PRIVILEGES FROM USER'S GRANTED ROLES
        /// </WARNING>
        private void UpdatePrivUserGrid()
        {
            PrivUserDataGrid.ItemsSource = Db.UpdateDataView(Db.PRIVS, selectedUserName);
        }

        private void PrivUserDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.User.ViewUserList());
            }
        }

        private void TestPrivUserButton_Click(object sender, RoutedEventArgs e)
        {
            // Tạo một instance của cửa sổ nhập mật khẩu
            PasswordWindow passwordWindow = new PasswordWindow();

            // Hiển thị cửa sổ nhập mật khẩu và chờ cho đến khi nó được đóng
            bool? result = passwordWindow.ShowDialog();

            // Kiểm tra xem cửa sổ nhập mật khẩu đã đóng hay không
            if (result == true)
            {
                // Lấy mật khẩu từ cửa sổ nhập mật khẩu
                string password = passwordWindow.Password;

                TestPrivileges testPrivileges = new TestPrivileges(selectedUserInfo, password);

                if (!testPrivileges.currentUserID.Equals(""))
                {
                    NavigationService.Navigate(testPrivileges);
                }
            }
        }

        private void EditPrivButton_Click(object sender, RoutedEventArgs e)
        {
            GrantPrivOnTable grantPrivOnTabPage = new GrantPrivOnTable(selectedUserInfo);
            NavigationService.Navigate(grantPrivOnTabPage);
        }    
    }
}
