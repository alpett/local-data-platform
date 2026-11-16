{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'base_cheapshark_deals'
ldts: 'load_ts'
rsrc: 'record_source'
hashed_columns:
    hk_deal_h:
        - deal_id
    hk_game_h:
        - game_id
    hk_game_deal_l:
        - game_id
        - deal_id
    hd_deal_s:
        is_hashdiff: true
        columns:
            - store_id
            - internal_name
            - title
            - sale_price
            - normal_price
            - is_on_sale
            - savings
            - metacritic_score
            - metacritic_link
            - steam_rating_text
            - steam_rating_percent
            - steam_rating_count
            - steam_app_id
            - release_date
            - last_change
            - deal_rating
            - thumb
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}