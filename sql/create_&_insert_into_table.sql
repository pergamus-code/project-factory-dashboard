USE grafana_demo;

-- ==========================================
-- 1. CREATE TWO NEW COMPLEMENTARY TABLES
-- ==========================================

-- Table 4: Energy Consumption (Great for bar charts and gauges)
CREATE TABLE energy_consumption (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT,
    recorded_at DATETIME,
    kwh_used DECIMAL(6,2),
    FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
);

-- Table 5: Maintenance Logs (Great for table panels and annotations)
CREATE TABLE maintenance_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT,
    logged_at DATETIME,
    issue_type VARCHAR(50),
    downtime_minutes INT,
    FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
);

-- ==========================================
-- 2. POPULATE 100+ ROWS INTO EVERY TABLE
-- ==========================================

-- Append 100 new machines
INSERT INTO machines (machine_name, production_line, status)
WITH RECURSIVE number_gen AS (
    SELECT 6 AS n
    UNION ALL
    SELECT n + 1 FROM number_gen WHERE n < 105
)
SELECT 
    CONCAT('Unit-', n), 
    CONCAT('Line ', (n % 5) + 1), 
    IF(n % 7 = 0, 'Maintenance', 'Active')
FROM number_gen;

-- Append 100 rows to production_metrics (spanning the last 100 hours)
INSERT INTO production_metrics (machine_id, recorded_at, units_produced, defects)
WITH RECURSIVE time_gen AS (
    SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 100 HOUR) AS t
    UNION ALL
    SELECT n + 1, DATE_ADD(t, INTERVAL 1 HOUR) FROM time_gen WHERE n < 100
)
SELECT 
    (n % 15) + 1, -- Picks a random machine ID between 1 and 15
    t, 
    FLOOR(120 + (RAND() * 80)), -- Random units between 120 and 200
    FLOOR(RAND() * 12)          -- Random defects between 0 and 11
FROM time_gen;

-- Append 100 rows to sensor_data (spanning the last 1000 minutes)
INSERT INTO sensor_data (machine_id, recorded_at, temperature_celsius, vibration_hz)
WITH RECURSIVE time_gen AS (
    SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 1000 MINUTE) AS t
    UNION ALL
    SELECT n + 1, DATE_ADD(t, INTERVAL 10 MINUTE) FROM time_gen WHERE n < 100
)
SELECT 
    (n % 15) + 1, 
    t, 
    ROUND(60 + (RAND() * 30), 2), -- Temp between 60.00 and 90.00
    ROUND(5 + (RAND() * 10), 2)   -- Vibration between 5.00 and 15.00
FROM time_gen;

-- Insert 100 rows into the new energy_consumption table
INSERT INTO energy_consumption (machine_id, recorded_at, kwh_used)
WITH RECURSIVE time_gen AS (
    SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 100 HOUR) AS t
    UNION ALL
    SELECT n + 1, DATE_ADD(t, INTERVAL 1 HOUR) FROM time_gen WHERE n < 100
)
SELECT 
    (n % 15) + 1, 
    t, 
    ROUND(15 + (RAND() * 10), 2) -- kWh between 15.00 and 25.00
FROM time_gen;

-- Insert 100 rows into the new maintenance_logs table
INSERT INTO maintenance_logs (machine_id, logged_at, issue_type, downtime_minutes)
WITH RECURSIVE time_gen AS (
    SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 100 DAY) AS t
    UNION ALL
    SELECT n + 1, DATE_ADD(t, INTERVAL 1 DAY) FROM time_gen WHERE n < 100
)
SELECT 
    (n % 20) + 1, 
    t, 
    ELT(FLOOR(1 + (RAND() * 4)), 'Overheating', 'Calibration', 'Part Replacement', 'Routine Inspection'), 
    FLOOR(15 + (RAND() * 105)) -- Downtime between 15 and 120 minutes
FROM time_gen;

-- drop rows from table --
DELETE FROM machines
ORDER BY machine_id DESC
LIMIT 100;

SELECT * from machines ORDER BY machine_id DESC