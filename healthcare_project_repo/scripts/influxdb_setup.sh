#!/bin/bash
# InfluxDB setup script

# Wait for InfluxDB instances to be ready
echo "Waiting for InfluxDB instances to start..."
sleep 20

# Configure InfluxDB-1 (primary node)
echo "Configuring InfluxDB primary node..."

# Create retention policies
curl -i -XPOST "http://influxdb-1:8086/query" \
  -u admin:adminpass \
  --data-urlencode "q=CREATE RETENTION POLICY \"recent_data\" ON \"health\" DURATION 7d REPLICATION 3 DEFAULT"

curl -i -XPOST "http://influxdb-1:8086/query" \
  -u admin:adminpass \
  --data-urlencode "q=CREATE RETENTION POLICY \"medium_term\" ON \"health\" DURATION 30d REPLICATION 2"

curl -i -XPOST "http://influxdb-1:8086/query" \
  -u admin:adminpass \
  --data-urlencode "q=CREATE RETENTION POLICY \"long_term\" ON \"health\" DURATION 52w REPLICATION 2"

# Create continuous queries for downsampling
curl -i -XPOST "http://influxdb-1:8086/query" \
  -u admin:adminpass \
  --data-urlencode "q=CREATE CONTINUOUS QUERY \"cq_downsample_5m\" ON \"health\" BEGIN SELECT mean(\"heartbeat\") AS \"heartbeat\", mean(\"blood_pressure_systolic\") AS \"blood_pressure_systolic\", mean(\"blood_pressure_diastolic\") AS \"blood_pressure_diastolic\", mean(\"temperature\") AS \"temperature\", mean(\"oxygen_saturation\") AS \"oxygen_saturation\", mean(\"respiratory_rate\") AS \"respiratory_rate\" INTO \"medium_term\".\"downsampled_vitals\" FROM \"recent_data\".\"vitals\" GROUP BY time(5m), \"patient_id\", \"region\" END"

curl -i -XPOST "http://influxdb-1:8086/query" \
  -u admin:adminpass \
  --data-urlencode "q=CREATE CONTINUOUS QUERY \"cq_downsample_1h\" ON \"health\" BEGIN SELECT mean(\"heartbeat\") AS \"heartbeat\", mean(\"blood_pressure_systolic\") AS \"blood_pressure_systolic\", mean(\"blood_pressure_diastolic\") AS \"blood_pressure_diastolic\", mean(\"temperature\") AS \"temperature\", mean(\"oxygen_saturation\") AS \"oxygen_saturation\", mean(\"respiratory_rate\") AS \"respiratory_rate\" INTO \"long_term\".\"downsampled_vitals\" FROM \"recent_data\".\"vitals\" GROUP BY time(1h), \"patient_id\", \"region\" END"

# Insert sample data for different regions and patients
echo "Inserting sample vital signs data..."

# Northeast region - Patient P001
curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P001,region=Northeast,device_id=D123 heartbeat=80,blood_pressure_systolic=120,blood_pressure_diastolic=80,temperature=98.6,oxygen_saturation=98,respiratory_rate=16 1621436400000000000'

curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P001,region=Northeast,device_id=D123 heartbeat=82,blood_pressure_systolic=122,blood_pressure_diastolic=81,temperature=98.7,oxygen_saturation=97,respiratory_rate=17 1621440000000000000'

curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P001,region=Northeast,device_id=D123 heartbeat=78,blood_pressure_systolic=118,blood_pressure_diastolic=79,temperature=98.5,oxygen_saturation=99,respiratory_rate=15 1621443600000000000'

# Southeast region - Patient P002
curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P002,region=Southeast,device_id=D456 heartbeat=75,blood_pressure_systolic=115,blood_pressure_diastolic=75,temperature=98.4,oxygen_saturation=97,respiratory_rate=14 1621436400000000000'

curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P002,region=Southeast,device_id=D456 heartbeat=76,blood_pressure_systolic=116,blood_pressure_diastolic=76,temperature=98.5,oxygen_saturation=98,respiratory_rate=15 1621440000000000000'

curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P002,region=Southeast,device_id=D456 heartbeat=74,blood_pressure_systolic=114,blood_pressure_diastolic=74,temperature=98.3,oxygen_saturation=96,respiratory_rate=14 1621443600000000000'

# Midwest region - Patient P003
curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P003,region=Midwest,device_id=D789 heartbeat=85,blood_pressure_systolic=130,blood_pressure_diastolic=85,temperature=98.8,oxygen_saturation=96,respiratory_rate=18 1621436400000000000'

curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P003,region=Midwest,device_id=D789 heartbeat=86,blood_pressure_systolic=132,blood_pressure_diastolic=86,temperature=98.9,oxygen_saturation=95,respiratory_rate=19 1621440000000000000'

curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P003,region=Midwest,device_id=D789 heartbeat=84,blood_pressure_systolic=128,blood_pressure_diastolic=84,temperature=98.7,oxygen_saturation=97,respiratory_rate=17 1621443600000000000'

# West region - Patient P004
curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P004,region=West,device_id=D101 heartbeat=72,blood_pressure_systolic=110,blood_pressure_diastolic=70,temperature=98.2,oxygen_saturation=99,respiratory_rate=14 1621436400000000000'

curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P004,region=West,device_id=D101 heartbeat=73,blood_pressure_systolic=112,blood_pressure_diastolic=71,temperature=98.3,oxygen_saturation=98,respiratory_rate=15 1621440000000000000'

curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P004,region=West,device_id=D101 heartbeat=71,blood_pressure_systolic=108,blood_pressure_diastolic=69,temperature=98.1,oxygen_saturation=99,respiratory_rate=13 1621443600000000000'

# Verify data was inserted
echo "Verifying data insertion..."
curl -G "http://influxdb-1:8086/query?pretty=true" \
  -u admin:adminpass \
  --data-urlencode "db=health" \
  --data-urlencode "q=SELECT COUNT(*) FROM vitals GROUP BY region"

echo "InfluxDB setup completed!"
