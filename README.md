# local-data-platform (work in progress)

A small local data platform built with Python, dbt and Data Vault 2.1, running on a single machine. It is built around price data for PC games from the public CheapShark API.

This is a personal project to practise and expand my knowledge of data engineering, analytics and data science. I write all the code myself. I use Claude through the regular chat interface (free plan) as a tutor for troubleshooting and for planning the workflow, not through Claude Code or any other coding agent.

## Current status

- Python ingestion script that pulls game deals from the CheapShark API and stores every response untouched in PostgreSQL (landing layer)
- dbt staging models that flatten the JSON and prepare hash keys and hashdiffs
- Raw Vault in progress, built with the datavault4dbt package: hubs, a link, satellites and record-tracking satellites for deals and games

## Planned

Reference table for stores, dbt tests, orchestration, BI layer, machine learning and CI.

## Stack

- Python (requests, psycopg)
- PostgreSQL 17 in a container (podman)
- dbt with datavault4dbt