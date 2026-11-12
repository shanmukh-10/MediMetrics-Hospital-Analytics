MediMetrics – Hospital Operations & Patient Flow Analytics

End-to-end healthcare analytics project: Python (data audit & cleaning) → MySQL → SQL analysis → Power BI dashboard, built on 75,000 hospital appointments (Jan 2022 – Dec 2024).

Hospital Overview dashboard

Images in this README are previews rendered from the project data. Open the .pbix in Power BI Desktop for the live, filterable dashboard.

Business problem

Hospital management needs to know where appointments are lost, which departments earn and underperform, and where patient flow can be improved. This project answers:

How many appointments are completed, cancelled, missed (no-show) or still scheduled?
Which specialties, booking channels and booking lead times have the highest no-show rates?
Which specialties generate the most revenue, in total and per visit?
How do waiting time and patient satisfaction differ by specialty?
Which doctors carry the highest workload?
Tech stack
Layer	Tools
Data cleaning & EDA	Python, pandas, Jupyter notebooks
Database	MySQL (SQLAlchemy / PyMySQL for loading)
Analysis	SQL (10 business queries)
Visualisation	Power BI (DAX measures, 3 report pages)
Repository structure
MediMetrics/
├── data/
│   └── processed/
│       ├── cleaned_appointments.csv     # 75,000 rows x 57 columns
│       └── cleaned_doctors.csv          # 320 rows x 15 columns
├── notebooks/
│   ├── data_auditing.ipynb              # missing values, duplicates, consistency checks
│   ├── data_auditing2.ipynb             # cleaning rules + feature engineering
│   ├── data_importing.ipynb             # load cleaned data into MySQL
│   └── exploraty_data_analysis.ipynb    # EDA charts
├── sql/
│   └── quaries.sql                      # business SQL queries
├── dashboard/
│   └── MediMetrics_Hospital_Analytics_Redesigned.pbix
├── my_undeerstanding/                   # step-by-step Power BI guide (PDF)
└── README.md
Dataset
Table	Rows × Columns	Description
appointments (fact)	75,000 × 57	One row per appointment: dates, time slot, booking channel, status, patient profile, fees, insurance, revenue, waiting time, satisfaction
doctors (dimension)	320 × 15	Doctor name, specialty, hospital, city, experience, fee, rating

Coverage: 14 specialties · 36 hospitals · 15 cities · 32,705 unique patients. Relationship: appointments.doctor_id → doctors.doctor_id (many-to-one).

Data cleaning highlights
No duplicate appointment_id or doctor_id.
Dates converted to date types; 0 invalid booking-lead times.
insurance_provider blank exactly when insurance_coverage = 'No' → filled with Not Insured; chronic condition and membership blanks → Unknown.
Waiting time, consultation duration and satisfaction are empty for non-completed visits by design (0 missing among completed visits).
5 engineered columns added (52 → 57): insurance_provider_clean, patient_chronic_condition_clean, booking_lead_days_calculated, is_weekend, lead_time_category.
SQL analysis

All queries are in sql/quaries.sql.

#	Business question	Key result
Q1	Overall performance	75,000 appointments · 32,705 patients · 320 doctors · 55,275 completed
Q2	Monthly demand	~25,000 appointments per year; seasonal dip in Jun–Aug
Q3	Status distribution	Completed 73.70% · No-Show 15.45% · Cancelled 7.72% · Scheduled 3.13%
Q4	No-show % of resolved visits	17.33% (11,584 of 66,859)
Q5	No-show rate by specialty	Highest: Psychiatry 26.64%, Dermatology 23.12%, ENT 20.44%; lowest: Neurology 11.67%
Q6	Busiest doctors	Top 3 are all General Physicians (419, 418, 417 appointments)
Q7	Waiting time by specialty	11.18 – 12.02 min average in every specialty
Q8	Revenue by specialty	General Physician highest in total (9.48M) but lowest per visit (632.79); Psychiatry 2,640.45 per visit
Q9	No-show by booking channel	Walk-In 22.70% highest; Apollo App 15.36% lowest
Q10	Satisfaction by specialty	4.02 – 4.10 across specialties
Power BI dashboard

Three navigable pages with five synced filters (Year, Specialty, Hospital, City, Status):

Page	Focus
Hospital Overview	6 KPI cards, status mix, monthly appointment & revenue trends, specialty volume, booking channels, key insights
Patient Flow Analysis	Waiting time, satisfaction, cancellations, time of day, no-show by lead time, age group, city
Doctor & Department Performance	Revenue, satisfaction and no-show rate by specialty, doctor performance table

Patient Flow Analysis Doctor & Department Performance

DAX measures: Total Appointment Count, Total Patients, Completed Appointments, No-Show Appointments, No-Show Rate, Cancelled Appointments, Scheduled Appointments, Total Revenue, Average Waiting Time, Average Satisfaction, Channel %.

Key insights
73.7% of appointments are completed; no-shows (15.4%) are about twice as common as cancellations (7.7%).
The no-show rate is stable at ~17.3% of resolved visits in 2022, 2023 and 2024.
No-shows concentrate in Psychiatry, Dermatology and ENT, in walk-in bookings, and in bookings made 8–30 days ahead.
General Physician is 27% of volume but earns the least per visit.
Waiting time and satisfaction are almost identical across specialties, so they are not the main improvement lever.

Recommendations: targeted reminders/confirmation for high no-show segments, controlled overbooking in those specialties, shifting walk-ins to the app, and reviewing General Physician pricing and visit mix.

Data notes & limitations
December 2024 is incomplete: all 2,348 appointments that month are Scheduled, which lowers 2024 revenue and completion figures. Compare years on Jan–Nov.
Two no-show definitions: SQL uses completed + no-show visits (17.33%); the Power BI card divides by all appointments (15.4%).
The calendar table in the Power BI model is not related to the appointments table, so monthly charts use month numbers (1–12).
Revenue is shown without a currency symbol (the dataset does not specify one).
Raw source files are not included in this repository.
How to run
Clone the repository and create an environment: pip install pandas sqlalchemy pymysql jupyter.
Create a MySQL database named medimetrics.
Run notebooks/data_importing.ipynb to load the two cleaned CSVs (enter your own credentials when prompted – never commit passwords).
Run the queries in sql/quaries.sql in MySQL Workbench.
Open dashboard/MediMetrics_Hospital_Analytics_Redesigned.pbix in Power BI Desktop and update the MySQL connection (Home → Transform data → Data source settings), then Refresh.

Security: do not store database passwords in notebooks. Use getpass or environment variables, and add a .gitignore for credentials and local config.
Author
Shanmukha Reddy Data Analytics Project – MediMetrics Hospital Analytics
