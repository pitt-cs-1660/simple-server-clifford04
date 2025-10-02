# Build Stage
FROM python:3.12 AS builder


COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/


WORKDIR /app


COPY pyproject.toml ./



RUN uv sync --no-install-project

# Final Stage
FROM python:3.12-slim


ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:${PATH}"
ENV PYTHONDONTWRITEBYTECODE=1 
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

WORKDIR /app


COPY --from=builder /app/.venv /app/.venv


COPY . ./


RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser


EXPOSE 8000

# Set CMD to run FastAPI server on 0.0.0.0:8000
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]

