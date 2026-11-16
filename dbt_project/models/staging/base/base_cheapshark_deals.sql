select
    l.run_id,
    min(l.fetched_at) over (partition by l.run_id)                   as load_ts,
    'cheapshark_deals_api'                                           as record_source,

    -- business keys (kept as text on purpose)
    d.deal ->> 'dealID'                                              as deal_id,
    d.deal ->> 'gameID'                                              as game_id,
    d.deal ->> 'storeID'                                             as store_id,

    -- descriptive attributes
    d.deal ->> 'internalName'                                        as internal_name,
    d.deal ->> 'title'                                               as title,
    cast(d.deal ->> 'salePrice' as decimal(10,2))                    as sale_price,
    cast(d.deal ->> 'normalPrice' as decimal(10,2))                  as normal_price,
    cast(cast(d.deal ->> 'isOnSale' as integer) as boolean)          as is_on_sale,
    cast(d.deal ->> 'savings' as decimal(12,6))                      as savings,
    cast(nullif(d.deal ->> 'metacriticScore', '') as integer)        as metacritic_score,
    d.deal ->> 'metacriticLink'                                      as metacritic_link,
    d.deal ->> 'steamRatingText'                                     as steam_rating_text,
    cast(nullif(d.deal ->> 'steamRatingPercent', '') as integer)     as steam_rating_percent,
    cast(nullif(d.deal ->> 'steamRatingCount', '') as integer)       as steam_rating_count,
    d.deal ->> 'steamAppID'                                          as steam_app_id,
    to_timestamp(cast(d.deal ->> 'releaseDate' as bigint))           as release_date,
    to_timestamp(cast(d.deal ->> 'lastChange' as bigint))            as last_change,
    cast(d.deal ->> 'dealRating' as decimal(4,1))                    as deal_rating,
    d.deal ->> 'thumb'                                               as thumb
from {{ source('landing', 'cheapshark_deals') }} as l
cross join lateral jsonb_array_elements(l.payload) as d(deal) -- We attach to the deal the run_id and load_ts from the json the deal was in
where l.http_status = 200