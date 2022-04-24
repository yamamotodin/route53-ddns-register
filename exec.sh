#!/bin/sh

ZONEID=__ROUTE53ZONEID__
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=ap-northeast-1

cd `dirname $0`

if [ -s homessid ]; then
  SSID=`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I  | grep " SSID:" | sed 's/.*SSID: //g;'`
  if [ $SSID != `cat homessid` ]; then
     exit # debug
  fi
fi

if ! curl -q httpbin.org/ip -o currentip; then
  echo "error: "
  exit 1
fi

if diff currentip lastip ; then exit 0; fi

IP=`cat currentip | jq -r .origin`
sed "s/_IPADDRESS_/$IP/g" record.json > recordx.json

if aws --profile mine route53 change-resource-record-sets --hosted-zone-id $ZONEID --change-batch file://recordx.json; then
  cp currentip lastip
fi

rm recordx.json
