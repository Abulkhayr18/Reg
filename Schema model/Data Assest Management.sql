-- Master data inventory
CREATE TABLE data_assets (
    asset_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_name VARCHAR(200) NOT NULL,
    asset_type VARCHAR(50) NOT NULL, -- 'DATABASE', 'FILE', 'API', 'STREAM'
    business_owner VARCHAR(100),
    technical_owner VARCHAR(100),
    
    -- Data classification
    data_sensitivity VARCHAR(20) NOT NULL, -- 'PUBLIC', 'INTERNAL', 'CONFIDENTIAL', 'RESTRICTED'
    contains_pii BOOLEAN DEFAULT FALSE,
    contains_financial_data BOOLEAN DEFAULT FALSE,
    contains_health_data BOOLEAN DEFAULT FALSE,
    
    -- Geographic scope
    data_locations TEXT[], -- Countries where data is stored/processed
    
    -- Audit columns
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE
);

-- Detailed data elements within assets
CREATE TABLE data_elements (
    element_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES data_assets(asset_id),
    element_name VARCHAR(200) NOT NULL,
    data_type VARCHAR(50) NOT NULL,
    is_primary_key BOOLEAN DEFAULT FALSE,
    is_encrypted BOOLEAN DEFAULT FALSE,
    encryption_method VARCHAR(50),
    
    -- Privacy classification
    pii_category VARCHAR(50), -- 'NAME', 'EMAIL', 'SSN', 'PHONE', etc.
    retention_period_days INTEGER,
    
    -- SCD Type 2
    version_start_date DATE NOT NULL,
    version_end_date DATE DEFAULT '9999-12-31',
    is_current_version BOOLEAN DEFAULT TRUE,
    
    -- Audit columns
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL
);