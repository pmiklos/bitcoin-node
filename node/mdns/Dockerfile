FROM python:3.11-alpine

WORKDIR /app

RUN pip install --no-cache-dir zeroconf ifaddr

COPY publisher.py .

CMD ["python", "-u", "publisher.py"]
