-- AI Expense Receipt Assistant: PostgreSQL schema
-- Run once against the database used by the "Expense Assistant · Postgres" credential.

CREATE TABLE IF NOT EXISTS employees (
    id                        SERIAL PRIMARY KEY,
    full_name                 TEXT        NOT NULL,
    email                     TEXT        UNIQUE,
    department                TEXT        NOT NULL,
    cost_center               TEXT,
    telegram_user_id          BIGINT      UNIQUE NOT NULL,
    manager_telegram_chat_id  BIGINT,
    active                    BOOLEAN     NOT NULL DEFAULT true,
    created_at                TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS expenses (
    id                SERIAL PRIMARY KEY,
    expense_key       TEXT        UNIQUE NOT NULL,
    employee_id       INT         NOT NULL REFERENCES employees(id),
    status            TEXT        NOT NULL CHECK (status IN ('APPROVED', 'REJECTED', 'APPROVAL_TIMEOUT')),
    decision          TEXT        NOT NULL,
    merchant_name     TEXT,
    merchant_tax_id   TEXT,
    merchant_country  CHAR(2),
    receipt_number    TEXT,
    receipt_date      DATE,
    currency          CHAR(3)     NOT NULL,
    payment_method    TEXT,
    category          TEXT        NOT NULL,
    contains_alcohol  BOOLEAN     NOT NULL DEFAULT false,
    subtotal          NUMERIC(12,2),
    tax               NUMERIC(12,2),
    tip               NUMERIC(12,2),
    total             NUMERIC(12,2),
    items             JSONB       NOT NULL DEFAULT '[]',
    policy_flags      JSONB       NOT NULL DEFAULT '[]',
    rejections        JSONB       NOT NULL DEFAULT '[]',
    confidence        NUMERIC(3,2),
    employee_note     TEXT,
    telegram_file_id  TEXT,
    execution_id      TEXT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_expenses_employee_date ON expenses (employee_id, receipt_date);
CREATE INDEX IF NOT EXISTS idx_expenses_created_at   ON expenses (created_at);
CREATE INDEX IF NOT EXISTS idx_expenses_status       ON expenses (status);

-- Example employee (replace IDs with real Telegram user / chat IDs)
-- INSERT INTO employees (full_name, email, department, cost_center, telegram_user_id, manager_telegram_chat_id)
-- VALUES ('Jane Doe', 'jane@yourcompany.com', 'Sales', 'CC-200', 123456789, 987654321);
