import os
import sys
import time
import socket
import signal
from typing import List, Tuple, Optional
from zeroconf import Zeroconf, ServiceInfo

def register_domain(zc: Zeroconf, domain: str, port: int, ip_address: str) -> Optional[ServiceInfo]:
    """Register an mDNS service representing the given domain pointing to the specified IP address and port."""
    # Ensure domain ends with a dot for zeroconf
    if not domain.endswith('.'):
        domain_dot = domain + '.'
    else:
        domain_dot = domain
        domain = domain[:-1]

    # Create a unique instance name to avoid service name collisions
    instance = domain.replace('.', '-')
    service_type = "_http._tcp.local."
    full_service_name = f"{instance}.{service_type}"

    print(f"Registering mDNS service: {full_service_name} for host {domain_dot} pointing to {ip_address} on port {port}")

    try:
        # Convert IP string to bytes representation
        address_bytes = socket.inet_aton(ip_address)

        info = ServiceInfo(
            type_=service_type,
            name=full_service_name,
            addresses=[address_bytes],
            port=port,
            server=domain_dot,
            properties={}
        )

        zc.register_service(info)
        return info
    except Exception as e:
        print(f"Failed to register mDNS service for {domain_dot}: {e}", file=sys.stderr)
        return None

def main() -> None:
    print("Starting mDNS Publisher daemon...")

    # Graceful shutdown handling
    running = True

    def handle_shutdown(signum: int, frame: any) -> None:
        nonlocal running
        print(f"Shutdown signal ({signum}) received. Cleaning up...")
        running = False

    signal.signal(signal.SIGINT, handle_shutdown)
    signal.signal(signal.SIGTERM, handle_shutdown)

    # 1. Retrieve the advertise IP
    advertise_ip = os.environ.get("MDNS_ADVERTISE_IP", "").strip()
    if not advertise_ip or advertise_ip == "0.0.0.0":
        print("Warning: MDNS_ADVERTISE_IP is not set or is '0.0.0.0'. "
              "mDNS publishing requires a specific host IP address. "
              "Please configure NODE_MDNS_ADVERTISE_IP in your environment. Exiting.", file=sys.stderr)
        sys.exit(0)

    # 2. Retrieve the list of hostnames and ports to advertise
    hosts_env = os.environ.get("MDNS_HOSTS", "")
    entries = [h.strip() for h in hosts_env.split() if h.strip()]

    domains_with_ports: List[Tuple[str, int]] = []
    for entry in entries:
        if ":" in entry:
            domain, port_str = entry.split(":", 1)
            try:
                port = int(port_str)
            except ValueError:
                port = 80
        else:
            domain = entry
            port = 80

        if domain.endswith(".local") or domain.endswith(".local."):
            domains_with_ports.append((domain, port))

    if not domains_with_ports:
        print("No valid .local domains configured in MDNS_HOSTS. Exiting.", file=sys.stderr)
        sys.exit(0)

    print(f"Configured domains to advertise: {domains_with_ports} on IP {advertise_ip}")

    # 3. Register mDNS services
    zc = Zeroconf(interfaces=[advertise_ip])
    registered_services: List[ServiceInfo] = []

    for domain, port in domains_with_ports:
        info = register_domain(zc, domain, port, advertise_ip)
        if info:
            registered_services.append(info)

    if not registered_services:
        print("Failed to register any mDNS services. Exiting.", file=sys.stderr)
        zc.close()
        sys.exit(1)

    print("mDNS Publisher is fully running. Press Ctrl+C to exit.")

    # Keep running until signal received
    while running:
        time.sleep(1)

    # 4. Cleanup
    print("Unregistering services...")
    for info in registered_services:
        try:
            zc.unregister_service(info)
        except Exception as e:
            print(f"Error unregistering service: {e}", file=sys.stderr)

    zc.close()
    print("mDNS Publisher stopped successfully.")

if __name__ == "__main__":
    main()
