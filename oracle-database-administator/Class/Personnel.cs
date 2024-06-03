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


        //// Constructor create object Personnel from OracleDataReader
        //public Personnel(OracleDataReader dr)
        //{
        //    PersonnelID = dr["Mã Nhân Viên"].ToString();
        //    Name = dr["Họ Tên"].ToString();
        //    Gender = dr["Phái"].ToString();
        //    Birth = dr["Ngày Sinh"] as DateTime?;
        //    Allowance = Convert.ToInt32(dr["Phụ Cấp"]);
        //    PhoneNo = dr["Điện Thoại"].ToString();
        //    Role = dr["Vai Trò"].ToString();
        //    UnitID = dr["Mã Đơn Vị"].ToString();
        //}

        // Default Constructor
        public Personnel() { }

        //// Copy constructor
        //public Personnel(Personnel other)
        //{
        //    PersonnelID = other.PersonnelID;
        //    Name = other.Name;
        //    Gender = other.Gender;
        //    Birth = other.Birth;
        //    Allowance = other.Allowance;
        //    PhoneNo = other.PhoneNo;
        //    Role = other.Role;
        //    UnitID = other.UnitID;
        //}      
    }
}
