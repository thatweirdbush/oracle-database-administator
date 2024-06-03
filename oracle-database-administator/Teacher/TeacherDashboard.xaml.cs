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
using Oracle.ManagedDataAccess.Client;
using oracle_database_administator.Class;

namespace oracle_database_administator.Teacher
{
    /// <summary>
    /// Interaction logic for TeacherDashboard.xaml
    /// </summary>
    public partial class TeacherDashboard : Page
    {
        private OracleConnection conn = Database.Instance.Connection;
        private Database Db = Database.Instance;
        Personnel personnel = null;

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
            personnel = Db.LoadDataContext<Personnel>(Db.STAFFS_VIEWBY_TEACHER);
            Grid_DisplayData.DataContext = personnel;
        }

        private void HideAllElements()
        {
            Grid_UserInfo.Visibility = Visibility.Collapsed;
            Grid_Unit.Visibility = Visibility.Collapsed;
            Grid_AcademicPlan.Visibility = Visibility.Collapsed;
            Grid_StudentList.Visibility = Visibility.Collapsed;
        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
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
            Table_KeHoachMo.Visibility = Visibility.Collapsed;
            Table_DsHocPhan.Visibility = Visibility.Visible;
            Table_DsHocPhan.ItemsSource = Db.GetAnyTable(Db.SUBJECTS);
        }

        private void DSHocPhan_Click(object sender, RoutedEventArgs e)
        {
            Table_KeHoachMo.Visibility = Visibility.Collapsed;
            Table_PhanCong.Visibility = Visibility.Collapsed;
            Table_DsHocPhan.Visibility = Visibility.Visible;
            Table_DsHocPhan.ItemsSource = Db.GetAnyTable(Db.SUBJECTS);
        }

        private void KeHoachMo_Click(object sender, RoutedEventArgs e)
        {
            Table_DsHocPhan.Visibility = Visibility.Collapsed;
            Table_PhanCong.Visibility = Visibility.Collapsed;
            Table_KeHoachMo.Visibility = Visibility.Visible;
            Table_KeHoachMo.ItemsSource = Db.GetAnyTable(Db.COURSE_OPENING_PLANS);
        }

        private void PhanCong_Click(object sender, RoutedEventArgs e)
        {
            Table_DsHocPhan.Visibility = Visibility.Collapsed;
            Table_KeHoachMo.Visibility = Visibility.Collapsed;
            Table_PhanCong.Visibility = Visibility.Visible;
            Table_PhanCong.ItemsSource = Db.GetAnyTable(Db.ASSIGNMENTS_VIEWBY_TEACHER);
        }

        private void DSSinhVien_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_StudentList.Visibility = Visibility.Visible;
            Table_DsSinhVien.ItemsSource = Db.GetAnyTable(Db.STUDENTS);
        }

        private void EditSDT_Click(object sender, RoutedEventArgs e)
        {
            TextBlock_SDT.IsHitTestVisible = true;
            TextBlock_SDT.Focusable = true;
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

        private void Table_DsSinhVien_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_PhanCong_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
    }
}
