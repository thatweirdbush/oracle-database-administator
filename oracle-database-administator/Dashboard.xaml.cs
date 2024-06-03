using Oracle.ManagedDataAccess.Client;
using oracle_database_administator.Role;
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

        private void SchoolButton_Click(object sender, RoutedEventArgs e)
        {
            if (conn == null)
            {
                if (Db.ConnectToServer())
                {
                    TeacherDashboard teacherDashboard = new TeacherDashboard();
                    NavigationService.Navigate(teacherDashboard);
                }
            }
            else
            {
                TeacherDashboard teacherDashboard = new TeacherDashboard();
                NavigationService.Navigate(teacherDashboard);
            }
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
