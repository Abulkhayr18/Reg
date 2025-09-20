-- =====================================================
-- COMPLIANCE REPORTING VIEWS AND QUERIES
-- =====================================================

-- 1. COMPLIANCE DASHBOARD 
-- =====================================================

CREATE VIEW compliance_dashboard AS
WITH latest_assessments AS (
    SELECT 
        ca.asset_id,
        ca.requirement_id,
        ca.compliance_score,
        ca.compliance_status,
        ca.risk_level,
        ca.assessment_date,
        ROW_NUMBER() OVER (
            PARTITION BY ca.asset_id, ca.requirement_id 
            ORDER BY ca.assessment_date DESC
        ) as rn
    FROM compliance_assessments ca
),
current_compliance AS (
    SELECT 
        da.asset_name,
        rf.framework_name,
        rf.jurisdiction,
        cr.requirement_code,
        cr.requirement_name,
        cr.severity_level,
        la.compliance_score,
        la.compliance_status,
        la.risk_level,
        la.assessment_date
    FROM latest_assessments la
    JOIN data_assets da ON la.asset_id = da.asset_id
    JOIN compliance_requirements cr ON la.requirement_id = cr.requirement_id
    JOIN regulatory_frameworks rf ON cr.framework_id = rf.framework_id
    WHERE la.rn = 1 AND da.is_active = TRUE
)
SELECT 
    framework_name,
    jurisdiction,
    COUNT(*) as total_requirements,
    COUNT(CASE WHEN compliance_status = 'COMPLIANT' THEN 1 END) as compliant_count,
    COUNT(CASE WHEN compliance_status = 'PARTIALLY_COMPLIANT' THEN 1 END) as partial_count,
    COUNT(CASE WHEN compliance_status = 'NON_COMPLIANT' THEN 1 END) as non_compliant_count,
    ROUND(AVG(compliance_score), 2) as avg_compliance_score,
    COUNT(CASE WHEN risk_level = 'CRITICAL' THEN 1 END) as critical_risks,
    COUNT(CASE WHEN risk_level = 'HIGH' THEN 1 END) as high_risks
FROM current_compliance
GROUP BY framework_name, jurisdiction
ORDER BY avg_compliance_score DESC;

-- 2. ASSET RISK ASSESSMENT - Identify High-Risk Data Assets
-- =====================================================

CREATE VIEW high_risk_assets AS
WITH asset_risk_summary AS (
    SELECT 
        da.asset_id,
        da.asset_name,
        da.asset_type,
        da.data_sensitivity,
        da.contains_pii,
        da.contains_financial_data,
        da.contains_health_data,
        COUNT(ca.assessment_id) as total_assessments,
        COUNT(CASE WHEN ca.compliance_status = 'NON_COMPLIANT' THEN 1 END) as non_compliant_count,
        COUNT(CASE WHEN ca.risk_level IN ('CRITICAL', 'HIGH') THEN 1 END) as high_risk_count,
        ROUND(AVG(ca.compliance_score), 2) as avg_compliance_score,
        MAX(ca.assessment_date) as last_assessment_date
    FROM data_assets da
    LEFT JOIN compliance_assessments ca ON da.asset_id = ca.asset_id
    WHERE da.is_active = TRUE
    GROUP BY da.asset_id, da.asset_name, da.asset_type, da.data_sensitivity,
             da.contains_pii, da.contains_financial_data, da.contains_health_data
),
risk_scoring AS (
    SELECT *,
        -- Risk scoring algorithm
        CASE 
            WHEN data_sensitivity = 'RESTRICTED' THEN 40
            WHEN data_sensitivity = 'CONFIDENTIAL' THEN 30
            WHEN data_sensitivity = 'INTERNAL' THEN 20
            ELSE 10
        END +
        CASE WHEN contains_pii THEN 20 ELSE 0 END +
        CASE WHEN contains_financial_data THEN 15 ELSE 0 END +
        CASE WHEN contains_health_data THEN 25 ELSE 0 END +
        (non_compliant_count * 10) +
        (high_risk_count * 5) +
        CASE WHEN avg_compliance_score < 50 THEN 20
             WHEN avg_compliance_score < 70 THEN 10
             ELSE 0
        END as calculated_risk_score
    FROM asset_risk_summary
)
SELECT 
    asset_name,
    asset_type,
    data_sensitivity,
    contains_pii,
    contains_financial_data,
    contains_health_data,
    total_assessments,
    non_compliant_count,
    high_risk_count,
    avg_compliance_score,
    last_assessment_date,
    calculated_risk_score,
    CASE 
        WHEN calculated_risk_score >= 80 THEN 'CRITICAL'
        WHEN calculated_risk_score >= 60 THEN 'HIGH'
        WHEN calculated_risk_score >= 40 THEN 'MEDIUM'
        ELSE 'LOW'
    END as overall_risk_level
FROM risk_scoring
ORDER BY calculated_risk_score DESC;

-- 3. COMPLIANCE TRENDS OVER TIME
-- =====================================================

CREATE VIEW compliance_trends AS
WITH monthly_compliance AS (
    SELECT 
        DATE_TRUNC('month', ca.assessment_date) as assessment_month,
        rf.framework_name,
        COUNT(*) as total_assessments,
        COUNT(CASE WHEN ca.compliance_status = 'COMPLIANT' THEN 1 END) as compliant_assessments,
        ROUND(AVG(ca.compliance_score), 2) as avg_score,
        COUNT(CASE WHEN ca.risk_level IN ('CRITICAL', 'HIGH') THEN 1 END) as high_risk_assessments
    FROM compliance_assessments ca
    JOIN compliance_requirements cr ON ca.requirement_id = cr.requirement_id
    JOIN regulatory_frameworks rf ON cr.requirement_name,