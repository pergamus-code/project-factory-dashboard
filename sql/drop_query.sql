USE grafana_demo;

-- ==========================================
-- 1. DROP ALL FOUR CHILD TABLES
-- ==========================================
DROP TABLE IF EXISTS sensor_data;
DROP TABLE IF EXISTS production_metrics;
DROP TABLE IF EXISTS energy_consumption;
DROP TABLE IF EXISTS maintenance_logs;

-- ==========================================
-- 2. CLEAN UP THE MACHINES TABLE
-- ==========================================
-- Now that the foreign keys are gone, we can safely delete machines 6 through 105
DELETE FROM machines WHERE machine_id > 5;

-- ==========================================
-- 3. BRING BACK THE FOUR TABLES
-- ==========================================
CREATE TABLE production_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT,
    recorded_at DATETIME,
    units_produced INT,
    defects INT,
    FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
);

CREATE TABLE sensor_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT,
    recorded_at DATETIME,
    temperature_celsius DECIMAL(5,2),
    vibration_hz DECIMAL(5,2),
    FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
);

CREATE TABLE energy_consumption (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT,
    recorded_at DATETIME,
    kwh_used DECIMAL(6,2),
    FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
);

CREATE TABLE maintenance_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT,
    logged_at DATETIME,
    issue_type VARCHAR(50),
    downtime_minutes INT,
    FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
);

-- ==========================================
-- 4. RE-INSERT 100+ ROWS (STRICTLY IDs 1-5)
-- ==========================================

-- Production Metrics (100 hours)
INSERT INTO production_metrics (machine_id, recorded_at, units_produced, defects)
WITH RECURSIVE time_gen AS (
    SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 100 HOUR) AS t
    UNION ALL
    SELECT n + 1, DATE_ADD(t, INTERVAL 1 HOUR) FROM time_gen WHERE n < 100
)
SELECT 
    (n % 5) + 1, 
    t, 
    FLOOR(120 + (RAND() * 80)), 
    FLOOR(RAND() * 12)          
FROM time_gen;

-- Sensor Data (100 intervals of 10 mins = ~16 hours)
INSERT INTO sensor_data (machine_id, recorded_at, temperature_celsius, vibration_hz)
WITH RECURSIVE time_gen AS (
    SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 1000 MINUTE) AS t
    UNION ALL
    SELECT n + 1, DATE_ADD(t, INTERVAL 10 MINUTE) FROM time_gen WHERE n < 100
)
SELECT 
    (n % 5) + 1, 
    t, 
    ROUND(60 + (RAND() * 30), 2), 
    ROUND(5 + (RAND() * 10), 2)   
FROM time_gen;

-- Energy Consumption (100 hours)
INSERT INTO energy_consumption (machine_id, recorded_at, kwh_used)
WITH RECURSIVE time_gen AS (
    SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 100 HOUR) AS t
    UNION ALL
    SELECT n + 1, DATE_ADD(t, INTERVAL 1 HOUR) FROM time_gen WHERE n < 100
)
SELECT 
    (n % 5) + 1, 
    t, 
    ROUND(15 + (RAND() * 10), 2) 
FROM time_gen;

-- Maintenance Logs (100 days)
INSERT INTO maintenance_logs (machine_id, logged_at, issue_type, downtime_minutes)
WITH RECURSIVE time_gen AS (
    SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 100 DAY) AS t
    UNION ALL
    SELECT n + 1, DATE_ADD(t, INTERVAL 1 DAY) FROM time_gen WHERE n < 100
)
SELECT 
    (n % 5) + 1, 
    t, 
    ELT(FLOOR(1 + (RAND() * 4)), 'Overheating', 'Calibration', 'Part Replacement', 'Routine Inspection'), 
    FLOOR(15 + (RAND() * 105)) 
FROM time_gen;