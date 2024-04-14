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
        private OracleConnection _alternated_connection = null;
        private bool disposed = false;
        private bool dataGridSelectionEnabled = true;

        public OracleConnection GetAlternateConnection {
        get { return _alternated_connection; }
        }

        public OracleConnection GetConnection()
        {
            return _connection;
        }

        public OracleConnection Connection
        {
            get
            {
                if (_connection == null/* || !CurrentUser.Equals("SYS")*/)
                {
                    try
                    {
                        //// Đóng kết nối hiện tại (nếu khác SYS)
                        //DisposeConnection();

                        // Đọc chuỗi kết nối từ tệp cấu hình
                        string connectionString = ConfigurationManager.ConnectionStrings["OracleDbContext"].ConnectionString;

                        _connection = new OracleConnection(connectionString);

                        _connection.Open();
                        if (_connection.State == System.Data.ConnectionState.Open)
                        {
                            Console.WriteLine("Connection opened successfully!");
                        }
                        else
                        {
                            MessageBox.Show("Failed to open connection.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                    }
                    catch (OracleException ex)
                    {
                        // Xử lý khi kết nối thất bại
                        MessageBox.Show("Failed to create connection: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
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
            get { return dataGridSelectionEnabled; }
            set {  dataGridSelectionEnabled = value; }
        }

        public OracleConnection AlternateConnection1(string username, string password)
        {
            if (_alternated_connection == null || _alternated_connection.State != ConnectionState.Open)
            {
                // Đóng kết nối hiện tại (nếu có)
                //DisposeConnection();

                string connectionString = "DATA SOURCE=localhost:1521/XE;PERSIST SECURITY INFO=True;USER ID=" + username + ";PASSWORD=" + password;

                _alternated_connection = new OracleConnection(connectionString);
                try
                {
                    _alternated_connection.Open();
                }
                catch (OracleException ex)
                {
                    // Xử lý khi kết nối thất bại
                    MessageBox.Show("Failed to create connection: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    _alternated_connection.Dispose();
                    _alternated_connection = null;
                }
            }
            return _alternated_connection;
        }

        public OracleConnection AlternateConnection(string username, string password)
        {
            if (_connection != null)
            {
                // Đóng kết nối hiện tại (nếu có)
                //DisposeConnection();

                string connectionString = "DATA SOURCE=localhost:1521/XE;PERSIST SECURITY INFO=True;USER ID=" + username + ";PASSWORD=" + password;

                _connection = new OracleConnection(connectionString);
                try
                {
                    _connection.Open();
                }
                catch (OracleException ex)
                {
                    // Xử lý khi kết nối thất bại
                    MessageBox.Show("Failed to create connection: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
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
                try
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
                catch (Exception)
                {
                    //MessageBox.Show("`Get current user` Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                }
                return user;
            }
        }

        public string CurrentAlternatedUser
        {
            get
            {
                string user = "";
                try
                {
                    string query = "SELECT USER FROM DUAL";
                    using (OracleCommand command = new OracleCommand(query, _alternated_connection))
                    {
                        object result = command.ExecuteScalar();
                        if (result != null)
                        {
                            user = result.ToString();
                        }
                    }
                }
                catch (Exception)
                {
                    //MessageBox.Show("`Get current user` Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                }
                return user;
            }
        }

        public void DisconnectAlternateConnection()
        {
            if (_alternated_connection != null)
            {
                _alternated_connection.Dispose();
                _alternated_connection.Close();
                OracleConnection.ClearPool(_alternated_connection);
                _alternated_connection = null;
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
    }
}
