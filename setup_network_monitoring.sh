#!/bin/bash
echo "🚀 เริ่มต้นตั้งค่า Network Monitoring System..."

# 1. ตรวจสอบ PostgreSQL
echo "📊 ตรวจสอบ PostgreSQL..."
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL ไม่ได้ติดตั้ง"
    exit 1
fi

# 2. นำเข้าข้อมูล
echo "📥 นำเข้าข้อมูล..."
python import_data.py

# 3. สร้าง Views
echo "🔧 สร้าง Views..."
psql -d network_monitoring -f create_views.sql

# 4. เริ่มต้น Superset
echo "📊 เริ่มต้น Apache Superset..."
docker-compose up -d

# 5. Superset
echo "⚙️ กำลังตั้งค่า Superset..."
sleep 30
docker exec -it superset superset db upgrade
docker exec -it superset superset fab create-admin --username admin --firstname Admin --lastname User --email admin@example.com --password admin123
docker exec -it superset superset init

echo "✅ การตั้งค่าสำเร็จ!"
echo "🌐 เปิด: http://localhost:8088"
echo "👤 Username: admin"
echo "🔑 Password: admin123"
