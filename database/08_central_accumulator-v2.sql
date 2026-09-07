-- =========================================================================
-- DATABASE SCHEMA: Unified Syndicate Ledger Accumulator & Document Archive
-- DBMS Target: PostgreSQL (Version 12+)
-- Description: Establishes a centralized financial transaction warehouse and 
--              immutable document repository across all 7 syndicate models.
--              Enables absolute historical reporting "per engineer" at the
--              finest grain of detail (Gross, Net, Stage 1-5 Deductions, Funds).
-- =========================================================================

BEGIN;

-- =========================================================================
-- 1. CENTRAL IMMUTABLE DOCUMENT STORAGE (Autosaved Issued PDFs)
-- =========================================================================

CREATE TYPE document_type_enum AS ENUM (
    'INV', -- Client Invoice (فاتورة العميل)
    'EPO', -- Engineer Payout Order (أمر صرف مستحقات المهندسين)
    'FSD'  -- Financial Syndicate Deposit Notice (إشعار الإيداع النقابي المالي)
);

CREATE TABLE IF NOT EXISTS central_document_archive (
    archive_id BIGSERIAL PRIMARY KEY,
    document_code VARCHAR(100) UNIQUE NOT NULL,    -- e.g., 'QAM-SC-2026-0004-INV'
    project_id VARCHAR(50) NOT NULL,               -- Unified Project ID cross-model
    model_type VARCHAR(10) NOT NULL,               -- 'GS', 'SR', 'SS', 'MP', 'BS', 'SC', 'BS-RPT'
    branch_code syndicate_branch_code NOT NULL,    -- 'HAS', 'QAM', 'DER'
    doc_type document_type_enum NOT NULL,
    receipt_no VARCHAR(100) NOT NULL,              -- Settled cashier receipt linkage
    client_name VARCHAR(150) NOT NULL,
    
    -- File storage & Integrity parameters
    file_name VARCHAR(255) NOT NULL,               -- Saved filename on disk
    file_path VARCHAR(512) NOT NULL,               -- Permanent filesystem/S3 URI
    sha256_checksum CHAR(64) UNIQUE NOT NULL,      -- Absolute cryptographic proof against tampering
    
    -- Structured Context JSON (Detailed snapshot of variables used to build the PDF)
    full_document_payload JSONB NOT NULL,
    
    issued_by VARCHAR(50) NOT NULL,                -- User/Accountant ID who issued it
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_doc_archive_project ON central_document_archive (project_id);
CREATE INDEX idx_doc_archive_model ON central_document_archive (model_type);
CREATE INDEX idx_doc_archive_branch ON central_document_archive (branch_code);
CREATE INDEX idx_doc_archive_checksum ON central_document_archive (sha256_checksum);

COMMENT ON TABLE central_document_archive IS 'Unified physical storage index for all legally issued PDF documents stamped with cryptographic verification hashes.';

-- =========================================================================
-- 2. CENTRAL ENGINEER LEDGER ACCUMULATOR (Unified Earnings Warehouse)
-- =========================================================================

CREATE TABLE IF NOT EXISTS central_engineer_ledger_accumulator (
    ledger_id BIGSERIAL PRIMARY KEY,
    engineer_id VARCHAR(50) NOT NULL REFERENCES engineers_registry(engineer_id),
    engineer_name VARCHAR(150) NOT NULL,
    discipline_code discipline_code NOT NULL,
    office_branch syndicate_branch_code NOT NULL,
    fund_status fund_subscription_status NOT NULL, -- 'IN' (25%) or 'OU' (10%)
    
    -- Transaction contextual identifiers
    project_id VARCHAR(50) NOT NULL,
    receipt_no VARCHAR(100) NOT NULL,
    model_type VARCHAR(10) NOT NULL,               -- 'GS', 'SR', 'SS', 'MP', 'BS', 'SC', 'BS-RPT'
    role_at_settlement VARCHAR(100) NOT NULL,      -- Role within the specific project
    settled_by VARCHAR(50) NOT NULL,               -- accountant who settled the transaction
    
    -- Financial breakdown (Stored in native USD and converted SYP for multi-currency compatibility)
    active_usd_rate NUMERIC(12, 2) NOT NULL CHECK (active_usd_rate > 0.0),
    
    -- Absolute details level (Accumulated ledger)
    gross_share_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    gross_share_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    
    stage_1_unit_fee_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,  -- Administrative retention
    stage_1_unit_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    
    stage_2_audit_pool_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00, -- Auditing pool (if model active)
    stage_2_audit_pool_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    
    stage_3_joint_fund_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00, -- 25% or 10% subscription
    stage_3_joint_fund_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    
    stage_4_coaching_hold_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00, -- Trainee coaching deduction
    stage_4_coaching_hold_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    
    stage_5_printing_pool_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00, -- Layout/plotting surcharge
    stage_5_printing_pool_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    
    net_payout_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,          -- Pocket cash disbursed
    net_payout_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    
    -- Dynamic balance destination funds
    joint_fund_destination combined_fund_type NOT NULL,
    audit_fund_destination combined_fund_type, -- NULL if model has no audit pool
    
    settled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_accumulator_engineer ON central_engineer_ledger_accumulator (engineer_id);
CREATE INDEX idx_accumulator_model ON central_engineer_ledger_accumulator (model_type);
CREATE INDEX idx_accumulator_settled_at ON central_engineer_ledger_accumulator (settled_at);
CREATE INDEX idx_accumulator_receipt ON central_engineer_ledger_accumulator (receipt_no);

COMMENT ON TABLE central_engineer_ledger_accumulator IS 'The ultimate core transaction warehouse. Every settled model flows detailed financial logs here for unified regional audits.';

-- =========================================================================
-- 3. INTER-MODEL REAL-TIME REALIGNMENT TRIGGERS (Auto-Populating Warehouse)
-- =========================================================================

-- A. Model 1 (GS) Real-Time Ledger Accumulator Sync Trigger
CREATE OR REPLACE FUNCTION fn_sync_model_1_to_accumulator()
RETURNS TRIGGER AS $$
DECLARE
    v_rate NUMERIC(12, 2);
    v_by VARCHAR(50);
BEGIN
    SELECT active_usd_rate, settled_by INTO v_rate, v_by 
    FROM model_1_projects WHERE project_id = NEW.project_id;
    
    INSERT INTO central_engineer_ledger_accumulator (
        engineer_id, engineer_name, discipline_code, office_branch, fund_status,
        project_id, receipt_no, model_type, role_at_settlement, settled_by, active_usd_rate,
        
        gross_share_usd, gross_share_syp,
        stage_1_unit_fee_usd, stage_1_unit_fee_syp,
        stage_2_audit_pool_usd, stage_2_audit_pool_syp,
        stage_3_joint_fund_usd, stage_3_joint_fund_syp,
        stage_4_coaching_hold_usd, stage_4_coaching_hold_syp,
        stage_5_printing_pool_usd, stage_5_printing_pool_syp,
        net_payout_usd, net_payout_syp,
        
        joint_fund_destination, audit_fund_destination, settled_at
    ) VALUES (
        NEW.engineer_id, NEW.engineer_name, NEW.discipline_code, NEW.branch, NEW.fund_status,
        NEW.project_id, NEW.receipt_no, 'GS', NEW.discipline_code::text, COALESCE(v_by, 'treasurer'), COALESCE(v_rate, 15000.00),
        
        -- SYP to USD calculations
        ROUND(NEW.gross_fee_syp / COALESCE(v_rate, 15000.00), 2), NEW.gross_fee_syp,
        ROUND(NEW.stage_1_unit_fee_syp / COALESCE(v_rate, 15000.00), 2), NEW.stage_1_unit_fee_syp,
        ROUND(NEW.stage_2_audit_pool_syp / COALESCE(v_rate, 15000.00), 2), NEW.stage_2_audit_pool_syp,
        ROUND(NEW.stage_3_fund_amount_syp / COALESCE(v_rate, 15000.00), 2), NEW.stage_3_fund_amount_syp,
        ROUND(NEW.stage_4_coaching_fee_syp / COALESCE(v_rate, 15000.00), 2), NEW.stage_4_coaching_fee_syp,
        ROUND(NEW.stage_5_printing_allowance_syp / COALESCE(v_rate, 15000.00), 2), NEW.stage_5_printing_allowance_syp,
        ROUND(NEW.net_payout_disbursed_syp / COALESCE(v_rate, 15000.00), 2), NEW.net_payout_disbursed_syp,
        
        NEW.joint_fund, NEW.audit_fund, NEW.created_at
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_ledger_m1 ON model_1_syndicate_contributions;
CREATE TRIGGER trg_sync_ledger_m1
AFTER INSERT ON model_1_syndicate_contributions
FOR EACH ROW EXECUTE FUNCTION fn_sync_model_1_to_accumulator();


-- B. Model 6 (SC) Real-Time Ledger Accumulator Sync Trigger
CREATE OR REPLACE FUNCTION fn_sync_model_6_to_accumulator()
RETURNS TRIGGER AS $$
DECLARE
    v_rate NUMERIC(12, 2);
    v_by VARCHAR(50);
BEGIN
    SELECT active_usd_rate, settled_by INTO v_rate, v_by 
    FROM model_6_projects WHERE project_id = NEW.project_id;
    
    INSERT INTO central_engineer_ledger_accumulator (
        engineer_id, engineer_name, discipline_code, office_branch, fund_status,
        project_id, receipt_no, model_type, role_at_settlement, settled_by, active_usd_rate,
        
        gross_share_usd, gross_share_syp,
        stage_1_unit_fee_usd, stage_1_unit_fee_syp,
        stage_2_audit_pool_usd, stage_2_audit_pool_syp,
        stage_3_joint_fund_usd, stage_3_joint_fund_syp,
        stage_4_coaching_hold_usd, stage_4_coaching_hold_syp,
        stage_5_printing_pool_usd, stage_5_printing_pool_syp,
        net_payout_usd, net_payout_syp,
        
        joint_fund_destination, audit_fund_destination, settled_at
    ) VALUES (
        NEW.engineer_id, NEW.engineer_name, NEW.discipline_code, NEW.branch, NEW.fund_status,
        NEW.project_id, NEW.receipt_no, 'SC', NEW.committee_role::text, COALESCE(v_by, 'treasurer'), COALESCE(v_rate, 15000.00),
        
        -- USD to SYP calculations
        NEW.gross_fee_usd, ROUND(NEW.gross_fee_usd * COALESCE(v_rate, 15000.00), 2),
        NEW.stage_1_unit_fee_usd, ROUND(NEW.stage_1_unit_fee_usd * COALESCE(v_rate, 15000.00), 2),
        0.00, 0.00, -- No auditing pool in Model 6
        NEW.stage_2_fund_amount_usd, ROUND(NEW.stage_2_fund_amount_usd * COALESCE(v_rate, 15000.00), 2),
        NEW.stage_3_coaching_fee_usd, ROUND(NEW.stage_3_coaching_fee_usd * COALESCE(v_rate, 15000.00), 2),
        0.00, 0.00, -- No printing pool in Model 6
        NEW.net_payout_disbursed_usd, ROUND(NEW.net_payout_disbursed_usd * COALESCE(v_rate, 15000.00), 2),
        
        NEW.joint_fund, NULL, NEW.created_at
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_ledger_m6 ON model_6_syndicate_contributions;
CREATE TRIGGER trg_sync_ledger_m6
AFTER INSERT ON model_6_syndicate_contributions
FOR EACH ROW EXECUTE FUNCTION fn_sync_model_6_to_accumulator();


-- =========================================================================
-- 4. THE ULTIMATE "REPORT PER ENGINEER" MASTER REPORTING ENGINE (SQL Views)
-- =========================================================================

-- View A: Engineer Lifetime Performance & Account Audit View
CREATE OR REPLACE VIEW view_engineer_lifetime_audit AS
SELECT 
    e.engineer_id,
    e.full_name AS engineer_name,
    e.discipline,
    e.office_branch,
    e.rank,
    e.fund_status,
    e.is_active,
    
    -- Lifetime Aggregates
    COUNT(DISTINCT c.project_id) AS total_settled_projects_count,
    COALESCE(SUM(c.gross_share_usd), 0.00) AS lifetime_gross_usd,
    COALESCE(SUM(c.net_payout_usd), 0.00) AS lifetime_net_disbursed_usd,
    COALESCE(SUM(c.net_payout_syp), 0.00) AS lifetime_net_disbursed_syp,
    
    -- Total Administrative Holdings Contribution
    COALESCE(SUM(c.stage_1_unit_fee_usd), 0.00) AS total_syndicate_unit_fees_usd,
    COALESCE(SUM(c.stage_2_audit_pool_usd), 0.00) AS total_audit_pool_contributions_usd,
    COALESCE(SUM(c.stage_3_joint_fund_usd), 0.00) AS total_joint_mutual_fund_contributions_usd,
    COALESCE(SUM(c.stage_4_coaching_hold_usd), 0.00) AS total_coaching_deductions_held_usd,
    
    -- High/Low Project Currency Trends
    ROUND(AVG(c.active_usd_rate), 2) AS average_exchange_rate_applied
FROM engineers_registry e
LEFT JOIN central_engineer_ledger_accumulator c ON e.engineer_id = c.engineer_id
GROUP BY e.engineer_id, e.full_name, e.discipline, e.office_branch, e.rank, e.fund_status, e.is_active;

COMMENT ON VIEW view_engineer_lifetime_audit IS 'Provides a comprehensive summary of an engineer''s historical activity, earnings, and financial contributions across all systems.';


-- View B: Detailed Itemized Project Ledger per Engineer
CREATE OR REPLACE VIEW view_engineer_project_ledger_detail AS
SELECT 
    c.engineer_id,
    c.engineer_name,
    c.project_id,
    c.receipt_no,
    c.model_type,
    c.role_at_settlement,
    c.settled_by AS accountant_username,
    c.active_usd_rate AS conversion_rate,
    
    -- Currencies split
    c.gross_share_usd,
    c.net_payout_usd,
    c.stage_1_unit_fee_usd AS unit_fee_deducted_usd,
    c.stage_3_joint_fund_usd AS joint_fund_deducted_usd,
    c.stage_4_coaching_hold_usd AS coaching_fee_deducted_usd,
    
    -- Destination Funds Details
    c.joint_fund_destination,
    COALESCE(c.audit_fund_destination::text, 'N/A (No Audit)') AS audit_fund_destination,
    
    c.settled_at
FROM central_engineer_ledger_accumulator c
ORDER BY c.settled_at DESC;

COMMENT ON VIEW view_engineer_project_ledger_detail IS 'Chronological audit trail showing every project payout and deduction details for any chosen engineer.';

COMMIT;
-- =========================================================================
-- END OF ACCUMULATOR & ARCHIVE SCHEMAS
-- =========================================================================
