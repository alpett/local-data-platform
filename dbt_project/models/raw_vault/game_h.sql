{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
hashkey: 'hk_game_h'
business_keys: 
    - game_id
source_models: stg_cheapshark_games
{%- endset -%}

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}