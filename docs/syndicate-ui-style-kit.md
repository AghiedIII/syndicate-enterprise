# 🌌 Engineering Syndicate: Futuristic UI/UX Style Kit (نظام الهوية البصرية المطور)

This document serves as the **Master UI/UX Design System Specification** for frontend developers building the **Engineering Syndicate Ledger Platform**. It defines the visual DNA, color tokens, typography scales, bento-grid guidelines, and component behaviors required to build a world-class, futuristic, multi-tenant ledger application.

---

## 1. Visual DNA: The "Hyper-Ledger" Concept
The platform's aesthetic is built around **absolute clarity, high-integrity data visualization, and localized administrative isolation**. By combining a premium, deep-dark canvas with vibrant, branch-specific neon glows, the interface feels like an advanced financial operations center.

```
+------------------------------------------------------------+
|  THEME: Obsidian Deep Space & High-Frequency Neon Glows     |
|  - Obsidian BG (#0B0F19) & Jet Slate Surface (#151D30)     |
|  - Interactive Bento-Grid Cards with Micro-Glow Borders    |
|  - Auto-Branch Color Shifting based on Active Login Unit    |
+------------------------------------------------------------+
```

---

## 2. Tokenized Color System (لوحة الألوان الرقمية)

### A. Core Canvas Colors
These foundational shades establish the deep dark-mode theme, offering high contrast and rich visual depth:
*   **`color-bg-primary`**: `#0B0F19` (Obsidian Deep Space — primary page background).
*   **`color-bg-surface`**: `#151D30` (Jet Slate — bento cards, tables, modal containers).
*   **`color-border-card`**: `#1E2942` (Muted Steel — default card borders).
*   **`color-border-hover`**: `#2C3B5E` (Interactive border highlighting).
*   **`color-text-primary`**: `#F8FAFC` (Glacial White — maximum readability for titles and values).
*   **`color-text-secondary`**: `#94A3B8` (Cool Slate — body prose, labels, and metadata).

### B. Multi-Tenant Branch Glows
When an accountant logs in, the entire dashboard's accent theme (borders, glowing status indicators, navigation highlights, and buttons) dynamically shifts color to represent their branch, ensuring they are always visually grounded in their isolated workspace:
*   **Hasakah Branch (`HAS`)**: **Emerald Aurora (`#00E676`)**
    *   *Glow Filter*: `drop-shadow(0 0 8px rgba(0, 230, 118, 0.4))`
*   **Qamishli Branch (`QAM`)**: **Electric Cyan (`#00E5FF`)**
    *   *Glow Filter*: `drop-shadow(0 0 8px rgba(0, 229, 255, 0.4))`
*   **Derik Branch (`DER`)**: **Neon Violet (`#D500F9`)**
    *   *Glow Filter*: `drop-shadow(0 0 8px rgba(213, 0, 249, 0.4))`

### C. Financial Integrity Status Colors
*   **Perfect Balance (`$0.00` discrepancy)**: **Radiant Jade (`#00F5D4`)** — Used for verified reconciliation badges.
*   **Escrow Held / Pending**: **Cyber Amber (`#FFD166`)** — Indicates transaction locked in escrow state.
*   **Alert / Deficit**: **Crimson Flare (`#FF5252`)** — Highlights mismatched ledger balances.

---

## 3. Typography Scale (المقاييس الطباعية الرقمية)

The application utilizes **Roboto** for numbers and Latin text to ensure sleek, geometric formatting, and **DejaVu Sans** (or **Cairo** as a web-safe alternative) for highly legible Arabic rendering.

| Token | Font Size (pt/rem) | Weight | Line Height | Color | Primary Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `font-scale-giant` | `32pt / 2.0rem` | `700 (Bold)` | `1.2` | `color-text-primary` | Hero values, KPI totals, landing titles |
| `font-scale-title` | `24pt / 1.5rem` | `700 (Bold)` | `1.3` | `color-text-primary` | Main section titles, Login Headers |
| `font-scale-heading` | `16pt / 1.0rem` | `600 (Semibold)` | `1.4` | `color-text-primary` | Bento Card titles, modal headers |
| `font-scale-body` | `11pt / 0.75rem` | `400 (Regular)` | `1.5` | `color-text-secondary` | Paragraphs, description lists, metadata |
| `font-scale-table` | `10pt / 0.65rem` | `400 (Regular)` | `1.3` | `color-text-primary` | Table cells, transaction grids |
| `font-scale-mono` | `10pt / 0.65rem` | `500 (Mono)` | `1.2` | `color-text-primary` | System codes (`BS-RPT-...`), project IDs |

---

## 4. Bento-Grid Layout System
The main dashboards utilize a modular **Bento-Grid layout** to organize complex technical inputs and financial metrics into neat, digestible visual containers:

```
+------------------------------------+-----------------------+
|  BENTO CARD 1: ACTIVE OFFICE       |  BENTO CARD 2: QUICK  |
|  - Dynamic Branch Logo & Header    |  - Fast Invoice (INV) |
|  - Localized Accountant Welcome    |  - Metric Counters    |
+------------------------------------+-----------------------+
|  BENTO CARD 3: MAIN DATA LEDGER                            |
|  - Interactive Transaction & Payout Grid                   |
|  - Complete 5-Stage Sequential Cascade Controls            |
+------------------------------------------------------------+
```

### Bento Card Guidelines:
*   **Grid Gap**: `16px / 1rem` standard gutter.
*   **Card Background**: Gradient from `color-bg-surface` to `#101726` at a `145-degree` angle.
*   **Border Radius**: `12px` rounded corners.
*   **Border Styling**: `1px solid color-border-card` with an active transition of `0.2s ease`.
*   **On-Hover Effect**: Scale card to `1.01x`, transition border to `color-border-hover`, and apply a subtle glow matching the active branch code.

---

## 5. UI Component Behavior Specifications

### A. Accountant Multi-Tenant Login Page
1.  **State**: Before authentication, the login screen displays a clean, neutral obsidian canvas with a unified syndicate emblem.
2.  **Authentication Trigger**: The accountant inputs their credentials. The backend verifies their assigned `office_branch` (`HAS`, `QAM`, or `DER`).
3.  **UI Transition**: The moment authentication succeeds, a glowing laser line matching the branch accent color sweeps horizontally across the screen. The dashboard fades in, and the UI shifts elements (headers, scrollbars, active indicators) to the local branch color.
4.  **Tenant Constraint**: The workspace completely hides and locks any route containing data from other cities, enforcing perfect multi-tenant database isolation.

### B. The Live Team Selection & K-Factor Payout Simulator
This component showcases the dynamic mathematical splits of your active schemas:
1.  **Workload Specialty Blocks**: Rendered as interactive slot cards (Architecture, Civil, Electrical, Mechanical, Sanitary, Geotech).
2.  **Dynamic Role Badging**: Displays the engineer's **Role Qualification (مؤهل الدور)**:
    *   If the selected engineer is strictly a junior designer (`دراسة` qualification only), the dashboard renders an amber Trainee outline and dynamically exposes an **"Assign Trainee Coach"** supervisor dropdown.
    *   The trigger immediately updates the calculated **`resolved_k_factor`** card in real time (e.g. dropping an Insider Trainee from `INNO = 0.6750` to `INCO = 0.5738`), updating the estimated net payout.
3.  **Fund Status Badging**: Displays **`IN`** (Insider, 25% Mutual deduction) or **`OU`** (Outsider, 10% Mutual deduction), updating Stage 2 fee calculations.

### C. Category-Aware Bayani Study Sliders (Model 5 & 7)
This controller allows accountants to input measured areas and instantly calculate billing without complex rounding errors:
1.  **Category Selector Tabs**:
    *   *Tab 1: General Pharmacies, Clinics, Labs* (Rounded Up ceiling blocks).
    *   *Tab 2: Drug Warehouses & Cosmetic Centers* (Unrounded linear base pricing of \$80 + \$0.10/m² on excess).
    *   *Tab 3: Hospitals* (Flat unrounded \$0.50/m² rate).
2.  **Slider Component**: A smooth slider mapped to built areas. As the slider drags, the "Calculated Units" and "Base Study Fee" counters cycle values instantly, keeping the math transparent.

### D. The Master Reconciliation Matching Panel
A dedicated bento card at the bottom of the financial summary showing your system's balancing proof:
1.  **The Formula Display**: Displays the mathematical equation:
    `Invoice Total == Engineer Disbursements + Syndicate Deposits`
2.  **The Balance Bar**: A stylized, centered horizontal bar. When the ledger reconciles to exactly `$0.00`, the bar pulses with a thick, glowing **Radiant Jade (`#00F5D4`)** color, displaying a **"Ledger Safely Balanced (0.00 Discrepancy)"** message.
3.  **The Action Trigger**: Reconciled states enable the glowing **"Issue Alphanumeric Al-Bayani Report (SETTLE)"** button, which triggers the backend archival and PDF generation.
