# Group 7: Insurance & Wealth — Data Modeling Project (D1 Deliverable)

This repository contains the data models, relational schemas, and integration specifications for the **D1 Deliverable** of the Insurance & Wealth management platform.

---

## 👥 Team Division & Responsibilities

The team of 10 is divided into two primary domain groups, connected by designated Integration Leads:

### Group 1: Insurance Domain (`1-insurance-domain/`)
* **Focus:** Complete customer lifecycle: from purchasing policy contracts to First Notice of Loss (FNOL) and claim settlement.
* **Core Challenge:** Relational structure allowing an incident (FNOL) to securely check active policy limits before issuing claim payouts.
* **Key Entities:**
  * `Customer`
  * `Policy_Header`
  * `Coverage_Limits`
  * `Premium_Invoice`
  * `FNOL_Report`
  * `Claim_File`
  * `Damage_Item`
  * `Claim_Payment`
* **Learning Focus:** State machines (Active vs. Lapsed policies), 1-to-Many relationships, premium & claims ledgers.

### Group 2: Wealth Domain (`2-wealth-domain/`)
* **Focus:** Capital management & investment engine to ensure corporate solvency and grow collected premiums.
* **Core Challenge:** Time-series data modeling (daily market price feeds) and hierarchical asset holding structures.
* **Key Entities:**
  * `Investment_Account`
  * `Portfolio`
  * `Asset_Class`
  * `Security_Holding`
  * `Market_Price_Feed`
  * `Daily_NAV_Ledger`
* **Learning Focus:** High-precision decimal storage, temporal tables (historical NAV), and Net Asset Value calculation models.

---

## 🌉 The Integration Bridge (`3-master-integration/`)

Designated Integration Leads coordinate cross-domain consistency:
* **Premium Inflow:** Paid `Premium_Invoice` records from Group 1 feed into `Investment_Account` in Group 2 for market allocation.
* **Claims Outflow:** Authorized `Claim_Payment` records from Group 1 draw down liquid reserves held in `Portfolio` in Group 2.

Detailed foreign key mapping and transaction logic are documented in [`3-master-integration/cross_domain_foreign_keys.md`](3-master-integration/cross_domain_foreign_keys.md).

---

## 📂 Monorepo Directory Structure

```text
Group7-Insurance-Wealth-DataModels/
│
├── 1-insurance-domain/
│   ├── sql-scripts/
│   │   ├── policy_schema.sql
│   │   └── claims_schema.sql
│   └── diagrams/
│       └── (Add your insurance_erd.drawio and export images here)
│
├── 2-wealth-domain/
│   ├── sql-scripts/
│   │   └── wealth_schema.sql
│   └── diagrams/
│       └── (Add your wealth_erd.drawio and export images here)
│
└── 3-master-integration/
    ├── cross_domain_foreign_keys.md
    └── (Add your global_ecosystem_erd export images here)
```

---

## 📋 Monorepo Workflow Rules

1. **Stay in your lane:**
   * Group 1 members only modify files in `1-insurance-domain/`.
   * Group 2 members only modify files in `2-wealth-domain/`.
   * Only designated Integration Leads edit `3-master-integration/`.
2. **Diagram Formats:**
   * Place raw editable diagram files (e.g. `.drawio`) in the respective `diagrams/` folder.
   * Also provide exported flattened images (`.png` / `.pdf`) for preview in the repository.
3. **Review Process:**
   * Do not push directly to `main`.
   * Branch out (`feature/<domain>-<feature-name>`), open a Pull Request, and require at least one peer review before merging.
