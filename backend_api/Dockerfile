FROM python:3.11

# ✅ FIX 1: Match the working directory with docker-compose.yml
WORKDIR /code

# Install build dependencies (Essential for some Python packages)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libffi-dev \
    libssl-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# ✅ FIX 2: Copy requirements to the correct folder
COPY ./requirements.txt /code/requirements.txt

# Install dependencies
RUN pip install --no-cache-dir -r /code/requirements.txt

# ✅ FIX 3: Copy the entire app to /code
COPY . /code

# Run the app (uvicorn looks for main.py in the current WORKDIR)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]