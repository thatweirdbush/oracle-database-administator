using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace oracle_database_administator.Role
{
    public class Role
    {
        public string RoleName { get; set; }

        public Role(string rolename)
        {
            RoleName = rolename;
        }
    }
}
