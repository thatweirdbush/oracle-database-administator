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
using System.Windows.Shapes;

namespace oracle_database_administator.User
{
    /// <summary>
    /// Interaction logic for PasswordWindow.xaml
    /// </summary>
    // Thuộc tính để lưu trữ mật khẩu
    public partial class PasswordWindow : Window
    {
        public string Password { get; private set; }

        public PasswordWindow()
        {
            InitializeComponent();
        }

        private void OKButton_Click(object sender, RoutedEventArgs e)
        {
            // Lưu mật khẩu khi người dùng nhấn nút OK
            Password = PasswordBox.Password;

            // Đóng cửa sổ nhập mật khẩu
            DialogResult = true;
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            // Không lưu mật khẩu nếu người dùng nhấn nút Cancel
            Password = null;

            // Đóng cửa sổ nhập mật khẩu
            DialogResult = false;
        }
    }
}
