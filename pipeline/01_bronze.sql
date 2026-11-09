-- BRONZE: raw flights loaded as-is, plus file name and load time
CREATE OR REFRESH STREAMING TABLE bronze_airline_flights AS
SELECT *,
       _metadata.file_name AS source_file,
       current_timestamp() AS loaded_at
FROM STREAM read_files('/Volumes/airline_flights/default/raw_files/',
                       format => 'csv', header => true);
