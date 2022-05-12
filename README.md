# rogsoft-proxor

A light proxy tool for my ASUS-AX88U :)

## 工作流程

1. 保证 nameserver 使用的是 dnsmasq 服务
2. 清理上一次配置, 顺序: iptables -> ipset
3. 创建好空的 ipset
4. 创建好 dnsmasq 的 conf, 核心配置: **【哪些域名】向【哪些DNS服务器】解析, 把结果放到【哪些ipset】 下**
5. 配置 iptables 规则, 匹配 步骤2 创建的 ipset 重定向到代理客户端的 IP:PORT, 转发到旁路由用 DNAT, 直接转发到代理进程用 REDIRECT
6. 重启 dnsmasq 进程, 应用 步骤4 创建的 conf

疑问点: iptable 配到 某个 ipset 后, 由 dnsmasq 动态的维护这个 ipset, 然后 ipset 变化后, 会自动更新 iptables? 这么厉害?
不会自动更新的话, 还得定时重启? 但 dns 解析是延时的, 不是刚启动就把所有域名都解析一次的

实验: iptables 配置 ipset, 然后更新这个 ipset
猜想: 实际 iptables 和 ipset 都只是配置而已, 真正工作的是 netfiler, 所以它们更新后, netfilter 直接能使用到最新的配置

---

## 调研

### dnsmasq

给 dnsmasq 用的配置文件:

``` conf
# *.google.com 泛域名 从 127.0.0.1:7913 上行DNS服务器解析
server=/.google.com/127.0.0.1#7913

# *.google.com 泛域名的DNS解析结果放到 gfwlist 这个 ipset 下
ipset=/.google.com/gfwlist
```

---

TODO: 仍在开发中...

## 调试

需要安装了 iptables, ipset, dnsmasq 的 linux 容器

---

## apply_ss 做了什么

1. 执行 disable_ss
2. 杀掉 ss_status 进程, 该进程会轮询连通性, 国内检查 baidu, 国外检查 google
3. 杀掉各种代理进程, v2ray, ssr等, 好像还有dns相关
4. 结束 2 个基于 crontabs 的重启任务
5. 删除一些配置文件, 包含 dnsmasq.d 下的和其他一些临时文件
6. 根据GUI配置在关闭后保持使用ss内置的 dnsmasq, 或关掉用回系统的 dnsmasq
7. 执行 restart_dnsmasq
8. 执行 flush_nat, 包含一系列 iptables/ipset 的 -D/-F/-X 操作
9. 删除代理的定时更新规则、定时更新订阅任务
10. 执行 ss_pre_start, 主要是负载均衡配置
11. 执行 detect, 包含了jffs配置检查, 虚拟内存检查, 清除自定义的DNS(也就是不支持在LAN里自定义DNS服务器了)
12. 执行 set_sys, 大致是配置一下上限和模式, 用于保证性能的
13. 执行 resolv_server_ip, 解析代理服务器的ip, 并写到 dnsmasq 的 server 和 address 上
14. 执行 ss_arg, 准备代理客户端的启动参数
15. 启动 Netfilter/xt_set 模块, 用于 ipset 和 iptables 联动, 引别人的解释: *iptables是用户用来管理和配置防火墙规则的一种策略，但是实际解析规则并按照规则实施产生作用的是Netfilter*
16. 执行 creat_ipset: 创建一些列空的ipset, 基于 chnroute.txt 添加到 chnroute 这个 set
17. 执行 create_dnsmasq_conf
18. 生成各代理客户端的配置文件, 如如 ss配置, v2ray配置等
19. 执行 load_nat

---

### restart_dnsmasq 做了什么

- 保证使用的是本地DNS服务器
  - 也就是保证使用 127.0.0.1:53(TODO: 是否是dnsmasq提供待验证)
  - 因为上游DNS可能解析不了 google.com
  - 具体做法是保证 ``/etc/resolv.conf`` 下有配置: ``nameserver 127.0.0.1``
- 执行重启 dnsmasq 服务: ``service restart_dnsmasq >/dev/null 2>&1``

### create_dnsmasq_conf 做了什么

- 设置上游 DNS 地址, 到 CDN 这个变量下, 默认会兜底到 114.114.114.114
- 支持GUI配置到其他常用的国内 DNS 地址, 其中 13 时是 SmartDNS, 使用 127.0.0.1:5335
- 删除现有的各种临时配置和 dnsmasq.d 下的配置
- 如果不是回国模式 先写一堆 dnsmasq.d/wblist.conf 配置到 127.0.0.1:7913, 输出到 router 的 ipset 里, 包含了 github.com/google.com.tw等
- 把GUI手动配置的名单也遍历加到 dnsmasq.d/wblist.conf 下 输出到 white_list/black_list 的 ipset 里
- 国内优先模式啥都不做, 国外优先模式下 加载 cdn.txt 里的域名作为server 到 /tmp/sscdn.conf 下

### load_nat 做了什么

- 轮询120秒 检查 iptables 的 nat 表的 PREROUTING 链记录中, PREROUTING 和 destination 都为空的记录是否不存在
  - 没有上述空记录, 说明 nat 表的 PREROUTING 规则均有 destination 值
- 执行 add_white_black_ip, 添加名单到 black_list 和 white_list 的 ipset, 包含内网地址, 代理服务器地址, 一些 cdn 地址等
- 执行 apply_nat_rules, 设置各 ipset 给自定义 iptables 规则
