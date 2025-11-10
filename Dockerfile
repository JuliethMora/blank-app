FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc libpq-dev build-essential unixodbc unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements e instalar
COPY requirements.txt ./
RUN python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt

# Copiar el resto del código
COPY . /app

EXPOSE 8501

# Puerto por defecto (puedes sobrescribir con la variable de entorno PORT)
ENV PORT=8501

CMD ["bash", "-lc", "streamlit run streamlit_app.py --server.port $PORT --server.address 0.0.0.0"]
