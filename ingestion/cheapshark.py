import requests
import time
import os
import uuid
import hashlib
import psycopg
from dotenv import load_dotenv
from datetime import datetime, timezone
from psycopg.types.json import Jsonb

url = 'https://www.cheapshark.com/api/1.0/deals'

# curl -sSf -A "local-data-platform/0.1 (github.com/alpett/local-data-platform)" "https://www.cheapshark.com/api/1.0/deals?upperPrice=0"
# curl -sSf -A "local-data-platform/0.1 (github.com/alpett/local-data-platform)" "https://www.cheapshark.com/api/1.0/stores?"

# Steam (1), GOG (7), Epic Games Store (25) and Humble Store (11)
stores = [1, 7, 25, 11]

# Set the page size
page_size = 60

headers = {'user-agent': 'local-data-platform/0.1 (github.com/alpett/local-data-platform)'}

# Define the price bands (lower price, upper price)
bands = [(0, 1), (1, 2), (2, 3), (3, 5), (5, 10), (10, 20), (20, 40)]

# Load postgres credentials and define connection parameters
load_dotenv()
conn = psycopg.connect(host="127.0.0.1", port=5432, dbname=os.environ["POSTGRES_DB"], user=os.environ["POSTGRES_USER"], password=os.environ["POSTGRES_PASSWORD"])

# Define a run id as uuid
run_id = uuid.uuid4()

# Define SQL query with placeholder values (%s)
sql = """
insert into landing.cheapshark_deals
(run_id, request_url, request_params, http_status, fetched_at, payload, payload_hash)
values (%s, %s, %s, %s, %s, %s, %s)
"""


for s in stores:
    for lower, upper in bands:
        # pages 0-50 are valid; page 51 returns HTTP 400 (API cap, ~3,060 rows per query)
        for p in range(0, 51):
            params = {'lowerPrice': lower,
                      'upperPrice': upper, 
                      'sortBy' : 'Title',
                      'onSale' : 1,
                      'pageNumber' : p,
                      'storeID' : s,
                      'pageSize' : page_size
                    }
            for attempt in range(3):
                try:
                    r = requests.get(url, headers = headers, timeout=(5,30), params = params)
                    break # success: leave the retry loop
                except (requests.exceptions.Timeout, requests.exceptions.ConnectionError):
                    if attempt == 2: # This is the last attempt: give up
                        raise
                    time.sleep(2 * (attempt + 1)) # First sleep is 2 seconds, then 4
            fetched_at = datetime.now(timezone.utc)
            if r.status_code == 200:
                deals = r.json() # define deals to not reparse json every time with r.json()
                payload = Jsonb(deals)
                payload_hash = hashlib.sha256(r.content).hexdigest() # Hash of the content otherwise payload and the hash are None

            else:
                payload = None
                payload_hash = None

            conn.execute(sql, (run_id, r.url, Jsonb(params), r.status_code, fetched_at, payload, payload_hash))
            conn.commit()

            # Repeat the if to break the loop, the first if is to save the results
            if r.status_code != 200:
                print(f"store {s}, band {lower}-{upper}, page {p}: status {r.status_code}")
                break

            if len(deals) == 0:
                print(f"store {s}, band {lower}-{upper}, page {p}: no deals")
                break
            prices = [float(d['salePrice']) for d in deals]
            print(f"store {s}, band {lower}-{upper}, page {p}: {len(deals)} deals, price {min(prices)}-{max(prices)}")
            if len(deals) < page_size: 
                break
            print(r.elapsed.total_seconds())
            time.sleep(2)
        else:
            print(f"store {s}, band {lower}-{upper}: hit page 50, truncated")

        



# Close the conection
conn.close()