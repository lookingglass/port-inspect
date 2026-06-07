# 🍃 port-inspect
<p align="center">
  ☁️ <strong>Lightweight tool that reveals information about port in use. 
    <br>No extra dependencies. Pure Bash.</strong>
</p>

## 🧠 What it does?
It basically provides a small report regarding specific port:
```
Checking port 3000/tcp: 
PID: 2599
Service: docker.service (Docker Application Container Engine)
Currently taken by: docker-proxy
Location: /usr/bin/docker-proxy
Command: /usr/bin/docker-proxy -proto tcp -host-ip :: -host-port 3000 -container-ip 172.17.0.2 -container-port 3000 -use-listen-fd
Network: 0.0.0.0:*
Owner: root
Busy since: Jun 6 13:06:12
```
---

## 🚀 Installation & Run

1. **Clone repository:**
   ```bash
   git clone https://github.com/lookingglass/port-inspect
   cd rapid-iperf
   ```

2. **Make script executable:**
   ```bash
   chmod +x port-inspect.sh
   ```

3. **Run tool:**
   ```bash
   ./port-inspect.sh
   ```

---


## 🆗 Tested on:
- Ubuntu 24.04
- Fedora 43
