#!/bin/bash
################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
################################################################################
## Collect email / phrase 1 / phrase 2 Form
## Generate / Find key & Astronaut PLAYER
## Return TW

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
ME="${0##*/}"

MOATS=$(date -u +"%Y%m%d%H%M%S%4N")
IPFSNODEID=$(cat ~/.ipfs/config | jq -r .Identity.PeerID)

## CHECK FOR ANY ALREADY RUNNING nc
ncrunning=$(ps auxf --sort=+utime | grep -w 'nc -l -p 1234' | grep -v -E 'color=auto|grep' | tail -n 1 | cut -d " " -f 1)
[[ $ncrunning ]] && echo "already running" && exit 1

myIP=$(hostname -I | awk '{print $1}' | head -n 1)

# Check if Astroport Station already has a "captain"
echo "Register and Connect Astronaut with http://$myIP:1234/?email=&ph1=&ph2="

[[ $DISPLAY ]] && xdg-open "file://$HOME/.zen/Astroport.ONE/templates/instascan.html" 2>/dev/null

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

PORT=12345

while true; do

    # REPLACE myIP in http response template
    sed "s~127.0.0.1:12345~$myIP:$PORT~g" $HOME/.zen/Astroport.ONE/templates/index.http > ~/.zen/tmp/myIP.http.${MOATS}
    ## LAUNCHING
    URL=$(cat $HOME/.zen/tmp/myIP.http.${MOATS} | nc -l -p 1234 -q 1 | grep '^GET' | cut -d ' ' -f2  | cut -d '?' -f2)

    echo "=================================================="
    echo "GET RECEPTION : $URL"
    arr=(${URL//[=&]/ })
    echo "PARAM : ${arr[0]} = ${arr[1]} & ${arr[2]} = ${arr[3]} & ${arr[4]} = ${arr[5]} & ${arr[6]} = ${arr[7]}"

    [[ ${arr[0]} == "" && ${arr[1]} == "" ]] && echo "GET NO DATA" && continue
    [[ ${arr[1]} == "ph1" ]] && echo "GET NO DATA" && continue

    ########## CHECK GET PARAM NAMES
###################################################################################################
###################################################################################################
# API ZERO : ?salt=Phrase%20Une&pepper=Phrase%20Deux&elastic=GChangeID
    if [[ ${arr[0]} == "salt" ]]; then
        echo "Application G1Radar !! ?salt=Phrase%20Une&pepper=Phrase%20Deux&elastic=GChangeID"
        SALT=$(urldecode ${arr[1]})
        [[ ! $SALT ]] && echo "BAD SALT API CALL" && continue
        PEPPER=$(urldecode ${arr[3]})
        [[ ! $PEPPER ]] && echo "BAD PEPPER API CALL" && continue
        PLAYER=$(urldecode ${arr[7]})

        ## CALCULATING IPNS ADDRESS
        ipfs key rm gchange 2>/dev/null
        rm -f ~/.zen/tmp/gchange.key
        ${MY_PATH}/tools/keygen -t ipfs -o ~/.zen/tmp/gchange.key "$SALT" "$PEPPER"
        GNS=$(ipfs key import gchange -f pem-pkcs8-cleartext ~/.zen/tmp/gchange.key )

        echo "$GNS"
        echo "$GNS" | nc -l -p ${PORT} -q 1 &

        ## CHECK IF ALREADY EXISTING PLAYER
        # IF NOT = BATCH CREATE TW

        continue

    fi

###################################################################################################
###################################################################################################
# API ONE : ?email/elastic=ELASTICID&salt=PHRASE%20UNE&pepper=PHRASE%20DEUX&pseudo=PROFILENAME
    if [[ ${arr[0]} == "email" || ${arr[0]} == "elastic" ]]; then
    start=`date +%s`

#######################################
### WAITING 12345 WITH SELF REDIRECT
rm -f ~/.zen/tmp/index.redirect.${MOATS}
###################################################################################################
while [[ ! -f ~/.zen/tmp/index.redirect.${MOATS} && ! $(ps auxf --sort=+utime | grep -w 'nc -l -p '${PORT} | grep -v -E 'color=auto|grep') ]]; do cat $HOME/.zen/tmp/myIP.http.${MOATS} | nc -l -p ${PORT} -q 1; done &
###################################################################################################
        PLAYER=$(urldecode ${arr[1]})
        SALT=$(urldecode ${arr[3]})
        PEPPER=$(urldecode ${arr[5]})
        PSEUDO=$(urldecode ${arr[7]})

                if [[ ! $PSEUDO ]]; then
                    PSEUDO=$(echo $PLAYER | cut -d '@' -f 1)
                    PSEUDO=${PSEUDO,,}; PSEUDO=${PSEUDO%%[0-9]*}
                fi
                # PASS CRYPTING KEY
                PASS=$(echo "${RANDOM}${RANDOM}${RANDOM}${RANDOM}" | tail -c-7)

            echo "$SALT"
            echo "$PEPPER"

                if [[ ! -d ~/.zen/game/players/$PLAYER ]]; then
                    $MY_PATH/tools/VISA.new.sh "$SALT" "$PEPPER" "$PLAYER" "$PSEUDO"
               else
                    CHECK=$(cat ~/.zen/game/players/$PLAYER/secret.june | grep -w "$SALT")
                    [[ $CHECK ]] && CHECK=$(cat ~/.zen/game/players/$PLAYER/secret.june | grep -w "$PEPPER")
                    [[ ! $CHECK ]] && echo "ERROR - CREDENTIALS NOT CORRESPONDING WITH PLAYER" && continue
                    echo "TODO VERIFY PLAYER CREDS... LOW SECURITY MODE !!! "
                    mkdir -p ~/.zen/tmp/TW/
                    cp ~/.zen/game/players/$PLAYER/ipfs/moa/index.html ~/.zen/tmp/TW/index.html
               fi

               ###################################################################################################
                # EXTRACTION MOA
                rm -f ~/.zen/tmp/tiddlers.json
                tiddlywiki --load ~/.zen/tmp/TW/index.html --output ~/.zen/tmp --render '.' 'tiddlers.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' '[tag[moa]]'
                TITLE=$(cat ~/.zen/tmp/tiddlers.json | jq -r '.[].title') # Dessin de PLAYER
                PLAYER=$(echo $TITLE | rev | cut -f 1 -d ' ' | rev)
                [[ ! $PLAYER ]] && echo "ERROR WRONG TW" && continue

                echo "Bienvenue Astronaute $PLAYER. Nous avons capté votre TW"
                echo "Redirection"
                [[ $YOU ]] && TWLINK="http://$myIP:8080/ipns/$GNS" \
                                    || TWLINK="$LIBRA/ipns/$GNS"
                echo "$TWLINK"

                # Injection TWLINK dans template de redirection.
                sed "s~_TWLINK_~$TWLINK~g" ~/.zen/Astroport.ONE/templates/index.redirect.${MOATS}  > ~/.zen/tmp/index.redirect.${MOATS}

                ## Attente cloture WAITING $PORT. Puis Lancement one shot http server
                while [[ $(ps auxf --sort=+utime | grep -w 'nc -l -p '${PORT} | grep -v -E 'color=auto|grep') ]]; do sleep 0.5; done
                cat ~/.zen/tmp/index.redirect.${MOATS} | nc -l -p ${PORT} -q 1 &

                ###################################################################################################
                end=`date +%s`
                echo Execution time was `expr $end - $start` seconds.

    fi

###################################################################################################
###################################################################################################
# API TWO : ?qrcode=G1PUB
    if [[ ${arr[0]} == "qrcode" ]]; then
        ## Astroport.ONE local use QRCODE Contains PLAYER G1PUB
        QRCODE=$(echo $URL | cut -d ' ' -f2 | cut -d '=' -f 2 | cut -d '&' -f 1)   && echo "Instascan.html QR : $QRCODE"
        g1pubpath=$(grep $QRCODE ~/.zen/game/players/*/.g1pub | cut -d ':' -f 1 2>/dev/null)
        PLAYER=$(echo "$g1pubpath" | rev | cut -d '/' -f 2 | rev 2>/dev/null)

        ## FORCE LOCAL USE ONLY. Remove to open 1234 API
        [[ ! -d ~/.zen/game/players/$PLAYER || $PLAYER == "" ]] && echo "AUCUN PLAYER !!" && continue

        ## UNE SECOND HTTP SERVER TO RECEIVE PASS

        [[ ${arr[2]} == "" ]] && continue


    fi

###################################################################################################
###################################################################################################
# API THREE : ?qrcode=G1PUB&url=HTTPLINK
    ## Demande de copie d'une URL reçue.
    if [[ ${arr[0]} == "qrcode" &&  ${arr[2]} == "url" ]]; then
        wsource="${arr[3]}"
         [[ ${arr[4]} == "type" ]] && wtype="${arr[5]}" || wtype="Youtube"

        ## LANCEMENT COPIE
        ~/.zen/Astropor.ONE/ajouter_video.sh "$(urldecode $wsource)" "$wtype" "$QRCODE" &

        echo "$QRCODE $wsource"

    fi

    ## ENVOYER MESSAGE GCHANGE POUR QRCODE

    ## Une seule boucle !!!
    [[ "$1" == "ONE" ]] && exit 0

    ## CHANGE NEXT PORT (HERE YOU CREATE A SOCKET QUEUE)
    [ $PORT -lt 12399 ] && PORT=$((PORT+1)) || PORT=12345

done
exit 0
