#!/bin/bash

# Function to generate the configuration
generate_config() {
    # Create a temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download WGCF
    wget -q https://github.com/ViRb3/wgcf/releases/download/v2.2.22/wgcf_2.2.22_linux_amd64
    chmod +x wgcf_2.2.22_linux_amd64

    # Generate account and obtain configuration
    ./wgcf_2.2.22_linux_amd64 register --accept-tos > /dev/null 2>&1
    ./wgcf_2.2.22_linux_amd64 generate > /dev/null 2>&1
    cat wgcf-profile.conf

    # Clean up the temporary directory
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Function to modify the configuration
modify_config() {
    local config="$1"
    local insert_text="Jc = 120
Jmin = 23
Jmax = 911
H1 = 1
H2 = 2
H3 = 3
H4 = 4"

    # Read the configuration line by line, modify it, and output the result
    local line_num=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        if [[ $line_num -eq 3 ]]; then
            echo "$insert_text"
        fi
        if [[ $line == "DNS ="* ]]; then
            echo "DNS = 8.8.8.8"
        elif [[ $line == "Endpoint ="* ]]; then
            echo "Endpoint = 188.114.97.66:2408"
        else
            echo "$line"
        fi
    done <<< "$config"
}

# --- Main code ---

echo "Генерация конфигурации WGCF..."
config=$(generate_config)

echo "Модификация конфигурации..."
modified_config=$(modify_config "$config")

echo "Установка qrencode..."
apt -y install qrencode > /dev/null 2>&1

# Очищаем экран для удобства
clear

echo "=================================================="
echo "Ваш готовый конфиг:"
echo "=================================================="
echo "$modified_config"
echo "=================================================="
echo ""

echo "Отсканируйте QR-код с помощью приложения AmneziaWG:"
echo "$modified_config" | qrencode -t ansiutf8
echo ""

# --- НОВЫЙ БЛОК ДЛЯ ССЫЛКИ НА СКАЧИВАНИЕ ---

# Кодируем конфиг в Base64. Флаг -w 0 убирает переносы строк.
config_base64=$(echo -n "$modified_config" | base64 -w 0)

# Формируем ссылку для скачивания
download_url="https://immalware.vercel.app/download?filename=wgcf-config.conf&content=${config_base64}"

# Выводим ссылку
echo "Или скачайте файл конфигурации по ссылке:"
echo "$download_url"
echo ""
