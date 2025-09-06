-- verify_data.sql
\c network_monitoring;

-- ตรวจสอบจำนวนแถว
SELECT COUNT(*) AS total_rows FROM host_states;

-- ตรวจสอบค่าสถานะ
SELECT status, COUNT(*) AS count 
FROM host_states 
GROUP BY status 
ORDER BY count DESC;

-- ดูข้อมูลล่าสุด
SELECT host_id, host_name, timestamp, status, response_time
FROM host_states 
ORDER BY timestamp DESC 
LIMIT 10;