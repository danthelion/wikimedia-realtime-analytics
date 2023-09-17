FROM python:3.9-slim

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY publish_wikidata_events.py .

ENV RUNTIME_ENVIRONMENT="DOCKER"

CMD ["python", "./publish_wikidata_events.py"]
