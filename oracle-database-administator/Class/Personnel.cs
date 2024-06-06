using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace oracle_database_administator.Class
{
    public class Personnel
    {
        public string MANV { get; set; }
        public string HOTEN { get; set; }
        public string PHAI { get; set; }
        public DateTime? NGSINH { get; set; }
        public Int64 PHUCAP { get; set; }
        public string DT { get; set; }
        public string VAITRO { get; set; }
        public string MADV { get; set; }
        public string COSO { get; set; }

        // Default Constructor
        public Personnel() { }
    }
}
