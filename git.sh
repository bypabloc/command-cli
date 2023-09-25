#!/bin/bash

# Colores ANSI para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
LIGHT_BLUE='\033[0;36m'
NC='\033[0m' # No color

# Array asociativo de comandos requeridos y sus comandos de instalación
declare -A commands_required=( ["git"]="sudo apt-get install -y git" ["nano"]="sudo apt-get install -y nano" )

# Verificar cada comando y si no está instalado, instalarlo
for cmd in "${!commands_required[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${YELLOW}El comando '$cmd' no está instalado.${NC}"
        install_command=${commands_required[$cmd]}
        read -p "¿Quieres instalarlo? (s/n): " user_input

        if [ "$user_input" = "s" ]; then
            eval $install_command
        else
            echo -e "${RED}El comando '$cmd' es necesario para continuar. Saliendo...${NC}"
            exit 1
        fi
    fi
done

# Verificar si estamos en un repositorio de Git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}No estás en un repositorio de Git. Saliendo...${NC}"
    exit 1
fi

# Obtener el último mensaje de commit
last_commit_message=$(git log -1 --pretty=%B)

# Mostrar el último mensaje de commit
echo -e "${LIGHT_BLUE}Último mensaje de commit:${NC}"
echo -e "${GREEN}$last_commit_message${NC}"

# Inicializar la variable para el flag --no-verify
no_verify_flag=""

# Verificar si el argumento --ignore-verify fue pasado
if [[ "$@" == *"--ignore-verify"* ]]; then
    no_verify_flag="--no-verify"
fi

# Verificar si el argumento "camp" fue pasado
if [[ "$@" == *"camp"* ]]; then
    temp_file=$(mktemp)
    echo "$last_commit_message" > "$temp_file"
    nano "$temp_file"
    last_commit_message=$(cat "$temp_file")
    rm "$temp_file"
fi

# Crear el comando final de git
final_command="git add . && git commit -m \"$last_commit_message\" $no_verify_flag && git push"

# Mostrar y ejecutar el comando final
echo -e "${LIGHT_BLUE}Ejecutando: $final_command${NC}"
eval $final_command

# Finalizar
echo -e "${GREEN}Hecho.${NC}"
