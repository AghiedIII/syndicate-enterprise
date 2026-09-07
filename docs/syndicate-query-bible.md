# PostgreSQL Query Bible: Multi-Tenant Syndicate Ledger Audit Guide

This master reference guide provides your database administrators and backend engineers with the exact, optimized SQL queries required to audit, reconcile, and report on the **four newly mapped syndicate outcome funds** across all seven accounting models.

---

## The 4 Unified Syndicate Funds
All transactions record holds into one of these four explicit destinations:
1.  **`FUND_JOINT_CIVIL_ARCH_WATER_GEO`**: Joint subscription fund for Civil, Architecture, Water, Geology, and Geotechnical engineers.
2.  **`FUND_JOINT_ELEC_MECH`**: Joint subscription fund for Electrical and Mechanical engineers.
3.  **`FUND_AUDIT_CIVIL_ARCH`**: Design auditing pool for Civil and Architectural studies (Models 1 & 3).
4.  **`FUND_AUDIT_ELEC_MECH`**: Design auditing pool for Electrical and Mechanical studies (Models 1 & 3).

---

## 1. Grand Monthly Branch Balance Sheet
This query aggregates all revenues, disbursements, and retentions across all four funds, grouped by branch office (**الحسكة**, **قامشلو**, **ديريك**) and month.

```sql
WITH unified_ledger AS (
    -- Model 1 (GS) Contributions
    SELECT 
        branch,
        DATE_TRUNC('month', created_at) AS audit_month,
        gross_fee_syp / 15000.0 AS gross_usd, -- Normalized to USD for comparative audits
        stage_1_unit_fee_syp / 15000.0 AS unit_fee_usd,
        stage_3_fund_amount_syp / 15000.0 AS subscription_fee_usd,
        stage_2_audit_pool_syp / 15000.0 AS audit_fee_usd,
        stage_4_coaching_fee_syp / 15000.0 AS coaching_fee_usd,
        joint_fund,
        audit_fund
    FROM model_1_syndicate_contributions

    UNION ALL

    -- Model 2 (SR) Contributions
    SELECT 
        branch,
        DATE_TRUNC('month', created_at) AS audit_month,
        gross_fee_usd AS gross_usd,
        stage_1_unit_fee_usd AS unit_fee_usd,
        stage_2_fund_amount_usd AS subscription_fee_usd,
        0.00 AS audit_fee_usd,
        0.00 AS coaching_fee_usd,
        joint_fund,
        audit_fund
    FROM model_2_syndicate_contributions

    UNION ALL

    -- Model 3 (SS) Contributions
    SELECT 
        branch,
        DATE_TRUNC('month', created_at) AS audit_month,
        gross_fee_syp / 15000.0 AS gross_usd,
        stage_1_unit_fee_syp / 15000.0 AS unit_fee_usd,
        stage_3_fund_amount_syp / 15000.0 AS subscription_fee_usd,
        stage_2_audit_pool_syp / 15000.0 AS audit_fee_usd,
        stage_4_coaching_fee_syp / 15000.0 AS coaching_fee_usd,
        joint_fund,
        audit_fund
    FROM model_3_syndicate_contributions

    UNION ALL

    -- Model 4 (MP) Contributions
    SELECT 
        branch,
        DATE_TRUNC('month', created_at) AS audit_month,
        gross_fee_syp / 15000.0 AS gross_usd,
        stage_1_unit_fee_syp / 15000.0 AS unit_fee_usd,
        stage_2_fund_amount_syp / 15000.0 AS subscription_fee_usd,
        0.00 AS audit_fee_usd,
        0.00 AS coaching_fee_usd,
        joint_fund,
        audit_fund
    FROM model_4_syndicate_contributions

    UNION ALL

    -- Model 5 & 7 (Bayani BS/BS-RPT) Contributions
    SELECT 
        branch,
        DATE_TRUNC('month', created_at) AS audit_month,
        gross_fee_usd AS gross_usd,
        stage_1_unit_fee_usd AS unit_fee_usd,
        stage_2_fund_amount_usd AS subscription_fee_usd,
        0.00 AS audit_fee_usd,
        stage_3_coaching_fee_usd AS coaching_fee_usd,
        joint_fund,
        audit_fund
    FROM model_5_syndicate_contributions

    UNION ALL

    -- Model 6 (SC) Contributions
    SELECT 
        branch,
        DATE_TRUNC('month', created_at) AS audit_month,
        gross_fee_usd AS gross_usd,
        stage_1_unit_fee_usd AS unit_fee_usd,
        stage_2_fund_amount_usd AS subscription_fee_usd,
        0.00 AS audit_fee_usd,
        stage_3_coaching_fee_usd AS coaching_fee_usd,
        joint_fund,
        audit_fund
    FROM model_6_syndicate_contributions
)
SELECT 
    branch AS "Branch Office",
    TO_CHAR(audit_month, 'YYYY-MM') AS "Audit Month",
    
    -- Fund 1: Civil/Arch Joint Subscription
    ROUND(SUM(CASE WHEN joint_fund = 'FUND_JOINT_CIVIL_ARCH_WATER_GEO' THEN subscription_fee_usd ELSE 0.00 END), 2) AS "Joint Civil/Arch (USD)",
    
    -- Fund 2: Elec/Mech Joint Subscription
    ROUND(SUM(CASE WHEN joint_fund = 'FUND_JOINT_ELEC_MECH' THEN subscription_fee_usd ELSE 0.00 END), 2) AS "Joint Elec/Mech (USD)",
    
    -- Fund 3: Civil/Arch Auditing Pool
    ROUND(SUM(CASE WHEN audit_fund = 'FUND_AUDIT_CIVIL_ARCH' THEN audit_fee_usd ELSE 0.00 END), 2) AS "Audit Civil/Arch (USD)",
    
    -- Fund 4: Elec/Mech Auditing Pool
    ROUND(SUM(CASE WHEN audit_fund = 'FUND_AUDIT_ELEC_MECH' THEN audit_fee_usd ELSE 0.00 END), 2) AS "Audit Elec/Mech (USD)",
    
    -- System Retentions
    ROUND(SUM(unit_fee_usd), 2) AS "Total Unit Fees Retained (USD)",
    ROUND(SUM(coaching_fee_usd), 2) AS "Total Coaching Fees Retained (USD)",
    ROUND(SUM(gross_usd), 2) AS "Total Processed Gross (USD)"
FROM unified_ledger
GROUP BY branch, audit_month
ORDER BY audit_month DESC, branch;
```

---

## 2. Multi-Tenant Branch Leak Detection View
This query enforces role-based workspace boundaries, checking if any accountant has crossed branch lines or if a discrepancy has leaked. 

```sql
CREATE OR REPLACE VIEW view_regional_leak_auditor AS
WITH project_sums AS (
    -- Model 5 Projects Summary
    SELECT 
        branch_code,
        project_id,
        client_invoice_total_usd AS client_billed,
        'M5' AS model
    FROM model_5_projects
    
    UNION ALL
    
    -- Model 6 Projects Summary
    SELECT 
        branch_code,
        project_id,
        client_invoice_total_usd AS client_billed,
        'M6' AS model
    FROM model_6_projects
),
ledger_sums AS (
    -- Model 5 Ledger Sums
    SELECT 
        project_id,
        SUM(net_payout_disbursed_usd) AS payouts,
        SUM(stage_1_unit_fee_usd + stage_2_fund_amount_usd + stage_3_coaching_fee_usd) AS deposits
    FROM model_5_syndicate_contributions
    GROUP BY project_id

    UNION ALL

    -- Model 6 Ledger Sums
    SELECT 
        project_id,
        SUM(net_payout_disbursed_usd) AS payouts,
        SUM(stage_1_unit_fee_usd + stage_2_fund_amount_usd + stage_3_coaching_fee_usd) AS deposits
    FROM model_6_syndicate_contributions
    GROUP BY project_id
)
SELECT 
    p.branch_code AS "Branch Limit",
    p.project_id AS "Project Ref",
    p.model AS "Model",
    p.client_billed AS "Billed Amount (USD)",
    COALESCE(l.payouts, 0.00) AS "Disbursed Payouts (USD)",
    COALESCE(l.deposits, 0.00) AS "Syndicate Deposits (USD)",
    ROUND(p.client_billed - (COALESCE(l.payouts, 0.00) + COALESCE(l.deposits, 0.00)), 2) AS "Discrepancy Leakage"
FROM project_sums p
LEFT JOIN ledger_sums l ON l.project_id = p.project_id;

-- Tenant Isolation Verification (Example: Qamishli Accountant Session)
-- SELECT * FROM view_regional_leak_auditor WHERE "Branch Limit" = 'QAM' AND "Discrepancy Leakage" != 0.00;
```

---

## 3. Real-Time Cashier Liquidity Status
Calculates cash holdings inside the branch's safe vault, separating settled ledger balances from pending invoices.

```sql
SELECT 
    branch_code AS "Office Branch",
    COUNT(CASE WHEN lifecycle_state = 'INV' THEN 1 END) AS "Pending Invoices Count",
    ROUND(COALESCE(SUM(CASE WHEN lifecycle_state = 'INV' THEN client_invoice_total_usd END), 0.00), 2) AS "Receivables Pipeline (USD)",
    COUNT(CASE WHEN lifecycle_state = 'SETTLED' THEN 1 END) AS "Settled Projects Count",
    ROUND(COALESCE(SUM(CASE WHEN lifecycle_state = 'SETTLED' THEN client_invoice_total_usd END), 0.00), 2) AS "Liquid Capital In Vault (USD)"
FROM model_5_projects
GROUP BY branch_code;
```

---

## 4. Trainee Coaching Performance Audit
Tracks coaching holds to ensure Trainee ranks (`'دراسة'`) are being actively paired with authorized supervisors, and sums up total training retainage holds:

```sql
SELECT 
    a.supervisor_name AS "Coaching Supervisor",
    a.discipline_code AS "Discipline",
    COUNT(DISTINCT a.engineer_id) AS "Active Trainees Under Supervision",
    COUNT(a.assignment_id) AS "Completed Joint Studies Checked",
    ROUND(SUM(a.gross_fee_share_usd * 0.15), 2) AS "Total Training Retainages Generated (USD)"
FROM model_5_assignments a
WHERE a.has_coach = TRUE AND a.supervisor_id IS NOT NULL
GROUP BY a.supervisor_id, a.supervisor_name, a.discipline_code
ORDER BY "Active Trainees Under Supervision" DESC;
```
