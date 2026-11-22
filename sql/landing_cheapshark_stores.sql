CREATE SCHEMA IF NOT EXISTS landing;

CREATE TABLE landing.cheapshark_stores (
    LIKE landing.cheapshark_deals INCLUDING ALL
);