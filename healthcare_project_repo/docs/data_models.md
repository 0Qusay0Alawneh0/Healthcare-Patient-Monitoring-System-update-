# Comprehensive Data Models for Healthcare Patient Monitoring System

This document details the data models for each database in our polyglot persistence architecture, including schema design, partitioning strategies, indexing approaches, and consistency considerations.

## MongoDB: Patient Information (Document Database)

### Schema Design

```json
{
  "patient_id": "P001",
  "region": "Northeast",
  "personal_info": {
    "name": "John Doe",
    "dob": "1978-05-15",
    "gender": "Male",
    "contact": {
      "email": "john.doe@example.com",
      "phone": "555-123-4567",
      "address": {
        "street": "123 Main St",
        "city": "Boston",
        "state": "MA",
        "zip": "02108",
        "country": "USA"
      }
    },
    "emergency_contact": {
      "name": "Jane Doe",
      "relationship": "Spouse",
      "phone": "555-987-6543"
    }
  },
  "medical_history": [
    {
      "condition": "Type 2 Diabetes",
      "diagnosed_date": "2015-03-10",
      "status": "Active",
      "notes": "Managed with medication and diet"
    },
    {
      "condition": "Hypertension",
      "diagnosed_date": "2018-07-22",
      "status": "Active",
      "notes": "Controlled with medication"
    }
  ],
  "allergies": [
    {
      "allergen": "Penicillin",
      "severity": "High",
      "reaction": "Anaphylaxis"
    }
  ],
  "medications": [
    {
      "name": "Metformin",
      "dosage": "500mg",
      "frequency": "Twice daily",
      "start_date": "2015-03-15",
      "end_date": null
    },
    {
      "name": "Lisinopril",
      "dosage": "10mg",
      "frequency": "Once daily",
      "start_date": "2018-08-01",
      "end_date": null
    }
  ],
  "insurance": {
    "provider": "HealthPlus",
    "policy_number": "HP12345678",
    "group_number": "G-9876",
    "coverage_start": "2023-01-01"
  },
  "created_at": "2023-01-15T10:30:00Z",
  "updated_at": "2023-05-10T14:45:00Z"
}
```

### Partitioning Strategy
- **Sharding Key**: `{ region: 1, patient_id: 1 }`
  - Ensures patients are distributed by geographic region
  - Patient_id provides additional uniqueness within regions
- **Shard Distribution**: Each shard corresponds to a major geographic region (Northeast, Southeast, Midwest, West, etc.)

### Indexing Strategy
```javascript
// Primary index (automatically created on _id)
db.patients.createIndex({ "_id": 1 })

// Region-based sharding index
db.patients.createIndex({ "region": 1, "patient_id": 1 })

// Name search index
db.patients.createIndex({ "personal_info.name": 1 })

// Medical condition search index
db.patients.createIndex({ "medical_history.condition": 1 })

// Compound index for region and medical condition queries
db.patients.createIndex({ "region": 1, "medical_history.condition": 1 })
```

### Consistency Configuration
- **Write Concern**: `{ w: "majority", j: true }`
  - Ensures writes are acknowledged by a majority of replicas
  - Journal commit required for durability
- **Read Concern**: `{ level: "majority" }`
  - Guarantees reading the most recent data acknowledged by majority
- **Read Preference**: `{ mode: "primaryPreferred" }`
  - Reads from primary by default for strong consistency
  - Falls back to secondary during primary unavailability

## InfluxDB: Vital Signs Monitoring (Time-Series Database)

### Schema Design

```
measurement: vitals
tags:
  - patient_id: P001
  - device_id: D123
  - region: Northeast
fields:
  - heartbeat: 80 (integer)
  - blood_pressure_systolic: 120 (integer)
  - blood_pressure_diastolic: 80 (integer)
  - temperature: 98.6 (float)
  - oxygen_saturation: 98 (integer)
  - respiratory_rate: 16 (integer)
timestamp: 2023-05-19T10:30:00Z
```

### Partitioning Strategy
- **Time-Based Partitioning**: Automatic partitioning by time (default in InfluxDB)
  - Configurable shard duration (e.g., 1 day for recent data, 7 days for older data)
- **Tag-Based Partitioning**: Using `region` tag to distribute data across nodes

### Retention Policies
```sql
-- High precision retention for recent data (7 days)
CREATE RETENTION POLICY "recent_data" ON "health" DURATION 7d REPLICATION 3 DEFAULT

-- Downsampled data for medium-term storage (30 days)
CREATE RETENTION POLICY "medium_term" ON "health" DURATION 30d REPLICATION 2

-- Long-term storage with aggregated data (1 year)
CREATE RETENTION POLICY "long_term" ON "health" DURATION 52w REPLICATION 2
```

### Continuous Queries for Downsampling
```sql
-- Downsample to 5-minute averages for medium-term storage
CREATE CONTINUOUS QUERY "cq_downsample_5m" ON "health"
BEGIN
  SELECT mean("heartbeat") AS "heartbeat",
         mean("blood_pressure_systolic") AS "blood_pressure_systolic",
         mean("blood_pressure_diastolic") AS "blood_pressure_diastolic",
         mean("temperature") AS "temperature",
         mean("oxygen_saturation") AS "oxygen_saturation",
         mean("respiratory_rate") AS "respiratory_rate"
  INTO "medium_term"."downsampled_vitals"
  FROM "recent_data"."vitals"
  GROUP BY time(5m), "patient_id", "region"
END

-- Downsample to hourly averages for long-term storage
CREATE CONTINUOUS QUERY "cq_downsample_1h" ON "health"
BEGIN
  SELECT mean("heartbeat") AS "heartbeat",
         mean("blood_pressure_systolic") AS "blood_pressure_systolic",
         mean("blood_pressure_diastolic") AS "blood_pressure_diastolic",
         mean("temperature") AS "temperature",
         mean("oxygen_saturation") AS "oxygen_saturation",
         mean("respiratory_rate") AS "respiratory_rate"
  INTO "long_term"."downsampled_vitals"
  FROM "recent_data"."vitals"
  GROUP BY time(1h), "patient_id", "region"
END
```

### Consistency Configuration
- **Consistency**: Set to `any` for write operations to prioritize availability
- **Replication Factor**: 3 for recent data, 2 for historical data
- **Eventual Consistency Model**: Acceptable for time-series vital sign data

## Neo4j: Doctor-Patient Relationships (Graph Database)

### Schema Design

#### Node Labels and Properties

**Patient Nodes**
```cypher
CREATE (:Patient {
  id: "P001",
  name: "John Doe",
  region: "Northeast",
  risk_level: "Medium"
})
```

**Doctor Nodes**
```cypher
CREATE (:Doctor {
  id: "D001",
  name: "Dr. Sarah Smith",
  specialization: "Cardiology",
  hospital: "Memorial Hospital",
  region: "Northeast"
})
```

**Hospital Nodes**
```cypher
CREATE (:Hospital {
  id: "H001",
  name: "Memorial Hospital",
  region: "Northeast",
  type: "General"
})
```

**Treatment Nodes**
```cypher
CREATE (:Treatment {
  id: "T001",
  name: "Cardiac Evaluation",
  date: "2023-05-10",
  outcome: "Stable"
})
```

#### Relationships

```cypher
// Doctor-Patient relationship
CREATE (p:Patient {id: "P001"})-[:TREATED_BY {
  since: "2022-01-15",
  primary: true
}]->(d:Doctor {id: "D001"})

// Doctor-Hospital affiliation
CREATE (d:Doctor {id: "D001"})-[:AFFILIATED_WITH {
  since: "2018-03-01",
  position: "Senior Cardiologist"
}]->(h:Hospital {id: "H001"})

// Patient-Treatment relationship
CREATE (p:Patient {id: "P001"})-[:RECEIVED {
  date: "2023-05-10"
}]->(t:Treatment {id: "T001"})

// Doctor-Treatment relationship
CREATE (d:Doctor {id: "D001"})-[:PERFORMED {
  date: "2023-05-10"
}]->(t:Treatment {id: "T001"})
```

### Indexing Strategy
```cypher
// Create indexes for efficient node lookup
CREATE INDEX patient_id FOR (p:Patient) ON (p.id)
CREATE INDEX doctor_id FOR (d:Doctor) ON (d.id)
CREATE INDEX hospital_id FOR (h:Hospital) ON (h.id)
CREATE INDEX treatment_id FOR (t:Treatment) ON (t.id)

// Composite indexes for region-based queries
CREATE INDEX patient_region FOR (p:Patient) ON (p.region, p.id)
CREATE INDEX doctor_region FOR (d:Doctor) ON (d.region, d.specialization)
```

### Partitioning Strategy
- **Neo4j Fabric**: Used for multi-region deployment
  - Each region has its own Neo4j instance
  - Cross-region queries handled by Fabric
- **Region-Based Routing**: Applications connect to the appropriate regional instance

### Consistency Configuration
- **Causal Consistency**: Enabled for read transactions
- **Transaction Functions**: Used for complex operations requiring atomicity
- **Read Replicas**: Deployed for scaling read operations while maintaining consistency

## Apache Cassandra: Patient Analytics (Column-Family Database)

### Schema Design

```cql
-- Keyspace with NetworkTopologyStrategy for multi-region deployment
CREATE KEYSPACE patient_analytics
WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'Northeast': 3,
  'Southeast': 3,
  'Midwest': 3,
  'West': 3
};

-- Table for storing patient risk analytics by region
CREATE TABLE patient_analytics.risk_scores (
  region text,
  patient_id text,
  timestamp timestamp,
  risk_score float,
  risk_factors map<text, float>,
  alert_level text,
  data_sources set<text>,
  PRIMARY KEY ((region, patient_id), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);

-- Table for regional aggregated analytics
CREATE TABLE patient_analytics.regional_stats (
  region text,
  date date,
  hour int,
  avg_risk_score float,
  high_risk_count int,
  medium_risk_count int,
  low_risk_count int,
  PRIMARY KEY ((region), date, hour)
) WITH CLUSTERING ORDER BY (date DESC, hour DESC);

-- Table for patient vital statistics trends
CREATE TABLE patient_analytics.vital_trends (
  patient_id text,
  vital_type text,
  date date,
  hour int,
  min_value float,
  max_value float,
  avg_value float,
  std_deviation float,
  sample_count int,
  PRIMARY KEY ((patient_id, vital_type), date, hour)
) WITH CLUSTERING ORDER BY (date DESC, hour DESC);
```

### Partitioning Strategy
- **Partition Key**: Composite key using `region` and `patient_id` for risk_scores
  - Ensures data for a patient is on the same node
  - Distributes load across regions
- **Clustering Key**: `timestamp` with descending order
  - Optimizes for recent data access patterns

### Indexing Strategy
```cql
-- Secondary index on alert level for filtering
CREATE INDEX ON patient_analytics.risk_scores (alert_level);

-- Secondary index on risk score for threshold queries
CREATE INDEX ON patient_analytics.risk_scores (risk_score);
```

### Consistency Configuration
- **Write Consistency**: LOCAL_QUORUM
  - Ensures durability within a region
- **Read Consistency**: LOCAL_ONE for real-time dashboards
  - Prioritizes availability and low latency
- **Read Consistency**: LOCAL_QUORUM for critical operations
  - Used when accuracy is more important than speed

## Redis: Alerts and Caching (Key-Value Database)

### Schema Design

#### Alert Keys
```
patient:alerts:{region}:{patient_id} -> List of recent alerts
patient:alerts:count:{region}:{patient_id} -> Count of unacknowledged alerts
patient:alerts:latest:{region}:{patient_id} -> Most recent alert details
```

#### Alert Notification Sets
```
alerts:pending:{region} -> Sorted set of patient_ids with pending alerts (score = priority)
alerts:critical:{region} -> Set of patient_ids with critical alerts
```

#### Cache Keys
```
cache:patient:{patient_id} -> Cached patient basic info (Hash)
cache:vitals:latest:{patient_id} -> Latest vital signs (Hash)
cache:risk:{patient_id} -> Current risk assessment (Hash)
```

### Data Structures

#### Alert Hash Structure
```
{
  "id": "A12345",
  "patient_id": "P001",
  "timestamp": "2023-05-19T10:35:00Z",
  "type": "high_heartrate",
  "value": 120,
  "threshold": 100,
  "priority": 2,
  "status": "pending",
  "message": "Elevated heart rate detected"
}
```

#### Patient Cache Hash Structure
```
{
  "id": "P001",
  "name": "John Doe",
  "age": 45,
  "primary_doctor": "D001",
  "risk_level": "medium",
  "region": "Northeast"
}
```

### Partitioning Strategy
- **Redis Cluster**: Implemented with hash slots
- **Key Prefixing**: Region-based prefixes ensure related data is co-located
- **Hash Tags**: Used to ensure related keys are on the same node
  - Example: `patient:{region}:{patient_id}` ensures all patient data is on same node

### Expiration Policies
```
// Set expiration for cached patient data (1 hour)
EXPIRE cache:patient:{patient_id} 3600

// Set expiration for resolved alerts (24 hours)
EXPIRE patient:alerts:resolved:{region}:{patient_id} 86400

// Set shorter expiration for latest vitals cache (5 minutes)
EXPIRE cache:vitals:latest:{patient_id} 300
```

### Persistence Configuration
- **RDB Snapshots**: Configured every 15 minutes
- **AOF Persistence**: Enabled with fsync every second
- **Replication**: Master-replica setup with at least 2 replicas per master

## Cross-Database Integration

### Consistency Boundaries
- **Strong Consistency Zone**: MongoDB (patient records)
- **Eventual Consistency Zone**: InfluxDB, Cassandra (time-series data, analytics)
- **Mixed Consistency Zone**: Redis (alerts - strong for critical, eventual for non-critical)

### Data Flow
1. **Patient Registration**: MongoDB → Redis (cache)
2. **Vital Sign Collection**: InfluxDB → Cassandra (analytics) → Redis (alerts)
3. **Doctor Assignment**: Neo4j → MongoDB (update patient record)
4. **Alert Generation**: Redis → MongoDB (patient history update)

### Synchronization Mechanisms
- **Change Data Capture**: For MongoDB to Neo4j synchronization
- **Message Queue**: For cross-database event propagation
- **Batch ETL Processes**: For analytics data aggregation

## Fault Tolerance Design

### Replication Strategies
- **MongoDB**: Replica sets with 3 nodes per region
- **InfluxDB**: 3-node clusters for recent data, 2-node for historical
- **Neo4j**: Causal cluster with 3 core servers and 2 read replicas
- **Cassandra**: Multi-datacenter deployment with RF=3 per datacenter
- **Redis**: Master-replica with sentinel for automatic failover

### Recovery Procedures
- **Automated Failover**: Configured for all databases
- **Backup Schedules**: Daily full backups, incremental as appropriate
- **Recovery Time Objectives**: 
  - Critical patient data: < 5 minutes
  - Analytics data: < 30 minutes
  - Historical data: < 2 hours
