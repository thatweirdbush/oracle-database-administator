-- Lớp: CQ2021/1
-- Nhóm: 09
-- Thành viên:
-- 21120037 - Mã Thùy Anh
-- 21120060 - Nguyễn Long Giang
-- 21120082 - Phan Quốc Huy 
-- 21120117 - Lê Thị Hồng Phượng



-- CONNECT vào C##ADMIN để tạo CSDL trên Schema C##ADMIN 
CONN C##ADMIN/123;
----------------------------------------------------------------
-- Script tạo các Role trong Database
------------------------------------------------------------------ 
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

-- Xóa các Role trước khi chạy script
DROP ROLE N09_RL_NHANVIEN;
DROP ROLE N09_RL_GIANGVIEN;
DROP ROLE N09_RL_GIAOVU;
DROP ROLE N09_RL_TRUONG_DONVI;
DROP ROLE N09_RL_TRUONG_KHOA;
DROP ROLE N09_RL_SINHVIEN;
/
-- Tạo Role
CREATE ROLE N09_RL_NHANVIEN;
CREATE ROLE N09_RL_GIANGVIEN;
CREATE ROLE N09_RL_GIAOVU;
CREATE ROLE N09_RL_TRUONG_DONVI;
CREATE ROLE N09_RL_TRUONG_KHOA;
CREATE ROLE N09_RL_SINHVIEN;
/

----------------------------------------------------------------
-- Script tạo View cho tất cả Table trong Database
----------------------------------------------------------------
-- Xóa các View trước khi chạy script
DROP VIEW UV_N09_NHANSU;
DROP VIEW UV_N09_SINHVIEN;
DROP VIEW UV_N09_DONVI;
DROP VIEW UV_N09_HOCPHAN;
DROP VIEW UV_N09_KHMO;
DROP VIEW UV_N09_PHANCONG;
DROP VIEW UV_N09_DANGKY;
/

-- Tạo View
CREATE OR REPLACE VIEW UV_N09_NHANSU AS
SELECT 
    MANV AS "Mã Nhân Viên",
    HOTEN AS "Họ Tên",
    PHAI AS "Phái",
    NGSINH AS "Ngày Sinh",
    PHUCAP AS "Phụ Cấp",
    DT AS "Điện Thoại",
    VAITRO AS "Vai Trò",
    MADV AS "Mã Đơn Vị",
    COSO AS "Cơ Sở"
FROM N09_NHANSU;
/

CREATE OR REPLACE VIEW UV_N09_SINHVIEN AS
SELECT 
    MASV AS "Mã Sinh Viên",
    HOTEN AS "Họ Tên",
    PHAI AS "Phái",
    NGSINH AS "Ngày Sinh",
    DIACHI AS "Địa Chỉ",
    DT AS "Điện Thoại",
    MACT AS "Mã Chương Trình",
    MANGANH AS "Mã Ngành",
    SOTCTL AS "Số Tín Chỉ",
    DTBTL AS "Điểm TB",
    COSO AS "Cơ Sở"
FROM N09_SINHVIEN;
/

CREATE OR REPLACE VIEW UV_N09_DONVI AS
SELECT 
    MADV AS "Mã Đơn Vị",
    TENDV AS "Tên Đơn Vị",
    TRGDV AS "Trưởng Đơn Vị"
FROM N09_DONVI;
/

CREATE OR REPLACE VIEW UV_N09_HOCPHAN AS
SELECT 
    MAHP AS "Mã Học Phần",
    TENHP AS "Tên Học Phần",
    SOTC AS "Số Tín Chỉ",
    STLT AS "Số Tiết LT",
    STTH AS "Số Tiết TH",
    SOSVTD AS "Số SV Tối Đa",
    MADV AS "Mã Đơn Vị"
FROM N09_HOCPHAN;
/

CREATE OR REPLACE VIEW UV_N09_KHMO AS
SELECT 
    MAHP AS "Mã Học Phần",
    HK AS "Học Kỳ",
    NAM AS "Năm",
    MACT AS "Mã Chương Trình"
FROM N09_KHMO;
/

CREATE OR REPLACE VIEW UV_N09_PHANCONG AS
SELECT 
    MAGV AS "Mã Giảng Viên",
    MAHP AS "Mã Học Phần",
    HK AS "Học Kỳ",
    NAM AS "Năm",
    MACT AS "Mã Chương Trình"
FROM N09_PHANCONG;
/

CREATE OR REPLACE VIEW UV_N09_DANGKY AS
SELECT 
    MASV AS "Mã Sinh Viên",
    MAGV AS "Mã Giảng Viên",
    MAHP AS "Mã Học Phần",
    HK AS "Học Kỳ",
    NAM AS "Năm",
    MACT AS "Mã Chương Trình",
    DIEMTH AS "Điểm Thi",
    DIEMQT AS "Điểm Quá Trình",
    DIEMCK AS "Điểm Cuối Kỳ",
    DIEMTK AS "Điểm Tổng Kết"
FROM N09_DANGKY;
/



-----------------------------------------------------------------
-- Stored Procedure tạo user cho tất cả nhân sự
-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_CREATE_USER_NHANSU
AS 
    CURSOR CUR IS (SELECT MANV
                    FROM N09_NHANSU
                    WHERE MANV NOT IN (SELECT USERNAME FROM ALL_USERS)); 
     STRSQL VARCHAR(2000); 
     USR VARCHAR2(5); 
BEGIN 
     OPEN CUR; 
     STRSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE'; 
     EXECUTE IMMEDIATE(STRSQL); 
     LOOP 
         FETCH CUR INTO USR; 
         EXIT WHEN CUR%NOTFOUND; 
         
         STRSQL := 'CREATE USER '|| USR ||' IDENTIFIED BY '|| USR; 
         EXECUTE IMMEDIATE(STRSQL); 
         STRSQL := 'GRANT CONNECT TO ' || USR; 
         EXECUTE IMMEDIATE(STRSQL); 
     END LOOP; 
     STRSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE'; 
     EXECUTE IMMEDIATE(STRSQL); 
     CLOSE CUR; 
END; 
/



-----------------------------------------------------------------
-- Stored Procedure tạo user cho tất cả sinh viên
-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_CREATE_USER_SINHVIEN
AS 
    CURSOR CUR IS (SELECT MASV
                    FROM N09_SINHVIEN
                    WHERE MASV NOT IN (SELECT USERNAME FROM ALL_USERS)); 
     STRSQL VARCHAR(2000); 
     USR VARCHAR2(5); 
BEGIN 
     OPEN CUR; 
     STRSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE'; 
     EXECUTE IMMEDIATE(STRSQL); 
     LOOP 
         FETCH CUR INTO USR; 
         EXIT WHEN CUR%NOTFOUND; 
         
         STRSQL := 'CREATE USER '|| USR ||' IDENTIFIED BY '|| USR; 
         EXECUTE IMMEDIATE(STRSQL); 
         STRSQL := 'GRANT CONNECT TO ' || USR; 
         EXECUTE IMMEDIATE(STRSQL); 
     END LOOP; 
     STRSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE'; 
     EXECUTE IMMEDIATE(STRSQL); 
     CLOSE CUR; 
END;
/



-----------------------------------------------------------------
-- Stored Procedure xóa user cho tất cả nhân sự
-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_DROP_USER_NHANSU
AS 
    CURSOR CUR IS (SELECT USERNAME
                    FROM ALL_USERS
                    WHERE USERNAME IN (SELECT MANV FROM N09_NHANSU)); 
     STRSQL VARCHAR(2000); 
     USR VARCHAR2(5);
BEGIN
    OPEN CUR; 
    STRSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE'; 
    EXECUTE IMMEDIATE(STRSQL); 
    LOOP 
        FETCH CUR INTO USR; 
        EXIT WHEN CUR%NOTFOUND; 
        
        STRSQL := 'DROP USER '|| USR || ' CASCADE'; 
        EXECUTE IMMEDIATE(STRSQL); 
    END LOOP; 
    STRSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE'; 
    EXECUTE IMMEDIATE(STRSQL); 
    CLOSE CUR; 
END;
/



-----------------------------------------------------------------
-- Stored Procedure xóa user cho tất cả sinh viên
-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_DROP_USER_SINHVIEN
AS 
    CURSOR CUR IS (SELECT USERNAME
                    FROM ALL_USERS
                    WHERE USERNAME IN (SELECT MASV FROM N09_SINHVIEN)); 
     STRSQL VARCHAR(2000); 
     USR VARCHAR2(5);
BEGIN
    OPEN CUR; 
    STRSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE'; 
    EXECUTE IMMEDIATE(STRSQL); 
    LOOP 
        FETCH CUR INTO USR; 
        EXIT WHEN CUR%NOTFOUND; 
        
        STRSQL := 'DROP USER '|| USR || ' CASCADE'; 
        EXECUTE IMMEDIATE(STRSQL); 
    END LOOP; 
    STRSQL := 'ALTER SESSION SET "_ORACLE_SCRIPT" = FALSE'; 
    EXECUTE IMMEDIATE(STRSQL); 
    CLOSE CUR; 
END;
/



-----------------------------------------------------------------
-- Stored Procedure gán Role cho tất cả nhân sự
-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_GRANT_ROLE_NHANSU(
    ROLENAME IN VARCHAR2,
    STR_VAITRO IN VARCHAR2) 
IS 
     CURSOR CUR IS (SELECT MANV
                     FROM N09_NHANSU
                     WHERE MANV IN (SELECT USERNAME FROM ALL_USERS) AND VAITRO = STR_VAITRO
                    ); 
     STRSQL VARCHAR(2000); 
     USR VARCHAR2(5); 
BEGIN 
     OPEN CUR; 
     LOOP 
         FETCH CUR INTO USR; 
         EXIT WHEN CUR%NOTFOUND; 
         
         STRSQL := 'GRANT '|| ROLENAME ||' TO '|| USR; 
         EXECUTE IMMEDIATE (STRSQL); 
     END LOOP; 
     CLOSE CUR; 
END; 
/



-----------------------------------------------------------------
-- Stored Procedure gán Role cho tất cả sinh viên
-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_GRANT_ROLE_SINHVIEN(
    ROLENAME IN VARCHAR2) 
IS 
     CURSOR CUR IS (SELECT MASV
                     FROM N09_SINHVIEN
                     WHERE MASV IN (SELECT USERNAME FROM ALL_USERS)
                    ); 
     STRSQL VARCHAR(2000); 
     USR VARCHAR2(5); 
BEGIN 
     OPEN CUR; 
     LOOP 
         FETCH CUR INTO USR; 
         EXIT WHEN CUR%NOTFOUND; 
         
         STRSQL := 'GRANT '|| ROLENAME ||' TO '|| USR; 
         EXECUTE IMMEDIATE (STRSQL); 
     END LOOP; 
     CLOSE CUR; 
END; 
/



-----------------------------------------------------------------
-- Thực thi các Stored Procedure cần thiết 
-----------------------------------------------------------------
-- Thực thi Stored Procedure xóa user cho tất cả nhân sự trước khi tạo user Nhân sự mới
EXEC N09_DROP_USER_NHANSU;
/
-- Thực thi Stored Procedure xóa user cho tất cả sinh viên trước khi tạo user Sinh viên mới
EXEC N09_DROP_USER_SINHVIEN;
/
-- Thực thi Stored Procedure tạo user cho tất cả nhân sự
EXEC N09_CREATE_USER_NHANSU;
/
-- Thực thi Stored Procedure tạo user cho tất cả sinh viên
EXEC N09_CREATE_USER_SINHVIEN;
/
-- Thực thi Stored Procedure gán Role cho tất cả Nhân viên
EXEC N09_GRANT_ROLE_NHANSU('N09_RL_NHANVIEN', 'Nhân viên');
/
-- Thực thi Stored Procedure gán Role cho tất cả Giảng viên
EXEC N09_GRANT_ROLE_NHANSU('N09_RL_GIANGVIEN', 'Giảng viên');
/
-- Thực thi Stored Procedure gán Role cho tất cả Giáo vụ
EXEC N09_GRANT_ROLE_NHANSU('N09_RL_GIAOVU', 'Giáo vụ');
/
-- Thực thi Stored Procedure gán Role cho tất cả Trưởng đơn vị
EXEC N09_GRANT_ROLE_NHANSU('N09_RL_TRUONG_DONVI', 'Trưởng đơn vị');
/
-- Thực thi Stored Procedure gán Role cho tất cả Trưởng khoa
EXEC N09_GRANT_ROLE_NHANSU('N09_RL_TRUONG_KHOA', 'Trưởng khoa');
/
-- Thực thi Stored Procedure gán Role cho tất cả sinh viên
EXEC N09_GRANT_ROLE_SINHVIEN('N09_RL_SINHVIEN');
/



----------------------------------------------------------------
-- Stored Procedure lấy thông tin User hiện tại
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_GET_CURRENT_USER(
    OUTPUT OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN OUTPUT FOR SELECT USER FROM DUAL;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_GET_CURRENT_USER TO PUBLIC;
/


----------------------------------------------------------------
-- Stored Procedure SELECT bất kỳ Table nào
-- Tham số truyền vào: Tên Table
-- Tham số optional: Điều kiện WHERE
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_SELECT_ANY_TABLE(
    OUTPUT OUT SYS_REFCURSOR,
    STR_TABLE_NAME IN VARCHAR2,
    STR_CONDITION IN VARCHAR2 DEFAULT NULL)
AS
BEGIN
    IF STR_CONDITION IS NULL THEN
        OPEN OUTPUT FOR 'SELECT * FROM ' || STR_TABLE_NAME;
    ELSE
        OPEN OUTPUT FOR 'SELECT * FROM ' || STR_TABLE_NAME || ' WHERE ' || STR_CONDITION;
    END IF;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_SELECT_ANY_TABLE TO PUBLIC;
/

-- -- Test
--  -- SELECT tất cả các dòng của Table N09_NHANVIEN
--  CONN HUYP/123
--  VARIABLE rc REFCURSOR;
--      EXECUTE SYS.N09_SELECT_ANY_TABLE(:rc, 'N09_BAOCAO');
--  PRINT rc;
-- /

-- -- Không SELECT được dòng nào trong Table N09_NHANVIEN
-- VARIABLE rc REFCURSOR;
--     EXECUTE SYS.N09_SELECT_ANY_TABLE(:rc, 'N09_NHANVIEN', '1=0');
-- PRINT rc;
-- /



-- -- Test
--  -- SELECT tất cả các dòng của Table N09_NHANVIEN
--  CONN NV201/NV201
--  VARIABLE rc REFCURSOR;
--      EXECUTE C##ADMIN.N09_SELECT_ANY_TABLE(:rc, 'C##ADMIN.UV_N09_DONVI');
--  PRINT rc;
--/



----------------------------------------------------------------
-- Stored Procedure SELECT chỉ trả về 1 dòng của Table
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_GET_SINGLE_LINE_DATA(
    OUTPUT OUT SYS_REFCURSOR,
    STR_TABLE_NAME IN VARCHAR2,
    STR_CONDITION IN VARCHAR2 DEFAULT NULL)
AS
BEGIN
    IF STR_CONDITION IS NULL THEN
        OPEN OUTPUT FOR 'SELECT * FROM ' || STR_TABLE_NAME || ' WHERE ROWNUM = 1';
    ELSE
        OPEN OUTPUT FOR 'SELECT * FROM ' || STR_TABLE_NAME || ' WHERE ' || STR_CONDITION || ' AND ROWNUM = 1';
    END IF;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_GET_SINGLE_LINE_DATA TO PUBLIC;
/

-- -- Test
--CONN NV201/NV201;
--VARIABLE rc REFCURSOR;
--     EXECUTE C##ADMIN.N09_GET_SINGLE_LINE_DATA(:rc, 'C##ADMIN.UV_N09_NHANSU_VIEWBY_GIANGVIEN');
--PRINT rc;
-- SELECT * FROM C##ADMIN.UV_N09_NHANSU_VIEWBY_GIANGVIEN
--/
 
 

----------------------------------------------------------------
-- Stored Procedure SELECT tất cả các Roles
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_SELECT_DBA_ROLES(
    OUTPUT OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN OUTPUT FOR SELECT ROLE, ROLE_ID FROM SYS.DBA_ROLES;
END;
/

-- -- Test
-- VARIABLE rc REFCURSOR;
-- EXECUTE N09_SELECT_DBA_ROLES(:rc);
-- PRINT rc;
-- /



----------------------------------------------------------------
-- Stored Procedure SELECT tất cả các Privillege của Roles
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_SELECT_DBA_ROLE_PRIVS(
    OUTPUT OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN OUTPUT FOR SELECT * FROM SYS.DBA_ROLE_PRIVS;
END;
/

-- -- Test
-- VARIABLE rc REFCURSOR;
-- EXECUTE N09_SELECT_DBA_ROLE_PRIVS(:rc);
-- PRINT rc;
-- /



----------------------------------------------------------------
-- Stored Procedure SELECT tất cả các Users
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_SELECT_ALL_USERS(
    OUTPUT OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN OUTPUT FOR SELECT * FROM SYS.ALL_USERS;
END;
/



----------------------------------------------------------------
-- Stored Procedure SELECT tất cả các Privillege của Roles tính đến cột
-- Tham số truyền vào: Tên User hoặc Role
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_SELECT_USER_OR_ROLE_PRIVS(
    OUTPUT OUT SYS_REFCURSOR,
    USER_OR_ROLE_NAME IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR SELECT GRANTOR, GRANTEE, TABLE_SCHEMA, TABLE_NAME,
                        NULL AS COLUMN_NAME, PRIVILEGE, GRANTABLE, HIERARCHY, COMMON, TYPE, INHERITED 
                    FROM ALL_TAB_PRIVS 
                    WHERE GRANTEE = USER_OR_ROLE_NAME 
                    UNION ALL
                    SELECT GRANTOR, GRANTEE, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, PRIVILEGE, GRANTABLE,
                        NULL AS HIERARCHY, COMMON, NULL AS TYPE, INHERITED 
                    FROM ALL_COL_PRIVS
                    WHERE GRANTEE =  USER_OR_ROLE_NAME;
END;
/

-- -- Test
-- VARIABLE rc REFCURSOR;
-- EXECUTE N09_SELECT_USER_OR_ROLE_PRIVS(:rc, 'HUYP');
-- PRINT rc;
-- /



----------------------------------------------------------------
-- Stored Procedure SELECT tất cả các Privillege của Roles tính đến cột (bản rút gọn)
-- Tham số truyền vào: Tên User hoặc Role
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_SELECT_USER_OR_ROLE_PRIVS_SIMPLIFY(
    OUTPUT OUT SYS_REFCURSOR,
    USER_OR_ROLE_NAME IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR SELECT TABLE_NAME, NULL AS COLUMN_NAME, PRIVILEGE, GRANTABLE
                    FROM SYS.ALL_TAB_PRIVS 
                    WHERE GRANTEE = USER_OR_ROLE_NAME 
                    UNION ALL
                    SELECT TABLE_NAME, COLUMN_NAME, PRIVILEGE, GRANTABLE
                    FROM SYS.ALL_COL_PRIVS 
                    WHERE GRANTEE = USER_OR_ROLE_NAME;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_SELECT_USER_OR_ROLE_PRIVS_SIMPLIFY TO PUBLIC;
/

-- -- Test
-- VARIABLE rc REFCURSOR;
-- EXECUTE N09_SELECT_USER_OR_ROLE_PRIVS_SIMPLIFY(:rc, 'KH1');
-- PRINT rc;
-- /



----------------------------------------------------------------
-- Stored Procedure SELECT tất cả các Tables
-- Tham số truyền vào: Chuỗi con của tên Table
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_SELECT_DBA_TABLES(
    OUTPUT OUT SYS_REFCURSOR,
    SUBSTR IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR SELECT TABLE_NAME FROM DBA_TABLES WHERE TABLE_NAME LIKE '%' || SUBSTR || '%';
END;
/

-- -- Test
-- VARIABLE rc REFCURSOR;
--     EXECUTE SYS.N09_SELECT_DBA_TABLES(:rc, 'N09_');
-- PRINT rc;
-- /



----------------------------------------------------------------
-- Stored Procedure SELECT tất cả các cột của Table
-- Tham số truyền vào: Tên Table
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_SELECT_TAB_COLUMNS(
    OUTPUT OUT SYS_REFCURSOR,
    STR_TABLE_NAME IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME = STR_TABLE_NAME;
END;
/

-- -- Test
-- VARIABLE rc REFCURSOR;
--     EXECUTE SYS.N09_SELECT_TAB_COLUMNS(:rc, 'N09_NHANVIEN');
-- PRINT rc;
-- /



----------------------------------------------------------------
-- Stored Procedure tạo User
-- Tham số truyền vào: Tên User, Mật khẩu
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_CREATE_USER(
    USRNAME IN VARCHAR2,
    PASSWRD IN VARCHAR2)
IS
BEGIN
    IF LENGTH(USRNAME) = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid username.');
    END IF;

    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE';
    EXECUTE IMMEDIATE 'CREATE USER ' || USRNAME || ' IDENTIFIED BY ' || PASSWRD;
    EXECUTE IMMEDIATE 'GRANT CONNECT TO "' || USRNAME || '"';
END;
/



----------------------------------------------------------------
-- Stored Procedure tạo Role
-- Tham số truyền vào: Tên Role
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_CREATE_ROLE(
    ROLENAME IN VARCHAR2)
IS
BEGIN
    IF LENGTH(ROLENAME) = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid role name.');
    END IF;

    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE';
    EXECUTE IMMEDIATE 'CREATE ROLE ' || ROLENAME;
END;
/



----------------------------------------------------------------
-- Stored Procedure xóa User
-- Tham số truyền vào: Tên User
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_DROP_USER(
    USERNAME IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE';
    EXECUTE IMMEDIATE 'DROP USER ' || USERNAME;
END;
/


----------------------------------------------------------------
-- Stored Procedure xóa Role
-- Tham số truyền vào: Tên Role
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_DROP_ROLE(
    ROLENAME IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE';
    EXECUTE IMMEDIATE 'DROP ROLE ' || ROLENAME;
END;
/


----------------------------------------------------------------
-- Stored Procedure gán quyền cho User hoặc Role
-- Tham số truyền vào: Tên quyền, Tên User hoặc Role
-- Tham số optional: Quyền WITH GRANT OPTION, Tên Table hoặc View, Tên cột
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_GRANT_PRIVILEGE
(PRIVILEGE IN VARCHAR2, USER_OR_ROLE IN VARCHAR2, WITH_GRANT_OPTION IN VARCHAR2 DEFAULT NULL,
TABLE_OR_VIEW IN VARCHAR2 DEFAULT NULL, COLUMNS_CSV IN VARCHAR2 DEFAULT NULL)
AS
    STRCOL VARCHAR2(100); 
BEGIN
    IF TABLE_OR_VIEW IS NULL THEN
        EXECUTE IMMEDIATE 'GRANT ' || PRIVILEGE || ' TO ' || USER_OR_ROLE || WITH_GRANT_OPTION;
    ELSE
        IF COLUMNS_CSV IS NOT NULL THEN
            STRCOL := ' (' || COLUMNS_CSV || ')';
        END IF;
        EXECUTE IMMEDIATE 'GRANT ' || PRIVILEGE || STRCOL || ' ON ' || TABLE_OR_VIEW || ' TO ' || USER_OR_ROLE || WITH_GRANT_OPTION;
    END IF;
END;
/


----------------------------------------------------------------
-- Stored Procedure thu hồi quyền từ User hoặc Role
-- Tham số truyền vào: Tên quyền, Tên User hoặc Role
-- Tham số optional: Tên Table hoặc View, Tên cột
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_REVOKE_PRIVILEGE
(PRIVILEGE IN VARCHAR2, USER_OR_ROLE IN VARCHAR2, 
TABLE_OR_VIEW IN VARCHAR2 DEFAULT NULL,
COLUMNS_CSV IN VARCHAR2 DEFAULT NULL)
AS
    STRCOL VARCHAR2(100); 
BEGIN
    IF TABLE_OR_VIEW IS NULL THEN
        EXECUTE IMMEDIATE 'REVOKE ' || PRIVILEGE || ' FROM ' || USER_OR_ROLE;
    ELSE
        IF COLUMNS_CSV IS NOT NULL THEN
            STRCOL := ' (' || COLUMNS_CSV || ')';
        END IF;
        EXECUTE IMMEDIATE 'REVOKE ' || PRIVILEGE || STRCOL || ' ON ' || TABLE_OR_VIEW || ' FROM ' || USER_OR_ROLE;
    END IF;
END;
/


/***************************************************************
* Phân Hệ 2
****************************************************************/
----------------------------------------------------------------
-- Stored Procedure UPDATE bảng N09_NHANSU
-- Tham số truyền vào: Tên cột cần UPDATE, Giá trị cần UPDATE, Mã nhân sự cần UPDATE
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_NHANSU
(STR_COLUMN IN VARCHAR2, STR_VALUE IN VARCHAR2, STR_ID IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_NHANSU SET ' || STR_COLUMN || ' = ''' || STR_VALUE || ''' WHERE MANV = ''' || STR_ID || '''';
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_NHANSU TO PUBLIC;
/


----------------------------------------------------------------
-- Stored Procedure UPDATE bảng N09_SINHVIEN
-- Tham số truyền vào: Tên cột cần UPDATE, Giá trị cần UPDATE, Mã nhân sự cần UPDATE
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_SINHVIEN
(STR_COLUMN IN VARCHAR2, STR_VALUE IN VARCHAR2, STR_ID IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_SINHVIEN SET ' || STR_COLUMN || ' = ''' || STR_VALUE || ''' WHERE MASV = ''' || STR_ID || '''';
END;
/
    
-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_SINHVIEN TO PUBLIC;
/
    
        
----------------------------------------------------------------
-- Stored Procedure SELECT bảng N09_DANGKY kết hợp với N09_PHANCONG bởi Giảng viên
-- Tham số truyền vào: Tất cả các cột của bảng N09_PHANCONG (Mã Giảng Viên, Mã Học Phần, Học Kỳ, Năm, Mã Chương Trình)
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_DANGKY_JOIN_PHANCONG_BY_GIANGVIEN(
    OUTPUT OUT SYS_REFCURSOR,
    STR_MAGV IN VARCHAR2,
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2)
IS
    sql_query VARCHAR2(1000);
BEGIN
    sql_query := 'SELECT D."Mã Sinh Viên", D."Mã Giảng Viên", D."Mã Học Phần", D."Học Kỳ", D."Năm", D."Mã Chương Trình",
        D."Điểm Thi", D."Điểm Quá Trình", D."Điểm Cuối Kỳ", D."Điểm Tổng Kết" 
        FROM C##ADMIN.UV_N09_DANGKY_VIEWBY_GIANGVIEN D, C##ADMIN.UV_N09_PHANCONG_VIEWBY_GIANGVIEN P 
        WHERE D."Mã Giảng Viên" = :1 AND D."Mã Học Phần" = :2 
        AND D."Học Kỳ" = :3 AND D."Năm" = :4 AND D."Mã Chương Trình" = :5
        AND D."Mã Giảng Viên" = P."Mã Giảng Viên" AND D."Mã Học Phần" = P."Mã Học Phần" 
        AND D."Học Kỳ" = P."Học Kỳ" AND D."Năm" = P."Năm" AND D."Mã Chương Trình" = P."Mã Chương Trình"';

    OPEN OUTPUT FOR sql_query USING STR_MAGV, STR_MAHP, STR_HK, STR_NAM, STR_MACT;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_DANGKY_JOIN_PHANCONG_BY_GIANGVIEN TO N09_RL_GIANGVIEN;
/
    
---- Test
--CONN NV201/NV201;
--VARIABLE rc REFCURSOR;
--EXECUTE C##ADMIN.N09_DANGKY_JOIN_PHANCONG_BY_GIANGVIEN(:rc, 'NV201', 'HP001', 1, 2024, 'CQ');
--PRINT rc;
--/   
    

    
----------------------------------------------------------------
-- Stored Procedure SELECT USER ROLE của User hiện tại
-- Tham số truyền vào: Không
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_GET_CURRENT_USER_ROLE(
    OUTPUT OUT SYS_REFCURSOR)
AS
    l_sql_stmt VARCHAR2(1000);
BEGIN
    l_sql_stmt := 'SELECT GRANTED_ROLE FROM DBA_ROLE_PRIVS WHERE GRANTEE = SYS_CONTEXT(''USERENV'', ''SESSION_USER'') AND GRANTED_ROLE LIKE ''%N09_%''';
    OPEN OUTPUT FOR l_sql_stmt;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_GET_CURRENT_USER_ROLE TO PUBLIC;
/

---- Test
--CONN NV201/NV201;
--VARIABLE rc REFCURSOR;
--EXECUTE C##ADMIN.N09_GET_CURRENT_USER_ROLE(:rc);
--PRINT rc;
--/   




















    