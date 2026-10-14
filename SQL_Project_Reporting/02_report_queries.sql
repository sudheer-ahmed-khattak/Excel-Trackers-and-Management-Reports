-- =====================================================================
--  PART 3 : REPORT QUERIES  (SELECT = database se sawal poochna)
--  Pehle 01_create_and_insert.sql chalayein, phir yeh queries ek ek kar ke.
--  Har query ke upar likha hai: Excel mein yeh kaam kaise hota, SQL mein kaise.
-- =====================================================================


-- ---------------------------------------------------------------------
-- LEVEL 1 : BASICS  (SELECT, WHERE, ORDER BY)
-- ---------------------------------------------------------------------

-- Q1. Saare employees dikhao
--     Excel: sheet khol ke dekh lena
SELECT * FROM employees;

-- Q2. Sirf chand columns dikhao
--     Excel: baaqi columns hide karna
SELECT emp_id, full_name, status, release_date
FROM employees;

-- Q3. Sirf Active log
--     Excel: Status column par Filter -> Active
SELECT emp_id, full_name, status
FROM employees
WHERE status = 'Active';

-- Q4. Active log jo 30-Nov-2026 ya us se pehle release honge, tareekh ke hisaab se
--     Excel: do filters + Sort
SELECT emp_id, full_name, release_date
FROM employees
WHERE status = 'Active'
  AND release_date <= '2026-11-30'
ORDER BY release_date;

-- Q5. Naam mein "Khan" wale  (Excel ka "Contains" filter / hamara Search sheet)
SELECT emp_id, full_name
FROM employees
WHERE full_name LIKE '%Khan%';

-- Q6. Active log jin ki release date abhi tak khaali (TBD) hai
--     NULL = khaali cell.  "= NULL" nahi, "IS NULL" likhte hain
SELECT emp_id, full_name
FROM employees
WHERE status = 'Active' AND release_date IS NULL;


-- ---------------------------------------------------------------------
-- LEVEL 2 : COUNT / SUM  (GROUP BY = Pivot Table)
-- ---------------------------------------------------------------------

-- Q7. Kitne Active, kitne Released
--     Excel: COUNTIF ya Pivot (Status in Rows, Count of ID)
SELECT status, COUNT(*) AS total
FROM employees
GROUP BY status;

-- Q8. Nationality aur Status ke hisaab se ginti
SELECT nationality, status, COUNT(*) AS total
FROM employees
GROUP BY nationality, status
ORDER BY nationality, status;

-- Q9. Sirf woh nationality jin ke 5 se zyada Active log hain
--     WHERE = group se PEHLE filter,  HAVING = group ke BAAD filter
SELECT nationality, COUNT(*) AS active_count
FROM employees
WHERE status = 'Active'
GROUP BY nationality
HAVING COUNT(*) > 5;

-- Q10. Mahine ke hisaab se release (hamara "Active Release Summary" pivot)
SELECT strftime('%Y-%m', release_date) AS release_month,
       COUNT(*) AS people
FROM employees
WHERE release_date IS NOT NULL
GROUP BY release_month
ORDER BY release_month;


-- ---------------------------------------------------------------------
-- LEVEL 3 : JOIN  (do tables jorna = VLOOKUP / INDEX-MATCH)
-- ---------------------------------------------------------------------

-- Q11. Employee ke saath us ke department ka naam
--      Excel: =VLOOKUP(dept_id, Departments!A:B, 2, 0)
SELECT e.emp_id, e.full_name, d.dept_name, e.status
FROM employees e
JOIN departments d ON d.dept_id = e.dept_id
ORDER BY d.dept_name, e.full_name;

-- Q12. Department-wise Active / Released (department naam ke saath)
SELECT d.dept_name,
       SUM(CASE WHEN e.status = 'Active'   THEN 1 ELSE 0 END) AS active,
       SUM(CASE WHEN e.status = 'Released' THEN 1 ELSE 0 END) AS released,
       COUNT(*) AS total
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY total DESC;

-- Q13. Har PO: supplier, requester, amount
--      (3 tables jore — Excel mein 2 VLOOKUP lagte)
SELECT po.po_no, s.supplier_name, e.full_name AS requester,
       po.description, po.po_date, po.amount_sar
FROM purchase_orders po
JOIN suppliers s ON s.supplier_id = po.supplier_id
JOIN employees e ON e.emp_id     = po.requester_id
ORDER BY po.po_date;


-- ---------------------------------------------------------------------
-- LEVEL 4 : MANAGEMENT REPORTS  (asal kaam ki queries)
-- ---------------------------------------------------------------------

-- Q14. PO vs Payment status: kitna paid, kitna pending, kitna baaqi
--      Excel mein SUMIFS + VLOOKUP + helper columns lagte. SQL mein ek query.
SELECT po.po_no,
       s.supplier_name,
       po.amount_sar                                                         AS po_amount,
       ROUND(COALESCE(SUM(CASE WHEN p.status='Paid'    THEN p.amount_sar END),0),2) AS paid,
       ROUND(COALESCE(SUM(CASE WHEN p.status='Pending' THEN p.amount_sar END),0),2) AS pending,
       ROUND(po.amount_sar
             - COALESCE(SUM(CASE WHEN p.status IN ('Paid','Pending') THEN p.amount_sar END),0),2) AS balance
FROM purchase_orders po
JOIN suppliers s     ON s.supplier_id = po.supplier_id
LEFT JOIN payments p ON p.po_no = po.po_no
GROUP BY po.po_no
ORDER BY balance DESC;

-- Q15. Supplier-wise: kitne PO, kul PO value, kul paid
--      Pehle har PO ka paid nikala (sub-query "pp"), phir supplier par jama kiya
SELECT s.supplier_name,
       COUNT(po.po_no)                   AS po_count,
       ROUND(SUM(po.amount_sar),2)       AS total_po_value,
       ROUND(COALESCE(SUM(pp.paid),0),2) AS total_paid
FROM suppliers s
LEFT JOIN purchase_orders po ON po.supplier_id = s.supplier_id
LEFT JOIN (SELECT po_no, SUM(amount_sar) AS paid
           FROM payments WHERE status = 'Paid'
           GROUP BY po_no) pp ON pp.po_no = po.po_no
GROUP BY s.supplier_id
ORDER BY total_po_value DESC;

-- Q16. Mahine-wise payments (Paid only)
SELECT strftime('%Y-%m', pay_date) AS month,
       COUNT(*)                    AS payments,
       ROUND(SUM(amount_sar),2)    AS total_paid_sar
FROM payments
WHERE status = 'Paid'
GROUP BY month
ORDER BY month;

-- Q17. Woh POs jin par abhi tak koi payment request hi nahi aayi
SELECT po.po_no, s.supplier_name, po.po_date, po.amount_sar
FROM purchase_orders po
JOIN suppliers s ON s.supplier_id = po.supplier_id
WHERE po.po_no NOT IN (SELECT po_no FROM payments);

-- Q18. Released log jo abhi bhi kisi PO ke requester hain (follow-up list)
SELECT e.full_name, e.release_date, po.po_no, po.amount_sar
FROM employees e
JOIN purchase_orders po ON po.requester_id = e.emp_id
WHERE e.status = 'Released';


-- ---------------------------------------------------------------------
-- LEVEL 5 : DATA BADALNA  (UPDATE / DELETE)  — hamare UPDATE button jaisa
-- ---------------------------------------------------------------------

-- Q19. Ek employee ko Released karna aur date dalna
--      (Search sheet ka UPDATE button andar se yahi karta hai)
UPDATE employees
SET status = 'Released', release_date = '2026-10-10'
WHERE emp_id = 5008;

-- Check karein:
SELECT emp_id, full_name, status, release_date FROM employees WHERE emp_id = 5008;

-- Q20. VIEW = saved query (ek "live report sheet" jo hamesha updated rahe)
DROP VIEW IF EXISTS v_active_manpower;
CREATE VIEW v_active_manpower AS
SELECT e.emp_id, e.full_name, e.nationality, d.dept_name, e.category,
       COALESCE(e.release_date, 'TBD') AS release_date
FROM employees e
JOIN departments d ON d.dept_id = e.dept_id
WHERE e.status = 'Active';

SELECT * FROM v_active_manpower ORDER BY release_date;

-- ZAROORI: UPDATE/DELETE mein WHERE bhool gaye to POORI table badal jaati hai,
-- aur Excel ki tarah Ctrl+Z nahi hota. Hamesha pehle SELECT se check karein.
