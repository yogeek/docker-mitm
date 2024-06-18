FROM ubuntu

ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y iptables tcpdump dsniff iproute2 python3 python3-pip tmux dnsutils pipx
RUN pipx install scapy mitmproxy && pipx ensurepath

ENV PATH="$PATH:/root/.local/bin"

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
