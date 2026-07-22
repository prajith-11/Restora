-- PostgreSQL / Standard Relational DDL Script
-- Project: Restora (Post-Surgical ACL Reconstruction Recovery Tracking)

-- 1. Patients Table
CREATE TABLE patients (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    surgery_type VARCHAR(50) NOT NULL DEFAULT 'ACL_RECONSTRUCTION',
    surgery_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Daily Check-Ins Table (The heart of the voice/text loop)
CREATE TABLE check_ins (
    id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    voice_recording_url VARCHAR(512), 
    transcript TEXT,                  
    pain_score INT CHECK (pain_score BETWEEN 1 AND 10), 
    medication_taken BOOLEAN NOT NULL DEFAULT FALSE, -- Added for adherence tracking
    sleep_rating INT CHECK (sleep_rating BETWEEN 1 AND 5), -- Added for recovery metrics (1-5 stars)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Pain Locations Table (Maps taps on the mobile human silhouette image)
CREATE TABLE pain_locations (
    id BIGSERIAL PRIMARY KEY,
    check_in_id BIGINT NOT NULL REFERENCES check_ins(id) ON DELETE CASCADE,
    zone_id VARCHAR(50) NOT NULL,     -- Predefined hitboxes (e.g., 'KNEE_LEFT', 'KNEE_RIGHT')
    severity_level VARCHAR(20)        -- Optional variation flags (e.g., 'MILD', 'THROBBING')
);

-- 4. Clinical Baseline Curves Table (Literature Benchmarks)
CREATE TABLE baseline_curves (
    id BIGSERIAL PRIMARY KEY,
    surgery_type VARCHAR(50) NOT NULL DEFAULT 'ACL_RECONSTRUCTION',
    days_since_surgery INT NOT NULL,  -- Timeline markers (e.g., Day 7, Day 14, Day 21)
    target_pain_score INT CHECK (target_pain_score BETWEEN 1 AND 10),
    target_flexion_degrees INT,       -- Target physical range of motion milestones
    UNIQUE(surgery_type, days_since_surgery)
);

-- 5. Trajectory Deviations Table (Flags consecutive stagnant data trends)
CREATE TABLE deviations (
    id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    deviation_type VARCHAR(50) NOT NULL, -- 'PAIN_STAGNATION' or 'MOBILITY_STAGNATION'
    description TEXT NOT NULL,         -- Structured appointment discussion prompts for the clinician
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Symptom lexicon: the vocabulary the rule-based NLP matcher searches for in transcripts
CREATE TABLE IF NOT EXISTS symptom_lexicon (
    id              SERIAL PRIMARY KEY,
    term            VARCHAR(100) NOT NULL,          -- canonical term, e.g. 'sharp_pain'
    category        VARCHAR(50)  NOT NULL,          -- e.g. 'pain_quality', 'trigger_context', 'mobility'
    synonyms        TEXT[]       NOT NULL,           -- raw words/phrases that map to this term
    severity_weight SMALLINT     DEFAULT 0,          -- optional: how strongly this term suggests a deviation
    created_at      TIMESTAMP DEFAULT NOW()
);

-- Optimization Indexes for Time-Series Trajectory Queries
CREATE INDEX idx_check_ins_patient_date ON check_ins(patient_id, created_at DESC);
CREATE INDEX idx_deviations_patient ON deviations(patient_id) WHERE resolved_at IS NULL;
CREATE INDEX idx_pain_locations_check_in ON pain_locations(check_in_id);
CREATE INDEX IF NOT EXISTS idx_symptom_lexicon_category ON symptom_lexicon(category);