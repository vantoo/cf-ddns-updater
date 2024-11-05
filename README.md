# cf-ddns-updater

一个使用Python编写的脚本，通过Cloudflare API定期更新DNS记录，支持Docker部署。

## 功能

- 获取当前机器的公网IP地址
- 使用Cloudflare API更新DNS记录
- 支持通过环境变量配置
- 支持Docker部署

## 环境变量

以下环境变量需要在运行容器时传递：

- `API_ENDPOINT`：Cloudflare API 端点，默认为 `https://api.cloudflare.com/client/v4`
- `API_TOKEN`：你的Cloudflare API Token
- `ZONE_ID`：你的Zone ID
- `DOMAIN_NAME`：你的域名
- `INTERVAL`：执行间隔时间（小时），默认为24小时

## 使用方法

### 运行Docker容器

```sh
# 请将 `your_api_token`、`your_zone_id` 和 `your_domain_name` 替换为实际的值。
docker run -e API_TOKEN=your_api_token -e ZONE_ID=your_zone_id -e DOMAIN_NAME=your_domain_name -e INTERVAL=12 vantoo/cf-ddns-updater
```