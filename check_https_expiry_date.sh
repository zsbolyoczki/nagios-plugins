#!/bin/bash


#
# checks the validity period of the certificate on the given host
# alerting: warning when the certificate expires in 2 weeks, critical if it expires within 1 week
#
#	required packages: curl, openssl
#
#
# usage: check_https_expiry_date.sh hostname
#
# zsbolyoczki - 2016.09.26.
#

if [ "${1}""x" == "x" ]; then
  echo "Usage: $0 hostname"
  exit 1
fi


HOST=${1}

if [ "${2}""x" != "x" ]; then
  PORT=${2}
else
  PORT=443
fi

curl --silent --insecure https://${HOST}:${PORT} >/dev/null 2>&1

if [ $? -ne 0 ]; then

  RETURN_MSG="No certificate is installed."
  RETURN_CODE=3

else

  ONE_WEEK=604800
  TWO_WEEKS=1209600

  NOW=$(date "+%s")

  CERT_END_DATE_H=$(echo | openssl s_client -connect ${HOST}:${PORT} 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep After | sed 's/=/ /g' | awk '{print $2" "$3" "$5}')
  CERT_END_DATE=$(date -d "$(echo | openssl s_client -connect ${HOST}:${PORT} 2>/dev/null | openssl x509 -noout -dates 2>/dev/null | grep After | sed 's/=/ /g' | awk '{print $2" "$3" "$5}')" +%s)

  if [ $(( ${CERT_END_DATE} - ${NOW})) -lt ${ONE_WEEK} ]; then

    RETURN_MSG="Certificate is going to expire within one week! (${CERT_END_DATE_H})"
    RETURN_CODE=2

  else

    if [ $(( ${CERT_END_DATE} - ${NOW})) -lt ${TWO_WEEKS} ]; then
      RETURN_MSG="Certificate is going to expire within two weeks! (${CERT_END_DATE_H})"
      RETURN_CODE=1
    else
      RETURN_MSG="Certificate is valid until ${CERT_END_DATE_H}"
      RETURN_CODE=0
    fi

  fi

fi

echo ${RETURN_MSG}
exit ${RETURN_CODE}

