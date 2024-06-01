-- Lớp: CQ2021/1
-- Nhóm: 09
-- Thành viên:
-- 21120037 - Mã Thùy Anh
-- 21120060 - Nguyễn Long Giang
-- 21120082 - Phan Quốc Huy 
-- 21120117 - Lê Thị Hồng Phượng



----------------------------------------------------------------
-- Chèn dữ liệu vào bảng N09_DONVI
----------------------------------------------------------------
INSERT INTO N09_DONVI (MADV, TENDV, TRGDV) VALUES ('DV001', 'Van phong khoa', 'NV001');
INSERT INTO N09_DONVI (MADV, TENDV, TRGDV) VALUES ('DV002', 'Bo mon HTTT', 'NV101');
INSERT INTO N09_DONVI (MADV, TENDV, TRGDV) VALUES ('DV003', 'Bo mon CNPM', 'NV102');
INSERT INTO N09_DONVI (MADV, TENDV, TRGDV) VALUES ('DV004', 'Bo mon KHMT', 'NV103');
INSERT INTO N09_DONVI (MADV, TENDV, TRGDV) VALUES ('DV005', 'Bo mon CNTT', 'NV104');
INSERT INTO N09_DONVI (MADV, TENDV, TRGDV) VALUES ('DV006', 'Bo mon TGMT', 'NV105');
INSERT INTO N09_DONVI (MADV, TENDV, TRGDV) VALUES ('DV007', 'Bo mon MMT va Vien thong', 'NV102');
/

----------------------------------------------------------------
-- Chèn dữ liệu vào bảng N09_NHANSU
----------------------------------------------------------------
-- Thêm dữ liệu cho vai trò "Trưởng khoa"
INSERT INTO N09_NHANSU (MANV, HOTEN, PHAI, NGSINH, PHUCAP, DT, VAITRO, MADV)
VALUES ('NV001', 'Nguyễn Thị Minh Thư', 'Nu', TO_DATE('1991-01-01', 'YYYY-MM-DD'), 9000000, '0909123001', 'Truong khoa', 'DV001');


----------------------------------------------------------------
-- Thêm dữ liệu cho vai trò "Trưởng đơn vị"
----------------------------------------------------------------
-- <NOTE>
-- Chỉ tạo 5 Trưởng đơn vị vì Trưởng khoa cũng là 1 Trưởng đơn vị
DECLARE
    v_manv CHAR(5);
BEGIN
    FOR i IN 1..5 LOOP
        v_manv := 'NV1' || LPAD(i, 2, '0');        
        INSERT INTO N09_NHANSU (MANV, HOTEN, PHAI, NGSINH, PHUCAP, DT, VAITRO, MADV)
        VALUES (v_manv, 'Trưởng Đơn Vị ' || i, 
        CASE WHEN MOD(i, 2) = 0 THEN 'Nam' ELSE 'Nu' END, 
        TO_DATE('1970-01-01', 'YYYY-MM-DD'), 
        1000000 + 10000 * i, 
        '090912310' || MOD(i, 10), 
        'Truong don vi', 
        'DV00' || (MOD(i, 7) + 1));
    END LOOP;
END;
/

----------------------------------------------------------------
-- Thêm dữ liệu cho vai trò "Giảng viên"
----------------------------------------------------------------
DECLARE
    v_manv CHAR(5);
BEGIN
    FOR i IN 1..80 LOOP
        v_manv := 'NV2' || LPAD(i, 2, '0');        
        INSERT INTO N09_NHANSU (MANV, HOTEN, PHAI, NGSINH, PHUCAP, DT, VAITRO, MADV)
        VALUES (v_manv, 'Giảng Viên ' || i, 
        CASE WHEN MOD(i, 2) = 0 THEN 'Nam' ELSE 'Nu' END, 
        TO_DATE('1990-01-01', 'YYYY-MM-DD'), 
        4000000 + 30000 * i, 
        '09091232' || MOD(i, 100), 
        'Giang vien', 
        'DV00' || (MOD(i, 7) + 1));
    END LOOP;
END;
/

----------------------------------------------------------------
-- Thêm dữ liệu cho vai trò "Giáo vụ"
----------------------------------------------------------------
DECLARE
    v_manv CHAR(5);
BEGIN
    FOR i IN 1..10 LOOP
        v_manv := 'NV3' || LPAD(i, 2, '0');        
        INSERT INTO N09_NHANSU (MANV, HOTEN, PHAI, NGSINH, PHUCAP, DT, VAITRO, MADV)
        VALUES (v_manv, 'Giáo Vụ ' || i, 
        CASE WHEN MOD(i, 2) = 0 THEN 'Nam' ELSE 'Nu' END, 
        TO_DATE('1995-01-01', 'YYYY-MM-DD'), 
        3000000 + 20000 * i, 
        '090912330' || MOD(i, 10), 
        'Giao vu', 
        'DV00' || (MOD(i, 7) + 1));
    END LOOP;
END;
/

----------------------------------------------------------------
-- Thêm dữ liệu cho vai trò "Nhân viên"
----------------------------------------------------------------
DECLARE
    v_manv CHAR(5);
BEGIN
    FOR i IN 1..10 LOOP
        v_manv := 'NV4' || LPAD(i, 2, '0');        
        INSERT INTO N09_NHANSU (MANV, HOTEN, PHAI, NGSINH, PHUCAP, DT, VAITRO, MADV)
        VALUES (v_manv, 'Nhân Viên ' || i, 
        CASE WHEN MOD(i, 2) = 0 THEN 'Nam' ELSE 'Nu' END, 
        TO_DATE('2000-01-01', 'YYYY-MM-DD'), 
        2000000 + 20000 * i, 
        '090912340' || MOD(i, 10), 
        'Nhan vien', 
        'DV00' || (MOD(i, 7) + 1));
    END LOOP;
END;
/

----------------------------------------------------------------
-- Chèn dữ liệu vào bảng N09_SINHVIEN
----------------------------------------------------------------
INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV001', 'Nguyen Thi Lan', 'Nu', TO_DATE('2000-01-01', 'YYYY-MM-DD'), '123 Le Loi', '0911234567', 'CQ', 'CNPM', 100, 8.5);
INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV002', 'Tran Van Minh', 'Nam', TO_DATE('2000-02-02', 'YYYY-MM-DD'), '456 Nguyen Hue', '0912345678', 'CQ', 'CNTT', 110, 7.8);
INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV003', 'Le Thi Hoa', 'Nu', TO_DATE('2000-03-03', 'YYYY-MM-DD'), '789 Tran Phu', '0913456789', 'CLC', 'KHMT', 120, 9.0);
INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV004', 'Pham Van Nam', 'Nam', TO_DATE('2000-04-04', 'YYYY-MM-DD'), '101 Le Thanh Ton', '0914567890', 'CTTT', 'TGMT', 95, 6.5);
INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV005', 'Hoang Thi Thu', 'Nu', TO_DATE('2000-05-05', 'YYYY-MM-DD'), '102 Tran Hung Dao', '0915678901', 'VP', 'MMT', 105, 7.2);
INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV006', 'Vu Van Lam', 'Nam', TO_DATE('2000-06-06', 'YYYY-MM-DD'), '103 Bach Dang', '0916789012', 'CQ', 'CNPM', 115, 8.0);
INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV007', 'Bui Thi Tuyet', 'Nu', TO_DATE('2000-07-07', 'YYYY-MM-DD'), '104 Ngo Gia Tu', '0917890123', 'CLC', 'CNTT', 110, 8.4);
INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV008', 'Do Van Hung', 'Nam', TO_DATE('2000-08-08', 'YYYY-MM-DD'), '105 Hai Ba Trung', '0918901234', 'CTTT', 'KHMT', 105, 6.9);
INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV009', 'Ngo Thi Lan', 'Nu', TO_DATE('2000-09-09', 'YYYY-MM-DD'), '106 Le Dai Hanh', '0919012345', 'VP', 'TGMT', 100, 7.5);
INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV010', 'Chu Van Tam', 'Nam', TO_DATE('2000-10-10', 'YYYY-MM-DD'), '107 Dien Bien Phu', '0910123456', 'CQ', 'MMT', 110, 8.1);
/

----------------------------------------------------------------
-- Chèn dữ liệu vào bảng N09_HOCPHAN
----------------------------------------------------------------
INSERT INTO N09_HOCPHAN (MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES ('HP001', 'Lap trinh C', 3, 30, 15, 50, 'DV001');
INSERT INTO N09_HOCPHAN (MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES ('HP002', 'Lap trinh Java', 4, 40, 20, 60, 'DV002');
INSERT INTO N09_HOCPHAN (MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES ('HP003', 'Cau truc du lieu', 3, 30, 15, 50, 'DV003');
INSERT INTO N09_HOCPHAN (MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES ('HP004', 'Co so du lieu', 3, 30, 15, 50, 'DV004');
INSERT INTO N09_HOCPHAN (MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES ('HP005', 'Mang may tinh', 4, 40, 20, 60, 'DV005');
INSERT INTO N09_HOCPHAN (MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES ('HP006', 'Tri tue nhan tao', 3, 30, 15, 50, 'DV006');
INSERT INTO N09_HOCPHAN (MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES ('HP007', 'Phan tich thiet ke HTTT', 4, 40, 20, 60, 'DV007');
INSERT INTO N09_HOCPHAN (MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES ('HP008', 'Khai thac du lieu', 3, 30, 15, 50, 'DV001');
INSERT INTO N09_HOCPHAN (MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES ('HP009', 'An toan thong tin', 3, 30, 15, 50, 'DV002');
INSERT INTO N09_HOCPHAN (MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES ('HP010', 'Lap trinh Python', 3, 30, 15, 50, 'DV003');
/

----------------------------------------------------------------
-- Chèn dữ liệu vào bảng N09_KHMO
----------------------------------------------------------------
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP001', 1, 2024, 'CQ');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP002', 2, 2024, 'CLC');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP003', 3, 2024, 'CTTT');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP004', 1, 2024, 'VP');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP005', 2, 2024, 'CQ');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP006', 3, 2024, 'CLC');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP007', 1, 2024, 'CTTT');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP008', 2, 2024, 'VP');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP009', 3, 2024, 'CQ');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP010', 1, 2024, 'CLC');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP001', 2, 2024, 'CLC');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP001', 2, 2024, 'CQ');
INSERT INTO N09_KHMO (MAHP, HK, NAM, MACT) VALUES ('HP002', 3, 2024, 'CLC');
/

----------------------------------------------------------------
-- Chèn dữ liệu vào bảng N09_PHANCONG
----------------------------------------------------------------
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV201', 'HP001', 1, 2024, 'CQ');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV202', 'HP002', 2, 2024, 'CLC');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV203', 'HP003', 3, 2024, 'CTTT');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV204', 'HP004', 1, 2024, 'VP');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV205', 'HP005', 2, 2024, 'CQ');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV206', 'HP006', 3, 2024, 'CLC');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV207', 'HP007', 1, 2024, 'CTTT');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV208', 'HP008', 2, 2024, 'VP');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV209', 'HP009', 3, 2024, 'CQ');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV210', 'HP010', 1, 2024, 'CLC');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV211', 'HP001', 2, 2024, 'CQ');
INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV212', 'HP002', 3, 2024, 'CLC');
/

----------------------------------------------------------------
-- Chèn dữ liệu vào bảng N09_DANGKY
----------------------------------------------------------------
INSERT INTO N09_DANGKY (MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) VALUES ('SV001', 'NV201', 'HP001', 1, 2024, 'CQ', 8.5, 7.0, 9.0, 8.0);
INSERT INTO N09_DANGKY (MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) VALUES ('SV002', 'NV202', 'HP002', 2, 2024, 'CLC', 7.8, 7.5, 8.0, 7.8);
INSERT INTO N09_DANGKY (MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) VALUES ('SV003', 'NV203', 'HP003', 3, 2024, 'CTTT', 9.0, 8.5, 9.5, 9.0);
INSERT INTO N09_DANGKY (MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) VALUES ('SV004', 'NV204', 'HP004', 1, 2024, 'VP', 6.5, 7.0, 7.0, 6.8);
INSERT INTO N09_DANGKY (MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) VALUES ('SV005', 'NV205', 'HP005', 2, 2024, 'CQ', 7.2, 7.0, 7.5, 7.2);
INSERT INTO N09_DANGKY (MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) VALUES ('SV006', 'NV206', 'HP006', 3, 2024, 'CLC', 8.0, 7.5, 8.5, 8.0);
INSERT INTO N09_DANGKY (MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) VALUES ('SV007', 'NV207', 'HP007', 1, 2024, 'CTTT', 8.4, 7.5, 8.5, 8.1);
INSERT INTO N09_DANGKY (MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) VALUES ('SV008', 'NV208', 'HP008', 2, 2024, 'VP', 6.9, 7.0, 7.5, 7.1);
INSERT INTO N09_DANGKY (MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) VALUES ('SV009', 'NV209', 'HP009', 3, 2024, 'CQ', 7.5, 7.0, 7.8, 7.4);
INSERT INTO N09_DANGKY (MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) VALUES ('SV010', 'NV210', 'HP010', 1, 2024, 'CLC', 8.1, 7.5, 8.5, 8.0);
/


