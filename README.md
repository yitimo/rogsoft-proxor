# rogsoft-proxor

A light proxy tool for my ASUS-AX88U :)

## 做了什么

维护进出路由器的防火墙规则

- 提供查询iptable的脚本
- 提供设置iptable的脚本
- 提供删除iptable的脚本
- 只支持设置 ``源IP:PORT`` 到 ``目标IP:PORT`` 的重定向
- 不提供DNS查询脚本, 外部做好后调用设置来配置

### 不做什么

不在路由器上运行具体的代理进程(如 clash/ss/v2ray 等)

### 可以做什么

最佳实践建议是搭配性能较好的旁路由使用:

- 旁路由上运行具体的代理进程, 如 v2ray 客户端, 并开启局域网代理
- 不需要走代理的请求, 路由器直接透传到外网
- 需要走代理的请求, 由路由器转发到旁路由的代理端口, 然后由旁路由的【代理客户端】又经过主路由最终发送到【代理服务器(VPS)】上

### 这样做的好处

- 对其他终端来说无需安装和配置代理客户端, 而是由网关路由器直接完成选择性的代理转发
- 避开家用路由器的性能瓶颈, 一般家用路由器都是 arm架构、小内存 的, 再多运行一个代理客户端进程难免会又慢又卡又不稳定

### 这样做的坏处

- 代理请求会先从主路由到旁路由再回到主路由, 比直连多了2次跳转, 不过额外的跳转是发生在内网, 换来性能提升是值得的
- 需要搭配一台性能较好的旁路由, 如 群辉NAS、PC、其他软路由, 每月会增加少量电费支出

## 调研

### dnsmasq

给 dnsmasq 用的配置文件:

``` conf
# *.google.com 泛域名 从 127.0.0.1:7913 上行DNS服务器解析
server=/.google.com/127.0.0.1#7913

# *.google.com 泛域名的DNS解析结果放到 gfwlist 这个 ipset 下
ipset=/.google.com/gfwlist
```

- iptables
- ipset

---

TODO: 仍在开发中...

## 调试

### Docker调试

``` bash
docker build -t proxor-debug .
docker run -dp 8880:80 proxor-debug
```

### 终端调试

- 路由器端容器: iptables + ping + host, 映射端口到宿主后, 从容器内 ping 各种 host 检查连通性
- 外网端容器: 运行 nginx 反向代理两个 host 网站, 供路由器端容器访问

### GUI调试

需要 固件系统环境 和 Asp.Net Core, 建议真机调试
