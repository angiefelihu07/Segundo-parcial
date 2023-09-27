#!/bin/bash

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


echo "==============================CONFIGURANDO ZONAS DE NAMED==========================="
cat <<TEST> /etc/named.conf
options {
        listen-on port 53 { 127.0.0.1; 172.16.0.2; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
        allow-query     { localhost; 172.16.0/24; };

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
	type slave;
	file "slaves/segg.com.fwd";
	masters{ 192.168.100.4; };
};

zone "0.16.172.in-addr.arpa" IN {
	type slave;
	file "slaves/segg.com.rev";
	masters{ 192.168.100.4; };
};
TEST

echo "===============================INICIANDO SERVICIO NAMED============================"
service named start


echo "=========================== CONFIGURACION DEL RESOLV =============================="
cat <<TEST> /etc/resolv.conf
nameserver 192.168.100.2
nameserver 172.16.0.2
TEST

echo "============================== REINICIAMOS SERVICIO NAMED ========================="
echo "================================ PARA APLICAR CAMBIOS ============================="
service named restart