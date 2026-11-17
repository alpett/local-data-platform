{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
link_hashkey: 'hk_game_deal_l'
foreign_hashkeys: 
    - 'hk_game_h'
    - 'hk_deal_h'
source_models: stg_cheapshark_deals
{%- endset -%}    

{{ datavault4dbt.link(yaml_metadata=yaml_metadata) }}