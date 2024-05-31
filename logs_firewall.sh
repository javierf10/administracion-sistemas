#!/bin/bash


#al principio del script
ptables -F
iptables -X
iptables -Z
iptables -N LOG_INPUT_ACCEPT
iptables -A LOG_INPUT_ACCEPT -j LOG --log-level 7 --log-prefix "[INPUT_ACCEPT]: "
iptables -A LOG_INPUT_ACCEPT -j ACCEPT
iptables -N LOG_INPUT_DROP
iptables -A LOG_INPUT_DROP -j LOG --log-level 7 --log-prefix "[INPUT_DROP]: "
iptables -A LOG_INPUT_DROP -j DROP
iptables -N LOG_FORWARD_DROP
iptables -A LOG_FORWARD_DROP -j LOG --log-level 7 --log-prefix "[FORWARD_DROP]: "
iptables -A LOG_FORWARD_DROP -j DROP



# LIMPIEZA DE REGLAS EN IPTABLES
#iptables -F
#iptables -X
#iptables -Z
#iptables -t nat -F
# POLITICAS POR DEFECTO
iptables -P INPUT LOG_INPUT_DROP
iptables -P FORWARD LOG_INPUT_DROP
# Configuración de direcciones con las que se sale hacia el NAT, dando acceso a Internet a estas redes
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o enp0s3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o enp0s3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.3.0/24 -o enp0s3 -j MASQUERADE
# Proporciona la IP de debian1 a todo lo que sale hacia la extranet
iptables -t nat -A POSTROUTING -o enp0s8 -j SNAT --to 192.168.56.2
iptables -t nat -A PREROUTING -i enp0s8 -j DNAT --to 192.168.56.2
# Redirección de peticiones al servidor web de Apache de debian2 y al servidor ssh de debian5
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to 192.168.1.2:80
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 192.168.3.5:22
# Permite el paso de todo el tráfico de intranet así como los pings de respuesta de host
iptables -A FORWARD -i enp0s8 -p icmp --icmp-type 0 -j ACCEPT
iptables -A FORWARD -i enp0s3 -p all -j ACCEPT
iptables -A FORWARD -i enp0s9 -p all -j ACCEPT
iptables -A FORWARD -i enp0s10 -p all -j ACCEPT
#Políticas para permitir el tráfico hacia debian5 por el puerto 22 (ssh) y hacia debian2 por los puertos 80(http) y 443(https)
iptables -A FORWARD -d 192.168.3.5 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -d 192.168.1.2 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -d 192.168.1.2 -p tcp --dport 443 -j ACCEPT
# Permite que entre todo el tráfico de intranet y la respuesta del host a los pings
iptables -A INPUT -i enp0s8 -p icmp --icmp-type 0 -j LOG_INPUT_ACCEPT
iptables -A INPUT -i enp0s3 -p all -j LOG_INPUT_ACCEPT
iptables -A INPUT -i enp0s9 -p all -j LOG_INPUT_ACCEPT
iptables -A INPUT -i enp0s10 -p all -j LOG_INPUT_ACCEPT
iptables -A INPUT -i lo -p all -j LOG_INPUT_ACCEPT
iptables -A INPUT -i enp0s3 -m state --state ESTABLISHED,RELATED -j LOG_INPUT_ACCEPT
iptables -A INPUT -i enp0s8 -m state --state ESTABLISHED,RELATED -j LOG_INPUT_ACCEPT


#Además, deberás sustituir el objetivo con estas nuevas reglas:
#cadenas INPUT con -j ACCEPT→ -j LOG_INPUT_ACCEPT
#cadenas INPUT con -j DROP→ -j LOG_INPUT_DROP
#cadenas FORWARD con -j DROP→ -j LOG_INPUT_DROP


#añadir al final del script
iptables -A INPUT -j LOG_INPUT_DROP
iptables -A FORWARD -j LOG_FORWARD_DROP



# Preservación de las reglas iptables
iptables-save > /etc/iptables/rules.v4
