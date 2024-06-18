-- Lớp: CQ2021/1
-- Nhóm: 09
-- Thành viên:
-- 21120037 - Mã Thùy Anh
-- 21120060 - Nguyễn Long Giang
-- 21120082 - Phan Quốc Huy 
-- 21120117 - Lê Thị Hồng Phượng



/***************************************************************
*  YÊU CẦU 1: CẤP QUYỀN TRUY CẬP
****************************************************************/
-- CONNECT vào C##ADMIN để tạo CSDL trên Schema C##ADMIN 
CONN C##ADMIN/123@//localhost:1521/TEST;
/***************************************************************
CS#1: Người dùng có VAITRO là “Nhân viên cơ bản” có quyền truy cập dữ liệu:
    - Xem dòng dữ liệu của chính mình trong quan hệ NHANSU, có thể chỉnh sửa số điện
    thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
    - Xem thông tin của tất cả SINHVIEN, ĐƠNVỊ, HOCPHAN, KHMO.
****************************************************************/
-- 1a. Xem dòng dữ liệu của chính mình trong quan hệ NHANSU.
-- Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
--
-- Sử dụng VPD trực tiếp lên bảng gốc NHANSU cho 2 quyền SELECT và UPDATE (DT)
CREATE OR REPLACE FUNCTION N09_POLICY_FUNCTION_NHANSU
(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    USERNAME VARCHAR2(30);
BEGIN
    USERNAME := SYS_CONTEXT('USERENV', 'SESSION_USER');
    
    -- Các nhân sự có mã NV bắt đầu từ NV1 (Trưởng đơn vị)
    IF INSTR(USERNAME, 'NV1') > 0 THEN
        RETURN 'MADV IN (SELECT MADV
                         FROM N09_DONVI
                         WHERE TRGDV = ''' || USERNAME || ''')';    

    -- Các nhân sự có mã NV không phải bắt đầu từ NV0 (Trưởng khoa)
    ELSIF (INSTR(USERNAME, 'NV') > 0 AND INSTR(USERNAME, 'NV0') <= 0) THEN
        RETURN 'MANV = ''' || USERNAME || '''';
    
    ELSE
        RETURN NULL;
    END IF;
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'C##ADMIN',
        OBJECT_NAME => 'N09_NHANSU',
        POLICY_NAME => 'N09_POLICY_NHANSU',
        FUNCTION_SCHEMA => 'C##ADMIN',
        POLICY_FUNCTION => 'N09_POLICY_FUNCTION_NHANSU',
        STATEMENT_TYPES => 'SELECT, UPDATE'
    );
END;
/

-- Cấp quyền SELECT và UPDATE cột DT trên bảng NHANSU cho Nhân viên
GRANT SELECT, UPDATE (DT) ON N09_NHANSU TO N09_RL_NHANVIEN;

---- Test
---- Xem dữ liệu của chính mình: Thành công
--CONN NV401/NV401;
--SELECT * FROM C##ADMIN.N09_NHANSU;
--/
--
---- Cập nhật cột DT: Thành công
--CONN NV401/NV401;
--UPDATE C##ADMIN.N09_NHANSU SET DT = '0123456789' WHERE MANV = 'NV401';
--/
--
---- Cập nhật cột PHAI: Không thành công
--CONN NV401/NV401;
--UPDATE C##ADMIN.N09_NHANSU SET PHAI = 'Nam' WHERE MANV = 'NV401';
--/


-- 1b. Xem thông tin của tất cả SINHVIEN, ĐƠNVỊ, HOCPHAN, KHMO.
-- Gán quyền SELECT cho các bảng gốc
GRANT SELECT ON N09_SINHVIEN TO N09_RL_NHANVIEN;
GRANT SELECT ON N09_DONVI TO N09_RL_NHANVIEN;
GRANT SELECT ON N09_HOCPHAN TO N09_RL_NHANVIEN;
GRANT SELECT ON N09_KHMO TO N09_RL_NHANVIEN;
/

-- Gán quyền SELECT cho các View tương ứng với các bảng gốc
GRANT SELECT ON UV_N09_SINHVIEN TO N09_RL_NHANVIEN;
GRANT SELECT ON UV_N09_DONVI TO N09_RL_NHANVIEN;
GRANT SELECT ON UV_N09_HOCPHAN TO N09_RL_NHANVIEN;
GRANT SELECT ON UV_N09_KHMO TO N09_RL_NHANVIEN;
/



/***************************************************************
CS#2: Người dùng có VAITRO là “Giảng viên” có quyền truy cập dữ liệu:
    - Như một người dùng có vai trò “Nhân viên cơ bản” (xem mô tả CS#1).
    - Xem dữ liệu phân công giảng dạy liên quan đến bản thân mình (PHANCONG).
    - Xem dữ liệu trên quan hệ ĐANGKY liên quan đến các lớp học phần mà giảng viên 
    được phân công giảng dạy.
    - Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
    sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. Các
    trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
****************************************************************/
-- 2a. Như một người dùng có vai trò “Nhân viên cơ bản”:
--
-----------------------------------------------------------------
-- Lặp lại việc gán các quyền như quyền của Nhân viên cơ bản 
-- Cần đổi tên View
-----------------------------------------------------------------
-- 1a. Xem dòng dữ liệu của chính mình trong quan hệ NHANSU
-- Sử dụng lại VPD tạo ở CS#1
-- Cấp quyền SELECT trên bảng NHANSU cho Giảng viên.
-- Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT SELECT, UPDATE (DT) ON N09_NHANSU TO N09_RL_GIANGVIEN;
/

-- 1b. Xem thông tin của tất cả SINHVIEN, ĐƠNVỊ, HOCPHAN, KHMO.
-- Gán quyền SELECT cho các bảng gốc
GRANT SELECT ON N09_SINHVIEN TO N09_RL_GIANGVIEN;
GRANT SELECT ON N09_DONVI TO N09_RL_GIANGVIEN;
GRANT SELECT ON N09_HOCPHAN TO N09_RL_GIANGVIEN;
GRANT SELECT ON N09_KHMO TO N09_RL_GIANGVIEN;
/

-- Gán quyền SELECT cho các View tương ứng với các bảng gốc
GRANT SELECT ON UV_N09_SINHVIEN TO N09_RL_GIANGVIEN;
GRANT SELECT ON UV_N09_DONVI TO N09_RL_GIANGVIEN;
GRANT SELECT ON UV_N09_HOCPHAN TO N09_RL_GIANGVIEN;
GRANT SELECT ON UV_N09_KHMO TO N09_RL_GIANGVIEN;/
/


-----------------------------------------------------------------
-- Các quyền riêng cho Giảng viên
-----------------------------------------------------------------
-- 2b. Xem dữ liệu phân công giảng dạy liên quan đến bản thân mình (PHANCONG).
-- Sử dụng VPD trực tiếp lên bảng gốc PHANCONG
CREATE OR REPLACE FUNCTION N09_POLICY_FUNCTION_PHANCONG
(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    USERNAME VARCHAR2(30);
BEGIN
    USERNAME := SYS_CONTEXT('USERENV', 'SESSION_USER');

    -- Các nhân sự có mã NV thuộc về Giảng viên (vd: NV201)
    IF INSTR(USERNAME, 'NV2') > 0 THEN
        RETURN 'MAGV = ''' || USERNAME || '''';
    
    -- Các nhân sự có mã NV thuộc về Trưởng đơn vị (vd: NV101):
    -- Xem dữ liệu phân công giảng dạy của các giảng viên thuộc đơn vị mà mình làm trưởng (4b.)
    -- VÀ các học phần được phụ trách chuyên môn bởi đơn vị mà mình làm trưởng (4c.)
    ELSIF INSTR(USERNAME, 'NV1') > 0 THEN
        RETURN 'MAGV IN (SELECT ns.MANV
                         FROM N09_NHANSU ns
                         JOIN N09_DONVI dv ON ns.MADV = dv.MADV
                         WHERE dv.TRGDV = ''' || USERNAME || ''')
               OR MAHP IN (SELECT hp.MAHP
                           FROM N09_HOCPHAN hp
                           JOIN N09_DONVI dv ON hp.MADV = dv.MADV
                           WHERE dv.TRGDV = ''' || USERNAME || ''')';
    ELSE
        RETURN NULL;
    END IF;
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'C##ADMIN',
        OBJECT_NAME => 'N09_PHANCONG',
        POLICY_NAME => 'N09_POLICY_PHANCONG',
        FUNCTION_SCHEMA => 'C##ADMIN',
        POLICY_FUNCTION => 'N09_POLICY_FUNCTION_PHANCONG',
        STATEMENT_TYPES => 'SELECT'
    );
END;
/

-- Cấp quyền SELECT trên bảng PHANCONG cho Giảng viên
GRANT SELECT ON N09_PHANCONG TO N09_RL_GIANGVIEN;
/

---- Test
--CONN NV201/NV201;
--SELECT * FROM C##ADMIN.N09_PHANCONG;
--/


-- 2c. Xem dữ liệu trên quan hệ ĐANGKY liên quan đến các lớp học phần mà giảng viên được phân công giảng dạy.
-- Sử dụng VPD trực tiếp lên bảng gốc ĐANGKY
-- NOTE: Áp dụng cả UPDATE cho câu 2d.
CREATE OR REPLACE FUNCTION N09_POLICY_FUNCTION_DANGKY
(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    USERNAME VARCHAR2(30);
BEGIN
    USERNAME := SYS_CONTEXT('USERENV', 'SESSION_USER');
    -- Các nhân sự có mã NV thuộc về Giảng viên (vd: NV201)
    IF (INSTR(USERNAME, 'NV2') > 0 OR INSTR(USERNAME, 'NV1') > 0) THEN
        RETURN 'MAGV = ''' || USERNAME || '''';
    ELSE
        RETURN NULL;
    END IF;
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'C##ADMIN',
        OBJECT_NAME => 'N09_DANGKY',
        POLICY_NAME => 'N09_POLICY_DANGKY',
        FUNCTION_SCHEMA => 'C##ADMIN',
        POLICY_FUNCTION => 'N09_POLICY_FUNCTION_DANGKY',
        STATEMENT_TYPES => 'SELECT, UPDATE'
    );
END;
/

-- Cấp quyền SELECT trên bảng ĐANGKY cho Giảng viên
GRANT SELECT ON N09_DANGKY TO N09_RL_GIANGVIEN;
/

-- -- Test
-- CONN NV201/NV201;
-- SELECT * FROM C##ADMIN.N09_DANGKY;
-- /


-- 2d. Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
-- sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. 
-- Các trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
GRANT UPDATE (DIEMTH, DIEMQT, DIEMCK, DIEMTK) ON N09_DANGKY TO N09_RL_GIANGVIEN;
/

---- Test
--CONN NV201/NV201;
---- UPDATE thành công
--UPDATE C##ADMIN.N09_DANGKY SET DIEMTH = 10, DIEMQT = 10, DIEMCK = 10, DIEMTK = 10 WHERE MASV = 'SV001' AND MAHP = 'HP001' AND HK = 1 AND NAM = 2024 AND MACT = 'CQ';
--/
--
--CONN NV201/NV201;
---- UPDATE KHÔNG thành công
--UPDATE C##ADMIN.N09_DANGKY SET DIEMTH = 10, DIEMQT = 10, DIEMCK = 10, DIEMTK = 10 WHERE MASV = 'SV002' AND MAHP = 'HP001' AND HK = 2 AND NAM = 2024 AND MACT = 'CLC';
--/
--
--CONN NV201/NV201;
---- UPDATE KHÔNG thành công
--UPDATE C##ADMIN.N09_DANGKY SET HK = 3 WHERE MASV = 'SV001' AND MAHP = 'HP001' AND HK = 1 AND NAM = 2024 AND MACT = 'CQ';
--/



/***************************************************************
CS#3: Người dùng có VAITRO là “Giáo vụ” có quyền:
    - Như một người dùng có vai trò “Nhân viên cơ bản” (xem mô tả CS#1).
    - Xem, Thêm mới hoặc Cập nhật dữ liệu trên các quan hệ SINHVIEN, ĐONVI,
    HOCPHAN, KHMO, theo yêu cầu của trưởng khoa.
    - Xem dữ liệu trên toàn bộ quan hệ PHANCONG. Tuy nhiên, chỉ được sửa trên các dòng
    dữ liệu phân công liên quan các học phần do “Văn phòng khoa” phụ trách phân công
    giảng dạy, thừa hành người trưởng đơn vị tương ứng là trưởng khoa.
    - Xóa hoặc Thêm mới dữ liệu trên quan hệ ĐANGKY theo yêu cầu của sinh viên trong
    khoảng thời gian còn cho hiệu chỉnh đăng ký.

    * Điều kiện có thể hiệu chỉnh đăng ký: 
    - Sinh viên có thể hiệu chỉnh đăng ký học phần (thêm, xóa) nếu ngày hiện tại 
    không vượt quá 14 ngày so với ngày bắt đầu học kỳ
****************************************************************/
-- 3a. Như một người dùng có vai trò “Nhân viên cơ bản” (xem mô tả CS#1):
--
-----------------------------------------------------------------
-- Lặp lại việc gán các quyền như quyền của Nhân viên cơ bản 
-- Cần đổi tên View
-----------------------------------------------------------------
-- 1a. Xem dòng dữ liệu của chính mình trong quan hệ NHANSU.
-- Sử dụng lại VPD tạo ở CS#1.
-- Cấp quyền SELECT trên bảng NHANSU cho Giáo vụ.
-- Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT SELECT, UPDATE (DT) ON N09_NHANSU TO N09_RL_GIAOVU;
/

-- 1b. Xem thông tin của tất cả SINHVIEN, ĐƠNVỊ, HOCPHAN, KHMO.
-- Gán quyền SELECT cho các bảng gốc
GRANT SELECT ON N09_SINHVIEN TO N09_RL_GIAOVU;
GRANT SELECT ON N09_DONVI TO N09_RL_GIAOVU;
GRANT SELECT ON N09_HOCPHAN TO N09_RL_GIAOVU;
GRANT SELECT ON N09_KHMO TO N09_RL_GIAOVU;
/

-- Gán quyền SELECT cho các View tương ứng với các bảng gốc
GRANT SELECT ON UV_N09_SINHVIEN TO N09_RL_GIAOVU;
GRANT SELECT ON UV_N09_DONVI TO N09_RL_GIAOVU;
GRANT SELECT ON UV_N09_HOCPHAN TO N09_RL_GIAOVU;
GRANT SELECT ON UV_N09_KHMO TO N09_RL_GIAOVU;
/


-----------------------------------------------------------------
-- Các quyền riêng cho Giáo vụ
-----------------------------------------------------------------
-- 3b. Xem, Thêm mới hoặc Cập nhật dữ liệu trên các quan hệ SINHVIEN, ĐONVI,
-- HOCPHAN, KHMO, theo yêu cầu của trưởng khoa.
GRANT SELECT, INSERT, UPDATE ON N09_SINHVIEN TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, UPDATE ON N09_DONVI TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, UPDATE ON N09_HOCPHAN TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, UPDATE ON N09_KHMO TO N09_RL_GIAOVU;
/

-- 3c. Xem dữ liệu trên toàn bộ quan hệ PHANCONG. Tuy nhiên, chỉ được sửa trên các dòng
-- dữ liệu phân công liên quan các học phần do “Văn phòng khoa” phụ trách phân công
-- giảng dạy, thừa hành người trưởng đơn vị tương ứng là trưởng khoa.
--
-- Trigger khi Update vào bảng PHANCONG bởi Giáo vụ
CREATE OR REPLACE TRIGGER N09_TRG_UPDATE_PHANCONG
BEFORE UPDATE ON N09_PHANCONG
FOR EACH ROW
DECLARE
    l_count NUMBER;
    USERNAME VARCHAR2(30);
BEGIN
    USERNAME := SYS_CONTEXT('USERENV', 'SESSION_USER');
    -- Các nhân sự có mã NV thuộc về Giáo vụ (vd: NV301)
    IF (INSTR(USERNAME, 'NV3') > 0) THEN    
        -- Kiểm tra nếu học phần thuộc đơn vị "Văn phòng khoa"
        SELECT COUNT(*)
        INTO l_count
        FROM N09_HOCPHAN hp
        JOIN N09_DONVI dv ON hp.MADV = dv.MADV
        WHERE hp.MAHP = :NEW.MAHP
          AND dv.TENDV = 'Văn phòng khoa';
        
        IF l_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Bạn không có quyền cập nhật dữ liệu phân công này vì học phần này không thuộc đơn vị Văn phòng khoa.');
        END IF;
    END IF;
END;
/

-- Cấp quyền SELECT, UPDATE trên bảng PHANCONG cho Giáo vụ
GRANT SELECT, UPDATE ON UV_N09_PHANCONG TO N09_RL_GIAOVU;
GRANT SELECT, UPDATE ON N09_PHANCONG TO N09_RL_GIAOVU;
/

-- -- Test
-- -- Xem dữ liệu trên toàn bộ quan hệ PHANCONG: Thành công
-- CONN NV301/NV301;
-- SELECT * FROM C##ADMIN.N09_PHANCONG;
-- /

-- NOTE: Khó test UPDATE vì ràng buộc khóa ngoại liên tiếp


-- 3d. Xóa hoặc Thêm mới dữ liệu trên quan hệ ĐANGKY theo yêu cầu của sinh viên trong
-- khoảng thời gian còn cho hiệu chỉnh đăng ký
-- 
-- * Điều kiện: 
--   - Sinh viên có thể hiệu chỉnh đăng ký học phần (thêm, xóa) nếu ngày hiện tại 
--   không vượt quá 14 ngày so với ngày bắt đầu học kỳ
--
-- * Lưu ý: Mỗi năm học có 3 học kỳ (HK) bắt đầu tương ứng vào ngày đầu tiên các tháng 1, 5, 9.
--
-- Cấp quyền SELECT, INSERT, DELETE trên bảng ĐANGKY cho Giáo vụ
GRANT SELECT, INSERT, DELETE ON UV_N09_DANGKY TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, DELETE ON N09_DANGKY TO N09_RL_GIAOVU;
/

-- Tạo Trigger khi Insert vào bảng DANGKY bởi Giáo vụ
CREATE OR REPLACE TRIGGER N09_TRG_MANAGE_DANGKY_BY_GIAOVU
BEFORE INSERT OR DELETE ON N09_DANGKY
FOR EACH ROW
DECLARE
    l_role_count NUMBER;
    l_start_date DATE;
    l_current_date DATE := SYSDATE;
BEGIN
    -- Kiểm tra nếu người dùng hiện tại là Giáo vụ
    SELECT COUNT(*)
    INTO l_role_count
    FROM N09_NHANSU
    WHERE MANV = SYS_CONTEXT('userenv', 'session_user')
      AND VAITRO = 'Giáo vụ';

    IF l_role_count > 0 THEN
        -- Xác định ngày bắt đầu học kỳ dựa trên giá trị của HK và thao tác (INSERT hoặc DELETE)
        IF INSERTING THEN
            IF :NEW.HK = 1 THEN
                l_start_date := TO_DATE(:NEW.NAM || '-01-01', 'YYYY-MM-DD');
            ELSIF :NEW.HK = 2 THEN
                l_start_date := TO_DATE(:NEW.NAM || '-05-01', 'YYYY-MM-DD');
            ELSIF :NEW.HK = 3 THEN
                l_start_date := TO_DATE(:NEW.NAM || '-09-01', 'YYYY-MM-DD');
            ELSE
                RAISE_APPLICATION_ERROR(-20005, 'Giá trị học kỳ không hợp lệ.');
            END IF;
        ELSIF DELETING THEN
            IF :OLD.HK = 1 THEN
                l_start_date := TO_DATE(:OLD.NAM || '-01-01', 'YYYY-MM-DD');
            ELSIF :OLD.HK = 2 THEN
                l_start_date := TO_DATE(:OLD.NAM || '-05-01', 'YYYY-MM-DD');
            ELSIF :OLD.HK = 3 THEN
                l_start_date := TO_DATE(:OLD.NAM || '-09-01', 'YYYY-MM-DD');
            ELSE
                RAISE_APPLICATION_ERROR(-20005, 'Giá trị học kỳ không hợp lệ.');
            END IF;
        END IF;

        -- Kiểm tra nếu ngày hiện tại không vượt quá 14 ngày so với ngày bắt đầu học kỳ
        IF l_current_date > l_start_date + 14 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Không thể thực hiện thao tác vì đã quá thời gian hiệu chỉnh đăng ký.');
        END IF;
    END IF;
END;
/

---- Test
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_DANGKY;
--/
--
--CONN NV301/NV301;
---- INSERT KHÔNG thành công
--INSERT INTO C##ADMIN.N09_DANGKY(MASV, MAGV, MAHP, HK, NAM, MACT) VALUES('SV001', 'NV202', 'HP002', 2, 2024, 'CLC');
--/
---- INSERT thành công
--INSERT INTO C##ADMIN.N09_DANGKY(MASV, MAGV, MAHP, HK, NAM, MACT) VALUES('SV001', 'NV217', 'HP006', 3, 2024, 'CLC');
--/
----------
--CONN NV301/NV301;
---- DELETE KHÔNG thành công
--DELETE FROM C##ADMIN.N09_DANGKY WHERE MASV = 'SV001' AND MAGV = 'NV201' AND MAHP = 'HP001' AND HK = 1 AND NAM = 2024 AND MACT = 'CQ';
--/
---- DELETE thành công
--DELETE FROM C##ADMIN.N09_DANGKY WHERE MASV = 'SV001' AND MAGV = 'NV217' AND MAHP = 'HP006' AND HK = 3 AND NAM = 2024 AND MACT = 'CLC';
--/



/***************************************************************
CS#4: Người dùng có VAITRO là “Trưởng đơn vị”, gồm trưởng các bộ môn (không bao
gồm trưởng khoa), có quyền truy cập dữ liệu:
    - Như một người dùng có vai trò “Giảng viên” (xem mô tả CS#2).
    - Thêm, Xóa, Cập nhật dữ liệu trên quan hệ PHANCONG, đối với các học phần được
    phụ trách chuyên môn bởi đơn vị mà mình làm trưởng
    - Được xem dữ liệu phân công giảng dạy của các giảng viên thuộc các đơn vị 
    mà mình làm trưởng.
****************************************************************/
-- 4a. Như một người dùng có vai trò “Giảng viên” (xem mô tả CS#2):
--
-----------------------------------------------------------------
-- A. Lặp lại việc gán các quyền như quyền của Nhân viên cơ bản 
-- Cần đổi tên View
-----------------------------------------------------------------
-- 1a. Xem dòng dữ liệu của chính mình trong quan hệ NHANSU
-- Sử dụng lại VPD tạo ở CS#1
-- Cấp quyền SELECT trên bảng NHANSU cho Trưởng đơn vị.
-- Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT SELECT, UPDATE (DT) ON N09_NHANSU TO N09_RL_TRUONG_DONVI;
/

---- Test
---- Trưởng đơn vị NV102 đảm nhiệm 2 đơn vị DV003 & DV007
---- Xem thông tin của các nhân sự thuộc đơn vị mình làm trưởng: Thành công (30 rows)
--CONN NV102/NV102;
--SELECT * FROM C##ADMIN.N09_NHANSU;
--/

-- 1b. Xem thông tin của tất cả SINHVIEN, ĐƠNVỊ, HOCPHAN, KHMO.
-- Gán quyền SELECT cho các bảng gốc
GRANT SELECT ON N09_SINHVIEN TO N09_RL_TRUONG_DONVI;
GRANT SELECT ON N09_DONVI TO N09_RL_TRUONG_DONVI;
GRANT SELECT ON N09_HOCPHAN TO N09_RL_TRUONG_DONVI;
GRANT SELECT ON N09_KHMO TO N09_RL_TRUONG_DONVI;
/

-- Gán quyền SELECT cho các View tương ứng với các bảng gốc
GRANT SELECT ON UV_N09_SINHVIEN TO N09_RL_TRUONG_DONVI;
GRANT SELECT ON UV_N09_DONVI TO N09_RL_TRUONG_DONVI;
GRANT SELECT ON UV_N09_HOCPHAN TO N09_RL_TRUONG_DONVI;
GRANT SELECT ON UV_N09_KHMO TO N09_RL_TRUONG_DONVI;
/


-----------------------------------------------------------------
-- B. Lặp lại việc gán các quyền như quyền của Giảng viên
-- Cần đổi tên View
-----------------------------------------------------------------
-- 2b. Xem dữ liệu phân công giảng dạy liên quan đến bản thân mình (PHANCONG).
-- <NOTE>
-- Không cấp quyền giống với Giảng viên vì Trưởng đơn vị có kiểu xem khác (xem mục 4c. bên dưới)
-- </NOTE>

-- 2c. Xem dữ liệu trên quan hệ ĐANGKY liên quan đến các lớp học phần mà giảng viên được phân công giảng dạy.
-- <NOTE>
-- Vì Trưởng đơn vị không tham gia giảng dạy (không có MAGV) nên khi xem View/Table này sẽ không có dữ liệu.
-- </NOTE>
GRANT SELECT ON UV_N09_DANGKY TO N09_RL_TRUONG_DONVI;
GRANT SELECT ON N09_DANGKY TO N09_RL_TRUONG_DONVI;
/

---- Test
---- Xem dữ liệu trên quan hệ ĐANGKY: Không có dữ liệu
--CONN NV101/NV101;
--SELECT * FROM C##ADMIN.N09_DANGKY
--/

-- 2d. Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
-- sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. 
-- Các trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
-- <NOTE>
-- Vì Trưởng đơn vị không tham gia giảng dạy (không có MAGV) nên sẽ không có dữ liệu khi cập nhật View này.
-- </NOTE>
GRANT UPDATE (DIEMTH, DIEMQT, DIEMCK, DIEMTK) ON N09_DANGKY TO N09_RL_TRUONG_DONVI;
/

---- Test
---- Cập nhật dữ liệu trên quan hệ ĐANGKY: Không thành công
--CONN NV101/NV101;
--UPDATE C##ADMIN.N09_DANGKY SET DIEMTH = 10, DIEMQT = 10, DIEMCK = 10, DIEMTK = 10 WHERE MASV = 'SV001' AND MAHP = 'HP001' AND HK = 1 AND NAM = 2024 AND MACT = 'CQ';
--/


-----------------------------------------------------------------
-- Các quyền riêng cho Trưởng đơn vị
-----------------------------------------------------------------
-- 4c. Được xem dữ liệu phân công giảng dạy của các giảng viên mà mình làm trưởng.
GRANT SELECT ON N09_PHANCONG TO N09_RL_TRUONG_DONVI;
/

---- Test
--CONN NV102/NV102;
--SELECT * FROM C##ADMIN.N09_PHANCONG;
--/


-- 4b. Thêm, Xóa, Cập nhật dữ liệu trên quan hệ PHANCONG, đối với các học phần được
-- phụ trách chuyên môn bởi đơn vị mà mình làm trưởng
--
-- Tạo Trigger khi Insert, Delete, Update vào bảng PHANCONG
CREATE OR REPLACE TRIGGER N09_TRG_MANAGE_PHANCONG_BY_TRUONGDONVI
BEFORE INSERT OR DELETE OR UPDATE ON N09_PHANCONG
FOR EACH ROW
DECLARE
    l_is_truongdonvi NUMBER;
    l_count NUMBER;
BEGIN
    -- Kiểm tra nếu người dùng hiện tại là Trưởng đơn vị
    SELECT COUNT(*)
    INTO l_is_truongdonvi
    FROM N09_NHANSU
    WHERE MANV = SYS_CONTEXT('userenv', 'session_user')
      AND VAITRO = 'Trưởng đơn vị';

    IF l_is_truongdonvi > 0 THEN
        IF UPDATING THEN
            -- Kiểm tra khi UPDATE
            SELECT COUNT(*)
            INTO l_count
            FROM N09_HOCPHAN hp
            JOIN N09_DONVI dv ON hp.MADV = dv.MADV
            WHERE hp.MAHP = :NEW.MAHP
              AND dv.TRGDV = SYS_CONTEXT('userenv', 'session_user');
            
            IF l_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác UPDATE vì học phần này không thuộc đơn vị của bạn.');
            END IF;
            
        ELSIF INSERTING THEN
            -- Kiểm tra khi INSERT
            SELECT COUNT(*)
            INTO l_count
            FROM N09_HOCPHAN hp
            JOIN N09_DONVI dv ON hp.MADV = dv.MADV
            WHERE hp.MAHP = :NEW.MAHP
              AND dv.TRGDV = SYS_CONTEXT('userenv', 'session_user');
            
            IF l_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác INSERT vì học phần này không thuộc đơn vị của bạn.');
            END IF;
            
        ELSIF DELETING THEN
            -- Kiểm tra khi DELETE
            SELECT COUNT(*)
            INTO l_count
            FROM N09_HOCPHAN hp
            JOIN N09_DONVI dv ON hp.MADV = dv.MADV
            WHERE hp.MAHP = :OLD.MAHP
              AND dv.TRGDV = SYS_CONTEXT('userenv', 'session_user');
            
            IF l_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác DELETE vì học phần này không thuộc đơn vị của bạn.');
            END IF;
        END IF;  
    END IF;    
END;
/

GRANT INSERT, DELETE, UPDATE ON N09_PHANCONG TO N09_RL_TRUONG_DONVI;
/

---- Test
--CONN NV102/NV102;
--SELECT * FROM C##ADMIN.N09_PHANCONG;
--/
--
---- INSERT KHÔNG thành công
--CONN NV102/NV102;
--INSERT INTO C##ADMIN.N09_PHANCONG VALUES('NV205', 'HP002', 2, 2024, 'CLC');
--/
--
---- INSERT thành công
--CONN NV102/NV102;
--INSERT INTO C##ADMIN.N09_PHANCONG VALUES('NV220', 'HP003', 1, 2024, 'CQ');
--/
--
---- DELETE KHÔNG thành công
--CONN NV102/NV102;
--DELETE FROM C##ADMIN.N09_PHANCONG WHERE MAGV = 'NV202' AND MAHP = 'HP002' AND HK = 2 AND NAM = 2024 AND MACT = 'CLC';
--/
--
--CONN NV102/NV102;
---- DELETE thành công
--DELETE FROM C##ADMIN.N09_PHANCONG WHERE MAGV = 'NV220' AND MAHP = 'HP003' AND HK = 1 AND NAM = 2024 AND MACT = 'CQ';
--/




/***************************************************************
CS#5: Người dùng có VAITRO là “Trưởng khoa” có quyền hạn:
    - Như một người dùng có vai trò “Giảng viên”
    - Thêm, Xóa, Cập nhật dữ liệu trên quan hệ PHANCONG đối với các học phần 
    quản lý bởi đơn vị “Văn phòng khoa”.
    - Được quyền Xem, Thêm, Xóa, Cập nhật trên quan hệ NHANSU.
    - Được quyền Xem (không giới hạn) dữ liệu trên toàn bộ lược đồ CSDL.
****************************************************************/
-- Như một người dùng có vai trò “Giảng viên”:
--
-----------------------------------------------------------------
-- A. Lặp lại việc gán các quyền như quyền của Nhân viên cơ bản 
-- Cần đổi tên View
-----------------------------------------------------------------
-- <NOTE>
-- Vì Trưởng khoa Được quyền Xem (không giới hạn) dữ liệu trên toàn bộ lược đồ CSDL.
-- Nên chỉ cấp các quyền trên TABLE khác SELECT cho Trưởng khoa.
-- </NOTE>
--
-- 1a. Xem dòng dữ liệu (KHÔNG CHỈ RIÊNG của chính mình) trong quan hệ NHANSU
GRANT SELECT ON N09_NHANSU TO N09_RL_TRUONG_KHOA;
/

---- Test
---- Xem TOÀN BỘ dữ liệu trên quan hệ NHANSU: Thành công
--CONN NV001/NV001;
--SELECT * FROM C##ADMIN.N09_NHANSU;
--/


-- 1a.(cont). Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
-- <NOTE>
-- A. Vì Trưởng khoa CÓ TOÀN QUYỀN thao tác dữ liệu trên bảng NHANSU nên không cần kiểm tra cột DT.
-- </NOTE>
GRANT UPDATE (DT) ON N09_NHANSU TO N09_RL_TRUONG_KHOA;
/

---- Test
---- Xem TOÀN BỘ dữ liệu trên quan hệ NHANSU: Thành công
--CONN NV001/NV001;
--SELECT * FROM C##ADMIN.N09_NHANSU;
--/
--
---- UPDATE SDT của chính mình: Thành công
--CONN NV001/NV001;
--UPDATE C##ADMIN.N09_NHANSU SET DT = '0987654321' WHERE MANV = 'NV001';
--/


-----------------------------------------------------------------
-- B. Lặp lại việc gán các quyền như quyền của Giảng viên
-- Cần đổi tên View
-----------------------------------------------------------------
-- 2b. Xem dữ liệu phân công giảng dạy.
GRANT SELECT ON N09_PHANCONG TO N09_RL_TRUONG_KHOA;
/

-- 2c. Xem dữ liệu trên quan hệ ĐANGKY.
GRANT SELECT ON N09_DANGKY TO N09_RL_TRUONG_KHOA;
/

-- 2d. Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
-- sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. 
-- Các trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
GRANT UPDATE (DIEMTH, DIEMQT, DIEMCK, DIEMTK) ON N09_DANGKY TO N09_RL_TRUONG_KHOA;
/


-----------------------------------------------------------------
-- Các quyền riêng cho Trưởng khoa
-----------------------------------------------------------------
-- 5b. Thêm, Xóa, Cập nhật dữ liệu trên quan hệ PHANCONG đối với các học phần quản lý bởi đơn vị “Văn phòng khoa”.
-- Tạo Trigger khi Insert, Delete, Update vào bảng PHANCONG
CREATE OR REPLACE TRIGGER N09_TRG_MANAGE_PHANCONG_BY_TRUONGKHOA
BEFORE INSERT OR DELETE OR UPDATE ON N09_PHANCONG
FOR EACH ROW
DECLARE
    l_role_count NUMBER;
    l_count NUMBER;
BEGIN
    -- Kiểm tra nếu người dùng hiện tại là Trưởng khoa
    SELECT COUNT(*)
    INTO l_role_count
    FROM N09_NHANSU
    WHERE MANV = SYS_CONTEXT('userenv', 'session_user')
      AND VAITRO = 'Trưởng khoa';

    IF l_role_count > 0 THEN
        IF INSERTING THEN
            -- Kiểm tra khi INSERT
            SELECT COUNT(*)
            INTO l_count
            FROM N09_HOCPHAN hp
            JOIN N09_DONVI dv ON hp.MADV = dv.MADV
            WHERE hp.MAHP = :NEW.MAHP
              AND dv.TENDV = 'Văn phòng khoa';

            IF l_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác INSERT vì học phần này không thuộc đơn vị Văn phòng khoa.');
            END IF;

        ELSIF UPDATING THEN
            -- Kiểm tra khi UPDATE
            SELECT COUNT(*)
            INTO l_count
            FROM N09_HOCPHAN hp
            JOIN N09_DONVI dv ON hp.MADV = dv.MADV
            WHERE hp.MAHP = :NEW.MAHP
              AND dv.TENDV = 'Văn phòng khoa';

            IF l_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác UPDATE vì học phần này không thuộc đơn vị Văn phòng khoa.');
            END IF;

        ELSIF DELETING THEN
            -- Kiểm tra khi DELETE
            SELECT COUNT(*)
            INTO l_count
            FROM N09_HOCPHAN hp
            JOIN N09_DONVI dv ON hp.MADV = dv.MADV
            WHERE hp.MAHP = :OLD.MAHP
              AND dv.TENDV = 'Văn phòng khoa';

            IF l_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác DELETE vì học phần này không thuộc đơn vị Văn phòng khoa.');
            END IF;
        END IF;
    END IF;
END;
/

-- Cấp quyền INSERT, DELETE, UPDATE trên bảng PHANCONG cho Trưởng khoa
GRANT INSERT, DELETE, UPDATE ON N09_PHANCONG TO N09_RL_TRUONG_KHOA;
/

---- Test
---- Xem dữ liệu trên toàn bộ quan hệ PHANCONG: Thành công
--CONN NV001/NV001;
--SELECT * FROM C##ADMIN.N09_PHANCONG;
--/
--
---- Thêm dữ liệu vào quan hệ PHANCONG: Không thành công
---- Giải thích: Văn phòng khoa thuộc Đơn vị DV001 & Học phần HP004 thuộc DV004 nên không thể thực hiện thao tác INSERT
--CONN NV001/NV001;
--INSERT INTO C##ADMIN.N09_PHANCONG VALUES('NV210', 'HP004', 3, 2024, 'CQ');
--/
--
---- Xóa dữ liệu trên quan hệ PHANCONG: Không thành công
---- Giải thích: Như trên
--CONN NV001/NV001;
--DELETE FROM C##ADMIN.N09_PHANCONG WHERE MAGV = 'NV210' AND MAHP = 'HP004';
--/
--
---- Thêm dữ liệu vào quan hệ PHANCONG: Thành công
---- Giải thích: Học phần HP001 thuộc DV001 nên có thể thực hiện thao tác INSERT
--CONN NV001/NV001;
--INSERT INTO C##ADMIN.N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT) VALUES ('NV210', 'HP001', 1, 2024, 'CQ');
--/
--
---- Xóa dữ liệu trên quan hệ PHANCONG: Thành công (2 rows)
---- Giải thích: Học phần HP001 thuộc DV001 nên có thể thực hiện thao tác DELETE
--CONN NV001/NV001;
--DELETE FROM C##ADMIN.N09_PHANCONG WHERE MAGV = 'NV210' AND MAHP = 'HP001';
--/
--
---- Cập nhật dữ liệu (tương tự)



-- 5c. Được quyền Xem, Thêm, Xóa, Cập nhật trên quan hệ NHANSU.
GRANT SELECT, INSERT, DELETE, UPDATE ON UV_N09_NHANSU TO N09_RL_TRUONG_KHOA;
GRANT SELECT, INSERT, DELETE, UPDATE ON N09_NHANSU TO N09_RL_TRUONG_KHOA;
/

-- 5d. Được quyền Xem (không giới hạn) dữ liệu trên toàn bộ lược đồ CSDL.
-- Gán quyền SELECT cho các bảng gốc
GRANT SELECT ON N09_NHANSU TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_SINHVIEN TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_DONVI TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_HOCPHAN TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_KHMO TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_PHANCONG TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_DANGKY TO N09_RL_TRUONG_KHOA;
/

-- Gán quyền SELECT cho các View tương ứng với các bảng gốc
GRANT SELECT ON UV_N09_NHANSU TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON UV_N09_SINHVIEN TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON UV_N09_DONVI TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON UV_N09_HOCPHAN TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON UV_N09_KHMO TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON UV_N09_PHANCONG TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON UV_N09_DANGKY TO N09_RL_TRUONG_KHOA;
/




/***************************************************************
CS#6: Người dùng có VAITRO là “Sinh viên” có quyền hạn:
    - Trên quan hệ SINHVIEN, sinh viên chỉ được xem thông tin của chính mình, được
    Chỉnh sửa thông tin địa chỉ (ĐCHI) và số điện thoại liên lạc (ĐT) của chính sinh viên.
    - Xem danh sách tất cả học phần (HOCPHAN), kế hoạch mở môn (KHMO) của chương
    trình đào tạo mà sinh viên đang theo học.
    - Thêm, Xóa các dòng dữ liệu đăng ký học phần (ĐANGKY) liên quan đến chính sinh
    viên đó trong học kỳ của năm học hiện tại (nếu thời điểm hiệu chỉnh đăng ký còn hợp
    lệ).
    - Sinh viên không được chỉnh sửa trên các trường liên quan đến điểm.
    - Sinh viên được Xem tất cả thông tin trên quan hệ ĐANGKY tại các dòng dữ liệu liên
    quan đến chính sinh viên.

    * LƯU Ý: 
        Sinh viên có thể hiệu chỉnh đăng ký học phần (thêm, xóa) nếu ngày hiện tại không vượt quá
        14 ngày so với ngày bắt đầu học kỳ (xem thêm thông tin về học kỳ trong quan hệ KHMO)
        mà sinh viên đang hiệu chỉnh đăng ký học phần.

    * YÊU CẦU BẮT BUỘC: CS#6 sử dụng cơ chế VPD của Oracle để cài đặt.
****************************************************************/
-- 6a. Trên quan hệ SINHVIEN, sinh viên chỉ được xem thông tin của chính mình,
-- Chỉnh sửa thông tin địa chỉ (ĐCHI) và số điện thoại liên lạc (ĐT) của chính sinh viên.
CREATE OR REPLACE FUNCTION N09_POLICY_FUNCTION_SINHVIEN
(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    USER VARCHAR(100);
BEGIN 
    USER:= SYS_CONTEXT('USERENV','SESSION_USER');
    IF INSTR(USER, 'SV') > 0 THEN
        RETURN 'MASV = ''' || USER || '''';
    ELSE
        RETURN NULL;
    END IF;
END;
/

BEGIN 
    DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA      => 'C##ADMIN',
        OBJECT_NAME        => 'N09_SINHVIEN',
        POLICY_NAME        => 'N09_POLICY_SINHVIEN',
        POLICY_FUNCTION    => 'N09_POLICY_FUNCTION_SINHVIEN',
        STATEMENT_TYPES    => 'UPDATE, SELECT',
        SEC_RELEVANT_COLS  => 'DIACHI, DT',
        UPDATE_CHECK       => TRUE
    );
END;
/

-- Trigger kiểm tra cột mà sinh viên không được phép cập nhật
CREATE OR REPLACE TRIGGER N09_TRG_UPDATE_SINHVIEN
BEFORE UPDATE ON C##ADMIN.N09_SINHVIEN
FOR EACH ROW
BEGIN
    IF INSTR(SYS_CONTEXT('USERENV','SESSION_USER'), 'SV') > 0 THEN
        -- Kiểm tra nếu sinh viên cập nhật các cột ngoài DIACHI và DT
        IF UPDATING('HOTEN') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Bạn không được phép chỉnh sửa Họ Tên');
        END IF;
        IF UPDATING('MASV') THEN
            RAISE_APPLICATION_ERROR(-20002, 'Bạn không được phép chỉnh sửa Mã Sinh Viên');
        END IF;
        IF UPDATING('PHAI') THEN
            RAISE_APPLICATION_ERROR(-20003, 'Bạn không được phép chỉnh sửa Giới Tính');
        END IF;
        IF UPDATING('NGSINH') THEN
            RAISE_APPLICATION_ERROR(-20004, 'Bạn không được phép chỉnh sửa cột Ngày Sinh');
        END IF;
        IF UPDATING('MACT') THEN
            RAISE_APPLICATION_ERROR(-20005, 'Bạn không được phép chỉnh sửa cột Chương Trình Học');
        END IF;
    END IF;
END;
/

-- Gán quyền SELECT, UPDATE trên bảng SINHVIEN cho sinh viên
GRANT SELECT, UPDATE ON C##ADMIN.N09_SINHVIEN TO N09_RL_SINHVIEN;
/

---- TEST
---- Xem bảng SINHVIEN liên quan đến bản thân: Thành công
--CONN SV001/SV001;
--SELECT * FROM C##ADMIN.N09_SINHVIEN;
--/
--
---- Cập nhật HOTEM: Không thành công
--CONN SV001/SV001;
--UPDATE C##ADMIN.N09_SINHVIEN 
--SET hoten = 'Nguyen Thi Lan'
--WHERE MASV = 'SV001';
--/
--
---- Cập nhật DT: Thành công
--CONN SV001/SV001;
--UPDATE C##ADMIN.N09_SINHVIEN 
--SET DT = '1234'
--WHERE MASV = 'SV001';
--/


-- 6b. Xem danh sách kế hoạch mở môn (KHMO) của chương
-- trình đào tạo mà sinh viên đang theo học.
CREATE OR REPLACE FUNCTION N09_POLICY_FUNCTION_KHMO
(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    MA VARCHAR2(5);
    USER VARCHAR2(100);
BEGIN 
    USER:= SYS_CONTEXT('USERENV','SESSION_USER');
    
    IF INSTR(USER, 'SV') > 0 THEN        
        SELECT MACT
        INTO MA
        FROM N09_SINHVIEN
        WHERE MASV = USER;
    
        RETURN 'MACT = ''' || MA || '''';
    ELSE
        RETURN NULL;
    END IF;
END; 
/

BEGIN 
DBMS_RLS.ADD_POLICY(
    OBJECT_SCHEMA => 'C##ADMIN',
    OBJECT_NAME => 'N09_KHMO',
    POLICY_NAME => 'N09_POLICY_KHMO',
    POLICY_FUNCTION => 'N09_POLICY_FUNCTION_KHMO',
    STATEMENT_TYPES => 'SELECT'
);
END;
/

-- Cấp quyền SELECT trên bảng KHMO cho sinh viên
GRANT SELECT ON C##ADMIN.N09_KHMO TO N09_RL_SINHVIEN;
/

---- TEST
--CONN SV001/SV001;
--SELECT * FROM C##ADMIN.N09_KHMO;
--/


-- 6b.(cont). Xem danh sách tất cả học phần (HOCPHAN) của chương
-- trình đào tạo mà sinh viên đang theo học.
CREATE OR REPLACE FUNCTION N09_POLICY_FUNCTION_HOCPHAN
(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    MACT VARCHAR2(5);
    USER VARCHAR(100);
    STRSQL VARCHAR2(2000);
BEGIN 
    USER:= SYS_CONTEXT('USERENV','SESSION_USER');
    IF INSTR(USER, 'SV') > 0 THEN
        -- Lấy mã chương trình của sinh viên
        SELECT MACT INTO MACT
        FROM N09_SINHVIEN
        WHERE MASV = USER;
        
        -- Xây dựng chuỗi điều kiện để lọc các học phần của chương trình
        STRSQL := 'MAHP IN (SELECT MAHP FROM N09_KHMO WHERE MACT = ''' || MACT || ''')';
        RETURN STRSQL;
    ELSE
        RETURN NULL;
    END IF;
END; 
/

BEGIN 
DBMS_RLS.ADD_POLICY(
    OBJECT_SCHEMA => 'C##ADMIN',
    OBJECT_NAME => 'N09_HOCPHAN',
    POLICY_NAME => 'N09_POLICY_HOCPHAN',
    POLICY_FUNCTION => 'N09_POLICY_FUNCTION_HOCPHAN',
    STATEMENT_TYPES => 'SELECT'
);
END;
/

-- Cấp quyền SELECT trên bảng HOCPHAN cho sinh viên
GRANT SELECT ON C##ADMIN.N09_HOCPHAN TO N09_RL_SINHVIEN;
/

---- TEST
--CONN SV001/SV001;
--SELECT * FROM C##ADMIN.N09_HOCPHAN;
--/


-- 6e. Sinh viên được Xem tất cả thông tin trên quan hệ ĐANGKY 
-- tại các dòng dữ liệu liên quan đến chính sinh viên
--
-- Sử dụng VPD trực tiếp lên bảng gốc ĐANGKY
-- NOTE: REPLACE Function từ CS#2
CREATE OR REPLACE FUNCTION N09_POLICY_FUNCTION_DANGKY
(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    USERNAME VARCHAR2(30);
BEGIN
    USERNAME := SYS_CONTEXT('USERENV', 'SESSION_USER');
    
    -- Các Nhân sự có mã NV thuộc về Giảng viên (vd: NV201)
    IF (INSTR(USERNAME, 'NV2') > 0 OR INSTR(USERNAME, 'NV1') > 0) THEN
        RETURN 'MAGV = ''' || USERNAME || '''';
        
    -- Các Sinh viên có mã SV (vd: SV01)
    ELSIF INSTR(USER, 'SV') > 0 THEN
        RETURN 'MASV = ''' || USER || '''';
    ELSE
        RETURN NULL;
    END IF;
END;
/

-- Drop Policy cùng tên ở CS#2 và tạo lại
BEGIN
    DBMS_RLS.DROP_POLICY(
        OBJECT_SCHEMA => 'C##ADMIN',
        OBJECT_NAME => 'N09_DANGKY',
        POLICY_NAME => 'N09_POLICY_DANGKY'
    );
END;
/

BEGIN 
    DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA      => 'C##ADMIN',
        OBJECT_NAME        => 'N09_DANGKY',
        POLICY_NAME        => 'N09_POLICY_DANGKY',
        POLICY_FUNCTION    => 'N09_POLICY_FUNCTION_DANGKY',
        STATEMENT_TYPES => 'SELECT, UPDATE',
        SEC_RELEVANT_COLS => 'DIEMTH, DIEMQT, DIEMCK, DIEMTK'
    );
END;
/

-- Cấp quyền SELECT trên bảng DANGKY cho sinh viên
GRANT SELECT ON C##ADMIN.N09_DANGKY TO N09_RL_SINHVIEN;

---- TEST
--CONN SV001/SV001;
--SELECT * FROM C##ADMIN.N09_DANGKY;
--/



-- 6d. Sinh viên không được chỉnh sửa trên các trường liên quan đến điểm (DANGKY).
CREATE OR REPLACE FUNCTION N09_POLICY_FUNCTION_UPDATE_DANGKY
(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    USER_NAME VARCHAR2(100);
BEGIN 
    USER_NAME := SYS_CONTEXT('USERENV', 'SESSION_USER');
    IF INSTR(USER_NAME, 'SV') > 0 THEN
        -- Trả về điều kiện sai để ngăn chặn cập nhật
        RETURN '1=2';
    ELSE
        RETURN NULL;
    END IF;
END;
/

BEGIN 
    DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'C##ADMIN',
        OBJECT_NAME => 'N09_DANGKY',
        POLICY_NAME => 'N09_POLICY_UPDATE_DANGKY',
        POLICY_FUNCTION => 'N09_POLICY_FUNCTION_UPDATE_DANGKY',
        STATEMENT_TYPES => 'UPDATE',
        SEC_RELEVANT_COLS => 'DIEMTH, DIEMQT, DIEMCK, DIEMTK',
        UPDATE_CHECK => TRUE
    );
END;
/

-- Cấp quyền UPDATE trên bảng DANGKY cho sinh viên
GRANT UPDATE ON C##ADMIN.N09_DANGKY TO SV001;
/

---- TEST 
--CONN SV001/SV001;
--SELECT * FROM C##ADMIN.N09_DANGKY;
--/
--
---- Cập nhật điểm: Không thành công
--CONN SV001/SV001;
--UPDATE C##ADMIN.N09_DANGKY
--SET DIEMTH = 10
--WHERE MASV = 'SV001';
--/


-- 6c. Thêm, Xóa các dòng dữ liệu đăng ký học phần (ĐANGKY) liên quan đến chính sinh
-- viên đó trong học kỳ của năm học hiện tại (nếu thời điểm hiệu chỉnh đăng ký còn hợp lệ).
CREATE OR REPLACE FUNCTION N09_POLICY_FUNCTION_INSERT_DELETE_DANGKY
(P_SCHEMA VARCHAR2, P_OBJ VARCHAR2)
RETURN VARCHAR2
AS
    USER VARCHAR2(100);
    HK NUMBER(1);
    NGAY NUMBER(2);
    THANG NUMBER(2);
    NAM NUMBER(4);

BEGIN 
    USER:= SYS_CONTEXT('USERENV','SESSION_USER');
    IF INSTR(USER, 'SV') > 0 THEN

        NGAY := TO_NUMBER(TO_CHAR(SYSDATE, 'DD'));
        THANG := TO_NUMBER(TO_CHAR(SYSDATE, 'MM'));
        NAM := TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'));

        IF NGAY >= 1 AND NGAY <= 14 THEN
            IF THANG = 1 THEN
                HK := 1;
            ELSIF THANG = 5 THEN
                HK := 2;
            ELSIF THANG = 9 THEN
                HK := 3;
            ELSIF THANG > 1 AND THANG <= 4 THEN
                HK := 2;
            ELSIF THANG > 5 AND THANG <= 8 THEN
                HK := 3;
            ELSE
                HK := 1;
                NAM := NAM + 1;
            END IF;
        ELSE
            IF THANG >= 1 AND THANG <= 4 THEN
                HK := 2;
            ELSIF THANG >= 5 AND THANG <= 8 THEN
                HK := 3;
            ELSE
                HK := 1;
                NAM := NAM + 1;
            END IF;
        END IF;
        
        -- Trả về điều kiện cho phép thêm, xóa NẾU năm học >= năm hiện tại và học kỳ >= học kỳ hiện tại
        RETURN 'HK >= ' || HK || ' AND NAM >= ' || NAM;
    ELSE
        RETURN NULL;
    END IF;
END;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'C##ADMIN',
        OBJECT_NAME => 'N09_DANGKY',
        POLICY_NAME => 'N09_POLICY_INSERT_DELETE_DANGKY',
        POLICY_FUNCTION => 'N09_POLICY_FUNCTION_INSERT_DELETE_DANGKY',
        STATEMENT_TYPES => 'INSERT, DELETE',
        UPDATE_CHECK => TRUE
    );
END;
/

-- Cấp quyền INSERT, DELETE trên bảng DANGKY cho sinh viên
GRANT INSERT, DELETE ON C##ADMIN.N09_DANGKY TO N09_RL_SINHVIEN;
/

----TEST
---- Kiểm tra xóa dữ liệu (đảm bảo ngày hiện tại nằm trong 14 ngày kể từ ngày bắt đầu học kỳ)
--CONN SV001/SV001;
--SELECT * FROM C##ADMIN.N09_DANGKY;
--/
--
---- Xóa Học phần HP003, Học kỳ 3, Năm 2024 (1/9/2024), Ngày hiện tại 10/6/2024: Thành công
--CONN SV001/SV001;
--DELETE FROM C##ADMIN.N09_DANGKY WHERE MASV = 'SV001' AND MAHP = 'HP003' AND MAGV = 'NV201' AND HK = 3 AND NAM = 2024;
--/
--
---- Xóa Học phần HP001, Học kỳ 1, Năm 2024 (1/1/2024), Ngày hiện tại 10/6/2024: Không thành công
--CONN SV001/SV001;
--DELETE FROM C##ADMIN.N09_DANGKY WHERE MASV = 'SV001' AND MAHP = 'HP001' AND MAGV = 'NV201' AND HK = 1 AND NAM = 2024;
--/
--
---- Thêm Học phần HP003, Học kỳ 3, Năm 2024 (1/9/2024), Ngày hiện tại 10/6/2024: Thành công
--CONN SV001/SV001;
--INSERT INTO C##ADMIN.N09_DANGKY VALUES('SV001', 'NV201', 'HP003', 3, 2024, 'CQ', NULL, NULL, NULL, NULL);
--/
--
---- Thêm Học phần HP001, Học kỳ 1, Năm 2024 (1/1/2024), Ngày hiện tại 10/6/2024: Không thành công
--CONN SV001/SV001;
--INSERT INTO C##ADMIN.N09_DANGKY VALUES('SV001', 'NV202', 'HP001', 2, 2024, 'CLC', NULL, NULL, NULL, NULL);
--/






