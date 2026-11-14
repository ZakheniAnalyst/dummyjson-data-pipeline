import os

import snowflake.connector
from cryptography.hazmat.primitives import serialization

key = serialization.load_pem_private_key(
    os.environ["SNOWFLAKE_PRIVATE_KEY"].encode(), password=None
)
der = key.private_bytes(
    serialization.Encoding.DER,
    serialization.PrivateFormat.PKCS8,
    serialization.NoEncryption(),
)

conn = snowflake.connector.connect(
    account=os.environ["SNOWFLAKE_ACCOUNT"],
    user=os.environ["SNOWFLAKE_USER"],
    private_key=der,
    role="ACCOUNTADMIN",
    warehouse="DUMMYJSON_WH",
    database="DUMMYJSON_DB",
    schema="RAW",
)

try:
    cur = conn.cursor()
    for name in ["products", "users", "carts"]:
        cur.execute(f"""
            COPY INTO raw_{name} (v, _source_file)
            FROM (SELECT $1, METADATA$FILENAME FROM @dummyjson_stage/{name}/)
            PATTERN = '.*[.]json'
        """)
        print(name, cur.fetchall())
finally:
    conn.close()