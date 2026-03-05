import socket
import subprocess
import platform

def get_local_ip():
    """Get the local IP address of the machine"""
    try:
        # Create a socket to get the IP address
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except:
        # Fallback method
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
        return local_ip

def main():
    ip = get_local_ip()
    print(f"Your laptop IP address: {ip}")
    print(f"Use this URL in your app: http://{ip}:5000/api")
    print("\nUpdate the baseUrl in lib/core/config/env_config.dart:")
    print(f"baseUrl = 'http://{ip}:5000/api';")

if __name__ == "__main__":
    main()
