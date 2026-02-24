-- Stock Pipeline Database Schema
-- Run this in Supabase SQL Editor

-- Main stocks table with all ranking data
CREATE TABLE IF NOT EXISTS stocks (
    id TEXT PRIMARY KEY,
    ticker TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    sector TEXT,
    industry TEXT,
    market_cap BIGINT,
    price DECIMAL(10,2),
    
    -- IBD Engine Components
    eps_rating INTEGER CHECK (eps_rating >= 0 AND eps_rating <= 100),
    rs_rating INTEGER CHECK (rs_rating >= 0 AND rs_rating <= 100),
    smr_rating TEXT CHECK (smr_rating IN ('A+', 'A', 'B', 'C', 'D', 'E')),
    acc_dist TEXT CHECK (acc_dist IN ('A+', 'A', 'B', 'C', 'D', 'E')),
    industry_rank INTEGER,
    pct_off_high DECIMAL(5,2),
    
    -- Source Scores
    fmp_score INTEGER CHECK (fmp_score >= 0 AND fmp_score <= 100),
    ibd_score INTEGER CHECK (ibd_score >= 0 AND ibd_score <= 100),
    finviz_score INTEGER CHECK (finviz_score >= 0 AND finviz_score <= 100),
    consensus_score INTEGER CHECK (consensus_score >= 0 AND consensus_score <= 100),
    
    -- Composite Score
    composite_score INTEGER CHECK (composite_score >= 0 AND composite_score <= 100),
    
    -- Technical Data
    rsi DECIMAL(5,2),
    volume BIGINT,
    avg_volume BIGINT,
    price_change_pct DECIMAL(5,2),
    
    -- Pipeline Status
    status TEXT DEFAULT 'ranked' CHECK (status IN ('ranked', 'watchlist', 'analyzing', 'entered', 'target_hit', 'stopped', 'exited')),
    
    -- Position Tracking (for entered stocks)
    entry_price DECIMAL(10,2),
    target_price DECIMAL(10,2),
    stop_loss DECIMAL(10,2),
    position_size INTEGER,
    entry_date DATE,
    exit_price DECIMAL(10,2),
    exit_date DATE,
    pnl_pct DECIMAL(5,2),
    
    -- Notes & Analysis
    notes TEXT,
    thesis TEXT,
    
    -- Metadata
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;

-- Allow all operations
CREATE POLICY "Allow all" ON stocks
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Indexes for performance
CREATE INDEX idx_stocks_composite ON stocks(composite_score DESC);
CREATE INDEX idx_stocks_status ON stocks(status);
CREATE INDEX idx_stocks_ticker ON stocks(ticker);
CREATE INDEX idx_stocks_sector ON stocks(sector);

-- Activity log for tracking changes
CREATE TABLE IF NOT EXISTS stock_activity (
    id SERIAL PRIMARY KEY,
    stock_id TEXT REFERENCES stocks(id),
    action TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_activity_stock ON stock_activity(stock_id);
CREATE INDEX idx_activity_created ON stock_activity(created_at DESC);

-- Sample data for testing
INSERT INTO stocks (id, ticker, name, sector, industry, market_cap, price, eps_rating, rs_rating, smr_rating, acc_dist, industry_rank, pct_off_high, fmp_score, ibd_score, finviz_score, consensus_score, composite_score, rsi, status) VALUES
('1', 'NVDA', 'NVIDIA Corporation', 'Technology', 'Semiconductors', 3200000000000, 875.50, 95, 92, 'A+', 'A', 3, 5.2, 88, 94, 91, 85, 90, 68.5, 'ranked'),
('2', 'MSFT', 'Microsoft Corporation', 'Technology', 'Software', 3100000000000, 415.20, 92, 88, 'A+', 'B+', 5, 3.1, 90, 89, 87, 92, 90, 62.3, 'ranked'),
('3', 'AVGO', 'Broadcom Inc.', 'Technology', 'Semiconductors', 850000000000, 1450.75, 89, 94, 'A', 'A-', 2, 8.5, 85, 91, 89, 88, 88, 71.2, 'watchlist'),
('4', 'LLY', 'Eli Lilly and Company', 'Healthcare', 'Pharmaceuticals', 720000000000, 780.25, 94, 96, 'A+', 'A+', 1, 2.1, 92, 95, 90, 89, 92, 75.8, 'entered')
ON CONFLICT (id) DO NOTHING;