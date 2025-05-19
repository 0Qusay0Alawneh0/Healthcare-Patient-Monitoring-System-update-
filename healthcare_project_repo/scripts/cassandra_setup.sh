#!/bin/bash
# Cassandra setup script

# Wait for Cassandra instances to be ready
echo "Waiting for Cassandra instances to start..."
sleep 60

# Connect to the primary Cassandra node and create keyspace and tables
echo "Configuring Cassandra..."

# Create keyspace with NetworkTopologyStrategy for multi-region deployment
cqlsh cassandra-node1 -e "
CREATE KEYSPACE IF NOT EXISTS patient_analytics
WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'DC1': 2,
  'DC2': 1
};
"

# Create tables for patient analytics
cqlsh cassandra-node1 -e "
USE patient_analytics;

-- Table for storing patient risk analytics by region
CREATE TABLE IF NOT EXISTS risk_scores (
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
CREATE TABLE IF NOT EXISTS regional_stats (
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
CREATE TABLE IF NOT EXISTS vital_trends (
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

-- Create secondary indexes
CREATE INDEX IF NOT EXISTS ON risk_scores (alert_level);
CREATE INDEX IF NOT EXISTS ON risk_scores (risk_score);
"

# Insert sample data
echo "Inserting sample data..."

# Insert risk scores for different regions and patients
cqlsh cassandra-node1 -e "
USE patient_analytics;

-- Northeast region - Patient P001
INSERT INTO risk_scores (region, patient_id, timestamp, risk_score, risk_factors, alert_level, data_sources)
VALUES ('Northeast', 'P001', '2023-05-19 10:00:00', 0.65, {'diabetes': 0.4, 'hypertension': 0.25}, 'medium', {'vitals', 'medical_history'});

INSERT INTO risk_scores (region, patient_id, timestamp, risk_score, risk_factors, alert_level, data_sources)
VALUES ('Northeast', 'P001', '2023-05-19 11:00:00', 0.68, {'diabetes': 0.4, 'hypertension': 0.28}, 'medium', {'vitals', 'medical_history'});

-- Southeast region - Patient P002
INSERT INTO risk_scores (region, patient_id, timestamp, risk_score, risk_factors, alert_level, data_sources)
VALUES ('Southeast', 'P002', '2023-05-19 10:00:00', 0.35, {'asthma': 0.35}, 'low', {'vitals', 'medical_history'});

INSERT INTO risk_scores (region, patient_id, timestamp, risk_score, risk_factors, alert_level, data_sources)
VALUES ('Southeast', 'P002', '2023-05-19 11:00:00', 0.32, {'asthma': 0.32}, 'low', {'vitals', 'medical_history'});

-- Midwest region - Patient P003
INSERT INTO risk_scores (region, patient_id, timestamp, risk_score, risk_factors, alert_level, data_sources)
VALUES ('Midwest', 'P003', '2023-05-19 10:00:00', 0.78, {'coronary_artery_disease': 0.5, 'hyperlipidemia': 0.28}, 'high', {'vitals', 'medical_history'});

INSERT INTO risk_scores (region, patient_id, timestamp, risk_score, risk_factors, alert_level, data_sources)
VALUES ('Midwest', 'P003', '2023-05-19 11:00:00', 0.82, {'coronary_artery_disease': 0.52, 'hyperlipidemia': 0.3}, 'high', {'vitals', 'medical_history'});

-- West region - Patient P004
INSERT INTO risk_scores (region, patient_id, timestamp, risk_score, risk_factors, alert_level, data_sources)
VALUES ('West', 'P004', '2023-05-19 10:00:00', 0.25, {'migraine': 0.25}, 'low', {'vitals', 'medical_history'});

INSERT INTO risk_scores (region, patient_id, timestamp, risk_score, risk_factors, alert_level, data_sources)
VALUES ('West', 'P004', '2023-05-19 11:00:00', 0.28, {'migraine': 0.28}, 'low', {'vitals', 'medical_history'});

-- Insert regional statistics
INSERT INTO regional_stats (region, date, hour, avg_risk_score, high_risk_count, medium_risk_count, low_risk_count)
VALUES ('Northeast', '2023-05-19', 10, 0.65, 0, 1, 0);

INSERT INTO regional_stats (region, date, hour, avg_risk_score, high_risk_count, medium_risk_count, low_risk_count)
VALUES ('Southeast', '2023-05-19', 10, 0.35, 0, 0, 1);

INSERT INTO regional_stats (region, date, hour, avg_risk_score, high_risk_count, medium_risk_count, low_risk_count)
VALUES ('Midwest', '2023-05-19', 10, 0.78, 1, 0, 0);

INSERT INTO regional_stats (region, date, hour, avg_risk_score, high_risk_count, medium_risk_count, low_risk_count)
VALUES ('West', '2023-05-19', 10, 0.25, 0, 0, 1);

-- Insert vital trends
INSERT INTO vital_trends (patient_id, vital_type, date, hour, min_value, max_value, avg_value, std_deviation, sample_count)
VALUES ('P001', 'heartbeat', '2023-05-19', 10, 78, 82, 80, 1.63, 3);

INSERT INTO vital_trends (patient_id, vital_type, date, hour, min_value, max_value, avg_value, std_deviation, sample_count)
VALUES ('P002', 'heartbeat', '2023-05-19', 10, 74, 76, 75, 0.82, 3);

INSERT INTO vital_trends (patient_id, vital_type, date, hour, min_value, max_value, avg_value, std_deviation, sample_count)
VALUES ('P003', 'heartbeat', '2023-05-19', 10, 84, 86, 85, 0.82, 3);

INSERT INTO vital_trends (patient_id, vital_type, date, hour, min_value, max_value, avg_value, std_deviation, sample_count)
VALUES ('P004', 'heartbeat', '2023-05-19', 10, 71, 73, 72, 0.82, 3);
"

# Verify data was inserted
echo "Verifying data insertion..."
cqlsh cassandra-node1 -e "
USE patient_analytics;
SELECT COUNT(*) FROM risk_scores;
SELECT COUNT(*) FROM regional_stats;
SELECT COUNT(*) FROM vital_trends;
"

echo "Cassandra setup completed!"
