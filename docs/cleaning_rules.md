# Cleaning Rules and Why

Source: `airline_flights_raw.csv` (1,365 rows, 20 columns, synthetic 2025 domestic flights). All rules run in `silver_flights_clean`, and bad rows are saved with a reason in `silver_flights_rejected`.

| # | Problem found | Rule applied | SQL used | Why |
|---|---|---|---|---|
| 1 | Duplicate flights (25 rows) | Keep one copy of each row | `SELECT DISTINCT` | `flight_id` must be unique, so extra copies inflate flights, passengers and revenue |
| 2 | Extra spaces and mixed case in airline, origin city, destination city, delay reason | Trim spaces, convert to Title Case | `INITCAP(TRIM(col))` | The same value must not appear as several groups in reports |
| 3 | Blank airline (11 rows) | Replace with `Unknown` | `COALESCE(..., 'Unknown')` | The flight is still valid, so we keep it and show the gap openly |
| 4 | Blank delay reason (12 rows) | Replace with `Unknown` | `COALESCE(..., 'Unknown')` | Same reason as above |
| 5 | Blank delay minutes (18 rows) | Calculate from the two departure times | `COALESCE(delay_minutes, TIMESTAMPDIFF(MINUTE, scheduled_departure, actual_departure))` | The answer is already in the data, so no guessing is needed |
| 6 | Blank ticket revenue (16 rows) | Calculate passengers x average fare | `COALESCE(ticket_revenue, passengers * avg_fare)` | This is the business formula for revenue |
| 7 | Blank aircraft ID | Leave as is | no change | Revenue and delays are still valid without it |
| 8 | Passengers more than seats (11 rows) | Remove from clean table, save in rejected table | `EXPECT (passengers BETWEEN 0 AND seat_capacity) ON VIOLATION DROP ROW` | A plane cannot carry more people than it has seats, so this would distort load factor |
| 9 | Negative average fare (8 rows) | Remove from clean table, save in rejected table | `EXPECT (avg_fare >= 0) ON VIOLATION DROP ROW` | A negative fare would reduce revenue incorrectly |
| 10 | Negative delay minutes | Keep (not an error) | no change | It means the flight left early, which counts as On Time |
| 11 | Aircraft ID text | Do not use INITCAP | no change | INITCAP would turn `VT-SJAF` into `Vt-Sjaf` |

**New column:** `delay_category` is `On Time` (15 minutes or less, including early), `Minor Delay` (16 to 60) or `Major Delay` (more than 60), built with `CASE WHEN`.

**Reconciliation:** 1,365 Bronze rows = 1,321 clean + 19 rejected + 25 duplicates removed. Result: **passed**.
