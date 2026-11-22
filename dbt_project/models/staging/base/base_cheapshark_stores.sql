select
    l.run_id,
    min(l.fetched_at) over (partition by l.run_id) as load_ts,
    'cheapshark_stores_api' as record_source,

    -- business keys (kept as text on purpose)
    d.store ->> 'storeID' as store_id,

    -- descriptive attributes
    d.store ->> 'storeName' as store_name,
    cast(d.store ->> 'isActive' as integer) as is_active
from {{ source('landing', 'cheapshark_stores') }} as l
cross join lateral jsonb_array_elements(l.payload) as d(store) -- We attach to the store the run_id and load_ts from the json the store was in
where l.http_status = 200