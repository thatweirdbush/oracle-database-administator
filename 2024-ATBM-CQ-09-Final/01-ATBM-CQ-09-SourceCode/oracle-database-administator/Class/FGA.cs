using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator.Class
{
    public class FGA
    {
        public string DB_USER { get; set; }
        public string TIME { get; set; }
        public string OBJECT_NAME { get; set; }
        public string STATEMENT_TYPE { get; set; }
        public string SQL_TEXT { get; set; }

        // Default Constructor
        public FGA() { }

        // Copy Constructor
        public FGA(FGA other)
        {
            DB_USER = other.DB_USER;
            TIME = other.TIME;
            OBJECT_NAME = other.OBJECT_NAME;
            STATEMENT_TYPE = other.STATEMENT_TYPE;
            SQL_TEXT = other.SQL_TEXT;
        }
    }
}
