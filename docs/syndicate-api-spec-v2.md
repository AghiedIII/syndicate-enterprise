# REST API Specification: Syndicate Ledger System (v1)
**Security Protocol**: Multi-Tenant Regional JWT Isolation  
**Target Environment**: Node.js (NestJS / Express) or Go (Fiber)  
**Encoding**: UTF-8 Multilingual (Arabic/English)  

---

## 1. Global Architectural & Security Policies

### A. Per-City Tenant Isolation (RBAC)
Every inbound API request must carry a cryptographically signed JWT in the `Authorization: Bearer <TOKEN>` header. The token payload must contain the accountant's authorized branch code:
```json
{
  "user_id": "usr_01HJ8Z3...",
  "role": "accountant",
  "branch_code": "QAM" // "HAS", "QAM", "DER"
}
```
*   **Database Enforcement**: The backend middleware must automatically append a `WHERE branch_code = JWT.branch_code` clause to all queries. 
*   **Cross-Tenant Graceful Redirection**: To prevent disruptive workflow errors, instead of throwing hard blocks (such as `403 Forbidden`), the gateway implements **Silent Auto-Filtering and Seamless Redirection**. If an accountant from Hasakah (`HAS`) accidentally accesses a Qamishli (`QAM`) resource link, the API automatically and gracefully redirects them back to their home branch dashboard, seamlessly auto-filtering all metrics and dropdown lists to show only their authorized regional records.

### B. Standard Response Envelopes
To keep the dashboard interface smooth and resilient, all endpoints return a standardized JSON structure:

```json
{
  "success": true,
  "timestamp": "2026-09-05T06:00:00Z",
  "data": {} // Payload maps to local db views
}
```

---

## 2. API Endpoint Registry

### [1] Authentication & Tenancy Verification
*   **Endpoint**: `POST /api/v1/auth/login`
*   **Access**: Public
*   **Payload**:
    ```json
    {
      "username": "qam_ledger_admin",
      "password": "hashed_password_string"
    }
    ```
*   **Success Response (`200 OK`)**:
    ```json
    {
      "success": true,
      "timestamp": "2026-09-05T06:01:00Z",
      "data": {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "user": {
          "id": "usr_99X101",
          "name": "م. أحمد سليمان",
          "role": "branch_accountant",
          "branch": "QAM",
          "city_ar": "القامشلي"
        },
        "ui_theme": {
          "primary_accent": "#00E5FF",
          "glow_color": "rgba(0, 229, 255, 0.15)",
          "sidebar_logo_url": "/assets/logos/logo-qam.jpg"
        }
      }
    }
    ```

---

### [2] Bento-Grid Dashboard Metrics
*   **Endpoint**: `GET /api/v1/dashboard/metrics`
*   **Access**: Authorized (JWT Bound)
*   **Database Reference**: Queries `view_model_5_balance_verification` and `view_model_6_balance_verification` filtered by tenant branch.
*   **Success Response (`200 OK` for Qamishli Accountant)**:
    ```json
    {
      "success": true,
      "timestamp": "2026-09-05T06:02:15Z",
      "data": {
        "branch_summary": {
          "branch_code": "QAM",
          "active_projects_count": 48,
          "monthly_turnover_usd": 14250.00,
          "monthly_turnover_syp": 213750000.00
        },
        "four_outcome_funds": {
          "joint_civil_arch_water_geo_usd": 4850.50,
          "joint_elec_mech_usd": 1240.00,
          "audit_civil_arch_usd": 1820.00,
          "audit_elec_mech_usd": 450.00
        },
        "reconciliation_alert": {
          "total_unallocated_limbo_usd": 0.00, // Safe status
          "ledger_integrity_badge": "PERFECT_BALANCE"
        }
      }
    }
    ```

---

### [3] Filtered Engineers Registry (Interactive Team Selector)
*   **Endpoint**: `GET /api/v1/engineers`
*   **Access**: Authorized (JWT Bound)
*   **Description**: Returns local active engineers to prevent cross-border hiring.
*   **Query Parameters**:
    *   `discipline_code`: `CIV`, `ARC`, `ELE`, `MCH`, `WTR`
    *   `is_coachable_only`: `true` (filters `role_qualification = 'دراسة'`)
*   **Database Reference**: `SELECT * FROM engineers_registry WHERE office_branch = JWT.branch`
*   **Success Response (`200 OK`)**:
    ```json
    {
      "success": true,
      "data": {
        "engineers": [
          {
            "engineer_id": "ENG-QAM-ARC-0034",
            "full_name": "فيريل يوسف توكمه جي",
            "discipline": "ARC",
            "rank": "تحت الاشراف",
            "role_qualification": "دراسة",
            "fund_status": "IN",
            "requires_coaching": true, // UI dynamic flag
            "stage_2_fund_rate_pct": 25.00
          },
          {
            "engineer_id": "ENG-QAM-ARC-0001",
            "full_name": "زليخان شوكت علي",
            "discipline": "ARC",
            "rank": "استشاري",
            "role_qualification": "دراسة,تدريب,تدقيق",
            "fund_status": "IN",
            "requires_coaching": false,
            "eligible_as_supervisor": true // Can act as coach in dropdown
          }
        ]
      }
    }
    ```

---

### [4] Calculate Live Project Estimate
*   **Endpoint**: `POST /api/v1/projects/estimate`
*   **Access**: Authorized (JWT Bound)
*   **Description**: Run dry-run calculations for Category-aware pricing or Supervision Contracts without committing rows to database.
*   **Payload (Category 2 - Unrounded Drug Warehouse Study)**:
    ```json
    {
      "model_type": "BS", // Bayani Study
      "facility_type": "مستودع أدوية", 
      "total_area_m2": 105.00,
      "assignments": [
        { "discipline_code": "ARC", "engineer_id": "ENG-QAM-ARC-0001" }, // Inside, No Coach
        { "discipline_code": "ELE", "engineer_id": "ENG-QAM-ELE-0022" }  // Inside, Trainee (Coach: ARC)
      ]
    }
    ```
*   **Success Response (`200 OK`)**:
    ```json
    {
      "success": true,
      "data": {
        "pricing_summary": {
          "billing_category": 2,
          "formula_applied": "Base $80.00 + Excess s.M * $0.10 (No Rounding)",
          "base_study_fee_usd": 85.50,
          "printing_surcharge_usd": 10.00,
          "client_invoice_total_usd": 95.50
        },
        "workload_splits": {
          "ARC": { "gross_share_pct": 60.00, "gross_fee_usd": 51.30 },
          "ELE": { "gross_share_pct": 40.00, "gross_fee_usd": 34.20 },
          "MCH": { "gross_share_pct": 0.00, "gross_fee_usd": 0.00 }
        },
        "itemized_ledger_payouts": [
          {
            "discipline": "Architecture",
            "engineer_name": "زليخان شوكت علي",
            "fund_status": "IN",
            "has_coach": false,
            "k_factor": 0.6750,
            "deductions": {
              "stage_1_unit_fee_usd": 5.13,
              "stage_2_joint_fund_usd": 11.54,
              "stage_3_coach_fee_usd": 0.00
            },
            "printing_share_usd": 5.00,
            "net_payout_usd": 39.63
          },
          {
            "discipline": "Electrical",
            "engineer_name": "هيم زكي سعدو",
            "fund_status": "IN",
            "has_coach": true, // Triggers due to 'دراسة' only
            "k_factor": 0.5738,
            "deductions": {
              "stage_1_unit_fee_usd": 3.42,
              "stage_2_joint_fund_usd": 7.70,
              "stage_3_coach_fee_usd": 2.59 // 15% holds
            },
            "printing_share_usd": 2.50,
            "net_payout_usd": 22.12
          }
        ]
      }
    }
    ```

---

### [5] Create & Commit Project Booking
*   **Endpoint**: `POST /api/v1/projects`
*   **Access**: Authorized (JWT Bound)
*   **Description**: Inserts a live project into DB, generates dynamic assignments, and sets state to `INV` (Invoiced).
*   **Payload (Model 6 - Supervision Contract)**:
    ```json
    {
      "project_id": "SC-QAM-2026-0004",
      "client_name": "جميل عبد الصمد",
      "zone_loc": "المنطقة الغربية الأولى",
      "parcel_no": "2054",
      "prop_no": "12",
      "total_area_m2": 600.00,
      "built_area_footprint_m2": 120.00,
      "active_usd_rate": 15000.00
    }
    ```
*   **Success Response (`201 Created`)**:
    ```json
    {
      "success": true,
      "data": {
        "project_id": "SC-QAM-2026-0004",
        "lifecycle_state": "INV",
        "billed_land_area_m2": 600.00,
        "billed_footprint_m2": 120.00,
        "basic_supervision_fee_usd": 1440.00, // 600 * $2.40
        "sanitary_supervision_fee_usd": 60.00, // <= 250 footprint base flat fee
        "client_invoice_total_usd": 1500.00,
        "assignments_initialized": 5 // Civil, Arch, Mech, Elec, Sanitary stubs
      }
    }
    ```

---

### [6] Document Studio PDF Compilation
*   **Endpoint**: `POST /api/v1/documents/compile`
*   **Access**: Authorized (JWT Bound)
*   **Description**: Calls Python microservice (`generate_pdf_sc.py`) to render and stamp PDF reports with regional logos and cryptographic validation hashes.
*   **Payload**:
    ```json
    {
      "project_id": "SC-QAM-2026-0004",
      "document_type": "SC-INV" // "SC-INV", "SC-EPO", "SC-FSD"
    }
    ```
*   **Success Response (`200 OK`)**:
    ```json
    {
      "success": true,
      "data": {
        "document_id": "doc_sc_qam_2026_0004_inv",
        "file_name": "sc-client-invoice.pdf",
        "download_url": "https://syndicate-portal.gov/dl/QAM/doc_sc_qam_2026_0004_inv.pdf",
        "document_metadata": {
          "pages": 1,
          "branding_branch": "QAM",
          "seal_status": "CERTIFIED_OFFICIAL",
          "qr_code_payload": "https://syndicate-portal.gov/verify/SC-QAM-2026-0004"
        }
      }
    }
    ```

---

## 3. Financial Reconcilation & Database Flow Webhook

### Project Settlement Hook (`UPDATE /api/v1/projects/:id/settle`)
When the accountant registers physical cash receipt in local branch vaults, they call the settle endpoint. This transitions `lifecycle_state` from `'INV'` to `'SETTLED'`.

```
[Accountant clicks Settle]
       │
       ▼
1. PUT /projects/SC-QAM-004/settle (receipt_no = "REC-9104")
       │
       ▼
2. SQL: UPDATE model_6_projects SET lifecycle_state = 'SETTLED', receipt_no = 'REC-9104' ...
       │
       ▼
3. DB TRIGGER (trg_release_escrow_on_settlement_model_6) fires:
   ├── Unlocks assignees payout_state = 'EARNED'
   └── Logs itemized entries into model_6_syndicate_contributions:
       ├── Joint Funds (FUND_JOINT_CIVIL_ARCH_WATER_GEO or FUND_JOINT_ELEC_MECH)
       └── Audit Funds (NULL for Model 6, or FUND_AUDIT_... for Model 1/3)
       │
       ▼
4. DB TRIGGER (trg_archive_bayani_report for Model 5/7) fires:
   └── Serializes complete, immutable ledger snapshot into bayani_reports_archive JSONB
       │
       ▼
5. WS Trigger: Emits "ledger.reconciled" socket event to active UI clients.
   └── Dashboard reconciliation footer transitions to "Perfect Balance (Discrepancy: $0.00)"
```
