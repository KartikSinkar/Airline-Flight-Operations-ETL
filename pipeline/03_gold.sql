-- GOLD: MONTHLY
CREATE OR REFRESH MATERIALIZED VIEW gold_monthly_flights AS
SELECT DATE_TRUNC('MONTH', flight_date) AS flight_month,
       COUNT(*)                         AS flights,
       SUM(passengers)                  AS passengers,
       SUM(seat_capacity)               AS seats,
       ROUND(SUM(passengers) * 100.0 / SUM(seat_capacity), 1) AS load_factor_pct,
       SUM(ticket_revenue)              AS ticket_revenue,
       SUM(fuel_cost)                   AS fuel_cost,
       SUM(CASE WHEN delay_category <> 'On Time' THEN 1 ELSE 0 END) AS delayed_flights
FROM silver_flights_clean
GROUP BY DATE_TRUNC('MONTH', flight_date);

-- GOLD: AIRLINE
CREATE OR REFRESH MATERIALIZED VIEW gold_airline_summary AS
SELECT airline,
       COUNT(*)                AS flights,
       SUM(passengers)         AS passengers,
       SUM(ticket_revenue)     AS ticket_revenue,
       ROUND(SUM(passengers) * 100.0 / SUM(seat_capacity), 1) AS load_factor_pct,
       ROUND(SUM(CASE WHEN delay_category = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS on_time_pct,
       ROUND(AVG(delay_minutes), 1) AS avg_delay_minutes
FROM silver_flights_clean
GROUP BY airline;

-- GOLD: ROUTE
CREATE OR REFRESH MATERIALIZED VIEW gold_route_summary AS
SELECT origin_city, destination_city,
       COUNT(*)            AS flights,
       SUM(passengers)     AS passengers,
       SUM(ticket_revenue) AS ticket_revenue,
       ROUND(SUM(passengers) * 100.0 / SUM(seat_capacity), 1) AS load_factor_pct
FROM silver_flights_clean
GROUP BY origin_city, destination_city;

-- GOLD: DELAY
CREATE OR REFRESH MATERIALIZED VIEW gold_delay_summary AS
SELECT delay_category, delay_reason,
       COUNT(*)                     AS flights,
       ROUND(AVG(delay_minutes), 1) AS avg_delay_minutes
FROM silver_flights_clean
GROUP BY delay_category, delay_reason;
