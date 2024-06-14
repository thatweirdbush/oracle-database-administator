using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator.Class
{
    public class MainViewModel
    {
        // Singleton pattern & connection
        private static MainViewModel _instance = null;
        private OracleConnection conn = Database.Instance.Connection;
        private Database Db = Database.Instance;

        // Common data context
        private ObservableCollection<Student> _students;
        private ObservableCollection<Personnel> _personnels;
        private ObservableCollection<Assignment> _assignments;
        private ObservableCollection<Registration> _registrations;
        private ObservableCollection<Subject> _subjects;
        private ObservableCollection<Unit> _units;
        private ObservableCollection<CourseOpeningPlan> _courseOpeningPlans;

        // Metadata context
        private ObservableCollection<StandardAudit> standardAudits;
        private ObservableCollection<FGA> fgas;
        private ObservableCollection<AuditObject> auditObjects;


        public ObservableCollection<Student> Students
        {
            //get { return _students; }
            get { return Db.LoadDataContext<Student>(Db.STUDENTS); }
            set
            {
                _students = value;
                OnPropertyChanged("Student");
            }
        }

        public ObservableCollection<Personnel> Personnels
        {
            //get { return _personnels; }
            get { return Db.LoadDataContext<Personnel>(Db.PERSONNELS); }
            set
            {
                _personnels = value;
                OnPropertyChanged("Personnel");
            }
        }

        public ObservableCollection<Assignment> Assignments
        {
            //get { return _assignments; }
            get { return Db.LoadDataContext<Assignment>(Db.ASSIGNMENTS); }
            set
            {
                _assignments = value;
                OnPropertyChanged("Assignment");
            }
        }

        public ObservableCollection<Registration> Registrations
        {
            //get { return _registrations; }
            get { return Db.LoadDataContext<Registration>(Db.REGISTRATIONS); }
            set
            {
                _registrations = value;
                OnPropertyChanged("Registration");
            }
        }

        public ObservableCollection<Subject> Subjects
        {
            //get { return _subjects; }
            get { return Db.LoadDataContext<Subject>(Db.SUBJECTS); }
            set
            {
                _subjects = value;
                OnPropertyChanged("Subject");
            }
        }

        public ObservableCollection<Unit> Units
        {
            //get { return _units; }
            get { return Db.LoadDataContext<Unit>(Db.UNITS); }
            set
            {
                _units = value;
                OnPropertyChanged("Unit");
            }
        }

        public ObservableCollection<CourseOpeningPlan> CourseOpeningPlans
        {
            //get { return _courseOpeningPlans; }
            get { return Db.LoadDataContext<CourseOpeningPlan>(Db.COURSE_OPENING_PLANS); }
            set
            {
                _courseOpeningPlans = value;
                OnPropertyChanged("CourseOpeningPlan");
            }
        }

        public ObservableCollection<StandardAudit> StandardAudits
        {
            get { return Db.LoadDataContext<StandardAudit>(Db.STANDARD_AUDIT); }
            set
            {
                standardAudits = value;
                OnPropertyChanged("StandardAudit");
            }
        }

        public ObservableCollection<FGA> FGAs
        {
            get { return Db.LoadDataContext<FGA>(Db.FGA); }
            set
            {
                fgas = value;
                OnPropertyChanged("FGA");
            }
        }

        public ObservableCollection<AuditObject> AuditObjects
        {
            get { return Db.LoadDataContext<AuditObject>(Db.AUDIT_OBJECTS); }
            set
            {
                auditObjects = value;
                OnPropertyChanged("AuditObject");
            }
        }

        // Default Constructor
        private MainViewModel()
        {
            //Students = Db.LoadDataContext<Student>(Db.STUDENTS);
            //Personnels = Db.LoadDataContext<Personnel>(Db.PERSONNELS);
            //Assignments = Db.LoadDataContext<Assignment>(Db.ASSIGNMENTS);
            //Registrations = Db.LoadDataContext<Registration>(Db.REGISTRATIONS);
            //Subjects = Db.LoadDataContext<Subject>(Db.SUBJECTS);
            //Units = Db.LoadDataContext<Unit>(Db.UNITS);
            //CourseOpeningPlans = Db.LoadDataContext<CourseOpeningPlan>(Db.COURSE_OPENING_PLANS);
        }

        // Implement Singleton pattern
        public static MainViewModel Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new MainViewModel();
                }
                return _instance;
            }
        }

        // Implement INotifyPropertyChanged
        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
