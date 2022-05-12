# 新版计划

## Get start

### 构建镜像

``` bash
# 构建 proxor-dns
docker build -t yitimo/proxor-dns:v1.0.0 -f dns/Dockerfile ./dns

# 构建 proxor-debug
docker build -t yitimo/proxor-debug:v1.0.0 -f debug/Dockerfile ./debug
```

## 调试

基于 ubuntu, 安装这些套件:

- [ ] dns server, 具体哪个待确定, 要求足够轻量, 只需要解析固定ip
- [ ] clash 客户端, 用来监听代理端口
- [ ] clash GUI, 用来配置 clash
- [ ] iptables

做这些配置:

- [ ] dns服务根据pac域名列表解析外网域名到特定ip, 要求特定ip与正常的dns都不冲突, 保证唯一
- [ ] 首选dns到dns服务, 备用dns到 223.5.5.5/223.6.6.6
- [ ] 配置iptables转发特定ip(由dns服务解析到)到代理端口
