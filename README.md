Create Snowflake stuff:
    - Generate private key: `openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt`
    - Generate public key: `openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub`
    - Create Landing table in snowflake (RECORD_METADATA and RECORD_CONTENT variant fields)
    - Create dynamic table that parses landing table with some lag
    - Create downstream dynamic table with aggregations and joins



TOPIC 1 -> LANDING TABLE 1 -> DYNAMIC TABLE 1 -\ 
                                                -> DYNAMIC TABLE 3 -> Streamlit?
TOPIC 2 -> LANDING TABLE 2 -> DYNAMIC TABLE 2 -/