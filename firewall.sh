#!/bin/bash


echo "===================================================================================="
echo "=========================== APROVISIONAMIENTO DE FIREWALL =========================="
echo "===================================================================================="
echo " "
echo "================================DESACTIVANDO SELINUX================================"

cat <<TEST> /etc/selinux/config
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
TEST

echo "===============================INSTALANDO SERVICIO VIM=============================="
sudo yum install vim -y

#echo "===================== DETENIENDO SERVICIOS DE NETWORK MANAGER ======================"
#sudo service NetworkManager stop
#sudo chkconfig NetworkManager off


echo "============================ INICIANDO SERVICIO FIREWALL ==========================="
sudo service firewalld start


echo "================================== LISTANDO ZONAS =================================="
sudo firewall-cmd --list-all-zones


echo "=============================== CONFIGURANDO FIREWALL =============================="
firewall-cmd --zone=internal --remove-interface=eth0 --permanent 
firewall-cmd --zone=internal --remove-interface=eth1 --permanent
firewall-cmd --zone=internal --remove-interface=eth2 --permanent 
firewall-cmd --zone=internal --add-interface=eth2 --permanent # Interfaz de red interna
firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --zone=public --remove-interface=eth2 --permanent
firewall-cmd --zone=public --remove-interface=eth1 --permanent
firewall-cmd --zone=dmz --add-masquerade --permanent
firewall-cmd --zone=dmz --add-interface=eth1 --permanent   # Interfaz de red externa
firewall-cmd --zone=dmz --add-masquerade --permanent
firewall-cmd --zone=dmz --add-service=dns --permanent
firewall-cmd --zone=dmz --add-service=https --permanent
firewall-cmd --zone=dmz --add-service=http --permanent
firewall-cmd --zone=dmz --add-masquerade --permanent
firewall-cmd --zone=dmz --add-forward-port=port=53:proto=tcp:toport=53:toaddr=192.168.50.2 --permanent 
firewall-cmd --zone=dmz --add-forward-port=port=53:proto=udp:toport=53:toaddr=192.168.50.2 --permanent 
sudo firewall-cmd --reload

echo "=========================== LISTANDO ZONAS AFTER CONF =============================="
sudo firewall-cmd --list-all-zones

echo "=========================== CONFIGURACION DEL RESOLV ==============================="
cat <<TEST> /etc/resolv.conf
nameserver 172.16.0.2
namerserver 192.168.100.4
TEST

echo "===================================================================================="
echo "=================== TERMINAMOS APROVISIONAMIENTO DE FIREWALL ======================="
echo "===================================================================================="
