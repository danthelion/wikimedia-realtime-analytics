import json
import os

from kafka import KafkaProducer, KafkaAdminClient
import sseclient

import requests
from kafka.admin import NewTopic

BOOTSTRAP_SERVERS = (
    "broker:19092" if os.getenv("RUNTIME_ENVIRONMENT") == "DOCKER" else "localhost:9092"
)

CHANGE_EVENTS_URL = "https://stream.wikimedia.org/v2/stream/recentchange"
TOPIC = "recentchange"


def create_topic_if_not_exists(topic: str) -> None:
    admin_client = KafkaAdminClient(
        bootstrap_servers=BOOTSTRAP_SERVERS, client_id="wikidata-producer"
    )
    existing_topics = admin_client.list_topics()
    if topic not in existing_topics:
        admin_client.create_topics(
            [NewTopic(topic, num_partitions=1, replication_factor=1)]
        )
        print(f"Created topic {topic}")
    else:
        print(f"Topic {topic} already exists")


def produce_events_from_url(url: str, topic: str) -> None:
    producer = KafkaProducer(
        bootstrap_servers=BOOTSTRAP_SERVERS, client_id="wikidata-producer"
    )
    response = requests.get(url, headers={"Accept": "text/event-stream"}, stream=True)
    client = sseclient.SSEClient(response)
    for event in client.events():
        if event.event == "message":
            try:
                parsed_event_metadata = json.loads(event.id)
                parsed_event_value = json.loads(event.data)
            except ValueError:
                pass
            else:
                key = json.dumps(parsed_event_metadata)
                value = json.dumps(parsed_event_value)
                print(f"Sending event to topic {topic}:\nKEY> {key}\nVALUE> {value}")
                producer.send(
                    topic, value=value.encode("utf-8"), key=key.encode("utf-8")
                )


if __name__ == "__main__":
    create_topic_if_not_exists(TOPIC)
    produce_events_from_url(url=CHANGE_EVENTS_URL, topic=TOPIC)
