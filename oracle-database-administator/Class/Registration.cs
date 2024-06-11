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
        public double DIEMTH { get; set; }
        public double DIEMQT { get; set; }
        public double DIEMCK { get; set; }
        public double DIEMTK { get; set; }

        // Default Constructor
        public Registration() { }

        // Copy Constructor
        public Registration(Registration other)
        {
            MASV = other.MASV;
            MAGV = other.MAGV;
            MAHP = other.MAHP;
            HK = other.HK;
            NAM = other.NAM;
            MACT = other.MACT;
            DIEMTH = other.DIEMTH;
            DIEMQT = other.DIEMQT;
            DIEMCK = other.DIEMCK;
            DIEMTK = other.DIEMTK;
        }

    }
}
