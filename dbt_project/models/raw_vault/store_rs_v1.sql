{{ config(materialized='view') }}

{%- set yaml_metadata -%}
ref_sat_v0: store_rs_v0
ref_keys: store_id
hashdiff: hd_store_rs
add_is_current_flag: true
{%- endset -%}

{{ datavault4dbt.ref_sat_v1(yaml_metadata=yaml_metadata) }}