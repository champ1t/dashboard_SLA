-- create_tables.sql
\c network_monitoring;

-- สร้างตาราง host_states
CREATE TABLE IF NOT EXISTS host_states (
    id SERIAL PRIMARY KEY,
    host_id VARCHAR(50) NOT NULL,
    host_name VARCHAR(255),
    timestamp TIMESTAMP NOT NULL,
    status VARCHAR(20) CHECK (status IN ('up', 'down', 'warning', 'unknown')),
    response_time FLOAT,
    cpu_usage FLOAT,
    memory_usage FLOAT,
    disk_usage FLOAT,
    network_throughput FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- สร้าง index เพื่อเพิ่มประสิทธิภาพ
CREATE INDEX IF NOT EXISTS idx_host_id ON host_states(host_id);
CREATE INDEX IF NOT EXISTS idx_timestamp ON host_states(timestamp);
CREATE INDEX IF NOT EXISTS idx_status ON host_states(status);