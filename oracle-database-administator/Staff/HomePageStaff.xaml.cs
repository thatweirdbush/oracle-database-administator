﻿using System;
using System.Collections.Generic;
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

namespace oracle_database_administator.Staff
{
    /// <summary>
    /// Interaction logic for HomePageStaff.xaml
    /// </summary>
    public partial class HomePageStaff : Page
    {
        public HomePageStaff()
        {
            InitializeComponent();
        }
        private void HideAllElements()
        {
            Label_TTCN.Visibility = Visibility.Hidden;
            DataGrid_TTCN.Visibility = Visibility.Hidden;
            Label_DonVi.Visibility = Visibility.Hidden;
            Table_DonVi.Visibility = Visibility.Hidden;
            Label_KHHT.Visibility = Visibility.Hidden;
            TextBlock_DSHocPhan.Visibility = Visibility.Hidden;
            TextBlock_KeHoachMo.Visibility = Visibility.Hidden;
            Table_DsHocPhan.Visibility = Visibility.Hidden;
            Table_KeHoachMo.Visibility = Visibility.Hidden;
            Label_DsSinhVien.Visibility = Visibility.Hidden;
            Table_DsSinhVien.Visibility = Visibility.Hidden;
        }

        private void HomeButton_Click(object sender, RoutedEventArgs e)
        {
            if (Application.Current.MainWindow is MainWindow mainWindow && mainWindow.MainFrame != null)
            {
                mainWindow.MainFrame.Navigate(new oracle_database_administator.Dashboard());
            }
        }

        private void TTCN_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Label_TTCN.Visibility = Visibility.Visible;
            DataGrid_TTCN.Visibility = Visibility.Visible;
        }

        private void TTDonVi_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Label_DonVi.Visibility = Visibility.Visible;
            Table_DonVi.Visibility = Visibility.Visible;
        }

        private void KHHocTap_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Label_KHHT.Visibility = Visibility.Visible;
            TextBlock_DSHocPhan.Visibility = Visibility.Visible;
            TextBlock_KeHoachMo.Visibility = Visibility.Visible;    
        }

        private void DSHocPhan_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Label_KHHT.Visibility = Visibility.Visible;
            TextBlock_DSHocPhan.Visibility = Visibility.Visible;
            TextBlock_KeHoachMo.Visibility = Visibility.Visible;
            Table_DsHocPhan.Visibility = Visibility.Visible;
        }

        private void KeHoachMo_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Label_KHHT.Visibility = Visibility.Visible;
            TextBlock_DSHocPhan.Visibility = Visibility.Visible;
            TextBlock_KeHoachMo.Visibility = Visibility.Visible;
            Table_KeHoachMo.Visibility = Visibility.Visible;
        }

        private void DSSinhVien_Click(object sender, RoutedEventArgs e)
        {
            HideAllElements();
            Label_DsSinhVien.Visibility = Visibility.Visible;
            Table_DsSinhVien.Visibility = Visibility.Visible;
        }

        private void EditSDT_Click(object sender, RoutedEventArgs e)
        {
            TextBlock_SDT.IsHitTestVisible = true;
            TextBlock_SDT.Focusable = true;
        }

        private void Table_DsHocPhan_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DonVi_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_KeHoachMo_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }

        private void Table_DsSinhVien_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }


    }
}
