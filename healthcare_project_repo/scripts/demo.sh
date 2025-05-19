#!/bin/bash
# Main demonstration script for Healthcare Patient Monitoring System

# Function to display section header
section() {
  echo ""
  echo "============================================================"
  echo "  $1"
  echo "============================================================"
  echo ""
}

# Function to pause between sections
pause() {
  echo ""
  echo "Press Enter to continue..."
  read
}

section "Healthcare Patient Monitoring System Demonstration"
echo "This script demonstrates the functionality of our polyglot database system"
echo "for healthcare patient monitoring, including:"
echo "- MongoDB for patient information (Document DB)"
echo "- InfluxDB for vital signs (Time-Series DB)"
echo "- Neo4j for doctor-patient relationships (Graph DB)"
echo "- Cassandra for analytics (Column-Family DB)"
echo "- Redis for alerts and caching (Key-Value DB)"
pause

section "1. MongoDB: Patient Information (Document Database)"
echo "Demonstrating CRUD operations on patient records..."

# Create a new patient
echo "Creating a new patient record..."
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin <<EOF
use healthcare;
db.patients.insertOne({
  patient_id: "P005",
  region: "Northeast",
  personal_info: {
    name: "Sarah Williams",
    dob: new Date("1982-11-30"),
    gender: "Female",
    contact: {
      email: "sarah.williams@example.com",
      phone: "555-567-8901",
      address: {
        street: "456 Park Ave",
        city: "New York",
        state: "NY",
        zip: "10022",
        country: "USA"
      }
    }
  },
  medical_history: [
    {
      condition: "Asthma",
      diagnosed_date: new Date("2010-05-12"),
      status: "Active"
    }
  ],
  created_at: new Date(),
  updated_at: new Date()
});
EOF
pause

# Read patient data with regional partitioning
echo "Reading patient data with regional partitioning..."
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin <<EOF
use healthcare;
// Query patients by region (demonstrating partitioning)
print("Patients in Northeast region:");
db.patients.find({region: "Northeast"}, {patient_id: 1, "personal_info.name": 1, region: 1, _id: 0}).pretty();

print("\nPatients in Southeast region:");
db.patients.find({region: "Southeast"}, {patient_id: 1, "personal_info.name": 1, region: 1, _id: 0}).pretty();

// Query patients by medical condition (demonstrating indexing)
print("\nPatients with Diabetes:");
db.patients.find({"medical_history.condition": "Type 2 Diabetes"}, 
                {patient_id: 1, "personal_info.name": 1, region: 1, _id: 0}).pretty();
EOF
pause

# Update patient data
echo "Updating patient data..."
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin <<EOF
use healthcare;
// Update a patient record
db.patients.updateOne(
  { patient_id: "P005" },
  { 
    \$push: { 
      allergies: {
        allergen: "Dust",
        severity: "Medium",
        reaction: "Sneezing, wheezing"
      }
    },
    \$set: { updated_at: new Date() }
  }
);

// Verify the update
db.patients.findOne({ patient_id: "P005" }, { patient_id: 1, "personal_info.name": 1, allergies: 1, _id: 0 });
EOF
pause

# Demonstrate strong consistency with write concern
echo "Demonstrating strong consistency with write concern..."
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin <<EOF
use healthcare;
// Insert with majority write concern for strong consistency
db.patients.insertOne(
  {
    patient_id: "P006",
    region: "West",
    personal_info: {
      name: "Thomas Anderson",
      dob: new Date("1975-03-11"),
      gender: "Male"
    },
    created_at: new Date(),
    updated_at: new Date()
  },
  { writeConcern: { w: "majority", j: true } }
);

// Read with majority read concern
db.patients.findOne(
  { patient_id: "P006" },
  { readConcern: { level: "majority" } }
);
EOF
pause

section "2. InfluxDB: Vital Signs Monitoring (Time-Series Database)"
echo "Demonstrating time-series data operations..."

# Write new vital signs data
echo "Writing new vital signs data..."
curl -i -XPOST "http://influxdb-1:8086/write?db=health" \
  -u admin:adminpass \
  --data-binary 'vitals,patient_id=P005,region=Northeast,device_id=D555 heartbeat=88,blood_pressure_systolic=125,blood_pressure_diastolic=82,temperature=99.1,oxygen_saturation=96,respiratory_rate=18 1621450000000000000'
pause

# Query vital signs data
echo "Querying vital signs data..."
curl -G "http://influxdb-1:8086/query?pretty=true" \
  -u admin:adminpass \
  --data-urlencode "db=health" \
  --data-urlencode "q=SELECT * FROM vitals WHERE patient_id='P005' ORDER BY time DESC LIMIT 1"
pause

# Demonstrate time-based queries
echo "Demonstrating time-based queries..."
curl -G "http://influxdb-1:8086/query?pretty=true" \
  -u admin:adminpass \
  --data-urlencode "db=health" \
  --data-urlencode "q=SELECT mean(\"heartbeat\") AS \"avg_heartbeat\", max(\"heartbeat\") AS \"max_heartbeat\", min(\"heartbeat\") AS \"min_heartbeat\" FROM vitals WHERE patient_id='P001' AND time > now() - 1d GROUP BY time(1h)"
pause

# Demonstrate downsampling with continuous queries
echo "Demonstrating downsampling with continuous queries..."
curl -G "http://influxdb-1:8086/query?pretty=true" \
  -u admin:adminpass \
  --data-urlencode "db=health" \
  --data-urlencode "q=SHOW CONTINUOUS QUERIES"
pause

section "3. Neo4j: Doctor-Patient Relationships (Graph Database)"
echo "Demonstrating graph relationship queries..."

# Basic relationship query
echo "Basic doctor-patient relationship query..."
cypher-shell -a neo4j-core1:7687 -u neo4j -p password "MATCH (p:Patient)-[r:TREATED_BY]->(d:Doctor) RETURN p.name AS Patient, d.name AS Doctor, r.since AS Since, r.primary AS IsPrimary LIMIT 5;"
pause

# Complex graph traversal
echo "Complex graph traversal - Find all doctors treating patients with high risk..."
cypher-shell -a neo4j-core1:7687 -u neo4j -p password "MATCH (p:Patient {risk_level: 'High'})-[:TREATED_BY]->(d:Doctor) RETURN p.name AS HighRiskPatient, d.name AS Doctor;"
pause

# Path finding
echo "Path finding - Find connection between doctors through patients..."
cypher-shell -a neo4j-core1:7687 -u neo4j -p password "MATCH path = (d1:Doctor)-[:PERFORMED]->(:Treatment)<-[:RECEIVED]-(p:Patient)-[:RECEIVED]->(:Treatment)<-[:PERFORMED]-(d2:Doctor) WHERE d1 <> d2 RETURN d1.name AS Doctor1, p.name AS SharedPatient, d2.name AS Doctor2 LIMIT 3;"
pause

# Regional analysis
echo "Regional analysis - Doctor distribution by region..."
cypher-shell -a neo4j-core1:7687 -u neo4j -p password "MATCH (d:Doctor) RETURN d.region AS Region, count(d) AS DoctorCount ORDER BY Region;"
pause

section "4. Cassandra: Patient Analytics (Column-Family Database)"
echo "Demonstrating analytics queries with eventual consistency..."

# Query risk scores by region
echo "Querying risk scores by region..."
cqlsh cassandra-node1 -e "USE patient_analytics; SELECT region, patient_id, timestamp, risk_score, alert_level FROM risk_scores WHERE region = 'Northeast' AND patient_id = 'P001';"
pause

# Insert new analytics data
echo "Inserting new analytics data with LOCAL_QUORUM consistency..."
cqlsh cassandra-node1 -e "
USE patient_analytics;
INSERT INTO risk_scores (region, patient_id, timestamp, risk_score, risk_factors, alert_level, data_sources)
VALUES ('Northeast', 'P005', toTimestamp(now()), 0.45, {'asthma': 0.45}, 'medium', {'vitals', 'medical_history'})
USING CONSISTENCY LOCAL_QUORUM;
"
pause

# Query with different consistency levels
echo "Querying with LOCAL_ONE consistency (prioritizing availability)..."
cqlsh cassandra-node1 -e "
CONSISTENCY LOCAL_ONE;
USE patient_analytics;
SELECT region, patient_id, timestamp, risk_score FROM risk_scores WHERE region = 'Northeast' AND patient_id = 'P005';
"
pause

# Regional aggregation
echo "Regional aggregation - Average risk scores by region..."
cqlsh cassandra-node1 -e "
USE patient_analytics;
SELECT region, avg_risk_score FROM regional_stats WHERE date = '2023-05-19' AND hour = 10;
"
pause

section "5. Redis: Alerts and Caching (Key-Value Database)"
echo "Demonstrating alerts and caching operations..."

# Create a new alert
echo "Creating a new alert..."
redis-cli -h redis-master -p 6379 LPUSH "patient:alerts:Northeast:P005" "High temperature detected at 12:15PM"
redis-cli -h redis-master -p 6379 INCR "patient:alerts:count:Northeast:P005"
redis-cli -h redis-master -p 6379 HMSET "patient:alerts:latest:Northeast:P005" "id" "A12346" "patient_id" "P005" "timestamp" "2023-05-19T12:15:00Z" "type" "high_temperature" "value" 99.1 "threshold" 99.0 "priority" 3 "status" "pending" "message" "High temperature detected"
pause

# Read alerts
echo "Reading alerts..."
redis-cli -h redis-master -p 6379 LRANGE "patient:alerts:Northeast:P005" 0 -1
redis-cli -h redis-master -p 6379 HGETALL "patient:alerts:latest:Northeast:P005"
pause

# Demonstrate caching
echo "Demonstrating caching of patient data..."
redis-cli -h redis-master -p 6379 HMSET "cache:patient:P005" "id" "P005" "name" "Sarah Williams" "age" 41 "primary_doctor" "D001" "risk_level" "medium" "region" "Northeast"
redis-cli -h redis-master -p 6379 EXPIRE "cache:patient:P005" 3600
redis-cli -h redis-master -p 6379 HGETALL "cache:patient:P005"
pause

# Demonstrate pub/sub for real-time alerts
echo "Demonstrating pub/sub for real-time alerts..."
redis-cli -h redis-master -p 6379 PUBLISH "alerts:critical" "CRITICAL ALERT: Patient P003 experiencing cardiac anomaly"
pause

section "6. Fault Tolerance Demonstration"
echo "Demonstrating fault tolerance capabilities..."

# Simulate MongoDB node failure
echo "Simulating MongoDB secondary node failure..."
echo "1. Current replica set status:"
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin --eval "rs.status()"
echo "2. Stopping mongodb-secondary-1 container..."
docker stop mongodb-secondary-1
echo "3. Checking replica set status after node failure:"
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin --eval "rs.status()"
echo "4. Verifying we can still read and write data:"
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin --eval "db.getSiblingDB('healthcare').patients.findOne({patient_id: 'P001'})"
echo "5. Restarting the failed node:"
docker start mongodb-secondary-1
echo "6. Waiting for node to rejoin the cluster..."
sleep 10
echo "7. Final replica set status:"
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin --eval "rs.status()"
pause

# Simulate Redis master failure and failover
echo "Simulating Redis master failure and sentinel failover..."
echo "1. Current Redis master info:"
redis-cli -h redis-master -p 6379 INFO replication
echo "2. Stopping redis-master container..."
docker stop redis-master
echo "3. Waiting for sentinel to detect failure and promote a replica..."
sleep 15
echo "4. Checking new master status:"
redis-cli -h redis-replica1 -p 6379 INFO replication
echo "5. Verifying we can still read and write data to the new master:"
redis-cli -h redis-replica1 -p 6379 SET "failover_test" "success"
redis-cli -h redis-replica1 -p 6379 GET "failover_test"
echo "6. Restarting the original master (will rejoin as replica):"
docker start redis-master
echo "7. Waiting for node to rejoin the cluster..."
sleep 10
echo "8. Final Redis replication status:"
redis-cli -h redis-replica1 -p 6379 INFO replication
pause

section "7. Performance Optimization Demonstration"
echo "Demonstrating performance optimization techniques..."

# MongoDB indexing performance
echo "MongoDB indexing performance comparison..."
echo "1. Query without using index:"
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin <<EOF
use healthcare;
db.patients.find({"medical_history.condition": "Type 2 Diabetes"}).explain("executionStats");
EOF
echo "2. Query using index:"
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin <<EOF
use healthcare;
db.patients.find({region: "Northeast"}).explain("executionStats");
EOF
pause

# Cassandra query optimization
echo "Cassandra query optimization with appropriate partition key..."
echo "1. Efficient query using partition key:"
cqlsh cassandra-node1 -e "USE patient_analytics; SELECT * FROM risk_scores WHERE region = 'Northeast' AND patient_id = 'P001' LIMIT 10;"
echo "2. Query that would require filtering (less efficient):"
cqlsh cassandra-node1 -e "USE patient_analytics; SELECT * FROM risk_scores WHERE alert_level = 'high' ALLOW FILTERING;"
pause

# Redis caching benefit
echo "Redis caching benefit demonstration..."
echo "1. Time to fetch patient data from MongoDB:"
time mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin --eval "db.getSiblingDB('healthcare').patients.findOne({patient_id: 'P001'})"
echo "2. Time to fetch cached patient data from Redis:"
time redis-cli -h redis-master -p 6379 HGETALL "cache:patient:P001"
pause

section "Healthcare Patient Monitoring System Demonstration Complete"
echo "This demonstration has shown:"
echo "1. Polyglot persistence with 5 different database types"
echo "2. Regional partitioning of patient data"
echo "3. Strong consistency for medical records"
echo "4. Eventual consistency for real-time data"
echo "5. High availability through replication"
echo "6. Fault tolerance with automated recovery"
echo "7. Performance optimization techniques"
echo ""
echo "Thank you for watching!"
