#!/bin/bash
## Script To Check & Block DDOS ##
## Written : 17 DEC 2014 ##
## By Qasim ( qasim@websouls.com)

netstat -plan|grep :80|awk {'print $5'}|cut -d: -f 1|sort|uniq -c|sort -nk 1 | tail -n 20 > /var/log/ddos
IPADR=`ifconfig | grep "inet addr" |awk '{print $2}' | grep -v 127 | cut -d : -f 2 > /var/log/IPADR`
grep -Ff /var/log/IPADR -v /var/log/ddos  > /var/log/Alpha
for i in {1..20}; do
	IPADR=`sed -n "$i"p /var/log/Alpha | awk '{print $2}'`
	Connections=`sed -n "$i"p /var/log/Alpha | awk '{print $1}'`
	if [[ $Connections -ge 1200 ]]; then
		csf -d $IPADR
	fi
done

awk '{print $1}' /usr/local/apache/logs/access_log | sort | uniq -c | sort -n | tail -n 200 > /var/log/ddosApacheAL.txt
grep -Ff /var/log/IPADR -v /var/log/ddosApacheAL.txt  > /var/log/ddosApacheALEx.txt
for dAal in {1..200}; do
NOFL=`sed -n "$dAal"p /var/log/ddosApacheALEx.txt |  awk '{print $1}'`
BIP=`sed -n "$dAal"p /var/log/ddosApacheALEx.txt |  awk '{print $2}'`
if [[ $NOFL -ge 10000 ]]; then
	csf -d $BIP
fi
done
