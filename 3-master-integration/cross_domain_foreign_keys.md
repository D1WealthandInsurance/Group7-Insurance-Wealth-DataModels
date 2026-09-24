# Cross-Domain Foreign Keys & Integration Bridge

This document specifies the integration architecture between the **Insurance Domain (Group 1)** and the **Wealth Management Domain (Group 2)**.

---

## 🔄 Integration Touchpoints

```text
+-----------------------------------------------------------------------------------+
|                            GROUP 1: INSURANCE DOMAIN                              |
+-----------------------------------------------------------------------------------+
       | (Premium Payment Received)                     ^ (Coverage Limit Verification)
       v                                                |
+-----------------------------------------------------------------------------------+
|                              INTEGRATION BRIDGE                                   |
|   - Premium Inflow: Premium_Invoice.paid_at -> Investment_Account.cash_balance     |
|   - Claims Outflow: Claim_Payment.authorized -> Portfolio.liquid_reserves         |
+-----------------------------------------------------------------------------------+
       |                                                ^
       v                                                | (Solvency / Reserve backing)
+-----------------------------------------------------------------------------------+
|                            GROUP 2: WEALTH DOMAIN                                 |
+-----------------------------------------------------------------------------------+
```

---

## 1. Premium Inflow (Group 1 ➔ Group 2)

* **Business Logic:** When an insured customer pays a `Premium_Invoice`, the funds must transition from policy receivables into an active `Investment_Account` to be deployed into market holdings.
* **Source Entity:** `1-insurance-domain.Premium_Invoice`
* **Target Entity:** `2-wealth-domain.Investment_Account`
* **Relational Bridge Table / Cross-Reference:**
  ```sql
  CREATE TABLE IF NOT EXISTS Premium_Investment_Allocation (
      allocation_id       VARCHAR(36) PRIMARY KEY,
      invoice_id          VARCHAR(36) NOT NULL,
      account_id          VARCHAR(36) NOT NULL,
      allocated_amount    NUMERIC(15, 2) NOT NULL,
      allocated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      CONSTRAINT fk_alloc_invoice FOREIGN KEY (invoice_id) 
          REFERENCES Premium_Invoice(invoice_id),
      CONSTRAINT fk_alloc_account FOREIGN KEY (account_id) 
          REFERENCES Investment_Account(account_id)
  );
  ```

---

## 2. Claims Outflow (Group 1 ➔ Group 2)

* **Business Logic:** When a `Claim_Payment` is authorized following damage assessment against `Coverage_Limits`, capital must be drawn from the company's liquid reserve `Portfolio`.
* **Source Entity:** `1-insurance-domain.Claim_Payment`
* **Target Entity:** `2-wealth-domain.Portfolio`
* **Relational Bridge Table / Cross-Reference:**
  ```sql
  CREATE TABLE IF NOT EXISTS Claim_Disbursement_Reserve (
      disbursement_id     VARCHAR(36) PRIMARY KEY,
      payment_id          VARCHAR(36) NOT NULL,
      portfolio_id        VARCHAR(36) NOT NULL,
      drawn_amount        NUMERIC(15, 2) NOT NULL,
      disbursed_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      CONSTRAINT fk_disb_payment FOREIGN KEY (payment_id) 
          REFERENCES Claim_Payment(payment_id),
      CONSTRAINT fk_disb_portfolio FOREIGN KEY (portfolio_id) 
          REFERENCES Portfolio(portfolio_id)
  );
  ```

---

## 3. Data Integrity & Verification Rules

1. **State Machine Constraint:** A `Claim_Payment` cannot be authorized if the corresponding `Policy_Header.policy_status != 'ACTIVE'`.
2. **Limit Checking:** Sum of `assessed_amount` in `Damage_Item` cannot exceed `Coverage_Limits.limit_amount`.
3. **Liquidity Guard:** A disbursement from `Portfolio` must verify that liquid reserves (`T0_IMMEDIATE` asset class) exceed or equal the `payout_amount` before finalizing settlement.

