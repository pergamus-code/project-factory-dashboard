"""
reseed.py
=========
Drops all grafana_demo tables and reseeds with 30 days of fresh data.
Run from the project root with the venv active:

    python reseed.py

No arguments needed. Edit DB_CONFIG below if your credentials differ.
"""

import mysql.connector
import sys

# ─────────────────────────────────────────────
#  CONFIG
# ─────────────────────────────────────────────
DB_CONFIG = {
    "host":     "127.0.0.1",
    "port":     3306,
    "user":     "root",
    "password": "",          
    "database": "grafana_demo",
}

# ─────────────────────────────────────────────
#  SQL STATEMENTS  (executed in order)
# ─────────────────────────────────────────────
# Each item is a (label, sql) tuple so the script can print
# progress as it runs. Keeps things easy to debug.

STEPS = [

    # MySQL's default recursion depth is 1000.
    # sensor_data needs 4,320 steps — raise it for this session.
    ("Set recursion depth",
     "SET SESSION cte_max_recursion_depth = 5000"),

    # ── Teardown ────────────────────────────────────────────────
    ("Drop sensor_data",          "DROP TABLE IF EXISTS sensor_data"),
    ("Drop production_metrics",   "DROP TABLE IF EXISTS production_metrics"),
    ("Drop energy_consumption",   "DROP TABLE IF EXISTS energy_consumption"),
    ("Drop maintenance_logs",     "DROP TABLE IF EXISTS maintenance_logs"),
    

    # ── Recreate tables ─────────────────────────────────────────
    ("Create production_metrics", """
        CREATE TABLE production_metrics (
            id             INT AUTO_INCREMENT PRIMARY KEY,
            machine_id     INT,
            recorded_at    DATETIME,
            units_produced INT,
            defects        INT,
            FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
        )
    """),

    ("Create sensor_data", """
        CREATE TABLE sensor_data (
            id                  INT AUTO_INCREMENT PRIMARY KEY,
            machine_id          INT,
            recorded_at         DATETIME,
            temperature_celsius DECIMAL(5,2),
            vibration_hz        DECIMAL(5,2),
            FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
        )
    """),

    ("Create energy_consumption", """
        CREATE TABLE energy_consumption (
            id          INT AUTO_INCREMENT PRIMARY KEY,
            machine_id  INT,
            recorded_at DATETIME,
            kwh_used    DECIMAL(6,2),
            FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
        )
    """),

    ("Create maintenance_logs", """
        CREATE TABLE maintenance_logs (
            id               INT AUTO_INCREMENT PRIMARY KEY,
            machine_id       INT,
            logged_at        DATETIME,
            issue_type       VARCHAR(50),
            downtime_minutes INT,
            FOREIGN KEY (machine_id) REFERENCES machines(machine_id)
        )
    """),

    # ── Seed data ───────────────────────────────────────────────
    # production_metrics: 1 row/hour/machine over 30 days = 720 rows
    ("Seed production_metrics", """
        INSERT INTO production_metrics (machine_id, recorded_at, units_produced, defects)
        WITH RECURSIVE time_gen AS (
            SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 720 HOUR) AS t
            UNION ALL
            SELECT n + 1, DATE_ADD(t, INTERVAL 1 HOUR)
            FROM time_gen WHERE n < 720
        )
        SELECT
            (n % 5) + 1,
            t,
            FLOOR(120 + (RAND() * 80)),
            FLOOR(RAND() * 12)
        FROM time_gen
    """),

    # sensor_data: 1 row/10 min/machine over 30 days = 4,320 rows
    ("Seed sensor_data", """
        INSERT INTO sensor_data (machine_id, recorded_at, temperature_celsius, vibration_hz)
        WITH RECURSIVE time_gen AS (
            SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 43200 MINUTE) AS t
            UNION ALL
            SELECT n + 1, DATE_ADD(t, INTERVAL 10 MINUTE)
            FROM time_gen WHERE n < 4320
        )
        SELECT
            (n % 5) + 1,
            t,
            ROUND(60 + (RAND() * 30), 2),
            ROUND(5  + (RAND() * 10), 2)
        FROM time_gen
    """),

    # energy_consumption: mirrors production_metrics cadence = 720 rows
    ("Seed energy_consumption", """
        INSERT INTO energy_consumption (machine_id, recorded_at, kwh_used)
        WITH RECURSIVE time_gen AS (
            SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 720 HOUR) AS t
            UNION ALL
            SELECT n + 1, DATE_ADD(t, INTERVAL 1 HOUR)
            FROM time_gen WHERE n < 720
        )
        SELECT
            (n % 5) + 1,
            t,
            ROUND(15 + (RAND() * 10), 2)
        FROM time_gen
    """),

    # maintenance_logs: 1 event/day over 30 days = 30 rows
    ("Seed maintenance_logs", """
        INSERT INTO maintenance_logs (machine_id, logged_at, issue_type, downtime_minutes)
        WITH RECURSIVE time_gen AS (
            SELECT 1 AS n, DATE_SUB(NOW(), INTERVAL 30 DAY) AS t
            UNION ALL
            SELECT n + 1, DATE_ADD(t, INTERVAL 1 DAY)
            FROM time_gen WHERE n < 30
        )
        SELECT
            (n % 5) + 1,
            t,
            ELT(
                FLOOR(1 + (RAND() * 4)),
                'Overheating', 'Calibration', 'Part Replacement', 'Routine Inspection'
            ),
            FLOOR(15 + (RAND() * 105))
        FROM time_gen
    """),
]

# ─────────────────────────────────────────────
#  ROW COUNT CHECK  (printed at the end)
# ─────────────────────────────────────────────
COUNT_CHECK = """
    SELECT 'machines' AS `Table`, COUNT(*) AS 'Row Count' FROM machines
    UNION ALL SELECT 'production_metrics', COUNT(*) FROM production_metrics
    UNION ALL SELECT 'sensor_data', COUNT(*) FROM sensor_data
    UNION ALL SELECT 'energy_consumption', COUNT(*) FROM energy_consumption
    UNION ALL SELECT 'maintenance_logs', COUNT(*) FROM maintenance_logs
"""


# ─────────────────────────────────────────────
#  RUNNER
# ─────────────────────────────────────────────
def main():
    print("\n🏭  Factory DB Reseed")
    print("─" * 40)

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cur  = conn.cursor()
    except mysql.connector.Error as e:
        print(f"\n❌  Could not connect to MySQL: {e}")
        print("    Check DB_CONFIG at the top of reseed.py")
        sys.exit(1)

    total = len(STEPS)
    for i, (label, sql) in enumerate(STEPS, start=1):
        try:
            print(f"  [{i:>2}/{total}]  {label}...", end=" ", flush=True)
            cur.execute(sql)
            conn.commit()
            print("✓")
        except mysql.connector.Error as e:
            print(f"\n❌  Failed on step '{label}':\n    {e}")
            cur.close()
            conn.close()
            sys.exit(1)

    # ── Final row count summary ──
    print("\n📊  Row counts:")
    print("─" * 40)
    cur.execute(COUNT_CHECK)
    for table_name, count in cur.fetchall():
        print(f"  {table_name:<25} {count:>6} rows")

    cur.close()
    conn.close()
    print("\n✅  Reseed complete — Grafana dashboards are ready.\n")


if __name__ == "__main__":
    main()