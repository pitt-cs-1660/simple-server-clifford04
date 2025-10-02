# Build Stage
FROM python:3.12 AS builder

# Install uv package manager
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set working directory
WORKDIR /app

# Copy pyproject.toml for dependency installation
COPY pyproject.toml uv.lock ./

# Install Python dependencies using uv (without installing the project itself)
RUN uv sync --no-install-project

# Final Stage
FROM python:3.12-slim

# Set environment variables for virtual environment
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:${PATH}"
ENV PYTHONDONTWRITEBYTECODE=1 
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Set working directory
WORKDIR /app

# Copy the virtual environment from build stage
COPY --from=builder /app/.venv /app/.venv

# Copy application source code
COPY . ./

# Create non-root user for security
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Expose port 8000
EXPOSE 8000

# Set CMD to run FastAPI server on 0.0.0.0:8000
CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]

