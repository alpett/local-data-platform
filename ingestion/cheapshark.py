import requests
import time
import os
import uuid
import hashlib
import psycopg
from dotenv import load_dotenv
from datetime import datetime, timezone
from psycopg.types.json import Jsonb
import sys

url = 'https://www.cheapshark.com/api/1.0/deals'

# Steam (1), GOG (7), Epic Games Store (25) and Humble Store (11)
stores = [1, 7, 25, 11]

# Set the page size
page_size = 60

headers = {'user-agent': 'local-data-platform/0.1 (github.com/alpett/local-data-platform)'}

# Define the price bands (lower price, upper price)
bands = [(0, 1), (1, 2), (2, 3), (3, 5), (5, 10), (10, 20), (20, 40)]

request_delay = 15

# Load postgres credentials and define connection parameters
load_dotenv()
conn = psycopg.connect(host="127.0.0.1", port=5432, dbname=os.environ["POSTGRES_DB"], user=os.environ["POSTGRES_USER"], password=os.environ["POSTGRES_PASSWORD"])

# Define a run id as uuid
run_id = uuid.uuid4()

deals_table = "landing.cheapshark_deals"
stores_table = "landing.cheapshark_stores"

def fetch(url, params = None, headers = headers):
    max_attempts = 3
    for attempt in range(max_attempts):
        try:
            r = requests.get(url, headers = headers, timeout = (5, 30), params = params)
            if not (r.status_code >= 500 or r.status_code == 408) or attempt == (max_attempts - 1):
                break  # 200, any other 4xx, or last attempt: keep this response
        except (requests.exceptions.Timeout, requests.exceptions.ConnectionError):
            if attempt == (max_attempts - 1):  # No response to save, so give up
                raise
        time.sleep(5 * (attempt + 1))  # Waits 5 seconds, then 10

    fetched_at = datetime.now(timezone.utc)
    return r, fetched_at

def save_response(table, r, fetched_at, params = None):
    # Define SQL query with placeholder values (%s)
    sql = f"""
    insert into {table}
    (run_id, request_url, request_params, http_status, fetched_at, payload, payload_hash)
    values (%s, %s, %s, %s, %s, %s, %s)
    """
    if r.status_code == 200:
        payload = Jsonb(r.json())
        payload_hash = hashlib.sha256(r.content).hexdigest() # Hash of the content otherwise payload and the hash are None

    else:
        payload = None
        payload_hash = None

    conn.execute(sql, (run_id, r.url, Jsonb(params or {}), r.status_code, fetched_at, payload, payload_hash))
    conn.commit()




for s in stores:
    for lower, upper in bands:
        # Pages 0-50 are valid; page 51 returns HTTP 400 (API cap, ~3,060 rows per query)
        for p in range(0, 51):
            params = {'lowerPrice': lower,
                      'upperPrice': upper, 
                      'sortBy' : 'Title',
                      'onSale' : 1,
                      'pageNumber' : p,
                      'storeID' : s,
                      'pageSize' : page_size
                    }
            r, fetched_at = fetch(url, params, headers)

            save_response(deals_table, r, fetched_at, params)

            # Stop the whole run on any non-200 response
            if r.status_code != 200:
                sys.exit(f"store {s}, band {lower}-{upper}, page {p}: status {r.status_code}, run stopped")
            
            time.sleep(request_delay)
            
            deals = r.json()

            if len(deals) == 0:
                print(f"store {s}, band {lower}-{upper}, page {p}: no deals")
                break
            prices = [float(d['salePrice']) for d in deals]
            print(f"store {s}, band {lower}-{upper}, page {p}: {len(deals)} deals, price {min(prices)}-{max(prices)}")
            if len(deals) < page_size: 
                break
        else:
            print(f"store {s}, band {lower}-{upper}: hit page 50, truncated")

        


url = 'https://www.cheapshark.com/api/1.0/stores'

r, fetched_at = fetch(url, headers = headers)

save_response(stores_table, r, fetched_at)

if r.status_code != 200:
    sys.exit(f"stores: status {r.status_code}, run stopped")


# Close the conection
conn.close()