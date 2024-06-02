using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Controls;

namespace oracle_database_administator.User
{
    public class User
    {
        public string UserName { get; set; }

        public User(string userName)
        {
            UserName = userName;
        }
    }
}
