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
        public string PersonnelID { get; set; }
        public string Name { get; set; }
        public string Gender { get; set; }
        public DateTime? Birth { get; set; }
        public int Allowance { get; set; }
        public string PhoneNo { get; set; }
        public string Role { get; set; }
        public string UnitID { get; set; }


        // Constructor create object Personnel from OracleDataReader
        public Personnel(OracleDataReader dr)
        {
            PersonnelID = dr["Mã Nhân Viên"].ToString();
            Name = dr["Họ Tên"].ToString();
            Gender = dr["Phái"].ToString();
            Birth = dr["Ngày Sinh"] as DateTime?;
            Allowance = Convert.ToInt32(dr["Phụ Cấp"]);
            PhoneNo = dr["Điện Thoại"].ToString();
            Role = dr["Vai Trò"].ToString();
            UnitID = dr["Mã Đơn Vị"].ToString();
        }

        // Default Constructor
        public Personnel() { }

        // Copy constructor
        public Personnel(Personnel other)
        {
            PersonnelID = other.PersonnelID;
            Name = other.Name;
            Gender = other.Gender;
            Birth = other.Birth;
            Allowance = other.Allowance;
            PhoneNo = other.PhoneNo;
            Role = other.Role;
            UnitID = other.UnitID;
        }      
    }
}
