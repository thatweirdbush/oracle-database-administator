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
using Oracle.ManagedDataAccess.Client;
using oracle_database_administator.Class;

namespace oracle_database_administator.Teacher
{
    /// <summary>
    /// Interaction logic for TeacherDashboard.xaml
    /// </summary>
    public partial class TeacherDashboard : Page
    {
        private MainViewModel MainViewModel = MainViewModel.Instance;
        private Database Db = Database.Instance;
        private Personnel personnel = null;

        public TeacherDashboard()
        {
            InitializeComponent();
            DataContext = this;
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            GetUserDataContext();
        }

        private void GetUserDataContext()
        {
            personnel = Db.LoadSingleLineDataContext<Personnel>(Db.PERSONNELS);
            Grid_DisplayData.DataContext = personnel;
        }

        private void HideAllElements()
        {
            // Hide all grids
            Grid_UserInfo.Visibility = Visibility.Collapsed;
            Grid_Unit.Visibility = Visibility.Collapsed;
            Grid_AcademicPlan.Visibility = Visibility.Collapsed;
            Grid_StudentList.Visibility = Visibility.Collapsed;

            // Hide elements in the Academic Plan grid
            Table_DsHocPhan.Visibility = Visibility.Collapsed;
            Table_KeHoachMo.Visibility = Visibility.Collapsed;
            Table_PhanCong.Visibility = Visibility.Collapsed;
            Table_DangKy.Visibility = Visibility.Collapsed;
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

        private void TTCN_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_UserInfo.Visibility = Visibility.Visible;
        }

        private void TTDonVi_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_Unit.Visibility = Visibility.Visible;
            Table_DonVi.ItemsSource = MainViewModel.Units;
        }

        private void KHHocTap_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_DsHocPhan.Visibility = Visibility.Visible;
            Table_DsHocPhan.ItemsSource = MainViewModel.Subjects;
        }

        private void DSHocPhan_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_DsHocPhan.Visibility = Visibility.Visible;
            Table_DsHocPhan.ItemsSource = MainViewModel.Subjects;
        }

        private void KeHoachMo_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_KeHoachMo.Visibility = Visibility.Visible;
            Table_KeHoachMo.ItemsSource = MainViewModel.CourseOpeningPlans;
        }

        private void PhanCong_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_PhanCong.Visibility = Visibility.Visible;
            Table_PhanCong.ItemsSource = MainViewModel.Assignments;
        }

        private void DangKy_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_DangKy.Visibility = Visibility.Visible;
            Table_DangKy.ItemsSource = MainViewModel.Registrations;
        }

        private void DSSinhVien_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_StudentList.Visibility = Visibility.Visible;
            Table_DsSinhVien.ItemsSource = MainViewModel.Students;
        }

        private void ThongBao_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_Notification.Visibility = Visibility.Visible;
            Table_DsThongBao.ItemsSource = MainViewModel.Notifications;
        }

        private void Button_EditSDT_Click(object sender, RoutedEventArgs e)
        {
            TextBlock_SDT.Visibility = Visibility.Collapsed;
            TextBox_SDT.Visibility = Visibility.Visible;
            Button_EditSDT.Visibility = Visibility.Collapsed;
            Button_SaveSDT.Visibility = Visibility.Visible;
            TextBox_SDT.Focus();
        }

        private void Button_SaveSDT_Click(object sender, RoutedEventArgs e)
        {
            // Update the database
            string column = "DT";
            string newPhoneNumber = TextBox_SDT.Text;
            int result = Db.UpdateStaffPhoneNo(column, newPhoneNumber, personnel.MANV);

            if (result != -1)
                return;

            // Update the binding source if necessary
            var binding = TextBox_SDT.GetBindingExpression(TextBox.TextProperty);
            binding?.UpdateSource();

            TextBlock_SDT.Visibility = Visibility.Visible;
            TextBox_SDT.Visibility = Visibility.Collapsed;
            Button_EditSDT.Visibility = Visibility.Visible;
            Button_SaveSDT.Visibility = Visibility.Collapsed;
        }       

        private void Table_DsHocPhan_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DonVi_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_KeHoachMo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }        
        
        private void Table_DangKy_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_PhanCong_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DsSinhVien_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DsThongBao_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DangKy_RowEditEnding(object sender, DataGridRowEditEndingEventArgs e)
        {
            if (e.EditAction == DataGridEditAction.Commit)
            {
                var dataGrid = sender as DataGrid;

                // Sử dụng Dispatcher để đợi cho quá trình chỉnh sửa hoàn tất
                dataGrid.Dispatcher.InvokeAsync(() =>
                {
                    var regist = e.Row.Item as Registration;
                    int result = 0;

                    // Only UPDATE (Diem)
                    result = Db.UpdateRegistration(regist);
                    MessageBox.Show("Executed!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);

                    // Update the binding source to the previous value
                    Table_DangKy.ItemsSource = MainViewModel.Registrations;

                }, System.Windows.Threading.DispatcherPriority.Background);
            }
        }
    }
}
