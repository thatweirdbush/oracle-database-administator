-- Lớp: CQ2021/1
-- Nhóm: 09
-- Thành viên:
-- 21120037 - Mã Thùy Anh
-- 21120060 - Nguyễn Long Giang
-- 21120082 - Phan Quốc Huy 
-- 21120117 - Lê Thị Hồng Phượng



/***************************************************************
Yêu cầu 4: Sao lưu và phục hồi dữ liệu
    Sinh viên hãy tìm hiểu về cơ chế sao lưu và phục hồi dữ liệu do các HQT CSDL cung cấp và
    cài đặt chức năng sao lưu (chủ động, tự động) và khôi phục dữ liệu dự vào nhật ký hệ thống
    ở Yêu cầu 3 (sau khi có sự cố).
        1. Tìm hiểu các phương pháp thực hiện sao lưu và phục hồi dữ liệu.
        2. Hãy hiện thực các phương pháp đó trên HQT CSDL Oracle.
        3. Đánh giá ưu khuyết điểm các phương pháp đã tìm hiểu và thử nghiệm.
        4. Kết luận.

****************************************************************/
/***************************************************************
FLASHBACK TABLE
https://viblo.asia/p/huong-dan-su-dung-tinh-nang-flashback-table-trong-oracle-database-de-khoi-phuc-du-lieu-mot-cach-hieu-qua-zOQJwnNb4MP
https://dbaclass.com/article/how-to-enable-and-disable-flashback-in-oracle-database/

-- Dùng SQL PLUS
-- Kích hoạt tính năng FLASHBACK TABLE:

B1: Shutdown và mở lại ở chế độ MOUNT
SQL> SHUT IMMEDIATE;
Database closed.
Database dismounted.
ORACLE instance shut down.

B2: Mở lại ở chế độ MOUNT
SQL> STARTUP MOUNT;
ORACLE instance started.

Total System Global Area 1610610712 bytes
Fixed Size                  9857048 bytes
Variable Size            1006632960 bytes
Database Buffers          587202560 bytes
Redo Buffers                6918144 bytes
Database mounted.

B3: Chuyển qua chế độ ARCHIVELOG
SQL> ALTER DATABASE ARCHIVELOG;
Database altered.

B4: Show đã có file recovery chưa
SQL> SHOW PARAMETER RECOVERY;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_recovery_file_dest                string
db_recovery_file_dest_size           big integer 0
recovery_parallelism                 integer     0
remote_recovery_file_dest            string

B5: Nếu chưa thì set db_recovery_file_dest_size
SQL> ALTER SYSTEM SET db_recovery_file_dest_size = 10G SCOPE = BOTH;
System altered.

B6: Tạo đường dẫn (1 đường dẫn bất kỳ là được)
SQL> ALTER SYSTEM SET db_recovery_file_dest = 'C:\oracleFRA' SCOPE=BOTH;

B7: Mở FLASHBACK TABLE lên
SQL> ALTER DATABASE FLASHBACK ON;
Database altered.

B8: Shutdown database
SQL> SHUT IMMEDIATE;
ORACLE instance shut down.

B9: Start database
SQL> STARTUP;
ORACLE instance started.

****************************************************************/
-- Tiếp theo, chúng ta sẽ kích hoạt tính năng FLASHBACK TABLE trên bảng nào đã thực hiện audit ở YC3:
-- Bảng C##ADMIN.N09_NHANSU
-- Bảng C##ADMIN.N09_DANGKY
-- Bảng C##ADMIN.N09_KHMO

-- Kích hoạt ROW MOVEMENT
ALTER TABLE C##ADMIN.N09_NHANSU ENABLE ROW MOVEMENT; 
ALTER TABLE C##ADMIN.N09_DANGKY ENABLE ROW MOVEMENT; 
ALTER TABLE C##ADMIN.N09_KHMO ENABLE ROW MOVEMENT; 
/

-- NOTE: Chạy dưới người dùng C##ADMIN
-- Viết procedure có đầu vào là thời gian từ bảng N09_FGA, N09_AUDIT_TRAIL
-- Chỉ khôi phực những hành động như UPDATE, DELETE

/****************************************************************
    Ý TƯỞNG
    Trên giao diện sẽ hiển thị N09_FGA, N09_AUDIT_TRAIL nhưng chỉ gồm những hành động làm thay đổi dữ liệu
    người dùng sẽ click vào dòng muốn khôi phục, từ đó lấy dữ liệu thời gian truyền vào procedure dưới là khôi phục lại thời điểm ngay trước hành động đó diễn ra
    viết procedure có đầu vào là thời gian từ bảng N09_FGA, N09_AUDIT_TRAIL
****************************************************************/
CREATE OR REPLACE PROCEDURE N09_RECOVERY_DANGKY(
    TIME IN char)
IS
BEGIN
    EXECUTE IMMEDIATE 'FLASHBACK TABLE N09_DANGKY TO TIMESTAMP TO_TIMESTAMP(:1,''dd-MON-YY hh24:MI:SS'')'
    USING TIME;
END;
/

CREATE OR REPLACE PROCEDURE N09_RECOVERY_NHANSU(
    TIME IN char)
IS
BEGIN
    EXECUTE IMMEDIATE 'FLASHBACK TABLE N09_NHANSU TO TIMESTAMP TO_TIMESTAMP(:1,''dd-MON-YY hh24:MI:SS'')'
    USING TIME;
END;
/

CREATE OR REPLACE PROCEDURE N09_RECOVERY_KHMO(
    TIME IN char)
IS
BEGIN
    EXECUTE IMMEDIATE 'FLASHBACK TABLE N09_KHMO TO TIMESTAMP TO_TIMESTAMP(:1,''dd-MON-YY hh24:MI:SS'')'
    USING TIME;
END;
/

-- Test
-- Kịch bản test: Thực hiện update trên bảng đăng ký như ở yc3
-- Xem dữ liệu lúc đầu
SELECT * FROM N09_DANGKY;
/

-- LÀ TRƯỞNG KHOA: SẼ ĐƯỢC AUDIT
-- Tại có cái PDB nên conn nó có đoạn sau, dùng CDB$ROOT thì bỏ đoạn sau nha chỉ cần CONN NV001/NV001
--(bỏ comment)
--CONN NV001/NV001@//localhost:1521/TEST;
--UPDATE C##ADMIN.N09_DANGKY SET DIEMQT = 8 WHERE MASV = 'SV004';

--Kiểm tra việc ghi dữ liệu FGA (1 row - DB_USER: NV001)
--(bỏ comment)
--SELECT * FROM SYS.N09_FGA;

--lấy dữ liệu time mà hành động mới xảy ra (hoặc muốn trở về trước hành động nào cũng dc) cho vào dưới là sẽ khôi phục được
--(bỏ comment)
--EXEC N09_RECOVERY_DANGKY ('15-JUN-2024 13:43:53')
--select lại thấy dữ liệu vừa được khôi phục trước đó



