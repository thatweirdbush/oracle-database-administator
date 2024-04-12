using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Controls;

namespace oracle_database_administator.User
{
    internal class UserDAO
    {
    }
    public class UserInfo
    {
        public string UserName { get; set; }

        public UserInfo(string userName)
        {
            UserName = userName;
        }
    }
}
