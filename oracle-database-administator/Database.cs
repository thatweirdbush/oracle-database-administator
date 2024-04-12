using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Windows;
using System.Data;

namespace oracle_database_administator
{
    
    public class Database : IDisposable
    {
        private static Database _instance = null;
        private OracleConnection _connection = null;
        private bool disposed = false;
        private bool dataGridSelectionEnabled = true;

        public OracleConnection Connection
        {
            get
            {
                if (_connection == null || _connection.State != ConnectionState.Open)
                {
                    // Đóng kết nối hiện tại (nếu có)
                    DisposeConnection();

                    // Đọc chuỗi kết nối từ tệp cấu hình
                    string connectionString = ConfigurationManager.ConnectionStrings["OracleDbContext"].ConnectionString;

                    _connection = new OracleConnection(connectionString);
                    try
                    {
                        _connection.Open();
                    }
                    catch (OracleException ex)
                    {
                        // Xử lý khi kết nối thất bại
                        Console.WriteLine("Không thể mở kết nối: " + ex.Message);
                        _connection.Dispose();
                        _connection = null;
                    }
                }
                return _connection;
            }
        }

        // Đóng kết nối hiện tại
        private void DisposeConnection()
        {
            if (_connection != null)
            {
                _connection.Dispose();
                _connection = null;

            }
        }

        // Phương thức giải phóng tài nguyên
        public void Dispose()
        {
            Dispose(true);
            //GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!disposed)
            {
                if (disposing)
                {
                    if (_connection != null)
                    {
                        DisposeConnection();
                    }
                }
                disposed = true;
            }
        }

        public static Database Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new Database();
                }
                return _instance;
            }
        }

        public bool IsSelectable
        {
            get { return dataGridSelectionEnabled; }
            set {  dataGridSelectionEnabled = value; }
        }

        public OracleConnection AlternateConnection
        {
            get
            {
                if (_connection == null || _connection.State != ConnectionState.Open)
                {
                    // Đóng kết nối hiện tại (nếu có)
                    DisposeConnection();

                    // Đọc chuỗi kết nối từ tệp cấu hình
                    string connectionString = ConfigurationManager.ConnectionStrings["OracleDbContext"].ConnectionString;

                    _connection = new OracleConnection(connectionString);
                    try
                    {
                        _connection.Open();
                    }
                    catch (OracleException ex)
                    {
                        // Xử lý khi kết nối thất bại
                        Console.WriteLine("Không thể mở kết nối: " + ex.Message);
                        _connection.Dispose();
                        _connection = null;
                    }
                }
                return _connection;
            }
        }
    }
}
