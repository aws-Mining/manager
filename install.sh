#!/bin/bash
key_id=""
key=""

download_org(){
  sudo mkdir /etc/aws_org
  sudo wget -O /etc/aws_org https://github.com/aws-Mining/manager/raw/refs/heads/main/orgm 
}

check_status(){
  SERVICE_NAME="orgm.service"
  # 
  if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "$SERVICE_NAME is running"
  else
    systemctl restart orgm
      # 
      # 
  fi
}
set_systemd(){
    sudo wget -O /etc/systemd/system/ https://raw.githubusercontent.com/aws-Mining/manager/refs/heads/main/orgm.service
    systemctl daemon-reload #
    sudo systemctl enable orgm #
}

check_xmrig_file(){
  if [ -f "/etc/xmrig/xmrig" ]; then
    echo "File already exists"
  else
    download_xmrig
  fi
}

check_service_file(){
  if [ -f "/etc/systemd/system/xmrig.service" ]; then
    echo "File already exists"
  else
    set_systemd
  fi
}
set_config(){
  sudo rm /etc/aws_org/config.json
  sudo wget -O /etc/aws_org https://raw.githubusercontent.com/aws-Mining/manager/refs/heads/main/config.json
  jq --arg key_id "$key_id" --arg key "$key" '.aws.access_key_id = $key_id | .aws.secret_access_key = $key' /etc/aws_org/config.json > tmp.json && mv tmp.json /etc/aws_org/config.json
}


run(){
  check_file
  check_service_file
  set_config
  check_status
}
while [[ $# -gt 0 ]]; do
    case $1 in
        -id) key_id="$2"; shift 2 ;;
        -k) key="$2"; shift 2 ;;
        *) echo "未知选项: $1"; exit 1 ;;
    esac
done

# 检查参数是否为空
[ -z "$key_id" ] && { echo "错误：请使用 -id 指定Access Key ID"; exit 1; }
[ -z "$key" ] && { echo "错误：请使用 -k 指定Secret Access Key"; exit 1; }
run
