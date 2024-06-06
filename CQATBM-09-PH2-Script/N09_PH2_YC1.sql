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
CONN C##ADMIN/123;
/***************************************************************
CS#1: Người dùng có VAITRO là “Nhân viên cơ bản” có quyền truy cập dữ liệu:
    - Xem dòng dữ liệu của chính mình trong quan hệ NHANSU, có thể chỉnh sửa số điện
    thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
    - Xem thông tin của tất cả SINHVIEN, ĐƠNVỊ, HOCPHAN, KHMO.
****************************************************************/
-- 1a. Xem dòng dữ liệu của chính mình trong quan hệ NHANSU
-- <NOTE>
-- Vì View này chủ yếu để lấy thoại số của chính bản thân User
-- nên lấy lại các cột từ bảng gốc N09_NHANSU
-- Để xử lý trên app dễ hơn
-- </NOTE>
CREATE OR REPLACE VIEW UV_N09_NHANSU_VIEWBY_NHANVIEN 
AS
    SELECT * FROM N09_NHANSU WHERE MANV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_NHANSU_VIEWBY_NHANVIEN TO N09_RL_NHANVIEN;
/

-- 1a.(cont). Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT UPDATE (DT) ON UV_N09_NHANSU_VIEWBY_NHANVIEN TO N09_RL_NHANVIEN;
/

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
-- <NOTE>
-- Vì View này chủ yếu để lấy thoại số của chính bản thân User
-- nên lấy lại các cột từ bảng gốc N09_NHANSU
-- Để xử lý trên app dễ hơn
-- </NOTE>
CREATE OR REPLACE VIEW UV_N09_NHANSU_VIEWBY_GIANGVIEN 
AS
    SELECT * FROM N09_NHANSU WHERE MANV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_NHANSU_VIEWBY_GIANGVIEN TO N09_RL_GIANGVIEN;
/

-- 1a.(cont). Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT UPDATE (DT) ON UV_N09_NHANSU_VIEWBY_GIANGVIEN TO N09_RL_GIANGVIEN;
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
CREATE OR REPLACE VIEW UV_N09_PHANCONG_VIEWBY_GIANGVIEN
AS
    SELECT * FROM UV_N09_PHANCONG WHERE "Mã Giảng Viên" = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_PHANCONG_VIEWBY_GIANGVIEN TO N09_RL_GIANGVIEN;
/

-- 2c. Xem dữ liệu trên quan hệ ĐANGKY liên quan đến các lớp học phần mà giảng viên được phân công giảng dạy.
CREATE OR REPLACE VIEW UV_N09_DANGKY_VIEWBY_GIANGVIEN
AS
    SELECT * FROM UV_N09_DANGKY WHERE "Mã Giảng Viên" = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_DANGKY_VIEWBY_GIANGVIEN TO N09_RL_GIANGVIEN;
/

-- 2d. Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
-- sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. 
-- Các trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
GRANT UPDATE ("Điểm Thi", "Điểm Quá Trình", "Điểm Cuối Kỳ", "Điểm Tổng Kết") ON UV_N09_DANGKY_VIEWBY_GIANGVIEN TO N09_RL_GIANGVIEN;
/



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
-- 1a. Xem dòng dữ liệu của chính mình trong quan hệ NHANSU
-- <NOTE>
-- Vì View này chủ yếu để lấy thoại số của chính bản thân User
-- nên lấy lại các cột từ bảng gốc N09_NHANSU
-- Để xử lý trên app dễ hơn
-- </NOTE>
CREATE OR REPLACE VIEW UV_N09_NHANSU_VIEWBY_GIAOVU 
AS
    SELECT * FROM N09_NHANSU WHERE MANV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_NHANSU_VIEWBY_GIAOVU TO N09_RL_GIAOVU;
/

-- 1a.(cont). Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT UPDATE (DT) ON UV_N09_NHANSU_VIEWBY_GIAOVU TO N09_RL_GIAOVU;
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
CREATE OR REPLACE VIEW UV_N09_PHANCONG_VIEWBY_GIAOVU
AS
    SELECT * FROM UV_N09_PHANCONG;
/

GRANT SELECT, UPDATE ON UV_N09_PHANCONG_VIEWBY_GIAOVU TO N09_RL_GIAOVU;
GRANT SELECT, UPDATE ON UV_N09_PHANCONG TO N09_RL_GIAOVU;
GRANT SELECT, UPDATE ON N09_PHANCONG TO N09_RL_GIAOVU;
/

-- 3c.(cont). Tạo Trigger khi Update vào bảng PHANCONG bởi Giáo vụ
-- <NOTE>
-- Ở đây chỉ sử dụng bảng gốc N09_PHANCONG để xử lý Trigger
-- </NOTE>
CREATE OR REPLACE TRIGGER TR_N09_PHANCONG_UPDATE_BY_GIAOVU
BEFORE UPDATE ON N09_PHANCONG
FOR EACH ROW
DECLARE
    l_count NUMBER;
BEGIN
    -- Kiểm tra nếu người dùng hiện tại là Giáo vụ
    SELECT COUNT(*)
    INTO l_count
    FROM N09_NHANSU
    WHERE MANV = SYS_CONTEXT('userenv', 'session_user')
      AND VAITRO = 'Giáo vụ';
    
    IF l_count > 0 THEN
        -- Nếu là Giáo vụ, kiểm tra nếu học phần thuộc đơn vị "Văn phòng khoa"
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

---- Test
--CREATE USER NV301 IDENTIFIED BY NV301;
--GRANT CONNECT TO NV301;
--GRANT N09_RL_GIAOVU TO NV301;
--/
--
--CONN NV301/NV301;
--SELECT * FROM C##ADMIN.N09_PHANCONG;
--/
--
--CONN NV301/NV301;
---- UPDATE thành công
--UPDATE C##ADMIN.N09_PHANCONG SET HK = 1 WHERE MAGV = 'NV211';
---- UPDATE KHÔNG thành công
--UPDATE C##ADMIN.N09_PHANCONG SET HK = 3 WHERE MAGV = 'NV202';
--/


-- 3d. Xóa hoặc Thêm mới dữ liệu trên quan hệ ĐANGKY theo yêu cầu của sinh viên trong
-- khoảng thời gian còn cho hiệu chỉnh đăng ký
-- 
-- * Điều kiện: 
--   - Sinh viên có thể hiệu chỉnh đăng ký học phần (thêm, xóa) nếu ngày hiện tại 
--   không vượt quá 14 ngày so với ngày bắt đầu học kỳ
--
-- * Lưu ý: Mỗi năm học có 3 học kỳ (HK) bắt đầu tương ứng vào ngày đầu tiên các tháng 1, 5, 9.
--
-- Vì chưa đủ thông tin và Giáo vụ có thể thêm, xóa dữ liệu nên
-- mặc định Giáo vụ có quyền xem toàn bộ bảng DANGKY và View của nó 
CREATE OR REPLACE VIEW UV_N09_DANGKY_VIEWBY_GIAOVU
AS
    SELECT * FROM UV_N09_DANGKY;
/

GRANT SELECT, INSERT, DELETE ON UV_N09_DANGKY_VIEWBY_GIAOVU TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, DELETE ON UV_N09_DANGKY TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, DELETE ON N09_DANGKY TO N09_RL_GIAOVU;
/

-- <NOTE>
-- Ở đây chỉ sử dụng bảng gốc N09_DANGKY để xử lý Trigger
-- </NOTE>
-- Tạo Trigger khi Insert vào bảng DANGKY bởi Giáo vụ
CREATE OR REPLACE TRIGGER TR_N09_DANGKY_MANAGE_BY_GIAOVU
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
--INSERT INTO C##ADMIN.N09_DANGKY(MASV, MAGV, MAHP, HK, NAM, MACT) VALUES('SV001', 'NV212', 'HP002', 3, 2024, 'CLC');
--/
----------
--CONN NV301/NV301;
---- DELETE KHÔNG thành công
--DELETE FROM C##ADMIN.N09_DANGKY WHERE MASV = 'SV001' AND MAGV = 'NV201' AND MAHP = 'HP001' AND HK = 1 AND NAM = 2024 AND MACT = 'CQ';
--/
---- DELETE thành công
--DELETE FROM C##ADMIN.N09_DANGKY WHERE MASV = 'SV001' AND MAGV = 'NV212' AND MAHP = 'HP002' AND HK = 3 AND NAM = 2024 AND MACT = 'CLC';
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
-- <NOTE>
-- Vì View này chủ yếu để lấy thoại số của chính bản thân User
-- nên lấy lại các cột từ bảng gốc N09_NHANSU
-- Để xử lý trên app dễ hơn
-- </NOTE>
CREATE OR REPLACE VIEW UV_N09_NHANSU_VIEWBY_TRUONGDONVI 
AS
    SELECT * FROM N09_NHANSU WHERE MANV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_NHANSU_VIEWBY_TRUONGDONVI TO N09_RL_TRUONG_DONVI;
/

-- 1a.(cont). Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT UPDATE (DT) ON UV_N09_NHANSU_VIEWBY_TRUONGDONVI TO N09_RL_TRUONG_DONVI;
/

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
-- Vì Trưởng đơn vị không tham gia giảng dạy (không có MAGV) nên khi xem View này sẽ không có dữ liệu.
-- </NOTE>
CREATE OR REPLACE VIEW UV_N09_DANGKY_VIEWBY_TRUONGDONVI 
AS
    SELECT * FROM UV_N09_DANGKY WHERE "Mã Giảng Viên" = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_DANGKY_VIEWBY_TRUONGDONVI TO N09_RL_TRUONG_DONVI;
/

-- 2d. Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
-- sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. 
-- Các trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
-- <NOTE>
-- Vì Trưởng đơn vị không tham gia giảng dạy (không có MAGV) nên sẽ không có dữ liệu khi cập nhật View này.
-- </NOTE>
GRANT UPDATE ("Điểm Thi", "Điểm Quá Trình", "Điểm Cuối Kỳ", "Điểm Tổng Kết") ON UV_N09_DANGKY_VIEWBY_TRUONGDONVI TO N09_RL_TRUONG_DONVI;
/


-----------------------------------------------------------------
-- Các quyền riêng cho Trưởng đơn vị
-----------------------------------------------------------------
-- 4c. Được xem dữ liệu phân công giảng dạy của các giảng viên mà mình làm trưởng.
CREATE OR REPLACE VIEW UV_N09_PHANCONG_VIEWBY_TRUONGDONVI 
AS
    SELECT pc.*
    FROM UV_N09_PHANCONG pc
    JOIN UV_N09_NHANSU ns ON pc."Mã Giảng Viên" = ns."Mã Nhân Viên"
    JOIN UV_N09_DONVI dv ON ns."Mã Đơn Vị" = dv."Mã Đơn Vị"
    WHERE dv."Trưởng Đơn Vị" = SYS_CONTEXT('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_PHANCONG_VIEWBY_TRUONGDONVI TO N09_RL_TRUONG_DONVI;
/

-- 4b. Thêm, Xóa, Cập nhật dữ liệu trên quan hệ PHANCONG, đối với các học phần được
-- phụ trách chuyên môn bởi đơn vị mà mình làm trưởng
--
-- Tạo Trigger khi Insert, Delete, Update vào bảng PHANCONG
-- <NOTE>
-- Vì Trigger được cài lên View nên phải xử lý thao tác trên TABLE thật (N09_PHANCONG)
-- </NOTE>
CREATE OR REPLACE TRIGGER TR_N09_PHANCONG_BY_TRUONGDONVI
INSTEAD OF INSERT OR DELETE OR UPDATE ON UV_N09_PHANCONG_VIEWBY_TRUONGDONVI
FOR EACH ROW
DECLARE
    l_role_count NUMBER;
    l_count NUMBER;
    l_is_truongdonvi NUMBER;
BEGIN
    -- Kiểm tra nếu người dùng hiện tại là Trưởng đơn vị
    SELECT COUNT(*)
    INTO l_is_truongdonvi
    FROM UV_N09_NHANSU_VIEWBY_TRUONGDONVI
    WHERE MANV = SYS_CONTEXT('userenv', 'session_user')
      AND VAITRO = 'Trưởng đơn vị';

    IF l_is_truongdonvi > 0 THEN
        IF UPDATING THEN
            -- Kiểm tra khi UPDATE
            SELECT COUNT(*)
            INTO l_count
            FROM N09_HOCPHAN hp
            JOIN N09_DONVI dv ON hp.MADV = dv.MADV
            WHERE hp.MAHP = :NEW."Mã Học Phần"
              AND dv.TRGDV = SYS_CONTEXT('userenv', 'session_user');
            
            IF l_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác UPDATE vì học phần này không thuộc đơn vị của bạn.');
            ELSE
                UPDATE N09_PHANCONG
                SET MAGV = :NEW."Mã Giảng Viên", MAHP = :NEW."Mã Học Phần", HK = :NEW."Học Kỳ", NAM = :NEW."Năm", MACT = :NEW."Mã Chương Trình"
                WHERE MAGV = :OLD."Mã Giảng Viên" AND MAHP = :OLD."Mã Học Phần" AND HK = :OLD."Học Kỳ" AND NAM = :OLD."Năm" AND MACT = :OLD."Mã Chương Trình";
            END IF;
            
        ELSIF INSERTING THEN
            -- Kiểm tra khi INSERT
            SELECT COUNT(*)
            INTO l_count
            FROM N09_HOCPHAN hp
            JOIN N09_DONVI dv ON hp.MADV = dv.MADV
            WHERE hp.MAHP = :NEW."Mã Học Phần"
              AND dv.TRGDV = SYS_CONTEXT('userenv', 'session_user');
            
            IF l_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác INSERT vì học phần này không thuộc đơn vị của bạn.');
            ELSE
                INSERT INTO N09_PHANCONG (MAGV, MAHP, HK, NAM, MACT)
                VALUES (:NEW."Mã Giảng Viên", :NEW."Mã Học Phần", :NEW."Học Kỳ", :NEW."Năm", :NEW."Mã Chương Trình");
            END IF;
            
        ELSIF DELETING THEN
            -- Kiểm tra khi DELETE
            SELECT COUNT(*)
            INTO l_count
            FROM N09_HOCPHAN hp
            JOIN N09_DONVI dv ON hp.MADV = dv.MADV
            WHERE hp.MAHP = :OLD."Mã Học Phần"
              AND dv.TRGDV = SYS_CONTEXT('userenv', 'session_user');
            
            IF l_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác DELETE vì học phần này không thuộc đơn vị của bạn.');
            ELSE
                DELETE FROM N09_PHANCONG
                WHERE MAGV = :OLD."Mã Giảng Viên" AND MAHP = :OLD."Mã Học Phần" AND HK = :OLD."Học Kỳ" AND NAM = :OLD."Năm" AND MACT = :OLD."Mã Chương Trình";
            END IF;
        END IF;  
    END IF;    
END;
/

GRANT INSERT, DELETE, UPDATE ON UV_N09_PHANCONG_VIEWBY_TRUONGDONVI TO N09_RL_TRUONG_DONVI;
/

--  -- Test
--  CREATE USER NV102 IDENTIFIED BY NV102;
--  GRANT CONNECT TO NV102;
--  GRANT N09_RL_TRUONG_DONVI TO NV102;
--  /

--  CONN NV102/NV102;
--  SELECT * FROM C##ADMIN.UV_N09_PHANCONG_VIEWBY_TRUONGDONVI;
--  /
--  -- INSERT KHÔNG thành công
--  INSERT INTO C##ADMIN.UV_N09_PHANCONG_VIEWBY_TRUONGDONVI VALUES('NV205', 'HP002', 2, 2024, 'CLC');
--  /
--  CONN NV102/NV102;
--  -- INSERT thành công
--  INSERT INTO C##ADMIN.UV_N09_PHANCONG_VIEWBY_TRUONGDONVI VALUES('NV220', 'HP007', 1, 2024, 'CTTT');
--  /

--  CONN NV102/NV102;
--  -- DELETE KHÔNG thành công
--  DELETE FROM C##ADMIN.UV_N09_PHANCONG_VIEWBY_TRUONGDONVI WHERE MAGV = 'NV202' AND MAHP = 'HP002' AND HK = 2 AND NAM = 2024 AND MACT = 'CLC';
--  /
--  CONN NV102/NV102;
--  -- DELETE thành công
--  DELETE FROM C##ADMIN.UV_N09_PHANCONG_VIEWBY_TRUONGDONVI WHERE MAGV = 'NV220' AND MAHP = 'HP007' AND HK = 1 AND NAM = 2024 AND MACT = 'CTTT';
--  /

--  -- SELECT * FROM N09_PHANCONG;
--  -- DELETE FROM C##ADMIN.N09_PHANCONG WHERE MAGV = 'NV220' AND MAHP = 'HP007' AND HK = 1 AND NAM = 2024 AND MACT = 'CTTT';
--  -- /




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
CREATE OR REPLACE VIEW UV_N09_NHANSU_VIEWBY_TRUONGKHOA
AS
    SELECT * FROM UV_N09_NHANSU;
/

GRANT SELECT ON UV_N09_NHANSU_VIEWBY_TRUONGKHOA TO N09_RL_TRUONG_KHOA;
/

-- 1a.(cont). Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
-- Tạo trigger khi UPDATE số điện thoại (DT) của chính mình
-- <NOTE>
-- A. Vì Trưởng khoa được xem dữ liệu trên toàn bộ lược đồ CSDL phải kiểm tra khi UPDATE số điện thoại
-- B. Trong Trigger không được dùng lại table/view của cùng tên table đang cài trigger
-- nếu không sẽ gặp lỗi `ORA-04091: table is mutating, trigger/function may not see it error during execution of oracle trigger`
-- </NOTE>
CREATE OR REPLACE TRIGGER TR_N09_NHANSU_UPDATE_SDT_BY_TRUONGKHOA
AFTER UPDATE OF DT ON N09_NHANSU
FOR EACH ROW
DECLARE
    l_is_truongdonvi NUMBER;
BEGIN
    -- Kiểm tra nếu người dùng hiện tại là Trưởng khoa
    SELECT COUNT (*)    
    INTO l_is_truongdonvi
    FROM USER_ROLE_PRIVS
    WHERE GRANTED_ROLE = 'N09_RL_TRUONG_KHOA';

    IF l_is_truongdonvi > 0 THEN
        IF :NEW.MANV <> :OLD.MANV THEN
            RAISE_APPLICATION_ERROR(-20001, 'Bạn không thể thay đổi số điện thoại của người khác.');
        END IF;
    END IF;
END;
/

GRANT UPDATE (DT) ON N09_NHANSU TO N09_RL_TRUONG_KHOA;
/


-----------------------------------------------------------------
-- B. Lặp lại việc gán các quyền như quyền của Giảng viên
-- Cần đổi tên View
-----------------------------------------------------------------
-- 2b. Xem dữ liệu phân công giảng dạy.
CREATE OR REPLACE VIEW UV_N09_PHANCONG_VIEWBY_TRUONGKHOA
AS
    SELECT * FROM UV_N09_PHANCONG;
/

GRANT SELECT ON UV_N09_PHANCONG_VIEWBY_TRUONGKHOA TO N09_RL_TRUONG_KHOA;
/

-- 2c. Xem dữ liệu trên quan hệ ĐANGKY.
CREATE OR REPLACE VIEW UV_N09_DANGKY_VIEWBY_TRUONGKHOA
AS
    SELECT * FROM UV_N09_DANGKY;
/

GRANT SELECT ON UV_N09_DANGKY_VIEWBY_TRUONGKHOA TO N09_RL_TRUONG_KHOA;
/

-- 2d. Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
-- sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. 
-- Các trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
CREATE OR REPLACE VIEW UV_N09_DANGKY_VIEWBY_TRUONGKHOA
AS
    SELECT * FROM UV_N09_DANGKY;
/

GRANT UPDATE ("Điểm Thi", "Điểm Quá Trình", "Điểm Cuối Kỳ", "Điểm Tổng Kết") ON UV_N09_DANGKY_VIEWBY_TRUONGKHOA TO N09_RL_TRUONG_KHOA;
GRANT UPDATE ("Điểm Thi", "Điểm Quá Trình", "Điểm Cuối Kỳ", "Điểm Tổng Kết") ON UV_N09_DANGKY TO N09_RL_TRUONG_KHOA;
GRANT UPDATE (DIEMTH, DIEMQT, DIEMCK, DIEMTK) ON N09_DANGKY TO N09_RL_TRUONG_KHOA;
/


-----------------------------------------------------------------
-- Các quyền riêng cho Trưởng khoa
-----------------------------------------------------------------
-- 5b. Thêm, Xóa, Cập nhật dữ liệu trên quan hệ PHANCONG đối với các học phần quản lý bởi đơn vị “Văn phòng khoa”.
-- Tạo Trigger khi Insert, Delete, Update vào bảng PHANCONG
CREATE OR REPLACE TRIGGER TR_N09_PHANCONG_BY_TRUONGKHOA
BEFORE INSERT OR DELETE OR UPDATE ON N09_PHANCONG
FOR EACH ROW
DECLARE
    l_count NUMBER;
    l_role_count NUMBER;
BEGIN
    -- Kiểm tra nếu người dùng hiện tại là Trưởng khoa
    SELECT COUNT(*)
    INTO l_role_count
    FROM N09_NHANSU
    WHERE MANV = SYS_CONTEXT('userenv', 'session_user')
      AND VAITRO = 'Trưởng khoa';

    IF l_role_count > 0 THEN
        -- Nếu là Trưởng khoa, kiểm tra nếu học phần thuộc đơn vị "Văn phòng khoa"
        SELECT COUNT(*)
        INTO l_count
        FROM N09_HOCPHAN hp
        JOIN N09_DONVI dv ON hp.MADV = dv.MADV
        WHERE hp.MAHP = :NEW.MAHP
          AND dv.TENDV = 'Văn phòng khoa';

        IF l_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác vì học phần này không thuộc đơn vị Văn phòng khoa.');
        END IF;
    END IF;
END;
/

GRANT INSERT, DELETE, UPDATE ON N09_PHANCONG TO N09_RL_TRUONG_KHOA;
/

---- Test
--CREATE USER NV001 IDENTIFIED BY NV001;
--GRANT CONNECT TO NV001;
--GRANT N09_RL_TRUONG_KHOA TO NV001;
--/
--
--CONN NV001/NV001;
--SELECT * FROM C##ADMIN.N09_PHANCONG;
--INSERT INTO C##ADMIN.N09_PHANCONG VALUES('NV210', 'HP009', 3, 2024, 'CQ');
--/


-- 5c. Được quyền Xem, Thêm, Xóa, Cập nhật trên quan hệ NHANSU.
GRANT SELECT, INSERT, DELETE, UPDATE ON UV_N09_NHANSU_VIEWBY_TRUONGKHOA TO N09_RL_TRUONG_KHOA;
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















