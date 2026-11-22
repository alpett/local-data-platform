{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: stg_cheapshark_stores
ref_keys: store_id
{%- endset -%}      

{{ datavault4dbt.ref_hub(yaml_metadata=yaml_metadata) }}