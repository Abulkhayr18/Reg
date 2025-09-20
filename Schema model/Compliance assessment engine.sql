-- Assessment results per asset per requirement
CREATE TABLE compliance_assessments (
    assessment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID REFERENCES data_assets(asset_id),
    requirement_id UUID REFERENCES compliance_requirements(requirement_id),
    assessment_date DATE NOT NULL,
    assessment_period_start DATE NOT NULL,
    assessment_period_end DATE NOT NULL,
    
    -- Compliance scoring
    compliance_score DECIMAL(5,2) NOT NULL, -- 0.00 to 100.00
    compliance_status VARCHAR(20) NOT NULL, -- 'COMPLIANT', 'NON_COMPLIANT', 'PARTIALLY_COMPLIANT', 'NOT_APPLICABLE'
    
    -- Risk assessment
    risk_level VARCHAR(20) NOT NULL, -- 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'
    potential_impact_score DECIMAL(5,2),
    
    -- Assessment details
    assessment_method VARCHAR(50) NOT NULL, -- 'AUTOMATED', 'MANUAL', 'HYBRID'
    assessor_id VARCHAR(50) NOT NULL,
    findings TEXT,
    recommendations TEXT,
    
    -- Remediation tracking
    remediation_required BOOLEAN DEFAULT FALSE,
    remediation_deadline DATE,
    remediation_status VARCHAR(20), -- 'PENDING', 'IN_PROGRESS', 'COMPLETED', 'OVERDUE'
    
    -- Audit trail
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(50)
);

-- Detailed findings for each assessment
CREATE TABLE assessment_findings (
    finding_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID REFERENCES compliance_assessments(assessment_id),
    finding_type VARCHAR(50) NOT NULL, -- 'GAP', 'VIOLATION', 'IMPROVEMENT', 'OBSERVATION'
    finding_description TEXT NOT NULL,
    evidence_location TEXT,
    
    -- Impact assessment
    business_impact VARCHAR(20), -- 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'
    technical_impact VARCHAR(20),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL
);