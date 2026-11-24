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
            - sale_price
            - normal_price
            - is_on_sale
            - savings
            - last_change

    hd_deal_rating_s:
        is_hashdiff: true
        columns:
            - deal_rating
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}