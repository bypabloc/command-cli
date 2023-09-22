#!/bin/bash

# Directorio donde se almacenarán los scripts
target_dir="/usr/local/bin/"

# Recorremos cada archivo con extensión .sh en el directorio actual
for script_file in *.sh; do
    # Evitamos el propio script de instalación
    if [ "$script_file" != "install.sh" ]; then
        # Creamos el nuevo nombre del archivo con el sufijo "_bp"
        new_script_name=$(basename "$script_file" .sh)"_bp"

        echo "Instalando $script_file como $new_script_name..."

        # Movemos y renombramos el archivo al directorio target
        sudo cp "$script_file" "$target_dir$new_script_name"

        # Le damos permisos de ejecución
        sudo chmod +x "$target_dir$new_script_name"
    fi
done

echo "¡Todos los scripts han sido instalados!"
