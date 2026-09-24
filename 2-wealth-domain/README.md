# Group 2: Wealth Domain (Portfolio, Holdings, NAV)

## 📌 Scope & Focus
This domain models the financial engine managing the capital collected from insurance premiums, investing it to ensure solvency and yield:
1. Investment account management and capital allocation.
2. Multi-tier portfolio structuring and asset classification.
3. Security holdings tracking with high-precision quantitative fields.
4. Time-series daily market price feeds.
5. Historical Net Asset Value (NAV) ledger generation.

---

## 🗂️ Folder Structure
```text
2-wealth-domain/
├── sql-scripts/
│   └── wealth_schema.sql    # DDL for Investment_Account, Portfolio, Asset_Class,
│                            # Security_Holding, Market_Price_Feed, Daily_NAV_Ledger
├── diagrams/                # Store wealth_erd.drawio and exported ERD images here
└── README.md
```

---

## 🔑 Key Entities to Model
* **`Investment_Account`**: Inflows from paid `Premium_Invoice` records.
* **`Portfolio`**: Asset groupings managing liquidity and risk reserves for `Claim_Payment` obligations.
* **`Asset_Class`**: Equities, Fixed Income, Money Market/Cash Equivalents, Alternatives.
* **`Security_Holding`**: Positions held (ticker, unit count, average cost basis).
* **`Market_Price_Feed`**: Temporal daily price feed for valuation.
* **`Daily_NAV_Ledger`**: End-of-day portfolio valuation ledger capturing assets, liabilities, and calculated NAV.

