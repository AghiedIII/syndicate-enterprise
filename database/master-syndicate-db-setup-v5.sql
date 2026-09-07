-- =========================================================================
-- UNIFIED MASTER SETUP: Engineering Syndicate Accounting System
-- GENERATED FOR: Solved DBeaver Rabbit Hole & Manual Script Errors
-- INSTRUCTIONS: Copy this entire file, paste into a blank SQL console,
--               and press Alt+X (or Run as Script) ONCE.
-- =========================================================================

BEGIN;

-- Clean up views, tables, and functions to guarantee a 100% clean start
DROP VIEW IF EXISTS view_engineer_lifetime_audit CASCADE;
DROP VIEW IF EXISTS view_engineer_project_ledger_detail CASCADE;
DROP VIEW IF EXISTS view_model_1_balance_verification CASCADE;
DROP VIEW IF EXISTS view_model_2_balance_verification CASCADE;
DROP VIEW IF EXISTS view_model_3_balance_verification CASCADE;
DROP VIEW IF EXISTS view_model_4_balance_verification CASCADE;
DROP VIEW IF EXISTS view_model_5_balance_verification CASCADE;
DROP VIEW IF EXISTS view_model_6_balance_verification CASCADE;
DROP VIEW IF EXISTS view_bayani_reports_ledger_integrity CASCADE;
DROP TABLE IF EXISTS central_engineer_ledger_accumulator CASCADE;
DROP TABLE IF EXISTS bayani_reports_archive CASCADE;
DROP TABLE IF EXISTS model_7_archive CASCADE;
DROP TABLE IF EXISTS model_6_syndicate_contributions CASCADE;
DROP TABLE IF EXISTS model_6_assignments CASCADE;
DROP TABLE IF EXISTS model_6_projects CASCADE;
DROP TABLE IF EXISTS model_6_config CASCADE;
DROP TABLE IF EXISTS k_factor_matrix_model_6 CASCADE;
DROP TABLE IF EXISTS model_5_syndicate_contributions CASCADE;
DROP TABLE IF EXISTS model_5_assignments CASCADE;
DROP TABLE IF EXISTS model_5_projects CASCADE;
DROP TABLE IF EXISTS model_5_config CASCADE;
DROP TABLE IF EXISTS k_factor_matrix_model_5 CASCADE;
DROP TABLE IF EXISTS model_4_syndicate_contributions CASCADE;
DROP TABLE IF EXISTS model_4_assignments CASCADE;
DROP TABLE IF EXISTS model_4_projects CASCADE;
DROP TABLE IF EXISTS model_4_config CASCADE;
DROP TABLE IF EXISTS k_factor_matrix_model_4 CASCADE;
DROP TABLE IF EXISTS model_3_syndicate_contributions CASCADE;
DROP TABLE IF EXISTS model_3_assignments CASCADE;
DROP TABLE IF EXISTS model_3_projects CASCADE;
DROP TABLE IF EXISTS model_3_tariffs CASCADE;
DROP TABLE IF EXISTS k_factor_matrix CASCADE;
DROP TABLE IF EXISTS model_2_syndicate_contributions CASCADE;
DROP TABLE IF EXISTS model_2_assignments CASCADE;
DROP TABLE IF EXISTS model_2_projects CASCADE;
DROP TABLE IF EXISTS model_2_config CASCADE;
DROP TABLE IF EXISTS k_factor_matrix_model_2 CASCADE;
DROP TABLE IF EXISTS model_1_syndicate_contributions CASCADE;
DROP TABLE IF EXISTS model_1_assignments CASCADE;
DROP TABLE IF EXISTS model_1_projects CASCADE;
DROP TABLE IF EXISTS model_1_tariffs CASCADE;
DROP TABLE IF EXISTS k_factor_matrix_model_1 CASCADE;
DROP TABLE IF EXISTS printing_reimbursements_model_1 CASCADE;
DROP TABLE IF EXISTS engineers_registry CASCADE;
DROP TYPE IF EXISTS syndicate_branch_code CASCADE;
DROP TYPE IF EXISTS project_lifecycle_state CASCADE;
DROP TYPE IF EXISTS engineer_rank CASCADE;
DROP TYPE IF EXISTS fund_subscription_status CASCADE;
DROP TYPE IF EXISTS discipline_code CASCADE;
DROP TYPE IF EXISTS combined_fund_type CASCADE;
DROP TYPE IF EXISTS facility_type_model_5 CASCADE;
DROP TYPE IF EXISTS sr_committee_role CASCADE;
DROP TYPE IF EXISTS document_type_enum CASCADE;
COMMIT;



-- =========================================================================
-- START OF SOURCE FILE: model-1-schema-v4.sql
-- =========================================================================

-- =========================================================================
-- DATABASE SCHEMA: Model 1 — Comprehensive Engineering Study (GS - الدراسة العامة)
-- DBMS Target: PostgreSQL (Version 12+)
-- =========================================================================

-- BEGIN; (Commented out to run in single global transaction script)

-- =========================================================================
-- 1. EXTENSIONS & DOMAINS / CUSTOM TYPES
-- =========================================================================

-- Note: Types are created conditionally to prevent collisions when running multiple schemas
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'syndicate_branch_code') THEN
        CREATE TYPE syndicate_branch_code AS ENUM ('HAS', 'QAM', 'DER');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_lifecycle_state') THEN
        CREATE TYPE project_lifecycle_state AS ENUM ('INV', 'SETTLED');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'engineer_rank') THEN
        CREATE TYPE engineer_rank AS ENUM ('دراسة', 'ممارس', 'مبتدئ', 'تدريب', 'تدقيق', 'استشاري', 'eng', 'c1', 'متدرب', 'مشارك', 'تحت الاشراف');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'fund_subscription_status') THEN
        CREATE TYPE fund_subscription_status AS ENUM ('IN', 'OU');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'discipline_code') THEN
        CREATE TYPE discipline_code AS ENUM ('CIV', 'ARC', 'ELE', 'MCH', 'WTR', 'GEO', 'GTK');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'combined_fund_type') THEN
        CREATE TYPE combined_fund_type AS ENUM (
            'FUND_1_CIVIL_ARCH_WATER_GEO',
            'FUND_2_ELEC_MECH'
        );
    END IF;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- =========================================================================
-- 2. MASTER REFERENCE TABLES
-- =========================================================================

-- A. Project Classification Pricing Tariffs (Syrian Pounds)
CREATE TABLE IF NOT EXISTS model_1_tariffs (
    project_type VARCHAR(100) PRIMARY KEY,
    base_rate_syp NUMERIC(12, 2) NOT NULL CHECK (base_rate_syp >= 0.0),
    description TEXT
);

COMMENT ON TABLE model_1_tariffs IS 'Master tariff rate sheet per square meter in Syrian Pounds (SYP) for Model 1';

-- Populate Model 1 Base Rates
INSERT INTO model_1_tariffs (project_type, base_rate_syp, description) VALUES
('سكن ريفي', 600.00, 'Rural Housing - 600 SYP per square meter'),
('سكني وجمعيات', 1400.00, 'Residential & Cooperative Societies - 1,400 SYP per square meter'),
('سكني وتجاري', 1750.00, 'Commercial & Residential Mixed - 1,750 SYP per square meter'),
('منشآت خاصة', 2600.00, 'Specialized Private Facilities - 2,600 SYP per square meter');


-- B. K-Factor Multiplier Matrix for Stateless Net Calculation
CREATE TABLE IF NOT EXISTS k_factor_matrix_model_1 (
    adapter_key VARCHAR(4) PRIMARY KEY, -- 'INNO', 'INCO', 'OUNO', 'OUCO'
    is_insider BOOLEAN NOT NULL,
    has_coach BOOLEAN NOT NULL,
    resolved_k_factor NUMERIC(6, 4) NOT NULL CHECK (resolved_k_factor BETWEEN 0.0000 AND 1.0000),
    stage_1_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.1500, -- 15% Unit/Syndicate fee for Model 1
    stage_2_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.1700, -- 20% of remaining Stage 1 (0.85 * 0.20 = 17%)
    stage_3_rate NUMERIC(5, 4) NOT NULL,                -- 25% or 10% of remaining Stage 2
    stage_4_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.0000, -- 15% of remaining Stage 3 if trainee
    CONSTRAINT unique_flags_model_1 UNIQUE (is_insider, has_coach)
);

COMMENT ON TABLE k_factor_matrix_model_1 IS 'Collapsed O(1) stateless lookup table mapping fund membership and supervision status to final net payouts for Model 1';

-- Populate static K-factor coefficients (With 15% Stage 1 Syndicate Unit Rate)
-- Insider with Coach: (1 - 0.15) * (1 - 0.20) * (1 - 0.25) * (1 - 0.15) = 0.85 * 0.80 * 0.75 * 0.85 = 0.4335
-- Outsider with Coach: (1 - 0.15) * (1 - 0.20) * (1 - 0.10) * (1 - 0.15) = 0.85 * 0.80 * 0.90 * 0.85 = 0.5202
INSERT INTO k_factor_matrix_model_1 (adapter_key, is_insider, has_coach, resolved_k_factor, stage_3_rate, stage_4_rate) VALUES
('INNO', TRUE,  FALSE, 0.5100, 0.1700, 0.0000), -- Insider, No Coach (0.85 * 0.80 * 0.75 * 1.00 = 0.5100)
('INCO', TRUE,  TRUE,  0.4335, 0.1700, 0.0765), -- Insider, Coach (0.5100 * 0.85 = 0.4335)
('OUNO', FALSE, FALSE, 0.6120, 0.0680, 0.0000), -- Outsider, No Coach (0.85 * 0.80 * 0.90 * 1.00 = 0.6120)
('OUCO', FALSE, TRUE,  0.5202, 0.0680, 0.0918); -- Outsider, Coach (0.6120 * 0.85 = 0.5202)


-- C. Standard Printing Allowances Matrix
CREATE TABLE IF NOT EXISTS printing_reimbursements_model_1 (
    discipline_code discipline_code PRIMARY KEY,
    printing_share_syp NUMERIC(12, 2) NOT NULL CHECK (printing_share_syp >= 0.0)
);

COMMENT ON TABLE printing_reimbursements_model_1 IS 'Standard printing pool allocation per engineering specialty for Model 1 (Total: 150k)';

-- Populate Model 1 Printing Allowances
INSERT INTO printing_reimbursements_model_1 (discipline_code, printing_share_syp) VALUES
('CIV', 30000.00), -- Civil Share (20%)
('ARC', 30000.00), -- Architectural Share (20%)
('WTR', 30000.00), -- Water & Sanitary Share (20%)
('MCH', 22500.00), -- Mechanical Share (15%)
('ELE', 22500.00), -- Electrical Share (15%)
('GEO', 7500.00),  -- Geology Share (5%)
('GTK', 7500.00);  -- Geotechnical Share (5%)


-- =========================================================================
-- 3. CORE REGISTRY & TRANSACTION TABLES
-- =========================================================================

-- A. Engineers Core Registry (Unified database)
CREATE TABLE IF NOT EXISTS engineers_registry (
    engineer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    discipline discipline_code NOT NULL,
    role_qualification VARCHAR(150),
    rank engineer_rank NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    office_branch syndicate_branch_code,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Auto-populate office_branch from engineer_id prefix
CREATE OR REPLACE FUNCTION fn_auto_populate_engineer_office_branch()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.engineer_id LIKE '%-HAS-%' THEN
        NEW.office_branch := 'HAS'::syndicate_branch_code;
    ELSIF NEW.engineer_id LIKE '%-QAM-%' THEN
        NEW.office_branch := 'QAM'::syndicate_branch_code;
    ELSIF NEW.engineer_id LIKE '%-DER-%' THEN
        NEW.office_branch := 'DER'::syndicate_branch_code;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_populate_office_branch ON engineers_registry;
CREATE TRIGGER trg_auto_populate_office_branch
BEFORE INSERT ON engineers_registry
FOR EACH ROW
EXECUTE FUNCTION fn_auto_populate_engineer_office_branch();


CREATE INDEX IF NOT EXISTS idx_engineers_lookup ON engineers_registry(discipline, rank, is_active);


-- B. Model 1 Project Postings
CREATE TABLE IF NOT EXISTS model_1_projects (
    project_id VARCHAR(50) PRIMARY KEY, -- Alphanumeric linked code e.g. 'GS-HAS-2026-0001'
    client_name VARCHAR(150) NOT NULL,
    client_phone VARCHAR(50),
    zone_loc VARCHAR(100) NOT NULL,     -- Real estate zone
    parcel_no VARCHAR(50) NOT NULL,     -- Parcel number
    prop_no VARCHAR(50) NOT NULL,       -- Property ID
    branch_code syndicate_branch_code NOT NULL,
    project_type VARCHAR(100) NOT NULL REFERENCES model_1_tariffs(project_type),
    
    -- Technical Input Vector parameters
    area_total NUMERIC(12, 2) NOT NULL CHECK (area_total > 0.0),       -- Total Built Area across all levels
    area_footprint NUMERIC(12, 2) NOT NULL CHECK (area_footprint > 0.0), -- Ground coverage footprint (رقعة البناء)
    floors_count INTEGER NOT NULL CHECK (floors_count >= 1),             -- Above ground levels/stories
    elevators_count INTEGER NOT NULL DEFAULT 0 CHECK (elevators_count >= 0),
    amperage INTEGER NOT NULL DEFAULT 0 CHECK (amperage >= 0),           -- panel rating in Amperes
    active_usd_rate NUMERIC(12, 2) NOT NULL CHECK (active_usd_rate > 0.0),
    
    -- Computed Client-facing Invoice Items (The 15 Client Invoice Items)
    item_1_base_study_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_2_water_sanitary_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_3_geology_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_4_geotech_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_5_thermal_insulation_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_6_column_jackets_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_7_seismic_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_8_electrical_panel_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_9_solar_energy_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_10_ventilation_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_11_lightning_arrester_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_12_fire_alarm_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 25000.00,
    item_13_grounding_network_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 5000.00,
    item_14_elevator_review_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    item_15_printing_pool_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 150000.00,
    
    client_invoice_total_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    
    -- Transaction Lifecycle fields
    lifecycle_state project_lifecycle_state NOT NULL DEFAULT 'INV',
    receipt_no VARCHAR(100) DEFAULT NULL, -- Verification Cash Receipt logged by branch cashier
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    settled_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    
    CONSTRAINT check_settlement_receipt_model_1 CHECK (
        (lifecycle_state = 'INV' AND receipt_no IS NULL AND settled_at IS NULL) OR
        (lifecycle_state = 'SETTLED' AND receipt_no IS NOT NULL AND settled_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_receipt_verification_model_1 ON model_1_projects (receipt_no) WHERE receipt_no IS NOT NULL;


-- C. Model 1 Engineering Discipline Assignments & Financial Split Breakdown
CREATE TABLE IF NOT EXISTS model_1_assignments (
    assignment_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL REFERENCES model_1_projects(project_id) ON DELETE CASCADE,
    discipline_code discipline_code NOT NULL,
    
    -- Assignee snapshot characteristics (locked at time of invoice creation/update)
    is_assigned BOOLEAN NOT NULL DEFAULT TRUE,
    engineer_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    engineer_name VARCHAR(150),
    engineer_status fund_subscription_status, -- IN / OU snapshot
    engineer_rank engineer_rank,               -- qualification snapshot
    
    -- Coaching parameters
    has_coach BOOLEAN NOT NULL DEFAULT FALSE,
    supervisor_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    supervisor_name VARCHAR(150),
    
    -- Financial ledger details (calculated per assignee)
    resolved_k_factor NUMERIC(6, 4) NOT NULL DEFAULT 0.0000,
    gross_fee_share_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (gross_fee_share_syp >= 0.0),
    printing_share_syp NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (printing_share_syp >= 0.0),
    net_payout_calculated_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (net_payout_calculated_syp >= 0.0),
    
    -- Dynamic Escrow constraint
    payout_state VARCHAR(20) NOT NULL DEFAULT 'HELD' CHECK (payout_state IN ('HELD', 'EARNED')),
    
    -- Ensure same discipline isn't assigned twice on the same project
    CONSTRAINT unique_project_discipline_model_1 UNIQUE (project_id, discipline_code)
);

CREATE INDEX IF NOT EXISTS idx_assignments_project_model_1 ON model_1_assignments(project_id);


-- D. Central Syndicate Ledger DB for Audit & Contributions Verification (Model 1 Logs)
CREATE TABLE IF NOT EXISTS model_1_syndicate_contributions (
    record_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL,
    receipt_no VARCHAR(100) NOT NULL,
    branch syndicate_branch_code NOT NULL,
    model_type VARCHAR(10) NOT NULL DEFAULT 'GS',
    client_name VARCHAR(150) NOT NULL,
    discipline_code discipline_code NOT NULL,
    engineer_id VARCHAR(50) NOT NULL,
    engineer_name VARCHAR(150) NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    
    -- Deductions itemization breakdown
    gross_fee_syp NUMERIC(15, 2) NOT NULL,
    stage_1_unit_fee_syp NUMERIC(15, 2) NOT NULL,  -- 15% unit/syndicate admin fee
    stage_2_audit_pool_syp NUMERIC(15, 2) NOT NULL, -- 20% of remaining (17% of Gross)
    stage_3_fund_amount_syp NUMERIC(15, 2) NOT NULL, -- 25% Insider (17% of Gross) or 10% Outsider (6.8% of Gross)
    stage_4_coaching_fee_syp NUMERIC(15, 2) NOT NULL, -- 15% of remaining if trainee
    stage_5_printing_allowance_syp NUMERIC(12, 2) NOT NULL,
    net_payout_disbursed_syp NUMERIC(15, 2) NOT NULL,
    
    -- Compound Syndicate Fund destination
    combined_fund combined_fund_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================================
-- 4. BUSINESS LOGIC DATABASE TRIGGERS & FUNCTIONS
-- =========================================================================

-- A. Automated Invoice Calculations for the 15 Client Invoice Items
CREATE OR REPLACE FUNCTION fn_process_model_1_invoice_calculations()
RETURNS TRIGGER AS $$
DECLARE
    v_base_rate NUMERIC(12, 2);
BEGIN
    -- Fetch current tariff base rate
    SELECT base_rate_syp INTO v_base_rate 
    FROM model_1_tariffs 
    WHERE project_type = NEW.project_type;

    -- 1. Base Study Fee: Area_total * Base Rate
    NEW.item_1_base_study_fee_syp := NEW.area_total * v_base_rate;

    -- 2. Sanitary & Water Study Fee: Footprint-based scalable fee
    IF NEW.area_footprint <= 250.00 THEN
        NEW.item_2_water_sanitary_fee_syp := 100000.00;
    ELSE
        NEW.item_2_water_sanitary_fee_syp := 100000.00 + ((NEW.area_footprint - 250.00) * 300.00);
    END IF;

    -- 3 & 4. Geology and Geotechnical Soil Reports: Footprint & USD-rated conversions
    NEW.item_3_geology_fee_syp := ROUND((100.00 + (0.1 * NEW.area_footprint)) * NEW.active_usd_rate, 2);
    NEW.item_4_geotech_fee_syp := NEW.item_3_geology_fee_syp; -- Mapped using identical footprint logic

    -- 5. Thermal Insulation: Total Area * 60 SYP
    NEW.item_5_thermal_insulation_fee_syp := NEW.area_total * 60.00;

    -- 6. Column Jackets Fee: 80% * Rate_base * Area_footprint
    NEW.item_6_column_jackets_fee_syp := ROUND(0.80 * v_base_rate * NEW.area_footprint, 2);

    -- 7. Seismic Study / Earthquake: Total floors dependent scaling
    IF NEW.floors_count >= 4 THEN
        NEW.item_7_seismic_fee_syp := ROUND(0.35 * v_base_rate * NEW.area_total, 2);
    ELSE
        NEW.item_7_seismic_fee_syp := ROUND(0.20 * v_base_rate * NEW.area_total, 2);
    END IF;

    -- 8. Electrical Panel Fee: Ampere bracket pricing
    IF NEW.amperage BETWEEN 40 AND 400 THEN
        NEW.item_8_electrical_panel_fee_syp := 50000.00;
    ELSIF NEW.amperage BETWEEN 401 AND 1000 THEN
        NEW.item_8_electrical_panel_fee_syp := 75000.00;
    ELSIF NEW.amperage >= 1001 THEN
        NEW.item_8_electrical_panel_fee_syp := 100000.00;
    ELSE
        NEW.item_8_electrical_panel_fee_syp := 0.00;
    END IF;

    -- 9. Solar Energy Fee: Total Area * 50 SYP
    NEW.item_9_solar_energy_fee_syp := NEW.area_total * 50.00;

    -- 10. Ventilation Fee: Area_footprint * 100 SYP
    NEW.item_10_ventilation_fee_syp := NEW.area_footprint * 100.00;

    -- 11. Lightning Arrester: Total Area * 50 SYP
    NEW.item_11_lightning_arrester_fee_syp := NEW.area_total * 50.00;

    -- 12. Fire Alarm/Fighting: Flat lump sum
    NEW.item_12_fire_alarm_fee_syp := 25000.00;

    -- 13. Grounding Network: Flat lump sum
    NEW.item_13_grounding_network_fee_syp := 5000.00;

    -- 14. Elevator Review: 100,000 * Count
    NEW.item_14_elevator_review_fee_syp := 100000.00 * NEW.elevators_count;

    -- 15. Printing Pool Fee: Flat lump sum (150,000 SYP)
    NEW.item_15_printing_pool_fee_syp := 150000.00;

    -- Client Invoice Total: Consolidated Sum of all 15 Items
    NEW.client_invoice_total_syp := NEW.item_1_base_study_fee_syp
                                   + NEW.item_2_water_sanitary_fee_syp
                                   + NEW.item_3_geology_fee_syp
                                   + NEW.item_4_geotech_fee_syp
                                   + NEW.item_5_thermal_insulation_fee_syp
                                   + NEW.item_6_column_jackets_fee_syp
                                   + NEW.item_7_seismic_fee_syp
                                   + NEW.item_8_electrical_panel_fee_syp
                                   + NEW.item_9_solar_energy_fee_syp
                                   + NEW.item_10_ventilation_fee_syp
                                   + NEW.item_11_lightning_arrester_fee_syp
                                   + NEW.item_12_fire_alarm_fee_syp
                                   + NEW.item_13_grounding_network_fee_syp
                                   + NEW.item_14_elevator_review_fee_syp
                                   + NEW.item_15_printing_pool_fee_syp;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_model_1_invoice
BEFORE INSERT OR UPDATE OF project_type, area_total, area_footprint, floors_count, elevators_count, amperage, active_usd_rate ON model_1_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_1_invoice_calculations();


-- B. Automatically initialize the 7 standard engineering assignments for team selection
CREATE OR REPLACE FUNCTION fn_initialize_model_1_assignments()
RETURNS TRIGGER AS $$
DECLARE
    r_print RECORD;
BEGIN
    FOR r_print IN 
        SELECT discipline_code, printing_share_syp FROM printing_reimbursements_model_1
    LOOP
        INSERT INTO model_1_assignments (
            project_id, 
            discipline_code, 
            is_assigned, 
            printing_share_syp, 
            gross_fee_share_syp, 
            net_payout_calculated_syp
        ) VALUES (
            NEW.project_id,
            r_print.discipline_code,
            TRUE,
            r_print.printing_share_syp,
            0.00,
            r_print.printing_share_syp -- initial payout contains the printing share
        );
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_initialize_assignments_stub_model_1
AFTER INSERT ON model_1_projects
FOR EACH ROW
EXECUTE FUNCTION fn_initialize_model_1_assignments();


-- C. Calculate individual gross fees and net payouts whenever assignees are updated
CREATE OR REPLACE FUNCTION fn_process_assignment_calculations_update_model_1()
RETURNS TRIGGER AS $$
DECLARE
    v_proj RECORD;
    v_calculated_gross NUMERIC(15, 2) := 0.00;
    v_k_factor NUMERIC(6, 4);
BEGIN
    -- Exit if no project associated
    IF NEW.engineer_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Fetch the project calculations snapshot
    SELECT * INTO v_proj
    FROM model_1_projects
    WHERE project_id = NEW.project_id;

    -- Mapping base fee shares and add-ons across disciplines:
    -- CIV: 46% of Base Study Fee (1) + 50% of Column Jackets (6) + 100% of Seismic (7)
    IF NEW.discipline_code = 'CIV' THEN
        v_calculated_gross := (v_proj.item_1_base_study_fee_syp * 0.46)
                            + (v_proj.item_6_column_jackets_fee_syp * 0.50)
                            + v_proj.item_7_seismic_fee_syp;

    -- ARC: 32% of Base Study Fee (1) + 50% of Thermal Insulation (5) + 50% of Column Jackets (6)
    ELSIF NEW.discipline_code = 'ARC' THEN
        v_calculated_gross := (v_proj.item_1_base_study_fee_syp * 0.32)
                            + (v_proj.item_5_thermal_insulation_fee_syp * 0.50)
                            + (v_proj.item_6_column_jackets_fee_syp * 0.50);

    -- ELE: 11% of Base Study Fee (1) + 100% of Elec Panel (8) + 50% of Lightning Arrester (11) + 100% of Grounding (13)
    ELSIF NEW.discipline_code = 'ELE' THEN
        v_calculated_gross := (v_proj.item_1_base_study_fee_syp * 0.11)
                            + v_proj.item_8_electrical_panel_fee_syp
                            + (v_proj.item_11_lightning_arrester_fee_syp * 0.50)
                            + v_proj.item_13_grounding_network_fee_syp;

    -- MCH: 11% of Base Study Fee (1) + 50% of Thermal (5) + 100% of Solar (9) + 100% of Vent (10) + 50% of Lightning Arrester (11) + 100% of Fire Alarm (12) + 100% of Elevator Review (14)
    ELSIF NEW.discipline_code = 'MCH' THEN
        v_calculated_gross := (v_proj.item_1_base_study_fee_syp * 0.11)
                            + (v_proj.item_5_thermal_insulation_fee_syp * 0.50)
                            + v_proj.item_9_solar_energy_fee_syp
                            + v_proj.item_10_ventilation_fee_syp
                            + (v_proj.item_11_lightning_arrester_fee_syp * 0.50)
                            + v_proj.item_12_fire_alarm_fee_syp
                            + v_proj.item_14_elevator_review_fee_syp;

    -- WTR: 100% of Sanitary Study Fee (2)
    ELSIF NEW.discipline_code = 'WTR' THEN
        v_calculated_gross := v_proj.item_2_water_sanitary_fee_syp;

    -- GEO: 100% of Geology Report Fee (3)
    ELSIF NEW.discipline_code = 'GEO' THEN
        v_calculated_gross := v_proj.item_3_geology_fee_syp;

    -- GTK: 100% of Geotechnical Report Fee (4)
    ELSIF NEW.discipline_code = 'GTK' THEN
        v_calculated_gross := v_proj.item_4_geotech_fee_syp;

    END IF;

    NEW.gross_fee_share_syp := ROUND(v_calculated_gross, 2);

    -- Resolve historical attributes from registry
    SELECT rank, fund_status INTO NEW.engineer_rank, NEW.engineer_status
    FROM engineers_registry
    WHERE engineer_id = NEW.engineer_id;

    -- Coaching triggers: if rank is Trainee ('دراسة')
    IF NEW.engineer_rank = 'دراسة' THEN
        NEW.has_coach := TRUE;
    ELSE
        NEW.has_coach := FALSE;
    END IF;

    -- Query O(1) K-Factor Lookup Matrix (Model 1 has sd=15%)
    SELECT resolved_k_factor INTO v_k_factor
    FROM k_factor_matrix_model_1
    WHERE is_insider = (NEW.engineer_status = 'IN') AND has_coach = NEW.has_coach;

    NEW.resolved_k_factor := COALESCE(v_k_factor, 0.0000);

    -- Calculate direct payout: Net = (Gross * K) + Printing Share
    NEW.net_payout_calculated_syp := ROUND((NEW.gross_fee_share_syp * NEW.resolved_k_factor) + NEW.printing_share_syp, 2);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_assignment_shares_model_1
BEFORE UPDATE OF engineer_id ON model_1_assignments
FOR EACH ROW
EXECUTE FUNCTION fn_process_assignment_calculations_update_model_1();


-- D. Automatically release locked payouts upon treasury settlement
CREATE OR REPLACE FUNCTION fn_process_model_1_settlement_payouts()
RETURNS TRIGGER AS $$
BEGIN
    -- Trigger when project state changes to SETTLED
    IF OLD.lifecycle_state = 'INV' AND NEW.lifecycle_state = 'SETTLED' THEN
        
        -- 1. Unlocked cash escrow for assigned engineers
        UPDATE model_1_assignments
        SET payout_state = 'EARNED'
        WHERE project_id = NEW.project_id;

        -- 2. Log itemized deductions and payouts directly into Central Syndicate ledger
        INSERT INTO model_1_syndicate_contributions (
            project_id, receipt_no, branch, client_name, discipline_code,
            engineer_id, engineer_name, fund_status, gross_fee_syp,
            stage_1_unit_fee_syp, stage_2_audit_pool_syp, stage_3_fund_amount_syp,
            stage_4_coaching_fee_syp, stage_5_printing_allowance_syp,
            net_payout_disbursed_syp, combined_fund
        )
        SELECT 
            a.project_id,
            NEW.receipt_no,
            NEW.branch_code,
            NEW.client_name,
            a.discipline_code,
            a.engineer_id,
            a.engineer_name,
            a.engineer_status,
            a.gross_fee_share_syp,
            
            -- Deductions pipeline tracing using the static k-factor matrix rules
            (a.gross_fee_share_syp * k.stage_1_rate) AS stage_1_unit_fee_syp,
            (a.gross_fee_share_syp * k.stage_2_rate) AS stage_2_audit_pool_syp,
            (a.gross_fee_share_syp * k.stage_3_rate) AS stage_3_fund_amount_syp,
            (a.gross_fee_share_syp * k.stage_4_rate) AS stage_4_coaching_fee_syp,
            a.printing_share_syp,
            a.net_payout_calculated_syp,
            
            -- Assign to respective combined funds
            CASE 
                WHEN a.discipline_code IN ('CIV', 'ARC', 'WTR', 'GEO', 'GTK') THEN 'FUND_1_CIVIL_ARCH_WATER_GEO'::combined_fund_type
                ELSE 'FUND_2_ELEC_MECH'::combined_fund_type
            END AS combined_fund
        FROM model_1_assignments a
        JOIN k_factor_matrix_model_1 k ON k.adapter_key = (
            CASE 
                WHEN a.engineer_status = 'IN' THEN 'IN'
                ELSE 'OU'
            END || 
            CASE 
                WHEN a.has_coach THEN 'CO'
                ELSE 'NO'
            END
        )
        WHERE a.project_id = NEW.project_id AND a.is_assigned = TRUE AND a.engineer_id IS NOT NULL;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_release_escrow_on_settlement_model_1
AFTER UPDATE OF lifecycle_state ON model_1_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_1_settlement_payouts();


-- =========================================================================
-- 5. RECONCILIATION & REPORTING VIEW (AUDIT LAYER)
-- =========================================================================

-- Consolidated view for verifying mathematical zero-discrepancy balance in real-time
CREATE OR REPLACE VIEW view_model_1_balance_verification AS
SELECT 
    p.project_id,
    p.client_name,
    p.client_invoice_total_syp AS client_billed_invoice,
    
    -- Sum of all net disbursements
    COALESCE(SUM(a.net_payout_calculated_syp), 0) AS total_net_disbursed_to_engineers,
    
    -- Sum of all Stage 2 design audit deductions
    COALESCE(SUM(a.gross_fee_share_syp * k.stage_2_rate), 0) AS total_auditor_pool_retention,
    
    -- Sum of all syndicate holdings (Stage 1 Unit + Stage 3 Fund + Stage 4 Coaching)
    COALESCE(SUM(
        (a.gross_fee_share_syp * k.stage_1_rate) + 
        (a.gross_fee_share_syp * k.stage_3_rate) + 
        (a.gross_fee_share_syp * k.stage_4_rate)
    ), 0) AS total_syndicate_administrative_retentions,
    
    -- Mathematical Balance Verification Formula (Perfect balance matches zero)
    (
        p.client_invoice_total_syp - (
            COALESCE(SUM(a.net_payout_calculated_syp), 0) + 
            COALESCE(SUM(a.gross_fee_share_syp * k.stage_2_rate), 0) + 
            COALESCE(SUM(
                (a.gross_fee_share_syp * k.stage_1_rate) + 
                (a.gross_fee_share_syp * k.stage_3_rate) + 
                (a.gross_fee_share_syp * k.stage_4_rate)
            ), 0)
        )
    ) AS reconciliation_discrepancy
FROM model_1_projects p
LEFT JOIN model_1_assignments a ON a.project_id = p.project_id AND a.is_assigned = TRUE
LEFT JOIN k_factor_matrix_model_1 k ON k.adapter_key = (
    CASE 
        WHEN a.engineer_status = 'IN' THEN 'IN'
        ELSE 'OU'
    END || 
    CASE 
        WHEN a.has_coach THEN 'CO'
        ELSE 'NO'
    END
)
GROUP BY p.project_id, p.client_name, p.client_invoice_total_syp;

-- COMMIT; (Commented out to run in single global transaction script)
-- =========================================================================
-- END OF DDL SCHEMA
-- =========================================================================

-- =========================================================================
-- END OF SOURCE FILE: model-1-schema-v4.sql
-- =========================================================================


-- =========================================================================
-- START OF SOURCE FILE: model-2-schema-v3.sql
-- =========================================================================

-- =========================================================================
-- DATABASE SCHEMA: Model 2 — Structural Safety Report (SR - تقرير السلامة الإنشائية)
-- DBMS Target: PostgreSQL (Version 12+)
-- Standard: Unified Syndicate Engineering Governance
-- =========================================================================

-- BEGIN; (Commented out to run in single global transaction script)

-- =========================================================================
-- 1. EXTENSIONS & CUSTOM TYPES (Conditionally created for standalone deployment)
-- =========================================================================

-- Note: In a shared database, these types may already be defined by Model 3.
-- We use a safe schema check or drop/create block if deploying standalone.

-- Branch Sub-units
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'syndicate_branch_code') THEN
        CREATE TYPE syndicate_branch_code AS ENUM ('HAS', 'QAM', 'DER');
    END IF;
END $$;

-- Project Lifecycle States
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_lifecycle_state') THEN
        CREATE TYPE project_lifecycle_state AS ENUM ('INV', 'SETTLED');
    END IF;
END $$;

-- Engineer Qualification Ranks
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'engineer_rank') THEN
        CREATE TYPE engineer_rank AS ENUM ('دراسة', 'ممارس', 'مبتدئ', 'تدريب', 'تدقيق', 'استشاري', 'eng', 'c1', 'متدرب', 'مشارك', 'تحت الاشراف');
    END IF;
END $$;

-- Syndicate Fund Subscription Status (IN: Insider / OUT: Outsider)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'fund_subscription_status') THEN
        CREATE TYPE fund_subscription_status AS ENUM ('IN', 'OU');
    END IF;
END $$;

-- Discipline Codes
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'discipline_code') THEN
        CREATE TYPE discipline_code AS ENUM ('CIV', 'ARC', 'ELE', 'MCH', 'WTR', 'GEO', 'GTK');
    END IF;
END $$;

-- Combined Funds Types
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'combined_fund_type') THEN
        CREATE TYPE combined_fund_type AS ENUM ('FUND_1_CIVIL_ARCH_WATER_GEO', 'FUND_2_ELEC_MECH');
    END IF;
END $$;

-- Model 2 Specific Committee Roles Custom Type
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'sr_committee_role') THEN
        CREATE TYPE sr_committee_role AS ENUM (
            'CIVIL_CONSULTANT',    -- رئيس اللجنة (مدني استشاري)
            'CIVIL_PRACTITIONER',  -- عضو لجنة (مدني ممارس)
            'GEOTECHNIC',          -- عضو لجنة (جيوتكنيك ممارس أو أعلى)
            'ARCHITECT'            -- عضو لجنة (معماري ممارس أو أعلى)
        );
    END IF;
END $$;

-- =========================================================================
-- 2. MASTER CONFIGURATION & REFERENCE TABLES
-- =========================================================================

-- A. Model 2 Configuration Values (Strict USD Pricing)
CREATE TABLE IF NOT EXISTS model_2_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value NUMERIC(12, 4) NOT NULL,
    description TEXT
);

COMMENT ON TABLE model_2_config IS 'Master configuration rates, thresholds, and currency rules for Model 2 (SR)';

INSERT INTO model_2_config (config_key, config_value, description) VALUES
('base_rate_usd', 0.50, 'Baseline pricing fee per square meter of total built area ($0.50)'),
('minimum_area_threshold', 300.00, 'Minimum calculated built area threshold in square meters (300 m2)'),
('minimum_report_fee_usd', 150.00, 'Minimum static base report fee matching the 300 m2 threshold ($150.00)');


-- B. K-Factor Matrix for Model 2 (SR) Stateless Net Calculation
-- Model 2 does not utilize Design Audit pools or coaching/training fees.
-- Payout multipliers are: Insider = 0.6750 (10% Unit Fee, 25% Fund Fee), Outsider = 0.8100 (10% Unit Fee, 10% Fund Fee).
CREATE TABLE IF NOT EXISTS k_factor_matrix_model_2 (
    fund_status fund_subscription_status PRIMARY KEY,
    resolved_k_factor NUMERIC(6, 4) NOT NULL CHECK (resolved_k_factor BETWEEN 0.0000 AND 1.0000),
    stage_1_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.1000, -- 10% Unit/Syndicate Fee
    stage_2_rate NUMERIC(5, 4) NOT NULL,                -- 25% or 10% on Remaining_1 (i.e. 22.5% or 9.0% of Gross)
    description VARCHAR(100)
);

COMMENT ON TABLE k_factor_matrix_model_2 IS 'Collapsed O(1) stateless payout lookup matrix for Model 2 (SR) based on VLOOKUP fund statuses';

INSERT INTO k_factor_matrix_model_2 (fund_status, resolved_k_factor, stage_1_rate, stage_2_rate, description) VALUES
('IN', 0.6750, 0.1000, 0.2250, 'Insider - 10% Unit Fee -> 25% of Remaining (Total: 67.5% net payout)'),
('OU', 0.8100, 0.1000, 0.0900, 'Outsider - 10% Unit Fee -> 10% of Remaining (Total: 81.0% net payout)');


-- =========================================================================
-- 3. CORE TRANSACTION & REGISTRY TABLES (Model 2 Isolated)
-- =========================================================================

-- Note: engineers_registry is shared across the syndicate project database.
-- If it does not exist, we create it; otherwise, we reuse the existing table.
CREATE TABLE IF NOT EXISTS engineers_registry (
    engineer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    discipline discipline_code NOT NULL,
    role_qualification VARCHAR(150),
    rank engineer_rank NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    office_branch syndicate_branch_code,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- A. Model 2 Structural Safety Report Project Posting
CREATE TABLE IF NOT EXISTS model_2_projects (
    project_id VARCHAR(50) PRIMARY KEY, -- Alphanumeric linked code e.g. 'SR-HAS-2026-0001'
    client_name VARCHAR(150) NOT NULL,
    client_phone VARCHAR(50),
    zone_loc VARCHAR(100) NOT NULL,     -- Real estate zone (المنطقة العقارية)
    parcel_no VARCHAR(50) NOT NULL,     -- Parcel number (رقم المقسم)
    prop_no VARCHAR(50) NOT NULL,       -- Property ID (رقم العقار)
    branch_code syndicate_branch_code NOT NULL,
    
    -- Technical Input Vector parameters
    is_permitted BOOLEAN NOT NULL,      -- Permit status (TRUE: مرخص, FALSE: غير مرخص)
    execution_year INTEGER NOT NULL CHECK (execution_year > 1900),
    permitted_area NUMERIC(12, 2) NOT NULL DEFAULT 0.0 CHECK (permitted_area >= 0.0),
    extra_area NUMERIC(12, 2) NOT NULL DEFAULT 0.0 CHECK (extra_area >= 0.0),
    total_area NUMERIC(12, 2) NOT NULL CHECK (total_area > 0.0), -- Total Executed & Future Area (كامل المساحة)
    
    -- Calculated client billings (Strictly in USD)
    calculated_area NUMERIC(12, 2) NOT NULL DEFAULT 0.0,
    billed_area NUMERIC(12, 2) NOT NULL DEFAULT 0.0,
    fee_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    soil_report_required BOOLEAN NOT NULL DEFAULT FALSE,
    client_invoice_total_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    
    -- Transaction Lifecycle fields
    lifecycle_state project_lifecycle_state NOT NULL DEFAULT 'INV',
    receipt_no VARCHAR(100) DEFAULT NULL, -- Verified cashier receipt logged by branch treasury
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    settled_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    
    -- Integrity Constraint Checks
    CONSTRAINT check_permitted_area_sum CHECK (total_area >= (permitted_area + extra_area)),
    CONSTRAINT check_settlement_receipt CHECK (
        (lifecycle_state = 'INV' AND receipt_no IS NULL AND settled_at IS NULL) OR
        (lifecycle_state = 'SETTLED' AND receipt_no IS NOT NULL AND settled_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_receipt_verification_model_2 ON model_2_projects (receipt_no) WHERE receipt_no IS NOT NULL;


-- B. Model 2 Committee Assignments Table
CREATE TABLE IF NOT EXISTS model_2_assignments (
    assignment_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL REFERENCES model_2_projects(project_id) ON DELETE CASCADE,
    committee_role sr_committee_role NOT NULL,
    
    -- Historical profile snapshot (frozen at time of registry validation)
    is_assigned BOOLEAN NOT NULL DEFAULT TRUE,
    engineer_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    engineer_name VARCHAR(150),
    engineer_status fund_subscription_status,
    engineer_rank engineer_rank,
    
    -- Financial payouts
    resolved_k_factor NUMERIC(6, 4) NOT NULL DEFAULT 0.0000,
    gross_fee_share_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (gross_fee_share_usd >= 0.0),
    net_payout_calculated_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (net_payout_calculated_usd >= 0.0),
    payout_state VARCHAR(20) NOT NULL DEFAULT 'HELD' CHECK (payout_state IN ('HELD', 'EARNED')),
    
    CONSTRAINT unique_project_role UNIQUE (project_id, committee_role)
);

CREATE INDEX IF NOT EXISTS idx_assignments_project_model_2 ON model_2_assignments(project_id);


-- C. Model 2 Syndicate Ledger DB (USD Accounting)
CREATE TABLE IF NOT EXISTS model_2_syndicate_contributions (
    record_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL,
    receipt_no VARCHAR(100) NOT NULL,
    branch syndicate_branch_code NOT NULL,
    model_type VARCHAR(10) NOT NULL DEFAULT 'SR',
    client_name VARCHAR(150) NOT NULL,
    committee_role sr_committee_role NOT NULL,
    engineer_id VARCHAR(50) NOT NULL,
    engineer_name VARCHAR(150) NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    
    -- Deductions itemization breakdown (USD)
    gross_fee_usd NUMERIC(12, 2) NOT NULL,
    stage_1_unit_fee_usd NUMERIC(12, 2) NOT NULL,  -- 10% unit/syndicate admin fee
    stage_2_fund_amount_usd NUMERIC(12, 2) NOT NULL, -- 25% Insider / 10% Outsider
    net_payout_disbursed_usd NUMERIC(12, 2) NOT NULL,
    combined_fund combined_fund_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================================
-- 4. BUSINESS LOGIC DATABASE TRIGGERS & FUNCTIONS
-- =========================================================================

-- A. Automated Area Calculations & Soil Report Trigger
CREATE OR REPLACE FUNCTION fn_process_model_2_invoice_calculations()
RETURNS TRIGGER AS $$
DECLARE
    v_base_rate NUMERIC(12, 4);
    v_min_area NUMERIC(12, 2);
BEGIN
    -- 1. Fetch rates from config table
    SELECT config_value INTO v_base_rate FROM model_2_config WHERE config_key = 'base_rate_usd';
    SELECT config_value INTO v_min_area FROM model_2_config WHERE config_key = 'minimum_area_threshold';

    -- 2. Model 2 (SR) charges 100% on total executed area for all buildings
    NEW.calculated_area := NEW.total_area;

    -- 3. Minimum Area Thresholding (300 m2 minimum gives $150 minimum base fee)
    NEW.billed_area := GREATEST(NEW.calculated_area, v_min_area);
    NEW.fee_usd := NEW.billed_area * v_base_rate;

    -- 4. Automatic Soil Report Trigger for unpermitted structures (Schmidt hammer / geotechnical study)
    IF NOT NEW.is_permitted THEN
        NEW.soil_report_required := TRUE;
    ELSE
        NEW.soil_report_required := FALSE;
    END IF;

    -- 5. Grand total invoice matches the computed fee
    NEW.client_invoice_total_usd := NEW.fee_usd;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_model_2_invoice
BEFORE INSERT OR UPDATE OF is_permitted, total_area ON model_2_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_2_invoice_calculations();


-- B. Automatically initialize the 4 standard committee assignments for team selection
CREATE OR REPLACE FUNCTION fn_initialize_model_2_assignments()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO model_2_assignments (project_id, committee_role, is_assigned) VALUES
    (NEW.project_id, 'CIVIL_CONSULTANT', TRUE),
    (NEW.project_id, 'CIVIL_PRACTITIONER', TRUE),
    (NEW.project_id, 'GEOTECHNIC', TRUE),
    (NEW.project_id, 'ARCHITECT', TRUE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_initialize_assignments_stub_model_2
AFTER INSERT ON model_2_projects
FOR EACH ROW
EXECUTE FUNCTION fn_initialize_model_2_assignments();


-- C. Automatically validate qualifications and calculate net payouts whenever assignees are updated
CREATE OR REPLACE FUNCTION fn_process_assignment_calculations_update_model_2()
RETURNS TRIGGER AS $$
DECLARE
    v_total_fee NUMERIC(12, 2);
    v_calculated_gross NUMERIC(12, 2);
    v_k_factor NUMERIC(6, 4);
    v_discipline discipline_code;
    v_rank engineer_rank;
    v_is_active BOOLEAN;
BEGIN
    -- Exit if no engineer is assigned
    IF NEW.engineer_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- 1. Fetch total Gross Fee
    SELECT client_invoice_total_usd INTO v_total_fee
    FROM model_2_projects
    WHERE project_id = NEW.project_id;

    -- 2. Committee is split equally among the 4 members (25% each)
    v_calculated_gross := v_total_fee / 4.0;
    NEW.gross_fee_share_usd := v_calculated_gross;

    -- 3. Resolve profile details from registry
    SELECT discipline, rank, fund_status, is_active 
    INTO v_discipline, v_rank, NEW.engineer_status, v_is_active
    FROM engineers_registry
    WHERE engineer_id = NEW.engineer_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION '⚠ المهندس المعين غير موجود في سجل النقابة المعتمد';
    END IF;

    IF NOT v_is_active THEN
        RAISE EXCEPTION '⚠ المهندس المختار غير مفعّل في السجل النقابي الحالي';
    END IF;

    NEW.engineer_name := (SELECT full_name FROM engineers_registry WHERE engineer_id = NEW.engineer_id);
    NEW.engineer_rank := v_rank;

    -- 4. Enforce strict qualifications rules of the 4-engineer committee
    IF NEW.committee_role = 'CIVIL_CONSULTANT' THEN
        IF v_discipline != 'CIV' THEN
            RAISE EXCEPTION '⚠ رئيس اللجنة يجب أن يكون مهندس مدني';
        END IF;
        IF v_rank != 'استشاري' THEN
            RAISE EXCEPTION '⚠ رئيس لجنة السلامة الإنشائية يجب أن يكون برتبة استشاري';
        END IF;
    ELSIF NEW.committee_role = 'CIVIL_PRACTITIONER' THEN
        IF v_discipline != 'CIV' THEN
            RAISE EXCEPTION '⚠ عضو اللجنة المدني يجب أن يكون مهندس مدني ممارس أو أعلى';
        END IF;
        IF v_rank NOT IN ('ممارس', 'تدريب', 'تدقيق', 'استشاري', 'c1') THEN
            RAISE EXCEPTION '⚠ رتبة العضو المدني يجب أن تكون ممارس على الأقل';
        END IF;
    ELSIF NEW.committee_role = 'GEOTECHNIC' THEN
        -- Geotechnic validation (can be geotechnic, geological, or civil with geotechnic qualification)
        IF v_discipline NOT IN ('GTK', 'GEO', 'CIV') THEN
            RAISE EXCEPTION '⚠ عضو الجيوتكنيك يجب أن يكون بتخصص جيوتكنيك أو جيولوجيا أو مدني ممارس';
        END IF;
        IF v_rank NOT IN ('ممارس', 'تدريب', 'تدقيق', 'استشاري', 'c1') THEN
            RAISE EXCEPTION '⚠ رتبة عضو الجيوتكنيك يجب أن تكون ممارس على الأقل';
        END IF;
    ELSIF NEW.committee_role = 'ARCHITECT' THEN
        IF v_discipline != 'ARC' THEN
            RAISE EXCEPTION '⚠ العضو المعماري يجب أن يكون مهندس عمارة ممارس أو أعلى';
        END IF;
        IF v_rank NOT IN ('ممارس', 'تدريب', 'تدقيق', 'استشاري', 'c1') THEN
            RAISE EXCEPTION '⚠ رتبة العضو المعماري يجب أن تكون ممارس على الأقل';
        END IF;
    END IF;

    -- 5. Query O(1) stateless K-Factor lookup from matrix
    SELECT resolved_k_factor INTO v_k_factor
    FROM k_factor_matrix_model_2
    WHERE fund_status = NEW.engineer_status;

    NEW.resolved_k_factor := COALESCE(v_k_factor, 0.0000);

    -- 6. Direct stateless calculation (No printing or coaching overrides exist in Model 2)
    NEW.net_payout_calculated_usd := ROUND(NEW.gross_fee_share_usd * NEW.resolved_k_factor, 2);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_assignment_shares_model_2
BEFORE UPDATE OF engineer_id ON model_2_assignments
FOR EACH ROW
EXECUTE FUNCTION fn_process_assignment_calculations_update_model_2();


-- D. Automatically release locked payouts upon treasury settlement
CREATE OR REPLACE FUNCTION fn_process_model_2_settlement_payouts()
RETURNS TRIGGER AS $$
BEGIN
    -- Only trigger when project state changes to SETTLED
    IF OLD.lifecycle_state = 'INV' AND NEW.lifecycle_state = 'SETTLED' THEN
        
        -- 1. Unlock escrow for assigned engineers
        UPDATE model_2_assignments
        SET payout_state = 'EARNED'
        WHERE project_id = NEW.project_id;

        -- 2. Log payouts and deductions directly into the Model 2 Syndicate ledger
        INSERT INTO model_2_syndicate_contributions (
            project_id, receipt_no, branch, client_name, committee_role,
            engineer_id, engineer_name, fund_status, gross_fee_usd,
            stage_1_unit_fee_usd, stage_2_fund_amount_usd,
            net_payout_disbursed_usd, combined_fund
        )
        SELECT 
            a.project_id,
            NEW.receipt_no,
            NEW.branch_code,
            NEW.client_name,
            a.committee_role,
            a.engineer_id,
            a.engineer_name,
            a.engineer_status,
            a.gross_fee_share_usd,
            
            -- Deductions
            (a.gross_fee_share_usd * k.stage_1_rate) AS stage_1_unit_fee_usd,
            (a.gross_fee_share_usd * k.stage_2_rate) AS stage_2_fund_amount_usd,
            a.net_payout_calculated_usd,
            
            -- Civil, Architecture, Geotechnic, and Geology funds map to FUND_1
            'FUND_1_CIVIL_ARCH_WATER_GEO'::combined_fund_type AS combined_fund
        FROM model_2_assignments a
        JOIN k_factor_matrix_model_2 k ON k.fund_status = a.engineer_status
        WHERE a.project_id = NEW.project_id AND a.is_assigned = TRUE AND a.engineer_id IS NOT NULL;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_release_escrow_on_settlement_model_2
AFTER UPDATE OF lifecycle_state ON model_2_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_2_settlement_payouts();


-- =========================================================================
-- 5. RECONCILIATION & REPORTING VIEW
-- =========================================================================

-- Consolidated view for verifying mathematical zero-discrepancy balance in real-time
CREATE OR REPLACE VIEW view_model_2_balance_verification AS
SELECT 
    p.project_id,
    p.client_name,
    p.client_invoice_total_usd AS client_billed_invoice_usd,
    
    -- Sum of all net payouts
    COALESCE(SUM(a.net_payout_calculated_usd), 0) AS total_net_disbursed_to_engineers_usd,
    
    -- Sum of all syndicate holdings (Stage 1 Unit Fee + Stage 2 Fund Retention)
    COALESCE(SUM(
        (a.gross_fee_share_usd * k.stage_1_rate) + 
        (a.gross_fee_share_usd * k.stage_2_rate)
    ), 0) AS total_syndicate_administrative_retentions_usd,
    
    -- Mathematical Balance Verification Formula (Perfect balance matches zero)
    (
        p.client_invoice_total_usd - (
            COALESCE(SUM(a.net_payout_calculated_usd), 0) + 
            COALESCE(SUM(
                (a.gross_fee_share_usd * k.stage_1_rate) + 
                (a.gross_fee_share_usd * k.stage_2_rate)
            ), 0)
        )
    ) AS reconciliation_discrepancy_usd
FROM model_2_projects p
LEFT JOIN model_2_assignments a ON a.project_id = p.project_id AND a.is_assigned = TRUE
LEFT JOIN k_factor_matrix_model_2 k ON k.fund_status = a.engineer_status
GROUP BY p.project_id, p.client_name, p.client_invoice_total_usd;

-- COMMIT; (Commented out to run in single global transaction script)
-- =========================================================================
-- END OF DDL SCHEMA FOR MODEL 2
-- =========================================================================

-- =========================================================================
-- END OF SOURCE FILE: model-2-schema-v3.sql
-- =========================================================================


-- =========================================================================
-- START OF SOURCE FILE: model-3-schema-v4.sql
-- =========================================================================

-- =========================================================================
-- DATABASE SCHEMA: Model 3 — Structural Safety Study (SS - دراسة السلامة الإنشائية)
-- DBMS Target: PostgreSQL (Version 12+)
-- =========================================================================

-- BEGIN; (Commented out to run in single global transaction script)

-- =========================================================================
-- =========================================================================
-- 1. EXTENSIONS & DOMAINS / CUSTOM TYPES (Conditionally created for standalone deployment)
-- =========================================================================

-- Branch Sub-units
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'syndicate_branch_code') THEN
        CREATE TYPE syndicate_branch_code AS ENUM ('HAS', 'QAM', 'DER');
    END IF;
END $$;

-- Project Lifecycle States
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_lifecycle_state') THEN
        CREATE TYPE project_lifecycle_state AS ENUM ('INV', 'SETTLED');
    END IF;
END $$;

-- Engineer Qualification Ranks (Ranks and coaching control values)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'engineer_rank') THEN
        CREATE TYPE engineer_rank AS ENUM ('دراسة', 'ممارس', 'مبتدئ', 'تدريب', 'تدقيق', 'استشاري', 'eng', 'c1', 'متدرب', 'مشارك', 'تحت الاشراف');
    END IF;
END $$;

-- Syndicate Fund Subscription Status
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'fund_subscription_status') THEN
        CREATE TYPE fund_subscription_status AS ENUM ('IN', 'OU');
    END IF;
END $$;

-- Discipline Codes for 5 standard disciplines + Soils
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'discipline_code') THEN
        CREATE TYPE discipline_code AS ENUM ('CIV', 'ARC', 'ELE', 'MCH', 'WTR', 'GEO', 'GTK');
    END IF;
END $$;

-- Combined Funds Types
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'combined_fund_type') THEN
        CREATE TYPE combined_fund_type AS ENUM (
            'FUND_1_CIVIL_ARCH_WATER_GEO',
            'FUND_2_ELEC_MECH'
        );
    END IF;
END $$;

-- =========================================================================
-- 2. MASTER REFERENCE TABLES
-- =========================================================================

-- A. Project Classification Pricing Tariffs (Syrian Pounds)
CREATE TABLE IF NOT EXISTS model_3_tariffs (
    project_type VARCHAR(100) PRIMARY KEY,
    base_rate_syp NUMERIC(12, 2) NOT NULL CHECK (base_rate_syp >= 0.0),
    description TEXT
);

COMMENT ON TABLE model_3_tariffs IS 'Master tariff rate sheet per square meter in Syrian Pounds (SYP) for Model 3';

-- Populate Model 3 Base Rates
INSERT INTO model_3_tariffs (project_type, base_rate_syp, description) VALUES
('سكن ريفي', 600.00, 'Rural Housing - 600 SYP per square meter'),
('سكني وجمعيات', 1400.00, 'Residential & Cooperative Societies - 1,400 SYP per square meter'),
('سكني وتجاري', 1750.00, 'Commercial & Residential Mixed - 1,750 SYP per square meter'),
('منشآت خاصة', 2600.00, 'Specialized Private Facilities - 2,600 SYP per square meter');


-- B. K-Factor Multiplier Matrix for Stateless Net Calculation
CREATE TABLE IF NOT EXISTS k_factor_matrix (
    adapter_key VARCHAR(4) PRIMARY KEY, -- 'INNO', 'INCO', 'OUNO', 'OUCO'
    is_insider BOOLEAN NOT NULL,
    has_coach BOOLEAN NOT NULL,
    resolved_k_factor NUMERIC(6, 4) NOT NULL CHECK (resolved_k_factor BETWEEN 0.0000 AND 1.0000),
    stage_1_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.1000, -- 10% Unit/Syndicate fee
    stage_2_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.1800, -- 20% of remaining Stage 1 (0.90 * 0.20 = 18%)
    stage_3_rate NUMERIC(5, 4) NOT NULL,                -- 25% or 10% of remaining Stage 2
    stage_4_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.0000, -- 15% of remaining Stage 3 if trainee
    CONSTRAINT unique_flags UNIQUE (is_insider, has_coach)
);

COMMENT ON TABLE k_factor_matrix IS 'Collapsed O(1) stateless lookup table mapping fund membership and supervision status to final net payouts';

-- Populate static K-factor coefficients
INSERT INTO k_factor_matrix (adapter_key, is_insider, has_coach, resolved_k_factor, stage_3_rate, stage_4_rate) VALUES
('INNO', TRUE,  FALSE, 0.5400, 0.1800, 0.0000), -- Insider, No Coach (0.90 * 0.80 * 0.75 * 1.00 = 0.5400)
('INCO', TRUE,  TRUE,  0.4590, 0.1800, 0.0810), -- Insider, Coach (0.5400 * 0.85 = 0.4590)
('OUNO', FALSE, FALSE, 0.6480, 0.0720, 0.0000), -- Outsider, No Coach (0.90 * 0.80 * 0.90 * 1.00 = 0.6480)
('OUCO', FALSE, TRUE,  0.5508, 0.0720, 0.0972); -- Outsider, Coach (0.6480 * 0.85 = 0.5508)


-- C. Standard Printing Allowances Matrix
CREATE TABLE IF NOT EXISTS printing_reimbursements (
    discipline_code discipline_code PRIMARY KEY,
    printing_share_syp NUMERIC(12, 2) NOT NULL CHECK (printing_share_syp >= 0.0)
);

COMMENT ON TABLE printing_reimbursements IS 'Immutable standard layout printing pool allocation per engineering specialty (SYP)';

-- Populate Model 3 Printing Allowances (150k printing pool)
INSERT INTO printing_reimbursements (discipline_code, printing_share_syp) VALUES
('CIV', 60000.00), -- Civil Printing Allowance
('ARC', 40000.00), -- Architectural Printing Allowance
('ELE', 15000.00), -- Electrical Printing Allowance
('MCH', 10000.00), -- Mechanical Printing Allowance
('WTR', 15000.00); -- Water & Sanitary Printing Allowance


-- =========================================================================
-- 3. CORE REGISTRY & TRANSACTION TABLES
-- =========================================================================

-- A. Engineers Core Registry (Unified database)
CREATE TABLE IF NOT EXISTS engineers_registry (
    engineer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    discipline discipline_code NOT NULL,
    role_qualification VARCHAR(150),
    rank engineer_rank NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    office_branch syndicate_branch_code,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_engineers_lookup ON engineers_registry(discipline, rank, is_active);


-- B. Model 3 Project Postings
CREATE TABLE IF NOT EXISTS model_3_projects (
    project_id VARCHAR(50) PRIMARY KEY, -- Alphanumeric linked code e.g. 'SS-HAS-2026-0001'
    client_name VARCHAR(150) NOT NULL,
    client_phone VARCHAR(50),
    zone_loc VARCHAR(100) NOT NULL,     -- Real estate zone (المنطقة العقارية)
    parcel_no VARCHAR(50) NOT NULL,     -- Parcel number (رقم المقسم)
    prop_no VARCHAR(50) NOT NULL,       -- Property ID (رقم العقار)
    branch_code syndicate_branch_code NOT NULL,
    project_type VARCHAR(100) NOT NULL REFERENCES model_3_tariffs(project_type),
    
    -- Technical Input Vector parameters
    is_permitted BOOLEAN NOT NULL,      -- Permit status (TRUE: مرخص, FALSE: غير مرخص)
    execution_year INTEGER NOT NULL CHECK (execution_year > 1900),
    permitted_area NUMERIC(12, 2) NOT NULL DEFAULT 0.0 CHECK (permitted_area >= 0.0),
    extra_area NUMERIC(12, 2) NOT NULL DEFAULT 0.0 CHECK (extra_area >= 0.0),
    total_area NUMERIC(12, 2) NOT NULL CHECK (total_area > 0.0),
    built_area NUMERIC(12, 2) NOT NULL CHECK (built_area > 0.0), -- Ground Floor Footprint Area (رقعة البناء)
    active_usd_rate NUMERIC(12, 2) NOT NULL CHECK (active_usd_rate > 0.0),
    
    -- Computed Client-facing Totals
    calculated_study_area NUMERIC(12, 2) NOT NULL DEFAULT 0.0,
    gross_study_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    water_sanitary_fee_syp NUMERIC(12, 2) NOT NULL DEFAULT 0.0,
    soil_report_required BOOLEAN NOT NULL DEFAULT FALSE,
    soil_report_fee_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    printing_pool_syp NUMERIC(12, 2) NOT NULL DEFAULT 140000.00,
    client_invoice_total_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.0,
    
    -- Transaction Lifecycle fields
    lifecycle_state project_lifecycle_state NOT NULL DEFAULT 'INV',
    receipt_no VARCHAR(100) DEFAULT NULL, -- Verification Cash Receipt logged by branch cashier
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    settled_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    
    -- Incomplete parameters checks constraint
    CONSTRAINT check_total_area_sum CHECK (total_area >= (permitted_area + extra_area)),
    CONSTRAINT check_settlement_receipt CHECK (
        (lifecycle_state = 'INV' AND receipt_no IS NULL AND settled_at IS NULL) OR
        (lifecycle_state = 'SETTLED' AND receipt_no IS NOT NULL AND settled_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_receipt_verification ON model_3_projects (receipt_no) WHERE receipt_no IS NOT NULL;


-- C. Model 3 Engineering Discipline Assignments & Financial Split Breakdown
CREATE TABLE IF NOT EXISTS model_3_assignments (
    assignment_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL REFERENCES model_3_projects(project_id) ON DELETE CASCADE,
    discipline_code discipline_code NOT NULL,
    
    -- Assignee snapshot characteristics (locked at time of invoice creation)
    is_assigned BOOLEAN NOT NULL DEFAULT TRUE,
    engineer_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    engineer_name VARCHAR(150),
    engineer_status fund_subscription_status, -- IN / OU snapshot
    engineer_rank engineer_rank,               -- qualification snapshot
    
    -- Coaching parameters
    has_coach BOOLEAN NOT NULL DEFAULT FALSE,
    supervisor_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    supervisor_name VARCHAR(150),
    
    -- Financial ledger details (calculated per assignee)
    resolved_k_factor NUMERIC(6, 4) NOT NULL DEFAULT 0.0000,
    gross_fee_share_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (gross_fee_share_syp >= 0.0),
    printing_share_syp NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (printing_share_syp >= 0.0),
    net_payout_calculated_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (net_payout_calculated_syp >= 0.0),
    
    -- Dynamic Escrow constraint
    payout_state VARCHAR(20) NOT NULL DEFAULT 'HELD' CHECK (payout_state IN ('HELD', 'EARNED')),
    
    -- Ensure same discipline isn't assigned twice on the same project
    CONSTRAINT unique_project_discipline UNIQUE (project_id, discipline_code)
);

CREATE INDEX IF NOT EXISTS idx_assignments_project ON model_3_assignments(project_id);


-- D. Central Syndicate Ledger DB for Audit & Contributions Verification
CREATE TABLE IF NOT EXISTS syndicate_contributions_db (
    record_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL,
    receipt_no VARCHAR(100) NOT NULL,
    branch syndicate_branch_code NOT NULL,
    model_type VARCHAR(10) NOT NULL DEFAULT 'SS',
    client_name VARCHAR(150) NOT NULL,
    discipline_code discipline_code NOT NULL,
    engineer_id VARCHAR(50) NOT NULL,
    engineer_name VARCHAR(150) NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    
    -- Deductions itemization breakdown
    gross_fee_syp NUMERIC(15, 2) NOT NULL,
    stage_1_unit_fee_syp NUMERIC(15, 2) NOT NULL, -- 10% unit/syndicate admin fee
    stage_2_audit_pool_syp NUMERIC(15, 2) NOT NULL, -- 20% of remaining (18% of Gross)
    stage_3_fund_amount_syp NUMERIC(15, 2) NOT NULL, -- 25% Insider / 10% Outsider
    stage_4_coaching_fee_syp NUMERIC(15, 2) NOT NULL, -- 15% if rank Trainee
    stage_5_printing_allowance_syp NUMERIC(12, 2) NOT NULL,
    net_payout_disbursed_syp NUMERIC(15, 2) NOT NULL,
    
    -- Compound Syndicate Fund destination
    combined_fund combined_fund_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================================
-- 4. BUSINESS LOGIC DATABASE TRIGGERS & FUNCTIONS
-- =========================================================================

-- A. Automated Soil Report Surcharges & Billed Area Triggers
CREATE OR REPLACE FUNCTION fn_process_model_3_invoice_calculations()
RETURNS TRIGGER AS $$
DECLARE
    v_base_rate NUMERIC(12, 2);
BEGIN
    -- 1. Fetch current tariff rate
    SELECT base_rate_syp INTO v_base_rate 
    FROM model_3_tariffs 
    WHERE project_type = NEW.project_type;

    -- 2. Establish Area calculations
    IF NEW.is_permitted THEN
        NEW.calculated_study_area := (0.50 * NEW.permitted_area) + (1.00 * NEW.extra_area);
    ELSE
        NEW.calculated_study_area := 1.00 * NEW.total_area;
    END IF;

    -- 3. Gross Base Study Fee calculations with mandatory 15% discount structure
    NEW.gross_study_fee_syp := NEW.calculated_study_area * v_base_rate * 0.85;

    -- 4. Calculate Water & Sanitary progressive footprint scaling
    IF NEW.built_area <= 250.00 THEN
        NEW.water_sanitary_fee_syp := 100000.00;
    ELSE
        NEW.water_sanitary_fee_syp := 100000.00 + ((NEW.built_area - 250.00) * 300.00);
    END IF;

    -- 5. Handle Unpermitted Buildings Diagnostic triggers (Soil/Hammer Report)
    IF NOT NEW.is_permitted THEN
        NEW.soil_report_required := TRUE;
        -- Fixed soil assessment / Schmidt concrete rebound hammer fee of 150,000 SYP
        NEW.soil_report_fee_syp := 150000.00;
    ELSE
        NEW.soil_report_required := FALSE;
        NEW.soil_report_fee_syp := 0.00;
    END IF;

    -- 6. Enforce locked total printing pool
    NEW.printing_pool_syp := 140000.00; -- Sum of printing matrix: 60k + 40k + 15k + 10k + 15k

    -- 7. Calculate client grand total bill
    NEW.client_invoice_total_syp := NEW.gross_study_fee_syp 
                                   + NEW.water_sanitary_fee_syp 
                                   + NEW.soil_report_fee_syp 
                                   + NEW.printing_pool_syp;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_model_3_invoice
BEFORE INSERT OR UPDATE OF project_type, is_permitted, permitted_area, extra_area, total_area, built_area ON model_3_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_3_invoice_calculations();


-- B. Automatically initialize the 5 standard engineering assignments for team selection
CREATE OR REPLACE FUNCTION fn_initialize_model_3_assignments()
RETURNS TRIGGER AS $$
DECLARE
    r_print RECORD;
BEGIN
    -- Core disciplines to auto-create upon project creation
    FOR r_print IN 
        SELECT discipline_code, printing_share_syp FROM printing_reimbursements
    LOOP
        INSERT INTO model_3_assignments (
            project_id, 
            discipline_code, 
            is_assigned, 
            printing_share_syp, 
            gross_fee_share_syp, 
            net_payout_calculated_syp
        ) VALUES (
            NEW.project_id,
            r_print.discipline_code,
            TRUE,
            r_print.printing_share_syp,
            0.00,
            r_print.printing_share_syp -- initial payout contains printing pool
        );
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_initialize_assignments_stub
AFTER INSERT ON model_3_projects
FOR EACH ROW
EXECUTE FUNCTION fn_initialize_model_3_assignments();


-- C. Automatically calculate the individual gross fees and net payouts whenever assignees are updated
CREATE OR REPLACE FUNCTION fn_process_assignment_calculations_update()
RETURNS TRIGGER AS $$
DECLARE
    v_gross_base NUMERIC(15, 2);
    v_share_pct NUMERIC(5, 4);
    v_calculated_gross NUMERIC(15, 2);
    v_k_factor NUMERIC(6, 4);
BEGIN
    -- Exit if no project associated
    IF NEW.engineer_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- 1. Fetch total Gross Study Fee
    SELECT gross_study_fee_syp INTO v_gross_base
    FROM model_3_projects
    WHERE project_id = NEW.project_id;

    -- 2. Map standard percentage splits across disciplines (CIV 46%, ARC 32%, ELE 11%, MCH 11%, WTR is flat)
    IF NEW.discipline_code = 'CIV' THEN
        v_share_pct := 0.4600;
        v_calculated_gross := v_gross_base * v_share_pct;
    ELSIF NEW.discipline_code = 'ARC' THEN
        v_share_pct := 0.3200;
        v_calculated_gross := v_gross_base * v_share_pct;
    ELSIF NEW.discipline_code = 'ELE' THEN
        v_share_pct := 0.1100;
        v_calculated_gross := v_gross_base * v_share_pct;
    ELSIF NEW.discipline_code = 'MCH' THEN
        v_share_pct := 0.1100;
        v_calculated_gross := v_gross_base * v_share_pct;
    ELSIF NEW.discipline_code = 'WTR' THEN
        -- Water/Sanitary is a flat/scalable footprint fee rather than a ratio of base study
        SELECT water_sanitary_fee_syp INTO v_calculated_gross
        FROM model_3_projects
        WHERE project_id = NEW.project_id;
    ELSE
        v_calculated_gross := 0.00;
    END IF;

    NEW.gross_fee_share_syp := v_calculated_gross;

    -- 3. Resolve historical attributes from registry if updated
    SELECT rank, fund_status INTO NEW.engineer_rank, NEW.engineer_status
    FROM engineers_registry
    WHERE engineer_id = NEW.engineer_id;

    -- 4. Check if coaching triggers apply (if engineer rank is Trainee: 'دراسة')
    IF NEW.engineer_rank = 'دراسة' THEN
        NEW.has_coach := TRUE;
    ELSE
        NEW.has_coach := FALSE;
    END IF;

    -- 5. Query O(1) K-Factor Lookup
    SELECT resolved_k_factor INTO v_k_factor
    FROM k_factor_matrix
    WHERE is_insider = (NEW.engineer_status = 'IN') AND has_coach = NEW.has_coach;

    NEW.resolved_k_factor := COALESCE(v_k_factor, 0.0000);

    -- 6. Execute direct payout calculus: Net = (Gross * K) + Printing
    NEW.net_payout_calculated_syp := ROUND((NEW.gross_fee_share_syp * NEW.resolved_k_factor) + NEW.printing_share_syp, 2);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_assignment_shares
BEFORE UPDATE OF engineer_id ON model_3_assignments
FOR EACH ROW
EXECUTE FUNCTION fn_process_assignment_calculations_update();


-- D. Automatically release locked payouts upon treasury settlement
CREATE OR REPLACE FUNCTION fn_process_model_3_settlement_payouts()
RETURNS TRIGGER AS $$
BEGIN
    -- Only trigger when project state changes to SETTLED
    IF OLD.lifecycle_state = 'INV' AND NEW.lifecycle_state = 'SETTLED' THEN
        
        -- 1. Unlocked cash escrow for assigned engineers
        UPDATE model_3_assignments
        SET payout_state = 'EARNED'
        WHERE project_id = NEW.project_id;

        -- 2. Log itemized deductions and payouts directly into Central Syndicate ledger
        INSERT INTO syndicate_contributions_db (
            project_id, receipt_no, branch, client_name, discipline_code,
            engineer_id, engineer_name, fund_status, gross_fee_syp,
            stage_1_unit_fee_syp, stage_2_audit_pool_syp, stage_3_fund_amount_syp,
            stage_4_coaching_fee_syp, stage_5_printing_allowance_syp,
            net_payout_disbursed_syp, combined_fund
        )
        SELECT 
            a.project_id,
            NEW.receipt_no,
            NEW.branch_code,
            NEW.client_name,
            a.discipline_code,
            a.engineer_id,
            a.engineer_name,
            a.engineer_status,
            a.gross_fee_share_syp,
            
            -- Deductions pipeline tracing using the static k-factor matrix rules
            (a.gross_fee_share_syp * k.stage_1_rate) AS stage_1_unit_fee_syp,
            (a.gross_fee_share_syp * k.stage_2_rate) AS stage_2_audit_pool_syp,
            (a.gross_fee_share_syp * k.stage_3_rate) AS stage_3_fund_amount_syp,
            (a.gross_fee_share_syp * k.stage_4_rate) AS stage_4_coaching_fee_syp,
            a.printing_share_syp,
            a.net_payout_calculated_syp,
            
            -- Assign to respective combined funds
            CASE 
                WHEN a.discipline_code IN ('CIV', 'ARC', 'WTR', 'GEO', 'GTK') THEN 'FUND_1_CIVIL_ARCH_WATER_GEO'::combined_fund_type
                ELSE 'FUND_2_ELEC_MECH'::combined_fund_type
            END AS combined_fund
        FROM model_3_assignments a
        JOIN k_factor_matrix k ON k.adapter_key = (
            CASE 
                WHEN a.engineer_status = 'IN' THEN 'IN'
                ELSE 'OU'
            END || 
            CASE 
                WHEN a.has_coach THEN 'CO'
                ELSE 'NO'
            END
        )
        WHERE a.project_id = NEW.project_id AND a.is_assigned = TRUE AND a.engineer_id IS NOT NULL;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Re-assign trg_release_escrow_on_settlement to use updated function with ignore-nulls
DROP TRIGGER IF EXISTS trg_release_escrow_on_settlement ON model_3_projects;
CREATE TRIGGER trg_release_escrow_on_settlement
AFTER UPDATE OF lifecycle_state ON model_3_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_3_settlement_payouts();


-- =========================================================================
-- 5. RECONCILIATION & REPORTING VIEW
-- =========================================================================

-- Consolidated view for verifying mathematical zero-discrepancy balance in real-time
CREATE OR REPLACE VIEW view_model_3_balance_verification AS
SELECT 
    p.project_id,
    p.client_name,
    p.client_invoice_total_syp AS client_billed_invoice,
    
    -- Sum of all net disbursements
    COALESCE(SUM(a.net_payout_calculated_syp), 0) AS total_net_disbursed_to_engineers,
    
    -- Sum of all Stage 2 design audit deductions
    COALESCE(SUM(a.gross_fee_share_syp * k.stage_2_rate), 0) AS total_auditor_pool_retention,
    
    -- Sum of all syndicate holdings (Stage 1 Unit + Stage 3 Fund + Stage 4 Coaching)
    COALESCE(SUM(
        (a.gross_fee_share_syp * k.stage_1_rate) + 
        (a.gross_fee_share_syp * k.stage_3_rate) + 
        (a.gross_fee_share_syp * k.stage_4_rate)
    ), 0) + p.soil_report_fee_syp AS total_syndicate_administrative_retentions,
    
    -- Mathematical Balance Verification Formula (Perfect balance matches zero)
    (
        p.client_invoice_total_syp - (
            COALESCE(SUM(a.net_payout_calculated_syp), 0) + 
            COALESCE(SUM(a.gross_fee_share_syp * k.stage_2_rate), 0) + 
            COALESCE(SUM(
                (a.gross_fee_share_syp * k.stage_1_rate) + 
                (a.gross_fee_share_syp * k.stage_3_rate) + 
                (a.gross_fee_share_syp * k.stage_4_rate)
            ), 0) + p.soil_report_fee_syp
        )
    ) AS reconciliation_discrepancy
FROM model_3_projects p
LEFT JOIN model_3_assignments a ON a.project_id = p.project_id AND a.is_assigned = TRUE
LEFT JOIN k_factor_matrix k ON k.adapter_key = (
    CASE 
        WHEN a.engineer_status = 'IN' THEN 'IN'
        ELSE 'OU'
    END || 
    CASE 
        WHEN a.has_coach THEN 'CO'
        ELSE 'NO'
    END
)
GROUP BY p.project_id, p.client_name, p.client_invoice_total_syp, p.soil_report_fee_syp;

-- COMMIT; (Commented out to run in single global transaction script)
-- =========================================================================
-- END OF DDL SCHEMA
-- =========================================================================

-- =========================================================================
-- END OF SOURCE FILE: model-3-schema-v4.sql
-- =========================================================================


-- =========================================================================
-- START OF SOURCE FILE: model-4-schema-v2.sql
-- =========================================================================

-- =========================================================================
-- DATABASE SCHEMA: Model 4 — Motive Power & Generators (MP - القوى المحركة والمولدات)
-- DBMS Target: PostgreSQL (Version 12+)
-- =========================================================================

-- BEGIN; (Commented out to run in single global transaction script)

-- =========================================================================
-- 1. EXTENSIONS & DOMAINS / CUSTOM TYPES (IF NOT EXISTS)
-- =========================================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'syndicate_branch_code') THEN
        CREATE TYPE syndicate_branch_code AS ENUM ('HAS', 'QAM', 'DER');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_lifecycle_state') THEN
        CREATE TYPE project_lifecycle_state AS ENUM ('INV', 'SETTLED');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'engineer_rank') THEN
        CREATE TYPE engineer_rank AS ENUM ('دراسة', 'ممارس', 'مبتدئ', 'تدريب', 'تدقيق', 'استشاري', 'eng', 'c1', 'متدرب', 'مشارك', 'تحت الاشراف');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'fund_subscription_status') THEN
        CREATE TYPE fund_subscription_status AS ENUM ('IN', 'OU');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'discipline_code') THEN
        CREATE TYPE discipline_code AS ENUM ('CIV', 'ARC', 'ELE', 'MCH', 'WTR', 'GEO', 'GTK');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'combined_fund_type') THEN
        CREATE TYPE combined_fund_type AS ENUM (
            'FUND_1_CIVIL_ARCH_WATER_GEO',
            'FUND_2_ELEC_MECH'
        );
    END IF;
END$$;

-- =========================================================================
-- 2. MASTER REFERENCE & STAF FACTOR TABLES
-- =========================================================================

-- A. Progressive Tier Bracket Calculators
CREATE OR REPLACE FUNCTION fn_calculate_motor_base(p_kw NUMERIC)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC := 0.00;
    v_rem NUMERIC := p_kw;
BEGIN
    IF p_kw <= 0 THEN
        RETURN 0.00;
    END IF;
    
    -- Tier 1: 0 to 22 kW (22 kW max) @ 12,000 SYP/kW
    IF v_rem <= 22 THEN
        v_total := v_total + (v_rem * 12000.00);
        v_rem := 0;
    ELSE
        v_total := v_total + (22 * 12000.00);
        v_rem := v_rem - 22;
    END IF;
    
    -- Tier 2: 23 to 45 kW (23 kW max) @ 10,000 SYP/kW
    IF v_rem > 0 THEN
        IF v_rem <= 23 THEN
            v_total := v_total + (v_rem * 10000.00);
            v_rem := 0;
        ELSE
            v_total := v_total + (23 * 10000.00);
            v_rem := v_rem - 23;
        END IF;
    END IF;
    
    -- Tier 3: 46 to 90 kW (45 kW max) @ 8,000 SYP/kW
    IF v_rem > 0 THEN
        IF v_rem <= 45 THEN
            v_total := v_total + (v_rem * 8000.00);
            v_rem := 0;
        ELSE
            v_total := v_total + (45 * 8000.00);
            v_rem := v_rem - 45;
        END IF;
    END IF;
    
    -- Tier 4: 91 to 200 kW (110 kW max) @ 6,000 SYP/kW
    IF v_rem > 0 THEN
        IF v_rem <= 110 THEN
            v_total := v_total + (v_rem * 6000.00);
            v_rem := 0;
        ELSE
            v_total := v_total + (110 * 6000.00);
            v_rem := v_rem - 110;
        END IF;
    END IF;
    
    -- Tier 5: > 200 kW (unlimited) @ 4,000 SYP/kW
    IF v_rem > 0 THEN
        v_total := v_total + (v_rem * 4000.00);
    END IF;
    
    RETURN ROUND(v_total, 2);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_calculate_generator_base(p_kva NUMERIC)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC := 0.00;
    v_rem NUMERIC := p_kva;
BEGIN
    IF p_kva <= 0 THEN
        RETURN 0.00;
    END IF;
    
    -- Tier 1: 0 to 30 kVA (30 kVA max) @ 5,000 SYP/kVA
    IF v_rem <= 30 THEN
        v_total := v_total + (v_rem * 5000.00);
        v_rem := 0;
    ELSE
        v_total := v_total + (30 * 5000.00);
        v_rem := v_rem - 30;
    END IF;
    
    -- Tier 2: 31 to 200 kVA (170 kVA max) @ 3,000 SYP/kVA
    IF v_rem > 0 THEN
        IF v_rem <= 170 THEN
            v_total := v_total + (v_rem * 3000.00);
            v_rem := 0;
        ELSE
            v_total := v_total + (170 * 3000.00);
            v_rem := v_rem - 170;
        END IF;
    END IF;
    
    -- Tier 3: > 200 kVA (unlimited) @ 2,000 SYP/kVA
    IF v_rem > 0 THEN
        v_total := v_total + (v_rem * 2000.00);
    END IF;
    
    RETURN ROUND(v_total, 2);
END;
$$ LANGUAGE plpgsql;


-- B. K-Factor Multiplier Matrix for Stateless Model 4 Net Calculation
-- Model 4 applies a 15% Chamber fee (Stage 1) and Fund Subscription VLOOKUP (Stage 2)
CREATE TABLE IF NOT EXISTS k_factor_matrix_model_4 (
    adapter_key VARCHAR(4) PRIMARY KEY, -- 'INNO', 'INCO', 'OUNO', 'OUCO'
    is_insider BOOLEAN NOT NULL,
    has_coach BOOLEAN NOT NULL,
    resolved_k_factor NUMERIC(6, 4) NOT NULL CHECK (resolved_k_factor BETWEEN 0.0000 AND 1.0000),
    stage_1_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.1500, -- 15% Chamber Fee
    stage_2_rate NUMERIC(5, 4) NOT NULL,                -- 25% (IN) or 10% (OU) on remaining 85%
    stage_3_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.0000, -- 15% on remaining if trainee, otherwise 0
    CONSTRAINT unique_flags_model_4 UNIQUE (is_insider, has_coach)
);

COMMENT ON TABLE k_factor_matrix_model_4 IS 'Collapsed O(1) stateless lookup table mapping fund membership and supervision status to Model 4 net payouts (15% Chamber fee)';

-- Populate static coefficients for Model 4
-- Formula: K = (1 - 0.15) * (1 - fund_rate) * (1 - coach_rate)
INSERT INTO k_factor_matrix_model_4 (adapter_key, is_insider, has_coach, resolved_k_factor, stage_2_rate, stage_3_rate) VALUES
('INNO', TRUE,  FALSE, 0.6375, 0.2125, 0.0000), -- Insider, No Coach (0.85 * 0.75 * 1.00 = 0.6375) (Stage 2 = 0.85 * 0.25 = 0.2125)
('INCO', TRUE,  TRUE,  0.5419, 0.2125, 0.0956), -- Insider, Coach (0.6375 * 0.85 = 0.541875 rounded to 0.5419)
('OUNO', FALSE, FALSE, 0.7650, 0.0850, 0.0000), -- Outsider, No Coach (0.85 * 0.90 * 1.00 = 0.7650) (Stage 2 = 0.85 * 0.10 = 0.0850)
('OUCO', FALSE, TRUE,  0.6503, 0.0850, 0.1148); -- Outsider, Coach (0.7650 * 0.85 = 0.65025 rounded to 0.6503)


-- =========================================================================
-- 3. CORE REGISTRY & TRANSACTION TABLES
-- =========================================================================

-- A. Engineers Core Registry (Unified database stub)
CREATE TABLE IF NOT EXISTS engineers_registry (
    engineer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    discipline discipline_code NOT NULL,
    role_qualification VARCHAR(150),
    rank engineer_rank NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    office_branch syndicate_branch_code,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- B. Model 4 Project Postings
CREATE TABLE IF NOT EXISTS model_4_projects (
    project_id VARCHAR(50) PRIMARY KEY, -- Alphanumeric linked code e.g. 'MP-HAS-2026-0001'
    client_name VARCHAR(150) NOT NULL,
    client_phone VARCHAR(50),
    zone_loc VARCHAR(100) NOT NULL,     -- Real estate zone (المنطقة العقارية)
    parcel_no VARCHAR(50) NOT NULL,     -- Parcel number (رقم المقسم)
    prop_no VARCHAR(50) NOT NULL,       -- Property ID (رقم العقار)
    branch_code syndicate_branch_code NOT NULL,
    facility_type VARCHAR(100) NOT NULL, -- Industrial, Pharmacy, Hospital, Private, etc.
    
    -- Technical Input Vector parameters
    power_kw NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (power_kw >= 0.00),
    gen_kva NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (gen_kva >= 0.00),
    reactive_kvar NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (reactive_kvar >= 0.00),
    active_usd_rate NUMERIC(12, 2) NOT NULL CHECK (active_usd_rate > 0.0),
    
    -- Computed Client-facing Totals
    motor_base_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    gen_base_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    reactive_base_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    
    mech_share_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    elec_share_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    client_invoice_total_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    
    -- Transaction Lifecycle fields
    lifecycle_state project_lifecycle_state NOT NULL DEFAULT 'INV',
    receipt_no VARCHAR(100) DEFAULT NULL, -- Verification Cash Receipt logged by branch cashier
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    settled_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    
    -- Validate that there is at least one active parameter to calculate
    CONSTRAINT check_positive_parameters CHECK (power_kw > 0.00 OR gen_kva > 0.00 OR reactive_kvar > 0.00),
    CONSTRAINT check_settlement_receipt_model_4 CHECK (
        (lifecycle_state = 'INV' AND receipt_no IS NULL AND settled_at IS NULL) OR
        (lifecycle_state = 'SETTLED' AND receipt_no IS NOT NULL AND settled_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_receipt_verification_model_4 ON model_4_projects (receipt_no) WHERE receipt_no IS NOT NULL;


-- C. Model 4 Engineering Discipline Assignments & Financial Split Breakdown
CREATE TABLE IF NOT EXISTS model_4_assignments (
    assignment_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL REFERENCES model_4_projects(project_id) ON DELETE CASCADE,
    discipline_code discipline_code NOT NULL CHECK (discipline_code IN ('ELE', 'MCH')),
    
    -- Assignee snapshot characteristics (locked at time of invoice creation/update)
    is_assigned BOOLEAN NOT NULL DEFAULT TRUE,
    engineer_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    engineer_name VARCHAR(150),
    engineer_status fund_subscription_status, -- IN / OU snapshot
    engineer_rank engineer_rank,               -- qualification snapshot
    
    -- Coaching parameters
    has_coach BOOLEAN NOT NULL DEFAULT FALSE,
    supervisor_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    supervisor_name VARCHAR(150),
    
    -- Financial ledger details (calculated per assignee)
    resolved_k_factor NUMERIC(6, 4) NOT NULL DEFAULT 0.0000,
    gross_fee_share_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (gross_fee_share_syp >= 0.0),
    net_payout_calculated_syp NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (net_payout_calculated_syp >= 0.0),
    
    -- Dynamic Escrow constraint
    payout_state VARCHAR(20) NOT NULL DEFAULT 'HELD' CHECK (payout_state IN ('HELD', 'EARNED')),
    
    -- Ensure same discipline isn't assigned twice on the same project
    CONSTRAINT unique_project_discipline_model_4 UNIQUE (project_id, discipline_code)
);

CREATE INDEX IF NOT EXISTS idx_assignments_project_model_4 ON model_4_assignments(project_id);


-- D. Central Syndicate Ledger DB for Audit & Contributions Verification (Model 4 Logs)
CREATE TABLE IF NOT EXISTS model_4_syndicate_contributions (
    record_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL,
    receipt_no VARCHAR(100) NOT NULL,
    branch syndicate_branch_code NOT NULL,
    model_type VARCHAR(10) NOT NULL DEFAULT 'MP',
    client_name VARCHAR(150) NOT NULL,
    discipline_code discipline_code NOT NULL,
    engineer_id VARCHAR(50) NOT NULL,
    engineer_name VARCHAR(150) NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    
    -- Deductions itemization breakdown
    gross_fee_syp NUMERIC(15, 2) NOT NULL,
    stage_1_chamber_fee_syp NUMERIC(15, 2) NOT NULL, -- 15% Chamber fee
    stage_2_fund_amount_syp NUMERIC(15, 2) NOT NULL, -- 25% Insider / 10% Outsider on remaining 85%
    stage_3_coaching_fee_syp NUMERIC(15, 2) NOT NULL, -- 15% if rank Trainee on remaining
    net_payout_disbursed_syp NUMERIC(15, 2) NOT NULL,
    
    -- Compound Syndicate Fund destination
    combined_fund combined_fund_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================================
-- 4. BUSINESS LOGIC DATABASE TRIGGERS & FUNCTIONS
-- =========================================================================

-- A. Automated Invoice Calculations for the progressive tiered brackets
CREATE OR REPLACE FUNCTION fn_process_model_4_invoice_calculations()
RETURNS TRIGGER AS $$
BEGIN
    -- 1. Calculate progressive Active Power (Motor) base
    NEW.motor_base_syp := fn_calculate_motor_base(NEW.power_kw);

    -- 2. Calculate progressive Generator Set base
    NEW.gen_base_syp := fn_calculate_generator_base(NEW.gen_kva);

    -- 3. Calculate flat Reactive Power fee (1,500 SYP per kVAR)
    NEW.reactive_base_syp := ROUND(NEW.reactive_kvar * 1500.00, 2);

    -- 4. Mechanical Share: Motor_Base + Gen_Base (Drives Mech work twice)
    NEW.mech_share_syp := NEW.motor_base_syp + NEW.gen_base_syp;

    -- 5. Electrical Share: Motor_Base + Gen_Base + Reactive_Base
    NEW.elec_share_syp := NEW.motor_base_syp + NEW.gen_base_syp + NEW.reactive_base_syp;

    -- 6. Total client invoice is the sum of both discipline portions
    NEW.client_invoice_total_syp := NEW.mech_share_syp + NEW.elec_share_syp;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_model_4_invoice
BEFORE INSERT OR UPDATE OF power_kw, gen_kva, reactive_kvar ON model_4_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_4_invoice_calculations();


-- B. Automatically initialize the 2 standard engineering assignments (MCH & ELE)
CREATE OR REPLACE FUNCTION fn_initialize_model_4_assignments()
RETURNS TRIGGER AS $$
BEGIN
    -- Create Electrical stub
    INSERT INTO model_4_assignments (project_id, discipline_code, is_assigned, gross_fee_share_syp, net_payout_calculated_syp)
    VALUES (NEW.project_id, 'ELE', TRUE, 0.00, 0.00);

    -- Create Mechanical stub
    INSERT INTO model_4_assignments (project_id, discipline_code, is_assigned, gross_fee_share_syp, net_payout_calculated_syp)
    VALUES (NEW.project_id, 'MCH', TRUE, 0.00, 0.00);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_initialize_assignments_stub_model_4
AFTER INSERT ON model_4_projects
FOR EACH ROW
EXECUTE FUNCTION fn_initialize_model_4_assignments();


-- C. Automatically calculate individual gross fees and net payouts when assignees are updated
CREATE OR REPLACE FUNCTION fn_process_model_4_assignment_updates()
RETURNS TRIGGER AS $$
DECLARE
    v_gross_share NUMERIC(15, 2);
    v_k_factor NUMERIC(6, 4);
BEGIN
    -- Exit if no engineer is assigned yet
    IF NEW.engineer_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- 1. Fetch the computed gross discipline share from the project
    IF NEW.discipline_code = 'MCH' THEN
        SELECT mech_share_syp INTO v_gross_share
        FROM model_4_projects
        WHERE project_id = NEW.project_id;
    ELSIF NEW.discipline_code = 'ELE' THEN
        SELECT elec_share_syp INTO v_gross_share
        FROM model_4_projects
        WHERE project_id = NEW.project_id;
    ELSE
        v_gross_share := 0.00;
    END IF;

    NEW.gross_fee_share_syp := v_gross_share;

    -- 2. Resolve engineer qualification rank and membership fund status from core registry
    SELECT rank, fund_status INTO NEW.engineer_rank, NEW.engineer_status
    FROM engineers_registry
    WHERE engineer_id = NEW.engineer_id;

    -- 3. Validation: Enforce that only qualified engineers (Practitioner 'ممارس' or higher) can execute Model 4
    -- Trainee 'دراسة' rank is allowed but triggers mandatory coaching
    IF NEW.engineer_rank = 'دراسة' THEN
        NEW.has_coach := TRUE;
    ELSE
        NEW.has_coach := FALSE;
    END IF;

    -- 4. Exclusion Pool Validation: Ensure no engineer holds both ELE and MCH assignments on the same project
    IF EXISTS (
        SELECT 1 
        FROM model_4_assignments 
        WHERE project_id = NEW.project_id 
          AND discipline_code != NEW.discipline_code 
          AND engineer_id = NEW.engineer_id
    ) THEN
        RAISE EXCEPTION '⚠ قاعدة استبعاد التضارب: لا يجوز إسناد تخصصين مختلفين لنفس المهندس في المعاملة ذاتها';
    END IF;

    -- 5. Query the static stateless K-factor look-up multiplier
    SELECT resolved_k_factor INTO v_k_factor
    FROM k_factor_matrix_model_4
    WHERE is_insider = (NEW.engineer_status = 'IN') AND has_coach = NEW.has_coach;

    NEW.resolved_k_factor := COALESCE(v_k_factor, 0.0000);

    -- 6. Direct payout calculation: Net = Gross * K
    NEW.net_payout_calculated_syp := ROUND(NEW.gross_fee_share_syp * NEW.resolved_k_factor, 2);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_assignment_shares_model_4
BEFORE UPDATE OF engineer_id ON model_4_assignments
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_4_assignment_updates();


-- D. Automatically release locked payouts upon cashier settlement
CREATE OR REPLACE FUNCTION fn_process_model_4_settlement_payouts()
RETURNS TRIGGER AS $$
BEGIN
    -- Only trigger when project state changes from INV (invoice) to SETTLED
    IF OLD.lifecycle_state = 'INV' AND NEW.lifecycle_state = 'SETTLED' THEN
        
        -- 1. Clear cash escrow and mark payouts as EARNED
        UPDATE model_4_assignments
        SET payout_state = 'EARNED'
        WHERE project_id = NEW.project_id;

        -- 2. Log transaction records directly into the central contributions ledger
        INSERT INTO model_4_syndicate_contributions (
            project_id, receipt_no, branch, client_name, discipline_code,
            engineer_id, engineer_name, fund_status, gross_fee_syp,
            stage_1_chamber_fee_syp, stage_2_fund_amount_syp, stage_3_coaching_fee_syp,
            net_payout_disbursed_syp, combined_fund
        )
        SELECT 
            a.project_id,
            NEW.receipt_no,
            NEW.branch_code,
            NEW.client_name,
            a.discipline_code,
            a.engineer_id,
            a.engineer_name,
            a.engineer_status,
            a.gross_fee_share_syp,
            
            -- Tracing the sequential deduction pipeline percentages
            (a.gross_fee_share_syp * k.stage_1_rate) AS stage_1_chamber_fee_syp,
            (a.gross_fee_share_syp * k.stage_2_rate) AS stage_2_fund_amount_syp,
            (a.gross_fee_share_syp * k.stage_3_rate) AS stage_3_coaching_fee_syp,
            a.net_payout_calculated_syp,
            
            -- Route to electro-mechanical combined funds
            'FUND_2_ELEC_MECH'::combined_fund_type AS combined_fund
        FROM model_4_assignments a
        JOIN k_factor_matrix_model_4 k ON k.adapter_key = (
            CASE WHEN a.engineer_status = 'IN' THEN 'IN' ELSE 'OU' END ||
            CASE WHEN a.has_coach THEN 'CO' ELSE 'NO' END
        )
        WHERE a.project_id = NEW.project_id AND a.is_assigned = TRUE AND a.engineer_id IS NOT NULL;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_release_escrow_on_settlement_model_4
AFTER UPDATE OF lifecycle_state ON model_4_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_4_settlement_payouts();


-- =========================================================================
-- 5. RECONCILIATION & AUDIT LAYER
-- =========================================================================

-- Verification view ensuring zero-discrepancy balance across Model 4 transactions
CREATE OR REPLACE VIEW view_model_4_balance_verification AS
SELECT 
    p.project_id,
    p.client_name,
    p.client_invoice_total_syp AS client_invoice_total,
    
    -- Total net payouts disbursed
    COALESCE(SUM(a.net_payout_calculated_syp), 0) AS total_disbursed_to_engineers,
    
    -- Total 15% Syndicate Chamber fees retained
    COALESCE(SUM(a.gross_fee_share_syp * k.stage_1_rate), 0) AS total_chamber_fee_retained,
    
    -- Total joint fund deposits (Stage 2 Fund + Stage 3 Coaching)
    COALESCE(SUM(
        (a.gross_fee_share_syp * k.stage_2_rate) +
        (a.gross_fee_share_syp * k.stage_3_rate)
    ), 0) AS total_syndicate_fund_deposits,
    
    -- Perfect Balance Identity Check (Discrepancy must equal 0.00)
    (
        p.client_invoice_total_syp - (
            COALESCE(SUM(a.net_payout_calculated_syp), 0) +
            COALESCE(SUM(a.gross_fee_share_syp * k.stage_1_rate), 0) +
            COALESCE(SUM(
                (a.gross_fee_share_syp * k.stage_2_rate) +
                (a.gross_fee_share_syp * k.stage_3_rate)
            ), 0)
        )
    ) AS reconciliation_discrepancy
FROM model_4_projects p
LEFT JOIN model_4_assignments a ON a.project_id = p.project_id AND a.is_assigned = TRUE
LEFT JOIN k_factor_matrix_model_4 k ON k.adapter_key = (
    CASE WHEN a.engineer_status = 'IN' THEN 'IN' ELSE 'OU' END ||
    CASE WHEN a.has_coach THEN 'CO' ELSE 'NO' END
)
GROUP BY p.project_id, p.client_name, p.client_invoice_total_syp;

-- COMMIT; (Commented out to run in single global transaction script)
-- =========================================================================
-- END OF DDL SCHEMA
-- =========================================================================

-- =========================================================================
-- END OF SOURCE FILE: model-4-schema-v2.sql
-- =========================================================================


-- =========================================================================
-- START OF SOURCE FILE: model-5-schema-v5.sql
-- =========================================================================

-- =========================================================================
-- DATABASE SCHEMA: Model 5 — Bayani Study Model (BS - نموذج البيان الفني والمنشآت الصحية والتجارية)
-- VERSION: v2 (Corrected: Removed Audit / Auditing Fee Stage)
-- DBMS Target: PostgreSQL (Version 12+)
-- =========================================================================

-- BEGIN; (Commented out to run in single global transaction script)

-- =========================================================================
-- 1. EXTENSIONS & DOMAINS / CUSTOM TYPES
-- =========================================================================

-- Note: Enums are created conditionally to prevent collisions when running multiple schemas
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'syndicate_branch_code') THEN
        CREATE TYPE syndicate_branch_code AS ENUM ('HAS', 'QAM', 'DER');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_lifecycle_state') THEN
        CREATE TYPE project_lifecycle_state AS ENUM ('INV', 'SETTLED');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'engineer_rank') THEN
        CREATE TYPE engineer_rank AS ENUM ('دراسة', 'ممارس', 'مبتدئ', 'تدريب', 'تدقيق', 'استشاري', 'eng', 'c1', 'متدرب', 'مشارك', 'تحت الاشراف');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'fund_subscription_status') THEN
        CREATE TYPE fund_subscription_status AS ENUM ('IN', 'OU');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'discipline_code') THEN
        CREATE TYPE discipline_code AS ENUM ('CIV', 'ARC', 'ELE', 'MCH', 'WTR', 'GEO', 'GTK');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'combined_fund_type') THEN
        CREATE TYPE combined_fund_type AS ENUM (
            'FUND_1_CIVIL_ARCH_WATER_GEO',
            'FUND_2_ELEC_MECH'
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'facility_type_model_5') THEN
        CREATE TYPE facility_type_model_5 AS ENUM (
            'صيدلية',
            'مركز تجميل',
            'مستودع أدوية',
            'عيادة طبية',
            'مخبر طبي',
            'مشفى'
        );
    END IF;
END $$;

-- =========================================================================
-- 2. MASTER REFERENCE TABLES
-- =========================================================================

-- A. Pricing Reference Configuration (USD)
CREATE TABLE IF NOT EXISTS model_5_config (
    config_key VARCHAR(50) PRIMARY KEY,
    config_value NUMERIC(12, 2) NOT NULL,
    description TEXT
);

COMMENT ON TABLE model_5_config IS 'Master pricing reference configuration for Model 5 (BS)';

-- Populate Model 5 Config
INSERT INTO model_5_config (config_key, config_value, description) VALUES
('BASE_RATE_PER_UNIT_USD', 80.00, 'Flat USD rate charged per 50 m² discrete unit'),
('FLAT_PRINTING_SURCHARGE_USD', 10.00, 'Flat printing and copies allowance added to client invoice and reimbursed to engineers'),
('UNIT_SIZE_M2', 50.00, 'Discrete unit size in square meters for pro-rata ceiling calculation');


-- B. K-Factor Multiplier Matrix for Stateless Net Calculation (Model 5 - sd = 10%, no ad)
CREATE TABLE IF NOT EXISTS k_factor_matrix_model_5 (
    adapter_key VARCHAR(4) PRIMARY KEY,
    is_insider BOOLEAN NOT NULL,
    has_coach BOOLEAN NOT NULL,
    resolved_k_factor NUMERIC(6, 4) NOT NULL CHECK (resolved_k_factor BETWEEN 0.0000 AND 1.0000),
    stage_1_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.1000,
    stage_2_rate NUMERIC(5, 4) NOT NULL,
    stage_3_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.0000,
    CONSTRAINT unique_flags_model_5 UNIQUE (is_insider, has_coach)
);

COMMENT ON TABLE k_factor_matrix_model_5 IS 'Collapsed O(1) stateless lookup table mapping fund membership and supervision status to final net payouts for Model 5 (No Audit)';

-- Populate static K-factor coefficients for Model 5 (Corrected: No Audit)
-- K = (1 - 0.10) * (1 - r_fund) * (1 - r_coach)
INSERT INTO k_factor_matrix_model_5 (adapter_key, is_insider, has_coach, resolved_k_factor, stage_2_rate, stage_3_rate) VALUES
('INNO', TRUE,  FALSE, 0.6750, 0.2250, 0.0000),
('INCO', TRUE,  TRUE,  0.5738, 0.2250, 0.1013),
('OUNO', FALSE, FALSE, 0.8100, 0.0900, 0.0000),
('OUCO', FALSE, TRUE,  0.6885, 0.0900, 0.1215);


-- C. Standard Printing Allowances Matrix for Model 5 ($10.00 pool)
CREATE TABLE IF NOT EXISTS printing_reimbursements_model_5 (
    discipline_code discipline_code PRIMARY KEY,
    printing_share_usd NUMERIC(6, 2) NOT NULL CHECK (printing_share_usd >= 0.0)
);

COMMENT ON TABLE printing_reimbursements_model_5 IS 'Standard blueprint layout printing pool allocation per specialty for Model 5 (BS) ($10 pool)';

-- Populate Model 5 Printing Allowances (50/25/25 split of $10.00)
INSERT INTO printing_reimbursements_model_5 (discipline_code, printing_share_usd) VALUES
('ARC', 5.00),
('MCH', 2.50),
('ELE', 2.50);


-- =========================================================================
-- 3. CORE REGISTRY & TRANSACTION TABLES
-- =========================================================================

-- A. Engineers Core Registry (Unified database link)
CREATE TABLE IF NOT EXISTS engineers_registry (
    engineer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    discipline discipline_code NOT NULL,
    role_qualification VARCHAR(150),
    rank engineer_rank NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    office_branch syndicate_branch_code,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- B. Model 5 Project Postings
CREATE TABLE IF NOT EXISTS model_5_projects (
    project_id VARCHAR(50) PRIMARY KEY,
    client_name VARCHAR(150) NOT NULL,
    client_phone VARCHAR(50),
    zone_loc VARCHAR(100) NOT NULL,
    parcel_no VARCHAR(50) NOT NULL,
    prop_no VARCHAR(50) NOT NULL,
    branch_code syndicate_branch_code NOT NULL,
    facility_type facility_type_model_5 NOT NULL,
    
    -- Technical Input Vector parameters
    total_area NUMERIC(12, 2) NOT NULL CHECK (total_area > 0.0),
    active_usd_rate NUMERIC(12, 2) NOT NULL CHECK (active_usd_rate > 0.0),
    
    -- Computed Client-facing Totals (in USD)
    calculated_units INTEGER NOT NULL DEFAULT 0 CHECK (calculated_units >= 1),
    base_study_fee_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    printing_pool_usd NUMERIC(12, 2) NOT NULL DEFAULT 10.00,
    client_invoice_total_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    
    -- Transaction Lifecycle fields
    lifecycle_state project_lifecycle_state NOT NULL DEFAULT 'INV',
    receipt_no VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    settled_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    
    CONSTRAINT check_settlement_receipt_model_5 CHECK (
        (lifecycle_state = 'INV' AND receipt_no IS NULL AND settled_at IS NULL) OR
        (lifecycle_state = 'SETTLED' AND receipt_no IS NOT NULL AND settled_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_receipt_verification_model_5 ON model_5_projects (receipt_no) WHERE receipt_no IS NOT NULL;


-- C. Model 5 Engineering Discipline Assignments & Financial Split Breakdown
CREATE TABLE IF NOT EXISTS model_5_assignments (
    assignment_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL REFERENCES model_5_projects(project_id) ON DELETE CASCADE,
    discipline_code discipline_code NOT NULL CHECK (discipline_code IN ('ARC', 'MCH', 'ELE')),
    
    -- Assignee snapshot characteristics (locked at time of invoice creation/update)
    is_assigned BOOLEAN NOT NULL DEFAULT TRUE,
    engineer_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    engineer_name VARCHAR(150),
    engineer_status fund_subscription_status,
    engineer_rank engineer_rank,
    
    -- Coaching parameters
    has_coach BOOLEAN NOT NULL DEFAULT FALSE,
    supervisor_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    supervisor_name VARCHAR(150),
    
    -- Financial ledger details in USD (calculated per assignee)
    resolved_k_factor NUMERIC(6, 4) NOT NULL DEFAULT 0.0000,
    gross_fee_share_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (gross_fee_share_usd >= 0.0),
    printing_share_usd NUMERIC(6, 2) NOT NULL DEFAULT 0.00 CHECK (printing_share_usd >= 0.0),
    net_payout_calculated_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (net_payout_calculated_usd >= 0.0),
    
    -- Dynamic Escrow constraint
    payout_state VARCHAR(20) NOT NULL DEFAULT 'HELD' CHECK (payout_state IN ('HELD', 'EARNED')),
    
    -- Ensure same discipline isn't assigned twice on the same project
    CONSTRAINT unique_project_discipline_model_5 UNIQUE (project_id, discipline_code)
);

CREATE INDEX IF NOT EXISTS idx_assignments_project_model_5 ON model_5_assignments(project_id);


-- D. Central Syndicate Ledger DB for Contributions Verification (Model 5 - BS)
CREATE TABLE IF NOT EXISTS model_5_syndicate_contributions (
    record_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL,
    receipt_no VARCHAR(100) NOT NULL,
    branch syndicate_branch_code NOT NULL,
    model_type VARCHAR(10) NOT NULL DEFAULT 'BS',
    client_name VARCHAR(150) NOT NULL,
    discipline_code discipline_code NOT NULL,
    engineer_id VARCHAR(50) NOT NULL,
    engineer_name VARCHAR(150) NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    
    -- Deductions itemization breakdown (USD)
    gross_fee_usd NUMERIC(12, 2) NOT NULL,
    stage_1_unit_fee_usd NUMERIC(12, 2) NOT NULL,
    stage_2_fund_amount_usd NUMERIC(12, 2) NOT NULL,
    stage_3_coaching_fee_usd NUMERIC(12, 2) NOT NULL,
    stage_4_printing_allowance_usd NUMERIC(6, 2) NOT NULL,
    net_payout_disbursed_usd NUMERIC(12, 2) NOT NULL,
    
    -- Compound Syndicate Fund destination
    combined_fund combined_fund_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================================
-- 4. BUSINESS LOGIC DATABASE TRIGGERS & FUNCTIONS
-- =========================================================================

-- A. Automated Invoice Calculations for Model 5
CREATE OR REPLACE FUNCTION fn_process_model_5_invoice_calculations()
RETURNS TRIGGER AS $$
DECLARE
    v_base_rate_usd NUMERIC(12, 2);
    v_printing_fee_usd NUMERIC(12, 2);
    v_unit_size NUMERIC(12, 2);
BEGIN
    -- Fetch active master configs
    SELECT config_value INTO v_base_rate_usd FROM model_5_config WHERE config_key = 'BASE_RATE_PER_UNIT_USD';
    SELECT config_value INTO v_printing_fee_usd FROM model_5_config WHERE config_key = 'FLAT_PRINTING_SURCHARGE_USD';
    SELECT config_value INTO v_unit_size FROM model_5_config WHERE config_key = 'UNIT_SIZE_M2';

    -- 1. Calculate base fee and units based on facility type categories
    IF NEW.facility_type IN ('صيدلية', 'عيادة طبية', 'مخبر طبي') THEN
        -- Category 1: Rounded-up units of 50 m², $80.00 per unit
        NEW.calculated_units := CEILING(NEW.total_area / v_unit_size);
        NEW.base_study_fee_usd := NEW.calculated_units * v_base_rate_usd;
        
    ELSIF NEW.facility_type IN ('مركز تجميل', 'مستودع أدوية') THEN
        -- Category 2: $80.00 for the first 50 m² + $0.10 per additional square meter (No Rounding!)
        NEW.calculated_units := 1;
        IF NEW.total_area <= v_unit_size THEN
            NEW.base_study_fee_usd := v_base_rate_usd;
        ELSE
            NEW.base_study_fee_usd := v_base_rate_usd + ((NEW.total_area - v_unit_size) * 0.10);
        END IF;
        
    ELSIF NEW.facility_type = 'مشفى' THEN
        -- Category 3: Flat $0.50 per square meter directly on total area (No Rounding!)
        NEW.calculated_units := 1;
        NEW.base_study_fee_usd := NEW.total_area * 0.50;
    ELSE
        -- Fallback default
        NEW.calculated_units := CEILING(NEW.total_area / v_unit_size);
        NEW.base_study_fee_usd := NEW.calculated_units * v_base_rate_usd;
    END IF;

    -- 2. Printing Surcharge Settle: flat 10.00
    NEW.printing_pool_usd := v_printing_fee_usd;
    
    -- 3. Calculate total client bill in USD
    NEW.client_invoice_total_usd := NEW.base_study_fee_usd + NEW.printing_pool_usd;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_model_5_invoice
BEFORE INSERT OR UPDATE OF total_area ON model_5_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_5_invoice_calculations();


-- B. Automatically initialize the 3 standard engineering assignments for team selection
CREATE OR REPLACE FUNCTION fn_initialize_model_5_assignments()
RETURNS TRIGGER AS $$
DECLARE
    r_print RECORD;
BEGIN
    -- Core specialties for Bayani Study: Architecture, Mechanical, Electrical
    FOR r_print IN 
        SELECT discipline_code, printing_share_usd FROM printing_reimbursements_model_5
    LOOP
        INSERT INTO model_5_assignments (
            project_id, 
            discipline_code, 
            is_assigned, 
            printing_share_usd, 
            gross_fee_share_usd, 
            net_payout_calculated_usd
        ) VALUES (
            NEW.project_id,
            r_print.discipline_code,
            TRUE,
            r_print.printing_share_usd,
            0.00,
            r_print.printing_share_usd
        );
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_initialize_assignments_stub_model_5
AFTER INSERT ON model_5_projects
FOR EACH ROW
EXECUTE FUNCTION fn_initialize_model_5_assignments();


-- C. Automatically calculate individual gross fees and net payouts when engineers are updated
CREATE OR REPLACE FUNCTION fn_process_assignment_calculations_update_model_5()
RETURNS TRIGGER AS $$
DECLARE
    v_base_fee_usd NUMERIC(12, 2);
    v_share_pct NUMERIC(5, 4);
    v_calculated_gross NUMERIC(12, 2);
    v_k_factor NUMERIC(6, 4);
    v_facility_type VARCHAR(100);
BEGIN
    -- Exit if no engineer is assigned yet
    IF NEW.engineer_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- 1. Fetch total project Base Study Fee and facility type
    SELECT base_study_fee_usd, facility_type INTO v_base_fee_usd, v_facility_type
    FROM model_5_projects
    WHERE project_id = NEW.project_id;

    -- 2. Map percentage splits dynamically based on facility type categories
    -- Architecture/Mechanical/Electrical splits
    -- Category 1 & 3: Arch 50%, Mechanical 25%, Electrical 25%
    -- Category 2: Arch 60%, Electrical 40%, Mechanical 0%
    IF v_facility_type IN ('مركز تجميل', 'مستودع أدوية') THEN
        -- Category 2 Splits: ARC 60%, ELE 40%, MCH 0%
        IF NEW.discipline_code = 'ARC' THEN
            v_share_pct := 0.6000;
        ELSIF NEW.discipline_code = 'ELE' THEN
            v_share_pct := 0.4000;
        ELSE
            v_share_pct := 0.0000;
        END IF;
    ELSE
        -- Category 1 & 3 Splits: ARC 50%, MCH 25%, ELE 25%
        IF NEW.discipline_code = 'ARC' THEN
            v_share_pct := 0.5000;
        ELSIF NEW.discipline_code IN ('MCH', 'ELE') THEN
            v_share_pct := 0.2500;
        ELSE
            v_share_pct := 0.0000;
        END IF;
    END IF;

    NEW.gross_fee_share_usd := v_base_fee_usd * v_share_pct;

    -- 3. Resolve historical credentials from registry
    SELECT rank, fund_status INTO NEW.engineer_rank, NEW.engineer_status
    FROM engineers_registry
    WHERE engineer_id = NEW.engineer_id;

    -- 4. Check if coaching is active (Trainee 'دراسة' rank requires supervisor)
    IF NEW.engineer_rank = 'دراسة' THEN
        NEW.has_coach := TRUE;
    ELSE
        NEW.has_coach := FALSE;
    END IF;

    -- 5. Query O(1) stateless K-Factor lookup
    SELECT resolved_k_factor INTO v_k_factor
    FROM k_factor_matrix_model_5
    WHERE is_insider = (NEW.engineer_status = 'IN') AND has_coach = NEW.has_coach;

    NEW.resolved_k_factor := COALESCE(v_k_factor, 0.0000);

    -- 6. Direct payout calculation: Net = (Gross * K) + Printing
    NEW.net_payout_calculated_usd := ROUND((NEW.gross_fee_share_usd * NEW.resolved_k_factor) + NEW.printing_share_usd, 2);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_assignment_shares_model_5
BEFORE UPDATE OF engineer_id ON model_5_assignments
FOR EACH ROW
EXECUTE FUNCTION fn_process_assignment_calculations_update_model_5();


-- D. Automatically release locked payouts upon treasury settlement
CREATE OR REPLACE FUNCTION fn_process_model_5_settlement_payouts()
RETURNS TRIGGER AS $$
DECLARE
    r_assign RECORD;
BEGIN
    -- Only trigger when project state transitions to SETTLED
    IF OLD.lifecycle_state = 'INV' AND NEW.lifecycle_state = 'SETTLED' THEN
        
        -- 1. Unlocked cash escrow for assigned engineers
        UPDATE model_5_assignments
        SET payout_state = 'EARNED'
        WHERE project_id = NEW.project_id;

        -- 2. Log itemized deductions and payouts directly into Central Syndicate ledger (Model 5)
        FOR r_assign IN 
            SELECT 
                a.discipline_code, a.engineer_id, a.engineer_name, a.engineer_status,
                a.gross_fee_share_usd, a.printing_share_usd, a.net_payout_calculated_usd, a.has_coach,
                k.stage_1_rate, k.stage_2_rate, k.stage_3_rate
            FROM model_5_assignments a
            JOIN k_factor_matrix_model_5 k ON k.adapter_key = (
                CASE WHEN a.engineer_status = 'IN' THEN 'IN' ELSE 'OU' END || 
                CASE WHEN a.has_coach THEN 'CO' ELSE 'NO' END
            )
            WHERE a.project_id = NEW.project_id AND a.is_assigned = TRUE AND a.engineer_id IS NOT NULL
        LOOP
            -- Log transaction trace
            INSERT INTO model_5_syndicate_contributions (
                project_id, receipt_no, branch, client_name, discipline_code,
                engineer_id, engineer_name, fund_status, gross_fee_usd,
                stage_1_unit_fee_usd, stage_2_fund_amount_usd,
                stage_3_coaching_fee_usd, stage_4_printing_allowance_usd,
                net_payout_disbursed_usd, combined_fund
            ) VALUES (
                NEW.project_id,
                NEW.receipt_no,
                NEW.branch_code,
                NEW.client_name,
                r_assign.discipline_code,
                r_assign.engineer_id,
                r_assign.engineer_name,
                r_assign.engineer_status,
                r_assign.gross_fee_share_usd,
                
                -- Deductions pipeline tracing using the static lookup rules
                (r_assign.gross_fee_share_usd * r_assign.stage_1_rate),
                (r_assign.gross_fee_share_usd * r_assign.stage_2_rate),
                (r_assign.gross_fee_share_usd * r_assign.stage_3_rate),
                r_assign.printing_share_usd,
                r_assign.net_payout_calculated_usd,
                
                -- Assign to combined funds (ARC goes to Fund 1, ELE & MCH go to Fund 2)
                CASE 
                    WHEN r_assign.discipline_code = 'ARC' THEN 'FUND_1_CIVIL_ARCH_WATER_GEO'::combined_fund_type
                    ELSE 'FUND_2_ELEC_MECH'::combined_fund_type
                END
            );
        END LOOP;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_release_escrow_on_settlement_model_5
AFTER UPDATE OF lifecycle_state ON model_5_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_5_settlement_payouts();


-- =========================================================================
-- 5. RECONCILIATION & REPORTING VIEW (BS-RPT PERFECT MATCH VIEW)
-- =========================================================================

-- Consolidated verification view for Model 5 ensuring zero-discrepancy balance in USD
CREATE OR REPLACE VIEW view_model_5_balance_verification AS
SELECT 
    p.project_id,
    p.client_name,
    p.client_invoice_total_usd AS client_billed_invoice_usd,
    
    -- Sum of all net payouts disbursed to study engineers
    COALESCE(SUM(a.net_payout_calculated_usd), 0) AS total_net_disbursed_to_engineers_usd,
    
    -- Sum of all syndicate holdings (Stage 1 Unit Fee + Stage 2 Fund Retention + Stage 3 Coaching)
    COALESCE(SUM(
        (a.gross_fee_share_usd * k.stage_1_rate) + 
        (a.gross_fee_share_usd * k.stage_2_rate) + 
        (a.gross_fee_share_usd * k.stage_3_rate)
    ), 0) AS total_syndicate_retained_usd,
    
    -- Master Balance Matching formula (Grand discrepancy must always verify to 0.00)
    ROUND(
        p.client_invoice_total_usd - (
            COALESCE(SUM(a.net_payout_calculated_usd), 0) + 
            COALESCE(SUM(
                (a.gross_fee_share_usd * k.stage_1_rate) + 
                (a.gross_fee_share_usd * k.stage_2_rate) + 
                (a.gross_fee_share_usd * k.stage_3_rate)
            ), 0)
        ), 2
    ) AS reconciliation_discrepancy_usd
FROM model_5_projects p
LEFT JOIN model_5_assignments a ON a.project_id = p.project_id AND a.is_assigned = TRUE
LEFT JOIN k_factor_matrix_model_5 k ON k.adapter_key = (
    CASE WHEN a.engineer_status = 'IN' THEN 'IN' ELSE 'OU' END || 
    CASE WHEN a.has_coach THEN 'CO' ELSE 'NO' END
)
GROUP BY p.project_id, p.client_name, p.client_invoice_total_usd;

-- COMMIT; (Commented out to run in single global transaction script)
-- =========================================================================
-- END OF DDL SCHEMA
-- =========================================================================

-- =========================================================================
-- END OF SOURCE FILE: model-5-schema-v5.sql
-- =========================================================================


-- =========================================================================
-- START OF SOURCE FILE: model-6-schema-v3.sql
-- =========================================================================

-- =========================================================================
-- DATABASE SCHEMA: Model 6 — Supervision Contract (SC - عقد الإشراف الهندسي)
-- DBMS Target: PostgreSQL (Version 12+)
-- Description: STANDALONE, trigger-automated SQL schema for Model 6 (SC).
--              Handles ongoing site supervision, land vs built area rules,
--              7.5% Syndicate Unit fee, 25%/10% VLOOKUP funds, and 15% coaching
--              triggers. Outlines perfect-match ledger reconciliation.
-- =========================================================================

-- BEGIN; (Commented out to run in single global transaction script)

-- =========================================================================
-- 1. EXTENSIONS & DOMAINS / CUSTOM TYPES
-- =========================================================================

-- Note: Types are created conditionally to prevent collisions when running multiple schemas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'syndicate_branch_code') THEN
        CREATE TYPE syndicate_branch_code AS ENUM ('HAS', 'QAM', 'DER');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_lifecycle_state') THEN
        CREATE TYPE project_lifecycle_state AS ENUM ('INV', 'SETTLED');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'engineer_rank') THEN
        CREATE TYPE engineer_rank AS ENUM ('دراسة', 'ممارس', 'مبتدئ', 'تدريب', 'تدقيق', 'استشاري', 'eng', 'c1', 'متدرب', 'مشارك', 'تحت الاشراف');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'fund_subscription_status') THEN
        CREATE TYPE fund_subscription_status AS ENUM ('IN', 'OU');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'discipline_code') THEN
        CREATE TYPE discipline_code AS ENUM ('CIV', 'ARC', 'ELE', 'MCH', 'WTR', 'GEO', 'GTK');
    END IF;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Check and create combined_fund_type specifically if missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'combined_fund_type') THEN
        CREATE TYPE combined_fund_type AS ENUM (
            'FUND_1_CIVIL_ARCH_WATER_GEO',
            'FUND_2_ELEC_MECH'
        );
    END IF;
END $$;


-- =========================================================================
-- 2. MASTER REFERENCE TABLES
-- =========================================================================

-- A. Pricing Reference Configuration (USD)
CREATE TABLE IF NOT EXISTS model_6_config (
    config_key VARCHAR(50) PRIMARY KEY,
    config_value NUMERIC(12, 2) NOT NULL,
    description TEXT
);

COMMENT ON TABLE model_6_config IS 'Master pricing reference configuration for Model 6 (SC)';

-- Populate Model 6 Config
INSERT INTO model_6_config (config_key, config_value, description) VALUES
('SUPERVISION_RATE_USD_M2', 2.40, 'Flat USD rate per square meter of total land area'),
('SANITARY_BASE_FEE_USD', 60.00, 'Flat USD base fee for Sanitary supervision up to 250 m² built area'),
('SANITARY_EXCESS_RATE_USD', 0.10, 'USD rate per excess square meter exceeding 250 m² built area'),
('SANITARY_THRESHOLD_M2', 250.00, 'Threshold footprint size in m² for progressive sanitary fee calculations')
ON CONFLICT (config_key) DO UPDATE SET config_value = EXCLUDED.config_value;


-- B. K-Factor Multiplier Matrix for Model 6 (sd = 7.5%, no ad)
-- K = (1 - 0.075) * (1 - r_fund) * (1 - r_coach)
CREATE TABLE IF NOT EXISTS k_factor_matrix_model_6 (
    adapter_key VARCHAR(4) PRIMARY KEY,
    is_insider BOOLEAN NOT NULL,
    has_coach BOOLEAN NOT NULL,
    resolved_k_factor NUMERIC(7, 5) NOT NULL CHECK (resolved_k_factor BETWEEN 0.00000 AND 1.00000),
    stage_1_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.0750,
    stage_2_rate NUMERIC(5, 4) NOT NULL,
    stage_3_rate NUMERIC(5, 4) NOT NULL DEFAULT 0.0000,
    CONSTRAINT unique_flags_model_6 UNIQUE (is_insider, has_coach)
);

COMMENT ON TABLE k_factor_matrix_model_6 IS 'Precompiled stateless lookup table mapping fund membership and coaching status to final net payouts for Model 6 (SC)';

-- Populate K-factor coefficients for Model 6
-- K = 0.925 * (1 - r_fund) * (1 - r_coach)
INSERT INTO k_factor_matrix_model_6 (adapter_key, is_insider, has_coach, resolved_k_factor, stage_2_rate, stage_3_rate) VALUES
('INNO', TRUE,  FALSE, 0.69375, 0.23125, 0.00000),
('INCO', TRUE,  TRUE,  0.58969, 0.23125, 0.10406),
('OUNO', FALSE, FALSE, 0.83250, 0.09250, 0.00000),
('OUCO', FALSE, TRUE,  0.70763, 0.09250, 0.12488)
ON CONFLICT (adapter_key) DO UPDATE SET resolved_k_factor = EXCLUDED.resolved_k_factor;


-- =========================================================================
-- 3. CORE REGISTRY & TRANSACTION TABLES
-- =========================================================================

-- A. Engineers Core Registry (Unified database link)
CREATE TABLE IF NOT EXISTS engineers_registry (
    engineer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    discipline discipline_code NOT NULL,
    role_qualification VARCHAR(150),
    rank engineer_rank NOT NULL,
    fund_status fund_subscription_status NOT NULL,
    office_branch syndicate_branch_code,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- B. Model 6 Supervision Projects
CREATE TABLE IF NOT EXISTS model_6_projects (
    project_id VARCHAR(50) PRIMARY KEY,
    client_name VARCHAR(150) NOT NULL,
    client_phone VARCHAR(50),
    zone_loc VARCHAR(100) NOT NULL,
    parcel_no VARCHAR(50) NOT NULL,
    prop_no VARCHAR(50) NOT NULL,
    branch_code syndicate_branch_code NOT NULL,

    -- Technical Input Vector parameters
    total_land_area NUMERIC(12, 2) NOT NULL CHECK (total_land_area > 0.0),
    built_area_footprint NUMERIC(12, 2) NOT NULL CHECK (built_area_footprint > 0.0),
    active_usd_rate NUMERIC(12, 2) NOT NULL CHECK (active_usd_rate > 0.0),

    -- Computed Client-facing Totals (in USD)
    basic_supervision_fee_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    sanitary_supervision_fee_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    client_invoice_total_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00,

    -- Transaction Lifecycle fields
    lifecycle_state project_lifecycle_state NOT NULL DEFAULT 'INV',
    receipt_no VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    settled_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,

    CONSTRAINT check_settlement_receipt_model_6 CHECK (
        (lifecycle_state = 'INV' AND receipt_no IS NULL AND settled_at IS NULL) OR
        (lifecycle_state = 'SETTLED' AND receipt_no IS NOT NULL AND settled_at IS NOT NULL)
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_receipt_verification_model_6 ON model_6_projects (receipt_no) WHERE receipt_no IS NOT NULL;


-- C. Model 6 Engineering Supervision Assignments & Financial Split Breakdown
CREATE TABLE IF NOT EXISTS model_6_assignments (
    assignment_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL REFERENCES model_6_projects(project_id) ON DELETE CASCADE,
    discipline_code discipline_code NOT NULL CHECK (discipline_code IN ('CIV', 'ARC', 'MCH', 'ELE', 'WTR')),

    -- Assignee snapshot characteristics (locked at time of invoice creation/update)
    is_assigned BOOLEAN NOT NULL DEFAULT TRUE,
    engineer_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    engineer_name VARCHAR(150),
    engineer_status fund_subscription_status,
    engineer_rank engineer_rank,

    -- Coaching parameters
    has_coach BOOLEAN NOT NULL DEFAULT FALSE,
    supervisor_id VARCHAR(50) REFERENCES engineers_registry(engineer_id),
    supervisor_name VARCHAR(150),

    -- Financial ledger details in USD (calculated per assignee)
    resolved_k_factor NUMERIC(7, 5) NOT NULL DEFAULT 0.00000,
    gross_fee_share_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (gross_fee_share_usd >= 0.0),
    net_payout_calculated_usd NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (net_payout_calculated_usd >= 0.0),

    -- Dynamic Escrow constraint
    payout_state VARCHAR(20) NOT NULL DEFAULT 'HELD' CHECK (payout_state IN ('HELD', 'EARNED')),

    -- Ensure same discipline isn't assigned twice on the same project
    CONSTRAINT unique_project_discipline_model_6 UNIQUE (project_id, discipline_code)
);

CREATE INDEX IF NOT EXISTS idx_assignments_project_model_6 ON model_6_assignments(project_id);


-- D. Central Syndicate Ledger DB for Contributions Verification (Model 6 - SC)
CREATE TABLE IF NOT EXISTS model_6_syndicate_contributions (
    record_id BIGSERIAL PRIMARY KEY,
    project_id VARCHAR(50) NOT NULL,
    receipt_no VARCHAR(100) NOT NULL,
    branch syndicate_branch_code NOT NULL,
    model_type VARCHAR(10) NOT NULL DEFAULT 'SC',
    client_name VARCHAR(150) NOT NULL,
    discipline_code discipline_code NOT NULL,
    engineer_id VARCHAR(50) NOT NULL,
    engineer_name VARCHAR(150) NOT NULL,
    fund_status fund_subscription_status NOT NULL,

    -- Deductions itemization breakdown (USD)
    gross_fee_usd NUMERIC(12, 2) NOT NULL,
    stage_1_unit_fee_usd NUMERIC(12, 2) NOT NULL,
    stage_2_fund_amount_usd NUMERIC(12, 2) NOT NULL,
    stage_3_coaching_fee_usd NUMERIC(12, 2) NOT NULL,
    net_payout_disbursed_usd NUMERIC(12, 2) NOT NULL,

    -- Compound Syndicate Fund destination
    combined_fund combined_fund_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- =========================================================================
-- 4. BUSINESS LOGIC DATABASE TRIGGERS & FUNCTIONS
-- =========================================================================

-- A. Automated Invoice Calculations for Model 6
CREATE OR REPLACE FUNCTION fn_process_model_6_invoice_calculations()
RETURNS TRIGGER AS $$
DECLARE
    v_supervision_rate NUMERIC(12, 2);
    v_sanitary_base NUMERIC(12, 2);
    v_sanitary_excess_rate NUMERIC(12, 2);
    v_sanitary_threshold NUMERIC(12, 2);
BEGIN
    -- Fetch active master configs
    SELECT config_value INTO v_supervision_rate FROM model_6_config WHERE config_key = 'SUPERVISION_RATE_USD_M2';
    SELECT config_value INTO v_sanitary_base FROM model_6_config WHERE config_key = 'SANITARY_BASE_FEE_USD';
    SELECT config_value INTO v_sanitary_excess_rate FROM model_6_config WHERE config_key = 'SANITARY_EXCESS_RATE_USD';
    SELECT config_value INTO v_sanitary_threshold FROM model_6_config WHERE config_key = 'SANITARY_THRESHOLD_M2';

    -- 1. Basic Supervision Fee: Land area * 2.40
    NEW.basic_supervision_fee_usd := NEW.total_land_area * v_supervision_rate;

    -- 2. Sanitary Supervision Fee: Footprint progressive calculation
    IF NEW.built_area_footprint <= v_sanitary_threshold THEN
        NEW.sanitary_supervision_fee_usd := v_sanitary_base;
    ELSE
        NEW.sanitary_supervision_fee_usd := v_sanitary_base + ((NEW.built_area_footprint - v_sanitary_threshold) * v_sanitary_excess_rate);
    END IF;

    -- 3. Grand total invoice (No Printing pool added to SC contracts)
    NEW.client_invoice_total_usd := NEW.basic_supervision_fee_usd + NEW.sanitary_supervision_fee_usd;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_calculate_model_6_invoice ON model_6_projects;
CREATE TRIGGER trg_calculate_model_6_invoice
BEFORE INSERT OR UPDATE OF total_land_area, built_area_footprint ON model_6_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_6_invoice_calculations();


-- B. Automatically initialize the 5 standard engineering assignments for team selection
CREATE OR REPLACE FUNCTION fn_initialize_model_6_assignments()
RETURNS TRIGGER AS $$
BEGIN
    -- Core specialties for Supervision Contract: Civil, Arch, Mechanical, Electrical, Sanitary (WTR)
    INSERT INTO model_6_assignments (project_id, discipline_code, is_assigned, gross_fee_share_usd, net_payout_calculated_usd) VALUES
    (NEW.project_id, 'CIV', TRUE, 0.00, 0.00),
    (NEW.project_id, 'ARC', TRUE, 0.00, 0.00),
    (NEW.project_id, 'MCH', TRUE, 0.00, 0.00),
    (NEW.project_id, 'ELE', TRUE, 0.00, 0.00),
    (NEW.project_id, 'WTR', TRUE, 0.00, 0.00);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_initialize_assignments_stub_model_6 ON model_6_projects;
CREATE TRIGGER trg_initialize_assignments_stub_model_6
AFTER INSERT ON model_6_projects
FOR EACH ROW
EXECUTE FUNCTION fn_initialize_model_6_assignments();


-- C. Automatically calculate individual gross fees and net payouts when supervisors are updated
CREATE OR REPLACE FUNCTION fn_process_assignment_calculations_update_model_6()
RETURNS TRIGGER AS $$
DECLARE
    v_basic_fee_usd NUMERIC(12, 2);
    v_sanitary_fee_usd NUMERIC(12, 2);
    v_share_pct NUMERIC(5, 4);
    v_calculated_gross NUMERIC(12, 2);
    v_k_factor NUMERIC(7, 5);
BEGIN
    -- Exit if no engineer is assigned yet
    IF NEW.engineer_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- 1. Fetch project master fees
    SELECT basic_supervision_fee_usd, sanitary_supervision_fee_usd
    INTO v_basic_fee_usd, v_sanitary_fee_usd
    FROM model_6_projects
    WHERE project_id = NEW.project_id;

    -- 2. Map discipline percentage splits of basic fee
    -- Civil: 48%, Arch: 32%, Mechanical: 10%, Electrical: 10%
    -- Sanitary (WTR) has its own independent gross calculation based on built area rules
    IF NEW.discipline_code = 'CIV' THEN
        v_share_pct := 0.4800;
        v_calculated_gross := v_basic_fee_usd * v_share_pct;
    ELSIF NEW.discipline_code = 'ARC' THEN
        v_share_pct := 0.3200;
        v_calculated_gross := v_basic_fee_usd * v_share_pct;
    ELSIF NEW.discipline_code = 'MCH' THEN
        v_share_pct := 0.1000;
        v_calculated_gross := v_basic_fee_usd * v_share_pct;
    ELSIF NEW.discipline_code = 'ELE' THEN
        v_share_pct := 0.1000;
        v_calculated_gross := v_basic_fee_usd * v_share_pct;
    ELSIF NEW.discipline_code = 'WTR' THEN
        -- Water/Sanitary is mapped directly to the sanitary supervision footprint fee
        v_calculated_gross := v_sanitary_fee_usd;
    ELSE
        v_calculated_gross := 0.00;
    END IF;

    NEW.gross_fee_share_usd := v_calculated_gross;

    -- 3. Resolve historical attributes from registry
    SELECT rank, fund_status INTO NEW.engineer_rank, NEW.engineer_status
    FROM engineers_registry
    WHERE engineer_id = NEW.engineer_id;

    -- 4. Check if coaching is active (Trainee 'دراسة' rank requires supervisor)
    IF NEW.engineer_rank = 'دراسة' THEN
        NEW.has_coach := TRUE;
    ELSE
        NEW.has_coach := FALSE;
    END IF;

    -- 5. Query O(1) stateless K-Factor lookup (sd = 7.5%, no ad)
    SELECT resolved_k_factor INTO v_k_factor
    FROM k_factor_matrix_model_6
    WHERE is_insider = (NEW.engineer_status = 'IN') AND has_coach = NEW.has_coach;

    NEW.resolved_k_factor := COALESCE(v_k_factor, 0.00000);

    -- 6. Direct payout calculation: Net = Gross * K (No Printing allowances in SC model)
    NEW.net_payout_calculated_usd := ROUND(NEW.gross_fee_share_usd * NEW.resolved_k_factor, 2);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_calculate_assignment_shares_model_6 ON model_6_assignments;
CREATE TRIGGER trg_calculate_assignment_shares_model_6
BEFORE UPDATE OF engineer_id ON model_6_assignments
FOR EACH ROW
EXECUTE FUNCTION fn_process_assignment_calculations_update_model_6();


-- D. Automatically release locked payouts upon treasury settlement
CREATE OR REPLACE FUNCTION fn_process_model_6_settlement_payouts()
RETURNS TRIGGER AS $$
DECLARE
    r_assign RECORD;
BEGIN
    -- Only trigger when project state transitions to SETTLED
    IF OLD.lifecycle_state = 'INV' AND NEW.lifecycle_state = 'SETTLED' THEN

        -- 1. Unlocked cash escrow for assigned supervisors
        UPDATE model_6_assignments
        SET payout_state = 'EARNED'
        WHERE project_id = NEW.project_id;

        -- 2. Log itemized deductions and payouts directly into Central Syndicate ledger (Model 6)
        FOR r_assign IN
            SELECT
                a.discipline_code, a.engineer_id, a.engineer_name, a.engineer_status,
                a.gross_fee_share_usd, a.net_payout_calculated_usd, a.has_coach,
                k.stage_1_rate, k.stage_2_rate, k.stage_3_rate
            FROM model_6_assignments a
            JOIN k_factor_matrix_model_6 k ON k.adapter_key = (
                CASE WHEN a.engineer_status = 'IN' THEN 'IN' ELSE 'OU' END ||
                CASE WHEN a.has_coach THEN 'CO' ELSE 'NO' END
            )
            WHERE a.project_id = NEW.project_id AND a.is_assigned = TRUE AND a.engineer_id IS NOT NULL
        LOOP
            -- Log transaction trace
            INSERT INTO model_6_syndicate_contributions (
                project_id, receipt_no, branch, client_name, discipline_code,
                engineer_id, engineer_name, fund_status, gross_fee_usd,
                stage_1_unit_fee_usd, stage_2_fund_amount_usd,
                stage_3_coaching_fee_usd, net_payout_disbursed_usd, combined_fund
            ) VALUES (
                NEW.project_id,
                NEW.receipt_no,
                NEW.branch_code,
                NEW.client_name,
                r_assign.discipline_code,
                r_assign.engineer_id,
                r_assign.engineer_name,
                r_assign.engineer_status,
                r_assign.gross_fee_share_usd,

                -- Deductions pipeline tracing using the static lookup rules
                (r_assign.gross_fee_share_usd * r_assign.stage_1_rate),
                (r_assign.gross_fee_share_usd * r_assign.stage_2_rate),
                (r_assign.gross_fee_share_usd * r_assign.stage_3_rate),
                r_assign.net_payout_calculated_usd,

                -- Assign to combined funds (CIV, ARC, WTR go to Fund 1; ELE & MCH go to Fund 2)
                CASE
                    WHEN r_assign.discipline_code IN ('CIV', 'ARC', 'WTR') THEN 'FUND_1_CIVIL_ARCH_WATER_GEO'::combined_fund_type
                    ELSE 'FUND_2_ELEC_MECH'::combined_fund_type
                END
            );
        END LOOP;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_release_escrow_on_settlement_model_6 ON model_6_projects;
CREATE TRIGGER trg_release_escrow_on_settlement_model_6
AFTER UPDATE OF lifecycle_state ON model_6_projects
FOR EACH ROW
EXECUTE FUNCTION fn_process_model_6_settlement_payouts();


-- =========================================================================
-- 5. RECONCILIATION & AUDIT VERIFICATION VIEW
-- =========================================================================

-- Consolidated verification view for Model 6 ensuring zero-discrepancy balance in USD
CREATE OR REPLACE VIEW view_model_6_balance_verification AS
SELECT
    p.project_id,
    p.client_name,
    p.client_invoice_total_usd AS client_billed_invoice_usd,

    -- Sum of all net payouts disbursed to study engineers
    COALESCE(SUM(a.net_payout_calculated_usd), 0) AS total_net_disbursed_to_supervisors_usd,

    -- Sum of all syndicate holdings (Stage 1 Unit Fee + Stage 2 Fund Retention + Stage 3 Coaching)
    COALESCE(SUM(
        (a.gross_fee_share_usd * k.stage_1_rate) +
        (a.gross_fee_share_usd * k.stage_2_rate) +
        (a.gross_fee_share_usd * k.stage_3_rate)
    ), 0) AS total_syndicate_retained_usd,

    -- Master Balance Matching formula (Grand discrepancy must always verify to 0.00)
    ROUND(
        p.client_invoice_total_usd - (
            COALESCE(SUM(a.net_payout_calculated_usd), 0) +
            COALESCE(SUM(
                (a.gross_fee_share_usd * k.stage_1_rate) +
                (a.gross_fee_share_usd * k.stage_2_rate) +
                (a.gross_fee_share_usd * k.stage_3_rate)
            ), 0)
        ), 2
    ) AS reconciliation_discrepancy_usd
FROM model_6_projects p
LEFT JOIN model_6_assignments a ON a.project_id = p.project_id AND a.is_assigned = TRUE
LEFT JOIN k_factor_matrix_model_6 k ON k.adapter_key = (
    CASE WHEN a.engineer_status = 'IN' THEN 'IN' ELSE 'OU' END ||
    CASE WHEN a.has_coach THEN 'CO' ELSE 'NO' END
)
GROUP BY p.project_id, p.client_name, p.client_invoice_total_usd;

-- COMMIT; (Commented out to run in single global transaction script)
-- =========================================================================
-- END OF DDL SCHEMA
-- =========================================================================

-- =========================================================================
-- END OF SOURCE FILE: model-6-schema-v3.sql
-- =========================================================================


-- =========================================================================
-- START OF SOURCE FILE: model-7-schema.sql
-- =========================================================================

-- =========================================================================
-- DATABASE SCHEMA: BS-RPT — Bayani Study Report Archival & Ledger System
-- VERSION: v3 (Category-Aware, No-Audit)
-- DBMS Target: PostgreSQL (Version 12+)
-- Description: Creates the dedicated SQL tables, triggers, and views for
--              storing, archiving, and querying finalized BS-RPT records.
--              Implements Category 1, 2, 3 rules & corrected 5-stage cascade.
-- =========================================================================

-- BEGIN; (Commented out to run in single global transaction script)

-- =========================================================================
-- 1. EXTENSIONS & PREREQUISITES
-- =========================================================================
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'syndicate_branch_code') THEN
        CREATE TYPE syndicate_branch_code AS ENUM ('HAS', 'QAM', 'DER');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'facility_type_model_5') THEN
        CREATE TYPE facility_type_model_5 AS ENUM (
            'صيدلية', 'مركز تجميل', 'مستودع أدوية', 'عيادة طبية', 'مخبر طبي', 'مشفى'
        );
    END IF;
END $$;

-- =========================================================================
-- 2. REPORT ARCHIVE LEDGER TABLE
-- =========================================================================
CREATE TABLE IF NOT EXISTS bayani_reports_archive (
    report_id BIGSERIAL PRIMARY KEY,
    report_code VARCHAR(100) UNIQUE NOT NULL,      -- e.g., 'BS-RPT-2026-HAS-0001'
    project_id VARCHAR(50) NOT NULL,               -- Reference linked project
    receipt_no VARCHAR(100) UNIQUE NOT NULL,       -- Payment cashier receipt reference
    branch_code syndicate_branch_code NOT NULL,
    facility_type facility_type_model_5 NOT NULL,
    client_name VARCHAR(150) NOT NULL,
    
    -- Technical Parameter Snapshots
    total_area NUMERIC(12, 2) NOT NULL CHECK (total_area > 0.0),
    calculated_units INTEGER NOT NULL CHECK (calculated_units >= 1),
    active_usd_rate NUMERIC(12, 2) NOT NULL CHECK (active_usd_rate > 0.0),
    
    -- Client Invoice Summary Snapshot
    base_study_fee_usd NUMERIC(12, 2) NOT NULL,
    printing_pool_usd NUMERIC(12, 2) NOT NULL,
    client_invoice_total_usd NUMERIC(12, 2) NOT NULL,
    
    -- Engineer Payout Order Snapshots (Net Payouts)
    payout_arch_id VARCHAR(50) NOT NULL,
    payout_arch_name VARCHAR(150) NOT NULL,
    payout_arch_net_usd NUMERIC(12, 2) NOT NULL,
    
    payout_mech_id VARCHAR(50) NOT NULL,
    payout_mech_name VARCHAR(150) NOT NULL,
    payout_mech_net_usd NUMERIC(12, 2) NOT NULL,
    
    payout_elec_id VARCHAR(50) NOT NULL,
    payout_elec_name VARCHAR(150) NOT NULL,
    payout_elec_net_usd NUMERIC(12, 2) NOT NULL,
    
    -- Syndicate Deposit (SFD) Component Snapshots
    total_unit_fees_usd NUMERIC(12, 2) NOT NULL,
    total_fund_retentions_usd NUMERIC(12, 2) NOT NULL,
    total_coaching_retentions_usd NUMERIC(12, 2) NOT NULL,
    syndicate_deposit_total_usd NUMERIC(12, 2) NOT NULL,
    
    -- Immutable JSON Document Snapshot (For easy API retrieval)
    full_report_document_json JSONB NOT NULL,
    
    settled_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE bayani_reports_archive IS 'Central, immutable audit repository storing the finalized single-point BS-RPT ledger documents.';

CREATE INDEX IF NOT EXISTS idx_bayani_reports_code ON bayani_reports_archive (report_code);
CREATE INDEX IF NOT EXISTS idx_bayani_reports_date ON bayani_reports_archive (settled_at);

-- =========================================================================
-- 3. AUTOMATED ARCHIVAL TRIGGER ENGINE
-- =========================================================================
CREATE OR REPLACE FUNCTION fn_generate_and_archive_bayani_report()
RETURNS TRIGGER AS $$
DECLARE
    v_report_code VARCHAR(100);
    v_seq_no INTEGER;
    v_year VARCHAR(4);
    
    -- Workspace variables for compiling assignments
    v_arch_id VARCHAR(50); v_arch_name VARCHAR(150); v_arch_net NUMERIC(12,2);
    v_mech_id VARCHAR(50); v_mech_name VARCHAR(150); v_mech_net NUMERIC(12,2);
    v_elec_id VARCHAR(50); v_elec_name VARCHAR(150); v_elec_net NUMERIC(12,2);
    
    -- Workspace variables for compiling retentions
    v_total_unit_fees NUMERIC(12,2) := 0.00;
    v_total_funds NUMERIC(12,2) := 0.00;
    v_total_coaching NUMERIC(12,2) := 0.00;
    v_sfd_total NUMERIC(12,2) := 0.00;
    v_json_doc JSONB;
BEGIN
    -- Only execute when state transitions to settled
    IF OLD.lifecycle_state = 'INV' AND NEW.lifecycle_state = 'SETTLED' THEN
        
        -- 1. Resolve Sequential Code Serial Number (e.g., BS-RPT-2026-HAS-0001)
        v_year := TO_CHAR(CURRENT_TIMESTAMP, 'YYYY');
        
        SELECT COALESCE(COUNT(*), 0) + 1 INTO v_seq_no
        FROM bayani_reports_archive
        WHERE branch_code = NEW.branch_code AND TO_CHAR(settled_at, 'YYYY') = v_year;
        
        v_report_code := 'BS-RPT-' || v_year || '-' || NEW.branch_code || '-' || LPAD(v_seq_no::text, 4, '0');
        
        -- 2. Pull and verify the 3 assigned engineer details
        -- Architectural Split
        SELECT engineer_id, COALESCE(engineer_name, 'Architect'), net_payout_calculated_usd INTO v_arch_id, v_arch_name, v_arch_net
        FROM model_5_assignments WHERE project_id = NEW.project_id AND discipline_code = 'ARC';
        
        -- Mechanical Split
        SELECT engineer_id, COALESCE(engineer_name, 'Mechanical Specialist'), net_payout_calculated_usd INTO v_mech_id, v_mech_name, v_mech_net
        FROM model_5_assignments WHERE project_id = NEW.project_id AND discipline_code = 'MCH';
        
        -- Electrical Split
        SELECT engineer_id, COALESCE(engineer_name, 'Electrical Specialist'), net_payout_calculated_usd INTO v_elec_id, v_elec_name, v_elec_net
        FROM model_5_assignments WHERE project_id = NEW.project_id AND discipline_code = 'ELE';
        
        -- 3. Compile the itemized syndicate deposit components from the ledger logs
        SELECT COALESCE(SUM(stage_1_unit_fee_usd), 0.00),
               COALESCE(SUM(stage_2_fund_amount_usd), 0.00),
               COALESCE(SUM(stage_3_coaching_fee_usd), 0.00)
        INTO v_total_unit_fees, v_total_funds, v_total_coaching
        FROM model_5_syndicate_contributions
        WHERE project_id = NEW.project_id;
        
        v_sfd_total := v_total_unit_fees + v_total_funds + v_total_coaching;
        
        -- 4. Build the immutable nested JSON document payload
        v_json_doc := jsonb_build_object(
            'document_metadata', jsonb_build_object(
                'report_code', v_report_code,
                'project_id', NEW.project_id,
                'receipt_no', NEW.receipt_no,
                'settled_at', CURRENT_TIMESTAMP
            ),
            'project_header', jsonb_build_object(
                'client_name', NEW.client_name,
                'facility_type', NEW.facility_type,
                'zone_loc', NEW.zone_loc,
                'parcel_no', NEW.parcel_no,
                'prop_no', NEW.prop_no,
                'branch', NEW.branch_code
            ),
            'client_invoice', jsonb_build_object(
                'total_area_m2', NEW.total_area,
                'ceiling_units_qty', NEW.calculated_units,
                'base_study_fee_usd', NEW.base_study_fee_usd,
                'printing_surcharge_usd', NEW.printing_pool_usd,
                'grand_total_invoice_usd', NEW.client_invoice_total_usd
            ),
            'engineer_payout_order', jsonb_build_array(
                jsonb_build_object(
                    'discipline', 'Architecture',
                    'engineer_id', v_arch_id,
                    'name', v_arch_name,
                    'net_payout_usd', v_arch_net
                ),
                jsonb_build_object(
                    'discipline', 'Mechanical',
                    'engineer_id', v_mech_id,
                    'name', v_mech_name,
                    'net_payout_usd', v_mech_net
                ),
                jsonb_build_object(
                    'discipline', 'Electrical',
                    'engineer_id', v_elec_id,
                    'name', v_elec_name,
                    'net_payout_usd', v_elec_net
                )
            ),
            'syndicate_deposit_sfd', jsonb_build_object(
                'syndicate_unit_fees_usd', v_total_unit_fees,
                'joint_funds_retained_usd', v_total_funds,
                'coaching_holds_usd', v_total_coaching,
                'consolidated_deposit_total_usd', v_sfd_total
            ),
            'reconciliation_audit', jsonb_build_object(
                'payouts_sum_usd', (v_arch_net + v_mech_net + v_elec_net),
                'sfd_deposit_usd', v_sfd_total,
                'invoice_total_usd', NEW.client_invoice_total_usd,
                'reconciliation_discrepancy_usd', (NEW.client_invoice_total_usd - ((v_arch_net + v_mech_net + v_elec_net) + v_sfd_total))
            )
        );
        
        -- 5. Insert records into the Reports Archive Ledger
        INSERT INTO bayani_reports_archive (
            report_code, project_id, receipt_no, branch_code, facility_type, client_name,
            total_area, calculated_units, active_usd_rate,
            base_study_fee_usd, printing_pool_usd, client_invoice_total_usd,
            payout_arch_id, payout_arch_name, payout_arch_net_usd,
            payout_mech_id, payout_mech_name, payout_mech_net_usd,
            payout_elec_id, payout_elec_name, payout_elec_net_usd,
            total_unit_fees_usd, total_fund_retentions_usd, total_coaching_retentions_usd,
            syndicate_deposit_total_usd, full_report_document_json, settled_at
        ) VALUES (
            v_report_code, NEW.project_id, NEW.receipt_no, NEW.branch_code, NEW.facility_type, NEW.client_name,
            NEW.total_area, NEW.calculated_units, NEW.active_usd_rate,
            NEW.base_study_fee_usd, NEW.printing_pool_usd, NEW.client_invoice_total_usd,
            v_arch_id, v_arch_name, v_arch_net,
            v_mech_id, v_mech_name, v_mech_net,
            v_elec_id, v_elec_name, v_elec_net,
            v_total_unit_fees, v_total_funds, v_total_coaching,
            v_sfd_total, v_json_doc, NEW.settled_at
        );
        
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Bind trigger to Model 5 projects
DROP TRIGGER IF EXISTS trg_archive_bayani_report ON model_5_projects;
CREATE TRIGGER trg_archive_bayani_report
AFTER UPDATE OF lifecycle_state ON model_5_projects
FOR EACH ROW
EXECUTE FUNCTION fn_generate_and_archive_bayani_report();

-- =========================================================================
-- 4. LEDGER INTEGRITY VERIFICATION VIEW
-- =========================================================================
CREATE OR REPLACE VIEW view_bayani_reports_ledger_integrity AS
SELECT 
    report_code,
    project_id,
    receipt_no,
    client_name,
    client_invoice_total_usd AS client_payment,
    (payout_arch_net_usd + payout_mech_net_usd + payout_elec_net_usd) AS disbursed_to_study_team,
    syndicate_deposit_total_usd AS administrative_syndicate_deposits,
    ROUND(
        client_invoice_total_usd - 
        ((payout_arch_net_usd + payout_mech_net_usd + payout_elec_net_usd) + syndicate_deposit_total_usd), 
        2
    ) AS reconciliation_leakage
FROM bayani_reports_archive;

-- COMMIT; (Commented out to run in single global transaction script)

-- =========================================================================
-- END OF SOURCE FILE: model-7-schema.sql
-- =========================================================================


-- =========================================================================
-- START OF SOURCE FILE: 08_central_accumulator-v2.sql
-- =========================================================================

-- =========================================================================
-- DATABASE SCHEMA: Unified Syndicate Ledger Accumulator & Document Archive
-- DBMS Target: PostgreSQL (Version 12+)
-- Description: Establishes a centralized financial transaction warehouse and 
--              immutable document repository across all 7 syndicate models.
--              Enables absolute historical reporting "per engineer" at the
--              finest grain of detail (Gross, Net, Stage 1-5 Deductions, Funds).
-- =========================================================================

-- BEGIN; (Commented out to run in single global transaction script)

-- =========================================================================
-- 1. CENTRAL IMMUTABLE DOCUMENT STORAGE (Autosaved Issued PDFs)
-- =========================================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'document_type_enum') THEN
        CREATE TYPE document_type_enum AS ENUM (
            'INV',
            'EPO',
            'FSD'
        );
    END IF;
END $$;

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

CREATE INDEX IF NOT EXISTS idx_doc_archive_project ON central_document_archive (project_id);
CREATE INDEX IF NOT EXISTS idx_doc_archive_model ON central_document_archive (model_type);
CREATE INDEX IF NOT EXISTS idx_doc_archive_branch ON central_document_archive (branch_code);
CREATE INDEX IF NOT EXISTS idx_doc_archive_checksum ON central_document_archive (sha256_checksum);

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

CREATE INDEX IF NOT EXISTS idx_accumulator_engineer ON central_engineer_ledger_accumulator (engineer_id);
CREATE INDEX IF NOT EXISTS idx_accumulator_model ON central_engineer_ledger_accumulator (model_type);
CREATE INDEX IF NOT EXISTS idx_accumulator_settled_at ON central_engineer_ledger_accumulator (settled_at);
CREATE INDEX IF NOT EXISTS idx_accumulator_receipt ON central_engineer_ledger_accumulator (receipt_no);

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

-- COMMIT; (Commented out to run in single global transaction script)
-- =========================================================================
-- END OF ACCUMULATOR & ARCHIVE SCHEMAS
-- =========================================================================

-- =========================================================================
-- END OF SOURCE FILE: 08_central_accumulator-v2.sql
-- =========================================================================


-- =========================================================================
-- START OF SOURCE FILE: seed-engineers-v2.sql
-- =========================================================================

-- =========================================================================
-- DATABASE SEEDING (DML): Master Engineers Registry (سجل المهندسين الموحد)
-- Target DBMS: PostgreSQL (Version 12+)
-- Project: Engineers Syndicate Accounting System (Hasakah, Qamishli, Derik)
-- Description: Seeds the core registry with real engineers compiled from 
--              the official 3-branch directories, mapping disciplines to 
--              standard codes (CIV, ARC, ELE, MCH, WTR, GEO, GTK), 
--              preserving role qualifications ('مؤهل الدور'), ranks ('المرتبة'), 
--              and mutual fund statuses ('الصندوق المشترك').
-- =========================================================================

-- BEGIN; (Commented out to run in single global transaction script)
-- Safeguard Alterations
ALTER TABLE engineers_registry ADD COLUMN IF NOT EXISTS role_qualification VARCHAR(150);
ALTER TABLE engineers_registry ADD COLUMN IF NOT EXISTS office_branch syndicate_branch_code;

-- Auto-populate office_branch from engineer_id prefix
CREATE OR REPLACE FUNCTION fn_auto_populate_engineer_office_branch()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.engineer_id LIKE '%-HAS-%' THEN
        NEW.office_branch := 'HAS'::syndicate_branch_code;
    ELSIF NEW.engineer_id LIKE '%-QAM-%' THEN
        NEW.office_branch := 'QAM'::syndicate_branch_code;
    ELSIF NEW.engineer_id LIKE '%-DER-%' THEN
        NEW.office_branch := 'DER'::syndicate_branch_code;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_populate_office_branch ON engineers_registry;
CREATE TRIGGER trg_auto_populate_office_branch
BEFORE INSERT ON engineers_registry
FOR EACH ROW
EXECUTE FUNCTION fn_auto_populate_engineer_office_branch();



-- Standard cleaner to prevent conflicts during test cycles
TRUNCATE TABLE engineers_registry CASCADE;

-- Insert Master Engineers Registry Records
INSERT INTO engineers_registry (
    engineer_id, 
    full_name, 
    discipline, 
    role_qualification, 
    rank, 
    fund_status, 
    is_active
) VALUES
-- =========================================================================
-- AL-HASAKAH OFFICE (وحدة الحسكة)
-- =========================================================================
('ENG-HAS-CIV-0001', 'ابراهيم نجيم طاهر', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'OU', TRUE),
('ENG-HAS-CIV-0002', 'هيفي عابد احمد', 'CIV', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-HAS-CIV-0003', 'عبد الباقي داود احمد', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'OU', TRUE),
('ENG-HAS-CIV-0004', 'كاوا احمد صالح', 'CIV', 'دراسة', 'متدرب', 'OU', TRUE),
('ENG-HAS-CIV-0005', 'صالح نايف ابراهيم', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-CIV-0006', 'عبود فرحان العمر', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-CIV-0007', 'رقيه مجيد الحاج علي', 'CIV', 'دراسة', 'متدرب', 'OU', TRUE),
('ENG-HAS-CIV-0008', 'عبد الباسط نذير يوسف', 'CIV', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-HAS-CIV-0010', 'محمد مجول ياسين', 'CIV', 'دراسة', 'متدرب', 'OU', TRUE),
('ENG-HAS-CIV-0014', 'رشا فخري يونس', 'CIV', 'دراسة', 'متدرب', 'IN', TRUE),
('ENG-HAS-CIV-0019', 'هيفيدار محمد باقي محمد', 'CIV', 'دراسة', 'مشارك', 'IN', TRUE),
('ENG-HAS-CIV-0020', 'عبد العزيز عامر شيخي', 'CIV', 'دراسة', 'مشارك', 'IN', TRUE),
('ENG-HAS-CIV-0023', 'عامر محي الحيجي', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'OU', TRUE),

-- Soil Specialists (HAS)
('ENG-HAS-GTK-0043', 'زياد طارق بوش', 'GTK', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-GTK-0044', 'وليد عباس ججو', 'GTK', 'دراسة,تدريب,تدقيق', 'استشاري', 'OU', TRUE),
('ENG-HAS-GTK-0045', 'هبون عدنان الاحمد', 'GTK', 'دراسة', 'متدرب', 'OU', TRUE),

-- Architecture (HAS)
('ENG-HAS-ARC-0046', 'ابراهيم شيخموس حسين', 'ARC', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-HAS-ARC-0047', 'محمد مصلح عبد العزيز محمود', 'ARC', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-ARC-0048', 'عبد الحليم صبري ابراهيم', 'ARC', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-ARC-0049', 'دلال حسن النعمه', 'ARC', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-HAS-ARC-0051', 'زيندان علي محمد', 'ARC', 'دراسة', 'مشارك', 'OU', TRUE),

-- Mechanical (HAS)
('ENG-HAS-MCH-0060', 'ذاكرة محمد ولو', 'MCH', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-MCH-0061', 'محمد خضر يوسف', 'MCH', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-MCH-0065', 'عبد الرزاق خليل خليف', 'MCH', 'دراسة', 'متدرب', 'OU', TRUE),

-- Electrical (HAS)
('ENG-HAS-ELE-0066', 'عبد الرحمن محمد ولو', 'ELE', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-HAS-ELE-0067', 'محمد بشير سمعو ملا احمد', 'ELE', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-HAS-ELE-0068', 'عبد الحميد محمد ولو', 'ELE', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),

-- =========================================================================
-- QAMISHLI OFFICE (وحدة القامشلي)
-- =========================================================================
-- Civil & Water (QAM)
('ENG-QAM-CIV-0001', 'خالد يونس عجو', 'CIV', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-QAM-CIV-0004', 'جفين يوسف شيخموس', 'CIV', 'دراسة', 'تحت الاشراف', 'OU', TRUE),
('ENG-QAM-WTR-0001', 'آلا محمد بشار حبو', 'WTR', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-QAM-GEO-0005', 'احمد عبدالله العوض', 'GEO', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-QAM-GTK-0001', 'نسرين خلف خلف', 'GTK', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),

-- Architecture (QAM)
('ENG-QAM-ARC-0001', 'زليخان شوكت علي', 'ARC', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-QAM-ARC-0002', 'عمر يونس سليفي', 'ARC', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-QAM-ARC-0007', 'سامر شيخموس واوي', 'ARC', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-QAM-ARC-0034', 'فيريل يوسف توكمه جي', 'ARC', 'دراسة', 'تحت الاشراف', 'IN', TRUE),
('ENG-QAM-ARC-0039', 'هيفين بدر الدين إسماعيل', 'ARC', 'دراسة', 'متدرب', 'OU', TRUE),

-- Electrical & Mechanical (QAM)
('ENG-QAM-ELE-0001', 'اكرم احمد محمود', 'ELE', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-QAM-ELE-0022', 'هيم زكي سعدو', 'ELE', 'دراسة', 'تحت الاشراف', 'IN', TRUE),
('ENG-QAM-MCH-0001', 'إبراهيم مجيد شيخموس', 'MCH', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-QAM-MCH-0003', 'سعيد محمود عمر حسن', 'MCH', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),

-- =========================================================================
-- DERIK OFFICE (وحدة ديريك)
-- =========================================================================
-- Civil & Soils (DER)
('ENG-DER-CIV-0001', 'رمضان حسن', 'CIV', 'دراسة,تدريب,تدقيق', 'استشاري', 'OU', TRUE),
('ENG-DER-CIV-0003', 'فرحان أحمد حسين', 'CIV', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-DER-CIV-0004', 'شيرزاد علوان إبراهيم', 'CIV', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-DER-CIV-0009', 'ليلى زبير عبدالله', 'CIV', 'دراسة', 'متدرب', 'OU', TRUE),
('ENG-DER-CIV-0010', 'نور إبراهيم يوسف', 'CIV', 'دراسة', 'متدرب', 'IN', TRUE),
('ENG-DER-GTK-0001', 'صالح محمد الرحيل', 'GTK', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-DER-GTK-0002', 'فنر عبدالباقي إبراهيم', 'GTK', 'دراسة', 'متدرب', 'OU', TRUE),

-- Architecture (DER)
('ENG-DER-ARC-0001', 'حسين علي خلف', 'ARC', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-DER-ARC-0002', 'حسن جتو', 'ARC', 'دراسة,تدريب', 'ممارس', 'IN', TRUE),
('ENG-DER-ARC-0003', 'شيماء ياسر البرهو', 'ARC', 'دراسة', 'متدرب', 'IN', TRUE),
('ENG-DER-ARC-0005', 'دلفين عبد الفادر حاجي', 'ARC', 'دراسة', 'متدرب', 'OU', TRUE),

-- Electrical & Mechanical (DER)
('ENG-DER-ELE-0001', 'أحمد كورو جاجان', 'ELE', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-DER-ELE-0005', 'أرين جميل حمو', 'ELE', 'دراسة', 'متدرب', 'OU', TRUE),
('ENG-DER-MCH-0001', 'أحمد إسماعيل أحمد', 'MCH', 'دراسة,تدريب,تدقيق', 'استشاري', 'IN', TRUE),
('ENG-DER-MCH-0004', 'عبد الباقي إبراهيم', 'MCH', 'دراسة,تدريب', 'ممارس', 'OU', TRUE);

-- COMMIT; (Commented out to run in single global transaction script)
-- =========================================================================
-- END OF SEEDING SCRIPT
-- =========================================================================

-- =========================================================================
-- END OF SOURCE FILE: seed-engineers-v2.sql
-- =========================================================================
