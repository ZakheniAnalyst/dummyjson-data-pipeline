import json
from datetime import datetime, timezone

import boto3
import requests

BASE_URL = "https://dummyjson.com"
BUCKET = "iamnc-dummyjson-raw"
ENDPOINTS = ["products", "users", "carts"]

s3 = boto3.client("s3")


def fetch_all(endpoint: str, page_size: int = 100) -> list:
    """Page through an endpoint until every record is fetched."""
    records, skip = [], 0
    while True:
        resp = requests.get(
            f"{BASE_URL}/{endpoint}",
            params={"limit": page_size, "skip": skip},
            timeout=30,
        )
        resp.raise_for_status()
        body = resp.json()
        batch = body[endpoint]
        records.extend(batch)
        skip += len(batch)
        if not batch or skip >= body["total"]:
            break
    return records


def write_to_s3(endpoint: str, records: list) -> str:
    now = datetime.now(timezone.utc)
    key = (
        f"raw/dummyjson/{endpoint}/"
        f"dt={now:%Y-%m-%d}/{endpoint}_{now:%Y%m%dT%H%M%S}.json"
    )
    s3.put_object(
        Bucket=BUCKET,
        Key=key,
        Body=json.dumps(records).encode("utf-8"),
        ContentType="application/json",
    )
    return key


if __name__ == "__main__":
    for ep in ENDPOINTS:
        data = fetch_all(ep)
        key = write_to_s3(ep, data)
        print(f"{ep}: {len(data)} records -> s3://{BUCKET}/{key}")