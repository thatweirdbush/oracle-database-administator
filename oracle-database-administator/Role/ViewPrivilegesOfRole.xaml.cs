﻿using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace oracle_database_administator.Role
{
    /// <summary>
    /// Interaction logic for ViewPrivilegesOfRole.xaml
    /// </summary>
    public partial class ViewPrivilegesOfRole : Page
    {
        OracleConnection conn;

        public ViewPrivilegesOfRole()
        {
            InitializeComponent();
        }

        private void UpdateUserGrid()
        {
            try
            {
                string query = "SELECT ROLE, ROLE_ID FROM SYS.DBA_ROLES";
                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    using (OracleDataAdapter adapter = new OracleDataAdapter(command))
                    {
                        DataTable dataTable = new DataTable();
                        adapter.Fill(dataTable);
                        RoleDataGrid.ItemsSource = dataTable.DefaultView;
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Dashboard());
            }
        }

        // Sử dụng sự kiện Unloaded để đảm bảo rằng kết nối được đóng khi chuyển khỏi Page
        private void Page_Unloaded(object sender, RoutedEventArgs e)
        {
            if (conn != null)
            {
                conn.Dispose();
            }
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            conn = Database.Instance.Connection;
            try
            {
                if (conn.State == System.Data.ConnectionState.Open)
                {
                    Console.WriteLine("Connection opened successfully!");
                    //InsertRoleButton.Visibility = Visibility.Collapsed;
                    //DeleteRoleButton.Visibility = Visibility.Collapsed;
                    UpdateUserGrid();
                }
                else
                {
                    MessageBox.Show("Failed to open connection.", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }

            catch (Exception ex)
            {
                MessageBox.Show("Connection error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void InsertButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string roleName = RoleNameTextBox.Text;

                string query = @"BEGIN
                            EXECUTE IMMEDIATE 'ALTER SESSION SET ""_ORACLE_SCRIPT"" = TRUE';
                            EXECUTE IMMEDIATE 'CREATE ROLE " + roleName + "';" +
                            " END;";


                using (OracleCommand command = new OracleCommand(query, conn))
                {
                    int rowSelected = command.ExecuteNonQuery();

                    if (rowSelected == -1)
                    {
                        MessageBox.Show("Create role successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        UpdateUserGrid();
                    }
                    else
                    {
                        MessageBox.Show("Cannot create role!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show("Create error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void DeleteButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (Database.Instance.IsSelectable)
                {
                    string roleName = RoleNameTextBox.Text;
                    RoleNameTextBox.Text = string.Empty;

                    if (!string.IsNullOrEmpty(roleName))
                    {
                        try
                        {
                            string query = @"BEGIN
                            EXECUTE IMMEDIATE 'ALTER SESSION SET ""_ORACLE_SCRIPT"" = TRUE';
                            EXECUTE IMMEDIATE 'DROP ROLE " + roleName + "';" +
                                " END;";

                            using (OracleCommand command = new OracleCommand(query, conn))
                            {
                                int rowSelected = command.ExecuteNonQuery();

                                if (rowSelected == -1)
                                {
                                    MessageBox.Show("Drop role successfully!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                    UpdateUserGrid();
                                }
                                else
                                {
                                    MessageBox.Show("Cannot drop role!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                    }
                    else
                    {
                        MessageBox.Show("No role selected!", "Message", MessageBoxButton.OK, MessageBoxImage.Information);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Drop error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Dashboard());
            }
        }

        private void RolesUserButton_Click(object sender, RoutedEventArgs e)
        {

        }

        private void PriUserButton_Click(object sender, RoutedEventArgs e)
        {

        }

        private void RoleDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try
            {
                if (Database.Instance.IsSelectable)
                {
                    if (RoleDataGrid.SelectedItem != null)
                    {
                        DataRowView row = (DataRowView)RoleDataGrid.SelectedItem;
                        if (row != null)
                        {
                            RoleNameTextBox.Text = row["ROLE"].ToString();
                        }
                    }
                }
                //else
                //{
                //    if (RoleDataGrid.SelectedItem != null)
                //    {
                //        DataRowView row = (DataRowView)RoleDataGrid.SelectedItem;
                //        if (row != null)
                //        {
                //            RoleNameTextBox.Text = row["ROLE"].ToString();
                //        }
                //    }
                //}
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, "Message", MessageBoxButton.OK, MessageBoxImage.Information);
            }
        }
    }
}
