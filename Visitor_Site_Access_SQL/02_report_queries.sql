-- =====================================================================
--  VISITOR & SITE ACCESS MANAGEMENT DATABASE  (SQLite)
--  File 2 of 2: report queries
--  Run 01_schema_and_data.sql first, then run these one by one.
--  The reporting date comes from the one-row table `settings`.
-- =====================================================================


-- ---------------------------------------------------------------------
-- LEVEL 1 : LOOK-UPS
-- ---------------------------------------------------------------------

-- Q1. Site zones with their risk level and PPE rule
SELECT zone_id, zone_name, risk_level, ppe_required
FROM site_zones
ORDER BY zone_id;

-- Q2. Everyone registered from one company
SELECT p.person_id, p.full_name, p.category, p.nationality
FROM people p
JOIN companies c ON c.company_id = p.company_id
WHERE c.company_name = 'Falcon Tunnel Services'
ORDER BY p.full_name;

-- Q3. Who is on site right now (checked in today, not checked out)
SELECT p.full_name, c.company_name, v.host, v.time_in, z.zone_name
FROM visits v
JOIN people p     ON p.person_id  = v.person_id
JOIN companies c  ON c.company_id = p.company_id
LEFT JOIN site_zones z ON z.zone_id = v.zone_id
WHERE v.visit_date = (SELECT today FROM settings)
  AND v.time_out IS NULL;


-- ---------------------------------------------------------------------
-- LEVEL 2 : COUNTS & SUMMARIES  (GROUP BY)
-- ---------------------------------------------------------------------

-- Q4. Head-count by category and company type
SELECT c.company_type, p.category, COUNT(*) AS people
FROM people p
JOIN companies c ON c.company_id = p.company_id
GROUP BY c.company_type, p.category
ORDER BY people DESC;

-- Q5. Access cards by type and status
SELECT card_type,
       SUM(status = 'Active')  AS active,
       SUM(status = 'Expired') AS expired,
       SUM(status = 'Lost')    AS lost,
       COUNT(*)                AS total
FROM access_cards
GROUP BY card_type;

-- Q6. Induction pass rate per trainer (first attempts and retakes)
SELECT trainer,
       COUNT(*)                                          AS inductions,
       SUM(result = 'Pass')                              AS passed,
       ROUND(100.0 * SUM(result = 'Pass') / COUNT(*), 1) AS pass_rate_pct,
       ROUND(AVG(score), 1)                              AS avg_score
FROM inductions
GROUP BY trainer
ORDER BY pass_rate_pct DESC;

-- Q7. Visits per month with average time on site (hours)
SELECT strftime('%Y-%m', visit_date) AS month,
       COUNT(*)                      AS visits,
       COUNT(DISTINCT person_id)     AS unique_visitors,
       ROUND(AVG((julianday(visit_date || ' ' || time_out) -
                  julianday(visit_date || ' ' || time_in)) * 24), 1) AS avg_hours_on_site
FROM visits
GROUP BY month
ORDER BY month;

-- Q8. PPE issued per month by item
SELECT strftime('%Y-%m', issue_date) AS month, item, SUM(qty) AS qty_issued
FROM ppe_issues
GROUP BY month, item
ORDER BY month, item;


-- ---------------------------------------------------------------------
-- LEVEL 3 : COMPLIANCE ALERTS  (the reports the gate and HSE use daily)
-- ---------------------------------------------------------------------

-- Q9. Active access cards expiring in the next 30 days
SELECT a.card_no, p.full_name, c.company_name, a.card_type, a.expiry_date,
       CAST(julianday(a.expiry_date) - julianday(s.today) AS INTEGER) AS days_left
FROM access_cards a
JOIN people p    ON p.person_id  = a.person_id
JOIN companies c ON c.company_id = p.company_id
CROSS JOIN settings s
WHERE a.status = 'Active'
  AND a.expiry_date BETWEEN s.today AND date(s.today, '+30 days')
ORDER BY a.expiry_date;

-- Q10. People with no passed induction (must not receive a card)
SELECT p.person_id, p.full_name, c.company_name, p.category
FROM people p
JOIN companies c ON c.company_id = p.company_id
WHERE NOT EXISTS (SELECT 1 FROM inductions i
                  WHERE i.person_id = p.person_id AND i.result = 'Pass')
ORDER BY c.company_name;

-- Q11. Cards that open High-risk zones but the holder has NO valid HSE training
SELECT DISTINCT a.card_no, p.full_name, c.company_name, z.zone_name
FROM access_cards a
JOIN card_zones cz ON cz.card_no   = a.card_no
JOIN site_zones z  ON z.zone_id    = cz.zone_id AND z.risk_level = 'High'
JOIN people p      ON p.person_id  = a.person_id
JOIN companies c   ON c.company_id = p.company_id
WHERE a.status = 'Active'
  AND NOT EXISTS (SELECT 1 FROM hse_trainings t, settings s
                  WHERE t.person_id = a.person_id AND t.expires_on >= s.today)
ORDER BY c.company_name, p.full_name;

-- Q12. HSE trainings expiring in the next 60 days (book refresher courses)
SELECT p.full_name, c.company_name, t.course, t.expires_on
FROM hse_trainings t
JOIN people p    ON p.person_id  = t.person_id
JOIN companies c ON c.company_id = p.company_id
CROSS JOIN settings s
WHERE t.expires_on BETWEEN s.today AND date(s.today, '+60 days')
ORDER BY t.expires_on;

-- Q13. Visits into a zone the visitor's card does not open (gate breach check)
SELECT v.visit_date, p.full_name, c.company_name, z.zone_name, v.host
FROM visits v
JOIN people p     ON p.person_id  = v.person_id
JOIN companies c  ON c.company_id = p.company_id
JOIN site_zones z ON z.zone_id    = v.zone_id
WHERE NOT EXISTS (SELECT 1
                  FROM access_cards a
                  JOIN card_zones cz ON cz.card_no = a.card_no
                  WHERE a.person_id = v.person_id AND cz.zone_id = v.zone_id)
ORDER BY v.visit_date DESC;

-- Q14. Visits made while the visitor's card was already expired
SELECT v.visit_date, p.full_name, a.card_no, a.expiry_date
FROM visits v
JOIN access_cards a ON a.person_id = v.person_id
JOIN people p       ON p.person_id = v.person_id
WHERE v.visit_date > a.expiry_date
ORDER BY v.visit_date DESC;


-- ---------------------------------------------------------------------
-- LEVEL 4 : MANAGEMENT REPORTS
-- ---------------------------------------------------------------------

-- Q15. Company compliance scorecard (one row per company)
WITH s AS (SELECT today FROM settings),
person_status AS (
    SELECT p.person_id, p.company_id,
           EXISTS (SELECT 1 FROM inductions i
                   WHERE i.person_id = p.person_id AND i.result = 'Pass'
                     AND i.valid_until >= (SELECT today FROM s))          AS inducted,
           EXISTS (SELECT 1 FROM access_cards a
                   WHERE a.person_id = p.person_id AND a.status = 'Active') AS active_card
    FROM people p
)
SELECT c.company_name,
       COUNT(*)                                         AS people,
       SUM(inducted)                                    AS valid_induction,
       SUM(active_card)                                 AS active_cards,
       ROUND(100.0 * SUM(inducted) / COUNT(*), 0)       AS compliance_pct
FROM person_status ps
JOIN companies c ON c.company_id = ps.company_id
GROUP BY c.company_name
ORDER BY compliance_pct, people DESC;

-- Q16. Top hosts: who receives the most visitors
SELECT host, COUNT(*) AS visits, COUNT(DISTINCT person_id) AS visitors
FROM visits
GROUP BY host
ORDER BY visits DESC;

-- Q17. Zone traffic: visits per zone with risk level
SELECT z.zone_name, z.risk_level, COUNT(v.visit_id) AS visits
FROM site_zones z
LEFT JOIN visits v ON v.zone_id = z.zone_id
GROUP BY z.zone_id
ORDER BY visits DESC;

-- Q18. Running total of cards issued per month (window function)
SELECT month, issued,
       SUM(issued) OVER (ORDER BY month) AS running_total
FROM (SELECT strftime('%Y-%m', issue_date) AS month, COUNT(*) AS issued
      FROM access_cards GROUP BY month);


-- ---------------------------------------------------------------------
-- LEVEL 5 : CHANGING DATA  (gate & HSE desk actions)
-- ---------------------------------------------------------------------

-- Q19. Mark expired cards automatically
UPDATE access_cards
SET status = 'Expired'
WHERE status = 'Active'
  AND expiry_date < (SELECT today FROM settings);

-- Q20. A saved VIEW the security gate can open every morning
DROP VIEW IF EXISTS v_access_compliance;
CREATE VIEW v_access_compliance AS
SELECT p.person_id, p.full_name, c.company_name, p.category,
       a.card_no, a.card_type, a.expiry_date, a.status AS card_status,
       (SELECT MAX(valid_until) FROM inductions i
         WHERE i.person_id = p.person_id AND i.result = 'Pass') AS induction_valid_until,
       CASE
         WHEN a.card_no IS NULL                          THEN 'No card'
         WHEN a.status <> 'Active'                       THEN 'Card ' || a.status
         WHEN a.expiry_date < date((SELECT today FROM settings), '+30 days') THEN 'Renew soon'
         ELSE 'Cleared'
       END AS gate_status
FROM people p
JOIN companies c        ON c.company_id = p.company_id
LEFT JOIN access_cards a ON a.person_id = p.person_id;

SELECT gate_status, COUNT(*) AS people
FROM v_access_compliance
GROUP BY gate_status
ORDER BY people DESC;

-- TIP: always run a SELECT with the same WHERE before any UPDATE or DELETE.
