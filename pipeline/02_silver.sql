-- SILVER: CLEAN
CREATE OR REFRESH MATERIALIZED VIEW silver_flights_clean (
  CONSTRAINT valid_passengers EXPECT (passengers BETWEEN 0 AND seat_capacity) ON VIOLATION DROP ROW,
  CONSTRAINT valid_fare       EXPECT (avg_fare >= 0)                          ON VIOLATION DROP ROW
) AS
WITH cleaned AS (
  SELECT DISTINCT
    flight_id,
    flight_number,
    COALESCE(INITCAP(TRIM(airline)), 'Unknown')        AS airline,
    aircraft_id,
    TRIM(aircraft_type)                                AS aircraft_type,
    flight_date,
    day_of_week,
    INITCAP(TRIM(origin_city))                         AS origin_city,
    INITCAP(TRIM(destination_city))                    AS destination_city,
    origin_region,
    distance_km,
    scheduled_departure,
    actual_departure,
    COALESCE(delay_minutes,
      TIMESTAMPDIFF(MINUTE, scheduled_departure, actual_departure)) AS delay_minutes,
    COALESCE(INITCAP(TRIM(delay_reason)), 'Unknown')   AS delay_reason,
    seat_capacity,
    passengers,
    avg_fare,
    COALESCE(ticket_revenue, passengers * avg_fare)    AS ticket_revenue,
    fuel_cost
  FROM bronze_airline_flights
)
SELECT *,
  CASE WHEN delay_minutes <= 15 THEN 'On Time'
       WHEN delay_minutes <= 60 THEN 'Minor Delay'
       ELSE 'Major Delay' END AS delay_category
FROM cleaned;

-- SILVER: REJECTED
CREATE OR REFRESH MATERIALIZED VIEW silver_flights_rejected AS
SELECT *,
  CASE WHEN passengers > seat_capacity OR passengers < 0 THEN 'Passengers more than seats'
       ELSE 'Average fare is negative' END AS reject_reason
FROM bronze_airline_flights
WHERE passengers > seat_capacity OR passengers < 0 OR avg_fare < 0;
