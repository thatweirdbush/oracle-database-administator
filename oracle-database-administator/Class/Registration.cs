using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator.Class
{
    public class Registration
    {
        public string MASV { get; set; }
        public string MAGV { get; set; }
        public string MAHP { get; set; }
        public Int64 HK { get; set; }
        public Int64 NAM { get; set; }
        public string MACT { get; set; }
        public Int64 DIEMTH { get; set; }
        public Int64 DIEMQT { get; set; }
        public Int64 DIEMCK { get; set; }
        public Int64 DIEMTK { get; set; }

        // Default Constructor
        public Registration() { }
    }
}
