#!/bin/bash
#g0, 2018

export LC_ALL=C
export PATH="${PATH}:/OpenBTS"
GSMME="/OpenBTS/gsm_helpers.sh"
GSMOBTSHOST='127.0.0.1'
GSMOBTSPORT='49300'


gsm_helpers_version()
{
  echo "v0.3"
}

if_not_root()
{
if [ "$EUID" -ne "0" ]; then
  echo "$(whoami), you may need to run ${*} as root."
  echo
fi
}

gsm_whatup()
{
if [ "$1" == "-v" ]; then
  echo
  echo -e "USER\tPID\t%CPU\t%MEM\tVSZ\tRSS\tTTY\tSTAT\tSTART\tTIME\tCOMMAND"
  ps afux |egrep -vw 'grep|vi|vim' \
  |egrep -i "sipauth|smqueue|asterisk|openbts|transceiver"
else
  echo
  echo -e "USER\tPID\tCOMMAND"
  ps aux |egrep -vw 'grep|vi|vim' \
  |egrep -i "sipauth|smqueue|asterisk|openbts|transceiver" \
  |awk '{print $1"\t"$2"\t"$11}'
fi

echo
echo

netstat -punta \
|egrep '127.0.0.1:45060|127.0.0.1:45063|127.0.0.1:45064|2133|28670|506'
}
alias gsm_status="gsm_whatup"
alias gsm_log="tail -f /var/log/OpenBTS.log"


gsm_show_subscribers()
{
/OpenBTS/nmcli.py sipauthserve subscribers read
}

gsm_find_provisioned_imsi()
{
/OpenBTS/nmcli.py sipauthserve subscribers read |egrep -A2 "^.*imsi.*${1}"
}

gsm_find_provisioned_num()
{
/OpenBTS/nmcli.py sipauthserve subscribers read |egrep -B1 -A1 "^.*msisdn.*${1}"
}

gsm_show_all_imsis()
{
  for i in `/OpenBTS/OpenBTSCLI -c tmsis |grep -v IMSI|awk '{print $1}'`;
    do
    echo " "
    gsm_find_provisioned_imsi ${i}
    if [ ! $? -eq "0" ]; then
      echo "${i} is not provisioned."
      echo " "
    fi
  done
}

gsm_provision_imsi()
{
if [ $# -lt 3 ]; then
 echo "# - Usage: gsm_provision_imsi nickname imsi msisdn"
else
  gsm_find_provisioned_imsi ${2}
  if [ ! $? -eq "0" ]; then
    gsm_find_provisioned_num ${3}
    if [ ! $? -eq "0" ]; then
      #(create a subscriber which uses cache auth)      name   imsi    msisdn ki
      /OpenBTS/nmcli.py sipauthserve subscribers create ${1} "IMSI${2}" ${3} ${4}
    else
      echo "# - The msisnd ${3} is taken."
    fi
  else
    echo "# - The IMSI ${2} is provisioned."
  fi
fi
}

gsm_kill_all()
{
for i in \
  `ps afux |egrep -vw 'grep|vi|vim' \
  |egrep -i "sipauth|smqueue|asterisk|openbts|transceiver" \
  |awk '{print $2}'`;
do
  echo $i;
  kill -9 $i;
done

sleep 2;
gsm_whatup
}

gsm_start_transceiver()
{
if [ `id -u` -eq 0 ]; then
  if pgrep transceiver > /dev/null 2>&1; then
    ps -C transceiver
    echo "It appears that the transceiver is running."
  else
    exec /OpenBTS/transceiver 1 &
   fi
else #For now,
  echo "You need to start it as root."
fi
}

gsm_stop_transceiver()
{
if [ `id -u` -eq 0 ]; then
  if pgrep transceiver; then
    pkill transceiver
  fi
else
  echo "You need to be root."
fi
}

gsm_start_asterisk()
{
systemctl start asterisk
}

gsm_stop_asterisk()
{
systemctl stop asterisk
}

gsm_asterisk_console()
{
/usr/sbin/asterisk -r
}

gsm_start_smqueue()
{
systemctl start smqueue
}

gsm_stop_smqueue()
{
systemctl stop smqueue
}

gsm_start_sipauthserve()
{
systemctl start sipauthserve
}

gsm_stop_sipauthserve()
{
systemctl stop sipauthserve
}

gsm_start_all()
{
if_not_root ${FUNCNAME[0]}

if [ ! -e /var/run/OpenBTS ]; then
  mkdir /var/run/OpenBTS
fi

if [ ! -e /var/run/rrlp ]; then
  mkdir /var/run/rrlp
  chmod 777 /var/run/rrlp
fi

if [ ! -e /var/lib/OpenBTS ]; then
  mkdir /var/lib/OpenBTS
fi

systemctl start openbts
systemctl start sipauthserve
systemctl start smqueue
systemctl start asterisk

}

gsm_stop_all()
{
if_not_root ${FUNCNAME[0]}

if pgrep transceiver; then
  killall transceiver
fi

rm /var/run/OpenBTS.pid > /dev/null 2>&1

systemctl stop openbts
gsm_stop_transceiver
gsm_stop_asterisk
gsm_stop_smqueue
gsm_stop_sipauthserve
}

gsm_start_openbts()
{
systemctl start openbts
}

gsm_openbtsCLI()
{
if [ $# -eq 1 ]; then
/OpenBTS/OpenBTSCLI -p ${GSMOBTSPORT} -t $1
else
/OpenBTS/OpenBTSCLI -p ${GSMOBTSPORT} -t ${GSMOBTSHOST}
fi
}

gsm_openbts_config()
{
if [ $# -eq 1 ]; then
/OpenBTS/OpenBTSCLI -p ${GSMOBTSPORT} -t $1 -c rawconfig
else
/OpenBTS/OpenBTSCLI -p ${GSMOBTSPORT} -t ${GSMOBTSHOST} -c rawconfig
fi
}

gsm_openbtsCommand()
{
/OpenBTS/OpenBTSCLI -p ${GSMOBTSPORT} -t ${GSMOBTSHOST} -c $1
}

gsm_sendsms_to_all_imsis() {
  echo "sending '${1}'"
  echo
  for i in `/OpenBTS/OpenBTSCLI -c tmsis |grep -v IMSI|awk '{print $1}'`;
  do echo $i; /OpenBTS/OpenBTSCLI -c sendsms $i 88888888 $1;
  done
}

gsm_sendsimple_to_all_imsis()
{
  echo "sending '${1}'"
  echo
  for i in `/OpenBTS/OpenBTSCLI -c tmsis |grep -v IMSI|awk '{print $1}'`;
  do echo $i; /OpenBTS/OpenBTSCLI -c sendsimple $i 88888888 $1;
  done
}

gsm_list_locations_of_databases()
{
echo "sipauhserve : /var/lib/asterisk/sqlite3dir/sqlite3.db"
echo "sipauhserve : /var/lib/asterisk/sqlite3dir/sqlite3.db-wal"
echo "sipauhserve : /var/lib/asterisk/sqlite3dir/sqlite3.db-shm"
echo "sipauhserve : /etc/OpenBTS/sipauthserve.db"

echo "smqueue     : /var/lib/asterisk/sqlite3dir/sqlite3.db"
echo "smqueue     : /var/lib/asterisk/sqlite3dir/sqlite3.db-wal"
echo "smqueue     : /var/lib/asterisk/sqlite3dir/sqlite3.db-shm"
echo "smqueue     : /etc/OpenBTS/smqueue.db"

echo "OpenBTS     : /etc/OpenBTS/OpenBTS.db     "
echo "OpenBTS     : /etc/OpenBTS/sipauthserve.db"
echo "OpenBTS     : /etc/OpenBTS/smqueue.db     "
echo "OpenBTS     : /run/TMSITable.db           "
echo "OpenBTS     : /run/TMSITable.db-shm       "
echo "OpenBTS     : /run/TMSITable.db-wal       "
echo "OpenBTS     : /var/run/ChannelTable.db    "
echo "OpenBTS     : /var/log/OpenBTSStats.db    "
echo "OpenBTS     : /var/log/OpenBTSStats.db-shm"
echo "OpenBTS     : /var/log/OpenBTSStats.db-wal"
echo "OpenBTS     : /var/run/NeighborTable.db"
}

gsm_chk_databases()
{

#delete *-shm and *-wal

read -r -d '' DATABASES << EOD
/etc/OpenBTS/OpenBTS.db
/etc/OpenBTS/sipauthserve.db
/etc/OpenBTS/smqueue.db
/run/TMSITable.db
/var/log/OpenBTSStats.db
/var/lib/asterisk/sqlite3dir/sqlite3.db
/var/run/NeighborTable.db
EOD

for i in $DATABASES;
  do echo -n "$i :"; sqlite3 $i "pragma integrity_check;"
done

}


gsm_backup_databases()
{

read -r -d '' DATABASES << EOD
/etc/OpenBTS/OpenBTS.db
/etc/OpenBTS/sipauthserve.db
/etc/OpenBTS/smqueue.db
/run/TMSITable.db
/var/log/OpenBTSStats.db
/var/lib/asterisk/sqlite3dir/sqlite3.db
/var/run/NeighborTable.db
EOD

if [ ! -e /etc/OpenBTS/backups ]; then
  mkdir /etc/OpenBTS/backups
fi

EPOCH=`date +%s`
mkdir /etc/OpenBTS/backups/${EPOCH}

for i in $DATABASES;
  do DBNAME=`echo $i|tr "/" "D"`;
  sqlite3 $i ".dump" > /etc/OpenBTS/backups/${EPOCH}/${DBNAME}.sql;
done

echo "Backups are in /etc/OpenBTS/backups/${EPOCH}"
ls /etc/OpenBTS/backups/${EPOCH}
}


gsm_chk_openbts_tmsitable()
{
sqlite3 /var/run/TMSITable.db "select * from TMSI_TABLE;"
}


gsm_debug_chk_usb()
{
for i in `lsusb -t |grep 5000 |grep /: |awk '{print $3}' |awk -F '.' '{print $1}'`;
do
  for j in `ls -d -1 /dev/bus/usb/0${i}/*`;
  do
      lsusb -D $j |grep "Ettus"
      if [ $? -eq "0" ]; then
        PORT=`echo ${j} |awk -F '/' '{print $6}'`
        echo "# - OK It appears that an Ettus Radio is plugged in 0${i}.${PORT}, a USB 3.0 \"port.\""
      fi
  done
done

if [ ! -z $1 ]; then
  if [ "$@" == "-v" ]; then
    sleep 1
    echo
    echo "More: "
    lsusb -d "${VENDPRODID}" -v
  fi
fi
}

if [ "${1}" = "gsm_sendsms_to_all_imsis" ]
then
  gsm_sendsms_to_all_imsis $2
elif [ "${1}" = "gsm_openbtsCommand" ]
then
 gsm_openbtsCommand $2
elif [ "${1}" = "gsm_start_openbts-with-testcall" ]
then
 gsm_start_openbts-with-testcall
elif [ "${1}" = "gsm_whatup" ]
then
 gsm_whatup
fi



















