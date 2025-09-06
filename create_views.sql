-- create_views.sql
\c network_monitoring;

-- สร้าง View สำหรับ SLA Summary
CREATE OR REPLACE VIEW host_sla_summary AS
SELECT 
    host_id,
    host_name,
    DATE(timestamp) as monitoring_date,
    COUNT(*) AS total_checks,
    COUNT(*) FILTER (WHERE status = 'up') AS up_count,
    COUNT(*) FILTER (WHERE status != 'up') AS down_count,
    ROUND((COUNT(*) FILTER (WHERE status = 'up') * 100.0 / COUNT(*))::numeric, 2) AS sla_percentage,
    MAX(timestamp) AS last_check
FROM host_states
GROUP BY host_id, host_name, DATE(timestamp);

-- สร้าง View สำหรับสถานะล่าสุด
CREATE OR REPLACE VIEW host_current_status AS
SELECT DISTINCT ON (host_id)
    host_id,
    host_name,
    timestamp,
    status
FROM host_states
ORDER BY host_id, timestamp DESC;

-- สร้าง Index สำหรับประสิทธิภาพ
CREATE INDEX IF NOT EXISTS idx_host_timestamp ON host_states(host_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_timestamp ON host_states(timestamp);
CREATE INDEX IF NOT EXISTS idx_status ON host_states(status);