#!/bin/bash

# Функция отображения справки
usage() {
    echo "Использование: $0 -c <credentials_file> -k <authorized_key.json> -C <cloud_id> -f <folder_id>"
    echo ""
    echo "Опции:"
    echo "  -c, --credentials PATH      Путь к файлу aws-типизированных кредов SA (по умолчанию: ./.yc/infrastructure_sa_credentials)"
    echo "  -k, --keyfile PATH          Путь к файлу статического ключа SA (по умолчанию: ./.yc/infrastructure_sa_key.json)"
    echo "  -C, --cloud-id VALUE        Значение переменной cloud_id для Terraform"
    echo "  -f, --folder-id VALUE       Значение переменной folder_id для Terraform"
    echo "  -h, --help                  Показать эту справку"
    exit 1
}

# Установка значений по умолчанию
CREDENTIALS_FILE="./.yc/infrastructure_sa_credentials"
KEYFILE_PATH="./.yc/infrastructure_sa_key.json"

# Обработка аргументов командной строки
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--credentials) CREDENTIALS_FILE="$2"; shift ;;
        -k|--keyfile) KEYFILE_PATH="$2"; shift ;;
        -C|--cloud-id) TF_VAR_cloud_id="$2"; shift ;;
        -f|--folder-id) TF_VAR_folder_id="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Неизвестный параметр: $1"; usage ;;
    esac
    shift
done

# Проверка наличия обязательных параметров
if [ -z "${TF_VAR_cloud_id}" ] || [ -z "${TF_VAR_folder_id}" ]; then
    echo "Ошибка: cloud_id и folder_id обязательны."
    usage
fi

# Проверка существования файла credentials
if [ ! -f "${CREDENTIALS_FILE}" ]; then
    echo "Ошибка: Файл ${CREDENTIALS_FILE} не найден."
    exit 1
fi

# Проверка существования файла authorized_key.json
if [ ! -f "${KEYFILE_PATH}" ]; then
    echo "Ошибка: Файл ${KEYFILE_PATH} не найден."
    exit 1
fi

# Извлечение AWS_ACCESS_KEY_ID и AWS_SECRET_ACCESS_KEY из файла credentials
AWS_SECTION=$(grep -A2 '\[default\]' "${CREDENTIALS_FILE}" 2>/dev/null)
if [ -z "${AWS_SECTION}" ]; then
    echo "Ошибка: Не найдена секция [default] в ${CREDENTIALS_FILE}"
    exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo "${AWS_SECTION}" | grep 'aws_access_key_id' | cut -d '=' -f2- | tr -d ' ')
export AWS_SECRET_ACCESS_KEY=$(echo "${AWS_SECTION}" | grep 'aws_secret_access_key' | cut -d '=' -f2- | tr -d ' ')

# Экспорт пути до ключа как переменной TF_VAR_key_file
export TF_VAR_service_account_key_filepath="${KEYFILE_PATH}"

# Экспорт переменных для Terraform
export TF_VAR_cloud_id="${TF_VAR_cloud_id}"
export TF_VAR_folder_id="${TF_VAR_folder_id}"

# Установка конфигурации Yandex Cloud CLI
yc config set cloud-id "${TF_VAR_cloud_id}"
yc config set folder-id "${TF_VAR_folder_id}"
yc config set service-account-key "${KEYFILE_PATH}"

echo "Переменные окружения успешно установлены."
echo "Конфигурация Yandex Cloud CLI обновлена"
