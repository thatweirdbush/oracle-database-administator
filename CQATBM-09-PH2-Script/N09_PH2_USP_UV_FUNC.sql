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
    DIEMTH AS "Điểm Thực Hành",
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
--  -- SELECT tất cả các dòng của Table UV_N09_DONVI
--  CONN NV201/NV201
--  VARIABLE rc REFCURSOR;
--      EXECUTE C##ADMIN.N09_SELECT_ANY_TABLE(:rc, 'C##ADMIN.UV_N09_DONVI');
--  PRINT rc;
--/

-- -- Không SELECT được dòng nào trong Table N09_NHANVIEN
--  CONN NV201/NV201
--  VARIABLE rc REFCURSOR;
--      EXECUTE C##ADMIN.N09_SELECT_ANY_TABLE(:rc, 'C##ADMIN.UV_N09_DONVI', '1=0');
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
-- Stored Procedure UPDATE 1 cột trên bảng N09_NHANSU
-- Tham số truyền vào: Tên cột cần UPDATE, Giá trị cần UPDATE, Mã nhân sự cần UPDATE
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_SINGLE_COL_NHANSU
(STR_COLUMN IN VARCHAR2, STR_VALUE IN VARCHAR2, STR_ID IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_NHANSU SET ' || STR_COLUMN || ' = ''' || STR_VALUE || ''' WHERE MANV = ''' || STR_ID || '''';
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_SINGLE_COL_NHANSU TO PUBLIC;
/

    
        
----------------------------------------------------------------
-- Stored Procedure UPDATE 1 cột trên bảng N09_SINHVIEN
-- Tham số truyền vào: Tên cột cần UPDATE, Giá trị cần UPDATE, Mã nhân sự cần UPDATE
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_SINGLE_COL_SINHVIEN
(STR_COLUMN IN VARCHAR2, STR_VALUE IN VARCHAR2, STR_ID IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_SINHVIEN SET ' || STR_COLUMN || ' = ''' || STR_VALUE || ''' WHERE MASV = ''' || STR_ID || '''';
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_SINGLE_COL_SINHVIEN TO PUBLIC;
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



/***************************************************************
* Stored Procedure Kiểm tra dữ liệu tồn tại
****************************************************************/
----------------------------------------------------------------
-- Stored Procedure Kiểm tra Sinh viên có tồn tại không
-- Tham số truyền vào: MASV
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_IS_EXIST_SINHVIEN(
    OUTPUT OUT SYS_REFCURSOR,
    STR_MASV IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR 'SELECT COUNT(*) FROM C##ADMIN.N09_SINHVIEN WHERE MASV = ''' || STR_MASV || '''';
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_IS_EXIST_SINHVIEN TO PUBLIC;
/

-- -- Test
-- CONN NV301/NV301;
-- VARIABLE rc REFCURSOR;
-- EXECUTE C##ADMIN.N09_IS_EXIST_SINHVIEN(:rc, 'SV001');
-- PRINT rc;
-- /



----------------------------------------------------------------
-- Stored Procedure Kiểm tra Nhân sự có tồn tại không
-- Tham số truyền vào: MANV
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_IS_EXIST_NHANSU(
    OUTPUT OUT SYS_REFCURSOR,
    STR_MANV IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR 'SELECT COUNT(*) FROM C##ADMIN.N09_NHANSU WHERE MANV = ''' || STR_MANV || '''';
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_IS_EXIST_NHANSU TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--VARIABLE rc REFCURSOR;
--EXECUTE C##ADMIN.N09_IS_EXIST_NHANSU(:rc, 'NV301');
--PRINT rc;
--/



----------------------------------------------------------------
-- Stored Procedure Kiểm tra Đơn vị có tồn tại không
-- Tham số truyền vào: MADV
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_IS_EXIST_DONVI(
    OUTPUT OUT SYS_REFCURSOR,
    STR_MADV IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR 'SELECT COUNT(*) FROM C##ADMIN.N09_DONVI WHERE MADV = ''' || STR_MADV || '''';
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_IS_EXIST_DONVI TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--VARIABLE rc REFCURSOR;
--EXECUTE C##ADMIN.N09_IS_EXIST_DONVI(:rc, 'KHOA1');
--PRINT rc;
--/



----------------------------------------------------------------
-- Stored Procedure Kiểm tra Học phần có tồn tại không
-- Tham số truyền vào: MAHP
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_IS_EXIST_HOCPHAN(
    OUTPUT OUT SYS_REFCURSOR,
    STR_MAHP IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR 'SELECT COUNT(*) FROM C##ADMIN.N09_HOCPHAN WHERE MAHP = ''' || STR_MAHP || '''';
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_IS_EXIST_HOCPHAN TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--VARIABLE rc REFCURSOR;
--EXECUTE C##ADMIN.N09_IS_EXIST_HOCPHAN(:rc, 'HP001');
--PRINT rc;
--/



----------------------------------------------------------------
-- Stored Procedure Kiểm tra KHMO có tồn tại không
-- Tham số truyền vào: MAHP, HK, NAM, MACT
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_IS_EXIST_KHMO(
    OUTPUT OUT SYS_REFCURSOR,
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR 'SELECT COUNT(*) FROM C##ADMIN.N09_KHMO WHERE MAHP = ''' || STR_MAHP || ''' AND HK = ' || STR_HK || ' AND NAM = ' || STR_NAM || ' AND MACT = ''' || STR_MACT || '''';
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_IS_EXIST_KHMO TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--VARIABLE rc REFCURSOR;
--EXECUTE C##ADMIN.N09_IS_EXIST_KHMO(:rc, 'HP001', 1, 2024, 'CQ');
--PRINT rc;
--/



----------------------------------------------------------------
-- Stored Procedure Kiểm tra DANGKY có tồn tại không
-- Tham số truyền vào: MASV, MAGV, MAHP, HK, NAM, MACT
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_IS_EXIST_DANGKY(
    OUTPUT OUT SYS_REFCURSOR,
    STR_MASV IN VARCHAR2,
    STR_MAGV IN VARCHAR2,
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR 'SELECT COUNT(*) FROM C##ADMIN.N09_DANGKY WHERE MASV = ''' || STR_MASV || ''' AND MAGV = ''' || STR_MAGV || ''' AND MAHP = ''' || STR_MAHP || ''' AND HK = ' || STR_HK || ' AND NAM = ' || STR_NAM || ' AND MACT = ''' || STR_MACT || '''';
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_IS_EXIST_DANGKY TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--VARIABLE rc REFCURSOR;
--EXECUTE C##ADMIN.N09_IS_EXIST_DANGKY(:rc, 'SV001', 'NV301', 'HP001', 1, 2024, 'CQ');
--PRINT rc;
--/



----------------------------------------------------------------
-- Stored Procedure Kiểm tra PHANCONG có tồn tại không
-- Tham số truyền vào: MAGV, MAHP, HK, NAM, MACT
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_IS_EXIST_PHANCONG(
    OUTPUT OUT SYS_REFCURSOR,
    STR_MAGV IN VARCHAR2,
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2)
AS
BEGIN
    OPEN OUTPUT FOR 'SELECT COUNT(*) FROM C##ADMIN.N09_PHANCONG WHERE MAGV = ''' || STR_MAGV || ''' AND MAHP = ''' || STR_MAHP || ''' AND HK = ' || STR_HK || ' AND NAM = ' || STR_NAM || ' AND MACT = ''' || STR_MACT || '''';
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_IS_EXIST_PHANCONG TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--VARIABLE rc REFCURSOR;
--EXECUTE C##ADMIN.N09_IS_EXIST_PHANCONG(:rc, 'NV301', 'HP001', 1, 2024, 'CQ');
--PRINT rc;
--/



/***************************************************************
* Stored Procedure INSERT, UPDATE, DELETE trên các bảng Phân hệ 2
****************************************************************/
----------------------------------------------------------------
-- Stored Procedure Insert SINHVIEN
-- Tham số truyền vào: MASV
-- Tham số optional: HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL, COSO
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_INSERT_SINHVIEN(
    STR_MASV IN VARCHAR2,
    STR_HOTEN IN VARCHAR2 DEFAULT NULL,
    STR_PHAI IN VARCHAR2 DEFAULT NULL,
    STR_NGSINH IN DATE DEFAULT NULL,
    STR_DIACHI IN VARCHAR2 DEFAULT NULL,
    STR_DT IN VARCHAR2 DEFAULT NULL,
    STR_MACT IN VARCHAR2 DEFAULT NULL,
    STR_MANGANH IN VARCHAR2 DEFAULT NULL,
    STR_SOTCTL IN NUMBER DEFAULT NULL,
    STR_DTBTL IN NUMBER DEFAULT NULL,
    STR_COSO IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO C##ADMIN.N09_SINHVIEN(MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL, COSO) 
                        VALUES(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11)'
                        USING STR_MASV, STR_HOTEN, STR_PHAI, STR_NGSINH, STR_DIACHI, STR_DT, STR_MACT, STR_MANGANH, STR_SOTCTL, STR_DTBTL, STR_COSO;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_INSERT_SINHVIEN TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_SINHVIEN;
--EXECUTE C##ADMIN.N09_INSERT_SINHVIEN('SV201', 'Nguyen Van A', 'Nam', TO_DATE('01/01/2000', 'DD/MM/YYYY'), 'Ha Noi', '0123456789', 'CT1', 'CN1', 120, 8.5, 'CS1');
--/



----------------------------------------------------------------
-- Stored Procedure Update SINHVIEN (FULL)
-- Tham số truyền vào: MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL, COSO
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_SINHVIEN(
    STR_MASV IN VARCHAR2,
    STR_HOTEN IN VARCHAR2,
    STR_PHAI IN VARCHAR2,
    STR_NGSINH IN DATE,
    STR_DIACHI IN VARCHAR2,
    STR_DT IN VARCHAR2,
    STR_MACT IN VARCHAR2,
    STR_MANGANH IN VARCHAR2,
    STR_SOTCTL IN NUMBER,
    STR_DTBTL IN NUMBER,
    STR_COSO IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_SINHVIEN SET HOTEN = :1, PHAI = :2, NGSINH = :3, DIACHI = :4, DT = :5, MACT = :6, MANGANH = :7, SOTCTL = :8, DTBTL = :9, COSO = :10 WHERE MASV = :11'
                        USING STR_HOTEN, STR_PHAI, STR_NGSINH, STR_DIACHI, STR_DT, STR_MACT, STR_MANGANH, STR_SOTCTL, STR_DTBTL, STR_COSO, STR_MASV;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_SINHVIEN TO PUBLIC;
/

-- -- Test
-- CONN NV301/NV301;
-- SELECT * FROM C##ADMIN.N09_SINHVIEN;
-- EXECUTE C##ADMIN.N09_UPDATE_SINHVIEN('SV001', 'Nguyen Van B', 'Nam', TO_DATE('01/01/2000', 'DD/MM/YYYY'), 'Ha Noi', '0123456789', 'CT1', 'CN1', 120, 8.5, 'CS1');
-- /



----------------------------------------------------------------
-- Stored Procedure Insert DANGKY
-- Tham số truyền vào: MASV, MAGV, MAHP, HK, NAM, MACT
-- Tham số optional: DIEMTH, DIEMQT, DIEMCK, DIEMTK
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_INSERT_DANGKY(
    STR_MASV IN VARCHAR2,
    STR_MAGV IN VARCHAR2,
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2,
    STR_DIEMTH IN NUMBER DEFAULT NULL,
    STR_DIEMQT IN NUMBER DEFAULT NULL,
    STR_DIEMCK IN NUMBER DEFAULT NULL,
    STR_DIEMTK IN NUMBER DEFAULT NULL)
IS
BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO C##ADMIN.N09_DANGKY(MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK) 
                        VALUES(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10)'
                        USING STR_MASV, STR_MAGV, STR_MAHP, STR_HK, STR_NAM, STR_MACT, STR_DIEMTH, STR_DIEMQT, STR_DIEMCK, STR_DIEMTK;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_INSERT_DANGKY TO PUBLIC;
/

---- Test
--CONN NV201/NV201;
--SELECT * FROM C##ADMIN.N09_DANGKY;
--EXECUTE C##ADMIN.N09_INSERT_DANGKY('SV001', 'NV201', 'HP001', 1, 2024, 'CQ', 10, 10, 10, 10);
--/



----------------------------------------------------------------
-- Stored Procedure Update DANGKY (Điểm)
-- Tham số truyền vào: MASV, MAGV, MAHP, HK, NAM, MACT, DIEMTH, DIEMQT, DIEMCK, DIEMTK
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_DANGKY(
    STR_MASV IN VARCHAR2,
    STR_MAGV IN VARCHAR2,
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2,
    STR_DIEMTH IN NUMBER,
    STR_DIEMQT IN NUMBER,
    STR_DIEMCK IN NUMBER,
    STR_DIEMTK IN NUMBER)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_DANGKY SET DIEMTH = :1, DIEMQT = :2, DIEMCK = :3, DIEMTK = :4 WHERE MASV = :5 AND MAGV = :6 AND MAHP = :7 AND HK = :8 AND NAM = :9 AND MACT = :10'
                        USING STR_DIEMTH, STR_DIEMQT, STR_DIEMCK, STR_DIEMTK, STR_MASV, STR_MAGV, STR_MAHP, STR_HK, STR_NAM, STR_MACT;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_DANGKY TO PUBLIC;
/

---- Test
--CONN NV201/NV201;
--SELECT * FROM C##ADMIN.N09_DANGKY;
--VARIABLE rc REFCURSOR;
--EXECUTE C##ADMIN.N09_SELECT_ANY_TABLE(:rc, 'C##ADMIN.N09_DANGKY');
--PRINT rc;
--EXECUTE C##ADMIN.N09_UPDATE_DANGKY('SV001', 'NV201', 'HP001', 1, 2024, 'CQ', 10, 10, 10, 10);
--/



----------------------------------------------------------------
-- Stored Procedure Insert PHANCONG (FULL)
-- Tham số truyền vào: MAGV, MAHP, HK, NAM, MACT
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_INSERT_PHANCONG(
    STR_MAGV IN VARCHAR2,
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO C##ADMIN.N09_PHANCONG(MAGV, MAHP, HK, NAM, MACT) VALUES(:1, :2, :3, :4, :5)'
                        USING STR_MAGV, STR_MAHP, STR_HK, STR_NAM, STR_MACT;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_INSERT_PHANCONG TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_PHANCONG;
--EXECUTE C##ADMIN.N09_INSERT_PHANCONG('NV201', 'HP001', 1, 2024, 'CQ');
--/



----------------------------------------------------------------
-- Stored Procedure Update PHANCONG (FULL)
-- Tham số truyền vào: MAGV, MAHP, HK, NAM, MACT
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_PHANCONG(
    STR_MAGV IN VARCHAR2,
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2,
    STR_OLD_MAGV IN VARCHAR2,
    STR_OLD_MAHP IN VARCHAR2,
    STR_OLD_HK IN NUMBER,
    STR_OLD_NAM IN NUMBER,
    STR_OLD_MACT IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_PHANCONG SET MAGV = :1, MAHP = :2, HK = :3, NAM = :4, MACT = :5 WHERE MAGV = :6 AND MAHP = :7 AND HK = :8 AND NAM = :9 AND MACT = :10'
                        USING STR_MAGV, STR_MAHP, STR_HK, STR_NAM, STR_MACT, STR_OLD_MAGV, STR_OLD_MAHP, STR_OLD_HK, STR_OLD_NAM, STR_OLD_MACT;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_PHANCONG TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_PHANCONG WHERE MAHP = 'HP032';
--/
--
---- UPDATE Học phần HP006 không thuộc Văn phòng khoa: Không thành công
--CONN NV301/NV301;
--EXECUTE C##ADMIN.N09_UPDATE_PHANCONG('NV217', 'HP006', 3, 2077, 'CLC', 'NV217', 'HP006', 3, 2024, 'CLC');
--/
--
---- UPDATE Học phần HP032 thuộc Văn phòng khoa: Thành công
--CONN NV301/NV301;
--EXECUTE C##ADMIN.N09_UPDATE_PHANCONG('NV209', 'HP032', 2, 2025, 'CQ', 'NV209', 'HP032', 2, 2024, 'CQ');
--/
--
---- UPDATE Học phần HP032 thuộc Văn phòng khoa: Thành công
--CONN NV301/NV301;
--EXECUTE C##ADMIN.N09_UPDATE_PHANCONG('NV209', 'HP032', 2, 2024, 'CQ', 'NV209', 'HP032', 2, 2025, 'CQ');
--/



----------------------------------------------------------------
-- Stored Procedure Insert DONVI (FULL)
-- Tham số truyền vào: MADV, TENDV, TRGDV
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_INSERT_DONVI(
    STR_MADV IN VARCHAR2,
    STR_TENDV IN VARCHAR2 DEFAULT NULL,
    STR_TRGDV IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO C##ADMIN.N09_DONVI(MADV, TENDV, TRGDV) VALUES(:1, :2, :3)'
                        USING STR_MADV, STR_TENDV, STR_TRGDV;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_INSERT_DONVI TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_DONVI;
--EXECUTE C##ADMIN.N09_INSERT_DONVI('DV008', 'Bộ môn TKVM', 'NV103');
--/



----------------------------------------------------------------
-- Stored Procedure Update DONVI (FULL)
-- Tham số truyền vào: MADV, TENDV, TRGDV
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_DONVI(
    STR_MADV IN VARCHAR2,
    STR_TENDV IN VARCHAR2,
    STR_TRGDV IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_DONVI SET TENDV = :1, TRGDV = :2 WHERE MADV = :3'
                        USING STR_TENDV, STR_TRGDV, STR_MADV;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_DONVI TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_DONVI;
--EXECUTE C##ADMIN.N09_UPDATE_DONVI('DV001', 'Khoa CNTT', 'Nguyen Van A');
--/



----------------------------------------------------------------
-- Stored Procedure Insert HOCPHAN (FULL)
-- Tham số truyền vào: MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_INSERT_HOCPHAN(
    STR_MAHP IN VARCHAR2,
    STR_TENHP IN VARCHAR2 DEFAULT NULL,
    STR_SOTC IN NUMBER DEFAULT NULL,
    STR_STLT IN NUMBER DEFAULT NULL,
    STR_STTH IN NUMBER DEFAULT NULL,
    STR_SOSVTD IN NUMBER DEFAULT NULL,
    STR_MADV IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO C##ADMIN.N09_HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV) VALUES(:1, :2, :3, :4, :5, :6, :7)'
                        USING STR_MAHP, STR_TENHP, STR_SOTC, STR_STLT, STR_STTH, STR_SOSVTD, STR_MADV;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_INSERT_HOCPHAN TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_HOCPHAN;
--EXECUTE C##ADMIN.N09_INSERT_HOCPHAN('HP008', 'Lập trình hướng đối tượng', 3, 2, 1, 50, 'DV001');
--/



----------------------------------------------------------------
-- Stored Procedure Update HOCPHAN (FULL)
-- Tham số truyền vào: MAHP, TENHP, SOTC, STLT, STTH, SOSVTD, MADV
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_HOCPHAN(
    STR_MAHP IN VARCHAR2,
    STR_TENHP IN VARCHAR2,
    STR_SOTC IN NUMBER,
    STR_STLT IN NUMBER,
    STR_STTH IN NUMBER,
    STR_SOSVTD IN NUMBER,
    STR_MADV IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_HOCPHAN SET TENHP = :1, SOTC = :2, STLT = :3, STTH = :4, SOSVTD = :5, MADV = :6 WHERE MAHP = :7'
                        USING STR_TENHP, STR_SOTC, STR_STLT, STR_STTH, STR_SOSVTD, STR_MADV, STR_MAHP;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_HOCPHAN TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_HOCPHAN;
--EXECUTE C##ADMIN.N09_UPDATE_HOCPHAN('HP008', 'Lập trình hướng đối tượng', 3, 2, 1, 50, 'DV001');
--/



----------------------------------------------------------------
-- Stored Procedure Insert KHMO (FULL)
-- Tham số truyền vào: MAHP, HK, NAM, MACT
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_INSERT_KHMO(
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO C##ADMIN.N09_KHMO(MAHP, HK, NAM, MACT) VALUES(:1, :2, :3, :4)'
                        USING STR_MAHP, STR_HK, STR_NAM, STR_MACT;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_INSERT_KHMO TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_KHMO;
--EXECUTE C##ADMIN.N09_INSERT_KHMO('HP008', 1, 2024, 'CQ');
--/



----------------------------------------------------------------
-- Stored Procedure Update KHMO (FULL)
-- Tham số truyền vào: MAHP, HK, NAM, MACT, OLD_MAHP, OLD_HK, OLD_NAM, OLD_MACT
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_KHMO(
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2,
    STR_OLD_MAHP IN VARCHAR2,
    STR_OLD_HK IN NUMBER,
    STR_OLD_NAM IN NUMBER,
    STR_OLD_MACT IN VARCHAR2)

IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_KHMO SET HK = :1, NAM = :2, MACT = :3, MAHP = :4 WHERE MAHP = :5 AND HK = :6 AND NAM = :7 AND MACT = :8'
                        USING STR_HK, STR_NAM, STR_MACT, STR_MAHP, STR_OLD_MAHP, STR_OLD_HK, STR_OLD_NAM, STR_OLD_MACT;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_KHMO TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_KHMO;
--EXECUTE C##ADMIN.N09_UPDATE_KHMO('HP034', 6, 9009, 'CLC', 'HP034', 6, 9999, 'CLC');
--/



----------------------------------------------------------------
-- Stored Procedure Insert NHANSU (FULL)
-- Tham số truyền vào: MANV
-- Tham số optional: HOTEN, PHAI, NGSINH, PHUCAP, DT, VAITRO, MADV, COSO
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_INSERT_NHANSU
(STR_MANV IN VARCHAR2,
STR_HOTEN IN VARCHAR2 DEFAULT NULL,
STR_PHAI IN VARCHAR2 DEFAULT NULL,
STR_NGSINH IN DATE DEFAULT NULL,
STR_PHUCAP IN NUMBER DEFAULT NULL,
STR_DT IN VARCHAR2 DEFAULT NULL,
STR_VAITRO IN VARCHAR2 DEFAULT NULL,
STR_MADV IN VARCHAR2 DEFAULT NULL,
STR_COSO IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO C##ADMIN.N09_NHANSU(MANV, HOTEN, PHAI, NGSINH, PHUCAP, DT, VAITRO, MADV, COSO) 
                        VALUES(:1, :2, :3, :4, :5, :6, :7, :8, :9)'
                        USING STR_MANV, STR_HOTEN, STR_PHAI, STR_NGSINH, STR_PHUCAP, STR_DT, STR_VAITRO, STR_MADV, STR_COSO;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_INSERT_NHANSU TO PUBLIC;
/

---- Test
--CONN NV001/NV001;
--SELECT * FROM C##ADMIN.N09_NHANSU;
--EXECUTE C##ADMIN.N09_INSERT_NHANSU('NV201', 'Nguyen Van A', 'Nam', TO_DATE('01/01/2000', 'DD/MM/YYYY'), 1000000, '0123456789', 'GV', 'DV001', 'CS1');
--/



----------------------------------------------------------------
-- Stored Procedure Update NHANSU (FULL)
-- Tham số truyền vào: MANV, HOTEN, PHAI, NGSINH, PHUCAP, DT, VAITRO, MADV, COSO
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_UPDATE_NHANSU
(STR_MANV IN VARCHAR2,
STR_HOTEN IN VARCHAR2,
STR_PHAI IN VARCHAR2,
STR_NGSINH IN DATE,
STR_PHUCAP IN NUMBER,
STR_DT IN VARCHAR2,
STR_VAITRO IN VARCHAR2,
STR_MADV IN VARCHAR2,
STR_COSO IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'UPDATE C##ADMIN.N09_NHANSU SET HOTEN = :1, PHAI = :2, NGSINH = :3, PHUCAP = :4, DT = :5, VAITRO = :6, MADV = :7, COSO = :8 WHERE MANV = :9'
                        USING STR_HOTEN, STR_PHAI, STR_NGSINH, STR_PHUCAP, STR_DT, STR_VAITRO, STR_MADV, STR_COSO, STR_MANV;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_UPDATE_NHANSU TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_NHANSU;
--EXECUTE C##ADMIN.N09_UPDATE_NHANSU('NV201', 'Nguyen Van A', 'Nam', TO_DATE('01/01/2000', 'DD/MM/YYYY'), 1000000, '0123456789', 'GV', 'DV001', 'CS1');
--/



----------------------------------------------------------------
-- Stored Procedure DELETE DANGKY 
-- Tham số truyền vào: MASV, MAGV, MAHP, HK, NAM, MACT
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_DELETE_DANGKY(
    STR_MASV IN VARCHAR2,
    STR_MAGV IN VARCHAR2,
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'DELETE FROM C##ADMIN.N09_DANGKY WHERE MASV = :1 AND MAGV = :2 AND MAHP = :3 AND HK = :4 AND NAM = :5 AND MACT = :6'
                        USING STR_MASV, STR_MAGV, STR_MAHP, STR_HK, STR_NAM, STR_MACT;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_DELETE_DANGKY TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_DANGKY;
--EXECUTE C##ADMIN.N09_DELETE_DANGKY('SV001', 'NV201', 'HP001', 1, 2024, 'CQ');
--/



----------------------------------------------------------------
-- Stored Procedure DELETE NHANSU 
-- Tham số truyền vào: MANV
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_DELETE_NHANSU(
    STR_MANV IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'DELETE FROM C##ADMIN.N09_NHANSU WHERE MANV = :1'
                        USING STR_MANV;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_DELETE_NHANSU TO PUBLIC;
/

---- Test
--CONN NV001/NV001;
--SELECT * FROM C##ADMIN.N09_NHANSU;
--EXECUTE C##ADMIN.N09_DELETE_NHANSU('NV201');
--/



----------------------------------------------------------------
-- Stored Procedure DELETE PHANCONG 
-- Tham số truyền vào: MAGV, MAHP, HK, NAM, MACT
-- Tham số optional: Không
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_DELETE_PHANCONG(
    STR_MAGV IN VARCHAR2,
    STR_MAHP IN VARCHAR2,
    STR_HK IN NUMBER,
    STR_NAM IN NUMBER,
    STR_MACT IN VARCHAR2)
IS
BEGIN
    EXECUTE IMMEDIATE 'DELETE FROM C##ADMIN.N09_PHANCONG WHERE MAGV = :1 AND MAHP = :2 AND HK = :3 AND NAM = :4 AND MACT = :5'
                        USING STR_MAGV, STR_MAHP, STR_HK, STR_NAM, STR_MACT;
END;
/

-- Gán quyền thực thi thủ tục trên cho tất cả user
GRANT EXECUTE ON N09_DELETE_PHANCONG TO PUBLIC;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_PHANCONG;
--EXECUTE C##ADMIN.N09_DELETE_PHANCONG('NV201', 'HP001', 1, 2024, 'CQ');
--/






