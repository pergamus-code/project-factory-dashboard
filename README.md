# Real-Time Factory Dashboard Demo

A local, interactive proof-of-concept demonstrating real-time operational monitoring and equipment telemetry. This project simulates a live factory environment, utilizing a lightweight local tech stack to showcase dynamic data visualization, equipment health tracking, and production metrics.

## 🚀 Architecture & Tech Stack

* **Database:** MySQL (Local, configured for high-frequency time-series data)
* **Visualization:** Grafana (Dashboards rendering real-time metrics and historical telemetry)
* **Simulation Engine:** Python / Tkinter (An interactive GUI to mock live factory events like temperature spikes and downtime) *[Pending]*
* **Environment:** macOS / Localhost

## 📊 Database Schema Overview

The database (`grafana_demo`) is highly normalized and constrained to a 5-machine production line to ensure clean visualizations. It consists of 5 core tables:

1.  `machines`: Static data defining the equipment and their current status.
2.  `production_metrics`: Hourly time-series data tracking units produced vs. defects.
3.  `sensor_data`: High-frequency time-series telemetry (Temperature & Vibration).
4.  `energy_consumption`: Hourly tracking of kWh used per machine.
5.  `maintenance_logs`: Categorized downtime events and physical repair logs.

## 🛠️ Setup Instructions

### 1. Prerequisites
Ensure you have the following installed on your machine:
* [Homebrew](https://brew.sh/)
* MySQL (brew install mysql)
* Grafana (brew install grafana)
* Python 3.x

### 2. Database Initialization
1. Start your local MySQL server:
       brew services start mysql
2. Connect to your local instance using your preferred SQL client (e.g., VS Code MySQL Extension or TablePlus).
3. Execute the `01_init_and_seed.sql` script located in the `/sql` directory. This will drop any existing demo tables, build the schema, and instantly seed the database with hundreds of rows of realistic dummy data using Recursive CTEs.

### 3. Grafana Configuration
1. Start your local Grafana server:
       brew services start grafana
2. Navigate to `http://localhost:3000` in your browser.
3. Add a new **MySQL Data Source**:
    * **Host:** `127.0.0.1:3306`
    * **Database:** `grafana_demo`
    * **User:** `root` (or your configured local user)
4. Import the dashboard JSON files located in the `/grafana` directory, or manually build the panels using the queries provided in the project documentation.

## 📱 Mobile Viewing
To view the dashboards dynamically on a mobile device during a presentation:
1. Ensure the mobile device is on the same local network as the host machine.
2. Find the host's local IP address (e.g., `ipconfig getifaddr en0` on macOS).
3. Navigate to `http://<LOCAL_IP>:3000` on the mobile browser.	
