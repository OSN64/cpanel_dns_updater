#!/usr/bin/env bash

BASEURL="" # Cpanel url
APITOKEN="" # Cpanel api token
APIUSER="" # Cpanel api user

DOMAIN="" # Root domain name
NAME="" # Subdomain or root domain name if managed by cpanel
IPADDR="" # IP address
TTL="" # Time to live
RECORDTYPE="A"

CPANELZONESEARCHPATH="cpanel_jsonapi_apiversion=2&cpanel_jsonapi_module=ZoneEdit&cpanel_jsonapi_func=fetchzone&domain=$DOMAIN&type=$RECORDTYPE"

DNSLINE=$(curl --silent -H"Authorization: cpanel $APIUSER:$APITOKEN" "$BASEURL/json-api/cpanel?$CPANELZONESEARCHPATH" \
    | jq --arg host_name "$NAME" -c '.[].data | .[0].record | .[] | select( .name == "'$NAME'.").line')

CPANELDNSPATH="cpanel_jsonapi_apiversion=2&cpanel_jsonapi_module=ZoneEdit&cpanel_jsonapi_func=edit_zone_record&domain=$DOMAIN&name=$NAME.&type=$RECORDTYPE&class=IN&ttl=$TTL&line=$DNSLINE&address=$IPADDR"

UPDATERESULT=$(curl --silent -H"Authorization: cpanel $APIUSER:$APITOKEN" "$BASEURL/json-api/cpanel?$CPANELDNSPATH" \
    | jq -c '.[].event.result')

if [[ $UPDATERESULT == 1 ]]; then
    echo "Successfully updated $NAME $RECORDTYPE record with $IPADDR"
else
    echo "Failed to update $NAME $RECORDTYPE record"
fi
