
--Core Schema Design
--Regulatory Framework Management

-- Master table for regulatory frameworks
CREATE TABLE regulatory_frameworks (
    framework_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    framework_name VARCHAR(100) NOT NULL, -- 'GDPR', 'CCPA', 'SOX', etc.
    jurisdiction VARCHAR(50) NOT NULL,     -- 'EU', 'California', 'US'
    framework_version VARCHAR(20) NOT NULL,
    effective_date DATE NOT NULL,
    expiry_date DATE,
    framework_description TEXT,
    
    -- Audit columns
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE
);

-- Compliance requirements within each framework
CREATE TABLE compliance_requirements (
    requirement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    framework_id UUID REFERENCES regulatory_frameworks(framework_id),
    requirement_code VARCHAR(50) NOT NULL, -- 'GDPR-Art-6', 'CCPA-1798.100'
    requirement_name VARCHAR(200) NOT NULL,
    requirement_description TEXT,
    severity_level VARCHAR(20) NOT NULL, -- 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'
    data_categories TEXT[], -- Array of data types this applies to
    
    -- SCD Type 2 columns
    version_start_date DATE NOT NULL,
    version_end_date DATE DEFAULT '9999-12-31',
    is_current_version BOOLEAN DEFAULT TRUE,
    
    -- Audit columns
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50)
);