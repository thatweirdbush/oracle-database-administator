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
        private OracleConnection conn = Database.Instance.Connection;
        private Database Db = Database.Instance;
        Personnel personnel = null;
        Assignment assignment = null;

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
            personnel = Db.LoadSingleLineDataContext<Personnel>(Db.STAFFS_VIEWBY_TEACHER);
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
            Button_SeeRegistrations.Visibility = Visibility.Collapsed;
            Button_BackToAssignments.Visibility = Visibility.Collapsed;
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
            Table_DonVi.ItemsSource = Db.GetAnyTable(Db.UNITS);
        }

        private void KHHocTap_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_DsHocPhan.Visibility = Visibility.Visible;
            Table_DsHocPhan.ItemsSource = Db.GetAnyTable(Db.SUBJECTS);
        }

        private void DSHocPhan_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_DsHocPhan.Visibility = Visibility.Visible;
            Table_DsHocPhan.ItemsSource = Db.GetAnyTable(Db.SUBJECTS);
        }

        private void KeHoachMo_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_KeHoachMo.Visibility = Visibility.Visible;
            Table_KeHoachMo.ItemsSource = Db.GetAnyTable(Db.COURSE_OPENING_PLANS);
        }

        private void PhanCong_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_PhanCong.Visibility = Visibility.Visible;
            Button_SeeRegistrations.Visibility = Visibility.Visible;
            Table_PhanCong.ItemsSource = Db.GetAnyTable(Db.ASSIGNMENTS_VIEWBY_TEACHER);
        }

        private void DSSinhVien_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_StudentList.Visibility = Visibility.Visible;
            //Table_DsSinhVien.ItemsSource = Db.GetAnyTable(Db.STUDENTS);





            Table_DsSinhVien.ItemsSource = Db.LoadDataContext<Student>("C##ADMIN.N09_SINHVIEN");
        }

        private void ThongBao_Click(object sender, RoutedEventArgs e)
        {

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
            int result = Db.UpdateStaff(column, newPhoneNumber, personnel.MANV);

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

        private void Button_SeeRegistrations_Click(object sender, RoutedEventArgs e)
        {
            if (assignment == null)
            {
                MessageBox.Show("An Assignment is required!", "Empty Field Exception", MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }

            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_DangKy.Visibility = Visibility.Visible;
            Button_BackToAssignments.Visibility = Visibility.Visible;
            Table_DangKy.ItemsSource = Db.GetAnyTable(Db.REGISTRATIONS_VIEWBY_MINISTRY);

            // Reset the assignment
            assignment = null;
        }

        private void Button_BackToAssignments_Click(object sender, RoutedEventArgs e)
        {
            PhanCong_Click(sender, e);
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
            if (Table_PhanCong.SelectedItem is DataRowView row)
            {
                assignment = new Assignment
                {
                    MAGV = row["Mã Giảng Viên"].ToString(),
                    MAHP = row["Mã Học Phần"].ToString(),
                    HK = Int64.Parse(row["Học Kỳ"].ToString()),
                    NAM = Int64.Parse(row["Năm"].ToString()),
                    MACT = row["Mã Chương Trình"].ToString()
                };
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
                    var student = e.Row.Item as Student;
                    int result = 0;

                    if (Db.IsExistStudent(student.MASV))
                    {
                        result = Db.UpdateStudent(student);
                    }
                    else
                    {
                        result = Db.InsertStudent(student);
                    }

                    if (result < 0)
                    {
                        MessageBox.Show("Execute successfully", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                    else
                    {                     
                        // Update the binding source to the previous value
                        Table_DsSinhVien.ItemsSource = Db.LoadDataContext<Student>("C##ADMIN.N09_SINHVIEN");
                    }
                }, System.Windows.Threading.DispatcherPriority.Background);
            }
        }
    }
}
