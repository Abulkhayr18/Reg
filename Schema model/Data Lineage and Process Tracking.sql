-- Data processing activities (GDPR Article 30 records)
CREATE TABLE data_processing_activities (
    activity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_name VARCHAR(200) NOT NULL,
    processing_purpose TEXT NOT NULL,
    legal_basis VARCHAR(100) NOT NULL, -- GDPR lawful basis
    data_controller VARCHAR(200) NOT NULL,
    data_processor VARCHAR(200),
    
    -- Data subject categories
    data_subject_categories TEXT[], -- 'CUSTOMERS', 'EMPLOYEES', 'VENDORS'
    
    -- Processing details
    processing_methods TEXT[],
    automated_decision_making BOOLEAN DEFAULT FALSE,
    profiling BOOLEAN DEFAULT FALSE,
    
    -- International transfers
    third_country_transfers BOOLEAN DEFAULT FALSE,
    transfer_mechanisms TEXT[], -- 'ADEQUACY_DECISION', 'STANDARD_CONTRACTUAL_CLAUSES'
    
    -- Retention and deletion
    retention_criteria TEXT,
    deletion_procedures TEXT,
    
    -- Audit columns
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE
);

-- Link processing activities to data assets
CREATE TABLE activity_data_assets (
    activity_id UUID REFERENCES data_processing_activities(activity_id),
    asset_id UUID REFERENCES data_assets(asset_id),
    access_type VARCHAR(20) NOT NULL, -- 'READ', 'WRITE', 'DELETE', 'TRANSFORM'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL,
    
    PRIMARY KEY (activity_id, asset_id)
);