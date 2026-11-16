{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
hashkey: 'hk_deal_h'
business_keys: 
    - deal_id
source_models: stg_cheapshark_deals
{%- endset -%}

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}