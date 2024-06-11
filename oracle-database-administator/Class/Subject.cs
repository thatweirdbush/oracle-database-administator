using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator.Class
{
    public class Subject
    {
        public string MAHP { get; set; }
        public string TENHP { get; set; }
        public Int64 SOTC { get; set; }
        public Int64 STLT { get; set; }
        public Int64 STTH { get; set; }
        public Int64 SOSVTD { get; set; }
        public string MADV { get; set; }

        // Default Constructor
        public Subject() { }

        // Copy Constructor
        public Subject(Subject other)
        {
            MAHP = other.MAHP;
            TENHP = other.TENHP;
            SOTC = other.SOTC;
            STLT = other.STLT;
            STTH = other.STTH;
            SOSVTD = other.SOSVTD;
            MADV = other.MADV;
        }
    }
}
