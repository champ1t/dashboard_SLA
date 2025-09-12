# fast_import_fixed.py
import psycopg2
import csv
import json
import tempfile
from tqdm import tqdm  # ✅ เพิ่ม progress bar

def fast_import():
    try:
        csv_path = "/Users/jakkapatmac/Documents/Lab 9 Cre/T.Boat/Dashboard_SLA/host_states.csv"
        
        # สร้างไฟล์ชั่วคราว
        temp_file = tempfile.NamedTemporaryFile(delete=False, mode='w', encoding='utf-8', newline='')
        writer = csv.writer(temp_file)
        writer.writerow(['host_id', 'host_name', 'timestamp', 'status'])
        
        # นับจำนวนบรรทัดเพื่อ progress bar
        with open(csv_path, 'r', encoding='utf-8') as f:
            total_lines = sum(1 for _ in f) - 1  # ลบ header
        
        # map state ให้ตรงกับ constraint (ตัวพิมพ์เล็ก)
        def map_status(val):
            val_str = str(val).strip()
            if val_str == "0":
                return "down"
            elif val_str == "1":
                return "up"
            else:
                return "unknown"
        
        # อ่าน CSV และเขียนลง temp file
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in tqdm(reader, total=total_lines, desc="Processing rows"):
                try:
                    meta = json.loads(row['metadata'])
                    host_id = meta.get('id', '')
                    host_name = meta.get('name', '')
                except:
                    host_id, host_name = '', ''
                
                status = map_status(row['state'])
                writer.writerow([host_id, host_name, row['timestamp'], status])
        
        temp_file.close()
        print(f"ไฟล์แปลงแล้วเก็บที่: {temp_file.name}")
        
        # เชื่อมต่อ PostgreSQL
        conn = psycopg2.connect(
            host="localhost",
            database="network_monitoring",
            user="jakkapatmac"
        )
        cur = conn.cursor()
        
        cur.execute("SELECT COUNT(*) FROM host_states")
        current_count = cur.fetchone()[0]
        print(f"จำนวน record ปัจจุบัน: {current_count}")
        
        print("เริ่ม COPY เข้า PostgreSQL ...")
        with open(temp_file.name, 'r', encoding='utf-8') as tf:
            copy_sql = """
            COPY host_states(host_id, host_name, timestamp, status) 
            FROM STDIN WITH CSV HEADER DELIMITER ','
            """
            cur.copy_expert(copy_sql, tf)
        
        conn.commit()
        print("นำเข้าข้อมูลสำเร็จ!")
        
        cur.execute("SELECT COUNT(*) FROM host_states")
        new_count = cur.fetchone()[0]
        print(f"จำนวน record หลังนำเข้า: {new_count}")
        print(f"เพิ่มขึ้น: {new_count - current_count} record")
        
        cur.close()
        conn.close()
        
    except Exception as e:
        print(f"เกิดข้อผิดพลาด: {e}")

if __name__ == "__main__":
    fast_import()
