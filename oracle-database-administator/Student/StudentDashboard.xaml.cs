using Oracle.ManagedDataAccess.Client;
using oracle_database_administator.Class;
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

namespace oracle_database_administator.Student
{
    /// <summary>
    /// Interaction logic for StudentDashboard.xaml
    /// </summary>
    public partial class StudentDashboard : Page
    {
        private MainViewModel MainViewModel = MainViewModel.Instance;
        private Database Db = Database.Instance;

        // Data Context
        private Class.Student thisStudent = null;
        private Registration selectedRegistration = null;

        public StudentDashboard()
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
            thisStudent = Db.LoadSingleLineDataContext<Class.Student>(Db.STUDENTS);
            Grid_DisplayData.DataContext = thisStudent;
        }

        private void DeselectDataContext()
        {
            selectedRegistration = null;
        }

        private void HideAllElements()
        {
            // Hide all grids
            Grid_UserInfo.Visibility = Visibility.Collapsed;
            Grid_AcademicPlan.Visibility = Visibility.Collapsed;

            // Hide elements in the Academic Plan grid
            Table_DsHocPhan.Visibility = Visibility.Collapsed;
            Table_KeHoachMo.Visibility = Visibility.Collapsed;
            Table_DangKy.Visibility = Visibility.Collapsed;
            Button_DeleteRegistration.Visibility = Visibility.Collapsed;

            // Free up all selected rows
            DeselectDataContext();
        }

        private void LogoutButton_Click(object sender, RoutedEventArgs e)
        {
            // Open a Confirmation dialog
            MessageBoxResult result = MessageBox.Show("Are you sure you want to exit?", "Exit", MessageBoxButton.YesNo, MessageBoxImage.Question);
            if (result == MessageBoxResult.No)
                return;

            // Navigate back to the Dashboard
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

        private void DangKy_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_DangKy.Visibility = Visibility.Visible;
            Button_DeleteRegistration.Visibility = Visibility.Visible;
            Table_DangKy.ItemsSource = MainViewModel.Registrations;
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
            int result = Db.UpdateStudentSingleCol(column, newPhoneNumber, thisStudent.MASV);

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

        private void Button_EditDIACHI_Click(object sender, RoutedEventArgs e)
        {
            TextBlock_DIACHI.Visibility = Visibility.Collapsed;
            TextBox_DIACHI.Visibility = Visibility.Visible;
            Button_EditDIACHI.Visibility = Visibility.Collapsed;
            Button_SaveDIACHI.Visibility = Visibility.Visible;
            TextBox_DIACHI.Focus();
        }

        private void Button_SaveDIACHI_Click(object sender, RoutedEventArgs e)
        {
            // Update the database
            string column = "DIACHI";
            string newAddress = TextBox_DIACHI.Text;
            int result = Db.UpdateStudentSingleCol(column, newAddress, thisStudent.MASV);

            if (result != -1)
                return;

            // Update the binding source if necessary
            var binding = TextBox_DIACHI.GetBindingExpression(TextBox.TextProperty);
            binding?.UpdateSource();

            TextBlock_DIACHI.Visibility = Visibility.Visible;
            TextBox_DIACHI.Visibility = Visibility.Collapsed;
            Button_EditDIACHI.Visibility = Visibility.Visible;
            Button_SaveDIACHI.Visibility = Visibility.Collapsed;
        }

        private void Button_DeleteRegistration_Click(object sender, RoutedEventArgs e)
        {
            if (selectedRegistration == null)
            {
                MessageBox.Show("A registration is required!", "Empty Field Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            // Open a Confirmation dialog
            MessageBoxResult confirm = MessageBox.Show("Are you sure you want to delete this registration?", "Delete Confirmation", MessageBoxButton.YesNo, MessageBoxImage.Question);
            if (confirm == MessageBoxResult.No)
                return;

            // Delete the registration from the database
            int result = Db.DeleteRegistration(selectedRegistration);

            // Check if the row still exists
            if (Db.IsExistRegistration(selectedRegistration))
            {
                MessageBox.Show("No permission to delete this row!", "Delete Denied", MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }

            // Update the binding source
            Table_DangKy.ItemsSource = MainViewModel.Registrations;
            selectedRegistration = null;
        }

        private void Table_DsHocPhan_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_KeHoachMo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DsThongBao_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DangKy_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (Table_DangKy.SelectedItem is Registration selectedRegistration)
            {
                this.selectedRegistration = new Registration(selectedRegistration);
            }
        }

        private void Table_DangKy_RowEditEnding(object sender, DataGridRowEditEndingEventArgs e)
        {
            if (e.EditAction == DataGridEditAction.Commit)
            {
                var dataGrid = sender as DataGrid;

                // Lưu trữ giá trị của selectedRegistration vào một biến tạm thời để tránh bị thay đổi giá trị SelectionChanged khi nhấn Enter
                var oldRegistration = selectedRegistration;

                // Sử dụng Dispatcher để đợi cho quá trình chỉnh sửa hoàn tất
                dataGrid.Dispatcher.InvokeAsync(() =>
                {
                    var newRegistration = e.Row.Item as Registration;
                    int result = 0;

                    if (Db.IsExistRegistration(oldRegistration))
                    {
                        result = Db.UpdateRegistration(newRegistration);
                    }
                    else
                    {
                        result = Db.InsertRegistration(newRegistration);
                    }

                    if (result == -1)
                    {
                        MessageBox.Show("Executed!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    // Update the binding source to the previous value
                    Table_DangKy.ItemsSource = MainViewModel.Registrations;

                }, System.Windows.Threading.DispatcherPriority.Background);
            }
        }
    }
}
