# Q2: Troubleshooting Unreachable Internal Web Dashboard

## Scenario

Our internal web dashboard, hosted at `internal.example.com`, has become unreachable from multiple systems. Users are reporting "host not found" errors, suggesting a DNS issue, although the service itself might be running. The task is to troubleshoot this DNS or network misconfiguration, verify the root cause, and restore connectivity.

## Your Task

### 1. Verify DNS Resolution

**Goal:** Check if the domain `internal.example.com` resolves correctly using the system's configured DNS servers versus a public DNS server like Google's (8.8.8.8).

**Commands (Linux):**

*   **Check configured DNS servers:**
    ```bash
    cat /etc/resolv.conf
    ```
    *Explanation:* This command displays the DNS servers the system is currently configured to use. Note the IP addresses listed under `nameserver`.

*   **Query using system's default DNS:**
    ```bash
    dig internal.example.com
    ```
    *Explanation:* `dig` (Domain Information Groper) queries the default DNS servers (from `/etc/resolv.conf`) for the IP address of `internal.example.com`. Look at the `ANSWER SECTION`. A "host not found" error (NXDOMAIN status) or no answer section indicates a failure with the default DNS.

*   **Query using a specific public DNS (Google):**
    ```bash
    dig @8.8.8.8 internal.example.com
    ```
    *Explanation:* This command specifically asks Google's public DNS server (`8.8.8.8`) to resolve `internal.example.com`. If this command returns a valid IP address in the `ANSWER SECTION` while the previous `dig` command failed, it strongly suggests the issue lies with the internal DNS servers listed in `/etc/resolv.conf`.

### 2. Diagnose Service Reachability

**Goal:** Once you have a potential IP address for `internal.example.com` (ideally obtained from the `dig @8.8.8.8` command if internal DNS failed), check if the web service is actually running and reachable on that IP address over the network. Assume the service runs on standard ports 80 (HTTP) or 443 (HTTPS). Let's assume the resolved IP is `192.168.1.100`.

**Commands (Linux):**

*   **Check connectivity using `curl` (HTTP/HTTPS):**
    ```bash
    # Check HTTP (Port 80)
    curl -Iv http://192.168.1.100
    
    # Check HTTPS (Port 443)
    curl -kIv https://192.168.1.100 
    ```
    *Explanation:* `curl` attempts to connect to the specified IP and port.
    *   `-I` fetches headers only.
    *   `-v` provides verbose output, showing connection attempts.
    *   `-k` (for HTTPS) ignores SSL certificate errors, useful for internal sites with self-signed certs.
    *   A successful connection will show HTTP status codes (e.g., `HTTP/1.1 200 OK`). Failure might show "Connection refused," "Connection timed out," or other errors.

*   **Check port reachability using `telnet`:**
    ```bash
    # Check Port 80
    telnet 192.168.1.100 80
    
    # Check Port 443
    telnet 192.168.1.100 443
    ```
    *Explanation:* `telnet` tries to establish a basic TCP connection to the specified IP and port.
    *   If it connects (shows `Connected to 192.168.1.100`), the port is open and listening. You might need to press `Ctrl+]` then type `quit` to exit.
    *   If it fails ("Connection refused," "Unable to connect"), the service isn't listening or a firewall is blocking access.

*   **Check if the service is listening locally (Run this ON the server `internal.example.com` if possible):**
    ```bash
    # Using netstat
    sudo netstat -tulnp | grep -E ':80|:443'
    
    # Using ss (newer alternative)
    sudo ss -tulnp | grep -E ':80|:443'
    ```
    *Explanation:* These commands list listening network sockets.
    *   `-t` TCP, `-u` UDP, `-l` listening, `-n` numeric ports/hosts, `-p` show process.
    *   We filter (`grep`) for lines containing `:80` or `:443`. If the web server process (like Apache, Nginx) is listening correctly, you should see entries for these ports, often bound to `0.0.0.0` (all interfaces) or a specific IP.

### 3. Trace the Issue – List All Possible Causes

Here are potential reasons why `internal.example.com` might be unreachable, even if the service process is running on the server:

1.  **Internal DNS Server Failure:** The DNS servers listed in `/etc/resolv.conf` are down, misconfigured, or cannot resolve `internal.example.com`.
2.  **Incorrect DNS Record:** The DNS record for `internal.example.com` on the internal DNS server points to the wrong IP address or doesn't exist (NXDOMAIN).
3.  **Client DNS Configuration Error:** The client machine's `/etc/resolv.conf` points to the wrong DNS servers entirely.
4.  **Client `/etc/hosts` File Override:** An incorrect entry in the client's `/etc/hosts` file is overriding DNS resolution for `internal.example.com`.
5.  **Network Connectivity Issue:** Basic network path failure between the client and the server (e.g., routing problems, down link).
6.  **Firewall Blocking (Client-side):** A firewall on the client machine is blocking outbound connections on port 80/443.
7.  **Firewall Blocking (Network):** A network firewall between the client and server is blocking traffic to the server's IP on port 80/443.
8.  **Firewall Blocking (Server-side):** A firewall (like `iptables`, `firewalld`, `ufw`) on the server `internal.example.com` is blocking incoming connections on port 80/443.
9.  **Web Service Not Running/Listening:** The web server process (Apache, Nginx, etc.) on `internal.example.com` has crashed or is not configured to listen on the expected IP address or port (80/443).
10. **Web Service Misconfiguration:** The web server is running but misconfigured (e.g., virtual host setup incorrect, binding to the wrong interface).
11. **Resource Exhaustion on Server:** The server has run out of resources like memory, CPU, or file descriptors, preventing it from accepting new connections.

### 4. Propose and Apply Fixes

*(Note: Commands often require `sudo` privileges)*

1.  **Internal DNS Server Failure**
    *   **Confirmation:** `dig internal.example.com` fails, but `dig @8.8.8.8 internal.example.com` succeeds. Pinging the internal DNS server IPs (from `/etc/resolv.conf`) might also fail.
    *   **Fix:**
        *   Investigate and restart/fix the internal DNS service (e.g., BIND, dnsmasq) on the DNS server machine(s). (Commands depend heavily on the specific DNS software).
        *   *Temporary Client Fix:* Manually edit `/etc/resolv.conf` on the client to use a working DNS server (like 8.8.8.8), but this might be overwritten. See Bonus for persistent changes.

2.  **Incorrect DNS Record**
    *   **Confirmation:** `dig internal.example.com` returns the wrong IP or NXDOMAIN, while `dig @8.8.8.8 internal.example.com` (if it's also public) might show the correct one, or internal checks confirm the record error.
    *   **Fix:** Log into the internal DNS server's management interface or configuration files and correct the A record (or AAAA for IPv6) for `internal.example.com` to point to the correct server IP. Restart the DNS service if needed.

3.  **Client DNS Configuration Error**
    *   **Confirmation:** `cat /etc/resolv.conf` shows incorrect/unreachable DNS server IPs.
    *   **Fix:** Correct the DNS settings. This depends on how the client network is managed:
        *   *DHCP:* Renew the DHCP lease: `sudo dhclient -r && sudo dhclient`
        *   *Static IP / NetworkManager:* Use `nmtui` or edit connection profiles via GUI/nmcli.
        *   *Static IP / systemd-networkd:* Edit `.network` files in `/etc/systemd/network/` and run `sudo networkctl reload`.
        *   *Manual /etc/resolv.conf (Not Recommended):* Edit the file directly (likely temporary).

4.  **Client `/etc/hosts` File Override**
    *   **Confirmation:** `grep internal.example.com /etc/hosts` shows an entry pointing to the wrong IP.
    *   **Fix:** Edit `/etc/hosts` and remove or correct the line for `internal.example.com`.
        ```bash
        sudo nano /etc/hosts 
        # Find the line with internal.example.com and either delete it or prefix it with # to comment it out.
        ```

5.  **Network Connectivity Issue**
    *   **Confirmation:** `ping <server_IP>` fails. `traceroute <server_IP>` or `mtr <server_IP>` shows packet loss or stops at a specific hop.
    *   **Fix:** Requires network infrastructure troubleshooting (checking routers, switches, cables between the client and server). This is beyond simple commands on one machine.

6.  **Firewall Blocking (Client-side)**
    *   **Confirmation:** Temporarily disable the client firewall (e.g., `sudo systemctl stop firewalld`, `sudo ufw disable`) and see if connectivity is restored. Check firewall logs (`/var/log/firewalld`, `/var/log/ufw.log`, `/var/log/syslog`).
    *   **Fix:** Add rules to allow outbound traffic on TCP ports 80 and 443.
        *   *firewalld:* `sudo firewall-cmd --add-port=80/tcp --permanent && sudo firewall-cmd --add-port=443/tcp --permanent && sudo firewall-cmd --reload`
        *   *ufw:* `sudo ufw allow out 80/tcp && sudo ufw allow out 443/tcp`

7.  **Firewall Blocking (Network)**
    *   **Confirmation:** Requires checking the configuration and logs of network firewalls (e.g., Palo Alto, Cisco ASA, Fortinet). `traceroute` might stop just before the server IP.
    *   **Fix:** Modify rules on the network firewall device to allow traffic from client networks to the server IP on ports 80/443.

8.  **Firewall Blocking (Server-side)**
    *   **Confirmation:** Run firewall status/listing commands *on the server*. Temporarily disable the server firewall (see Client-side) and test connectivity from the client. Check server firewall logs.
    *   **Fix:** Add rules *on the server* to allow incoming traffic on TCP ports 80 and 443.
        *   *firewalld:* `sudo firewall-cmd --add-service=http --permanent && sudo firewall-cmd --add-service=https --permanent && sudo firewall-cmd --reload` (or use `--add-port` as above)
        *   *ufw:* `sudo ufw allow http && sudo ufw allow https` (or `sudo ufw allow 80/tcp && sudo ufw allow 443/tcp`)
        *   *iptables:* Requires specific `iptables -A INPUT ...` commands (more complex).

9.  **Web Service Not Running/Listening**
    *   **Confirmation:** `sudo netstat -tulnp | grep -E ':80|:443'` (or `ss`) *on the server* shows no process listening on the expected ports/IPs. `systemctl status <webserver_service_name>` (e.g., `apache2`, `nginx`, `httpd`) shows inactive or failed status.
    *   **Fix:** Start or restart the web server service *on the server*.
        ```bash
        sudo systemctl start <webserver_service_name>
        sudo systemctl enable <webserver_service_name> # To start on boot
        ```
        Check service logs (`/var/log/nginx/error.log`, `/var/log/apache2/error.log`, etc.) for startup errors.

10. **Web Service Misconfiguration**
    *   **Confirmation:** Service is running (`systemctl status` is active), but `netstat`/`ss` shows it listening on the wrong IP (e.g., `127.0.0.1` instead of `0.0.0.0` or the public IP) or port. `curl` or `telnet` might connect but give unexpected errors (e.g., 403 Forbidden, wrong site content).
    *   **Fix:** Edit the web server configuration files *on the server* (e.g., `/etc/nginx/sites-available/`, `/etc/apache2/sites-available/`, `/etc/httpd/conf.d/`) to correct `Listen` directives, `ServerName`, `VirtualHost` blocks, etc. Reload/restart the web service after changes (`sudo systemctl reload nginx`, `sudo systemctl restart apache2`).

11. **Resource Exhaustion on Server**
    *   **Confirmation:** Commands like `top`, `htop`, `free -h`, `df -h` *on the server* show very high CPU/memory usage or full disks. Server logs might indicate resource errors. Connections might be very slow or time out intermittently.
    *   **Fix:** Identify the resource-hungry process(es) and either optimize them, kill them if unnecessary, or add more resources (CPU, RAM, disk space) to the server.

---

### Bonus

*   **Configure `/etc/hosts` entry to bypass DNS:**
    *   **Action:** Add a line to the client's `/etc/hosts` file mapping the domain name directly to the known correct IP address.
    *   **Command:**
        ```bash
        # Assuming 192.168.1.100 is the correct IP
        echo "192.168.1.100 internal.example.com" | sudo tee -a /etc/hosts
        ```
    *   **Verification:** `ping internal.example.com` or `curl http://internal.example.com` should now work immediately on this client, regardless of DNS server status. Remember to remove this line once the actual DNS issue is fixed to avoid future confusion.

*   **Persist DNS Server Settings:** Manually editing `/etc/resolv.conf` is often temporary. To make DNS server settings persistent:
    *   **Using `systemd-resolved`:**
        1.  Edit `/etc/systemd/resolved.conf`.
        2.  Uncomment and set the `DNS=` line (e.g., `DNS=8.8.8.8 1.1.1.1`).
        3.  Uncomment and set `FallbackDNS=` if desired.
        4.  Restart the service: `sudo systemctl restart systemd-resolved`.
        5.  Ensure `/etc/resolv.conf` is a symlink to `/run/systemd/resolve/stub-resolv.conf` (often managed automatically).
    *   **Using `NetworkManager`:**
        1.  Use the command-line tool `nmcli` or the text UI `nmtui`.
        2.  Example using `nmcli` (replace `YourConnectionName` with the actual connection name, e.g., `eth0` or `Wired connection 1`):
            ```bash
            # View current DNS
            nmcli dev show YourConnectionName | grep IP4.DNS 
            # Set new DNS servers (overwrites existing)
            sudo nmcli con mod YourConnectionName ipv4.dns "8.8.8.8 1.1.1.1"
            # Ensure DNS is not ignored
            sudo nmcli con mod YourConnectionName ipv4.ignore-auto-dns no 
            # Apply changes
            sudo nmcli con down YourConnectionName && sudo nmcli con up YourConnectionName
            ```
        3.  Alternatively, use `nmtui` -> "Edit a connection" -> Select connection -> Edit -> IPv4 CONFIGURATION -> Change Method to "Manual", add DNS servers, set "Ignore automatically obtained DNS parameters" to YES. Save and reactivate the connection.