CREATE (p:Patient {id: 'P001', name: 'John'})
CREATE (d:Doctor {id: 'D001', name: 'Dr. Smith'})
CREATE (p)-[:TREATED_BY]->(d)