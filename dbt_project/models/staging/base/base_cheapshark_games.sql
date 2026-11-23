with ranked as (
    select
        run_id,
        load_ts,
        record_source,
        game_id,
        internal_name,
        title,
        metacritic_score,
        metacritic_link,
        steam_rating_text,
        steam_rating_percent,
        steam_rating_count,
        steam_app_id,
        release_date,
        thumb,
        -- the same game can appear in several deals of the same run:
        -- keep the most recently fetched version
        row_number() over (
            partition by run_id, game_id
            order by fetched_at desc, landing_id desc
        ) as rn
    from {{ ref('base_cheapshark_deals') }}
)

select
    run_id,
    load_ts,
    record_source,
    game_id,
    internal_name,
    title,
    metacritic_score,
    metacritic_link,
    steam_rating_text,
    steam_rating_percent,
    steam_rating_count,
    steam_app_id,
    release_date,
    thumb
from ranked
where rn = 1