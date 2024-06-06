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

namespace oracle_database_administator.Staff
{
    /// <summary>
    /// Interaction logic for StaffDashboard.xaml
    /// </summary>
    public partial class StaffDashboard : Page
    {
        private OracleConnection conn = Database.Instance.Connection;
        private Database Db = Database.Instance;
        Personnel personnel = null;

        public StaffDashboard()
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
            personnel = Db.LoadDataContext<Personnel>(Db.STAFFS_VIEWBY_STAFF);
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
            Table_DsHocPhan.Visibility = Visibility.Visible;
            Table_DsHocPhan.ItemsSource = Db.GetAnyTable(Db.SUBJECTS);
        }

        private void KeHoachMo_Click(object sender, RoutedEventArgs e)
        {
            Table_DsHocPhan.Visibility = Visibility.Collapsed;
            Table_KeHoachMo.Visibility = Visibility.Visible;
            Table_KeHoachMo.ItemsSource = Db.GetAnyTable(Db.COURSE_OPENING_PLANS);
        }

        private void DSSinhVien_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Grid_StudentList.Visibility = Visibility.Visible;
            Table_DsSinhVien.ItemsSource = Db.GetAnyTable(Db.STUDENTS);
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
    }
}
