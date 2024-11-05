#!/bin/bash

# Cloudflare API 端点
API_ENDPOINT=${API_ENDPOINT:-"https://api.cloudflare.com/client/v4"}

# 替换为你的Cloudflare API Token
API_TOKEN=${API_TOKEN:-""}

# 替换为你的Zone ID
ZONE_ID=${ZONE_ID:-""}

# 替换为你的域名
DOMAIN_NAME=${DOMAIN_NAME:-""}

# 获取执行间隔时间（秒）
INTERVAL=${INTERVAL:-24}  # 默认每24小时执行一次

get_current_public_ip() {
    # 获取当前机器的公网IP地址
    response=$(curl -s https://ip.clang.cn | tr -d '[:space:]')
    http_code=$(curl -s -o /dev/null -w "%{http_code}" https://ip.clang.cn)
    if [ "$http_code" -eq 200 ]; then
        echo "$response"
    else
        echo "获取公网IP失败: $http_code"
        return 1
    fi
}

extract_json_value() {
    echo "$1" | grep -o '"'"$2"'"\s*:\s*"[^"]*"' | sed -E 's/.*:\s*"([^"]*)".*/\1/'
}

update_dns_record() {
    # 获取当前DNS记录
    record_response=$(curl -s -X GET "$API_ENDPOINT/zones/$ZONE_ID/dns_records?name=$DOMAIN_NAME" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json")
    
    record_id=$(extract_json_value "$record_response" "id")
    current_ip=$(extract_json_value "$record_response" "content")
    echo "当前域名解析记录: $current_ip"

    if [ "$current_ip" != "$1" ]; then
        # 更新DNS记录
        update_response=$(curl -s -X PUT "$API_ENDPOINT/zones/$ZONE_ID/dns_records/$record_id" \
            -H "Authorization: Bearer $API_TOKEN" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$DOMAIN_NAME\",\"content\":\"$1\",\"ttl\":1,\"proxied\":false}")
        
        success=$(extract_json_value "$update_response" "success")
        if [ "$success" == "true" ]; then
            echo "DNS记录更新成功: $1"
        else
            error_message=$(extract_json_value "$update_response" "message")
            echo "DNS记录更新失败: $error_message"
        fi
    else
        echo "IP地址未变化，无需更新"
    fi
}

while true; do
    current_ip=$(get_current_public_ip)
    echo "获取公网IP成功: $current_ip"
    if [ $? -eq 0 ]; then
        update_dns_record "$current_ip"
    fi
    sleep $((INTERVAL * 3600))
done
