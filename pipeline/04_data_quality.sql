-- GOLD: DATA QUALITY AND RECONCILIATION
CREATE OR REFRESH MATERIALIZED VIEW gold_data_quality AS
SELECT COUNT(*)                                   AS bronze_rows,
       COUNT(*) - COUNT(DISTINCT flight_id)       AS duplicate_rows,
       SUM(CASE WHEN passengers > seat_capacity THEN 1 ELSE 0 END) AS overbooked_rows,
       SUM(CASE WHEN avg_fare < 0 THEN 1 ELSE 0 END)               AS negative_fare_rows,
       SUM(CASE WHEN airline IS NULL THEN 1 ELSE 0 END)            AS missing_airline_rows,
       SUM(CASE WHEN delay_minutes IS NULL THEN 1 ELSE 0 END)      AS missing_delay_rows,
       SUM(CASE WHEN ticket_revenue IS NULL THEN 1 ELSE 0 END)     AS missing_revenue_rows,
       SUM(CASE WHEN delay_reason IS NULL THEN 1 ELSE 0 END)       AS missing_reason_rows,
       (SELECT COUNT(*) FROM silver_flights_clean)    AS clean_rows,
       (SELECT COUNT(*) FROM silver_flights_rejected) AS rejected_rows
FROM bronze_airline_flights;
