#!/bin/bash

# Функция отображения справки
usage() {
    echo "Использование: $0 -c <cluster_name> -s <service_account_name> -n <namespace> -o <output_file>"
    echo ""
    echo "Опции:"
    echo "  -i, --cluster-id ID          Идентификатор кластера Kubernetes (обязательно)"
    echo "  -c, --cluster-name NAME      Имя кластера Kubernetes (обязательно)"
    echo "  -s, --service-account NAME   Имя сервисного аккаунта"
    echo "  -n, --namespace NAME         Имя пространства имен"
    echo "  -o, --output-file PATH       Путь к выходному файлу"
    echo "  -h, --help                   Показать эту справку"
    exit 1
}

# Занчения по умолчанию
SA_NAME="admin-user"
NAMESPACE="kube-system"
OUTPUT_FILE="./.kube/kube_config"

# Обработка аргументов командной строки
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--cluster-id) CLUSTER_ID="$2"; shift ;;
        -c|--cluster-name) CLUSTER_NAME="$2"; shift ;;
        -s|--service-account) SA_NAME="$2"; shift ;;
        -n|--namespace) NAMESPACE="$2"; shift ;;
        -o|--output-file) OUTPUT_FILE="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Неизвестный параметр: $1"; usage ;;
    esac
    shift
done

# Проверка наличия обязательных параметров
if [ -z "${CLUSTER_NAME}" ] || [ -z "${CLUSTER_ID}" ]; then
    echo "Ошибка: Параметры --cluster-name и --cluster-id обязательны."
    usage
fi

# Создание директории для kubeconfig файла при необходимости
KUBECONFIG_DIR=$(dirname "${OUTPUT_FILE}")
if [[ ! -d "${KUBECONFIG_DIR}" ]]; then
  echo "Создаём директорию: ${KUBECONFIG_DIR}"
  mkdir -p "${KUBECONFIG_DIR}"
fi

# Создание ServiceAccount и ClusterRoleBinding
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SA_NAME}
  namespace: ${NAMESPACE}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${SA_NAME}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: ${SA_NAME}
  namespace: ${NAMESPACE}
EOF

# Получение токена, CA и серверного адреса
TOKEN=$(kubectl -n ${NAMESPACE} create token ${SA_NAME} --duration=8760h)
CA=$(kubectl config view --raw -o jsonpath='{.clusters[?(@.name == "'yc-managed-k8s-$CLUSTER_ID'")].cluster.certificate-authority-data}')
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[?(@.name == "'yc-managed-k8s-$CLUSTER_ID'")].cluster.server}')

if [[ -z "${CA}" ]]; then
  echo "Ошибка: Не удалось получить certificate-authority-data"
  exit 1
fi

# Создание kubeconfig файла
cat <<EOF > "${OUTPUT_FILE}"
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CA}
    server: ${SERVER}
  name: ${CLUSTER_NAME}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: ${SA_NAME}
  name: default
current-context: default
users:
- name: ${SA_NAME}
  user:
    token: ${TOKEN}
EOF

echo "Готово! Kubeconfig для сервисного аккаунта сохранён в ${OUTPUT_FILE}"