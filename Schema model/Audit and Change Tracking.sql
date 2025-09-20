-- audit log for all compliance-related changes
CREATE TABLE compliance_audit_log (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    operation_type VARCHAR(10) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    
    -- Change details
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    
    -- Context
    change_reason TEXT,
    business_justification TEXT,
    
    -- Audit trail
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50) NOT NULL,
    source_system VARCHAR(50),
    session_id VARCHAR(100)
);

-- Compliance events and incidents
CREATE TABLE compliance_events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL, -- 'BREACH', 'AUDIT', 'REMEDIATION', 'POLICY_CHANGE'
    event_date TIMESTAMP NOT NULL,
    severity VARCHAR(20) NOT NULL,
    
    -- Event details
    event_description TEXT NOT NULL,
    affected_assets UUID[],
    affected_requirements UUID[],
    
    -- Response tracking
    response_required BOOLEAN DEFAULT TRUE,
    response_deadline TIMESTAMP,
    response_status VARCHAR(20) DEFAULT 'PENDING',
    resolution_notes TEXT,
    
    -- Regulatory reporting
    requires_breach_notification BOOLEAN DEFAULT FALSE,
    notification_deadline TIMESTAMP,
    notification_status VARCHAR(20),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL
);