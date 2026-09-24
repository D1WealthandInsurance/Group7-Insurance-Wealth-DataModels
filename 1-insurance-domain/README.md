# Group 1: Insurance Domain (Policy & Claims)

## Scope & Focus
This domain models the complete lifecycle of insurance customers:
1. Customer onboarding and identity.
2. Underwriting & policy issuance with explicit coverage limits.
3. Premium invoicing and payment tracking.
4. First Notice of Loss (FNOL) incident reporting.
5. Claims processing, itemized damage assessment, and payout authorization.

---

## Folder Structure
```text
1-insurance-domain/
├── sql-scripts/
├── diagrams/               
└── README.md
```


* **`Coverage_Limits`**: Specific coverage categories, maximum limits, and deductible amounts.
* **`Premium_Invoice`**: Billing schedule, payment status, and inflow ledger references.
* **`FNOL_Report`**: Initial incident recording (date, incident description, reporting party).
* **`Claim_File`**: Formal claim lifecycle tracking, adjudicator assignment, and status.
* **`Damage_Item`**: Granular breakdown of individual damage line items.
* **`Claim_Payment`**: Authorized indemnity disbursements with verification against policy coverage limits.

