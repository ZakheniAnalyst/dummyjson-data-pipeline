import pandas as pd
import snowflake.connector
from cryptography.hazmat.primitives import serialization

key = serialization.load_pem_private_key(open("dbt_key.p8", "rb").read(), None)
der = key.private_bytes(
    serialization.Encoding.DER,
    serialization.PrivateFormat.PKCS8,
    serialization.NoEncryption(),
)

conn = snowflake.connector.connect(
    account="bt32729.af-south-1.aws", user="SELUENGINEER",
    private_key=der, warehouse="DUMMYJSON_WH",
    database="DUMMYJSON_DB", schema="MARTS",
)
for t in ["fct_cart_items", "dim_users"]:
    pd.read_sql(f"select * from {t}", conn).to_csv(f"{t}.csv", index=False)
    print("wrote", t)