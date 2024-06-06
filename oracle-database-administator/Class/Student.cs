using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator.Class
{
    public class Student
    {
        public string MASV { get; set; }
        public string HOTEN { get; set; }
        public string PHAI { get; set; }
        public DateTime? NGSINH { get; set; }
        public string DIACHI { get; set; }
        public string DT { get; set; }
        public string MACT { get; set; }
        public string MANGANH { get; set; }
        public Int64 SOTCTL { get; set; }
        public double DTBTL { get; set; }
        public string COSO { get; set; }

        // Default Constructor
        public Student() { }
    }
}
