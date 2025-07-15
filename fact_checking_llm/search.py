import os
from googleapiclient.discovery import build
from urllib.parse import urlparse

TRUSTED_DOMAINS = ["vnexpress.net", "24h.com.vn", "dantri.com.vn", "tuoitre.vn", "baomoi.com", "vietnamnet.vn", "zingnews.vn", "thanhnien.vn", "laodong.vn", "plo.vn", "bbc.com"] ##RAG 

def is_trusted_source(url):
    domain = urlparse(url).netloc
    return any(trusted in domain for trusted in TRUSTED_DOMAINS)

def search_google(query, num_results=5):
    try:
        res = build("customsearch", "v1", developerKey=os.getenv("GOOGLE_SEARCH_API_KEY")).cse().list(q=query, cx=os.getenv("GOOGLE_SEARCH_CX"), num=num_results).execute()
        search_result = []

        if 'items' in res:
            for item in res['items']:
                search_result.append({
                    "title": item.get('title'),
                    "link": item.get('link'),
                    "snippet": item.get('snippet'),
                    "trusted": is_trusted_source(item.get('link'))
                })
        return search_result
    except Exception as e:
        print(f"Lỗi khi tìm kiếm {e}.")
        return []