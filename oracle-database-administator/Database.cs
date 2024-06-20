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
using oracle_database_administator.User;
using System.Reflection;
using oracle_database_administator.Class;
using oracle_database_administator.Teacher;
using System.Windows.Navigation;
using oracle_database_administator.Staff;
using oracle_database_administator.Ministry;
using System.Windows.Controls;
using System.Collections.ObjectModel;

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
                        string connectionString = $"DATA SOURCE=localhost:1521/PDB_N09;{SYSDBA_OPTION}PERSIST SECURITY INFO=True;USER ID={ConnectionUsername};PASSWORD={ConnectionPassword}";
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
            if (_connection != null || ConnectionPassword != "")
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

        /// <summary>
        /// Clear up connection credentials
        /// </summary>
        public void ClearUpConnection()
        {
            // Disconnect from the server & reset the connection credentials
            Disconnect();
            ConnectionUsername = "";
            ConnectionPassword = "";
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
            set { dataGridChanged = value; }
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
                    string connectionString = $"DATA SOURCE=localhost:1521/PDB_N09;{SYSDBA_OPTION}PERSIST SECURITY INFO=True;USER ID={new_username};PASSWORD={new_password}";

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
        static public string ADMIN_SCHEMA = "N09_ADMIN.";
        static public string DEFAULT_PREFIX = "N09_";
        static public string DEFAULT_PREFIX_VIEW = "UV_";

        // Combine schema and prefix to create stored procedure & function name
        static public string COMBINED_PREFIX = $"{ADMIN_SCHEMA}{DEFAULT_PREFIX}";


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
            try
            {
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
            catch (Exception ex)
            {
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
        static public string ADMIN_PREFIX = $"N09_ADMIN.N09_";

        // Table's name for EVERY role
        public string STUDENTS = $"{ADMIN_PREFIX}SINHVIEN";
        public string PERSONNELS = $"{ADMIN_PREFIX}NHANSU";
        public string UNITS = $"{ADMIN_PREFIX}DONVI";
        public string SUBJECTS = $"{ADMIN_PREFIX}HOCPHAN";
        public string COURSE_OPENING_PLANS = $"{ADMIN_PREFIX}KHMO";
        public string ASSIGNMENTS = $"{ADMIN_PREFIX}PHANCONG";
        public string REGISTRATIONS = $"{ADMIN_PREFIX}DANGKY";
        public string NOTIFICATIONS = $"{ADMIN_PREFIX}THONGBAO";

        // Special stored procedures
        public string SELECT_ANY_TABLE_ADMIN = $"{ADMIN_PREFIX}SELECT_ANY_TABLE";
        public string GET_SINGLE_LINE_DATA = $"{ADMIN_PREFIX}GET_SINGLE_LINE_DATA";
        public string UPDATE_SINGLE_COL_STAFF = $"{ADMIN_PREFIX}UPDATE_SINGLE_COL_NHANSU";
        public string UPDATE_SINGLE_COL_STUDENT = $"{ADMIN_PREFIX}UPDATE_SINGLE_COL_SINHVIEN";
        public string STUDENT_REGISTRATION_BY_TEACHER = $"{ADMIN_PREFIX}DANGKY_JOIN_PHANCONG_BY_GIANGVIEN";
        public string GET_CURRENT_ROLE = $"{ADMIN_PREFIX}GET_CURRENT_USER_ROLE";

        // Stored procedures for Check exist
        public string IS_EXIST_STUDENT = $"{ADMIN_PREFIX}IS_EXIST_SINHVIEN";
        public string IS_EXIST_PERSONNEL = $"{ADMIN_PREFIX}IS_EXIST_NHANSU";
        public string IS_EXIST_UNIT = $"{ADMIN_PREFIX}IS_EXIST_DONVI";
        public string IS_EXIST_SUBJECT = $"{ADMIN_PREFIX}IS_EXIST_HOCPHAN";
        public string IS_EXIST_COURSE_OPENING_PLAN = $"{ADMIN_PREFIX}IS_EXIST_KHMO";
        public string IS_EXIST_ASSIGNMENT = $"{ADMIN_PREFIX}IS_EXIST_PHANCONG";
        public string IS_EXIST_REGISTRATION = $"{ADMIN_PREFIX}IS_EXIST_DANGKY";

        // Stored procedures for CRUD operations
        public string INSERT_PERSONNEL = $"{ADMIN_PREFIX}INSERT_NHANSU";
        public string UPDATE_PERSONNEL = $"{ADMIN_PREFIX}UPDATE_NHANSU";
        public string INSERT_STUDENT = $"{ADMIN_PREFIX}INSERT_SINHVIEN";
        public string UPDATE_STUDENT = $"{ADMIN_PREFIX}UPDATE_SINHVIEN";
        public string INSERT_UNIT = $"{ADMIN_PREFIX}INSERT_DONVI";
        public string UPDATE_UNIT = $"{ADMIN_PREFIX}UPDATE_DONVI";
        public string INSERT_SUBJECT = $"{ADMIN_PREFIX}INSERT_HOCPHAN";
        public string UPDATE_SUBJECT = $"{ADMIN_PREFIX}UPDATE_HOCPHAN";
        public string INSERT_COURSE_OPENING_PLAN = $"{ADMIN_PREFIX}INSERT_KHMO";
        public string UPDATE_COURSE_OPENING_PLAN = $"{ADMIN_PREFIX}UPDATE_KHMO";
        public string INSERT_ASSIGNMENT = $"{ADMIN_PREFIX}INSERT_PHANCONG";
        public string UPDATE_ASSIGNMENT = $"{ADMIN_PREFIX}UPDATE_PHANCONG";
        public string INSERT_REGISTRATION = $"{ADMIN_PREFIX}INSERT_DANGKY";
        public string UPDATE_REGISTRATION = $"{ADMIN_PREFIX}UPDATE_DANGKY";
        public string DELETE_REGISTRATION = $"{ADMIN_PREFIX}DELETE_DANGKY";
        public string DELETE_PERSONNEL = $"{ADMIN_PREFIX}DELETE_NHANSU";
        public string DELETE_ASSIGNMENT= $"{ADMIN_PREFIX}DELETE_PHANCONG";

        // Table's name for Security Admin
        public string STANDARD_AUDIT = $"{COMBINED_PREFIX}AUDIT_TRAIL";
        public string FGA = $"{COMBINED_PREFIX}FGA";
        public string AUDIT_OBJECTS = $"{COMBINED_PREFIX}AUDIT_OBJECTS";





        /// <summary>
        /// Get data context for each role using stored procedure name, and parameter name and value (optional)
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="tableName"></param>
        /// <param name="parameterName"></param>
        /// <param name="parameterValue"></param>
        /// <returns>T object</returns>
        public T LoadSingleLineDataContext<T>(string tableName, string parameterName = null, object parameterValue = null) where T : class, new()
        {
            try
            {
                using (OracleCommand cmd = new OracleCommand(GET_SINGLE_LINE_DATA, Connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
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

        /// <summary>
        /// Get data context for each role using ObservableCollection, stored procedure name, and parameter name and value (optional)
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="tableName"></param>
        /// <param name="parameterName"></param>
        /// <param name="parameterValue"></param>
        /// <returns>ObservableCollection</returns>
        public ObservableCollection<T> LoadDataContext<T>(string tableName, string parameterName = null, object parameterValue = null) where T : class, new()
        {
            try
            {
                ObservableCollection<T> entities = new ObservableCollection<T>();

                using (OracleCommand cmd = new OracleCommand(SELECT_ANY_TABLE_ADMIN, Connection))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("STR_TABLE_NAME", OracleDbType.Varchar2).Value = tableName;
                    if (parameterName != null)
                        cmd.Parameters.Add(parameterName, OracleDbType.Varchar2).Value = parameterValue;

                    using (OracleDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            T entity = new T();
                            foreach (PropertyInfo prop in typeof(T).GetProperties())
                            {
                                if (!dr.IsDBNull(dr.GetOrdinal(prop.Name)))
                                {
                                    prop.SetValue(entity, dr[prop.Name]);
                                }

                            }
                            entities.Add(entity);

                        }
                        dr.Close();
                        return entities;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Load Data Context Error: {ex.Message}", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return null;
            }
        }

        /// <summary>
        /// Update NHANSU table with single column
        /// </summary>
        /// <param name="columnName"></param>
        /// <param name="columnValue"></param>
        /// <param name="ID"></param>
        /// <returns>Status: -1 when successfully!</returns>
        public int UpdateStaffPhoneNo(string columnName, object columnValue, object ID)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(UPDATE_SINGLE_COL_STAFF, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_COLUMN", OracleDbType.Varchar2).Value = columnName;
                    command.Parameters.Add("STR_VALUE", OracleDbType.Varchar2).Value = columnValue;
                    command.Parameters.Add("STR_ID", OracleDbType.Varchar2).Value = ID;
                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return 1;
            }
        }

        public int UpdateStudentSingleCol(string columnName, object columnValue, object ID)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(UPDATE_SINGLE_COL_STUDENT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_COLUMN", OracleDbType.Varchar2).Value = columnName;
                    command.Parameters.Add("STR_VALUE", OracleDbType.Varchar2).Value = columnValue;
                    command.Parameters.Add("STR_ID", OracleDbType.Varchar2).Value = ID;
                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return 1;
            }
        }

        /// <summary>
        /// Get DANGKY JOIN PHANCONG BY GIANGVIEN
        /// </summary>
        /// <param name="assignment"></param>
        /// <returns>Table type with selected cols</returns>
        public DataView GetRegistrationsByTeacher(Assignment assignment)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(STUDENT_REGISTRATION_BY_TEACHER, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    command.Parameters.Add("STR_MAGV", OracleDbType.Varchar2).Value = assignment.MAGV;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = assignment.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Varchar2).Value = assignment.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Varchar2).Value = assignment.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = assignment.MACT;

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
        /// Get current role of user
        /// </summary>
        /// <returns>String role</returns>
        public string GetCurrentRole()
        {
            try
            {
                using (OracleCommand command = new OracleCommand(GET_CURRENT_ROLE, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;

                    object result = command.ExecuteScalar();
                    return result.ToString();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Get Current Role Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return null;
            }
        }


        /**********************************************************
        * Stored Procedures - Check exist
        ***********************************************************/
        /// <summary>
        /// Check if student is exist in database
        /// </summary>
        /// <param name="studentId"></param>
        /// <returns>True/False</returns>
        public bool IsExistStudent(string studentId)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(IS_EXIST_STUDENT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    command.Parameters.Add("STR_MASV", OracleDbType.Varchar2).Value = studentId;
                    var result = command.ExecuteScalar();

                    return Convert.ToInt32(result) > 0;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return false;
            }
        }

        /// <summary>
        /// Check if personnel is exist in database
        /// </summary>
        /// <param name="personnelId"></param>
        /// <returns></returns>
        public bool IsExistPersonnel(string personnelId)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(IS_EXIST_PERSONNEL, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    command.Parameters.Add("STR_MANV", OracleDbType.Varchar2).Value = personnelId;
                    var result = command.ExecuteScalar();

                    return Convert.ToInt32(result) > 0;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return false;
            }
        }

        /// <summary>
        /// Check if unit is exist in database
        /// </summary>
        /// <param name="unitId"></param>
        /// <returns>True/False</returns>
        public bool IsExistUnit(string unitId)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(IS_EXIST_UNIT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    command.Parameters.Add("STR_MADV", OracleDbType.Varchar2).Value = unitId;
                    var result = command.ExecuteScalar();

                    return Convert.ToInt32(result) > 0;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return false;
            }
        }

        /// <summary>
        /// Check if subject is exist in database
        /// </summary>
        /// <param name="subjectId"></param>
        /// <returns>True/False</returns>
        public bool IsExistSubject(string subjectId)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(IS_EXIST_SUBJECT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = subjectId;
                    var result = command.ExecuteScalar();

                    return Convert.ToInt32(result) > 0;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return false;
            }
        }

        /// <summary>
        /// Check if course opening plan is exist in database
        /// </summary>
        /// <param name="plan"></param>
        /// <returns>True/False</returns>
        public bool IsExistCourseOpeningPlan(CourseOpeningPlan plan)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(IS_EXIST_COURSE_OPENING_PLAN, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = plan.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Varchar2).Value = plan.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Varchar2).Value = plan.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = plan.MACT;
                    var result = command.ExecuteScalar();

                    return Convert.ToInt32(result) > 0;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return false;
            }
        }

        /// <summary>
        /// Check if assignment is exist in database
        /// </summary>
        /// <param name="assignment"></param>
        /// <returns>True/False</returns>
        public bool IsExistAssignment(Assignment assignment)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(IS_EXIST_ASSIGNMENT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    command.Parameters.Add("STR_MAGV", OracleDbType.Varchar2).Value = assignment.MAGV;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = assignment.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Int64).Value = assignment.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Int64).Value = assignment.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = assignment.MACT;
                    var result = command.ExecuteScalar();

                    return Convert.ToInt32(result) > 0;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return false;
            }
        }

        /// <summary>
        /// Check if registration is exist in database
        /// </summary>
        /// <param name="registration"></param>
        /// <returns>True/False</returns>
        public bool IsExistRegistration(Registration registration)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(IS_EXIST_REGISTRATION, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(outParameter, OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    command.Parameters.Add("STR_MASV", OracleDbType.Varchar2).Value = registration.MASV;
                    command.Parameters.Add("STR_MAGV", OracleDbType.Varchar2).Value = registration.MAGV;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = registration.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Int64).Value = registration.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Int64).Value = registration.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = registration.MACT;

                    var result = command.ExecuteScalar();

                    return Convert.ToInt32(result) > 0;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                return false;
            }
        }


        /**********************************************************
        * Stored Procedures - CRUD operations
        ***********************************************************/
        /// <summary>
        /// Insert student into database
        /// </summary>
        /// <param name="student"></param>
        /// <returns>-1 if success</returns>
        public int InsertStudent(Class.Student student)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(INSERT_STUDENT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MASV", OracleDbType.Varchar2).Value = student.MASV;
                    command.Parameters.Add("STR_HOTEN", OracleDbType.Varchar2).Value = (object)student.HOTEN ?? DBNull.Value;
                    command.Parameters.Add("STR_PHAI", OracleDbType.Varchar2).Value = (object)student.PHAI ?? DBNull.Value;
                    command.Parameters.Add("STR_NGSINH", OracleDbType.Date).Value = (object)student.NGSINH ?? DBNull.Value;
                    command.Parameters.Add("STR_DIACHI", OracleDbType.Varchar2).Value = (object)student.DIACHI ?? DBNull.Value;
                    command.Parameters.Add("STR_DT", OracleDbType.Varchar2).Value = (object)student.DT ?? DBNull.Value;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = (object)student.MACT ?? DBNull.Value;
                    command.Parameters.Add("STR_MANGANH", OracleDbType.Varchar2).Value = (object)student.MANGANH ?? DBNull.Value;
                    command.Parameters.Add("STR_SOTCTL", OracleDbType.Int64).Value = (object)student.SOTCTL ?? DBNull.Value;
                    command.Parameters.Add("STR_DTBTL", OracleDbType.Double).Value = (object)student.DTBTL ?? DBNull.Value;
                    command.Parameters.Add("STR_COSO", OracleDbType.Varchar2).Value = (object)student.COSO ?? DBNull.Value;
                    
                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Insert Student Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Update student into database
        /// </summary>
        /// <param name="student"></param>
        /// <returns>-1 if success</returns>
        public int UpdateStudent(Class.Student student)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(UPDATE_STUDENT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MASV", OracleDbType.Varchar2).Value = student.MASV;
                    command.Parameters.Add("STR_HOTEN", OracleDbType.Varchar2).Value = (object)student.HOTEN ?? DBNull.Value;
                    command.Parameters.Add("STR_PHAI", OracleDbType.Varchar2).Value = (object)student.PHAI ?? DBNull.Value;
                    command.Parameters.Add("STR_NGSINH", OracleDbType.Date).Value = (object)student.NGSINH ?? DBNull.Value;
                    command.Parameters.Add("STR_DIACHI", OracleDbType.Varchar2).Value = (object)student.DIACHI ?? DBNull.Value;
                    command.Parameters.Add("STR_DT", OracleDbType.Varchar2).Value = (object)student.DT ?? DBNull.Value;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = (object)student.MACT ?? DBNull.Value;
                    command.Parameters.Add("STR_MANGANH", OracleDbType.Varchar2).Value = (object)student.MANGANH ?? DBNull.Value;
                    command.Parameters.Add("STR_SOTCTL", OracleDbType.Int64).Value = (object)student.SOTCTL ?? DBNull.Value;
                    command.Parameters.Add("STR_DTBTL", OracleDbType.Double).Value = (object)student.DTBTL ?? DBNull.Value;
                    command.Parameters.Add("STR_COSO", OracleDbType.Varchar2).Value = (object)student.COSO ?? DBNull.Value;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Update Student Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Insert registration into database
        /// </summary>
        /// <param name="registration"></param>
        /// <returns>-1 if success</returns>
        public int InsertRegistration(Registration registration)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(INSERT_REGISTRATION, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MASV", OracleDbType.Varchar2).Value = registration.MASV;
                    command.Parameters.Add("STR_MAGV", OracleDbType.Varchar2).Value = registration.MAGV;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = registration.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Int64).Value = registration.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Int64).Value = registration.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = registration.MACT;
                    command.Parameters.Add("STR_DIEMTH", OracleDbType.Double).Value = registration.DIEMTH;
                    command.Parameters.Add("STR_DIEMQT", OracleDbType.Double).Value = registration.DIEMQT;
                    command.Parameters.Add("STR_DIEMCK", OracleDbType.Double).Value = registration.DIEMCK;
                    command.Parameters.Add("STR_DIEMTK", OracleDbType.Double).Value = registration.DIEMTK;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Insert Registration Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Update registration into database
        /// </summary>
        /// <param name="registration"></param>
        /// <returns>-1 if success</returns>
        public int UpdateRegistration(Registration registration)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(UPDATE_REGISTRATION, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MASV", OracleDbType.Varchar2).Value = registration.MASV;
                    command.Parameters.Add("STR_MAGV", OracleDbType.Varchar2).Value = registration.MAGV;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = registration.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Int64).Value = registration.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Int64).Value = registration.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = registration.MACT;
                    command.Parameters.Add("STR_DIEMTH", OracleDbType.Double).Value = registration.DIEMTH;
                    command.Parameters.Add("STR_DIEMQT", OracleDbType.Double).Value = registration.DIEMQT;
                    command.Parameters.Add("STR_DIEMCK", OracleDbType.Double).Value = registration.DIEMCK;
                    command.Parameters.Add("STR_DIEMTK", OracleDbType.Double).Value = registration.DIEMTK;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Update Registration Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Insert personnel from database
        /// </summary>
        /// <param name="personnel"></param>
        /// <returns>-1 if success</returns>
        public int InsertPersonnel(Personnel personnel)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(INSERT_PERSONNEL, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MANV", OracleDbType.Varchar2).Value = personnel.MANV;
                    command.Parameters.Add("STR_HOTEN", OracleDbType.Varchar2).Value = (object)personnel.HOTEN ?? DBNull.Value;
                    command.Parameters.Add("STR_PHAI", OracleDbType.Varchar2).Value = (object)personnel.PHAI ?? DBNull.Value;
                    command.Parameters.Add("STR_NGSINH", OracleDbType.Date).Value = (object)personnel.NGSINH ?? DBNull.Value;
                    command.Parameters.Add("STR_PHUCAP", OracleDbType.Int64).Value = (object)personnel.PHUCAP ?? DBNull.Value;
                    command.Parameters.Add("STR_DT", OracleDbType.Varchar2).Value = (object)personnel.DT ?? DBNull.Value;
                    command.Parameters.Add("STR_VAITRO", OracleDbType.Varchar2).Value = (object)personnel.VAITRO ?? DBNull.Value;
                    command.Parameters.Add("STR_MADV", OracleDbType.Varchar2).Value = (object)personnel.MADV ?? DBNull.Value;
                    command.Parameters.Add("STR_COSO", OracleDbType.Varchar2).Value = (object)personnel.COSO ?? DBNull.Value;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Insert Personnel Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Update personnel into database
        /// </summary>
        /// <param name="personnel"></param>
        /// <returns>-1 if success</returns>
        public int UpdatePersonnel(Personnel personnel)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(UPDATE_PERSONNEL, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MANV", OracleDbType.Varchar2).Value = personnel.MANV;
                    command.Parameters.Add("STR_HOTEN", OracleDbType.Varchar2).Value = (object)personnel.HOTEN ?? DBNull.Value;
                    command.Parameters.Add("STR_PHAI", OracleDbType.Varchar2).Value = (object)personnel.PHAI ?? DBNull.Value;
                    command.Parameters.Add("STR_NGSINH", OracleDbType.Date).Value = (object)personnel.NGSINH ?? DBNull.Value;
                    command.Parameters.Add("STR_PHUCAP", OracleDbType.Int64).Value = (object)personnel.PHUCAP ?? DBNull.Value;
                    command.Parameters.Add("STR_DT", OracleDbType.Varchar2).Value = (object)personnel.DT ?? DBNull.Value;
                    command.Parameters.Add("STR_VAITRO", OracleDbType.Varchar2).Value = (object)personnel.VAITRO ?? DBNull.Value;
                    command.Parameters.Add("STR_MADV", OracleDbType.Varchar2).Value = (object)personnel.MADV ?? DBNull.Value;
                    command.Parameters.Add("STR_COSO", OracleDbType.Varchar2).Value = (object)personnel.COSO ?? DBNull.Value;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Update Personnel Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Insert unit into database
        /// </summary>
        /// <param name="unit"></param>
        /// <returns>-1 if success</returns>
        public int InsertUnit(Unit unit)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(INSERT_UNIT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MADV", OracleDbType.Varchar2).Value = unit.MADV;
                    command.Parameters.Add("STR_TENDV", OracleDbType.Varchar2).Value = (object)unit.TENDV ?? DBNull.Value;
                    command.Parameters.Add("STR_TRGDV", OracleDbType.Varchar2).Value = (object)unit.TRGDV ?? DBNull.Value;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Insert Unit Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Update unit into database
        /// </summary>
        /// <param name="unit"></param>
        /// <returns>-1 if success</returns>
        public int UpdateUnit(Unit unit)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(UPDATE_UNIT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MADV", OracleDbType.Varchar2).Value = unit.MADV;
                    command.Parameters.Add("STR_TENDV", OracleDbType.Varchar2).Value = (object)unit.TENDV ?? DBNull.Value;
                    command.Parameters.Add("STR_TRGDV", OracleDbType.Varchar2).Value = (object)unit.TRGDV ?? DBNull.Value;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Update Unit Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Insert subject into database
        /// </summary>
        /// <param name="subject"></param>
        /// <returns>-1 if success</returns>
        public int InsertSubject(Subject subject)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(INSERT_SUBJECT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = subject.MAHP;
                    command.Parameters.Add("STR_TENHP", OracleDbType.Varchar2).Value = (object)subject.TENHP ?? DBNull.Value;
                    command.Parameters.Add("STR_SOTC", OracleDbType.Int64).Value = (object)subject.SOTC ?? DBNull.Value;
                    command.Parameters.Add("STR_SOTL", OracleDbType.Int64).Value = (object)subject.STLT ?? DBNull.Value;
                    command.Parameters.Add("STR_SOTH", OracleDbType.Int64).Value = (object)subject.STTH ?? DBNull.Value;
                    command.Parameters.Add("STR_SOSVTD", OracleDbType.Varchar2).Value = (object)subject.SOSVTD ?? DBNull.Value;
                    command.Parameters.Add("STR_MADV", OracleDbType.Varchar2).Value = (object)subject.MADV ?? DBNull.Value;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Insert Subject Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Update subject into database
        /// </summary>
        /// <param name="subject"></param>
        /// <returns>-1 if success</returns>
        public int UpdateSubject(Subject subject)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(UPDATE_SUBJECT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = subject.MAHP;
                    command.Parameters.Add("STR_TENHP", OracleDbType.Varchar2).Value = (object)subject.TENHP ?? DBNull.Value;
                    command.Parameters.Add("STR_SOTC", OracleDbType.Int64).Value = (object)subject.SOTC ?? DBNull.Value;
                    command.Parameters.Add("STR_SOTL", OracleDbType.Int64).Value = (object)subject.STLT ?? DBNull.Value;
                    command.Parameters.Add("STR_SOTH", OracleDbType.Int64).Value = (object)subject.STTH ?? DBNull.Value;
                    command.Parameters.Add("STR_SOSVTD", OracleDbType.Varchar2).Value = (object)subject.SOSVTD ?? DBNull.Value;
                    command.Parameters.Add("STR_MADV", OracleDbType.Varchar2).Value = (object)subject.MADV ?? DBNull.Value;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Update Subject Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Insert course opening plan into database
        /// </summary>
        /// <param name="courseOpeningPlan"></param>
        /// <returns>-1 if success</returns>
        public int InsertCourseOpeningPlan(CourseOpeningPlan courseOpeningPlan)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(INSERT_COURSE_OPENING_PLAN, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = courseOpeningPlan.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Int64).Value = courseOpeningPlan.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Int64).Value = courseOpeningPlan.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = courseOpeningPlan.MACT;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Insert Course Opening Plan Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Update course opening plan into database
        /// </summary>
        /// <param name="newPlan"></param>
        /// <param name="oldPlan"></param>
        /// <returns>-1 if success</returns>
        public int UpdateCourseOpeningPlan(CourseOpeningPlan newPlan, CourseOpeningPlan oldPlan)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(UPDATE_COURSE_OPENING_PLAN, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = newPlan.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Int64).Value = newPlan.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Int64).Value = newPlan.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = newPlan.MACT;
                    command.Parameters.Add("STR_OLD_MAHP", OracleDbType.Varchar2).Value = oldPlan.MAHP;
                    command.Parameters.Add("STR_OLD_HK", OracleDbType.Int64).Value = oldPlan.HK;
                    command.Parameters.Add("STR_OLD_NAM", OracleDbType.Int64).Value = oldPlan.NAM;
                    command.Parameters.Add("STR_OLD_MACT", OracleDbType.Varchar2).Value = oldPlan.MACT;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Update Course Opening Plan Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Insert assignment into database
        /// </summary>
        /// <param name="assignment"></param>
        /// <returns>-1 if success</returns>
        public int InsertAssignment(Assignment assignment)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(INSERT_ASSIGNMENT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MAGV", OracleDbType.Varchar2).Value = assignment.MAGV;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = assignment.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Int64).Value = assignment.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Int64).Value = assignment.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = assignment.MACT;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Insert Assignment Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Update assignment into database
        /// </summary>
        /// <param name="newAssignment"></param>
        /// <param name="oldAssignment"></param>
        /// <returns>-1 if success</returns>
        public int UpdateAssignment(Assignment newAssignment, Assignment oldAssignment)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(UPDATE_ASSIGNMENT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MAGV", OracleDbType.Varchar2).Value = newAssignment.MAGV;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = newAssignment.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Int64).Value = newAssignment.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Int64).Value = newAssignment.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = newAssignment.MACT;
                    command.Parameters.Add("STR_OLD_MAGV", OracleDbType.Varchar2).Value = oldAssignment.MAGV;
                    command.Parameters.Add("STR_OLD_MAHP", OracleDbType.Varchar2).Value = oldAssignment.MAHP;
                    command.Parameters.Add("STR_OLD_HK", OracleDbType.Int64).Value = oldAssignment.HK;
                    command.Parameters.Add("STR_OLD_NAM", OracleDbType.Int64).Value = oldAssignment.NAM;
                    command.Parameters.Add("STR_OLD_MACT", OracleDbType.Varchar2).Value = oldAssignment.MACT;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Update Assignment Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Delete registration from database
        /// </summary>
        /// <param name="registration"></param>
        /// <returns>-1 if success</returns>
        public int DeleteRegistration(Registration registration)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(DELETE_REGISTRATION, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MASV", OracleDbType.Varchar2).Value = registration.MASV;
                    command.Parameters.Add("STR_MAGV", OracleDbType.Varchar2).Value = registration.MAGV;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = registration.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Int64).Value = registration.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Int64).Value = registration.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = registration.MACT;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Delete Registration Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        /// <summary>
        /// Delete personnel from database
        /// </summary>
        /// <param name="personnel"></param>
        /// <returns>-1 if success</returns>
        public int DeletePersonnel(Personnel personnel)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(DELETE_PERSONNEL, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MANV", OracleDbType.Varchar2).Value = personnel.MANV;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Delete Personnel Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }

        public int DeleteAssignment(Assignment assignment)
        {
            try
            {
                using (OracleCommand command = new OracleCommand(DELETE_ASSIGNMENT, Connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add("STR_MAGV", OracleDbType.Varchar2).Value = assignment.MAGV;
                    command.Parameters.Add("STR_MAHP", OracleDbType.Varchar2).Value = assignment.MAHP;
                    command.Parameters.Add("STR_HK", OracleDbType.Int64).Value = assignment.HK;
                    command.Parameters.Add("STR_NAM", OracleDbType.Int64).Value = assignment.NAM;
                    command.Parameters.Add("STR_MACT", OracleDbType.Varchar2).Value = assignment.MACT;

                    return command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Delete Assignment Error", MessageBoxButton.OK, MessageBoxImage.Information);
                return 0;
            }
        }
    }
}
