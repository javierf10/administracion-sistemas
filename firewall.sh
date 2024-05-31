#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

# Comprobamos que el script tiene permisos de administrador
if [ $EUID -ne 0 ]; then
    echo "No posees de servicios de administrador"
    exit 1
fi

# Interfaces
INTRANET_IF1="enp0s9"  # Ejemplo de interfaz para intranet
INTRANET_IF2="enp0s10" # Ejemplo de interfaz para intranet
EXTRANET_IF="enp0s3"   # Ejemplo de interfaz para extranet

# IPs de los servidores
DEBIAN2_IP="192.168.56.10" # IP del servidor web
DEBIAN5_IP="192.168.58.10" # IP del servidor SSH

# IP pública del firewall (interfaz a la extranet)
FIREWALL_PUBLIC_IP="192.168.59.20"

# Inicializamos la tabla filter
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitimos todas las conexiones dentro de la red interna (intranet)
iptables -A FORWARD -i $INTRANET_IF1 -j ACCEPT
iptables -A FORWARD -i $INTRANET_IF2 -j ACCEPT
iptables -A FORWARD -s 192.168.56.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.57.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.58.0/24 -j ACCEPT

# Permitimos tráfico entrante en la interfaz loopback
iptables -A INPUT -i lo -j ACCEPT

# Permitimos tráfico ICMP (ping) desde la intranet
iptables -A INPUT -i $INTRANET_IF1 -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -i $INTRANET_IF2 -p icmp --icmp-type echo-request -j ACCEPT

# Bloqueamos tráfico ICMP (ping) desde la extranet
iptables -A INPUT -i $EXTRANET_IF -p icmp --icmp-type echo-request -j DROP

# Permitimos respuestas de extranet a peticiones de intranet (conexión a Internet)
iptables -A INPUT -i $EXTRANET_IF -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $EXTRANET_IF -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitimos tráfico entrante HTTP y SSH desde la extranet a los servidores específicos
iptables -A FORWARD -p tcp -d $DEBIAN2_IP --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp -d $DEBIAN5_IP --dport 22 -j ACCEPT

# Configuramos NAT (POSTROUTING) para que todo el tráfico saliente de la intranet use la IP pública del firewall
iptables -t nat -A POSTROUTING -o $EXTRANET_IF -j SNAT --to $FIREWALL_PUBLIC_IP

# Configuramos DNAT (PREROUTING) para redirigir tráfico entrante desde la extranet a los servidores específicos en la intranet
iptables -t nat -A PREROUTING -i $EXTRANET_IF -p tcp --dport 80 -j DNAT --to-destination $DEBIAN2_IP
iptables -t nat -A PREROUTING -i $EXTRANET_IF -p tcp --dport 22 -j DNAT --to-destination $DEBIAN5_IP

# Guardamos las reglas de iptables
iptables-save > /etc/iptables/rules.v4

echo "Configuración del firewall satisfactoria"
