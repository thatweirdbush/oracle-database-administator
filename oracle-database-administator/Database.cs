﻿using Oracle.ManagedDataAccess.Client;
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
using oracle_database_administator.User;
using System.Reflection;

namespace oracle_database_administator
{    
    public class Database
    {
        /**********************************************************
        * Database's Connection
        ***********************************************************/
        private static Database _instance = null;
        private OracleConnection _connection = null;
        private bool dataGridChanged = true;
        private string username = "";
        private string password = "";

        /// <WARNING>
        /// TODO: THIS MUST NOT BE PUBLIC
        /// </WARNING>
        public string ConnectionPassword 
        {
            get { return password; }
            set { password = value; }
        }

        /// <WARNING>
        /// TODO: THIS MUST NOT BE PUBLIC
        /// </WARNING>
        public string ConnectionUsername
        {
            // Tự động chuyển username thành chữ in hoa
            get { return username; }
            set { username = value.ToUpper(); }
        }

        public OracleConnection Connection
        {
            get
            {
                if (_connection == null)
                {
                    try
                    {
                        string SYSDBA_OPTION = "";

                        if (ConnectionUsername == "SYS" || ConnectionUsername == "SYSTEM")
                        {
                            SYSDBA_OPTION = "DBA PRIVILEGE=SYSDBA;";
                        }
                        string connectionString = $"DATA SOURCE=localhost:1521/XE;{SYSDBA_OPTION}PERSIST SECURITY INFO=True;USER ID={ConnectionUsername};PASSWORD={ConnectionPassword}";
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

        // Connect to server, using loop to handle when user close the window
        public bool ConnectToServer()
        {
            // Nếu đã kết nối rồi thì không cần kết nối lại
            if (ConnectionPassword != "")
            {
                _connection = Connection;
                return true;
            }

            bool windowClosed = false;
            while (!windowClosed)
            {
                PasswordWindow passwordWindow = new PasswordWindow();
                bool? result = passwordWindow.ShowDialog();

                // Xử lý trường hợp người dùng nhập mật khẩu
                if (result == true)
                {
                    ConnectionUsername = passwordWindow.Username;
                    ConnectionPassword = passwordWindow.Password;

                    _connection = Connection;
                    if (_connection != null)
                    {
                        Console.WriteLine("Connection opened successfully!");
                        break;
                    }
                    else
                    {
                        ConnectionPassword = "";
                        return false;
                    }
                }
                else
                {
                    // Xử lý trường hợp người dùng đóng cửa sổ
                    windowClosed = true;
                    return false;
                }
            }
            return true;
        }

        // Disconnect current connection (Mainly used)
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

        // Implement Singleton pattern
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

        public OracleConnection AlternateConnection(string new_username, string new_password)
        {
            if (_connection != null)
            {
                try
                {
                    string SYSDBA_OPTION = "";

                    if (new_username == "SYS" || new_username == "SYSTEM")
                    {
                        SYSDBA_OPTION = "DBA PRIVILEGE=SYSDBA;";
                    }
                    string connectionString = $"DATA SOURCE=localhost:1521/XE;{SYSDBA_OPTION}PERSIST SECURITY INFO=True;USER ID={new_username};PASSWORD={new_password}";

                    _connection = new OracleConnection(connectionString);
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
                if (_connection != null)
                    return GetCurrentUser();
                else
                    return null;
            }
        }

        /**********************************************************
        * Define Application default schema & default tablespace prefix
        ***********************************************************/
        static public string SYS_SCHEMA = "SYS.";
        static public string DEFAULT_PREFIX = "N09_";
        static public string DEFAULT_PREFIX_VIEW = "UV_";

        // Combine schema and prefix to create stored procedure & function name
        static public string COMBINED_PREFIX = $"{SYS_SCHEMA}{DEFAULT_PREFIX}";


        /**********************************************************
        * Define Application Data Table name by stored procedure name
        ***********************************************************/
        public string ROLES = $"{COMBINED_PREFIX}SELECT_DBA_ROLES";
        public string ROLE_PRIVS = $"{COMBINED_PREFIX}SELECT_DBA_ROLE_PRIVS";
        public string USERS = $"{COMBINED_PREFIX}SELECT_ALL_USERS";
        public string PRIVS = $"{COMBINED_PREFIX}SELECT_USER_OR_ROLE_PRIVS";
        public string PRIVS_SIMPLIFY = $"{COMBINED_PREFIX}SELECT_USER_OR_ROLE_PRIVS_SIMPLIFY";
        public string TABLES = $"{COMBINED_PREFIX}SELECT_DBA_TABLES";
        public string TABLE_COLUMNS = $"{COMBINED_PREFIX}SELECT_TAB_COLUMNS";

        // Special stored procedures
        public string SELECT_ANY_TABLE = $"{COMBINED_PREFIX}SELECT_ANY_TABLE";
        public string GET_CURRENT_USER = $"{COMBINED_PREFIX}GET_CURRENT_USER";

        //////////////////////////////////////////////
        /// <summary>
        /// Constant for output parameter in stored procedures
        /// Ex: CREATE OR REPLACE PROCEDURE MyProcedure(OUTPUT OUT SYS_REFCURSOR)
        /// NOTE: Currently, the output parameter is useless
        /// </summary>
        private string outParameter = "OUTPUT";
        private string inParameter = "INPUT";




        /**********************************************************
        * Database's Stored Procedures - Phan He 1
        ***********************************************************/
        /// <summary>
        /// Return current user that connected to database
        /// </summary>
        /// <returns>Current user in string</returns>
        public string GetCurrentUser()
        {
            try
            {
                using (OracleCommand command = new OracleCommand(GET_CURRENT_USER, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;

                    object result = command.ExecuteScalar();
                    return result.ToString();
                }            
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return null;
            }
        }

        /// <summary>
        /// Return a table when SELECT stored procedures with INPUT optional parameter
        /// </summary>
        /// <param name="procedureName"></param>
        /// <param name="inputValue"></param>
        /// <returns>Table type with selected cols</returns>
        public DataView UpdateDataView(string procedureName, string inputValue = null)
        {
            try {
                using (OracleCommand command = new OracleCommand(procedureName, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    if (inputValue != null)
                    {
                        command.Parameters.Add(inParameter, OracleDbType.Varchar2).Value = inputValue;
                    }

                    using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);

                        return dataTable.DefaultView;
                    }
                }
            }
            catch (Exception ex) {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return null;
            }
        }

        /// <summary>
        /// Return a table when SELECT stored procedures with optional 'condition' parameter
        /// </summary>
        /// <param name="tableName"></param>
        /// <param name="condition"></param>
        /// <returns>Table type with all cols</returns>
        public DataView GetAnyTable(string tableName, string condition = null)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(SELECT_ANY_TABLE, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    command.Parameters.Add("STR_TABLE_NAME", OracleDbType.Varchar2).Value = tableName;
                    if (condition != null)
                    {
                        command.Parameters.Add("STR_CONDITION", OracleDbType.Varchar2).Value = condition;
                    }

                    using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        return dataTable.DefaultView;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return null;
            }
        }

        /// <summary>
        /// Grant privilege to user or role with optional: with grant option, table or view and columns
        /// </summary>
        /// <param name="privilege"></param>
        /// <param name="userOrRole"></param>
        /// <param name="withGrantOption"></param>
        /// <param name="tableOrView"></param>
        /// <param name="columns"></param>
        /// <returns>Number of affected rows. Return -1 when got error!</returns>
        /// NOTE: The columns parameter is separated by comma ','
        public int GrantPrivilege(string privilege, string userOrRole, string withGrantOption = null, string tableOrView = null, string columns = null)
        {
            try
            {
                using (OracleCommand command = new OracleCommand($"{COMBINED_PREFIX}GRANT_PRIVILEGE", Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("PRIVILEGE", OracleDbType.Varchar2).Value = privilege;
                    command.Parameters.Add("USER_OR_ROLE", OracleDbType.Varchar2).Value = userOrRole;

                    // Default value for withGrantOption is NULL so we don't need to check it
                    command.Parameters.Add("WITH_GRANT_OPTION", OracleDbType.Varchar2).Value = withGrantOption;

                    if (tableOrView != null)
                    {
                        command.Parameters.Add("TABLE_OR_VIEW", OracleDbType.Varchar2).Value = tableOrView;
                        if (columns != null)
                        {
                            command.Parameters.Add("COLUMNS_CSV", OracleDbType.Varchar2).Value = columns;
                        }
                    }
                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Revoke privilege from user or role with optional: table or view and columns
        /// </summary>
        /// <param name="privilege"></param>
        /// <param name="userOrRole"></param>
        /// <param name="tableOrView"></param>
        /// <param name="columns"></param>
        /// <returns></returns>
        public int RevokePrivilege(string privilege, string userOrRole, string tableOrView = null, string columns = null)
        {
            try
            {
                using (OracleCommand command = new OracleCommand($"{COMBINED_PREFIX}REVOKE_PRIVILEGE", Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("PRIVILEGE", OracleDbType.Varchar2).Value = privilege;
                    command.Parameters.Add("USER_OR_ROLE", OracleDbType.Varchar2).Value = userOrRole;
                    if (tableOrView != null)
                    {
                        command.Parameters.Add("TABLE_OR_VIEW", OracleDbType.Varchar2).Value = tableOrView;
                        if (columns != null)
                        {
                            command.Parameters.Add("COLUMNS_CSV", OracleDbType.Varchar2).Value = columns;
                        }
                    }
                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Create a new user with password and grant CONNECT privilege
        /// </summary>
        /// <param name="username"></param>
        /// <param name="password"></param>
        /// <returns>Status: -1 when successfully!</returns>
        public int CreateUser(string username, string password)
        {
            try
            {
                using (OracleCommand command = new OracleCommand($"{COMBINED_PREFIX}CREATE_USER", Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("USERNAME", OracleDbType.Varchar2).Value = username;
                    command.Parameters.Add("PASSWORD", OracleDbType.Varchar2).Value = password;
                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Create a new role
        /// </summary>
        /// <param name="roleName"></param>
        /// <returns>Status: -1 when successfully!</returns>
        public int CreateRole(string roleName)
        {
            try
            {
                using (OracleCommand command = new OracleCommand($"{COMBINED_PREFIX}CREATE_ROLE", Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("ROLE_NAME", OracleDbType.Varchar2).Value = roleName;
                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Drop a user
        /// </summary>
        /// <param name="userName"></param>
        /// <returns>Status: -1 when successfully!</returns>
        public int DropUser(string userName)
        {
            try
            {
                using (OracleCommand command = new OracleCommand($"{COMBINED_PREFIX}DROP_USER", Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("USERNAME", OracleDbType.Varchar2).Value = userName;
                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Drop a role
        /// </summary>
        /// <param name="roleName"></param>
        /// <returns>Status: -1 when successfully!</returns>
        public int DropRole(string roleName)
        {
            try
            {
                using (OracleCommand command = new OracleCommand($"{COMBINED_PREFIX}DROP_ROLE", Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("ROLE_NAME", OracleDbType.Varchar2).Value = roleName;
                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }



        /**********************************************************
        * Database's Stored Procedures - Phan He 2
        ***********************************************************/
        static public string ADMIN_TABLE_PREFIX = $"C##ADMIN.UV_N09_";
        public static string GET_SINGLE_LINE_DATA = $"C##ADMIN.N09_GET_SINGLE_LINE_DATA";

        // Table's view name for each role - NHANSU
        public string STAFFS_VIEWBY_STAFF= $"{ADMIN_TABLE_PREFIX}NHANSU_VIEWBY_NHANVIEN";
        public string STAFFS_VIEWBY_TEACHER = $"{ADMIN_TABLE_PREFIX}NHANSU_VIEWBY_GIANGVIEN";
        public string STAFFS_VIEWBY_MINISTRY= $"{ADMIN_TABLE_PREFIX}NHANSU_VIEWBY_GIAOVU";
        public string STAFFS_VIEWBY_UNIT_HEAD = $"{ADMIN_TABLE_PREFIX}NHANSU_VIEWBY_TRUONGDONVI";
        public string STAFFS_VIEWBY_DEPARTMENT_HEAD = $"{ADMIN_TABLE_PREFIX}NHANSU_VIEWBY_TRUONGKHOA";

        // Table's view name for each role - PHANCONG
        public string ASSIGNMENTS_VIEWBY_TEACHER= $"{ADMIN_TABLE_PREFIX}PHANCONG_VIEWBY_GIANGVIEN";
        public string ASSIGNMENTS_VIEWBY_MINISTRY = $"{ADMIN_TABLE_PREFIX}PHANCONG_VIEWBY_GIAOVU";
        public string ASSIGNMENTS_VIEWBY_UNIT_HEAD = $"{ADMIN_TABLE_PREFIX}PHANCONG_VIEWBY_TRUONGDONVI";
        public string ASSIGNMENTS_VIEWBY_DEPARTMENT_HEAD = $"{ADMIN_TABLE_PREFIX}PHANCONG_VIEWBY_TRUONGKHOA";

        // Table's view name for each role - DANGKY
        public string REGISTRATIONS_VIEWBY_TEACHER = $"{ADMIN_TABLE_PREFIX}DANGKY_VIEWBY_GIANGVIEN";
        public string REGISTRATIONS_VIEWBY_MINISTRY= $"{ADMIN_TABLE_PREFIX}DANGKY_VIEWBY_GIAOVU";
        public string REGISTRATIONS_VIEWBY_UNIT_HEAD = $"{ADMIN_TABLE_PREFIX}DANGKY_VIEWBY_TRUONGDONVI";
        public string REGISTRATIONS_VIEWBY_DEPARTMENT_HEAD = $"{ADMIN_TABLE_PREFIX}DANGKY_VIEWBY_TRUONGKHOA";

        // Table's view name for EVERY role
        public string STUDENTS = $"{ADMIN_TABLE_PREFIX}SINHVIEN";
        public string UNIT = $"{ADMIN_TABLE_PREFIX}DONVI";
        public string SUBJECTS = $"{ADMIN_TABLE_PREFIX}HOCPHAN";
        public string COURSE_OPENING_PLAN = $"{ADMIN_TABLE_PREFIX}KHMO";



        // Get data context for each role using stored procedure name, and parameter name and value (optional)
        public T LoadDataContext<T>(string tableName, string parameterName = null, object parameterValue = null) where T : class, new()
        {
            try
            {
                using (OracleCommand cmd = new OracleCommand(GET_SINGLE_LINE_DATA, Connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("STR_TABLE_NAME", OracleDbType.Varchar2).Value = tableName;
                    if (parameterName != null)
                        cmd.Parameters.Add(parameterName, OracleDbType.Varchar2).Value = parameterValue;

                    using (OracleDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            T entity = new T();
                            foreach (PropertyInfo prop in typeof(T).GetProperties())
                            {
                                if (!dr.IsDBNull(dr.GetOrdinal(prop.Name)))
                                {
                                    prop.SetValue(entity, dr[prop.Name]);
                                }
                            }
                            dr.Close();
                            return entity;
                        }
                        else
                        {
                            dr.Close();
                            return null;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Load Data Context Error: {ex.Message}", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return null;
            }
        }



    }
}
