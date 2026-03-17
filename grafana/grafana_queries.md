# Grafana Dashboard Queries: Factory Telemetry & Production

This document contains the SQL queries used to power the two main Grafana dashboards for the factory monitoring demo. 

All time-series queries utilize the Grafana $__timeFilter() macro to link dynamically with the dashboard's master date/time picker.

---

## Dashboard 1: Production & Efficiency Overview
Focus: Output, yields, and the energy cost of production.

### 1. Total Units Produced
* Panel Type: Stat
* Description: Top-level number of units made in the selected time range.
```sql
SELECT 
    SUM(units_produced) AS "Total Units" 
FROM production_metrics 
WHERE $__timeFilter(recorded_at);
```
### 2. Production Output by Line
* Panel Type: Time Series or Stacked Bar Chart
* Description: Hourly production volume, separated by production line.

```sql
SELECT 
    p.recorded_at AS "time", 
    m.production_line AS metric, 
    SUM(p.units_produced) AS "Units"
FROM production_metrics p
JOIN machines m ON p.machine_id = m.machine_id
WHERE $__timeFilter(p.recorded_at)
GROUP BY p.recorded_at, m.production_line
ORDER BY p.recorded_at ASC;
```

### 3. Defect Rate Percentage
* Panel Type: Time Series
* Description: Tracks defects relative to total output over time.
```sql

SELECT 
    p.recorded_at AS "time", 
    m.machine_name AS metric, 
    (p.defects / p.units_produced) * 100 AS "Defect Rate (%)"
FROM production_metrics p
JOIN machines m ON p.machine_id = m.machine_id
WHERE $__timeFilter(p.recorded_at)
ORDER BY p.recorded_at ASC;
```

### 4. Energy Consumption vs. Production Volume
* Panel Type: Time Series (with 2 Y-Axes)
* Description: Combines tables to see if energy spikes correlate with production volume.

```sql
SELECT 
    p.recorded_at AS "time", 
    SUM(p.units_produced) AS "Total Units", 
    SUM(e.kwh_used) AS "Total Energy (kWh)"
FROM production_metrics p
JOIN energy_consumption e ON p.machine_id = e.machine_id AND p.recorded_at = e.recorded_at
WHERE $__timeFilter(p.recorded_at)
GROUP BY p.recorded_at
ORDER BY p.recorded_at ASC;
```

### 5. Total Downtime by Machine
* Panel Type: Bar Chart (Horizontal)
* Description: Identifies machines with the most lost time.

```sql
SELECT 
    m.machine_name AS "Machine", 
    SUM(l.downtime_minutes) AS "Total Downtime (Mins)" 
FROM maintenance_logs l
JOIN machines m ON l.machine_id = m.machine_id
WHERE $__timeFilter(l.logged_at)
GROUP BY m.machine_name
ORDER BY "Total Downtime (Mins)" DESC
LIMIT 10;
```

### 6. Current Machine Status
* Panel Type: Pie Chart or Donut
* Description: Live snapshot of the production floor (no time filter needed).

```sql
SELECT 
    status AS metric, 
    COUNT(*) AS value 
FROM machines 
GROUP BY status;
```
---

## Dashboard 2: Equipment Health & Telemetry
Focus: High-frequency sensor data and maintenance logs for predictive analysis.

### 7. Machine Temperature Monitoring
* Panel Type: Time Series
* Description: Tracks the heat of every machine to spot overheating.

```sql
SELECT 
    s.recorded_at AS "time", 
    m.machine_name AS metric, 
    s.temperature_celsius AS "Temp (°C)"
FROM sensor_data s
JOIN machines m ON s.machine_id = m.machine_id
WHERE $__timeFilter(s.recorded_at)
ORDER BY s.recorded_at ASC;
```

### 8. Vibration Anomalies
* Panel Type: Time Series
* Description: Monitors for sudden spikes in vibration (indicative of failing parts).

```sql
SELECT 
    s.recorded_at AS "time", 
    m.machine_name AS metric, 
    s.vibration_hz AS "Vibration (Hz)"
FROM sensor_data s
JOIN machines m ON s.machine_id = m.machine_id
WHERE $__timeFilter(s.recorded_at)
ORDER BY s.recorded_at ASC;
```

### 9. Max Temperature by Production Line
* Panel Type: Gauge
* Description: The absolute hottest reading recorded per line in the selected window.

```sql
SELECT 
    m.production_line AS metric, 
    MAX(s.temperature_celsius) AS "Peak Temp"
FROM sensor_data s
JOIN machines m ON s.machine_id = m.machine_id
WHERE $__timeFilter(s.recorded_at)
GROUP BY m.production_line;
```

### 10. Most Common Maintenance Issues
* Panel Type: Bar Gauge or Pie Chart
* Description: Categorizes the most frequent causes of line stoppage.

```sql
SELECT 
    issue_type AS metric, 
    COUNT(*) AS "Occurrences"
FROM maintenance_logs
WHERE $__timeFilter(logged_at)
GROUP BY issue_type
ORDER BY "Occurrences" DESC;
```

### 11. Average Energy Draw per Machine
* Panel Type: Bar Chart
* Description: Identifies power-hungry equipment across the floor.

```sql
SELECT 
    m.machine_name AS "Machine", 
    AVG(e.kwh_used) AS "Avg kWh"
FROM energy_consumption e
JOIN machines m ON e.machine_id = m.machine_id
WHERE $__timeFilter(e.recorded_at)
GROUP BY m.machine_name
ORDER BY "Avg kWh" DESC;
```

### 12. Recent Maintenance Logbook
* Panel Type: Table
* Description: Raw data table showing recent physical logs from technicians.

```sql
SELECT 
    l.logged_at AS "Time", 
    m.machine_name AS "Machine", 
    l.issue_type AS "Issue", 
    l.downtime_minutes AS "Downtime (mins)" 
FROM maintenance_logs l
JOIN machines m ON l.machine_id = m.machine_id
WHERE $__timeFilter(l.logged_at)
ORDER BY l.logged_at DESC
LIMIT 20;
```