import streamlit as st
import tempfile
import os
import subprocess
import shutil
from pathlib import Path
import glob

st.set_page_config(page_title="ETL AutoCAD", layout="wide")

st.title("🚀 Ejecución del ETL AutoCAD")
st.markdown("""
Esta aplicación ejecuta automáticamente el proceso ETL definido en **etlautocad.py**  
Sube el archivo Excel principal del proyecto y presiona **Ejecutar ETL**.
""")

# ---- Entrada del usuario ----
uploaded_excel = st.file_uploader("📁 Sube el archivo Excel principal del proyecto", type=["xlsx", "xls"])

run_button = st.button("▶️ Ejecutar ETL")

# ---- Validaciones ----
if run_button:
    if not uploaded_excel:
        st.error("Por favor, sube un archivo Excel antes de ejecutar.")
        st.stop()

    # Crear carpeta temporal
    tmp_dir = Path(tempfile.mkdtemp(prefix="etl_run_"))
    st.info(f"Directorio temporal creado: `{tmp_dir}`")

    # Guardar el Excel subido
    excel_path = tmp_dir / uploaded_excel.name
    with open(excel_path, "wb") as f:
        f.write(uploaded_excel.getbuffer())

    # Copiar el script original
    original_script = Path("etlautocad.py")
    if not original_script.exists():
        st.error("No se encontró `etlautocad.py` en el mismo directorio que este script.")
        st.stop()

    # Copiarlo al directorio temporal
    tmp_script = tmp_dir / "etlautocad.py"
    shutil.copy(original_script, tmp_script)

    # Modificar el script para eliminar input() e insertar la ruta del Excel automáticamente
    content = tmp_script.read_text(encoding="utf-8")

    import re
    # Busca la línea con 'dataset = input(' y reemplaza con el path del Excel subido
    pattern = r'dataset\s*=\s*input\(.*\)\.strip\(\)'
    replacement = f'dataset = r"{excel_path.name}"'
    content = re.sub(pattern, replacement, content)

    tmp_script.write_text(content, encoding="utf-8")

    st.write("✅ Script preparado, iniciando ejecución...")

    # Ejecutar el ETL en el entorno temporal
    cmd = ["python", str(tmp_script.name)]
    log_placeholder = st.empty()
    logs = []

    with subprocess.Popen(
        cmd, cwd=tmp_dir, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1
    ) as proc:
        for line in proc.stdout:
            logs.append(line)
            log_placeholder.text("".join(logs[-40:]))  # muestra últimas 40 líneas
        proc.wait()

    st.success("Ejecución completada ✅")

    # Mostrar outputs generados
    output_files = list(tmp_dir.glob("*.xlsx")) + list(tmp_dir.glob("*.csv"))
    if not output_files:
        st.warning("No se detectaron archivos de salida. Verifica el log de ejecución.")
    else:
        st.subheader("📦 Archivos generados:")
        for f in output_files:
            with open(f, "rb") as file:
                st.download_button(
                    label=f"Descargar {f.name}",
                    data=file.read(),
                    file_name=f.name,
                    mime="application/octet-stream",
                )

    st.subheader("📜 Log de ejecución")
    st.code("".join(logs[-300:]) if logs else "Sin salida de log.")
