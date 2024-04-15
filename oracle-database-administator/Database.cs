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
        private bool dataGridChanged = true;
        private string password = "";


        /// <WARNING>
        /// TODO: THIS MUST NOT BE PUBLIC
        /// </WARNING>
        public string ConnectionPassword 
        {
            get { return password; }
            set { password = value; }
        }

        public OracleConnection Connection
        {
            get
            {
                if (_connection == null)
                {
                    try
                    {
                        //// Đóng kết nối hiện tại
                        //DisposeConnection();

                        // Đọc chuỗi kết nối từ tệp cấu hình
                        //string connectionString = ConfigurationManager.ConnectionStrings["OracleDbContext"].ConnectionString;
                        string connectionString = $"DATA SOURCE=localhost:1521/XE;DBA PRIVILEGE=SYSDBA;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD={ConnectionPassword}";
                        _connection = new OracleConnection(connectionString);
                        _connection.Open();
                    }
                    catch (OracleException ex)
                    {
                        // Xử lý khi kết nối thất bại
                        MessageBox.Show(ex.Message, "Create Connection Failed", MessageBoxButton.OK, MessageBoxImage.Information);
                        _connection.Dispose();
                        _connection = null;
                    }
                }
                return _connection;
            }
        }

        public void Disconnect()
        {
            if (_connection != null)
            {
                _connection.Dispose();
                _connection.Close();
                OracleConnection.ClearPool(_connection);
                _connection = null;
            }
        }

        // Giải phóng tài nguyên kết nối hiện tại
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
            GC.SuppressFinalize(this);
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
            get { return dataGridChanged; }
            set {  dataGridChanged = value; }
        }

        public OracleConnection AlternateConnection(string username, string password)
        {
            if (_connection != null)
            {
                // Đóng kết nối hiện tại (nếu có)
                //DisposeConnection();

                string connectionString = $"DATA SOURCE=localhost:1521/XE;PERSIST SECURITY INFO=True;USER ID={username};PASSWORD={password}";
                _connection = new OracleConnection(connectionString);
                try
                {
                    _connection.Open();
                }
                catch (OracleException ex)
                {
                    // Xử lý khi kết nối thất bại
                    MessageBox.Show(ex.Message, "Create Alternate Connection Failed", MessageBoxButton.OK, MessageBoxImage.Information);
                    _connection.Dispose();
                    _connection = null;
                }
            }
            return _connection;
        }

        public string CurrentUser
        {
            get
            {
                string user = "";
                if (_connection != null)
                {
                    string query = "SELECT USER FROM DUAL";
                    using (OracleCommand command = new OracleCommand(query, _connection))
                    {
                        object result = command.ExecuteScalar();
                        if (result != null)
                        {
                            user = result.ToString();
                        }
                    }
                }
                return user;
            }
        }
    }
}
