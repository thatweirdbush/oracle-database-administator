-- Lớp: CQ2021/1
-- Nhóm: 09
-- Thành viên:
-- 21120037 - Mã Thùy Anh
-- 21120060 - Nguyễn Long Giang
-- 21120082 - Phan Quốc Huy 
-- 21120117 - Lê Thị Hồng Phượng



/***************************************************************
Create a new pluggable database named PDB_N09

***************************************************************/
-- Set the current container to the root container
ALTER SESSION SET CONTAINER = CDB$ROOT;
SHOW CON_NAME;

-- Open PDB$SEED to for file name converting
ALTER PLUGGABLE DATABASE PDB$SEED OPEN READ ONLY;

-- Create a pluggable database named PDB_N09
CREATE PLUGGABLE DATABASE PDB_N09 
  ADMIN USER TESTPDB1 IDENTIFIED BY 123
    FILE_NAME_CONVERT = ('PDBSEED', 'PDB_N09');

-- Select all pluggable databases in current container with it's open mode
SELECT NAME, OPEN_MODE, INST_ID FROM GV$PDBS;

-- Open the pluggable database
ALTER PLUGGABLE DATABASE PDB_N09 OPEN;

-- Select all active services in the current container
SELECT NAME, CON_ID FROM V$ACTIVE_SERVICES ORDER BY 1;

-- Set the current container to the pluggable database PDB_N09
SHOW CON_NAME;
ALTER SESSION SET CONTAINER = PDB_N09;

---- Drop the pluggable database PDB_N09 (Uncomment this to drop the PDB)
--ALTER SESSION SET CONTAINER=CDB$ROOT;
--ALTER PLUGGABLE DATABASE PDB_N09 CLOSE;
--DROP PLUGGABLE DATABASE PDB_N09 INCLUDING DATAFILES;
--SELECT NAME, OPEN_MODE, INST_ID FROM GV$PDBS;
--/

----------------------------------------------------------------
-- Tạo User ADMIN với quyền hạn gần tương đương SYS
----------------------------------------------------------------
-- Xóa user ADMIN trước khi tạo mới lại
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
DROP USER N09_ADMIN CASCADE;
/

-- Tạo user ADMIN:
-- B1. Tạo Common User N09_ADMIN (Password=123) trong CDB$ROOT
CREATE USER N09_ADMIN IDENTIFIED BY 123;
/

-- B2. Cấp quyền DBA CHO N09_ADMIN
GRANT DBA TO N09_ADMIN; 
/

-- B3. Cấp các quyền cao cấp trên toàn bộ CONTAINER
GRANT CREATE SESSION TO N09_ADMIN; 
GRANT ALTER SESSION TO N09_ADMIN;
GRANT EXECUTE ANY PROCEDURE TO N09_ADMIN;
GRANT CONNECT TO N09_ADMIN WITH ADMIN OPTION;
GRANT CREATE USER TO N09_ADMIN;
GRANT CREATE ANY PROCEDURE TO N09_ADMIN;
GRANT GRANT ANY ROLE TO N09_ADMIN;
GRANT DROP USER TO N09_ADMIN;
GRANT SELECT_CATALOG_ROLE TO N09_ADMIN;
GRANT SELECT ANY DICTIONARY TO N09_ADMIN;
--ALTER USER N09_ADMIN QUOTA UNLIMITED ON USERS;
/

-- CONNECT vào N09_ADMIN để tạo CSDL trên Schema N09_ADMIN 
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
/

----------------------------------------------------------------
-- Tạo CSDL cho đồ án
----------------------------------------------------------------
-- Xóa các bảng và user trước khi chạy script
DROP TABLE N09_NHANSU CASCADE CONSTRAINTS;
DROP TABLE N09_SINHVIEN CASCADE CONSTRAINTS;
DROP TABLE N09_DONVI CASCADE CONSTRAINTS;
DROP TABLE N09_HOCPHAN CASCADE CONSTRAINTS;
DROP TABLE N09_KHMO CASCADE CONSTRAINTS;
DROP TABLE N09_PHANCONG CASCADE CONSTRAINTS;
DROP TABLE N09_DANGKY CASCADE CONSTRAINTS;
DROP TABLE N09_THONGBAO CASCADE CONSTRAINTS;
/

-- Tạo CSDL
CREATE TABLE N09_NHANSU
(
    MANV CHAR(5),
    HOTEN NVARCHAR2(100),
    PHAI NVARCHAR2(3),
    NGSINH DATE,
    PHUCAP NUMBER(10),
    DT CHAR(10),
    VAITRO NVARCHAR2(30),
    MADV CHAR(5),
    COSO NVARCHAR2(30),
    
    PRIMARY KEY(MANV)
);

CREATE TABLE N09_SINHVIEN
(
    MASV CHAR(5),
    HOTEN NVARCHAR2(100),
    PHAI NVARCHAR2(3),
    NGSINH DATE,
    DIACHI NVARCHAR2(100),
    DT CHAR(10),
    MACT NVARCHAR2(30),
    MANGANH NVARCHAR2(30),
    SOTCTL NUMBER(4),
    DTBTL NUMBER(4,2),
    COSO NVARCHAR2(30),
    
    PRIMARY KEY(MASV)
);

CREATE TABLE N09_DONVI
(
    MADV CHAR(5),
    TENDV NVARCHAR2(100),
    TRGDV CHAR(5),
    
    PRIMARY KEY(MADV)
);

CREATE TABLE N09_HOCPHAN
(
    MAHP CHAR(5),
    TENHP NVARCHAR2(100),
    SOTC NUMBER(2),
    STLT NUMBER(4),
    STTH NUMBER(4),
    SOSVTD NUMBER(4),
    MADV CHAR(5),
    
    PRIMARY KEY(MAHP)
);

CREATE TABLE N09_KHMO
(
    MAHP CHAR(5),
    HK NUMBER(1),
    NAM NUMBER(4),
    MACT VARCHAR(4),
    
    PRIMARY KEY(MAHP, HK, NAM, MACT)
);

CREATE TABLE N09_PHANCONG
(
    MAGV CHAR(5),
    MAHP CHAR(5),
    HK NUMBER(1),
    NAM NUMBER(4),
    MACT VARCHAR(4),
    
    PRIMARY KEY(MAGV, MAHP, HK, NAM, MACT)
);

CREATE TABLE N09_DANGKY
(
    MASV CHAR(5),
    MAGV CHAR(5),
    MAHP CHAR(5),
    HK NUMBER(1),
    NAM NUMBER(4),
    MACT VARCHAR(4),
    DIEMTH NUMBER(4,2),
    DIEMQT NUMBER(4,2),
    DIEMCK NUMBER(4,2),
    DIEMTK NUMBER(4,2),
    
    PRIMARY KEY(MASV, MAGV, MAHP, HK, NAM, MACT)
);

CREATE TABLE N09_THONGBAO
(
    MATB CHAR(5),
    TENTB NVARCHAR2(100),
    NGAYGUI DATE,
    NGUOINHAN NVARCHAR2(100),
    LINHVUC CHAR(4),
    COSO NVARCHAR2(30),
    NOIDUNG NVARCHAR2(1000),
    
    PRIMARY KEY(MATB)
);

-- Thiết lập các khóa ngoại
ALTER TABLE N09_NHANSU
ADD
    FOREIGN KEY (MADV)
    REFERENCES N09_DONVI(MADV);

ALTER TABLE N09_HOCPHAN
ADD
    FOREIGN KEY (MADV)
    REFERENCES N09_DONVI(MADV);
    
ALTER TABLE N09_KHMO
ADD
    FOREIGN KEY (MAHP)
    REFERENCES N09_HOCPHAN(MAHP);

ALTER TABLE N09_PHANCONG
ADD
    FOREIGN KEY (MAGV)
    REFERENCES N09_NHANSU(MANV);

ALTER TABLE N09_PHANCONG
ADD
    FOREIGN KEY (MAHP, HK, NAM, MACT)
    REFERENCES N09_KHMO(MAHP, HK, NAM, MACT);

ALTER TABLE N09_DANGKY
ADD
    FOREIGN KEY (MAGV, MAHP, HK, NAM, MACT)
    REFERENCES N09_PHANCONG(MAGV, MAHP, HK, NAM, MACT);
/