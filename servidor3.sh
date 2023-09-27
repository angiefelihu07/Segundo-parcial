#!/bin/bash

echo " "
echo " " 
echo " "
echo "===================================================================================="
echo "=========================== APROVISIONAMIENTO DE MAESTRO ==========================="
echo "===================================================================================="


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

echo "===============================INSTALANDO SERVICIO NAMED============================"
sudo yum install bind-utils bind-libs bind-* -y

echo "================================= CONFIGURANDO ZONAS ==============================="
cat > /var/named/segg.com.fwd << 'EOF'
$ORIGIN segg.com.
$TTL 3H
@       IN      SOA     servidor3.segg.com. root@segg.com. (
                        0          ; serial
                        1D         ; refresh
                        1H         ; retry
                        1W         ; expire
                        3H         ; minimum TTL
                        )
@       IN      NS      servidor3.segg.com.
@	IN	NS	servidor2.segg.com.
@	IN	NS	firewall.segg.com.
@	IN	NS	firewallpub.segg.com.

;host en la zona

@       IN      A       192.168.100.4
@	IN	A	192.168.100.2
@	IN	A	192.168.100.3
@	IN	A	172.16.0.3
servidor3	IN	A	192.168.100.4
servidor2	IN	A	192.168.100.2
firewall	IN	A	192.168.100.3
firewallpub	IN	A	172.16.0.3
EOF

cat > /var/named/segg.com.rev << 'EOF'
$ORIGIN 0.16.172.in-addr.arpa.
$TTL 3H
@       IN      SOA     servidor3.segg.com. root@segg.com. (
                        0          ; serial
                        1D         ; refresh
                        1H         ; retry
                        1W         ; expire
                        3H         ; minimum TTL
                        )
@       IN      NS      servidor3.segg.com.
@       IN      NS      servidor2.segg.com.
@       IN      NS      firewall.segg.com.
@	IN	NS	firewallpub.segg.com.

;host en la zona

4	IN	PTR     servidor3.segg.com.
2	IN	PTR     servidor2.segg.com.
3	IN	PTR     firewall.segg.com.
3	IN	PTR     firewallpub.segg.com.
EOF

echo "========================== MODIFICANDO PERMISOS DE LAS ZONAS ======================="
sudo chmod 755 /var/named/segg.com.fwd
sudo chmod 755 /var/named/segg.com.rev

echo "============================= CONFIGURANDO ZONAS EN NAMED =========================="
cat <<TEST> /etc/named.conf
options {
        listen-on port 53 { 127.0.0.1; 192.168.100.4; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
	forward only;
	forwarders { 192.168.100.4; };
        allow-query     { localhost; 192.168.100.0/24; };
	allow-transfer { 192.168.100.2; };

        recursion yes;

        dnssec-enable yes;
        dnssec-validation yes;

        /* Path to ISC DLV key */
        bindkeys-file "/etc/named.root.key";

        managed-keys-directory "/var/named/dynamic";

        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
        type hint;
        file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

zone "segg.com" IN {
	type master;
	file "segg.com.fwd";
};

zone "0.16.172.in-addr.arpa" IN {
	type master;
	file "segg.com.rev";
};
TEST

echo "===============================INICIANDO SERVICIO NAMED============================"
service named start

echo "================================= VERIFICAMOS ZONAS ==============================="
named-checkzone segg.com /var/named/segg.com.fwd
named-checkzone 0.16.172.in-addr.arpa /var/named/segg.com.rev

echo "=========================== CONFIGURACION DEL RESOLV ==============================="
cat <<TEST> /etc/resolv.conf
nameserver 192.168.100.4
TEST


echo "============================== REINICIAMOS SERVICIO NAMED ========================="
echo "================================ PARA APLICAR CAMBIOS ============================="
service named restart

echo "===================================================================================="
echo "=================== TERMINAMOS APROVISIONAMIENTO DE MAESTRO ========================"
echo "===================================================================================="