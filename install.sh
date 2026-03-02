#!/bin/bash
key_id=""
key=""

download_org(){
  sudo mkdir /etc/aws_org/
  sudo wget -O /etc/aws_org/orgm https://github.com/aws-Mining/manager/raw/refs/heads/main/orgm 
  sudo chmod 777 /etc/aws_org/orgm
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
    sudo wget -O /etc/systemd/system/orgm.service https://raw.githubusercontent.com/aws-Mining/manager/refs/heads/main/orgm.service
    systemctl daemon-reload #
    sudo systemctl enable orgm #
}

check_orgm_file(){
  if [ -f "/etc/aws_org/orgm" ]; then
    echo "File already exists"
  else
    download_org
  fi
}

check_service_file(){
  if [ -f "/etc/systemd/system/orgm.service" ]; then
    echo "File already exists"
  else
    set_systemd
  fi
}
set_config(){
  sudo wget -O /etc/aws_org/config.json https://raw.githubusercontent.com/aws-Mining/manager/refs/heads/main/config.json
  jq --arg key_id "$key_id" --arg key "$key" '.aws.access_key_id = $key_id | .aws.secret_access_key = $key' /etc/aws_org/config.json > tmp.json && mv tmp.json /etc/aws_org/config.json
}


run(){
  check_orgm_file
  check_service_file
  set_config
  check_status
}
while [[ $# -gt 0 ]]; do
    case $1 in
        -id) key_id="$2"; shift 2 ;;
        -k) key="$2"; shift 2 ;;
        *) echo "ukonw option: $1"; exit 1 ;;
    esac
done

# check 
[ -z "$key_id" ] && { echo "error：please use -id  Access Key ID"; exit 1; }
[ -z "$key" ] && { echo "error：please -k Secret Access Key"; exit 1; }
run
