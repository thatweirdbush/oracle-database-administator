using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator
{
    public class Database
    {
        OracleConnection conn;
        public string conStr { get; set; } = @"DATA SOURCE=localhost:1521/XE;DBA PRIVILEGE=SYSDBA;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD=244466666";
    }
}
