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

namespace oracle_database_administator.Ministry
{
    /// <summary>
    /// Interaction logic for MinistryDashboard.xaml
    /// </summary>
    public partial class MinistryDashboard : Page
    {
        private MainViewModel MainViewModel = MainViewModel.Instance;
        private Database Db = Database.Instance;

        // Data Context
        private Personnel thisPersonnel = null;
        private Assignment selectedAssignment = null;
        private CourseOpeningPlan selectedPlan = null;
        private Registration selectedRegistration = null;

        public MinistryDashboard()
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
            thisPersonnel = Db.LoadSingleLineDataContext<Personnel>(Db.PERSONNELS);
            Grid_DisplayData.DataContext = thisPersonnel;
        }

        private void DeselectDataContext()
        {
            selectedAssignment = null;
            selectedPlan = null;
            selectedRegistration = null;
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
            Button_DeleteRegistration.Visibility = Visibility.Visible;
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
            int result = Db.UpdateStaffPhoneNo(column, newPhoneNumber, thisPersonnel.MANV);

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

            if (result == -1)
            {
                // Update the binding source
                Table_DangKy.ItemsSource = MainViewModel.Registrations;
                selectedRegistration = null;
            }
        }

        private void Table_DsHocPhan_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DonVi_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DsThongBao_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_KeHoachMo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (Table_KeHoachMo.SelectedItem is CourseOpeningPlan selectedPlan)
            {
                this.selectedPlan = new CourseOpeningPlan(selectedPlan);
            }
        }

        private void Table_DangKy_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (Table_DangKy.SelectedItem is Registration selectedRegistration)
            {
                this.selectedRegistration = new Registration(selectedRegistration);
            }
        }

        private void Table_PhanCong_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (Table_PhanCong.SelectedItem is Assignment selectedAssignment)
            {
                this.selectedAssignment = new Assignment(selectedAssignment);
            }
        }

        private void Table_DsSinhVien_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DsSinhVien_RowEditEnding(object sender, DataGridRowEditEndingEventArgs e)
        {
            if (e.EditAction == DataGridEditAction.Commit)
            {
                var dataGrid = sender as DataGrid;

                // Sử dụng Dispatcher để đợi cho quá trình chỉnh sửa hoàn tất
                dataGrid.Dispatcher.InvokeAsync(() =>
                {
                    var student = e.Row.Item as Class.Student;
                    int result = 0;

                    if (Db.IsExistStudent(student.MASV))
                    {
                        result = Db.UpdateStudent(student);
                    }
                    else
                    {
                        result = Db.InsertStudent(student);
                    }

                    if (result == -1)
                    {
                        MessageBox.Show("Executed!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    // Update the binding source to the previous value
                    Table_DsSinhVien.ItemsSource = MainViewModel.Students;
                }, System.Windows.Threading.DispatcherPriority.Background);
            }
        }

        private void Table_DonVi_RowEditEnding(object sender, DataGridRowEditEndingEventArgs e)
        {
            if (e.EditAction == DataGridEditAction.Commit)
            {
                var dataGrid = sender as DataGrid;

                // Sử dụng Dispatcher để đợi cho quá trình chỉnh sửa hoàn tất
                dataGrid.Dispatcher.InvokeAsync(() =>
                {
                    var unit = e.Row.Item as Unit;
                    int result = 0;

                    if (Db.IsExistUnit(unit.MADV))
                    {
                        result = Db.UpdateUnit(unit);
                    }
                    else
                    {
                        result = Db.InsertUnit(unit);
                    }

                    if (result == -1)
                    {
                        MessageBox.Show("Executed!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    // Update the binding source to the previous value
                    Table_DonVi.ItemsSource = MainViewModel.Units;
                }, System.Windows.Threading.DispatcherPriority.Background);
            }
        }

        private void Table_KeHoachMo_RowEditEnding(object sender, DataGridRowEditEndingEventArgs e)
        {
            if (e.EditAction == DataGridEditAction.Commit)
            {
                var dataGrid = sender as DataGrid;

                // Lưu trữ giá trị của selectedAssignment vào một biến tạm thời để tránh bị thay đổi giá trị SelectionChanged khi nhấn Enter
                var oldPlan = selectedPlan;

                // Sử dụng Dispatcher để đợi cho quá trình chỉnh sửa hoàn tất
                dataGrid.Dispatcher.InvokeAsync(() =>
                {
                    var plan = e.Row.Item as CourseOpeningPlan;
                    int result = 0;

                    // Get oldPlan from the selected item
                    if (Db.IsExistCourseOpeningPlan(oldPlan))
                    {
                        result = Db.UpdateCourseOpeningPlan(plan, oldPlan);
                    }
                    else
                    {
                        result = Db.InsertCourseOpeningPlan(plan);
                    }

                    if (result == -1)
                    {
                        MessageBox.Show("Executed!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    // Update the binding source to the previous value
                    Table_KeHoachMo.ItemsSource = MainViewModel.CourseOpeningPlans;
                    selectedPlan = null;

                }, System.Windows.Threading.DispatcherPriority.Background);
            }
        }

        private void Table_DangKy_RowEditEnding(object sender, DataGridRowEditEndingEventArgs e)
        {
            if (e.EditAction == DataGridEditAction.Commit)
            {
                var dataGrid = sender as DataGrid;

                // Sử dụng Dispatcher để đợi cho quá trình chỉnh sửa hoàn tất
                dataGrid.Dispatcher.InvokeAsync(() =>
                {
                    var registration = e.Row.Item as Registration;
                    int result = 0;

                    // Only UPDATE (Diem) and DELETE
                    result = Db.UpdateRegistration(registration);

                    if (result == -1)
                    {
                        MessageBox.Show("Executed!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    // Update the binding source to the previous value
                    Table_DangKy.ItemsSource = MainViewModel.Registrations;

                }, System.Windows.Threading.DispatcherPriority.Background);
            }
        }

        private void Table_PhanCong_RowEditEnding(object sender, DataGridRowEditEndingEventArgs e)
        {
            if (e.EditAction == DataGridEditAction.Commit)
            {
                var dataGrid = sender as DataGrid;

                // Lưu trữ giá trị của selectedAssignment vào một biến tạm thời để tránh bị thay đổi giá trị SelectionChanged khi nhấn Enter
                var oldAssignment = selectedAssignment;

                // Sử dụng Dispatcher để đợi cho quá trình chỉnh sửa hoàn tất
                dataGrid.Dispatcher.InvokeAsync(() =>
                {
                    var assignment = e.Row.Item as Assignment;
                    int result = 0;

                    // Only UPDATE
                    if (Db.IsExistAssignment(oldAssignment))
                    {
                        result = Db.UpdateAssignment(assignment, oldAssignment);
                    }

                    if (result == -1)
                    {
                        MessageBox.Show("Executed!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    // Update the binding source to the previous value
                    Table_PhanCong.ItemsSource = MainViewModel.Assignments;
                    selectedAssignment = null;

                }, System.Windows.Threading.DispatcherPriority.Background);
            }
        }

        private void Table_DsHocPhan_RowEditEnding(object sender, DataGridRowEditEndingEventArgs e)
        {
            if (e.EditAction == DataGridEditAction.Commit)
            {
                var dataGrid = sender as DataGrid;

                // Sử dụng Dispatcher để đợi cho quá trình chỉnh sửa hoàn tất
                dataGrid.Dispatcher.InvokeAsync(() =>
                {
                    var subject = e.Row.Item as Subject;
                    int result = 0;

                    if (Db.IsExistSubject(subject.MAHP))
                    {
                        result = Db.UpdateSubject(subject);
                    }
                    else
                    {
                        result = Db.InsertSubject(subject);
                    }

                    if (result == -1)
                    {
                        MessageBox.Show("Executed!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    // Update the binding source to the previous value
                    Table_DsHocPhan.ItemsSource = MainViewModel.Subjects;
                }, System.Windows.Threading.DispatcherPriority.Background);
            }
        }
    }
}
