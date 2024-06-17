-- Lớp: CQ2021/1
-- Nhóm: 09
-- Thành viên:
-- 21120037 - Mã Thùy Anh
-- 21120060 - Nguyễn Long Giang
-- 21120082 - Phan Quốc Huy 
-- 21120117 - Lê Thị Hồng Phượng



/***************************************************************
CHU Y KHONG TAO BANG N09_THONGBAO TRUOC. PHAI TAO POLICY DAU TIEN
    TAO USER OLS_TEST

****************************************************************/
CONN SYS/244466666@XE AS SYSDBA;
ALTER SESSION SET CONTAINER = CDB$ROOT;
/
CONN OLS_TEST/1@//localhost:1521/TEST
SELECT name, pdb FROM v$services ORDER BY name;
SHOW CON_NAME;
/
-- KIEM TRA XEM OLS DA DUOC CAI DAT CHUA
SELECT * FROM DBA_REGISTRY WHERE COMP_ID = 'OLS';
/
-- NEU CHUA KHOI TAO OLS THI CHAY 2 DONG NAY
-- NEU KHONG THE CHAY DUOC 2 DONG NAY THI KIEM TRA XEM ORACLE 21C DA BAT DUOC OLS CHUA
BEGIN
    -- This procedure registers Oracle Label Security.
    LBACSYS.CONFIGURE_OLS;
    -- This procedure enables it.
    LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
END;
/

/***************************************************************
Create the OLS_TEST user
    The OLS_TEST user will be used to create the policy and the labels.
    The user will also be used to create the levels, compartments, and groups.
    The user will be granted the necessary privileges to administer the policy.

****************************************************************/
CONN SYS/244466666@//localhost:1521/TEST AS SYSDBA;
ALTER SESSION SET CONTAINER = TEST;
/
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
/
DROP USER OLS_TEST CASCADE;
/
CREATE USER OLS_TEST IDENTIFIED BY 1 CONTAINER = CURRENT
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
/
GRANT CONNECT, RESOURCE, SELECT_CATALOG_ROLE TO OLS_TEST;
/

/***************************************************************
Connect to LBACSYS user to grant the necessary privileges to the OLS_TEST user.
The SEC_MGR will perform all the OLS administration duties.
    The following privileges are therefore required:

****************************************************************/
ALTER USER LBACSYS IDENTIFIED BY LBACSYS ACCOUNT UNLOCK;
CONN LBACSYS/LBACSYS;
GRANT EXECUTE ON SA_COMPONENTS TO OLS_TEST;
GRANT EXECUTE ON SA_LABEL_ADMIN TO OLS_TEST;
GRANT EXECUTE ON SA_USER_ADMIN TO OLS_TEST;
GRANT EXECUTE ON SA_POLICY_ADMIN TO OLS_TEST;
GRANT EXECUTE ON SA_AUDIT_ADMIN TO OLS_TEST;
GRANT EXECUTE ON CHAR_TO_LABEL TO OLS_TEST;
GRANT EXECUTE ON SA_SYSDBA TO OLS_TEST;
GRANT EXECUTE ON TO_LBAC_DATA_LABEL TO OLS_TEST;
GRANT LBAC_DBA TO OLS_TEST;
/

/***************************************************************
Connect to OLS_TEST and Create the policy
    The policy will be created with the name "N09_POLICY_THONGBAO".
    The policy will be applied to the "N09_THONGBAO" table.
    The policy will be created with the column "ROW_LABEL".
    The role "N09_POLICY_THONGBAO_DBA" will be granted to the OLS_TEST user.

****************************************************************/
CONN OLS_TEST/1@//localhost:1521/TEST;
BEGIN
    SA_SYSDBA.DROP_POLICY (
        policy_name => 'N09_POLICY_THONGBAO'
    );
END;
/

CONN OLS_TEST/1@//localhost:1521/TEST;
CONN LBACSYS/LBACSYS@//localhost:1521/TEST;
BEGIN
    SA_SYSDBA.CREATE_POLICY (
        policy_name => 'N09_POLICY_THONGBAO',
        column_name => 'ROW_LABEL'
    );
END;
/

-- Grant privs and authorization to administer the THONGBAO policy
CONN LBACSYS/LBACSYS@//localhost:1521/TEST;
GRANT N09_POLICY_THONGBAO_DBA TO OLS_TEST;
/

/***************************************************************
PHAN CHIA LEVEL CHO POLICY
    DO NHAY CAM TANG DAN (10 < 20 < 30 < ...)
        CHIA 6 LEVEL: Truong khoa > Truong don vi > Giang vien > Giao vu > Nhan vien > Sinh vien.

****************************************************************/
CONN OLS_TEST/1@//localhost:1521/TEST;
-- TRUONG KHOA
EXECUTE SA_COMPONENTS.CREATE_LEVEL('N09_POLICY_THONGBAO', 9000, 'TKHOA', 'Truong Khoa'); 
/
-- TRUONG DON VI
EXECUTE SA_COMPONENTS.CREATE_LEVEL('N09_POLICY_THONGBAO', 8000, 'TDONVI', 'Truong Don Vi'); 
/
-- GIANG VIEN
EXECUTE SA_COMPONENTS.CREATE_LEVEL('N09_POLICY_THONGBAO', 7000, 'GVIEN', 'Giang Vien');
/
-- GIAO VU
EXECUTE SA_COMPONENTS.CREATE_LEVEL('N09_POLICY_THONGBAO', 6000, 'GVU', 'Giao Vu'); 
/
-- NHAN VIEN
EXECUTE SA_COMPONENTS.CREATE_LEVEL('N09_POLICY_THONGBAO', 5000, 'NVIEN', 'Nhan Vien'); 
/
-- SINH VIEN
EXECUTE SA_COMPONENTS.CREATE_LEVEL('N09_POLICY_THONGBAO', 4000, 'SVIEN', 'Sinh Vien'); 
/

/***************************************************************
PHAN CHIA COMPARTMENT CHO POLICY
    COMPARTMENT LA LINH VUC CUA POLICY
        CHIA 7 COMPARTMENT: HTTT, CNPM, KHMT, CNTT, TGMT, MMT, ALL
            CAC SO 100, 200,... QUI DINH THU TU HIEN THI

****************************************************************/
CONN OLS_TEST/1@//localhost:1521/TEST;
BEGIN
  SA_COMPONENTS.CREATE_COMPARTMENT (
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'He Thong Thong Tin',
    short_name       => 'HTTT',
    comp_num         =>  100);

  SA_COMPONENTS.CREATE_COMPARTMENT (
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'Cong Nghe Phan Mem',
    short_name       => 'CNPM',
    comp_num         =>  200);

    SA_COMPONENTS.CREATE_COMPARTMENT (
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'Khoa Hoc May Tinh',
    short_name       => 'KHMT',
    comp_num         =>  300);

    SA_COMPONENTS.CREATE_COMPARTMENT (
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'Cong Nghe Thong Tin',
    short_name       => 'CNTT',
    comp_num         =>  400);

    SA_COMPONENTS.CREATE_COMPARTMENT (
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'Thi Giac May Tinh',
    short_name       => 'TGMT',
    comp_num         =>  500);

    SA_COMPONENTS.CREATE_COMPARTMENT (
    policy_name      => 'N09_POLICY_THONGBAO',
    long_name        => 'Mang May Tinh',
    short_name       => 'MMT',
    comp_num         =>  600);

    -- SA_COMPONENTS.CREATE_COMPARTMENT (
    -- policy_name      => 'N09_POLICY_THONGBAO',
    -- long_name        => 'Tat ca',
    -- short_name       => 'ALL',
    -- comp_num         =>  700);
END;
/

/***************************************************************
PHAN CHIA GROUP CHO POLICY
    GROUP DUNG DE XAC DINH CO QUAN NAO QUAN LI DU LIEU
        GROUP CO CAU TRUC PHAN CAP (1 CHA QUAN LI NHIEU CON)
            CHIA LAM 3 GROUP: CS1, CS2, HCMUS (Parent group)
                CAC SO 100, 200 CHI THU TU HIEN THI

****************************************************************/
CONN OLS_TEST/1@//localhost:1521/TEST;
BEGIN
    SA_COMPONENTS.CREATE_GROUP (
        policy_name      => 'N09_POLICY_THONGBAO',
        group_num        => 1,
        short_name       => 'HCMUS',
        long_name        => 'Truong_DH_Khoa_Hoc_Tu_Nhien_VNUHCM',
        parent_name      => NULL);

    SA_COMPONENTS.CREATE_GROUP (
        policy_name      => 'N09_POLICY_THONGBAO',
        group_num        => 100,
        short_name       => 'CS1',
        long_name        => 'Co_So_1',
        parent_name      => 'HCMUS');
    
    SA_COMPONENTS.CREATE_GROUP (
        policy_name      => 'N09_POLICY_THONGBAO',
        group_num        => 200,
        short_name       => 'CS2',
        long_name        => 'Co_So_2',
        parent_name      => 'HCMUS');
    
    -- SA_COMPONENTS.CREATE_GROUP (
    -- policy_name      => 'N09_POLICY_THONGBAO',
    -- group_num        => 300,
    -- short_name       => 'A',
    -- long_name        => 'ALL');
END;
/

/***************************************************************
Create the labels

****************************************************************/
CONN OLS_TEST/1@//localhost:1521/TEST;
BEGIN
    SA_LABEL_ADMIN.CREATE_LABEL(
        policy_name => 'N09_POLICY_THONGBAO',
        label_tag   => 1,
        label_value  => 'TKHOA');

    SA_LABEL_ADMIN.CREATE_LABEL(
        policy_name => 'N09_POLICY_THONGBAO',
        label_tag   => 2,
        label_value  => 'TDONVI');

    SA_LABEL_ADMIN.CREATE_LABEL(
        policy_name => 'N09_POLICY_THONGBAO',
        label_tag   => 3,
        label_value  => 'GVIEN');

    SA_LABEL_ADMIN.CREATE_LABEL(
        policy_name => 'N09_POLICY_THONGBAO',
        label_tag   => 4,
        label_value  => 'GVU');

    SA_LABEL_ADMIN.CREATE_LABEL(
        policy_name => 'N09_POLICY_THONGBAO',
        label_tag   => 5,
        label_value  => 'NVIEN');

    SA_LABEL_ADMIN.CREATE_LABEL(
        policy_name => 'N09_POLICY_THONGBAO',
        label_tag   => 6,
        label_value  => 'SVIEN');
END;
/

/***************************************************************
Create the user authorizations
    3 authorizations will be created:
        “ALL_EMPLOYEES”: representing general employees.
        “ALL_MANAGERS”: for managers.
        “ALL_EXECS”: for executives.

****************************************************************/
CONN OLS_TEST/1@//localhost:1521/TEST;
BEGIN
    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV001',
        max_read_label => 'TKHOA:HTTT,CNPM,KHMT,CNTT,TGMT,MMT:HCMUS');

    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV101',
        max_read_label => 'TDONVI');

    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV201',
        max_read_label => 'GVIEN');

    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV301',
        max_read_label => 'GVU');

    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV401',
        max_read_label => 'NVIEN');

    SA_USER_ADMIN.SET_USER_LABELS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'SV001',
        max_read_label => 'SVIEN');
END;
/

/***************************************************************
Authorizations for Compartments & Groups
    For TRUONGKHOA, modify the current authorization to add 
    the new compartments & groups using SA_USER_ADMIN package
****************************************************************/
CONN OLS_TEST/1@//localhost:1521/TEST;
BEGIN
    SA_USER_ADMIN.ADD_COMPARTMENTS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV001',
        comps => 'HTTT,CNPM,KHMT,CNTT,TGMT,MMT');

    SA_USER_ADMIN.ADD_GROUPS(
        policy_name => 'N09_POLICY_THONGBAO',
        user_name   => 'NV001',
        groups => 'HCMUS');
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

****************************************************************/
-- The SEC_MGR can now set the OLS security profile to be any one of 6 authorization “users” just defined.
CONN LBACSYS/LBACSYS;
EXECUTE SA_USER_ADMIN.SET_USER_PRIVS('N09_POLICY_THONGBAO', 'OLS_TEST', 'PROFILE_ACCESS');
EXECUTE SA_USER_ADMIN.SET_USER_PRIVS('N09_POLICY_THONGBAO', 'OLS_TEST', 'FULL');
/

-- SEC_MGR resets own profile to ALL_NHANVIEN
EXECUTE SA_SESSION.SET_ACCESS_PROFILE('N09_POLICY_THONGBAO', 'ALL_NHANVIEN');
/

-- Test relogging
CONN OLS_TEST/1@//localhost:1521/TEST;
SELECT *
FROM N09_THONGBAO;
/

-- SEC_MGR resets own profile to ALL_TRUONGDONVI
EXECUTE SA_SESSION.SET_ACCESS_PROFILE('N09_POLICY_THONGBAO', 'ALL_TRUONGDONVI');

-- Test relogging
CONN OLS_TEST/1@//localhost:1521/TEST;
SELECT *
FROM N09_THONGBAO;
/

-- To get the label of the current user
COL "Read Label" format a25
SELECT SA_SESSION.READ_LABEL('N09_POLICY_THONGBAO') "Read Label"
FROM DUAL;
/





----------------------------
-- NEU KHONG INSERT DUOC VAO BANG N09_THONGBAO THI CHAY DONG NAY
-- ALTER USER OLS_TEST quota unlimited on USERS;
----------------------------
CONN SYS/244466666@//localhost:1521/TEST  AS SYSDBA
ALTER USER OLS_TEST quota unlimited on USERS;


-- CAI POLICY XONG MOI TAO BANG
CONN OLS_TEST/1@//localhost:1521/TEST;
DROP TABLE N09_THONGBAO CASCADE CONSTRAINTS;


-- DROP TABLE N09_THONGBAO CASCADE CONSTRAINTS;
-- TAO BANG LUU THONG BAO
CREATE TABLE N09_THONGBAO
(
    MATB CHAR(5),
    TENTB NVARCHAR2(100),
    NGAYGUI DATE,
    NGUOINHAN NVARCHAR2(100),
    LINHVUC CHAR(4),
    COSO NVARCHAR2(30),
    NOIDUNG NVARCHAR2(1000),
    
    PRIMARY KEY(MATB)
);


CONN OLS_TEST/1@//localhost:1521/TEST;
GRANT SELECT, INSERT, UPDATE, DELETE ON N09_THONGBAO TO PUBLIC;


CONN OLS_TEST/1@//localhost:1521/TEST;
INSERT INTO N09_THONGBAO (MATB, TENTB, NGAYGUI, NGUOINHAN, LINHVUC, COSO, NOIDUNG) VALUES ('TB001', 'THONG BAO NGHI HOC TUAN 2', TO_DATE('2024-06-03', 'YYYY-MM-DD'), 'SINH VIEN', 'HTTT', 'Cơ sở 2', 'DO NHA TRUONG DANG TO CHUC BUOI VAN DAP BAO VE DO AN NEN SINH VIEN, GIANG VIEN KHOA HTTT DUOC NGHI VAO TUAN 2');
INSERT INTO N09_THONGBAO (MATB, TENTB, NGAYGUI, NGUOINHAN, LINHVUC, COSO, NOIDUNG) VALUES ('TB002', 'THONG BAO HOP NHAN SU NGAY 24/6/2024', TO_DATE('2024-06-03', 'YYYY-MM-DD'), 'NHAN VIEN', 'ALL', NULL, 'HOP NHAN SU GAP VAO NGAY 24/6/2024 LUC 17H. DE NGHI CAC NHAN VIEN DEN DAY DU');
INSERT INTO N09_THONGBAO (MATB, TENTB, NGAYGUI, NGUOINHAN, LINHVUC, COSO, NOIDUNG) VALUES ('TB003', 'THONG BAO NOP BAO CAO TINH HINH HOC TAP SINH VIEN', TO_DATE('2024-06-03', 'YYYY-MM-DD'), 'GIAO VU', 'ALL', NULL, 'BO PHAN GIAO VU NOP BANG THONG KE TINH HINH HOC TAP SINH VIEN VAO TUAN SAU');
INSERT INTO N09_THONGBAO (MATB, TENTB, NGAYGUI, NGUOINHAN, LINHVUC, COSO, NOIDUNG) VALUES ('TB004', 'THONG BAO NOP BANG DIEM BO MON CNPM', TO_DATE('2024-06-03', 'YYYY-MM-DD'), 'GIANG VIEN', 'CNPM', NULL, 'CAC GIANG VIEN BO MON CNPM NOP LAI BANG DIEM CUOI KI TRUOC NGAY 30/6/2024');
INSERT INTO N09_THONGBAO (MATB, TENTB, NGAYGUI, NGUOINHAN, LINHVUC, COSO, NOIDUNG) VALUES ('TB005', 'THONG BAO HOP TRUONG DON VI', TO_DATE('2024-06-03', 'YYYY-MM-DD'), 'TRUONG DON VI', 'ALL', NULL, 'CAC TRUONG DON VI CUA CAC KHOA HOP GAP NGAY HOM NAY');
INSERT INTO N09_THONGBAO (MATB, TENTB, NGAYGUI, NGUOINHAN, LINHVUC, COSO, NOIDUNG) VALUES ('TB006', 'THONG BAO HOP TRUONG KHOA', TO_DATE('2024-06-03', 'YYYY-MM-DD'), 'TRUONG KHOA', 'ALL', NULL, 'CAC TRUONG KHOA HOP GAP NGAY HOM NAY');
INSERT INTO N09_THONGBAO (MATB, TENTB, NGAYGUI, NGUOINHAN, LINHVUC, COSO, NOIDUNG) VALUES ('TB007', 'THONG BAO NGHI HOC TUAN 3', TO_DATE('2024-06-03', 'YYYY-MM-DD'), 'SINH VIEN', 'CNTT', 'Cơ sở 1', 'DO NHA TRUONG DANG TO CHUC BUOI VAN DAP BAO VE DO AN NEN SINH VIEN, GIANG VIEN KHOA CNTT DUOC NGHI VAO TUAN 3');

CONN OLS_TEST/1@//localhost:1521/TEST;
COMMIT;




CONN OLS_TEST/1@//localhost:1521/TEST;
-- TAO CHUC NANG CUA LABEL
CREATE OR REPLACE FUNCTION UF_N09_GET_NOTI_LABEL(
    P_NGNHAN IN NVARCHAR2,
    P_LINHVUC IN CHAR,
    P_COSO IN CHAR
    )
    RETURN LBACSYS.LBAC_LABEL AS 
    P_LABEL VARCHAR2(50);
    BEGIN
        -- LABEL NGUOI NHAN
        IF P_NGNHAN = 'TRUONG KHOA' THEN
            P_LABEL := 'LVLTK:';
        ELSIF P_NGNHAN = 'TRUONG DON VI' THEN
            P_LABEL := 'LVLTDV:';
        ELSIF P_NGNHAN = 'GIANG VIEN' THEN
            P_LABEL := 'LVLGVIEN:';
        ELSIF P_NGNHAN = 'GIAO VU' THEN
            P_LABEL := 'LVLGVU:';
        ELSIF P_NGNHAN = 'NHAN VIEN' THEN
            P_LABEL := 'LVLNV:';
        ELSE 
            P_LABEL := 'LVLSV:';
        END IF;
        -- LABEL LINH VUC
        IF P_LINHVUC = 'HTTT' THEN
            P_LABEL := P_LABEL || 'H:';
        ELSIF P_LINHVUC = 'CNPM' THEN
            P_LABEL := P_LABEL || 'CP:';
        ELSIF P_LINHVUC = 'KHMT' THEN
            P_LABEL := P_LABEL || 'K:';
        ELSIF P_LINHVUC = 'CNTT' THEN
            P_LABEL := P_LABEL || 'CT:';
        ELSIF P_LINHVUC = 'TGMT' THEN
            P_LABEL := P_LABEL || 'T:';
        ELSIF P_LINHVUC = 'MMT' THEN
            P_LABEL := P_LABEL || 'M:';
        ELSE 
            P_LABEL := P_LABEL || 'A:';
        END IF;
        -- LABEL CO SO
        IF P_COSO = 'CS1' THEN
            P_LABEL := P_LABEL || 'CS1';
        ELSIF P_COSO = 'CS2' THEN
            P_LABEL := P_LABEL || 'CS2';
        ELSE
            P_LABEL := P_LABEL || 'A';
        END IF;
        RETURN TO_LBAC_DATA_LABEL('N09_POLICY_THONGBAO', P_LABEL);
    END UF_N09_GET_NOTI_LABEL;
/

-- AP DUNG POLICY CHO BANG N09_THONGBAO
CONN OLS_TEST/1@//localhost:1521/TEST;
BEGIN
    SA_POLICY_ADMIN.APPLY_TABLE_POLICY(
        policy_name     => 'N09_POLICY_THONGBAO',
        schema_name     => 'OLS_TEST',
        table_name      => 'N09_THONGBAO',
        table_options   => 'NO_CONTROL');
END;
/




CONN OLS_TEST/1@//localhost:1521/TEST;
-- KHOI TAO NHAN
UPDATE N09_THONGBAO
SET NOTI_LABEL = CHAR_TO_LABEL('N09_POLICY_THONGBAO', 'LVLTK');
COMMIT;




CONN OLS_TEST/1@//localhost:1521/TEST;
-- AP DUNG LAI CHINH SACH
BEGIN
    SA_POLICY_ADMIN.REMOVE_TABLE_POLICY(
        policy_name     => 'N09_POLICY_THONGBAO',
        schema_name     => 'OLS_TEST',
        table_name      => 'N09_THONGBAO');
END;



-- Test
CONN OLS_TEST/1@//localhost:1521/TEST;
SELECT * FROM N09_THONGBAO



CONN OLS_TEST/1@//localhost:1521/TEST;
GRANT SELECT ON LBACSYS.OLS$POLICY_LABELS TO OLS_TEST;
GRANT SELECT, INSERT, UPDATE ON N09_THONGBAO TO OLS_TEST;



CONN OLS_TEST/1@//localhost:1521/TEST;
BEGIN
    SA_POLICY_ADMIN.APPLY_TABLE_POLICY (
        policy_name     => 'N09_POLICY_THONGBAO',
        schema_name     => 'OLS_TEST',
        table_name      => 'N09_THONGBAO',
        table_options   => 'LABEL_DEFAULT,READ_CONTROL,WRITE_CONTROL,CHECK_CONTROL',
        label_function  => 'OLS_TEST.UF_N09_GET_NOTI_LABEL',
        predicate       => NULL);
END;
/


------------------------
CONN OLS_TEST/1@//localhost:1521/TEST;
DECLARE
    P_NGNHAN NVARCHAR2(100) := 'TRUONG KHOA'; 
    P_LINHVUC CHAR(4) := 'HTTT'; 
    P_COSO CHAR(3) := 'CS1';
    P_RESULT LBACSYS.LBAC_LABEL;
BEGIN
    P_RESULT := UF_N09_GET_NOTI_LABEL(P_NGNHAN, P_LINHVUC, P_COSO);
END;
/
------------------------




CONN SYS/244466666 AS SYSDBA
GRANT CONNECT TO NV001, NV101, NV102, NV103, NV104, NV105;
/

--CONN OLS_TEST/1@//localhost:1521/TEST;
--CREATE USER NV001 IDENTIFIED BY NV001;
--CREATE USER NV101 IDENTIFIED BY NV001;
--GRANT CONNECT TO NV001;
--GRANT CONNECT TO NV001;
---------------------------





-- CAU D
-- CHO BIET LABEL CUA DONG THONG BAO DUOC DOC BOI TAT CA TRUONG DON VI
CONN NV101/NV101
SELECT * FROM N09_THONGBAO;
/
-- INSERT INTO N09_SINHVIEN (MASV, HOTEN, PHAI, NGSINH, DIACHI, DT, MACT, MANGANH, SOTCTL, DTBTL) VALUES ('SV031', 'Nguy?n Th? Lan', 'N?', TO_DATE('2000-01-01', 'YYYY-MM-DD'), '123 L� L?i, Ph� Nhu?n, TP. H? Ch� Minh', '0911234588', 'CQ', 'HTTT', 100, 8.5);
-- CAU E
-- CHO BIET LABEL CUA DONG THONG BAO PHAT TAN DEN SV HTTT CS1
-- GIA SU SV031 HOC NGANH HTTT TAI CS1
CONN SV031/SV031
SELECT * FROM N09_THONGBAO;

