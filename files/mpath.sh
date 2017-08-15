#!/bin/sh
#
# This script must umount multipath on any circunstances
# If it is mounted and in use... Kill the processes then umpount and unexport multipath
# Is been designed to use with multipath isca0 ansible roles
#
# by : isca
#
#

set -x
set -e

error=

if [ "$#" -lt "2" ];then
  echo "Insuficient arguments"
  erro=50
  exit $erro
fi

mpathbin=$(which multipath)
if [ "$?" != "0" ];then
  echo "Multipath not installed"
  export error=100
  exit $error
fi

dmsetbin=$(which dmsetup)
if [ "$?" != "0" ];then
  echo "dmsetup not found"
  export error=101
  exit $error
fi


#wwids="/etc/multipath/wwids"
#if [ -e "$wwids" ];then
#  declare -a multipaths=($(grep '/' "$wwids"|awk -F'/' '{print $2}'))
#fi
#
#umount_mpath(){
#  for ((mounts=0; mounts < ${#multipaths[@]}; mounts++ ));do
#    if mount|grep ${multipaths[$mounts]};then
#      for pids in $(lsof /dev/mapper/${multipaths[$mounts]}|awk '{print $2}'|grep -vi pid);do
#        kill -9 $pids
#      done
#      umount -l /dev/mapper/${multipaths[$mounts]}
#    fi
#    if multipath -l|grep ${multipaths[$mounts]};then
#      multipath -f ${multipaths[$mounts]}
#    fi
#  done
#}

export devsof="$2"
release_mount(){

  if [ ! -e "$devsof" ];then
    echo "No such device found"
    erro=200
    exit $erro
  fi

  for pids in $(lsof "$devsof"|awk '{print $2}'|grep -vi pid);do
    kill -9 $pids
  done

}

case "$1" in
  release)
    release_mount
  ;;

  *)
    echo "Use: release"
  ;;
esac
exit 0
