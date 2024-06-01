-- Lớp: CQ2021/1
-- Nhóm: 09
-- Thành viên:
-- 21120037 - Mã Thùy Anh
-- 21120060 - Nguyễn Long Giang
-- 21120082 - Phan Quốc Huy 
-- 21120117 - Lê Thị Hồng Phượng



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


----------------------------------------------------------------
-- Stored Procedure lấy thông tin User hiện tại
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE N09_GET_CURRENT_USER
AS
BEGIN
    EXECUTE IMMEDIATE 'SELECT USER FROM DUAL';
END;
/

CONN HUYP/123;
EXEC N09_GET_CURRENT_USER;


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


-- -- Test
 -- SELECT tất cả các dòng của Table N09_NHANVIEN
 CONN HUYP/123
 VARIABLE rc REFCURSOR;
     EXECUTE SYS.N09_SELECT_ANY_TABLE(:rc, 'N09_BAOCAO');
 PRINT rc;

-- -- Không SELECT được dòng nào trong Table N09_NHANVIEN
-- VARIABLE rc REFCURSOR;
--     EXECUTE SYS.N09_SELECT_ANY_TABLE(:rc, 'N09_NHANVIEN', '1=0');
-- PRINT rc;



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

-- -- Test
-- VARIABLE rc REFCURSOR;
-- EXECUTE N09_SELECT_USER_OR_ROLE_PRIVS_SIMPLIFY(:rc, 'KH1');
-- PRINT rc;



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

VARIABLE rc REFCURSOR;
    EXECUTE SYS.N09_SELECT_DBA_TABLES(:rc, 'N09_');
PRINT rc;



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

VARIABLE rc REFCURSOR;
    EXECUTE SYS.N09_SELECT_TAB_COLUMNS(:rc, 'N09_NHANVIEN');
PRINT rc;



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


    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    