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
        OracleConnection conn = Database.Instance.Connection;
        Database Db = Database.Instance;

        private ObservableCollection<Student> _students;
        private ObservableCollection<Personnel> _personnel;
        private ObservableCollection<Assignment> _assignment;
        private ObservableCollection<Registration> _registrations;
        private ObservableCollection<Subject> _subjects;
        private ObservableCollection<Unit> _unit;
        private ObservableCollection<CourseOpeningPlan> _courseOpeningPlan;


        public ObservableCollection<Student> Students
        {
            get { return _students; }
            set
            {
                _students = value;
                OnPropertyChanged("Students");
            }
        }

        public ObservableCollection<Personnel> Personnel
        {
            get { return _personnel; }
            set
            {
                _personnel = value;
                OnPropertyChanged("Personnel");
            }
        }

        public ObservableCollection<Assignment> Assignment
        {
            get { return _assignment; }
            set
            {
                _assignment = value;
                OnPropertyChanged("Assignment");
            }
        }

        public ObservableCollection<Registration> Registrations
        {
            get { return _registrations; }
            set
            {
                _registrations = value;
                OnPropertyChanged("Registrations");
            }
        }

        public ObservableCollection<Subject> Subjects
        {
            get { return _subjects; }
            set
            {
                _subjects = value;
                OnPropertyChanged("Subjects");
            }
        }

        public ObservableCollection<Unit> Unit
        {
            get { return _unit; }
            set
            {
                _unit = value;
                OnPropertyChanged("Unit");
            }
        }

        public ObservableCollection<CourseOpeningPlan> CourseOpeningPlan
        {
            get { return _courseOpeningPlan; }
            set
            {
                _courseOpeningPlan = value;
                OnPropertyChanged("CourseOpeningPlan");
            }
        }

        public MainViewModel()
        {
            Students = new ObservableCollection<Student>();
            Personnel = new ObservableCollection<Personnel>();
            Assignment = new ObservableCollection<Assignment>();
            Registrations = new ObservableCollection<Registration>();
            Subjects = new ObservableCollection<Subject>();
            Unit = new ObservableCollection<Unit>();
            CourseOpeningPlan = new ObservableCollection<CourseOpeningPlan>();
        }

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
