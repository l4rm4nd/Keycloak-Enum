FROM python:3.12-slim

LABEL org.opencontainers.image.title="keycloak-enum" \
      org.opencontainers.image.description="Identify Keycloak versions by fingerprinting publicly-served static assets" \
      org.opencontainers.image.source="https://github.com/l4rm4nd/Keycloak-Enum"

WORKDIR /app

COPY keycloak-enum.py fingerprints.json ./

RUN useradd -r -s /bin/false appuser
USER appuser

ENTRYPOINT ["python3", "keycloak-enum.py"]
