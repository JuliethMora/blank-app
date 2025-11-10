# Despliegue público

Opciones y pasos para desplegar esta aplicación Streamlit públicamente.

1) Deploy rápido en Render (recomendado):
   - Crea una cuenta en https://render.com
   - Conecta tu repositorio de GitHub.
   - Crea un nuevo "Web Service" y selecciona "Deploy from Dockerfile".
   - Render construirá la imagen desde el `Dockerfile` y expondrá la app en una URL pública.

2) Publicar imagen en GitHub Container Registry (automático):
   - El workflow GitHub Actions `.github/workflows/build-and-push.yml` construye y publica la imagen en `ghcr.io/<OWNER>/<REPO>:latest` cuando haces push a `main`.
   - En Render, Railway o cualquier proveedor, puedes apuntar a esa imagen para desplegar.

3) Streamlit Community Cloud:
   - Para apps sencillas, usa https://streamlit.io/cloud
   - Conecta tu repo y configura `streamlit_app.py` como comando de inicio.

4) Docker (local o VPS):
   - Construir imagen:
     ```bash
     docker build -t etl-autocad:latest .
     ```
   - Ejecutar contenedor:
     ```bash
     docker run -p 8501:8501 etl-autocad:latest
     ```

Notas importantes:
- Si tu script `etlautocad.py` necesita drivers ODBC o conectividad a una base de datos, asegúrate de instalar los paquetes del sistema y configurar variables de entorno en la máquina/servicio donde despliegues.
- El workflow sube la imagen a GitHub Container Registry usando el `GITHUB_TOKEN` proporcionado por Actions; para desplegar automáticamente en Render u otro proveedor necesitarás configurar integraciones o secrets en el panel del proveedor.
- Asegúrate de no exponer credenciales en el repositorio. Usa secrets en GitHub Actions y variables de entorno en el servicio de despliegue.

Ejemplo: desplegar en Render desde GitHub
1. Push del repo a GitHub (branch `main`).
2. El workflow build-and-push construirá y publicará la imagen en GHCR.
3. En Render, crea un Web Service y en la sección "Docker / Container Registry" usa la imagen `ghcr.io/<OWNER>/<REPO>:latest`.