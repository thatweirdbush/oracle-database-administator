using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace oracle_database_administator.Class
{
    public class Student
    {
        public string MASV { get; set; }
        public string HOTEN { get; set; }
        public string PHAI { get; set; }
        public DateTime? NGSINH { get; set; }
        public string DIACHI { get; set; }
        public string DT { get; set; }
        public string MACT { get; set; }
        public string MANGANH { get; set; }
        public Int64 SOTCTL { get; set; }
        public double DTBTL { get; set; }
        public string COSO { get; set; }

        // Default Constructor
        public Student() { }

        //public Student(DataRowView row)
        //{
        //    try
        //    {
        //        int index = 0;
        //        foreach (PropertyInfo prop in typeof(Student).GetProperties())
        //        {
        //            prop.SetValue(this, row[index]);
        //            index++;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show("Error: " + ex.Message, "DataRowView Conversion Error", MessageBoxButton.OK, MessageBoxImage.Information);
        //    }
        //}

        public string ToOracleDate()
        {
            return "TO_DATE('" + NGSINH.Value.ToString("dd/MM/yyyy") + "', 'DD/MM/YYYY')";
        }
    }


}
