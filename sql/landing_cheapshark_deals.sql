CREATE SCHEMA IF NOT EXISTS landing;

CREATE TABLE IF NOT EXISTS landing.cheapshark_deals (
    id              bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    run_id          uuid        NOT NULL,
    request_url     text        NOT NULL,
    request_params  jsonb       NOT NULL,
    http_status     integer     NOT NULL,
    fetched_at      timestamptz NOT NULL,
    loaded_at       timestamptz NOT NULL DEFAULT now(),
    payload         jsonb,
    payload_hash    text
);