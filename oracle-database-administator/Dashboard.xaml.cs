using Oracle.ManagedDataAccess.Client;
using oracle_database_administator.DepartmentHead;
using oracle_database_administator.Ministry;
using oracle_database_administator.Role;
using oracle_database_administator.Staff;
using oracle_database_administator.Student;
using oracle_database_administator.Teacher;
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
    /// Interaction logic for Dashboard.xaml
    /// </summary>
    public partial class Dashboard : Page
    {
        OracleConnection conn = null;
        Database Db = Database.Instance;

        public Dashboard()
        {
            InitializeComponent();
        }

        public void SwitchCaseRole()
        {
            //MessageBox.Show(Db.GetCurrentRole(), "Message", MessageBoxButton.OK, MessageBoxImage.Information);

            switch (Db.GetCurrentRole())
            {
                case "N09_RL_NHANVIEN":
                    {
                        StaffDashboard staffDashboard = new StaffDashboard();
                        NavigationService.Navigate(staffDashboard);
                        break;
                    }

                case "N09_RL_GIANGVIEN":
                    {
                        TeacherDashboard teacherDashboard = new TeacherDashboard();
                        NavigationService.Navigate(teacherDashboard);
                        break;
                    }
                case "N09_RL_GIAOVU":
                    {
                        MinistryDashboard ministryDashboard = new MinistryDashboard();
                        NavigationService.Navigate(ministryDashboard);
                        break;
                    }
                case "N09_RL_TRUONG_DONVI":
                    {
                        //DepartmentUnitDashboard departmentUnitDashboard = new DepartmentUnitDashboard();
                        //NavigationService.Navigate(departmentUnitDashboard);
                        break;
                    }
                case "N09_RL_TRUONG_KHOA":
                    {
                        DepartmentHeadDashboard departmentHeadDashboard = new DepartmentHeadDashboard();
                        NavigationService.Navigate(departmentHeadDashboard);
                        break;
                    }
                case "N09_RL_SINHVIEN":
                    {
                        StudentDashboard studentDashboard = new StudentDashboard();
                        NavigationService.Navigate(studentDashboard);
                        break;
                    }
                default:
                    {
                        Db.ClearUpConnection();
                        MessageBox.Show("You do not have permission to access this application!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        break;
                    }
            }
        }

        public void UserAccessControl()
        {
            if (conn == null)
            {
                if (Db.ConnectToServer())
                    SwitchCaseRole();
            }
            else
                SwitchCaseRole();
        }

        private void SchoolButton_Click(object sender, RoutedEventArgs e)
        {
            UserAccessControl();
        }

        private void SystemButton_Click(object sender, RoutedEventArgs e)
        {
            if (conn == null)
            {
                if (Db.ConnectToServer())
                {
                    SystemDashboard systemDashboard = new SystemDashboard();
                    NavigationService.Navigate(systemDashboard);
                }
            }
            else
            {
                SystemDashboard systemDashboard = new SystemDashboard();
                NavigationService.Navigate(systemDashboard);
            }
        }
    }
}
