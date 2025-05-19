#!/bin/bash
# MongoDB replica set initialization script

# Wait for MongoDB instances to be ready
echo "Waiting for MongoDB instances to start..."
sleep 30

# Connect to the primary and initiate the replica set
echo "Configuring MongoDB replica set..."
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin <<EOF
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongodb-primary:27017", priority: 2 },
    { _id: 1, host: "mongodb-secondary-1:27017", priority: 1 },
    { _id: 2, host: "mongodb-secondary-2:27017", priority: 1 }
  ]
});
EOF

# Wait for replica set to initialize
echo "Waiting for replica set initialization..."
sleep 20

# Check replica set status
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin --eval "rs.status()"

# Create database and collections with sharding by region
echo "Creating database and collections..."
mongo --host mongodb-primary:27017 -u admin -p password --authenticationDatabase admin <<EOF
use healthcare;

// Create admin user for the healthcare database
db.createUser({
  user: "healthcare_admin",
  pwd: "healthcare_password",
  roles: [{ role: "readWrite", db: "healthcare" }]
});

// Create patients collection with schema validation
db.createCollection("patients", {
  validator: {
    \$jsonSchema: {
      bsonType: "object",
      required: ["patient_id", "region", "personal_info"],
      properties: {
        patient_id: { bsonType: "string" },
        region: { bsonType: "string" },
        personal_info: { bsonType: "object" },
        medical_history: { bsonType: "array" },
        allergies: { bsonType: "array" },
        medications: { bsonType: "array" },
        insurance: { bsonType: "object" },
        created_at: { bsonType: "date" },
        updated_at: { bsonType: "date" }
      }
    }
  }
});

// Create indexes for efficient querying
db.patients.createIndex({ "region": 1, "patient_id": 1 }, { unique: true });
db.patients.createIndex({ "personal_info.name": 1 });
db.patients.createIndex({ "medical_history.condition": 1 });
db.patients.createIndex({ "region": 1, "medical_history.condition": 1 });

// Insert sample data for different regions
db.patients.insertMany([
  {
    patient_id: "P001",
    region: "Northeast",
    personal_info: {
      name: "John Doe",
      dob: new Date("1978-05-15"),
      gender: "Male",
      contact: {
        email: "john.doe@example.com",
        phone: "555-123-4567",
        address: {
          street: "123 Main St",
          city: "Boston",
          state: "MA",
          zip: "02108",
          country: "USA"
        }
      },
      emergency_contact: {
        name: "Jane Doe",
        relationship: "Spouse",
        phone: "555-987-6543"
      }
    },
    medical_history: [
      {
        condition: "Type 2 Diabetes",
        diagnosed_date: new Date("2015-03-10"),
        status: "Active",
        notes: "Managed with medication and diet"
      },
      {
        condition: "Hypertension",
        diagnosed_date: new Date("2018-07-22"),
        status: "Active",
        notes: "Controlled with medication"
      }
    ],
    allergies: [
      {
        allergen: "Penicillin",
        severity: "High",
        reaction: "Anaphylaxis"
      }
    ],
    medications: [
      {
        name: "Metformin",
        dosage: "500mg",
        frequency: "Twice daily",
        start_date: new Date("2015-03-15"),
        end_date: null
      },
      {
        name: "Lisinopril",
        dosage: "10mg",
        frequency: "Once daily",
        start_date: new Date("2018-08-01"),
        end_date: null
      }
    ],
    insurance: {
      provider: "HealthPlus",
      policy_number: "HP12345678",
      group_number: "G-9876",
      coverage_start: new Date("2023-01-01")
    },
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    patient_id: "P002",
    region: "Southeast",
    personal_info: {
      name: "Alice Smith",
      dob: new Date("1985-08-23"),
      gender: "Female",
      contact: {
        email: "alice.smith@example.com",
        phone: "555-234-5678",
        address: {
          street: "456 Oak Ave",
          city: "Miami",
          state: "FL",
          zip: "33101",
          country: "USA"
        }
      },
      emergency_contact: {
        name: "Bob Smith",
        relationship: "Husband",
        phone: "555-876-5432"
      }
    },
    medical_history: [
      {
        condition: "Asthma",
        diagnosed_date: new Date("2010-06-15"),
        status: "Active",
        notes: "Mild, triggered by allergens"
      }
    ],
    allergies: [
      {
        allergen: "Pollen",
        severity: "Medium",
        reaction: "Respiratory distress"
      },
      {
        allergen: "Shellfish",
        severity: "High",
        reaction: "Hives, swelling"
      }
    ],
    medications: [
      {
        name: "Albuterol",
        dosage: "90mcg",
        frequency: "As needed",
        start_date: new Date("2010-06-20"),
        end_date: null
      }
    ],
    insurance: {
      provider: "BlueCross",
      policy_number: "BC87654321",
      group_number: "G-5432",
      coverage_start: new Date("2022-01-01")
    },
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    patient_id: "P003",
    region: "Midwest",
    personal_info: {
      name: "Robert Johnson",
      dob: new Date("1965-12-10"),
      gender: "Male",
      contact: {
        email: "robert.johnson@example.com",
        phone: "555-345-6789",
        address: {
          street: "789 Elm St",
          city: "Chicago",
          state: "IL",
          zip: "60601",
          country: "USA"
        }
      },
      emergency_contact: {
        name: "Mary Johnson",
        relationship: "Daughter",
        phone: "555-765-4321"
      }
    },
    medical_history: [
      {
        condition: "Coronary Artery Disease",
        diagnosed_date: new Date("2012-09-05"),
        status: "Active",
        notes: "Stent placed in 2012"
      },
      {
        condition: "Hyperlipidemia",
        diagnosed_date: new Date("2012-09-05"),
        status: "Active",
        notes: "Managed with statins"
      }
    ],
    allergies: [],
    medications: [
      {
        name: "Atorvastatin",
        dosage: "40mg",
        frequency: "Once daily",
        start_date: new Date("2012-09-10"),
        end_date: null
      },
      {
        name: "Aspirin",
        dosage: "81mg",
        frequency: "Once daily",
        start_date: new Date("2012-09-10"),
        end_date: null
      }
    ],
    insurance: {
      provider: "Medicare",
      policy_number: "M123456789",
      group_number: null,
      coverage_start: new Date("2020-01-01")
    },
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    patient_id: "P004",
    region: "West",
    personal_info: {
      name: "Emily Chen",
      dob: new Date("1990-03-25"),
      gender: "Female",
      contact: {
        email: "emily.chen@example.com",
        phone: "555-456-7890",
        address: {
          street: "101 Pine St",
          city: "San Francisco",
          state: "CA",
          zip: "94101",
          country: "USA"
        }
      },
      emergency_contact: {
        name: "David Chen",
        relationship: "Brother",
        phone: "555-654-3210"
      }
    },
    medical_history: [
      {
        condition: "Migraine",
        diagnosed_date: new Date("2018-02-14"),
        status: "Active",
        notes: "Triggered by stress and lack of sleep"
      }
    ],
    allergies: [
      {
        allergen: "Latex",
        severity: "Medium",
        reaction: "Contact dermatitis"
      }
    ],
    medications: [
      {
        name: "Sumatriptan",
        dosage: "50mg",
        frequency: "As needed",
        start_date: new Date("2018-02-20"),
        end_date: null
      }
    ],
    insurance: {
      provider: "Kaiser",
      policy_number: "K98765432",
      group_number: "G-1234",
      coverage_start: new Date("2021-06-01")
    },
    created_at: new Date(),
    updated_at: new Date()
  }
]);

// Verify data was inserted
db.patients.find().count();
EOF

echo "MongoDB setup completed!"
