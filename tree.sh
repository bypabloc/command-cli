#!/bin/bash

# Colores ANSI para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
LIGHT_BLUE='\033[0;36m'
NC='\033[0m' # No color

# Array asociativo de comandos requeridos y sus comandos de instalación
declare -A commands_required=( ["awk"]="sudo apt-get install -y gawk" ["sed"]="sudo apt-get install -y sed" ["tree"]="sudo apt-get install -y tree" ["xclip"]="sudo apt-get install -y xclip" )

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

# Variables
ignore_string=""
additional_ignore=""
file_path=""
tree_args=""

# Parsear argumentos
while [ "$1" != "" ]; do
    case $1 in
        --ignore-file )    shift
                           file_path=$1
                           ;;
        --ignore-add )     shift
                           additional_ignore=$1
                           ;;
        * )                tree_args="$tree_args $1"
    esac
    shift
done

# Crear cadena de texto desde archivo y almacenar en variable
if [ -n "$file_path" ]; then
    if [ -f "$file_path" ]; then
        echo -e "${LIGHT_BLUE}Creando cadena de texto desde $file_path...${NC}"
        ignore_string=$(awk '!/#/ && !/^$/ { gsub(/\/$/, ""); printf "%s|", $0 }' "$file_path" | sed 's/.$//')
        echo -e "${LIGHT_BLUE}Cadena creada desde archivo: $ignore_string${NC}"
    else
        echo -e "${YELLOW}Advertencia: El archivo $file_path no existe.${NC}"
    fi
fi

# Añadir elementos adicionales para ignorar
if [ -n "$additional_ignore" ]; then
    if [ -n "$ignore_string" ]; then
        ignore_string="${ignore_string}|${additional_ignore}"
    else
        ignore_string="${additional_ignore}"
    fi
    echo -e "${LIGHT_BLUE}Cadena con elementos adicionales: $ignore_string${NC}"
fi

# Ejecutar comando "tree"
if [ -n "$ignore_string" ] || [ -n "$tree_args" ]; then
    tree_command="tree"
    if [ -n "$ignore_string" ]; then
        tree_command="$tree_command -I '$ignore_string'"
    fi
    tree_command="$tree_command $tree_args"
    echo -e "${LIGHT_BLUE}Ejecutando: $tree_command${NC}"
    tree_result=$(eval $tree_command)
    echo -e "${GREEN}Resultado del comando tree:${NC}"
    echo "$tree_result"
else
    echo -e "${LIGHT_BLUE}Ejecutando 'tree' sin argumentos adicionales...${NC}"
    tree_result=$(tree)
    echo -e "${GREEN}Resultado del comando tree:${NC}"
    echo "$tree_result"
fi

# Copiar en portapapeles la variable anterior
echo -e "${LIGHT_BLUE}Copiando el resultado en el portapapeles...${NC}"
echo -n "$tree_result" | xclip -selection clipboard
# Para macOS, descomenta la siguiente línea
# echo -n "$tree_result" | pbcopy
echo -e "${GREEN}Resultado copiado en el portapapeles.${NC}"
