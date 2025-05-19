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
- : Documentation files
  - : Justification for database choices
  - : Comprehensive data models for all databases
  - : System architecture overview
- : Setup and demonstration scripts
  - : MongoDB initialization script
  - : InfluxDB initialization script
  - : Neo4j initialization script
  - : Cassandra initialization script
  - : Redis initialization script
  - : Comprehensive demonstration script
- : Docker Compose configuration for all databases

## Setup Instructions
1. Ensure Docker and Docker Compose are installed
2. Run `docker-compose -f docker-compose-enhanced.yml up -d`
3. Execute setup scripts in the following order:
   - `./scripts/mongodb_setup.sh`
   - `./scripts/influxdb_setup.sh`
   - `./scripts/neo4j_setup.sh`
   - `./scripts/cassandra_setup.sh`
   - `./scripts/redis_setup.sh`
4. Run the demonstration script: `./scripts/demo.sh`

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
