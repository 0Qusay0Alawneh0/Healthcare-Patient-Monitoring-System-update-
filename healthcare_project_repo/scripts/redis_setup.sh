#!/bin/bash
# Redis setup script

# Wait for Redis instances to be ready
echo "Waiting for Redis instances to start..."
sleep 20

# Create Redis configuration files
echo "Creating Redis configuration files..."

# Master configuration
mkdir -p /home/ubuntu/healthcare_project/redis
cat > /home/ubuntu/healthcare_project/redis/redis-master.conf << EOF
port 6379
bind 0.0.0.0
dir /data
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
EOF

# Replica 1 configuration
cat > /home/ubuntu/healthcare_project/redis/redis-replica1.conf << EOF
port 6379
bind 0.0.0.0
dir /data
replicaof redis-master 6379
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
EOF

# Replica 2 configuration
cat > /home/ubuntu/healthcare_project/redis/redis-replica2.conf << EOF
port 6379
bind 0.0.0.0
dir /data
replicaof redis-master 6379
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
EOF

# Sentinel 1 configuration
cat > /home/ubuntu/healthcare_project/redis/sentinel1.conf << EOF
port 26379
sentinel monitor mymaster redis-master 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
EOF

# Sentinel 2 configuration
cat > /home/ubuntu/healthcare_project/redis/sentinel2.conf << EOF
port 26379
sentinel monitor mymaster redis-master 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
EOF

# Sentinel 3 configuration
cat > /home/ubuntu/healthcare_project/redis/sentinel3.conf << EOF
port 26379
sentinel monitor mymaster redis-master 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
EOF

echo "Redis configuration files created."

# Insert sample data using redis-cli
echo "Inserting sample data into Redis..."

# Function to insert data for a region
insert_region_data() {
  local region=$1
  
  # Patient alerts for the region
  redis-cli -h redis-master -p 6379 LPUSH "patient:alerts:$region:P001" "Abnormal heartbeat detected at 10:01AM"
  redis-cli -h redis-master -p 6379 LPUSH "patient:alerts:$region:P001" "Elevated blood pressure at 11:30AM"
  redis-cli -h redis-master -p 6379 SET "patient:alerts:count:$region:P001" 2
  redis-cli -h redis-master -p 6379 HMSET "patient:alerts:latest:$region:P001" "id" "A12345" "patient_id" "P001" "timestamp" "2023-05-19T11:30:00Z" "type" "high_blood_pressure" "value" 135 "threshold" 130 "priority" 2 "status" "pending" "message" "Elevated blood pressure detected"
  
  # Alert notification sets
  redis-cli -h redis-master -p 6379 ZADD "alerts:pending:$region" 2 "P001"
  
  # Cache keys
  redis-cli -h redis-master -p 6379 HMSET "cache:patient:P001" "id" "P001" "name" "John Doe" "age" 45 "primary_doctor" "D001" "risk_level" "medium" "region" "$region"
  redis-cli -h redis-master -p 6379 HMSET "cache:vitals:latest:P001" "heartbeat" 82 "blood_pressure_systolic" 135 "blood_pressure_diastolic" 85 "temperature" 98.7 "oxygen_saturation" 97 "respiratory_rate" 17
  redis-cli -h redis-master -p 6379 HMSET "cache:risk:P001" "score" 0.68 "level" "medium" "factors" "diabetes,hypertension" "last_updated" "2023-05-19T11:00:00Z"
  
  # Set expiration for cached data
  redis-cli -h redis-master -p 6379 EXPIRE "cache:patient:P001" 3600
  redis-cli -h redis-master -p 6379 EXPIRE "cache:vitals:latest:P001" 300
  redis-cli -h redis-master -p 6379 EXPIRE "cache:risk:P001" 600
}

# Insert data for each region
insert_region_data "Northeast"
insert_region_data "Southeast"
insert_region_data "Midwest"
insert_region_data "West"

# Verify data was inserted
echo "Verifying data insertion..."
redis-cli -h redis-master -p 6379 KEYS "*"
redis-cli -h redis-master -p 6379 LLEN "patient:alerts:Northeast:P001"
redis-cli -h redis-master -p 6379 HGETALL "cache:patient:P001"

echo "Redis setup completed!"
