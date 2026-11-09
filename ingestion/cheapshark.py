import requests
import time

url = 'https://www.cheapshark.com/api/1.0/deals'

# curl -sSf -A "local-data-platform/0.1 (github.com/alpett/local-data-platform)" "https://www.cheapshark.com/api/1.0/deals?pageSize=60"
# curl -sSf -A "local-data-platform/0.1 (github.com/alpett/local-data-platform)" "https://www.cheapshark.com/api/1.0/stores?"
# Steam (1), GOG (7), Epic Games Store (25) and Humble Store (11)

stores = [7]
page_size = 60

headers = {'user-agent': 'local-data-platform/0.1 (github.com/alpett/local-data-platform)'}

bands = [(0, 5), (5, 10), (10, 20), (20, 40)]

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
            r = requests.get(url, headers = headers, timeout=10, params = params)
            if r.status_code != 200:
                print(f"store {s}, band {lower}-{upper}, page {p}: status {r.status_code}")
                break
            deals = r.json() # define deals to not reparse json every time with r.json()
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