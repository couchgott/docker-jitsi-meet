FROM debian:stretch-slim

ENV DEBIAN_FRONTEND noninteractive


RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list \
 && apt -y update \
 && apt -y install -t stretch-backports --no-install-recommends gnupg2 ca-certificates curl procps \
      dnsutils nginx bash pwgen apt-transport-https

RUN mkdir -p /usr/share/man/man1

RUN curl https://download.jitsi.org/jitsi-key.gpg.key | sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg' \
 && echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' | tee /etc/apt/sources.list.d/jitsi-stable.list > /dev/null \
 && apt -y update \
 && apt -y install jitsi-meet

RUN rm -rf /etc/nginx/sites-enabled/* \
 && rm -rf /etc/prosody/conf.d/*

COPY config/jitsi /etc/jitsi
RUN chown -R jicofo: /etc/jitsi/jicofo \
 && chown -R jvb: /etc/jitsi/videobridge

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/prosody.cfg.lua /etc/prosody/prosody.cfg.lua

COPY start.sh /start.sh

ENV DOMAIN=test.com STUN=stun.test.com BRIDGE_IP=1.2.3.4 BRIDGE_TCP_PORT=4443 BRIDGE_UDP_PORT=10000

EXPOSE 4443 10000/udp

CMD /start.sh
