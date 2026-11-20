{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
parent_hashkey: 'hk_deal_h'
src_hashdiff: 'hd_deal_rating_s'
src_payload:
    - deal_rating
source_model: 'stg_cheapshark_deals'
{%- endset -%}    

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}