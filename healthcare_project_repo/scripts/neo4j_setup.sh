#!/bin/bash
# Neo4j setup script

# Wait for Neo4j instances to be ready
echo "Waiting for Neo4j instances to start..."
sleep 60

# Connect to the primary Neo4j instance and create constraints and indexes
echo "Configuring Neo4j..."
cypher-shell -a neo4j-core1:7687 -u neo4j -p password <<EOF
// Create constraints for uniqueness
CREATE CONSTRAINT patient_id_constraint IF NOT EXISTS ON (p:Patient) ASSERT p.id IS UNIQUE;
CREATE CONSTRAINT doctor_id_constraint IF NOT EXISTS ON (d:Doctor) ASSERT d.id IS UNIQUE;
CREATE CONSTRAINT hospital_id_constraint IF NOT EXISTS ON (h:Hospital) ASSERT h.id IS UNIQUE;
CREATE CONSTRAINT treatment_id_constraint IF NOT EXISTS ON (t:Treatment) ASSERT t.id IS UNIQUE;

// Create indexes for efficient lookup
CREATE INDEX patient_region_idx IF NOT EXISTS FOR (p:Patient) ON (p.region, p.id);
CREATE INDEX doctor_region_idx IF NOT EXISTS FOR (d:Doctor) ON (d.region, d.specialization);
CREATE INDEX hospital_region_idx IF NOT EXISTS FOR (h:Hospital) ON (h.region, h.type);

// Clear existing data (for idempotent setup)
MATCH (n) DETACH DELETE n;

// Create Patient nodes for different regions
// Northeast region
CREATE (p1:Patient {id: 'P001', name: 'John Doe', region: 'Northeast', risk_level: 'Medium'});

// Southeast region
CREATE (p2:Patient {id: 'P002', name: 'Alice Smith', region: 'Southeast', risk_level: 'Low'});

// Midwest region
CREATE (p3:Patient {id: 'P003', name: 'Robert Johnson', region: 'Midwest', risk_level: 'High'});

// West region
CREATE (p4:Patient {id: 'P004', name: 'Emily Chen', region: 'West', risk_level: 'Low'});

// Create Doctor nodes
CREATE (d1:Doctor {id: 'D001', name: 'Dr. Sarah Smith', specialization: 'Cardiology', hospital: 'Memorial Hospital', region: 'Northeast'});
CREATE (d2:Doctor {id: 'D002', name: 'Dr. Michael Brown', specialization: 'Endocrinology', hospital: 'City Medical Center', region: 'Southeast'});
CREATE (d3:Doctor {id: 'D003', name: 'Dr. James Wilson', specialization: 'Neurology', hospital: 'Midwest General', region: 'Midwest'});
CREATE (d4:Doctor {id: 'D004', name: 'Dr. Lisa Wong', specialization: 'Pulmonology', hospital: 'Pacific Medical', region: 'West'});
CREATE (d5:Doctor {id: 'D005', name: 'Dr. David Miller', specialization: 'Cardiology', hospital: 'Northeast Heart Center', region: 'Northeast'});

// Create Hospital nodes
CREATE (h1:Hospital {id: 'H001', name: 'Memorial Hospital', region: 'Northeast', type: 'General'});
CREATE (h2:Hospital {id: 'H002', name: 'City Medical Center', region: 'Southeast', type: 'General'});
CREATE (h3:Hospital {id: 'H003', name: 'Midwest General', region: 'Midwest', type: 'General'});
CREATE (h4:Hospital {id: 'H004', name: 'Pacific Medical', region: 'West', type: 'General'});
CREATE (h5:Hospital {id: 'H005', name: 'Northeast Heart Center', region: 'Northeast', type: 'Specialty'});

// Create Treatment nodes
CREATE (t1:Treatment {id: 'T001', name: 'Cardiac Evaluation', date: '2023-05-10', outcome: 'Stable'});
CREATE (t2:Treatment {id: 'T002', name: 'Diabetes Management', date: '2023-04-15', outcome: 'Improved'});
CREATE (t3:Treatment {id: 'T003', name: 'Neurological Assessment', date: '2023-05-05', outcome: 'Stable'});
CREATE (t4:Treatment {id: 'T004', name: 'Respiratory Therapy', date: '2023-05-12', outcome: 'Improved'});
CREATE (t5:Treatment {id: 'T005', name: 'Cardiac Surgery', date: '2023-03-20', outcome: 'Recovered'});

// Create relationships
// Doctor-Patient relationships
CREATE (p1)-[:TREATED_BY {since: '2022-01-15', primary: true}]->(d1);
CREATE (p1)-[:TREATED_BY {since: '2023-02-10', primary: false}]->(d5);
CREATE (p2)-[:TREATED_BY {since: '2022-03-20', primary: true}]->(d2);
CREATE (p3)-[:TREATED_BY {since: '2021-11-05', primary: true}]->(d3);
CREATE (p4)-[:TREATED_BY {since: '2022-07-12', primary: true}]->(d4);

// Doctor-Hospital affiliations
CREATE (d1)-[:AFFILIATED_WITH {since: '2018-03-01', position: 'Senior Cardiologist'}]->(h1);
CREATE (d2)-[:AFFILIATED_WITH {since: '2019-05-15', position: 'Endocrinologist'}]->(h2);
CREATE (d3)-[:AFFILIATED_WITH {since: '2017-09-10', position: 'Neurologist'}]->(h3);
CREATE (d4)-[:AFFILIATED_WITH {since: '2020-01-20', position: 'Pulmonologist'}]->(h4);
CREATE (d5)-[:AFFILIATED_WITH {since: '2015-06-01', position: 'Chief of Cardiology'}]->(h5);

// Patient-Treatment relationships
CREATE (p1)-[:RECEIVED {date: '2023-05-10'}]->(t1);
CREATE (p1)-[:RECEIVED {date: '2023-03-20'}]->(t5);
CREATE (p2)-[:RECEIVED {date: '2023-04-15'}]->(t2);
CREATE (p3)-[:RECEIVED {date: '2023-05-05'}]->(t3);
CREATE (p4)-[:RECEIVED {date: '2023-05-12'}]->(t4);

// Doctor-Treatment relationships
CREATE (d1)-[:PERFORMED {date: '2023-05-10'}]->(t1);
CREATE (d5)-[:PERFORMED {date: '2023-03-20'}]->(t5);
CREATE (d2)-[:PERFORMED {date: '2023-04-15'}]->(t2);
CREATE (d3)-[:PERFORMED {date: '2023-05-05'}]->(t3);
CREATE (d4)-[:PERFORMED {date: '2023-05-12'}]->(t4);

// Verify data was inserted
MATCH (n) RETURN labels(n) AS NodeType, count(*) AS Count;
MATCH ()-[r]->() RETURN type(r) AS RelationshipType, count(*) AS Count;
EOF

echo "Neo4j setup completed!"
