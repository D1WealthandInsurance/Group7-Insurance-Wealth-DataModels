-- =============================================================================
-- Group 1: Insurance Domain - Policy & Underwriting Schema
-- Entities: Customer, Policy_Header, Coverage_Limits, Premium_Invoice
-- =============================================================================

-- 1. Customer Entity
CREATE TABLE IF NOT EXISTS Customer (
    customer_id         VARCHAR(36) PRIMARY KEY,
    first_name          VARCHAR(100) NOT NULL,
    last_name           VARCHAR(100) NOT NULL,
    email               VARCHAR(255) NOT NULL UNIQUE,
    phone_number        VARCHAR(20),
    tax_identifier      VARCHAR(50),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Policy Header Entity (State Machine: DRAFT, ACTIVE, LAPSED, EXPIRED, TERMINATED)
CREATE TABLE IF NOT EXISTS Policy_Header (
    policy_id           VARCHAR(36) PRIMARY KEY,
    customer_id         VARCHAR(36) NOT NULL,
    policy_number       VARCHAR(50) NOT NULL UNIQUE,
    policy_type         VARCHAR(50) NOT NULL, -- e.g., 'PROPERTY', 'CASUALTY', 'LIFE'
    policy_status       VARCHAR(20) NOT NULL DEFAULT 'DRAFT'
                        CHECK (policy_status IN ('DRAFT', 'ACTIVE', 'LAPSED', 'EXPIRED', 'TERMINATED')),
    effective_date      DATE NOT NULL,
    expiration_date     DATE NOT NULL,
    total_premium       NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_policy_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- 3. Coverage Limits Entity
CREATE TABLE IF NOT EXISTS Coverage_Limits (
    coverage_id         VARCHAR(36) PRIMARY KEY,
    policy_id           VARCHAR(36) NOT NULL,
    coverage_name       VARCHAR(100) NOT NULL, -- e.g., 'BODILY_INJURY', 'PROPERTY_DAMAGE'
    limit_amount        NUMERIC(15, 2) NOT NULL,
    deductible_amount   NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_coverage_policy FOREIGN KEY (policy_id) REFERENCES Policy_Header(policy_id)
);

-- 4. Premium Invoice Entity (Feeds into Wealth Management Investment Account)
CREATE TABLE IF NOT EXISTS Premium_Invoice (
    invoice_id          VARCHAR(36) PRIMARY KEY,
    policy_id           VARCHAR(36) NOT NULL,
    invoice_number      VARCHAR(50) NOT NULL UNIQUE,
    due_date            DATE NOT NULL,
    amount_due          NUMERIC(15, 2) NOT NULL,
    amount_paid         NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    payment_status      VARCHAR(20) NOT NULL DEFAULT 'UNPAID'
                        CHECK (payment_status IN ('UNPAID', 'PARTIALLY_PAID', 'PAID', 'OVERDUE', 'CANCELLED')),
    paid_at             TIMESTAMP,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoice_policy FOREIGN KEY (policy_id) REFERENCES Policy_Header(policy_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_policy_customer ON Policy_Header(customer_id);
CREATE INDEX IF NOT EXISTS idx_policy_status ON Policy_Header(policy_status);
CREATE INDEX IF NOT EXISTS idx_coverage_policy ON Coverage_Limits(policy_id);
CREATE INDEX IF NOT EXISTS idx_invoice_policy ON Premium_Invoice(policy_id);
CREATE INDEX IF NOT EXISTS idx_invoice_status ON Premium_Invoice(payment_status);
