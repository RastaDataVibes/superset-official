# ---------- OFFICIAL SUPERSET ----------
FROM apache/superset:4.1.3

# System deps for Postgres driver
USER root
RUN apt-get update && apt-get install -y libpq-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

# Python deps (Pillow already in base, pin psycopg2)
USER superset
RUN pip install --no-cache-dir psycopg2-binary==2.9.9

# Copy only the config we need
COPY superset_config.py /app/pythonpath/superset_config.py

# Tell Superset where the config lives
ENV SUPERSET_CONFIG_PATH=/app/pythonpath/superset_config.py

# Use the official entrypoint + gunicorn with sync workers
ENTRYPOINT ["/app/docker/docker-entrypoint.sh"]
CMD ["gunicorn", "--worker-class", "sync", "-w", "4", "--timeout", "300", "-b", "0.0.0.0:8088", "superset.app:create_app()"]
