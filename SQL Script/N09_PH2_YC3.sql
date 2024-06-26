-- Lớp: CQ2021/1
-- Nhóm: 09
-- Thành viên:
-- 21120037 - Mã Thùy Anh
-- 21120060 - Nguyễn Long Giang
-- 21120082 - Phan Quốc Huy 
-- 21120117 - Lê Thị Hồng Phượng



/***************************************************************
Yêu cầu 3: Ghi nhật ký hệ thống
    Sinh viên hãy thực hiện cài đặt trên Oracle và Ứng dụng:
    
    1. Kích hoạt việc ghi nhật ký hệ thống.
    2. Thực hiện ghi nhật ký hệ thống dùng Standard audit: theo dõi hành vi của những user
        nào trên những đối tượng cụ thể, trên các đối tượng khác nhau (table, view, stored
        procedure, function), hay chỉ định theo dõi các hành vi hiện thành công hay không
        thành công.
    3. Thực hiện Fine-grained Audit các tình huống sau và tạo ngữ cảnh để có thể ghi vết
        được (có dữ liệu ghi vết) các hành vi sau:
        a. Hành vi Cập nhật quan hệ ĐANGKY tại các trường liên quan đến điểm số
            nhưng người đó không thuộc vai trò Giảng viên.
        b. Hành vi của người dùng này có thể đọc trên trường PHUCAP của người khác
            ở quan hệ NHANSU.
    4. Kiểm tra (đọc xuất) dữ liệu nhật ký hệ thống. 
    
****************************************************************/
-- Xóa user SEC_MGR trước khi tạo mới lại
-- Kết nối bằng quyền SYS AS SYSDBA
--CONN SYS/244466666 AS SYSDBA
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
DROP USER SEC_MGR CASCADE;
DROP ROLE N09_RL_SEC_MGR;
/

-- Tạo security administrator thực hiện việc ghi nhật ký hệ thống
CREATE USER SEC_MGR IDENTIFIED BY 123;
CREATE ROLE N09_RL_SEC_MGR;
/

-- Gán quyền cấp cao cho SEC_MGR
GRANT CONNECT, RESOURCE TO N09_RL_SEC_MGR;
GRANT SELECT ANY TABLE TO N09_RL_SEC_MGR;
GRANT CREATE PROCEDURE TO N09_RL_SEC_MGR;
GRANT EXECUTE ANY PROCEDURE TO N09_RL_SEC_MGR;
GRANT EXECUTE ON DBMS_FGA TO N09_RL_SEC_MGR;
GRANT AUDIT ANY TO N09_RL_SEC_MGR;
GRANT AUDIT SYSTEM TO N09_RL_SEC_MGR;
GRANT ANALYZE ANY TO N09_RL_SEC_MGR;
GRANT DELETE ON SYS.AUD$ TO N09_RL_SEC_MGR;
GRANT DELETE ON SYS.FGA_LOG$ TO N09_RL_SEC_MGR;
GRANT SELECT ANY DICTIONARY TO N09_RL_SEC_MGR;

-- Gán role cho SEC_MGR
GRANT N09_RL_SEC_MGR TO SEC_MGR;
/

/***************************************************************/
-- Tạo các View để lấy dữ liệu từ DBA_AUDIT_TRAIL và DBA_FGA_AUDIT_TRAIL (Dành để xử lý trên App)
-- Xóa view cũ trước khi tạo mới
DROP VIEW N09_AUDIT_TRAIL;
DROP VIEW N09_FGA;
DROP VIEW N09_AUDIT_OBJECTS;
/

-- Tạo View từ DBA_AUDIT_TRAIL
CREATE OR REPLACE VIEW N09_AUDIT_TRAIL AS
SELECT 
    USERNAME, 
    TO_CHAR(Timestamp, 'DD-MON-YYYY HH24:MI:SS') AS TIME, 
    OBJ_NAME, 
    ACTION_NAME, 
    SQL_TEXT
FROM DBA_AUDIT_TRAIL;
/

-- Gán quyền cho SEC_MGR
GRANT SELECT ON N09_AUDIT_TRAIL TO SEC_MGR;
/

-- Tạo View từ DBA_FGA_AUDIT_TRAIL
CREATE OR REPLACE VIEW N09_FGA AS
SELECT 
    DB_USER, 
    TO_CHAR(Timestamp, 'DD-MON-YYYY HH24:MI:SS') AS TIME, 
    OBJECT_NAME, 
    STATEMENT_TYPE, 
    SQL_TEXT
FROM DBA_FGA_AUDIT_TRAIL;
/

-- Gán quyền cho SEC_MGR
GRANT SELECT ON N09_FGA TO SEC_MGR;
/

-- Tạo View từ DBA_OBJ_AUDIT_OPTS
CREATE OR REPLACE VIEW N09_AUDIT_OBJECTS AS
SELECT *
FROM DBA_OBJ_AUDIT_OPTS
WHERE OWNER = 'N09_ADMIN'
/

-- Gán quyền cho SEC_MGR
GRANT SELECT ON N09_AUDIT_OBJECTS TO SEC_MGR;
/


/***************************************************************/
-- Kết nối với user mới và thực hiện script
-- NOTE: KHÔNG KẾT NỐI TỚI USER NÀY NỮA VÌ KHÔNG THỂ AUDIT TRÊN PROC/FUNC
-- NOTE: GIỮ KẾT NỐI SYS
--CONNECT SEC_MGR/123@//localhost:1521/PDB_N09;
/

/***************************************************************
-- 1. Kích hoạt việc ghi nhật ký hệ thống. (Thực hiện bằng SQL Plus)
-- ALTER SYSTEM SET AUDIT_TRAIL = DB, EXTENDED SCOPE = SPFILE;
-- SHUTDOWN IMMEDIATE;
-- STARTUP;
-- SHOW PARAMETER AUDIT_TRAIL;
-- /
***************************************************************/
-- 2. Thực hiện ghi nhật ký hệ thống dùng Standard audit:
--
-- Standard Audit tất cả các hành vi trên Table 
AUDIT ALL ON N09_ADMIN.N09_NHANSU BY ACCESS WHENEVER SUCCESSFUL;
AUDIT UPDATE, DELETE ON N09_ADMIN.N09_DANGKY BY ACCESS;
AUDIT SELECT ON N09_ADMIN.N09_SINHVIEN BY ACCESS;
AUDIT UPDATE ON N09_ADMIN.N09_KHMO BY ACCESS;

-- Standard Audit các hành vi trên View
-- Không sử dụng View trong đồ án này

-- Standard Audit các hành vi trên Function
AUDIT EXECUTE ON N09_ADMIN.N09_POLICY_FUNCTION_INSERT_DELETE_DANGKY BY ACCESS;
AUDIT EXECUTE ON N09_ADMIN.N09_POLICY_FUNCTION_UPDATE_DANGKY BY ACCESS;
/

-- Standard Audit các hành vi trên Stored Procedure
AUDIT EXECUTE ON N09_ADMIN.N09_UPDATE_DANGKY BY ACCESS;
AUDIT EXECUTE ON N09_ADMIN.N09_DELETE_DANGKY BY ACCESS;
AUDIT EXECUTE ON N09_ADMIN.N09_INSERT_SINHVIEN BY ACCESS;
AUDIT EXECUTE ON N09_ADMIN.N09_UPDATE_KHMO BY ACCESS;
/

---- Standard Audit tất cả các hành vi trên Stored Procedure và Function
-- BEGIN
--     FOR REC IN (
--         SELECT OBJECT_NAME, OBJECT_TYPE
--         FROM ALL_OBJECTS
--         WHERE OWNER = 'N09_ADMIN'
--         AND OBJECT_TYPE IN ('PROCEDURE', 'FUNCTION')
--     ) LOOP
--         EXECUTE IMMEDIATE 'AUDIT EXECUTE ON N09_ADMIN.' || REC.OBJECT_NAME || ' BY ACCESS';
--     END LOOP;
-- END;
-- /


---- Tạo ngữ cảnh để có thể ghi vết được (Gỡ comment để thực hiện)
--CONN SV001/SV001@//localhost:1521/PDB_N09;
--SELECT * FROM N09_ADMIN.N09_SINHVIEN;
--UPDATE N09_ADMIN.N09_SINHVIEN SET DT = '123' WHERE MASV = 'SV001';
--/
--
--CONN NV102/NV102@//localhost:1521/PDB_N09;
--SELECT * FROM N09_ADMIN.N09_DONVI;
--SELECT * FROM N09_ADMIN.N09_KHMO;
--/
--
--CONN NV201/NV201@//localhost:1521/PDB_N09;
--UPDATE N09_ADMIN.N09_DANGKY SET DIEMTH = 8 WHERE MASV = 'SV001';
--SELECT * FROM N09_ADMIN.N09_NHANSU;
--SELECT * FROM N09_ADMIN.N09_SINHVIEN;
--SELECT * FROM N09_ADMIN.N09_DANGKY;
--/
--
--CONN NV301/NV301@//localhost:1521/PDB_N09;
--SELECT * FROM N09_ADMIN.N09_PHANCONG;
---- Failed attempt
--DELETE FROM N09_ADMIN.N09_DONVI WHERE MADV = 'DV020';
--/

-- Xem dữ liệu Standard Audit
SELECT * FROM SYS.N09_AUDIT_TRAIL;
/

-- XOÁ TOÀN BỘ DỮ LIỆU AUDIT
DELETE FROM SYS.AUD$;
DELETE FROM SYS.FGA_LOG$;
COMMIT;
/


/***************************************************************
3. Thực hiện Fine-grained Audit các tình huống sau và tạo ngữ cảnh để có thể ghi vết
        được (có dữ liệu ghi vết) các hành vi sau:
        a. Hành vi Cập nhật quan hệ ĐANGKY tại các trường liên quan đến điểm số
            nhưng người đó không thuộc vai trò Giảng viên.

****************************************************************/
-- Tắt standard audit cho các bảng dùng FGA
NOAUDIT ALL ON N09_ADMIN.N09_NHANSU;
NOAUDIT ALL ON N09_ADMIN.N09_DANGKY;
/

-- Strange results từ FGA có thể xảy ra nếu không ANALYZE bảng trước
ANALYZE TABLE N09_ADMIN.N09_NHANSU COMPUTE STATISTICS;
ANALYZE TABLE N09_ADMIN.N09_DANGKY COMPUTE STATISTICS;
/

-- Xóa Policy FGA trước khi tạo mới
BEGIN
    DBMS_FGA.DROP_POLICY(
        OBJECT_SCHEMA => 'N09_ADMIN',
        OBJECT_NAME => 'N09_DANGKY',
        POLICY_NAME => 'AUDIT_UPDATE_DIEM'
    );
END;
/

BEGIN 
    DBMS_FGA.ADD_POLICY (
    OBJECT_SCHEMA => 'N09_ADMIN',
    OBJECT_NAME => 'N09_DANGKY',
    POLICY_NAME => 'AUDIT_UPDATE_DIEM',
    AUDIT_CONDITION => 'INSTR(USER,''NV2'') <= 0',
    AUDIT_COLUMN => 'DIEMTH, DIEMQT, DIEMCK, DIEMTK',
    STATEMENT_TYPES => 'UPDATE'
    );
END;
/

---- TEST (Gỡ comment để thực hiện)
---- LÀ GIẢNG VIÊN: SẼ KHÔNG ĐƯỢC AUDIT
--CONN NV201/NV201@//localhost:1521/PDB_N09;
--UPDATE N09_ADMIN.N09_DANGKY SET DIEMTK = 8 WHERE MASV = 'SV001';
--/
--
---- LÀ TRƯỞNG KHOA: SẼ ĐƯỢC AUDIT
--CONN NV001/NV001@//localhost:1521/PDB_N09;
--UPDATE N09_ADMIN.N09_DANGKY SET DIEMQT = 10 WHERE MASV = 'SV004';
--/

-- Kiểm tra việc ghi dữ liệu FGA (1 row - DB_USER: NV001)
SELECT * FROM SYS.N09_FGA;
/


/***************************************************************
3. Thực hiện Fine-grained Audit các tình huống sau và tạo ngữ cảnh để có thể ghi vết
        được (có dữ liệu ghi vết) các hành vi sau:
        b. Hành vi của người dùng này có thể đọc trên trường PHUCAP của người khác
            ở quan hệ NHANSU.

****************************************************************/
-- Xóa Policy FGA trước khi tạo mới
BEGIN
    DBMS_FGA.DROP_POLICY(
        OBJECT_SCHEMA => 'N09_ADMIN',
        OBJECT_NAME => 'N09_NHANSU',
        POLICY_NAME => 'AUDIT_SELECT_OTHER_PHUCAP'
    );
END;
/

BEGIN 
    DBMS_FGA.ADD_POLICY (
    OBJECT_SCHEMA => 'N09_ADMIN',
    OBJECT_NAME => 'N09_NHANSU',
    POLICY_NAME => 'AUDIT_SELECT_OTHER_PHUCAP',
    AUDIT_CONDITION => 'USER != MANV',
    AUDIT_COLUMN => 'PHUCAP',
    STATEMENT_TYPES => 'SELECT'
    );
END;
/

---- TEST (Gỡ comment để thực hiện)
---- LÀ GIẢNG VIÊN: SẼ KHÔNG ĐƯỢC AUDIT 
---- (VÌ VAI TRÒ GIẢNG VIÊN CHỈ ĐƯỢC ĐỌC DỮ LIỆU CỦA CHÍNH MÌNH)
--CONN NV201/NV201@//localhost:1521/PDB_N09;
--SELECT * FROM N09_ADMIN.N09_NHANSU;
--/
--
---- LÀ TRƯỞNG KHOA: SẼ ĐƯỢC AUDIT
--CONN NV001/NV001@//localhost:1521/PDB_N09;
--SELECT * FROM N09_ADMIN.N09_NHANSU;
--/

-- Kiểm tra việc ghi dữ liệu FGA (1 row - DB_USER: NV001)
SELECT * FROM SYS.N09_FGA;
/


/***************************************************************
3. Kiểm tra (đọc xuất) dữ liệu nhật ký hệ thống.

****************************************************************/ 
-- Các TEST ở trên đã thực hiện việc kiểm tra dữ liệu nhật ký hệ thống





