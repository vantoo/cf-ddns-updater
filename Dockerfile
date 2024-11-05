# 使用Alpine Linux作为基础镜像
FROM alpine:latest

# 安装curl
RUN apk --no-cache add curl

# 复制sh脚本到容器中
COPY update.sh /usr/local/bin/update.sh

# 赋予脚本可执行权限
RUN chmod +x /usr/local/bin/update.sh

# 运行sh脚本
CMD ["/usr/local/bin/update.sh"]