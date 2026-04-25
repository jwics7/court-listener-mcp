FROM python:3.12-slim

WORKDIR /app

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv

COPY . /app

RUN if [ ! -f README.md ]; then \
      if [ -f app/README.md ]; then cp app/README.md README.md; \
      else printf '%s\n' '# CourtListener MCP Server' > README.md; \
      fi; \
    fi

RUN uv pip install --system .
RUN uv pip install --system markdown mcpo

ENV COURTLISTENER_BASE_URL=https://www.courtlistener.com/api/rest/v4/
ENV COURT_LISTENER_TIMEOUT=30
ENV LOG_LEVEL=INFO
ENV COURTLISTENER_LOG_LEVEL=INFO
ENV RATE_LIMIT_REQUESTS=10
ENV RATE_LIMIT_PERIOD=60
ENV DEBUG=false
ENV PORT=8000

EXPOSE 8000

CMD ["mcpo", "--host", "0.0.0.0", "--port", "8000", "--", "python", "-m", "app.server"]
