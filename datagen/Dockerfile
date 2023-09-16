FROM python:3.9-slim

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY publish_wikidata_events.py .

CMD ["python", "./publish_wikidata_events.py"]