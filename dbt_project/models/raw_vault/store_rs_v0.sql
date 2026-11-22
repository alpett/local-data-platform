{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_cheapshark_stores
parent_ref_keys: store_id
src_hashdiff: hd_store_rs
src_payload:
    - store_name
    - is_active
{%- endset -%}      

{{ datavault4dbt.ref_sat_v0(yaml_metadata=yaml_metadata) }}