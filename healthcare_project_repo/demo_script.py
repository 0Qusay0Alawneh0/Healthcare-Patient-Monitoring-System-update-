# Demo Script: Demonstrate All DB Accesses (pseudo-code style)
# MongoDB (patient data)
#   db.patients.insertOne({...})
#   db.patients.find()

# InfluxDB (time-series data)
#   Write: curl -i -XPOST http://localhost:8086/write?db=health --data-binary 'vitals,patient_id=P001 heartbeat=80'

# Cassandra (analytics)
#   INSERT INTO patient_analytics (patient_id, timestamp, risk_score) VALUES ('P001', toTimestamp(now()), 0.7);

# Neo4j (relationships)
#   MATCH (p:Patient)-[:TREATED_BY]->(d:Doctor) RETURN p, d;

# Redis (alerts)
#   SET patient:alerts:P001 "Abnormal heartbeat at 10:01AM"
#   GET patient:alerts:P001
