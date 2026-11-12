USE medimetrics;

-- Check appointments count
SELECT COUNT(*) AS total_appointments
FROM appointments;

-- Check doctors count
SELECT COUNT(*) AS total_doctors
FROM doctors;

-- Check appointments structure
DESCRIBE appointments;

-- Check doctors structure
DESCRIBE doctors;
-- Business Question:
-- What is the overall performance of the hospital?

SELECT
    COUNT(*) AS total_appointments,
    COUNT(DISTINCT patient_id) AS total_patients,
    COUNT(DISTINCT doctor_id) AS total_doctors,

    -- Count completed appointments
    SUM(CASE WHEN appointment_status = 'Completed' THEN 1 ELSE 0 END)
        AS completed_appointments,

    -- Count cancelled appointments
    SUM(CASE WHEN appointment_status = 'Cancelled' THEN 1 ELSE 0 END)
        AS cancelled_appointments,

    -- Count no-show appointments
    SUM(CASE WHEN appointment_status = 'No-Show' THEN 1 ELSE 0 END)
        AS no_show_appointments

FROM appointments;

-- Business Question:
-- How does appointment demand change every month?

SELECT
    YEAR(appointment_date) AS year,
    MONTH(appointment_date) AS month,
    COUNT(*) AS total_appointments

FROM appointments

-- Group appointments by year and month
GROUP BY YEAR(appointment_date), MONTH(appointment_date)

-- Display results in chronological order
ORDER BY year, month;

-- Business Question:
-- What percentage of appointments are completed,
-- cancelled, scheduled, or missed?

SELECT
    appointment_status,
    COUNT(*) AS total_appointments,

    -- Calculate percentage of each appointment status
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM appointments), 2
    ) AS percentage

FROM appointments

GROUP BY appointment_status
ORDER BY total_appointments DESC;


-- Business Question:
-- What percentage of resolved appointments are missed by patients?

SELECT
    COUNT(*) AS resolved_appointments,

    -- Count appointments where patients did not attend
    SUM(CASE WHEN appointment_status = 'No-Show' THEN 1 ELSE 0 END)
        AS no_show_count,

    -- Calculate no-show percentage
    ROUND(
        SUM(CASE WHEN appointment_status = 'No-Show' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS no_show_percentage

FROM appointments

-- Exclude cancelled and pending appointments
WHERE appointment_status IN ('Completed', 'No-Show');

-- Business Question:
-- Which medical specialties experience the highest no-show rates?

SELECT
    specialty,
    COUNT(*) AS total_resolved_appointments,

    -- Count missed appointments
    SUM(CASE WHEN appointment_status = 'No-Show' THEN 1 ELSE 0 END)
        AS no_shows,

    -- Calculate specialty-wise no-show rate
    ROUND(
        SUM(CASE WHEN appointment_status = 'No-Show' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    ) AS no_show_rate

FROM appointments

WHERE appointment_status IN ('Completed', 'No-Show')

GROUP BY specialty
ORDER BY no_show_rate DESC;

-- Identify the busiest doctors based on appointment volume

SELECT
    d.doctor_name,
    d.specialty,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(CASE WHEN a.appointment_status = 'Completed'
        THEN 1 ELSE 0 END) AS completed_appointments

FROM doctors d
LEFT JOIN appointments a
    ON d.doctor_id = a.doctor_id

GROUP BY d.doctor_id, d.doctor_name, d.specialty
ORDER BY total_appointments DESC
LIMIT 15;
-- Analyse average patient waiting time by specialty

SELECT
    specialty,
    COUNT(*) AS completed_visits,
    ROUND(AVG(wait_time_minutes), 2) AS avg_waiting_time,
    MAX(wait_time_minutes) AS maximum_waiting_time

FROM appointments

WHERE appointment_status = 'Completed'
AND wait_time_minutes IS NOT NULL

GROUP BY specialty
ORDER BY avg_waiting_time DESC;

-- Identify the highest revenue-generating specialties

SELECT
    specialty,
    COUNT(*) AS completed_visits,
    ROUND(SUM(revenue_realized), 2) AS total_revenue,
    ROUND(AVG(revenue_realized), 2) AS avg_revenue_per_visit

FROM appointments

WHERE appointment_status = 'Completed'

GROUP BY specialty
ORDER BY total_revenue DESC;
-- Compare patient no-show rates across booking channels

SELECT
    booking_channel,
    COUNT(*) AS total_resolved_appointments,

    SUM(CASE WHEN appointment_status = 'No-Show'
        THEN 1 ELSE 0 END) AS no_shows,

    ROUND(
        SUM(CASE WHEN appointment_status = 'No-Show'
            THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS no_show_rate

FROM appointments

WHERE appointment_status IN ('Completed', 'No-Show')

GROUP BY booking_channel
ORDER BY no_show_rate DESC;

-- Evaluate patient satisfaction across medical specialties

SELECT
    specialty,
    COUNT(patient_satisfaction_score) AS feedback_count,
    ROUND(AVG(patient_satisfaction_score), 2) AS avg_satisfaction

FROM appointments

WHERE appointment_status = 'Completed'
AND patient_satisfaction_score IS NOT NULL

GROUP BY specialty
ORDER BY avg_satisfaction DESC;

