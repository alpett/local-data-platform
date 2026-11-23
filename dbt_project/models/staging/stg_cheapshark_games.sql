{%- set yaml_metadata -%}
source_model: 'base_cheapshark_games'
ldts: 'load_ts'
rsrc: 'record_source'
hashed_columns:
    hk_game_h:
        - game_id
    hd_game_s:
        is_hashdiff: true
        columns:
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
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}