using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator.Class
{
    public class StandardAudit
    {
        public string USERNAME { get; set; }
        public string TIME { get; set; }
        public string OBJ_NAME { get; set; }
        public string ACTION_NAME { get; set; }
        public string SQL_TEXT { get; set; }

        // Default Constructor
        public StandardAudit() { }

        // Copy Constructor
        public StandardAudit(StandardAudit other)
        {
            USERNAME = other.USERNAME;
            TIME = other.TIME;
            OBJ_NAME = other.OBJ_NAME;
            ACTION_NAME = other.ACTION_NAME;
            SQL_TEXT = other.SQL_TEXT;
        }
    }
}
