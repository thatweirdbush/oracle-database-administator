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
-- 1. Kích hoạt việc ghi nhật ký hệ thống. (Thực hiện bằng SQL Plus)
ALTER SYSTEM SET AUDIT_TRAIL = 'DB', 'EXTENDED' SCOPE = SPFILE;
SHUTDOWN;
STARTUP;

-- 2. Thực hiện ghi nhật ký hệ thống dùng Standard audit:
AUDIT ALL ON C##ADMIN.N09_NHANSU BY ACCESS;
AUDIT ALL ON C##ADMIN.N09_SINHVIEN BY ACCESS;
AUDIT ALL ON C##ADMIN.N09_DONVI BY ACCESS;
AUDIT ALL ON C##ADMIN.N09_HOCPHAN BY ACCESS;
AUDIT ALL ON C##ADMIN.N09_KHMO BY ACCESS;
AUDIT ALL ON C##ADMIN.N09_PHANCONG BY ACCESS;
AUDIT ALL ON C##ADMIN.N09_DANGKY BY ACCESS;

BEGIN
    FOR REC IN (
        SELECT OBJECT_NAME, OBJECT_TYPE
        FROM ALL_OBJECTS
        WHERE OWNER = 'C##ADMIN'
        AND OBJECT_TYPE IN ('PROCEDURE', 'FUNCTION')
    ) LOOP
        EXECUTE IMMEDIATE 'AUDIT EXECUTE ON C##ADMIN.' || REC.OBJECT_NAME || ' BY ACCESS';
    END LOOP;
END;
/

-- Tình huống tạo hành vi trên 
CONN C##ADMIN/123;
SELECT * FROM C##ADMIN.N09_SINHVIEN;
/

CONN SV001/SV001;
SELECT * FROM C##ADMIN.N09_SINHVIEN;
UPDATE C##ADMIN.N09_SINHVIEN SET DT = '123' WHERE MASV = 'SV001';

-- Kiểm tra (đọc xuất) dữ liệu nhật ký hệ thống.
COLUMN USERNAME FORMAT A9
COLUMN OWNER FORMAT A5
COLUMN OBJ_NAME FORMAT A10
COLUMN ACTION_NAME FORMAT A11
COLUMN SQL_TEXT FORMAT A40

SELECT USERNAME, TO_CHAR(Timestamp, 'DD-MON-YYYY HH24:MI:SS') AS AUDIT_TIME, OWNER, OBJ_NAME, ACTION_NAME, SQL_TEXT FROM DBA_AUDIT_TRAIL;

-- XOÁ TOÀN BỘ DỮ LIỆU AUDIT
DELETE FROM SYS.AUD$;
COMMIT;

/***************************************************************
3. Thực hiện Fine-grained Audit các tình huống sau và tạo ngữ cảnh để có thể ghi vết
        được (có dữ liệu ghi vết) các hành vi sau:
        a. Hành vi Cập nhật quan hệ ĐANGKY tại các trường liên quan đến điểm số
            nhưng người đó không thuộc vai trò Giảng viên.

****************************************************************/
BEGIN 
    DBMS_FGA.ADD_POLICY (
    OBJECT_SCHEMA => 'C##ADMIN',
    OBJECT_NAME => 'N09_DANGKY',
    POLICY_NAME => 'AUDIT_UPDATE_DIEM',
    AUDIT_CONDITION => 'INSTR(SYS_CONTEXT(''USERENV'',''SESSION_USER''),''NV2'') < 0',
    AUDIT_COLUMN => 'DIEMTH, DIEMQT, DIEMCK, DIEMTK',
    STATEMENT_TYPES => 'UPDATE'
    );
END;
/

-- XOÁ POLICY
BEGIN
    DBMS_FGA.DROP_POLICY(
        OBJECT_SCHEMA => 'C##ADMIN',
        OBJECT_NAME => 'N09_DANGKY',
        POLICY_NAME => 'AUDIT_UPDATE_DIEM'
    );
END;
/

-- TEST
GRANT SELECT, UPDATE ON C##ADMIN.N09_DANGKY TO NV201;
GRANT SELECT, UPDATE ON C##ADMIN.N09_DANGKY TO NV001;

-- LÀ GIẢNG VIÊN: SẼ KHÔNG ĐƯỢC AUDIT
CONN NV201/NV201;
UPDATE C##ADMIN.N09_DANGKY SET DIEMTK = 8 WHERE MASV = 'SV001';

-- LÀ TRƯỞNG KHOA: SẼ ĐƯỢC AUDIT
CONN NV001/NV001;
UPDATE C##ADMIN.N09_DANGKY SET DIEMTK = 8 WHERE MASV = 'SV001';


/***************************************************************
3. Thực hiện Fine-grained Audit các tình huống sau và tạo ngữ cảnh để có thể ghi vết
        được (có dữ liệu ghi vết) các hành vi sau:
        b. Hành vi của người dùng này có thể đọc trên trường PHUCAP của người khác
            ở quan hệ NHANSU.

****************************************************************/
BEGIN 
    DBMS_FGA.ADD_POLICY (
    OBJECT_SCHEMA => 'C##ADMIN',
    OBJECT_NAME => 'N09_NHANSU',
    POLICY_NAME => 'AUDIT_SELECT_PHUCAP',
    AUDIT_CONDITION => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') != USER',
    AUDIT_COLUMN => 'PHUCAP',
    STATEMENT_TYPES => 'SELECT'
    );
END;
/

BEGIN
    DBMS_FGA.DROP_POLICY(
        OBJECT_SCHEMA => 'C##ADMIN',
        OBJECT_NAME => 'N09_DANGKY',
        POLICY_NAME => 'AUDIT_SELECT_PHUCAP'
    );
END;
/

















