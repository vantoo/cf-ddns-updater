import os
import time
import requests

# Cloudflare API 端点
API_ENDPOINT = os.getenv("API_ENDPOINT", "https://api.cloudflare.com/client/v4")

# 替换为你的Cloudflare API Token
API_TOKEN = os.getenv("API_TOKEN", "")

# 替换为你的Zone ID
ZONE_ID = os.getenv("ZONE_ID", "")

# 替换为你的域名
DOMAIN_NAME = os.getenv("DOMAIN_NAME", "")

# 获取执行间隔时间（秒）
INTERVAL = int(os.getenv("INTERVAL", 24))  # 默认每24小时执行一次

def get_current_public_ip():
    try:
        response = requests.get("https://ip.clang.cn")
        response.raise_for_status()
        return response.text.strip()
    except requests.RequestException as e:
        print(f"获取公网IP失败: {e}")
        return None

def extract_json_value(json_data, key):
    return json_data.get(key, "")

def update_dns_record(current_ip):
    headers = {
        "Authorization": f"Bearer {API_TOKEN}",
        "Content-Type": "application/json"
    }

    # 获取当前DNS记录
    record_response = requests.get(f"{API_ENDPOINT}/zones/{ZONE_ID}/dns_records?name={DOMAIN_NAME}", headers=headers)
    record_data = record_response.json()

    if not record_data.get("success"):
        print(f"获取DNS记录失败: {record_data.get('errors')}")
        return

    record_id = extract_json_value(record_data["result"][0], "id")
    current_dns_ip = extract_json_value(record_data["result"][0], "content")
    print(f"当前域名解析记录: {current_dns_ip}")

    if current_dns_ip != current_ip:
        # 更新DNS记录
        update_data = {
            "type": "A",
            "name": DOMAIN_NAME,
            "content": current_ip,
            "ttl": 1,
            "proxied": False
        }
        update_response = requests.put(f"{API_ENDPOINT}/zones/{ZONE_ID}/dns_records/{record_id}", headers=headers, json=update_data)
        update_data = update_response.json()

        if update_data.get("success"):
            print(f"DNS记录更新成功: {current_ip}")
        else:
            error_message = extract_json_value(update_data, "message")
            print(f"DNS记录更新失败: {error_message}")
    else:
        print("IP地址未变化，无需更新")

if __name__ == "__main__":
    while True:
        current_ip = get_current_public_ip()
        if current_ip:
            print(f"获取公网IP成功: {current_ip}")
            update_dns_record(current_ip)
        time.sleep(INTERVAL * 3600)