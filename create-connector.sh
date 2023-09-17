#!/bin/bash

set -e

# Set the Kafka Connect REST API URL
KAFKA_CONNECT_URL="http://localhost:8083/connectors"

# Set the path to your JSON configuration file
CONFIG_FILE_PATH="connector-config.json"

# Check if the config file exists
if [ ! -f "$CONFIG_FILE_PATH" ]; then
  echo "Configuration file not found: $CONFIG_FILE_PATH"
  exit 1
fi

# Define the JSON payload for creating the connector
JSON_PAYLOAD=$(cat "$CONFIG_FILE_PATH")

# Replace <SNOWFLAKE_DATABASE> from .env file
# Read .env file and export it's content as environment variables
[ -f .env ] && . .env
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed "s/<SNOWFLAKE_DATABASE>/$SNOWFLAKE_DATABASE/g")
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed "s/<SNOWFLAKE_ROLE>/$SNOWFLAKE_ROLE/g")
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed "s/<SNOWFLAKE_SCHEMA>/$SNOWFLAKE_SCHEMA/g")
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed "s/<SNOWFLAKE_URL>/$SNOWFLAKE_URL/g")
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed "s/<SNOWFLAKE_USER>/$SNOWFLAKE_USER/g")

# Read private key from file and replace <SNOWFLAKE_PRIVATE_KEY>
# with the private key in the JSON payload

# Read private key from file
PRIVATE_KEY=$(cat "rsa_key.p8")

# escape forward slashes

PRIVATE_KEY=$(echo "$PRIVATE_KEY" | sed 's/\//\\\//g')

# cut first and last line
PRIVATE_KEY=$(echo "$PRIVATE_KEY" | sed '1d;$d')

# remove newlines
PRIVATE_KEY=$(echo "$PRIVATE_KEY" | tr -d '\n')

echo "Private key:"
echo "$PRIVATE_KEY"

# Replace <SNOWFLAKE_PRIVATE_KEY> with the private key in the JSON payload, careful with special characters
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed "s/<SNOWFLAKE_PRIVATE_KEY>/$PRIVATE_KEY/g")

echo "Creating the connector with the following configuration:"
echo "$JSON_PAYLOAD"

# Send a POST request to create the Kafka Connect connector
response=$(curl -X POST -H "Content-Type: application/json" --data "$JSON_PAYLOAD" "$KAFKA_CONNECT_URL")

# Check the response from the Kafka Connect REST API
if [ $? -eq 0 ]; then
  echo "Connector created successfully."
  echo "Response from Kafka Connect:"
  echo "$response"
else
  echo "Failed to create the connector."
  echo "Response from Kafka Connect:"
  echo "$response"
  exit 1
fi
