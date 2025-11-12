FROM python:3.11-slim

# Evita prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Define directorio de trabajo
WORKDIR /app

# 🧩 Instalar dependencias del sistema necesarias para pandas, numpy, psycopg2, etc.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc \
       libpq-dev \
       build-essential \
       unixodbc \
       unixodbc-dev \
       libssl-dev \
       libffi-dev \
       libblas-dev \
       liblapack-dev \
       gfortran \
    && rm -rf /var/lib/apt/lists/*

# 🧩 Copiar e instalar dependencias de Python
COPY requirements.txt ./

# Actualizar pip y herramientas base antes de instalar
RUN python -m pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt

# 🧩 Copiar el resto del código fuente
COPY . /app

# Exponer el puerto de Streamlit
EXPOSE 8501

# Permitir definir el puerto desde fuera (por ejemplo en un contenedor ECS o Render)
ENV PORT=8501

# 🧩 Comando de ejecución
# Usamos exec-form (lista JSON) + expansión segura del puerto
CMD ["sh", "-c", "streamlit run streamlit_app.py --server.port=${PORT} --server.address=0.0.0.0"]
