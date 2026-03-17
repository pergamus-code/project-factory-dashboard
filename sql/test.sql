-- Create and use the database
CREATE DATABASE IF NOT EXISTS grafana_demo;
USE grafana_demo;

-- 1. Machines Table (Static data)
CREATE TABLE machines (
    machine_id INT AUTO_INCREMENT PRIMARY KEY,
    machine_name VARCHAR(50),
    production_line VARCHAR(10),
    status VARCHAR(20)
);

INSERT INTO machines (machine_name, production_line, status) VALUES
('Press A1', 'Line 1', 'Active'),
('Press A2', 'Line 1', 'Active'),
('Welder B1', 'Line 2', 'Maintenance'),
('Welder B2', 'Line 2', 'Active'),
('Packager C1', 'Line 3', 'Active');

-- 2. Production Metrics (Time-series data, hourly)
CREATE TABLE production_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT,
    recorded_at DATETIME,
    units_produced INT,
    defects INT,
    FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
);

-- Inserting dummy data for the last 4 hours
INSERT INTO production_metrics (machine_id, recorded_at, units_produced, defects) VALUES
(1, DATE_SUB(NOW(), INTERVAL 4 HOUR), 150, 2),
(2, DATE_SUB(NOW(), INTERVAL 4 HOUR), 145, 1),
(4, DATE_SUB(NOW(), INTERVAL 4 HOUR), 300, 5),
(5, DATE_SUB(NOW(), INTERVAL 4 HOUR), 500, 10),

(1, DATE_SUB(NOW(), INTERVAL 3 HOUR), 155, 3),
(2, DATE_SUB(NOW(), INTERVAL 3 HOUR), 140, 0),
(4, DATE_SUB(NOW(), INTERVAL 3 HOUR), 310, 4),
(5, DATE_SUB(NOW(), INTERVAL 3 HOUR), 490, 8),

(1, DATE_SUB(NOW(), INTERVAL 2 HOUR), 148, 1),
(2, DATE_SUB(NOW(), INTERVAL 2 HOUR), 130, 5),
(4, DATE_SUB(NOW(), INTERVAL 2 HOUR), 290, 6),
(5, DATE_SUB(NOW(), INTERVAL 2 HOUR), 505, 12),

(1, DATE_SUB(NOW(), INTERVAL 1 HOUR), 160, 2),
(2, DATE_SUB(NOW(), INTERVAL 1 HOUR), 150, 1),
(4, DATE_SUB(NOW(), INTERVAL 1 HOUR), 305, 3),
(5, DATE_SUB(NOW(), INTERVAL 1 HOUR), 495, 9);

-- 3. Sensor Data (Time-series data, frequent)
CREATE TABLE sensor_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id INT,
    recorded_at DATETIME,
    temperature_celsius DECIMAL(5,2),
    vibration_hz DECIMAL(5,2),
    FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
);

-- Inserting dummy sensor readings for the last 30 minutes (simulated intervals)
INSERT INTO sensor_data (machine_id, recorded_at, temperature_celsius, vibration_hz) VALUES
(1, DATE_SUB(NOW(), INTERVAL 30 MINUTE), 75.5, 12.1),
(1, DATE_SUB(NOW(), INTERVAL 20 MINUTE), 76.2, 12.3),
(1, DATE_SUB(NOW(), INTERVAL 10 MINUTE), 78.0, 12.8),
(1, NOW(), 80.5, 13.5),

(4, DATE_SUB(NOW(), INTERVAL 30 MINUTE), 60.1, 8.5),
(4, DATE_SUB(NOW(), INTERVAL 20 MINUTE), 60.5, 8.6),
(4, DATE_SUB(NOW(), INTERVAL 10 MINUTE), 61.0, 8.4),
(4, NOW(), 60.8, 8.5);