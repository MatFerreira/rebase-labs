CREATE TABLE IF NOT EXISTS MedicalExams (
    cpf VARCHAR(14) NOT NULL,
    patient_name VARCHAR(255) NOT NULL,
    patient_email VARCHAR(255) NOT NULL,
    patient_birthdate DATE NOT NULL,
    patient_address VARCHAR(255) NOT NULL,
    patient_city VARCHAR(255) NOT NULL,
    patient_state VARCHAR(255) NOT NULL,
    doctor_crm VARCHAR(10) NOT NULL,
    doctor_crm_state VARCHAR(2) NOT NULL,
    doctor_name VARCHAR(255) NOT NULL,
    doctor_email VARCHAR(255) NOT NULL,
    exam_result_token VARCHAR(255) NOT NULL,
    exam_date DATE NOT NULL,
    exam_type VARCHAR(255) NOT NULL,
    exam_type_limits VARCHAR(255) NOT NULL,
    exam_type_result VARCHAR(255) NOT NULL
);
