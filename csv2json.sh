#!/bin/bash

## This parser is ready for v3 of slists file.

# Columns:
# [0]  vpnserver_country
# [1]  vpnserver_city
# [2]  vpnserver_note
# [3]  vpnserver_supported_protocols
# [4]  vpnserver_address
# [5]  vpnserver_servers
# [6]  vpnserver_t_p2p
# [7]  vpnserver_smartvpn
# [8]  vpnserver_dns
# [9]  vpnserver_openvpn_port
# [10] vpnserver_description
# [11] vpnserver_flag
# [12] vpnserver_map

CSV_URL="https://raw.githubusercontent.com/goodylabs/devops-test/main/slist-combined-v3.csv"

AWK=`which awk`
CAT=`which cat`
CURL=`which curl`
CUT=`which cut`
SED=`which sed`
TR=`which tr`
WC=`which wc`

### DO NOT EDIT BELOW THIS LINE ###

backupIFS="${IFS}"

CSV_LOCAL_FILE="$1"
JSON_LOCAL_FILE="$2"

if [ "x${CSV_LOCAL_FILE}" == "" ]; then
  CSV_LOCAL_FILE="./slist-combined-v3.csv"
fi

if [ "x${JSON_LOCAL_FILE}" == "" ]; then
  JSON_LOCAL_FILE="./slist-combined-v3.json"
fi

$CURL -vvvvvvv "${CSV_URL}" -o "${CSV_LOCAL_FILE}"

num_of_lines=`${AWK} 'END { print NR }' ${CSV_LOCAL_FILE}`

echo -n "" > ${JSON_LOCAL_FILE}

echo "{" >> ${JSON_LOCAL_FILE}
echo "  \"servers\": [" >> ${JSON_LOCAL_FILE}

line_no=1

while read line; do
  # echo "Line: $line"

  line=`echo ${line} | ${SED} -e "s/^,/%,/" -e "s/,/,%,/g" -e "s/,$/,%/"`

  # echo "Safe line: ${line}"

  first_column=`echo ${line} | ${CUT} -f 1 -d ","`

  if [ "x${first_column}" != "xvpnserver_country" ]; then
    read -a columns <<< $(echo ${line} | ${TR} ' ' '%' | ${TR} ',' ' ')
    # for column in "${columns[@]}"; do
    #   echo "Column: ${column}"
    # done

    echo "    {" >> ${JSON_LOCAL_FILE}
    echo "      \"vpnserver_country\": \"${columns[0]//%/ }\","   >> ${JSON_LOCAL_FILE}
    echo "      \"vpnserver_city\": \"${columns[1]//%/ }\","      >> ${JSON_LOCAL_FILE}
    echo "      \"vpnserver_note\": \"${columns[2]//%/ }\","      >> ${JSON_LOCAL_FILE}
    echo "      \"vpnserver_supported_protocols\": ["             >> ${JSON_LOCAL_FILE}

    read -a values <<< $(echo ${columns[3]} | ${TR} -d '%' | ${TR} ';' ' ')

    i=0
    for value in "${values[@]}"; do
      echo -n "        \"${value//%/ }\""                        >> ${JSON_LOCAL_FILE}
      if [ "x${value}" != "x${values[${#values[@]}-1]}" ]; then
        echo "," >> ${JSON_LOCAL_FILE}
      else
        echo "" >> ${JSON_LOCAL_FILE}
      fi
    done
    echo "      ],"                                              >> ${JSON_LOCAL_FILE}
    echo "      \"vpnserver_address\": \"${columns[4]}\","       >> ${JSON_LOCAL_FILE}
    echo "      \"vpnserver_servers\": ["                        >> ${JSON_LOCAL_FILE}
    echo "        \"${columns[5]}\""                             >> ${JSON_LOCAL_FILE}
    echo "      ],"                                              >> ${JSON_LOCAL_FILE}

    value=""
    if [ "x${columns[6]}" == "xyes" ]; then
      value="true"
    elif [ "x${columns[6]}" == "xno" ]; then
      value="false"
    fi
    echo "      \"vpnserver_t_p2p\": ${value},"                  >> ${JSON_LOCAL_FILE}

    value=""
    if [ "x${columns[7]}" == "xyes" ]; then
      value="true"
    elif [ "x${columns[7]}" == "xno" ]; then
      value="false"
    fi
    echo "      \"vpnserver_smartvpn\": ${value},"               >> ${JSON_LOCAL_FILE}
    echo "      \"vpnserver_dns\": ["                            >> ${JSON_LOCAL_FILE}

    read -a values <<< $(echo ${columns[8]} | ${TR} -d '%' | ${TR} ';' ' ')

    i=0
    for value in "${values[@]}"; do
      echo -n "        \"${value//%/ }\""                        >> ${JSON_LOCAL_FILE}
      if [ "x${value}" != "x${values[${#values[@]}-1]}" ]; then
        echo "," >> ${JSON_LOCAL_FILE}
      else
        echo "" >> ${JSON_LOCAL_FILE}
      fi
    done
    echo "      ],"                                              >> ${JSON_LOCAL_FILE}

    echo "      \"vpnserver_openvpn_port\": ["                   >> ${JSON_LOCAL_FILE}

    read -a values <<< $(echo ${columns[9]} | ${TR} ' ' '%' | ${TR} ';' ' ')

    i=0
    for value in "${values[@]}"; do
      orig_value="${value}"
      value="${value//%/ }"
      value="${value// UDP/UDP}"
      value="${value// TCP/TCP}"

      echo -n "        \"${value}\""                             >> ${JSON_LOCAL_FILE}
      if [ "x${orig_value}" != "x${values[${#values[@]}-1]}" ]; then
        echo "," >> ${JSON_LOCAL_FILE}
      else
        echo "" >> ${JSON_LOCAL_FILE}
      fi
    done
    echo "      ],"                                              >> ${JSON_LOCAL_FILE}

    value="${columns[10]//%/ }"
    echo "      \"vpnserver_description\": \"${value}\","        >> ${JSON_LOCAL_FILE}
    echo "      \"vpnserver_flag\": \"${columns[11]}\","         >> ${JSON_LOCAL_FILE}
    echo "      \"vpnserver_map\": \"${columns[12]}\""           >> ${JSON_LOCAL_FILE}

    echo -n "    }" >> ${JSON_LOCAL_FILE}

    line_no=$(($line_no+1))

    # echo "Line no: ${line_no} of ${num_of_lines}"

    if [ ${line_no} -lt ${num_of_lines} ]; then
      echo "," >> ${JSON_LOCAL_FILE}
    else
      echo "" >> ${JSON_LOCAL_FILE}
    fi
  fi
done < ${CSV_LOCAL_FILE}

echo "  ]" >> ${JSON_LOCAL_FILE}
echo "}" >> ${JSON_LOCAL_FILE}

IFS=${backupIFS}
