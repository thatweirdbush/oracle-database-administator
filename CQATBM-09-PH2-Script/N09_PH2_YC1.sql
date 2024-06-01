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



/***************************************************************
CS#1: Người dùng có VAITRO là “Nhân viên cơ bản” có quyền truy cập dữ liệu:
    - Xem dòng dữ liệu của chính mình trong quan hệ NHANSU, có thể chỉnh sửa số điện
    thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
    - Xem thông tin của tất cả SINHVIEN, ĐƠNVỊ, HOCPHAN, KHMO.
****************************************************************/
-- Xem dòng dữ liệu của chính mình trong quan hệ NHANSU
CREATE OR REPLACE VIEW UV_N09_NHANSU_VIEWBY_NHANVIEN 
AS
    SELECT * FROM N09_NHANSU WHERE MANV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_NHANSU_VIEWBY_NHANVIEN TO N09_RL_NHANVIEN;
/

-- Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT UPDATE (DT) ON UV_N09_NHANSU_VIEWBY_NHANVIEN TO N09_RL_NHANVIEN;
/

-- Xem thông tin của tất cả SINHVIEN, ĐƠNVỊ, HOCPHAN, KHMO.
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
-- Như một người dùng có vai trò “Nhân viên cơ bản”:
--
-- Xem dòng dữ liệu của chính mình trong quan hệ NHANSU
GRANT SELECT ON UV_N09_NHANSU_VIEWBY_NHANVIEN TO N09_RL_GIANGVIEN;
/

-- Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT UPDATE (DT) ON UV_N09_NHANSU_VIEWBY_NHANVIEN TO N09_RL_GIANGVIEN;
/

-- Xem dữ liệu phân công giảng dạy liên quan đến bản thân mình (PHANCONG).
CREATE OR REPLACE VIEW UV_N09_PHANCONG_VIEWBY_GIANGVIEN
AS
    SELECT * FROM N09_PHANCONG WHERE MAGV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_PHANCONG_VIEWBY_GIANGVIEN TO N09_RL_GIANGVIEN;
/

-- Xem dữ liệu trên quan hệ ĐANGKY liên quan đến các lớp học phần mà giảng viên được phân công giảng dạy.
CREATE OR REPLACE VIEW UV_N09_DANGKY_VIEWBY_GIANGVIEN
AS
    SELECT * FROM N09_DANGKY WHERE MAGV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_DANGKY_VIEWBY_GIANGVIEN TO N09_RL_GIANGVIEN;
/

-- Cập nhật dữ liệu tại các trường liên quan điểm số (trong quan hệ ĐANGKY) của các
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
-- Như một người dùng có vai trò “Nhân viên cơ bản” (xem mô tả CS#1):
--
-- Xem dòng dữ liệu của chính mình trong quan hệ NHANSU
GRANT SELECT ON UV_N09_NHANSU_VIEWBY_NHANVIEN TO N09_RL_GIAOVU;
/

-- Có thể chỉnh sửa số điện thoại (ĐT) của chính mình (nếu số điện thoại có thay đổi).
GRANT UPDATE (DT) ON UV_N09_NHANSU_VIEWBY_NHANVIEN TO N09_RL_GIAOVU;
/

-- Xem, Thêm mới hoặc Cập nhật dữ liệu trên các quan hệ SINHVIEN, ĐONVI,
-- HOCPHAN, KHMO, theo yêu cầu của trưởng khoa.
GRANT SELECT, INSERT, UPDATE ON N09_SINHVIEN TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, UPDATE ON N09_DONVI TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, UPDATE ON N09_HOCPHAN TO N09_RL_GIAOVU;
GRANT SELECT, INSERT, UPDATE ON N09_KHMO TO N09_RL_GIAOVU;
/

-- Xem dữ liệu trên toàn bộ quan hệ PHANCONG. Tuy nhiên, chỉ được sửa trên các dòng
-- dữ liệu phân công liên quan các học phần do “Văn phòng khoa” phụ trách phân công
-- giảng dạy, thừa hành người trưởng đơn vị tương ứng là trưởng khoa.
GRANT SELECT ON N09_PHANCONG TO N09_RL_GIAOVU;

-- TODO: FINISH THIS
GRANT UPDATE ON N09_PHANCONG TO N09_RL_GIAOVU;


-- Xóa hoặc Thêm mới dữ liệu trên quan hệ ĐANGKY theo yêu cầu của sinh viên trong
-- khoảng thời gian còn cho hiệu chỉnh đăng ký
-- *
-- * Điều kiện có thể hiệu chỉnh đăng ký: 
--   - Sinh viên có thể hiệu chỉnh đăng ký học phần (thêm, xóa) nếu ngày hiện tại 
--   không vượt quá 14 ngày so với ngày bắt đầu học kỳ
CREATE OR REPLACE VIEW UV_N09_DANGKY_VIEWBY_SINHVIEN
AS
    SELECT * FROM N09_DANGKY WHERE MASV = SYS_CONTEXT ('userenv', 'session_user');
/

GRANT SELECT ON UV_N09_DANGKY_VIEWBY_SINHVIEN TO N09_RL_GIAOVU;
/

GRANT INSERT, DELETE ON UV_N09_DANGKY_VIEWBY_SINHVIEN TO N09_RL_GIAOVU;
-- TODO: FINISH THIS

















/***************************************************************
CS#4: Người dùng có VAITRO là “Trưởng đơn vị”, gồm trưởng các bộ môn (không bao
gồm trưởng khoa), có quyền truy cập dữ liệu:
    - Như một người dùng có vai trò “Giảng viên” (xem mô tả CS#2).
    - Thêm, Xóa, Cập nhật dữ liệu trên quan hệ PHANCONG, đối với các học phần được
    phụ trách chuyên môn bởi đơn vị mà mình làm trưởng,
    - Được xem dữ liệu phân công giảng dạy của các giảng viên thuộc các đơn vị 
    mà mình làm trưởng.
****************************************************************/




/***************************************************************
CS#5: Người dùng có VAITRO là “Trưởng khoa” có quyền hạn:
    - Như một người dùng có vai trò “Giảng viên”
    - Thêm, Xóa, Cập nhật dữ liệu trên quan hệ PHANCONG đối với các học phần 
    quản lý bởi đơn vị “Văn phòng khoa”.
    - Được quyền Xem, Thêm, Xóa, Cập nhật trên quan hệ NHANSU.
    - Được quyền Xem (không giới hạn) dữ liệu trên toàn bộ lược đồ CSDL.
****************************************************************/




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











