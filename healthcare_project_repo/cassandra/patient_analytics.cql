CREATE TABLE patient_analytics (
    patient_id text,
    timestamp timestamp,
    risk_score float,
    PRIMARY KEY (patient_id, timestamp)
);