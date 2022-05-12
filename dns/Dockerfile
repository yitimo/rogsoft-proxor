FROM alpine:3.15.4

# 支持非江浙地方按需调整更近的上游dns地址
ARG UPSTREAM=223.5.5.5,223.6.6.6,114.114.114.114

RUN apk add dnsmasq

RUN echo "nameserver $UPSTREAM" | sed 's/,/\nnameserver /g' > /etc/proxor-resolv.conf && \
  echo $'\nresolv-file=/etc/proxor-resolv.conf\nconf-dir=/etc/dnsmasq.d/,*.conf\n' > /etc/dnsmasq.conf && \
  rm -rf /etc/dnsmasq.d && \
  mkdir -p /data/dnsmasq.d && \
  ln -s /data/dnsmasq.d /etc/dnsmasq.d

EXPOSE 53 53/udp

CMD ["dnsmasq", "-k"]
