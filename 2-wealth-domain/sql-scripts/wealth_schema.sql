-- =============================================================================
-- Group 2: Wealth Domain - Portfolio, Holdings & NAV Schema
-- Entities: Investment_Account, Portfolio, Asset_Class, Security_Holding, 
--           Market_Price_Feed, Daily_NAV_Ledger
-- =============================================================================

-- 1. Investment Account Entity (Receives inflows from Premium_Invoice)
CREATE TABLE IF NOT EXISTS Investment_Account (
    account_id          VARCHAR(36) PRIMARY KEY,
    account_number      VARCHAR(50) NOT NULL UNIQUE,
    account_name        VARCHAR(100) NOT NULL,
    account_type        VARCHAR(50) NOT NULL, -- e.g., 'RESERVE', 'GROWTH', 'OPERATIONAL_LIQUIDITY'
    currency_code       VARCHAR(3) NOT NULL DEFAULT 'USD',
    current_cash_balance NUMERIC(18, 4) NOT NULL DEFAULT 0.0000,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Portfolio Entity (Aggregates assets and manages reserves for Claim_Payment)
CREATE TABLE IF NOT EXISTS Portfolio (
    portfolio_id        VARCHAR(36) PRIMARY KEY,
    account_id          VARCHAR(36) NOT NULL,
    portfolio_name      VARCHAR(100) NOT NULL,
    target_risk_level   VARCHAR(20) NOT NULL, -- e.g., 'CONSERVATIVE', 'BALANCED', 'AGGRESSIVE'
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_portfolio_account FOREIGN KEY (account_id) REFERENCES Investment_Account(account_id)
);

-- 3. Asset Class Entity
CREATE TABLE IF NOT EXISTS Asset_Class (
    asset_class_id      VARCHAR(36) PRIMARY KEY,
    class_name          VARCHAR(50) NOT NULL UNIQUE, -- e.g., 'EQUITY', 'FIXED_INCOME', 'CASH_EQUIVALENT'
    liquidity_tier      VARCHAR(20) NOT NULL,        -- e.g., 'T0_IMMEDIATE', 'T1_DAILY', 'T30_MONTHLY'
    description         TEXT
);

-- 4. Security Holding Entity
CREATE TABLE IF NOT EXISTS Security_Holding (
    holding_id          VARCHAR(36) PRIMARY KEY,
    portfolio_id        VARCHAR(36) NOT NULL,
    asset_class_id      VARCHAR(36) NOT NULL,
    security_symbol     VARCHAR(20) NOT NULL,        -- e.g., 'AAPL', 'US10Y', 'VMFXX'
    security_name       VARCHAR(100) NOT NULL,
    quantity            NUMERIC(18, 6) NOT NULL,     -- High-precision for fractional shares
    average_cost_basis  NUMERIC(18, 4) NOT NULL,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_holding_portfolio FOREIGN KEY (portfolio_id) REFERENCES Portfolio(portfolio_id),
    CONSTRAINT fk_holding_class FOREIGN KEY (asset_class_id) REFERENCES Asset_Class(asset_class_id),
    CONSTRAINT uq_portfolio_symbol UNIQUE (portfolio_id, security_symbol)
);

-- 5. Market Price Feed Entity (Time-series daily valuation)
CREATE TABLE IF NOT EXISTS Market_Price_Feed (
    price_feed_id       VARCHAR(36) PRIMARY KEY,
    security_symbol     VARCHAR(20) NOT NULL,
    pricing_date        DATE NOT NULL,
    closing_price       NUMERIC(18, 4) NOT NULL,
    currency_code       VARCHAR(3) NOT NULL DEFAULT 'USD',
    feed_source         VARCHAR(50) NOT NULL, -- e.g., 'BLOOMBERG', 'REFINITIV', 'INTERNAL'
    recorded_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_symbol_pricing_date UNIQUE (security_symbol, pricing_date)
);

-- 6. Daily NAV Ledger Entity (Temporal record for historical NAV calculations)
CREATE TABLE IF NOT EXISTS Daily_NAV_Ledger (
    nav_ledger_id       VARCHAR(36) PRIMARY KEY,
    portfolio_id        VARCHAR(36) NOT NULL,
    valuation_date      DATE NOT NULL,
    gross_asset_value   NUMERIC(18, 4) NOT NULL,
    total_liabilities   NUMERIC(18, 4) NOT NULL DEFAULT 0.0000,
    net_asset_value     NUMERIC(18, 4) NOT NULL, -- GAV - Total Liabilities
    total_shares_units  NUMERIC(18, 6) NOT NULL,
    nav_per_unit        NUMERIC(18, 6) NOT NULL, -- NAV / Total Units
    calculated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_nav_portfolio FOREIGN KEY (portfolio_id) REFERENCES Portfolio(portfolio_id),
    CONSTRAINT uq_portfolio_valuation_date UNIQUE (portfolio_id, valuation_date)
);

-- Indexes for time-series and query performance
CREATE INDEX IF NOT EXISTS idx_portfolio_account ON Portfolio(account_id);
CREATE INDEX IF NOT EXISTS idx_holding_portfolio ON Security_Holding(portfolio_id);
CREATE INDEX IF NOT EXISTS idx_price_feed_symbol_date ON Market_Price_Feed(security_symbol, pricing_date);
CREATE INDEX IF NOT EXISTS idx_nav_portfolio_date ON Daily_NAV_Ledger(portfolio_id, valuation_date);
