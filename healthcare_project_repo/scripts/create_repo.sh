#!/bin/bash
# Script to create a Git repository for the Healthcare DBMS Project

# Create a new directory for the Git repository
mkdir -p /home/ubuntu/healthcare_project_repo

# Copy all project files to the repository directory
cp -r /home/ubuntu/healthcare_project/* /home/ubuntu/healthcare_project_repo/

# Initialize Git repository
cd /home/ubuntu/healthcare_project_repo
git init

# Configure Git user
git config user.email "healthcare.project@example.com"
git config user.name "Healthcare Project Team"

# Add all files to the repository
git add .

# Commit the changes
git commit -m "Initial commit: Healthcare Patient Monitoring System with Polyglot Persistence"

# Create README.md file
cat > README.md << EOF
# Healthcare Patient Monitoring System

## Overview
This project implements a comprehensive healthcare patient monitoring system using a polyglot persistence approach with multiple database types:

- **MongoDB**: Document database for patient information
- **InfluxDB**: Time-series database for vital signs monitoring
- **Neo4j**: Graph database for doctor-patient relationships
- **Cassandra**: Column-family database for patient data analytics
- **Redis**: Key-value database for alerts and caching

## Features
- Regional partitioning of patient data
- High availability through replication
- Strong consistency for medical records
- Eventual consistency for real-time sensor data
- Fault tolerance with automated recovery
- Performance optimization through indexing and caching

## Directory Structure
- `/docs/`: Documentation files
  - `database_selection.md`: Justification for database choices
  - `data_models.md`: Comprehensive data models for all databases
  - `architecture.md`: System architecture overview
- `/scripts/`: Setup and demonstration scripts
  - `mongodb_setup.sh`: MongoDB initialization script
  - `influxdb_setup.sh`: InfluxDB initialization script
  - `neo4j_setup.sh`: Neo4j initialization script
  - `cassandra_setup.sh`: Cassandra initialization script
  - `redis_setup.sh`: Redis initialization script
  - `demo.sh`: Comprehensive demonstration script
- `/docker-compose-enhanced.yml`: Docker Compose configuration for all databases

## Setup Instructions
1. Ensure Docker and Docker Compose are installed
2. Run \`docker-compose -f docker-compose-enhanced.yml up -d\`
3. Execute setup scripts in the following order:
   - \`./scripts/mongodb_setup.sh\`
   - \`./scripts/influxdb_setup.sh\`
   - \`./scripts/neo4j_setup.sh\`
   - \`./scripts/cassandra_setup.sh\`
   - \`./scripts/redis_setup.sh\`
4. Run the demonstration script: \`./scripts/demo.sh\`

## Implementation Details
This project demonstrates:
1. Polyglot persistence with 5 different database types
2. Regional partitioning of patient data
3. Strong consistency for medical records
4. Eventual consistency for real-time data
5. High availability through replication
6. Fault tolerance with automated recovery
7. Performance optimization techniques

## Presentation
The 20-minute presentation covers:
- Use case analysis and database selection
- Implementation details and challenges
- Demonstration of key features
- Lessons learned and potential improvements
EOF

# Add README.md to the repository
git add README.md
git commit -m "Add README.md with project documentation"

# Create a presentation file
cat > presentation.md << EOF
# Healthcare Patient Monitoring System
## Polyglot Persistence Implementation

---

## Use Case Analysis
- **Patient Information**: Heterogeneous data requiring flexible schema
- **Vital Signs**: Time-stamped measurements requiring time-series optimization
- **Doctor-Patient Relationships**: Complex network of relationships
- **Analytics**: High-volume data processing with regional partitioning
- **Alerts**: Real-time notification system requiring high performance

---

## Database Selection
- **MongoDB**: Document DB for patient information
  - Schema flexibility for varied medical records
  - Strong consistency for critical data
- **InfluxDB**: Time-series DB for vital signs
  - Optimized for time-based data
  - Downsampling capabilities
- **Neo4j**: Graph DB for relationships
  - Natural representation of healthcare networks
  - Efficient traversal for complex queries
- **Cassandra**: Column-family DB for analytics
  - Linear scalability for analytics workloads
  - Tunable consistency levels
- **Redis**: Key-value DB for alerts
  - Sub-millisecond response times
  - Pub/sub capabilities for notifications

---

## Implementation Details

### Regional Partitioning
- Patients partitioned by geographic region
- MongoDB: Sharding by region
- Cassandra: Region as partition key
- Redis: Region-based key prefixing

### Consistency Models
- Strong consistency: MongoDB (patient records)
- Eventual consistency: InfluxDB, Cassandra (time-series, analytics)
- Mixed consistency: Redis (critical vs. non-critical alerts)

### Replication Strategy
- MongoDB: 3-node replica sets
- InfluxDB: 3-node clusters
- Neo4j: Causal clusters with core servers and read replicas
- Cassandra: Multi-datacenter deployment
- Redis: Master-replica with sentinel

---

## Demonstration Highlights

### CRUD Operations
- Patient record creation, retrieval, update, deletion
- Vital sign data insertion and querying
- Relationship management in the graph database

### Fault Tolerance
- MongoDB node failure and recovery
- Redis master failure and sentinel failover
- Cassandra node resilience

### Performance Optimization
- Indexing strategies for each database
- Caching with Redis
- Query optimization techniques

---

## Challenges and Solutions

### Challenge: Consistency vs. Availability Trade-offs
- **Solution**: Different consistency models for different data types
  - Strong consistency for medical records
  - Eventual consistency for sensor data

### Challenge: Cross-Database Integration
- **Solution**: Event-driven architecture with message passing

### Challenge: Regional Compliance
- **Solution**: Data partitioning by region with local-first access

---

## Lessons Learned
1. Polyglot persistence provides optimal performance for diverse data types
2. Careful consideration of consistency models is critical in healthcare
3. Automated failover mechanisms are essential for high availability
4. Performance optimization requires database-specific approaches

---

## Future Improvements
1. Implement cross-database transaction management
2. Add machine learning for predictive analytics
3. Enhance security with end-to-end encryption
4. Implement more sophisticated data lifecycle management
5. Add real-time dashboarding capabilities

---

## Questions?
EOF

# Add presentation.md to the repository
git add presentation.md
git commit -m "Add presentation slides"

# Create a zip file of the repository
cd /home/ubuntu
zip -r healthcare_project_repo.zip healthcare_project_repo

echo "Git repository created and zipped at /home/ubuntu/healthcare_project_repo.zip"
