-- =====================================================================
--  PROJECT MANPOWER & PROCUREMENT DATABASE  (SQL learning / portfolio sample)
--  All names, IDs and amounts are FICTIONAL demo data.
--  Works in SQLite (DB Browser for SQLite, sqliteonline.com).
--
--  Is file ke 3 hisse hain:
--    PART 1  CREATE TABLE  -> tables (Excel ki sheets jaisi) banana
--    PART 2  INSERT        -> tables mein data dalna
--    PART 3  SELECT        -> sawal poochna (reports nikalna)
-- =====================================================================

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS purchase_orders;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- =====================================================================
-- PART 1 : CREATE TABLE  (har table ke columns aur un ki type pehle se fix)
-- =====================================================================

CREATE TABLE departments (
    dept_id     INTEGER PRIMARY KEY,          -- har row ka unique number
    dept_name   TEXT    NOT NULL UNIQUE       -- khaali nahi ho sakta, dohra nahi sakta
);

CREATE TABLE employees (
    emp_id        INTEGER PRIMARY KEY,        -- Employee ID (unique)
    full_name     TEXT    NOT NULL,
    nationality   TEXT,
    dept_id       INTEGER NOT NULL REFERENCES departments(dept_id),  -- link to departments
    category      TEXT    CHECK (category IN ('Staff','Labor')),
    join_date     DATE    NOT NULL,
    status        TEXT    NOT NULL CHECK (status IN ('Active','Released')),
    release_date  DATE                         -- khaali ho sakta hai (NULL)
);

CREATE TABLE suppliers (
    supplier_id   INTEGER PRIMARY KEY,
    supplier_name TEXT NOT NULL,
    country       TEXT
);

CREATE TABLE purchase_orders (
    po_no         TEXT    PRIMARY KEY,        -- e.g. DEMO-PO-1001
    supplier_id   INTEGER NOT NULL REFERENCES suppliers(supplier_id),
    requester_id  INTEGER NOT NULL REFERENCES employees(emp_id),
    description   TEXT,
    po_date       DATE    NOT NULL,
    amount_sar    REAL    NOT NULL CHECK (amount_sar > 0)
);

CREATE TABLE payments (
    payment_id    INTEGER PRIMARY KEY,
    po_no         TEXT    NOT NULL REFERENCES purchase_orders(po_no),
    pr_no         TEXT    NOT NULL,           -- e.g. DEMO-PO-1001-PR-1
    pay_date      DATE    NOT NULL,
    amount_sar    REAL    NOT NULL,
    status        TEXT    CHECK (status IN ('Paid','Pending','Rejected'))
);

-- =====================================================================
-- PART 2 : INSERT  (data dalna)
-- =====================================================================

INSERT INTO departments (dept_id, dept_name) VALUES
    (1, 'Management'),
    (2, 'Tunnelling'),
    (3, 'Logistics'),
    (4, 'QA/QC'),
    (5, 'HSE'),
    (6, 'Procurement'),
    (7, 'Finance'),
    (8, 'Document Control');

INSERT INTO employees (emp_id, full_name, nationality, dept_id, category, join_date, status, release_date) VALUES
    (5001, 'Imran Haider', 'Pakistan', 8, 'Staff', '2024-02-17', 'Active', '2026-10-30'),
    (5002, 'Burak Aydin', 'Turkiye', 3, 'Labor', '2025-08-07', 'Released', '2026-06-08'),
    (5003, 'Murat Demir', 'Turkiye', 4, 'Staff', '2025-10-16', 'Released', '2026-05-23'),
    (5004, 'Rakesh Kumar', 'India', 3, 'Labor', '2025-05-23', 'Active', '2026-12-31'),
    (5005, 'Yasir Raza', 'Pakistan', 3, 'Labor', '2025-01-05', 'Released', '2025-11-05'),
    (5006, 'Asif Hussain', 'Pakistan', 2, 'Labor', '2025-05-21', 'Active', '2026-12-31'),
    (5007, 'Tariq Qureshi', 'Pakistan', 4, 'Staff', '2024-03-15', 'Released', '2025-09-14'),
    (5008, 'Adeel Malik', 'Pakistan', 5, 'Staff', '2025-05-15', 'Active', NULL),
    (5009, 'Arjun Pillai', 'India', 2, 'Labor', '2025-05-23', 'Active', '2026-12-31'),
    (5010, 'Ali Shah', 'Pakistan', 6, 'Staff', '2024-10-03', 'Active', NULL),
    (5011, 'Irfan Khan', 'Pakistan', 5, 'Labor', '2025-08-14', 'Active', '2026-12-31'),
    (5012, 'Nabeel Qureshi', 'Pakistan', 5, 'Labor', '2024-12-21', 'Released', '2026-08-05'),
    (5013, 'Waqas Raza', 'Pakistan', 2, 'Staff', '2024-03-01', 'Released', '2025-04-19'),
    (5014, 'Hakan Yilmaz', 'Turkiye', 5, 'Labor', '2025-05-23', 'Released', '2026-09-30'),
    (5015, 'Can Celik', 'Turkiye', 3, 'Labor', '2025-03-16', 'Active', '2026-11-30'),
    (5016, 'Suresh Verma', 'India', 8, 'Staff', '2025-11-30', 'Active', '2026-10-30'),
    (5017, 'Salman Akhtar', 'Pakistan', 2, 'Staff', '2025-11-05', 'Released', '2026-09-30'),
    (5018, 'Serkan Ozturk', 'Turkiye', 2, 'Staff', '2024-05-29', 'Active', '2026-11-30'),
    (5019, 'Emre Ozturk', 'Turkiye', 3, 'Labor', '2025-12-08', 'Active', NULL),
    (5020, 'Hassan Sheikh', 'Pakistan', 7, 'Staff', '2026-03-09', 'Active', '2026-12-31'),
    (5021, 'Saad Iqbal', 'Pakistan', 3, 'Staff', '2025-10-11', 'Active', '2026-10-30'),
    (5022, 'Ravi Kumar', 'India', 8, 'Staff', '2025-03-27', 'Released', '2026-07-08'),
    (5023, 'Danish Khan', 'Pakistan', 2, 'Labor', '2025-07-03', 'Released', '2026-09-30'),
    (5024, 'Rizwan Khan', 'Pakistan', 2, 'Staff', '2025-01-20', 'Released', '2026-02-02'),
    (5025, 'Faisal Raza', 'Pakistan', 4, 'Staff', '2025-04-30', 'Released', '2026-09-30'),
    (5026, 'Noman Sheikh', 'Pakistan', 3, 'Labor', '2024-05-27', 'Released', '2025-09-09'),
    (5027, 'Kerem Kaya', 'Turkiye', 2, 'Labor', '2024-06-14', 'Active', '2026-10-30'),
    (5028, 'Kamran Butt', 'Pakistan', 2, 'Labor', '2024-01-28', 'Active', '2026-11-30'),
    (5029, 'Bilal Shah', 'Pakistan', 5, 'Staff', '2025-01-10', 'Active', '2026-11-30'),
    (5030, 'Vijay Nair', 'India', 3, 'Labor', '2024-12-03', 'Active', '2026-10-30'),
    (5031, 'Khalid Hussain', 'Pakistan', 6, 'Staff', '2026-01-27', 'Active', '2026-10-30'),
    (5032, 'Omar Butt', 'Pakistan', 3, 'Labor', '2024-01-29', 'Active', '2026-12-31'),
    (5033, 'Fahad Khan', 'Pakistan', 2, 'Labor', '2024-12-18', 'Active', '2026-11-30'),
    (5034, 'Sami Khan', 'Pakistan', 2, 'Staff', '2025-04-26', 'Released', '2026-03-21'),
    (5035, 'Jamal Sheikh', 'Pakistan', 4, 'Staff', '2025-09-16', 'Active', '2026-12-31'),
    (5036, 'Kareem Raza', 'Pakistan', 6, 'Staff', '2024-03-27', 'Active', NULL);

INSERT INTO suppliers (supplier_id, supplier_name, country) VALUES
    (1, 'Desert Steel Trading', 'Saudi Arabia'),
    (2, 'Anatolia Machinery', 'Turkiye'),
    (3, 'Red Sea Logistics', 'Saudi Arabia'),
    (4, 'Gulf Safety Supplies', 'UAE'),
    (5, 'Euro Tunnel Parts', 'Germany'),
    (6, 'Oasis Catering Co.', 'Saudi Arabia');

INSERT INTO purchase_orders (po_no, supplier_id, requester_id, description, po_date, amount_sar) VALUES
    ('DEMO-PO-1001', 4, 5031, 'PPE - helmets and vests', '2026-04-17', 203757.41),
    ('DEMO-PO-1002', 6, 5007, 'Ramadan iftar catering', '2026-06-24', 216474.83),
    ('DEMO-PO-1003', 6, 5013, 'Camp catering - monthly', '2026-02-17', 447003.88),
    ('DEMO-PO-1004', 1, 5036, 'Steel plates for segments', '2026-03-23', 365828.36),
    ('DEMO-PO-1005', 2, 5022, 'TBM spare parts', '2026-09-04', 253667.12),
    ('DEMO-PO-1006', 2, 5001, 'TBM spare parts', '2026-01-15', 244062.76),
    ('DEMO-PO-1007', 2, 5016, 'TBM spare parts', '2026-08-15', 27177.27),
    ('DEMO-PO-1008', 2, 5034, 'TBM spare parts', '2026-06-03', 347200.71),
    ('DEMO-PO-1009', 3, 5035, 'Truck rental - October', '2026-05-17', 377874.82),
    ('DEMO-PO-1010', 1, 5029, 'Steel plates for segments', '2026-07-05', 374805.76),
    ('DEMO-PO-1011', 5, 5035, 'Cutter discs', '2026-03-12', 242725.36),
    ('DEMO-PO-1012', 1, 5013, 'Rebar 16mm supply', '2026-08-18', 352576.95),
    ('DEMO-PO-1013', 2, 5010, 'Hydraulic pump overhaul', '2026-04-03', 284309.04),
    ('DEMO-PO-1014', 1, 5021, 'Steel plates for segments', '2026-02-05', 356158.53),
    ('DEMO-PO-1015', 1, 5017, 'Rebar 16mm supply', '2026-02-03', 135458.93),
    ('DEMO-PO-1016', 1, 5029, 'Rebar 16mm supply', '2026-09-21', 345597.02);

INSERT INTO payments (payment_id, po_no, pr_no, pay_date, amount_sar, status) VALUES
    (1, 'DEMO-PO-1002', 'DEMO-PO-1002-PR-1', '2026-08-02', 86088.6, 'Rejected'),
    (2, 'DEMO-PO-1002', 'DEMO-PO-1002-PR-2', '2026-08-30', 59149.51, 'Pending'),
    (3, 'DEMO-PO-1003', 'DEMO-PO-1003-PR-1', '2026-03-22', 205615.36, 'Paid'),
    (4, 'DEMO-PO-1003', 'DEMO-PO-1003-PR-2', '2026-04-22', 123051.51, 'Pending'),
    (5, 'DEMO-PO-1004', 'DEMO-PO-1004-PR-1', '2026-04-29', 207727.03, 'Paid'),
    (6, 'DEMO-PO-1004', 'DEMO-PO-1004-PR-2', '2026-05-29', 53934.74, 'Paid'),
    (7, 'DEMO-PO-1005', 'DEMO-PO-1005-PR-1', '2026-10-05', 81620.9, 'Paid'),
    (8, 'DEMO-PO-1006', 'DEMO-PO-1006-PR-1', '2026-02-16', 122236.79, 'Pending'),
    (9, 'DEMO-PO-1007', 'DEMO-PO-1007-PR-1', '2026-09-18', 13399.41, 'Paid'),
    (10, 'DEMO-PO-1007', 'DEMO-PO-1007-PR-2', '2026-10-17', 7782.42, 'Rejected'),
    (11, 'DEMO-PO-1007', 'DEMO-PO-1007-PR-3', '2026-11-20', 3141.64, 'Paid'),
    (12, 'DEMO-PO-1008', 'DEMO-PO-1008-PR-1', '2026-07-05', 207265.43, 'Pending'),
    (13, 'DEMO-PO-1009', 'DEMO-PO-1009-PR-1', '2026-06-21', 162280.81, 'Paid'),
    (14, 'DEMO-PO-1009', 'DEMO-PO-1009-PR-2', '2026-07-17', 91925.61, 'Paid'),
    (15, 'DEMO-PO-1009', 'DEMO-PO-1009-PR-3', '2026-08-23', 63892.69, 'Paid'),
    (16, 'DEMO-PO-1010', 'DEMO-PO-1010-PR-1', '2026-08-09', 161967.6, 'Paid'),
    (17, 'DEMO-PO-1010', 'DEMO-PO-1010-PR-2', '2026-09-04', 96890.35, 'Paid'),
    (18, 'DEMO-PO-1012', 'DEMO-PO-1012-PR-1', '2026-09-21', 208552.36, 'Paid'),
    (19, 'DEMO-PO-1013', 'DEMO-PO-1013-PR-1', '2026-05-07', 88669.3, 'Pending'),
    (20, 'DEMO-PO-1014', 'DEMO-PO-1014-PR-1', '2026-03-17', 194438.76, 'Pending'),
    (21, 'DEMO-PO-1015', 'DEMO-PO-1015-PR-1', '2026-03-13', 57134.46, 'Paid'),
    (22, 'DEMO-PO-1016', 'DEMO-PO-1016-PR-1', '2026-10-25', 154960.04, 'Paid'),
    (23, 'DEMO-PO-1016', 'DEMO-PO-1016-PR-2', '2026-11-26', 60481.1, 'Pending');
