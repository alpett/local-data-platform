{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'base_cheapshark_stores'
ldts: 'load_ts'
rsrc: 'record_source'
hashed_columns:
    hd_store_rs:
        is_hashdiff: true
        columns:
            - store_name
            - is_active
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}