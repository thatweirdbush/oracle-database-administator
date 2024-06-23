using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator.Class
{
    public class CourseOpeningPlan
    {
        public string MAHP { get; set; }
        public Int64 HK { get; set; }
        public Int64 NAM { get; set; }
        public string MACT { get; set; }

        // Default Constructor
        public CourseOpeningPlan() { }

        // Copy Constructor
        public CourseOpeningPlan(CourseOpeningPlan other)
        {
            MAHP = other.MAHP;
            HK = other.HK;
            NAM = other.NAM;
            MACT = other.MACT;
        }
    }
}
