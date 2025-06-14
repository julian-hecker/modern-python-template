ARG PYTHON_VERSION="3.12"

# Base Stage
FROM python:${PYTHON_VERSION} AS base

ARG POETRY_VERSION="2.1.0"
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
RUN pip install "poetry==${POETRY_VERSION}" --no-cache-dir
COPY pyproject.toml poetry.lock* /app/

# Development Stage
FROM base AS dev
ENV ENVIRONMENT=development \
    # Enable virtual environment in development
    POETRY_VIRTUALENVS_CREATE=true \
    POETRY_VIRTUALENVS_IN_PROJECT=false
# Install all dependencies for development
RUN poetry install --no-ansi --no-interaction
COPY . /app
CMD ["poetry", "run", "uvicorn", "src.package_name_to_replace.app:app"]

# Production Stage
FROM base AS prod
ENV ENVIRONMENT=production \
    # Disable virtual environment in production
    POETRY_VIRTUALENVS_CREATE=false
# Install only main dependencies for production
RUN poetry install --no-ansi --no-cache --no-interaction --only main
COPY . /app
CMD ["uvicorn", "src.package_name_to_replace.app:app"]
