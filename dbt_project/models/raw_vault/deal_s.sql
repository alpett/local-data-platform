{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
parent_hashkey: 'hk_deal_h'
src_hashdiff: 'hd_deal_s'
src_payload:
    - store_id
    - sale_price
    - normal_price
    - is_on_sale
    - savings
    - last_change
source_model: 'stg_cheapshark_deals'
{%- endset -%}    

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}