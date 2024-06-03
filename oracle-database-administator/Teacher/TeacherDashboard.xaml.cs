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
        //static private OracleConnection conn = Database.Instance.Connection;
        //static Database Db = Database.Instance;
        public string currentUserID { get; set; }
        Personnel personnel = null;

        public TeacherDashboard()
        {
            InitializeComponent();
            //currentUserID = Database.Instance.CurrentUser;
            DataContext = this;
        }

        private void GetUserDataContext()
        {
            //personnel = Db.LoadDataContext<Personnel>(Db.STAFFS_VIEWBY_TEACHER);
            //Grid_DisplayData.DataContext = personnel;
        }

        private void HideAllElements()
        {
            Grid_UserInfo.Visibility = Visibility.Hidden;
            Grid_Unit.Visibility = Visibility.Hidden;
            Grid_AcademicPlan.Visibility = Visibility.Hidden;
            Grid_StudentList.Visibility = Visibility.Hidden;
        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
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
        }

        private void KHHocTap_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_AcademicPlan.Visibility = Visibility.Visible;
            Table_KeHoachMo.Visibility = Visibility.Hidden;
            Table_DsHocPhan.Visibility = Visibility.Visible;
        }

        private void DSHocPhan_Click(object sender, RoutedEventArgs e)
        {
            Table_KeHoachMo.Visibility = Visibility.Hidden;
            Table_PhanCong.Visibility = Visibility.Hidden;
            Table_DsHocPhan.Visibility = Visibility.Visible;
        }

        private void KeHoachMo_Click(object sender, RoutedEventArgs e)
        {
            Table_DsHocPhan.Visibility = Visibility.Hidden;
            Table_PhanCong.Visibility = Visibility.Hidden;
            Table_KeHoachMo.Visibility = Visibility.Visible;
        }

        private void PhanCong_Click(object sender, RoutedEventArgs e)
        {
            Table_DsHocPhan.Visibility = Visibility.Hidden;
            Table_KeHoachMo.Visibility = Visibility.Hidden;
            Table_PhanCong.Visibility = Visibility.Visible;
        }

        private void DSSinhVien_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_StudentList.Visibility = Visibility.Visible;
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
