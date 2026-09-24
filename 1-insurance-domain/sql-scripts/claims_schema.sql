-- =============================================================================
-- Group 1: Insurance Domain - Claims Processing Schema
-- Entities: FNOL_Report, Claim_File, Damage_Item, Claim_Payment
-- =============================================================================

-- 1. First Notice of Loss (FNOL) Report Entity
CREATE TABLE IF NOT EXISTS FNOL_Report (
    fnol_id             VARCHAR(36) PRIMARY KEY,
    policy_id           VARCHAR(36) NOT NULL,
    incident_date       TIMESTAMP NOT NULL,
    reported_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    incident_location   VARCHAR(255),
    incident_description TEXT NOT NULL,
    reported_by         VARCHAR(100) NOT NULL,
    fnol_status         VARCHAR(20) NOT NULL DEFAULT 'REPORTED'
                        CHECK (fnol_status IN ('REPORTED', 'UNDER_REVIEW', 'ACCEPTED', 'REJECTED')),
    CONSTRAINT fk_fnol_policy FOREIGN KEY (policy_id) REFERENCES Policy_Header(policy_id)
);

-- 2. Claim File Entity
CREATE TABLE IF NOT EXISTS Claim_File (
    claim_id            VARCHAR(36) PRIMARY KEY,
    fnol_id             VARCHAR(36) NOT NULL UNIQUE,
    policy_id           VARCHAR(36) NOT NULL,
    claim_number        VARCHAR(50) NOT NULL UNIQUE,
    adjudicator_id      VARCHAR(36),
    claim_status        VARCHAR(20) NOT NULL DEFAULT 'OPEN'
                        CHECK (claim_status IN ('OPEN', 'INVESTIGATING', 'APPROVED', 'DENIED', 'SETTLED', 'CLOSED')),
    total_claimed       NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    total_approved      NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    opened_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_date         TIMESTAMP,
    CONSTRAINT fk_claim_fnol FOREIGN KEY (fnol_id) REFERENCES FNOL_Report(fnol_id),
    CONSTRAINT fk_claim_policy FOREIGN KEY (policy_id) REFERENCES Policy_Header(policy_id)
);

-- 3. Damage Item Entity (Itemized damages linked to coverage limit checking)
CREATE TABLE IF NOT EXISTS Damage_Item (
    damage_item_id      VARCHAR(36) PRIMARY KEY,
    claim_id            VARCHAR(36) NOT NULL,
    coverage_id         VARCHAR(36) NOT NULL,
    item_description    VARCHAR(255) NOT NULL,
    claimed_amount      NUMERIC(15, 2) NOT NULL,
    assessed_amount     NUMERIC(15, 2) DEFAULT 0.00,
    item_status         VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                        CHECK (item_status IN ('PENDING', 'APPROVED', 'DISPUTED', 'REJECTED')),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_damage_claim FOREIGN KEY (claim_id) REFERENCES Claim_File(claim_id),
    CONSTRAINT fk_damage_coverage FOREIGN KEY (coverage_id) REFERENCES Coverage_Limits(coverage_id)
);

-- 4. Claim Payment Entity (Draws liquid capital from Wealth Management reserves)
CREATE TABLE IF NOT EXISTS Claim_Payment (
    payment_id          VARCHAR(36) PRIMARY KEY,
    claim_id            VARCHAR(36) NOT NULL,
    payment_reference   VARCHAR(50) NOT NULL UNIQUE,
    payout_amount       NUMERIC(15, 2) NOT NULL,
    payment_method      VARCHAR(50) NOT NULL, -- e.g., 'ACH', 'CHECK', 'WIRE'
    payment_status      VARCHAR(20) NOT NULL DEFAULT 'PENDING_APPROVAL'
                        CHECK (payment_status IN ('PENDING_APPROVAL', 'AUTHORIZED', 'DISBURSED', 'RECONCILED', 'CANCELLED')),
    authorized_at       TIMESTAMP,
    disbursed_at        TIMESTAMP,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_claim FOREIGN KEY (claim_id) REFERENCES Claim_File(claim_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_fnol_policy ON FNOL_Report(policy_id);
CREATE INDEX IF NOT EXISTS idx_claim_policy ON Claim_File(policy_id);
CREATE INDEX IF NOT EXISTS idx_claim_status ON Claim_File(claim_status);
CREATE INDEX IF NOT EXISTS idx_damage_claim ON Damage_Item(claim_id);
CREATE INDEX IF NOT EXISTS idx_payment_claim ON Claim_Payment(claim_id);
CREATE INDEX IF NOT EXISTS idx_payment_status ON Claim_Payment(payment_status);
