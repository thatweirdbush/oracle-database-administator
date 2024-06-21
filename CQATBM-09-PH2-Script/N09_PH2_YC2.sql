-- Lớp: CQ2021/1
-- Nhóm: 09
-- Thành viên:
-- 21120037 - Mã Thùy Anh
-- 21120060 - Nguyễn Long Giang
-- 21120082 - Phan Quốc Huy 
-- 21120117 - Lê Thị Hồng Phượng



/***************************************************************
Yêu cầu 2: Vận dụng mô hình điều khiển truy cập OLS
    •   Giả sử nhân sự của khoa được bổ sung thêm người để vận hành tại 2 cơ sở khác nhau gồm:
    Cơ sở 1 và Cơ sở 2. Khoa muốn thiết lập cho hệ thống chức năng phát tán thông báo, được
    lưu ở bảng THÔNGBÁO(NỘIDUNG), đến những người dùng trong hệ thống tùy vào cấp
    bậc, lĩnh vực hoạt động và vị trí địa lý.
    
    •   Cho biết nhân sự và các dòng thông báo được chia ra làm các cấp bậc sau: Trưởng khoa,
    Trưởng đơn vị, Giảng viên, Giáo vụ và Nhân viên; Độ ưu tiên giảm dần tương ứng là: 
    Trưởng khoa > Trưởng đơn vị > Giảng viên > Giáo vụ > Nhân viên > Sinh viên.

    •   Nội dung thông báo thường tùy thuộc vào lĩnh vực hoạt động của các bộ môn có liên quan,
    gồm: HTTT, CNPM, KHMT, CNTT, TGMT, MMT.

    •   Hãy thiết lập hệ thống nhãn gồm 03 thành phần và điều chỉnh mô hình dữ liệu (nếu cần thiết)
    để hệ thống có thể đáp ứng các yêu cầu sau. Đồng thời, cài đặt chức năng minh hoạ trên ứng dụng.

****************************************************************/
-- Kiểm tra xem OLS đã được cài đặt chưa
SELECT * FROM DBA_REGISTRY WHERE COMP_ID = 'OLS';
/

-- Nếu chưa, cần chạy 2 dòng dưới
BEGIN
    -- This procedure registers Oracle Label Security.
    LBACSYS.CONFIGURE_OLS;
    -- This procedure enables it.
    LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
END;
/

/***************************************************************
Connect to LBACSYS user to grant the necessary privileges to the N09_ADMIN user.
    The N09_ADMIN user will perform all the OLS administration duties.
        The following privileges are therefore required:

****************************************************************/
show con_name;
ALTER SESSION SET CONTAINER = PDB_N09;
ALTER USER LBACSYS IDENTIFIED BY LBACSYS ACCOUNT UNLOCK;

CONN LBACSYS/LBACSYS@//localhost:1521/PDB_N09;
GRANT EXECUTE ON SA_COMPONENTS TO N09_ADMIN;
GRANT EXECUTE ON SA_LABEL_ADMIN TO N09_ADMIN;
GRANT EXECUTE ON SA_USER_ADMIN TO N09_ADMIN;
GRANT EXECUTE ON SA_POLICY_ADMIN TO N09_ADMIN;
GRANT EXECUTE ON SA_AUDIT_ADMIN TO N09_ADMIN;
GRANT EXECUTE ON CHAR_TO_LABEL TO N09_ADMIN;
GRANT EXECUTE ON SA_SYSDBA TO N09_ADMIN;
GRANT EXECUTE ON TO_LBAC_DATA_LABEL TO N09_ADMIN;
GRANT LBAC_DBA TO N09_ADMIN;
/

/***************************************************************
Connect to N09_ADMIN and Create the policy
    The policy will be created with the name "N09_POLICY_THONGBAO".
    The policy will be applied to the "N09_THONGBAO" table.
    The policy will be created with the column "ROW_LABEL".
    The role "N09_POLICY_THONGBAO_DBA" will be granted to the N09_ADMIN user.

****************************************************************/
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
BEGIN
    SA_SYSDBA.DROP_POLICY (
        policy_name => 'N09_POLICY_THONGBAO'
    );
END;
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
BEGIN
    SA_SYSDBA.CREATE_POLICY (
        policy_name => 'N09_POLICY_THONGBAO',
        column_name => 'ROW_LABEL'
    );
END;
/

-- Grant privs and authorization to administer the THONGBAO policy
GRANT N09_POLICY_THONGBAO_DBA TO N09_ADMIN;
/

/***************************************************************
PHAN CHIA LEVEL CHO POLICY
    DO NHAY CAM TANG DAN (10 < 20 < 30 < ...)
        CHIA 6 LEVEL: Truong khoa > Truong don vi > Giang vien > Giao vu > Nhan vien > Sinh vien.

****************************************************************/
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
BEGIN
    -- Level 9000: Truong khoa
    SA_COMPONENTS.CREATE_LEVEL(
        policy_name => 'N09_POLICY_THONGBAO',
        long_name => 'Truong Khoa',
        short_name => 'TKHOA',
        level_num => 9000);

    -- Level 8000: Truong don vi
    SA_COMPONENTS.CREATE_LEVEL(
        policy_name => 'N09_POLICY_THONGBAO',
        long_name => 'Truong Don Vi',
        short_name => 'TDONVI',
        level_num => 8000);

    -- Level 7000: Giang vien
    SA_COMPONENTS.CREATE_LEVEL(
        policy_name => 'N09_POLICY_THONGBAO',
        long_name => 'Giang Vien',
        short_name => 'GVIEN',
        level_num => 7000);

    -- Level 6000: Giao vu
    SA_COMPONENTS.CREATE_LEVEL(
        policy_name => 'N09_POLICY_THONGBAO',
        long_name => 'Giao Vu',
        short_name => 'GVU',
        level_num => 6000);

    -- Level 5000: Nhan vien
    SA_COMPONENTS.CREATE_LEVEL(
        policy_name => 'N09_POLICY_THONGBAO',
        long_name => 'Nhan Vien',
        short_name => 'NVIEN',
        level_num => 5000);

    -- Level 4000: Sinh vien
    SA_COMPONENTS.CREATE_LEVEL(
        policy_name => 'N09_POLICY_THONGBAO',
        long_name => 'Sinh Vien',
        short_name => 'SVIEN',
        level_num => 4000);
END;
/

/***************************************************************
PHAN CHIA COMPARTMENT CHO POLICY
    COMPARTMENT LA LINH VUC CUA POLICY
        CHIA 7 COMPARTMENT: HTTT, CNPM, KHMT, CNTT, TGMT, MMT, ALL
            CAC SO 100, 200,... QUI DINH THU TU HIEN THI

****************************************************************/
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
BEGIN
    -- Compartment 100: He Thong Thong Tin
    SA_COMPONENTS.CREATE_COMPARTMENT(
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'He Thong Thong Tin',
    short_name       => 'HTTT',
    comp_num         =>  100);

    -- Compartment 200: Cong Nghe Phan Mem
    SA_COMPONENTS.CREATE_COMPARTMENT(
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'Cong Nghe Phan Mem',
    short_name       => 'CNPM',
    comp_num         =>  200);

    -- Compartment 300: Khoa Hoc May Tinh
    SA_COMPONENTS.CREATE_COMPARTMENT(
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'Khoa Hoc May Tinh',
    short_name       => 'KHMT',
    comp_num         =>  300);

    -- Compartment 400: Cong Nghe Thong Tin
    SA_COMPONENTS.CREATE_COMPARTMENT(
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'Cong Nghe Thong Tin',
    short_name       => 'CNTT',
    comp_num         =>  400);

    -- Compartment 500: Thi Giac May Tinh
    SA_COMPONENTS.CREATE_COMPARTMENT(
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'Thi Giac May Tinh',
    short_name       => 'TGMT',
    comp_num         =>  500);

    -- Compartment 600: Mang May Tinh
    SA_COMPONENTS.CREATE_COMPARTMENT(
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'Mang May Tinh',
    short_name       => 'MMT',
    comp_num         =>  600);
END;
/

/***************************************************************
PHAN CHIA GROUP CHO POLICY
    GROUP DUNG DE XAC DINH CO QUAN NAO QUAN LI DU LIEU
        GROUP CO CAU TRUC PHAN CAP (1 CHA QUAN LI NHIEU CON)
            CHIA LAM 3 GROUP: CS1, CS2, HCMUS (Parent group)
                CAC SO 100, 200 CHI THU TU HIEN THI

****************************************************************/
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
BEGIN
    -- Group 1: HCMUS (Parent group)
    SA_COMPONENTS.CREATE_GROUP (
        policy_name      => 'N09_POLICY_THONGBAO',
        group_num        => 1,
        short_name       => 'HCMUS',
        long_name        => 'Truong DH Khoa Hoc Tu Nhien VNUHCM',
        parent_name      => NULL);

    -- Group 100: Co So 1 (Child group of HCMUS)
    SA_COMPONENTS.CREATE_GROUP (
        policy_name      => 'N09_POLICY_THONGBAO',
        group_num        => 100,
        short_name       => 'CS1',
        long_name        => 'Co So 1',
        parent_name      => 'HCMUS');
    
    -- Group 200: Co So 2 (Child group of HCMUS)
    SA_COMPONENTS.CREATE_GROUP (
        policy_name      => 'N09_POLICY_THONGBAO',
        group_num        => 200,
        short_name       => 'CS2',
        long_name        => 'Co So 2',
        parent_name      => 'HCMUS');
END;
/

/***************************************************************
Create the labels
    The actual labels are created using the SA_LABEL_ADMIN package.
    The labels are created with the policy name, the tag, and the value.
    The labels are created for the levels, compartments, and groups.

****************************************************************/
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 1, 'TDONVI::CS1,CS2', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 2, 'SVIEN:HTTT:CS1', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 3, 'TDONVI:KHMT:CS1', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 4, 'TDONVI:KHMT:CS1,CS2', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 5, 'NVIEN::CS2', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 6, 'SVIEN::CS1,CS2', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 7, 'GVU:KHMT:CS2', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 8, 'GVU::CS1,CS2', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 9, 'GVU:HTTT:CS1', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 10, 'GVU:HTTT:CS2', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 11, 'TDONVI::CS1', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 12, 'TDONVI::CS2', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 13, 'GVU:KHMT:CS1', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 14, 'TDONVI:HTTT:CS1', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 15, 'TDONVI:HTTT:CS2', TRUE)
EXEC SA_LABEL_ADMIN.CREATE_LABEL ('N09_POLICY_THONGBAO', 16, 'TDONVI:HTTT:CS1,CS2', TRUE)
/

/***************************************************************
Create the user authorizations
    For example, 3 authorizations will be created:
        “ALL_EMPLOYEES”: representing general employees.
        “ALL_MANAGERS”: for managers.
        “ALL_EXECS”: for executives.

****************************************************************/
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
-- Store procedure thiết lập nhãn cho Sinh viên dựa trên vị trí (COSO) và ngành học (MANGANH)
CREATE OR REPLACE PROCEDURE SET_LABELS_FOR_SINHVIEN AS
BEGIN
    FOR sv_record IN (
        SELECT sv.MASV, sv.COSO, sv.MANGANH
        FROM N09_SINHVIEN sv
    ) LOOP
        DECLARE
            v_label VARCHAR2(100);
            v_coso VARCHAR2(30);
        BEGIN
            -- Lấy giá trị của COSO
            IF sv_record.COSO = 'Cơ sở 1' THEN
                v_coso := 'CS1';
            ELSIF sv_record.COSO = 'Cơ sở 2' THEN
                v_coso := 'CS2';
            ELSE
                v_coso := 'HCMUS';
            END IF;

            -- Tạo nhãn dựa trên COSO và MANGANH
            v_label := 'SVIEN:' || sv_record.MANGANH || ':' || v_coso;
            
            -- Gọi procedure SET_USER_LABELS để thiết lập nhãn cho user
            SA_USER_ADMIN.SET_USER_LABELS(
                policy_name => 'N09_POLICY_THONGBAO',
                user_name   => sv_record.MASV,
                max_read_label => v_label
            );
        END;
    END LOOP;
END;
/

-- Store procedure thiết lập nhãn cho Nhân sự dựa trên vị trí (COSO) và lĩnh vực hoạt động (ns.VAITRO & dv.TENDV)
-- NOTE: Ngoại trừ Trưởng khoa & Trưởng đơn vị
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
CREATE OR REPLACE PROCEDURE SET_LABELS_FOR_NHANSU AS
BEGIN
    FOR ns_record IN (
        SELECT nh.MANV, nh.COSO, nh.VAITRO, dv.TENDV
        FROM N09_NHANSU nh
        JOIN N09_DONVI dv ON nh.MADV = dv.MADV
    ) LOOP
        DECLARE
            v_label VARCHAR2(100);
            v_vaitro VARCHAR2(30);
            v_coso VARCHAR2(30);
            v_donvi VARCHAR2(30);
        BEGIN        
            -- Bỏ qua nếu là Trưởng khoa
            IF ns_record.VAITRO = 'Trưởng khoa' OR ns_record.VAITRO = 'Trưởng đơn vị' THEN
                CONTINUE;
            END IF;

            -- Lấy giá trị của VAITRO
            IF ns_record.VAITRO = 'Giảng viên' THEN
                v_vaitro := 'GVIEN';
            ELSIF ns_record.VAITRO = 'Giáo vụ' THEN
                v_vaitro := 'GVU';
            ELSIF ns_record.VAITRO = 'Nhân viên' THEN
                v_vaitro := 'NVIEN';
            END IF;            

            -- Lấy giá trị của COSO
            IF ns_record.COSO = 'Cơ sở 1' THEN
                v_coso := 'CS1';
            ELSIF ns_record.COSO = 'Cơ sở 2' THEN
                v_coso := 'CS2';
            ELSE 
                v_coso := 'HCMUS';
            END IF;

            -- Lấy giá trị của TENDV
            IF ns_record.TENDV LIKE '%HTTT%' THEN
                v_donvi := 'HTTT';
            ELSIF ns_record.TENDV LIKE '%CNPM%' THEN
                v_donvi := 'CNPM';
            ELSIF ns_record.TENDV LIKE '%KHMT%' THEN
                v_donvi := 'KHMT';
            ELSIF ns_record.TENDV LIKE '%CNTT%' THEN
                v_donvi := 'CNTT';
            ELSIF ns_record.TENDV LIKE '%TGMT%' THEN
                v_donvi := 'TGMT';
            ELSIF ns_record.TENDV LIKE '%MMT%' THEN
                v_donvi := 'MMT';
            END IF;

            -- Tạo nhãn dựa trên COSO, VAITRO và TENDV
            v_label := v_vaitro || ':' || v_donvi || ':' || v_coso;
            
            -- Gọi procedure SET_USER_LABELS để thiết lập nhãn cho user
            SA_USER_ADMIN.SET_USER_LABELS(
                policy_name => 'N09_POLICY_THONGBAO',
                user_name   => ns_record.MANV,
                max_read_label => v_label
            );
        END;
    END LOOP;
END;
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
-- Thiết lập nhãn cho riêng Trưởng khoa & Trưởng đơn vị
BEGIN
    -- Label: Truong Khoa
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV001',
        max_read_label => 'TKHOA:HTTT,CNPM,KHMT,CNTT,TGMT,MMT:HCMUS');

    -- Label: Truong Don Vi 1 - HTTT - CS2 
    -- SỬA LABEL PHÙ HỢP CÂU B: 1 số Trưởng bộ môn phụ trách cả 2 cơ sở
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV101',
        max_read_label => 'TDONVI:HTTT:HCMUS');

    -- Label: Truong Don Vi 2 - CNPM & MMT - CS1
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV102',
        max_read_label => 'TDONVI:CNPM,MMT:CS1');

    -- Label: Truong Don Vi 3 - KHMT - CS2
    -- SỬA LABEL PHÙ HỢP CÂU B: 1 số Trưởng bộ môn phụ trách cả 2 cơ sở
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV103',
        max_read_label => 'TDONVI:KHMT:HCMUS');

    -- Label: Truong Don Vi 4 - CNTT - CS1
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV104',
        max_read_label => 'TDONVI:CNTT:CS1');

    -- Label: Truong Don Vi 5 - TGMT - CS2
    -- SỬA LABEL PHÙ HỢP CÂU B: 1 số Trưởng bộ môn phụ trách cả 2 cơ sở
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV105',
        max_read_label => 'TDONVI:TGMT:HCMUS');

    -- Label: Truong Don Vi 6 - HTTT - CS1
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV106',
        max_read_label => 'TDONVI:HTTT:CS1');
END;
/

-- Thiết lập nhãn cho các Nhân sự còn lại
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
EXECUTE SET_LABELS_FOR_NHANSU;
/

-- Thiết lập nhãn cho tất cả Sinh viên
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
EXECUTE SET_LABELS_FOR_SINHVIEN;
/

-- c) Hãy gán nhãn cho 01 Giáo vụ có thể đọc toàn bộ thông báo dành cho giáo vụ.
-- Giáo vụ NV301
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
BEGIN
 SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV301',
        max_read_label => 'GVU:HTTT,CNPM,KHMT,CNTT,TGMT,MMT:HCMUS');
END;
/
                

/***************************************************************
Specific authorizations of OLS
    Some privileges allowed the authorized user to bypass the specific label security
    enforcements:
        - PROFILE ACCESS Allows the user to switch their security profile
        - READ Allows the user to select any data. This is valuable for inspecting labels and
        performing exports of data.
        - WRITE Allows the user to override the OLS protections for each of the label components.
        - FULL This is the shortcut for granting both read and write privileges.

NOTE: This section is currently not required for the assignment.

****************************************************************/
-- -- The N09_ADMIN user can now set the OLS security profile to be any one of 6 authorization “users” just defined.
-- CONN LBACSYS/LBACSYS@//localhost:1521/PDB_N09;
-- EXECUTE SA_USER_ADMIN.SET_USER_PRIVS('N09_POLICY_THONGBAO', 'N09_ADMIN', 'PROFILE_ACCESS');
-- EXECUTE SA_USER_ADMIN.SET_USER_PRIVS('N09_POLICY_THONGBAO', 'N09_ADMIN', 'FULL');
-- /

-- -- N09_ADMIN user resets own profile to NV001 - Truong khoa
-- EXECUTE SA_SESSION.SET_ACCESS_PROFILE('N09_POLICY_THONGBAO', 'NV001');
-- /

-- -- Test relogging
-- CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
-- SELECT *
-- FROM N09_THONGBAO;
-- /

-- -- N09_ADMIN user resets own profile to SV001 - Sinh vien
-- EXECUTE SA_SESSION.SET_ACCESS_PROFILE('N09_POLICY_THONGBAO', 'SV001');

-- -- Test relogging
-- CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
-- SELECT *
-- FROM N09_THONGBAO;
-- /

-- -- To get the label of the current user (NV001 - Truong khoa)
-- CONN NV001/123@//localhost:1521/PDB_N09;
-- COL "Read Label" format a25
-- SELECT SA_SESSION.READ_LABEL('N09_POLICY_THONGBAO') "Read Label"
-- FROM DUAL;
-- /


/***************************************************************
Applying the OLS policy (labels) to the table by executing the
APPLY_TABLE_POLICY procedure of the SA_POLICY_ADMIN package.

    •   To begin, choose the ‘NO_CONTROL’ option indicating that you don’t want
    OLS to enforce any security.
    •   Until the label column values are populated, you’ll not be able to access any
    of the data. That is, OLS returns no records when the label values are
    undefined or are null.
    
****************************************************************/
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
BEGIN
    SA_POLICY_ADMIN.REMOVE_TABLE_POLICY (
        policy_name     => 'N09_POLICY_THONGBAO',
        schema_name     => 'N09_ADMIN',
        table_name      => 'N09_THONGBAO');
END;
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
BEGIN
    SA_POLICY_ADMIN.APPLY_TABLE_POLICY(
        policy_name     => 'N09_POLICY_THONGBAO',
        schema_name     => 'N09_ADMIN',
        table_name      => 'N09_THONGBAO',
        table_options   => 'NO_CONTROL');
END;
/

/***************************************************************
Update the OLS labels in the THONGBAO table.
    N09_ADMIN user will set the values for records by one of the following ways:
        • C1: Assigns manually by using INSERT or UPDATE.
        • C2: Use the option LABEL_DEFAULT.
        • C3: Use the function to assign the labels for records automatically.
    The function will be executed when there are INSERT or UPDATE
    command on the data:
    • We use C1 from now on.

****************************************************************/
---- Set all records to lowest level
--CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
--UPDATE N09_THONGBAO
--SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'SVIEN');
--/
--
---- Increase level for Nhan vien's records
--CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
--UPDATE N09_THONGBAO
--SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'NVIEN')
--WHERE NGUOINHAN = 'NHAN VIEN';
--/
--
---- Increase level for Giang vien's records
--CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
--UPDATE N09_THONGBAO
--SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'GVIEN')
--WHERE NGUOINHAN = 'GIANG VIEN';
--/
--
---- Increase level for Giao vu's records
--CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
--UPDATE N09_THONGBAO
--SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'GVU')
--WHERE NGUOINHAN = 'GIAO VU';
--/
--
---- Increase level for Truong don vi's records
--CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
--UPDATE N09_THONGBAO
--SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'TDONVI')
--WHERE NGUOINHAN = 'TRUONG DON VI';
--/
--
---- Increase level for Truong khoa's records
--CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
--UPDATE N09_THONGBAO
--SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'TKHOA')
--WHERE NGUOINHAN = 'TRUONG KHOA';
--/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'TDONVI::CS1,CS2')
WHERE MATB='TB001'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'SVIEN:HTTT:CS1')
WHERE MATB='TB002'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'TDONVI:KHMT:CS1')
WHERE MATB='TB003'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'TDONVI:KHMT:CS1,CS2')
WHERE MATB='TB004'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'NVIEN::CS2')
WHERE MATB='TB005'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'SVIEN::CS1,CS2')
WHERE MATB='TB006'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'GVU:KHMT:CS2')
WHERE MATB='TB007'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'GVU::CS1,CS2')
WHERE MATB='TB008'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'GVU:HTTT:CS1')
WHERE MATB='TB009'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'TDONVI::CS1')
WHERE MATB='TB010'
/
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'TDONVI::CS2')
WHERE MATB='TB011'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'GVU:KHMT:CS1')
WHERE MATB='TB012'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'GVU:HTTT:CS2')
WHERE MATB='TB013'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'TDONVI:HTTT:CS1')
WHERE MATB='TB014'
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
UPDATE N09_THONGBAO
SET ROW_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'TDONVI:HTTT:CS1,CS2')
WHERE MATB='TB015'
/

COMMIT;
/

/***************************************************************
Re-applying the OLS policy (labels) to the table.
    To change the policy enforcement options, you have to first
    remove the policy with NO_CONTROL enforcement and then re-add it with the
    READ_CONTROL,... enforcement options, which will restrict all select,... operations on the table.

****************************************************************/
CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
BEGIN
    SA_POLICY_ADMIN.REMOVE_TABLE_POLICY (
        policy_name     => 'N09_POLICY_THONGBAO',
        schema_name     => 'N09_ADMIN',
        table_name      => 'N09_THONGBAO');
END;
/

CONN N09_ADMIN/123@//localhost:1521/PDB_N09;
BEGIN
    SA_POLICY_ADMIN.APPLY_TABLE_POLICY (
        policy_name     => 'N09_POLICY_THONGBAO',
        schema_name     => 'N09_ADMIN',
        table_name      => 'N09_THONGBAO',
        table_options   => 'LABEL_DEFAULT,READ_CONTROL,WRITE_CONTROL,CHECK_CONTROL');
END;
/

/***************************************************************
Test the OLS policy
    To test the OLS policy, you can connect to every role-based user and
    execute the SELECT statement on the THONGBAO table.
    The OLS policy will enforce the security and return only the records
    that the user is authorized to see.

Yêu cầu:
a) Hãy gán nhãn cho người dùng là Trưởng khoa có thể đọc được toàn bộ thông báo.
b) Hãy gán nhãn cho các Trưởng bộ môn phụ trách Cơ sở 2 có thể đọc được toàn bộ thông
báo. dành cho trưởng bộ môn không phân biệt vị trí địa lý.
    -- này đi xét từng dòng i
    -- kiếm tra trưởng bộ môn phụ trách 
c) Hãy gán nhãn cho 01 Giáo vụ có thể đọc toàn bộ thông báo dành cho giáo vụ.
    --  1 giáo vụ nào đó TKHOA:HTTT,CNPM,KHMT,CNTT,TGMT,MMT:HCMUS,CS1,CS2
d) Hãy cho biết nhãn của dòng thông báo t1 để t1 được phát tán (đọc) bởi tất cả Trưởng đơn vị.
    -- Nhãn dòng tb t1 là TDONVI
e) Hãy cho biết nhãn của dòng thông báo t2 để phát tán t2 đến Sinh viên thuộc ngành
HTTT học ở Cơ sở 1.
    -- Nhãn dòng thông báo t2 là SV:HTTT:CS1
f) Hãy cho biết nhãn của dòng thông báo t3 để phát tán t3 đến Trưởng bộ môn KHMT ở Cơ sở 1.
    -- Nhãn dòng thông báo t3 là TDONVI
g) Cho biết nhãn của dòng thông báo t4 để phát tán t4 đến Trưởng bộ môn KHMT ở Cơ
sở 1 và Cơ sở 2.
    -- Nhãn dòng thông báo t4 TDONVI:KHMT:CS1,CS2 
h) Em hãy cho thêm 3 chính sách phát tán dòng dữ liệu nữa trên mô hình OLS đã cài đặt.
    -- Nhãn dòng thông báo t5
    -- Nhãn dòng thông báo t6
    -- Nhãn dòng thông báo t7 
    (kiểm tra mấy dòng trong bảng thông báo là dc)

****************************************************************/
-- a. Hãy gán nhãn cho người dùng là Trưởng khoa có thể đọc được toàn bộ thông báo.
-- Đọc được tất cả 15 dòng trong bảng Thông báo
CONN NV001/NV001@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO;
/

-- Xem nhãn của Trưởng khoa
-- Nhãn:
-- TKHOA:HTTT,CNPM,KHMT,CNTT,TGMT,MMT:HCMUS,CS1,CS2
CONN NV001/NV001@//localhost:1521/PDB_N09;
COL "Read Label" format a25
SELECT SA_SESSION.READ_LABEL('N09_POLICY_THONGBAO') "Read Label"
FROM DUAL;
/


-- b. Hãy gán nhãn cho các Trưởng bộ môn phụ trách Cơ sở 2 có thể đọc được toàn bộ thông
-- báo dành cho Trưởng bộ môn không phân biệt vị trí địa lý.
-- Test Trưởng đơn vị NV101 - HTTT - CS2
-- Đọc được 5 dòng: 2 dòng HTTT, 3 dòng ALL
CONN NV101/NV101@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'TRUONG DON VI';
/

-- Test Trưởng đơn vị NV103 - KHMT - CS2
-- Đọc được 5 dòng: 2 dòng KHMT, 3 dòng ALL
CONN NV103/NV103@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'TRUONG DON VI';
/

-- Test Trưởng đơn vị NV105 - TGMT - CS2
-- Đọc được 3 dòng: 3 dòng ALL
CONN NV105/NV105@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'TRUONG DON VI';
/


-- c. Hãy gán nhãn cho 01 Giáo vụ có thể đọc toàn bộ thông báo dành cho giáo vụ.
-- Giáo vụ NV301 có nhãn:
-- GVU:HTTT,CNPM,KHMT,CNTT,TGMT,MMT:HCMUS,CS1,CS2
-- Đọc được tất cả 5 dòng của Giáo vụ
CONN NV301/NV301@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'GIAO VU';
/


-- d. Hãy cho biết nhãn của dòng thông báo t1 để t1 được phát tán (đọc) bởi tất cả Trưởng đơn vị.
-- Nhãn: 
-- TDONVI::CS1,CS2
CONN NV001/NV001@//localhost:1521/PDB_N09;
SELECT label_to_char (row_label)
FROM N09_ADMIN.N09_THONGBAO
WHERE MATB = 'TB001'

-- Test bằng user Trưởng đơn vị NV102 - CNPM - CS1
-- Đọc được 2 dòng: ALL Lĩnh vực
CONN NV102/NV102@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'TRUONG DON VI';
/


-- e. Hãy cho biết nhãn của dòng thông báo t2 để phát tán t2 đến Sinh viên thuộc ngành HTTT học ở Cơ sở 1.
-- Nhãn:
-- SVIEN:HTTT:CS1
CONN NV001/NV001@//localhost:1521/PDB_N09;
SELECT label_to_char (row_label)
FROM N09_ADMIN.N09_THONGBAO
WHERE MATB = 'TB002'
/

-- Test sinh viên SV031 - HTTT - CS1 (đọc thành công: 2 dòng - tất cả dòng của Sinh viên)
CONN SV031/SV031@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO;
/

-- Test sinh viên SV001 - CNTT - CS2 (đọc thành công: 1 dòng)
CONN SV002/SV002@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO;
/


-- f. Hãy cho biết nhãn của dòng thông báo t3 để phát tán t3 đến Trưởng bộ môn KHMT ở Cơ sở 1.
-- Nhãn:
-- TDONVI:KHMT:CS1
CONN NV001/NV001@//localhost:1521/PDB_N09;
SELECT label_to_char (row_label)
FROM N09_ADMIN.N09_THONGBAO
WHERE MATB = 'TB003'
/

-- Test Trưởng đơn vị NV106 - HTTT - CS1 (đọc thành công: 4 dòng)
CONN NV106/NV106@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'TRUONG DON VI';
/


-- g. Cho biết nhãn của dòng thông báo t4 để phát tán t4 đến Trưởng bộ môn KHMT ở Cơ sở 1 và Cơ sở 2
-- Nhãn:
-- TDONVI:KHMT:CS1,CS2
CONN NV001/NV001@//localhost:1521/PDB_N09;
SELECT label_to_char (row_label)
FROM N09_ADMIN.N09_THONGBAO
WHERE MATB = 'TB004'
/

-- Test Trưởng đơn vị NV106 - HTTT - CS1 (đọc thành công: 2 dòng KHMT, 2 dòng ALL lĩnh vực)
CONN NV106/NV106@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'TRUONG DON VI';
/

-- Test Trưởng đơn vị NV103 - KHMT - CS2 (đọc thành công: 5 dòng)
CONN NV103/NV103@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'TRUONG DON VI';
/


-- h. Em hãy cho thêm 3 chính sách phát tán dòng dữ liệu nữa trên mô hình OLS đã cài đặt.
-- Dòng t5: Thông báo phát tán đến nhân viên ở CS2 không phân biệt lĩnh vực.
-- Nhãn của dòng thông báo t5:
-- NVIEN::CS2
CONN NV001/NV001@//localhost:1521/PDB_N09;
SELECT label_to_char (row_label)
FROM N09_ADMIN.N09_THONGBAO
WHERE MATB = 'TB005'
/

-- Test Nhân viên NV401 - CS2 (đọc thành công: 1 dòng)
CONN NV401/NV401@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'NHAN VIEN';
/

-- Test Nhân viên NV402 - CS1 (không đọc được)
CONN NV402/NV402@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'NHAN VIEN';
/


-- Dòng t6: Thông báo được gửi đến tất cả Sinh viên không phân biệt lĩnh vực hay cơ sở.
-- Nhãn của dòng thông báo t6:
-- SVIEN::CS1,CS2
CONN NV001/NV001@//localhost:1521/PDB_N09;
SELECT label_to_char (row_label)
FROM N09_ADMIN.N09_THONGBAO
WHERE MATB = 'TB006'
/

-- Test Sinh viên SV001 - CNTT - CS2 (đọc thành công: 1 dòng)
CONN SV001/SV001@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO;
/


-- Dòng t7: Thông báo được gửi đến Giáo vụ Bộ môn KHMT tại Cơ sở 2
-- Nhãn của dòng thông báo t7:
-- GVU:KHMT:CS2
CONN NV001/NV001@//localhost:1521/PDB_N09;
SELECT label_to_char (row_label)
FROM N09_ADMIN.N09_THONGBAO
WHERE MATB = 'TB007'
/

-- Test Giáo vụ NV303 - KHMT - CS2 (đọc thành công: 2 dòng)
CONN NV303/NV303@//localhost:1521/PDB_N09;
SELECT * FROM N09_ADMIN.N09_THONGBAO
WHERE NGUOINHAN = 'GIAO VU';
/



