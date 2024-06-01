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

-- Thực thi Stored Procedure tạo user cho tất cả nhân sự
EXEC N09_CREATE_USER_NHANSU;
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

-- Thực thi Stored Procedure tạo user cho tất cả sinh viên
EXEC N09_CREATE_USER_SINHVIEN;
/



/***************************************************************
CS#1: Người dùng có VAITRO là “Nhân viên cơ bản” có quyền truy cập dữ liệu:
    - Xem dòng dữ liệu của chính mình trong quan hệ NHANSU, có thể chỉnh sửa số điện
    thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
    - Xem thông tin của tất cả SINHVIEN, ĐƠNVỊ, HOCPHAN, KHMO.
****************************************************************/
-- 1a. Xem dòng dữ liệu của chính mình trong quan hệ NHANSU
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
GRANT SELECT * ON N09_SINHVIEN TO N09_RL_NHANVIEN;
GRANT SELECT * ON N09_DONVI TO N09_RL_NHANVIEN;
GRANT SELECT * ON N09_HOCPHAN TO N09_RL_NHANVIEN;
GRANT SELECT * ON N09_KHMO TO N09_RL_NHANVIEN;
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
GRANT SELECT * ON N09_SINHVIEN TO N09_RL_NHANVIEN;
GRANT SELECT * ON N09_DONVI TO N09_RL_NHANVIEN;
GRANT SELECT * ON N09_HOCPHAN TO N09_RL_NHANVIEN;
GRANT SELECT * ON N09_KHMO TO N09_RL_NHANVIEN;
/


-----------------------------------------------------------------
-- Các quyền riêng cho Giảng viên
-----------------------------------------------------------------
-- 2b. Xem dữ liệu phân công giảng dạy liên quan đến bản thân mình (PHANCONG).
CREATE OR REPLACE VIEW UV_N09_PHANCONG_VIEWBY_GIANGVIEN
AS
    SELECT * FROM N09_PHANCONG WHERE MAGV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_PHANCONG_VIEWBY_GIANGVIEN TO N09_RL_GIANGVIEN;
/

-- 2c. Xem dữ liệu trên quan hệ ĐANGKY liên quan đến các lớp học phần mà giảng viên được phân công giảng dạy.
CREATE OR REPLACE VIEW UV_N09_DANGKY_VIEWBY_GIANGVIEN
AS
    SELECT * FROM N09_DANGKY WHERE MAGV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_DANGKY_VIEWBY_GIANGVIEN TO N09_RL_GIANGVIEN;
/

-- 2d. Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
-- sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. 
-- Các trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
GRANT UPDATE (DIEMTH, DIEMQT, DIEMCK, DIEMTK) ON UV_N09_DANGKY_VIEWBY_GIANGVIEN TO N09_RL_GIANGVIEN;
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
GRANT SELECT * ON N09_SINHVIEN TO N09_RL_NHANVIEN;
GRANT SELECT * ON N09_DONVI TO N09_RL_NHANVIEN;
GRANT SELECT * ON N09_HOCPHAN TO N09_RL_NHANVIEN;
GRANT SELECT * ON N09_KHMO TO N09_RL_NHANVIEN;
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
    SELECT * FROM N09_PHANCONG;
/

GRANT SELECT ON UV_N09_PHANCONG_VIEWBY_GIAOVU TO N09_RL_GIAOVU;
/

-- 3c.(cont). Tạo Trigger khi Update vào bảng PHANCONG
CREATE OR REPLACE TRIGGER TR_N09_PHANCONG_UPDATE_BY_GIAOVU
BEFORE UPDATE ON N09_PHANCONG
FOR EACH ROW
DECLARE
    l_vanphongkhoa_madv CHAR(5);
    l_count NUMBER;
BEGIN
    -- Lấy mã đơn vị của "Văn phòng khoa"
    SELECT MADV
    INTO l_vanphongkhoa_madv
    FROM N09_DONVI
    WHERE TENDV = 'Văn phòng khoa';

    -- Kiểm tra nếu hành động là cập nhật dữ liệu phân công
    SELECT COUNT(*)
    INTO l_count
    FROM N09_HOCPHAN hp
    JOIN N09_DONVI dv ON hp.MADV = dv.MADV
    WHERE hp.MAHP = :OLD.MAHP
      AND dv.MADV = l_vanphongkhoa_madv
      AND dv.TRGDV IN (SELECT MANV FROM N09_NHANSU WHERE VAITRO = 'Trưởng khoa');

    IF l_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Bạn không có quyền cập nhật dữ liệu phân công này vì nó không thuộc đơn vị Văn phòng khoa hoặc trưởng đơn vị không phải là trưởng khoa.');
    END IF;
END;


-- <NOTE>
-- FINISH THIS
-- <NOTE>
/

-- 3d. Xóa hoặc Thêm mới dữ liệu trên quan hệ ĐANGKY theo yêu cầu của sinh viên trong
-- khoảng thời gian còn cho hiệu chỉnh đăng ký
-- 
-- * Điều kiện: 
--   - Sinh viên có thể hiệu chỉnh đăng ký học phần (thêm, xóa) nếu ngày hiện tại 
--   không vượt quá 14 ngày so với ngày bắt đầu học kỳ
--
-- * Lưu ý: Mỗi năm học có 3 học kỳ (HK) bắt đầu tương ứng vào ngày đầu tiên các tháng 1, 5, 9.
CREATE OR REPLACE VIEW UV_N09_DANGKY_VIEWBY_SINHVIEN
AS
    SELECT * FROM N09_DANGKY WHERE MASV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_DANGKY_VIEWBY_SINHVIEN TO N09_RL_GIAOVU;
/

GRANT INSERT, DELETE ON UV_N09_DANGKY_VIEWBY_SINHVIEN TO N09_RL_GIAOVU;
-- <NOTE>
-- FINISH THIS
-- <NOTE>







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
CREATE OR REPLACE VIEW UV_N09_NHANSU_VIEWBY_TRUONGDONVI 
AS
    SELECT * FROM N09_NHANSU WHERE MANV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_NHANSU_VIEWBY_TRUONGDONVI TO N09_RL_GIAOVU;
/

-- 1a.(cont). Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT UPDATE (DT) ON UV_N09_NHANSU_VIEWBY_TRUONGDONVI TO N09_RL_GIAOVU;
/

-- 1b. Xem, Thêm mới hoặc Cập nhật dữ liệu trên các quan hệ SINHVIEN, ĐONVI,
-- HOCPHAN, KHMO, theo yêu cầu của trưởng khoa.
GRANT SELECT, INSERT, UPDATE ON N09_SINHVIEN TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, UPDATE ON N09_DONVI TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, UPDATE ON N09_HOCPHAN TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, UPDATE ON N09_KHMO TO N09_RL_GIAOVU;
/

-----------------------------------------------------------------
-- B. Lặp lại việc gán các quyền như quyền của Giảng viên
-- Cần đổi tên View
-----------------------------------------------------------------
-- 2b. Xem dữ liệu phân công giảng dạy liên quan đến bản thân mình (PHANCONG).
-- <NOTE>
-- Không cấp quyền giống với Giảng viên vì Trưởng đơn vị có kiểu xem khác (xem mục 4c. bên dưới)
-- <NOTE>

-- 2c. Xem dữ liệu trên quan hệ ĐANGKY liên quan đến các lớp học phần mà giảng viên được phân công giảng dạy.
-- <NOTE>
-- Vì Trưởng đơn vị không tham gia giảng dạy (không có MAGV) nên khi xem View này sẽ không có dữ liệu.
-- <NOTE>
CREATE OR REPLACE VIEW UV_N09_DANGKY_VIEWBY_TRUONGDONVI 
AS
    SELECT * FROM N09_DANGKY WHERE MAGV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_DANGKY_VIEWBY_TRUONGDONVI TO N09_RL_GIANGVIEN;
/

-- 2d. Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
-- sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. 
-- Các trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
-- <NOTE>
-- Vì Trưởng đơn vị không tham gia giảng dạy (không có MAGV) nên sẽ không có dữ liệu khi cập nhật View này.
-- <NOTE>
GRANT UPDATE (DIEMTH, DIEMQT, DIEMCK, DIEMTK) ON UV_N09_DANGKY_VIEWBY_TRUONGDONVI TO N09_RL_GIANGVIEN;
/

-----------------------------------------------------------------
-- Các quyền riêng cho Trưởng đơn vị
-----------------------------------------------------------------
-- 4c. Được xem dữ liệu phân công giảng dạy của các giảng viên mà mình làm trưởng.
CREATE OR REPLACE VIEW UV_N09_PHANCONG_VIEWBY_TRUONGDONVI 
AS
    SELECT pc.*
    FROM N09_PHANCONG pc
    JOIN N09_NHANSU ns ON pc.MAGV = ns.MANV
    JOIN N09_DONVI dv ON ns.MADV = dv.MADV
    WHERE dv.TRGDV = SYS_CONTEXT('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_PHANCONG_VIEWBY_TRUONGDONVI TO N09_RL_TRUONG_DONVI;
/

-- 4b. Thêm, Xóa, Cập nhật dữ liệu trên quan hệ PHANCONG, đối với các học phần được
-- phụ trách chuyên môn bởi đơn vị mà mình làm trưởng
-- Tạo Trigger khi Insert, Delete, Update vào bảng PHANCONG
CREATE OR REPLACE TRIGGER TR_N09_PHANCONG_BY_TRUONGDONVI
INSTEAD OF INSERT OR DELETE OR UPDATE ON UV_N09_PHANCONG_VIEWBY_TRUONGDONVI
FOR EACH ROW
DECLARE
    l_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO l_count
    FROM N09_HOCPHAN hp
    JOIN N09_DONVI dv ON hp.MADV = dv.MADV
    WHERE hp.MAHP = :NEW.MAHP
      AND dv.TRGDV = SYS_CONTEXT('userenv', 'session_user');
    
    IF l_count > 0 THEN
        NULL; -- Thực hiện hành động nếu điều kiện thỏa mãn
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác vì học phần này không thuộc đơn vị của bạn.');
    END IF;
END;
/

GRANT INSERT, DELETE, UPDATE ON UV_N09_PHANCONG_VIEWBY_TRUONGDONVI TO N09_RL_TRUONG_DONVI;
/

-- -- Test
-- CREATE USER NV102 IDENTIFIED BY NV102;
-- GRANT CONNECT TO NV102;
-- /
-- CONN NV102/NV102;
-- SELECT * FROM C##ADMIN.UV_N09_PHANCONG_VIEWBY_TRUONGDONVI;
-- INSERT INTO C##ADMIN.UV_N09_PHANCONG_VIEWBY_TRUONGDONVI VALUES('NV205', 'HP002', 2, 2024, 'CLC');
/



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
-- <NOTE>
--
-- 1a.(cont). Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
-- Tạo trigger khi UPDATE số điện thoại (DT) của chính mình
CREATE OR REPLACE TRIGGER TR_N09_NHANSU_UPDATE_SDT_BY_TRUONGKHOA
BEFORE UPDATE OF DT ON N09_NHANSU
FOR EACH ROW
BEGIN
    IF :OLD.MANV = SYS_CONTEXT('userenv', 'session_user') THEN
        :NEW.DT := :OLD.DT;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Bạn không thể thay đổi số điện thoại của người khác.');
    END IF;
END;
/

GRANT UPDATE (DT) ON N09_NHANSU TO N09_RL_TRUONG_KHOA;
/

-----------------------------------------------------------------
-- B. Lặp lại việc gán các quyền như quyền của Giảng viên
-- Cần đổi tên View
-----------------------------------------------------------------
-- <NOTE>
-- Vì Trưởng khoa Được quyền Xem (không giới hạn) dữ liệu trên toàn bộ lược đồ CSDL.
-- Nên chỉ cấp các quyền khác SELECT cho Trưởng khoa.
-- <NOTE>
--
-- 2d. Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
-- sinh viên có tham gia lớp học phần mà giảng viên đó được phân công giảng dạy. 
-- Các trường liên quan điểm số bao gồm: ĐIEMTH, ĐIEMQT, ĐIEMCK, ĐIEMTK.
GRANT UPDATE (DIEMTH, DIEMQT, DIEMCK, DIEMTK) ON UV_N09_DANGKY_VIEWBY_GIANGVIEN TO N09_RL_TRUONG_KHOA;
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
BEGIN
    SELECT COUNT(*)
    INTO l_count
    FROM N09_HOCPHAN hp
    JOIN N09_DONVI dv ON hp.MADV = dv.MADV
    WHERE hp.MAHP = :NEW.MAHP
    AND dv.TENDV = 'Van phong khoa';
    
    IF l_count > 0 THEN
        NULL; -- Thực hiện hành động nếu điều kiện thỏa mãn
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Không thể thực hiện thao tác vì học phần này không thuộc đơn vị Văn phòng khoa.');
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
GRANT SELECT, INSERT, DELETE, UPDATE ON N09_NHANSU TO N09_RL_TRUONG_KHOA;
/

-- 5d. Được quyền Xem (không giới hạn) dữ liệu trên toàn bộ lược đồ CSDL.
GRANT SELECT ON N09_NHANSU TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_SINHVIEN TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_DONVI TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_HOCPHAN TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_KHMO TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_PHANCONG TO N09_RL_TRUONG_KHOA;
GRANT SELECT ON N09_DANGKY TO N09_RL_TRUONG_KHOA;
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
****************************************************************/











