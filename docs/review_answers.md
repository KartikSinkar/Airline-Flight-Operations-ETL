# Answers to the Project Review Questions

**1. Why do we keep the raw data in Bronze instead of cleaning the file directly?**
Bronze is an exact copy of the source. If a cleaning rule turns out to be wrong, or we need to audit a number later, we can re-run Silver from the original data. Cleaning the file directly would destroy that evidence and make errors unrecoverable.

**2. Why is a negative delay accepted, but a flight with more passengers than seats rejected?**
A negative delay is real: the flight left early, so it counts as On Time. More passengers than seats is physically impossible, so it must be a data error. Valid-but-unusual values are kept, and impossible values are rejected.

**3. Why can `flight_id` find duplicates but `flight_number` cannot?**
`flight_id` identifies one flight on one day, so it should appear once. `flight_number` (for example SJ-472) is the same flight operating on many days, so repeating is normal.

**4. How does TIMESTAMPDIFF fill a blank delay, and what happens if you swap the two timestamps?**
`TIMESTAMPDIFF(MINUTE, scheduled_departure, actual_departure)` counts the minutes from the scheduled time to the actual time, so 08:30 to 09:12 gives 42. If you swap them, the sign flips: late flights become negative and look early, and early flights look late. Every delay category would be wrong.

**5. Why calculate load factor as SUM(passengers) / SUM(seats) instead of averaging each flight's load factor?**
Averaging per-flight ratios gives a 60-seat plane the same weight as a 180-seat plane. The sum-over-sum method weights each flight by its size, so it equals the true share of all seats that were filled.

**6. Why do we multiply by 100.0 and not 100?**
It forces decimal arithmetic. In many SQL engines, integer division drops the fraction, so a result like 83.9 would become 83 or 0. Using `100.0` keeps the decimals and is a safe habit everywhere, even though Spark SQL's `/` already returns a decimal result.

**7. Which airline has the best on-time performance, and what is the most common delay reason?**
Fly Easy has the best on-time rate at **71.5%** (Air Bharat is next at 69.9%). The most common delay reason is **Weather** with 108 delayed flights, followed closely by Air Traffic with 104.

**8. Which dashboard tool did you choose, and why?**
Databricks AI/BI. It reads the Gold tables directly in the same workspace, needs no connection setup, refreshes right after a pipeline run, and works on Free Edition. Power BI would need extra connection steps to a SQL warehouse for the same result.
