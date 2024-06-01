-- Lớp: CQ2021/1
-- Nhóm: 09
-- Thành viên:
-- 21120037 - Mã Thùy Anh
-- 21120060 - Nguyễn Long Giang
-- 21120082 - Phan Quốc Huy 
-- 21120117 - Lê Thị Hồng Phượng



----------------------------------------------------------------
-- Script tạo các Role trong Database
------------------------------------------------------------------ 
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
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
CREATE OR REPLACE VIEW UV_N09_NHANSU
AS
    SELECT * FROM N09_NHANSU;
    
CREATE OR REPLACE VIEW UV_N09_SINHVIEN
AS
    SELECT * FROM N09_SINHVIEN;
    
CREATE OR REPLACE VIEW UV_N09_DONVI
AS
    SELECT * FROM N09_DONVI;
    
CREATE OR REPLACE VIEW UV_N09_HOCPHAN
AS
    SELECT * FROM N09_HOCPHAN;
    
CREATE OR REPLACE VIEW UV_N09_KHMO
AS
    SELECT * FROM N09_KHMO;
        
CREATE OR REPLACE VIEW UV_N09_PHANCONG
AS
    SELECT * FROM N09_PHANCONG;    
    
CREATE OR REPLACE VIEW UV_N09_DANGKY
AS
    SELECT * FROM N09_DANGKY;    
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
        
        STRSQL := 'DROP USER '|| USR ||' CASCADE'; 
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
        
        STRSQL := 'DROP USER '|| USR ||' CASCADE'; 
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
-- Thực thi Stored Procedure xóa user cho tất cả nhân sự
EXEC N09_DROP_USER_NHANSU;
/
-- Thực thi Stored Procedure xóa user cho tất cả sinh viên
EXEC N09_DROP_USER_SINHVIEN;
/
-- Thực thi Stored Procedure tạo user cho tất cả nhân sự
EXEC N09_CREATE_USER_NHANSU;
/
-- Thực thi Stored Procedure tạo user cho tất cả sinh viên
EXEC N09_CREATE_USER_SINHVIEN;
/
-- Thực thi Stored Procedure gán Role cho tất cả Nhân viên
EXEC N09_GRANT_ROLE_NHANSU('N09_RL_NHANVIEN', 'Nhan vien');
/
-- Thực thi Stored Procedure gán Role cho tất cả Giảng viên
EXEC N09_GRANT_ROLE_NHANSU('N09_RL_GIANGVIEN', 'Giang vien');
/
-- Thực thi Stored Procedure gán Role cho tất cả Giáo vụ
EXEC N09_GRANT_ROLE_NHANSU('N09_RL_GIAOVU', 'Giao vu');
/
-- Thực thi Stored Procedure gán Role cho tất cả Trưởng đơn vị
EXEC N09_GRANT_ROLE_NHANSU('N09_RL_TRUONG_DONVI', 'Truong don vi');
/
-- Thực thi Stored Procedure gán Role cho tất cả Trưởng khoa
EXEC N09_GRANT_ROLE_NHANSU('N09_RL_TRUONG_KHOA', 'Truong khoa');
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


    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    