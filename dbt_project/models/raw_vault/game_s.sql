{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
parent_hashkey: 'hk_game_h'
src_hashdiff: 'hd_game_s'
src_payload:
    - internal_name
    - title
    - metacritic_score
    - metacritic_link
    - steam_rating_text
    - steam_rating_percent
    - steam_rating_count
    - steam_app_id
    - release_date
    - thumb  
source_model: 'stg_cheapshark_deals'
{%- endset -%}    

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}