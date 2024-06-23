using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator.Class
{
    public class AuditObject
    {
        public string OWNER { get; set; }
        public string OBJECT_NAME { get; set; }
        public string OBJECT_TYPE { get; set; }

        // Default Constructor
        public AuditObject() {}

        // Copy Constructor
        public AuditObject(AuditObject other)
        {
            OWNER = other.OWNER;
            OBJECT_NAME = other.OBJECT_NAME;
            OBJECT_TYPE = other.OBJECT_TYPE;
        }
    }
}
