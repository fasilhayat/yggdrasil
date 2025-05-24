# Civitas Monitoring with Prometheus and Grafana

This guide explains how to integrate **Prometheus** and **Grafana** with the **Civitas REST API** to monitor real-time metrics. The setup assumes the Civitas API exposes a `/metrics` endpoint compatible with Prometheus.

---

## 🧱 Prerequisites

* Docker and Docker Compose installed
* Civitas API exposing metrics at `/metrics` (e.g. using `prometheus-net.AspNetCore`)
* External Docker network named `civitas` created:

  ```bash
  docker network create civitas
  ```

---

## 📦 Project Structure

```
.
├── docker-compose.yml
├── prometheus
│   └── prometheus.yml
├── certs/
├── conf/
│   └── nginx/
├── logs/
└── README.md
```

---

## 💠 Docker Compose Configuration

Ensure your `docker-compose.yml` includes the following relevant services:

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9092:9090"
    restart: always
    networks:
      - civitas

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    restart: always
    networks:
      - civitas

  civitas-api:
    image: civitas-api
    container_name: api
    build:
      context: .
      dockerfile: Civitas.Api/Dockerfile
    ports:
      - "7080:7080"
      - "7081:7081"
    environment:
      - ASPNETCORE_URLS=https://+:7081;http://+:7080
      - Kestrel__Certificates__Default__Password=yourpassword
      - Kestrel__Certificates__Default__Path=/https/yourcert.pfx
      - ASPNETCORE_ENVIRONMENT=Development
      - API_KEY=yourapikey
      - Redis__ConnectionString=civitas-cache:6379
    networks:
      - civitas

networks:
  civitas:
    external: true
```

---

## 📊 Prometheus Configuration

Create the file `prometheus/prometheus.yml` with the following content:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'civitas'
    metrics_path: /metrics
    scheme: https
    static_configs:
      - targets: ['host.docker.internal:7081']
```

---

## 🚀 Run the Stack

Start the services:

```bash
docker-compose up -d
```

Verify running containers:

```bash
docker ps
```

---

## 🔎 Verify Prometheus Is Scraping Metrics

Open the Prometheus UI:

> [http://localhost:9092/targets](http://localhost:9092/targets)

* Confirm that the `civitas` job is shown as `UP`
* Click the job to inspect scrape status and duration

---

## 📊 Configure Grafana

1. Open Grafana: [http://localhost:3000](http://localhost:3000)

2. Log in with:

   * Username: `admin`
   * Password: `admin`

3. Navigate to: **Configuration → Data Sources → Add data source**

4. Select **Prometheus**

5. Set the URL to:

   ```
   http://prometheus:9090
   ```

6. Click **Save & Test**

---

## 📋 Create Your First Dashboard

1. Go to **Create → Dashboard → Add new panel**

2. In the query field, try:

   ```
   rate(http_requests_total[1m])
   ```

3. Choose a visualization type (Graph, Stat, etc.)

4. Click **Apply**

5. Save your dashboard

---

## 🥪 Trigger Metrics

Call your Civitas API endpoint via Swagger UI or `curl`:

```bash
curl https://localhost:7081/api/yourendpoint --insecure
```

Refresh your Grafana dashboard to see updated metric values.

---

## ✅ Useful Metrics

Here are some useful Prometheus metrics you might expose from Civitas:

* `http_requests_total`
* `process_cpu_seconds_total`
* `aspnetcore_request_duration_seconds`

Use the Prometheus UI at [http://localhost:9092/graph](http://localhost:9092/graph) to explore available metrics.

---

## 🛑 Stop the Stack

```bash
docker-compose down
```

---

## 📚 References

* \[Prometheus Documentation]\([https://prometheus.io/docs/introduction/ove](https://prometheus.io/docs/introduction/ove)
