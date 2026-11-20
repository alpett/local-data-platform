{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
tracked_hashkey: hk_game_h
source_models:
    - name: stg_cheapshark_deals
      rsrc_static: cheapshark_deals_api
{%- endset -%}    

{{ datavault4dbt.rec_track_sat(yaml_metadata=yaml_metadata) }}