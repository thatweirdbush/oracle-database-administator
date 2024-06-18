using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator.Class
{
    public class Notification
    {
        public string MATB { get; set; }
        public string TENTB { get; set; }
        public DateTime? NGAYGUI { get; set; }
        public string NGUOINHAN { get; set; }
        public string LINHVUC { get; set; }
        public string COSO { get; set; }
        public string NOIDUNG { get; set; }

        // Default constructor
        public Notification() {}

        // Copy constructor
        public Notification(Notification other)
        {
            MATB = other.MATB;
            TENTB = other.TENTB;
            NGAYGUI = other.NGAYGUI;
            NGUOINHAN = other.NGUOINHAN;
            LINHVUC = other.LINHVUC;
            COSO = other.COSO;
            NOIDUNG = other.NOIDUNG;
        }
    }
}
