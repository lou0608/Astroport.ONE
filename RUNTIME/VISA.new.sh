#!/bin/bash
################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"${MY_PATH}\" && pwd )`"  # absolutized and normalized
. "${MY_PATH}/../tools/my.sh"

! ipfs swarm peers >/dev/null 2>&1 && echo "Lancez 'ipfs daemon' SVP" && exit 1
################################################################################
[[ ! ${MOATS} ]] && MOATS=$(date -u +"%Y%m%d%H%M%S%4N")

mkdir -p ~/.zen/tmp/${MOATS}

SALT="$1"
PEPPER="$2"
PLAYER="$3"
PSEUDO="$4"
[[ $PSEUDO == "" ]] && PSEUDO="Anonymous"

LANG="$5"
[[ $LANG == "" ]] && LANG="_LANG_"

## UPLANET UMAP
LAT="$6"
[[ $LAT == "" ]] && LAT="0.00"
LON="$7"
[[ $LON == "" ]] && LON="0.00"

################################################################################
YOU=$(myIpfsApi);
################################################################################
## LIST TW MODELS
################################################################################
#~ TWMODEL="/ipfs/bafybeid7xwuqkgyiffehs77x3wky3dghjncxepr5ln6dewapgvbwrqi7n4"
#~ # ipfs cat $TWMODEL > templates/twdefault.html
TWUPLANET="/ipfs/bafybeigpwapdih24vnakummoyj6vodxiem4i6ezp5hxa35yt3paxpqz53y" ## WITH LIGHTBEAMS SAVER
TWUPLANET="/ipfs/bafybeicku4z2diasnkc4tch45bcbuvkfqhsic7747uuecwoullts5ehwk4" ## WITH IPFS SAVER
# ipfs cat $TWUPLANET > templates/twuplanet.html
################################################################################

mkdir -p ~/.zen/tmp/${MOATS}/TW

## TEST chargement ONLINE TW !!!
if [[ $SALT != "" && PEPPER != "" ]]; then

    ## Creating SALT/PEPPER IPNS KEY
    ${MY_PATH}/../tools/keygen -t ipfs -o ~/.zen/tmp/${MOATS}/player.key "$SALT" "$PEPPER" 2>/dev/null
    ASTRONAUTENS=$(ipfs key import ${MOATS} -f pem-pkcs8-cleartext ~/.zen/tmp/${MOATS}/player.key 2>/dev/null)
    # echo "/ipns/${ASTRONAUTENS}"

    echo "SCANNING /ipns/${ASTRONAUTENS} for 180s"
    ## GETTING LAST TW via IPFS or HTTP GW
    ipfs --timeout 180s cat  /ipns/${ASTRONAUTENS} > ~/.zen/tmp/${MOATS}/TW/index.html

    if [[ -s ~/.zen/tmp/${MOATS}/TW/index.html ]]; then
        echo "TW FOUND... BACKUP TIDDLERS"
        # BACKUP tiddlers
        tiddlywiki --load ~/.zen/tmp/${MOATS}/TW/index.html --output ~/.zen/tmp/${MOATS} \
        --render '.' 'backup.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' '[!is[system]]'

        [[ -s ~/.zen/tmp/${MOATS}/backup.json ]] \
            && echo ">> Tiddlers Backup : ~/.zen/tmp/${MOATS}/backup.json" \
            || echo "ERROR EXTRACTING TIDDLERS"

        rm ~/.zen/tmp/${MOATS}/TW/index.html
    fi

    #############################################
    ## CREATE NEW TW FROM TEMPLATE
    cp ${MY_PATH}/../templates/twuplanet.html ~/.zen/tmp/${MOATS}/TW/index.html

    #### REFILL WITH BACKUP
    if [[ -s ~/.zen/tmp/${MOATS}/backup.json ]]; then

        tiddlywiki  --load ~/.zen/tmp/${MOATS}/TW/index.html \
                --import ~/.zen/tmp/${MOATS}/backup.json "application/json" \
                --output ~/.zen/tmp/${MOATS} --render "$:/core/save/all" "tw.html" "text/plain"

        [[ -s ~/.zen/tmp/${MOATS}/tw.html ]] \
            && cp -f ~/.zen/tmp/${MOATS}/tw.html ~/.zen/tmp/${MOATS}/TW/index.html

        echo "BACKUP RESTORED"
    fi
    #############################################
    # EXISTING TW : DATA TESTING & CACHE
    rm -f ~/.zen/tmp/${MOATS}/Astroport.json
    tiddlywiki --load ~/.zen/tmp/${MOATS}/TW/index.html --output ~/.zen/tmp/${MOATS} --render '.' 'Astroport.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' 'Astroport'
    ASTROPORT=$(cat ~/.zen/tmp/${MOATS}/Astroport.json | jq -r .[].astroport)
    HPass=$(cat ~/.zen/tmp/${MOATS}/Astroport.json | jq -r .[].HPASS)
    echo "ASTROPORT=${ASTROPORT}"
    tiddlywiki --load ~/.zen/tmp/${MOATS}/TW/index.html --output ~/.zen/tmp/${MOATS} --render '.' 'AstroID.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' 'AstroID'
    AstroID=$(cat ~/.zen/tmp/${MOATS}/AstroID.json | jq -r .[]._canonical_uri) ## Can be deleted
    [[ -z $HPass ]] && HPass=$(cat ~/.zen/tmp/${MOATS}/AstroID.json | jq -r .[].HPASS) ## Double HPASS
    echo "AstroID=$AstroID ($HPass)"
    tiddlywiki --load ~/.zen/tmp/${MOATS}/TW/index.html --output ~/.zen/tmp/${MOATS} --render '.' 'ZenCard.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' 'ZenCard'
    ZenCard=$(cat ~/.zen/tmp/${MOATS}/ZenCard.json | jq -r .[]._canonical_uri)
    echo "ZenCard=$ZenCard"

    if [[ ${ASTROPORT} != "" && ${ASTROPORT} != "null" ]]; then

        IPNSTAIL=$(echo ${ASTROPORT} | rev | cut -f 1 -d '/' | rev) # Remove "/ipns/" part
        echo "TW ASTROPORT GATEWAY : ${ASTROPORT}"
        echo "---> CONNECTING PLAYER $(cat ~/.zen/tmp/${MOATS}/Astroport.json | jq -r .[].pseudo) TW NOW with $IPFSNODEID"

    else

        echo ">> NO ACTIVE TW - CREATING FRESH NEW ONE"
        cp ${MY_PATH}/../templates/twuplanet.html ~/.zen/tmp/${MOATS}/TW/index.html

    fi



    ipfs key rm ${MOATS} 2>/dev/null ## CLEANING MOATS KEY

fi


##################################################### # NEW PLAYER ###############
################################################################################
#~ echo "=============================================
#~ ASTROPORT DIPLOMATIC PASSPORT - MadeInZion VISA -
#~ =============================================
#~ A Cryptographic Key to control your INTERNET
#~ Adventure & Exploration P2P Terraforming Game.
#~ =============================================
#~ WELCOME 'Astronaute'"; # sleep 1

#~ echo "Inscription..."

[[ $SALT == "" ]] && SALT=$(${MY_PATH}/../tools/diceware.sh 4 | xargs)
#~ echo "-> ID : $SALT"

[[ $PEPPER == "" ]] && PEPPER=$(${MY_PATH}/../tools/diceware.sh 4 | xargs)
#~ echo "-> PASS : $PEPPER"

[[ ! $PSEUDO ]] && PSEUDO=${PLAYER%%[0-9]*}
[[ ! $PSEUDO ]] && PSEUDO="Anonymous"
[[ $(ls ~/.zen/game/players/$PSEUDO 2>/dev/null) ]] && echo "$PSEUDO EST DEJA UN PLAYER. EXIT" && exit 1

# PSEUDO=${PSEUDO,,} #lowercase
[[ ! ${PLAYER} ]] \
    && PLAYER=${PSEUDO}${RANDOM:0:3}@$(${MY_PATH}/../tools/diceware.sh 1 | xargs).${RANDOM:0:3} \
    && echo "ADRESSE EMAIL ?" && read OPLAYER && [[ $OPLAYER ]] && PLAYER=$OPLAYER ## CLI MODE

PLAYER=${PLAYER,,}

# 4 DIGIT PASS CODE TO PROTECT QRSEC
PASS=$(echo "${RANDOM}${RANDOM}${RANDOM}${RANDOM}" | tail -c-5)

############################################################
${MY_PATH}/../tools/keygen -t duniter -o ~/.zen/tmp/${MOATS}/secret.dunikey "$SALT" "$PEPPER"

G1PUB=$(cat ~/.zen/tmp/${MOATS}/secret.dunikey | grep 'pub:' | cut -d ' ' -f 2)

[[ ! $G1PUB ]] && echo "Désolé. clef Cesium absente. ERROR" && exit 1

## CREATE Player personnal files storage and IPFS publish directory
mkdir -p ~/.zen/game/players/${PLAYER}/.ipfs # Prepare PLAYER datastructure
echo "/ip4/127.0.0.1/tcp/5001" > ~/.zen/game/players/${PLAYER}/.ipfs/api

## secret.june = SALT PEPPER CREDENTIALS
echo "SALT=\"$SALT\"" > ~/.zen/game/players/${PLAYER}/secret.june
echo "PEPPER=\"$PEPPER\"" >> ~/.zen/game/players/${PLAYER}/secret.june
####
## MOVE ${MOATS} secret.dunikey IN PLAYER DIRECTORY
mv ~/.zen/tmp/${MOATS}/secret.dunikey ~/.zen/game/players/${PLAYER}/

NID="${myIPFS}"
WID="${myAPI}" ## https://ipfs.libra.copylaradio.com

[[ $isLAN ]] && NID="http://ipfs.localhost:8080" \
             && WID="http://ipfs.localhost:5001"

# Create ${PLAYER} "IPNS Key"
ipfs key rm ${PLAYER} >/dev/null 2>&1
ipfs key rm ${G1PUB} >/dev/null 2>&1
${MY_PATH}/../tools/keygen -t ipfs -o ~/.zen/game/players/${PLAYER}/secret.player "$SALT" "$PEPPER"
TWNS=$(ipfs key import ${PLAYER} -f pem-pkcs8-cleartext ~/.zen/game/players/${PLAYER}/secret.player)
ASTRONAUTENS=$(ipfs key import ${G1PUB} -f pem-pkcs8-cleartext ~/.zen/game/players/${PLAYER}/secret.player)

## TODO MAKE CLEANER
mkdir -p ~/.zen/game/players/${PLAYER}/ipfs/G1SSB # Prepare astrXbian sub-datastructure "old scarf code"
qrencode -s 12 -o ~/.zen/game/players/${PLAYER}/QR.png "$G1PUB"  ## Check by VISA.print.sh
cp ~/.zen/game/players/${PLAYER}/QR.png ~/.zen/game/players/${PLAYER}/ipfs/QR.png
echo "$G1PUB" > ~/.zen/game/players/${PLAYER}/ipfs/G1SSB/_g1.pubkey # G1SSB NOTATION (astrXbian compatible)
qrencode -s 12 -o ~/.zen/game/players/${PLAYER}/QR.ASTRONAUTENS.png "$myLIBRA/ipns/${ASTRONAUTENS}"

############################################################################
## SEC PASS PROTECTED QRCODE : base58 secret.june / openssl(pass)
#~ secFromDunikey=$(cat ~/.zen/game/players/${PLAYER}/secret.dunikey | grep "sec" | cut -d ' ' -f2)
#~ echo "$secFromDunikey" > ~/.zen/tmp/${MOATS}/${PSEUDO}.sec

USALT=$(echo "$SALT" | jq -Rr @uri)
UPEPPER=$(echo "$PEPPER" | jq -Rr @uri)
DISCO="/?salt=${USALT}&pepper=${UPEPPER}"

## PGP ENCODING SALT/PEPPER API ACCESS
echo "${DISCO}" > ~/.zen/tmp/${MOATS}/topgp
cat ~/.zen/tmp/${MOATS}/topgp | gpg --symmetric --armor --batch --passphrase "$PASS" -o ~/.zen/tmp/${MOATS}/gpg.${PSEUDO}.asc
rm ~/.zen/tmp/${MOATS}/topgp
#~ openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -in ~/.zen/game/players/${PLAYER}/secret.june -out "$HOME/.zen/tmp/${MOATS}/enc.${PSEUDO}.sec" -k "$PASS"
#~ PASsec=$(cat ~/.zen/tmp/${MOATS}/enc.${PSEUDO}.sec  | base64 -w 0 | jq -sRr '@uri' )
#~ HPass=$(echo "$PASS" | sha512sum | cut -d ' ' -f 1)
#~ qrencode -s 12 -o $HOME/.zen/game/players/${PLAYER}/QRsec.png $PASsec

## Add logo to QRCode
cp ${MY_PATH}/../images/astrologo_nb.png ~/.zen/tmp/${MOATS}/fond.png

## ASTROID ~~~~~
ASTROIDQR="$(cat ~/.zen/tmp/${MOATS}/gpg.${PSEUDO}.asc  | tr '-' '~' | tr '\n' '-'  | tr '+' '_' | jq -Rr @uri )"
## MAKE amzqr ASTROID PGP QRCODE
amzqr "${ASTROIDQR}" \
            -d ~/.zen/tmp/${MOATS} \
            -l H \
            -p ~/.zen/tmp/${MOATS}/fond.png 1>/dev/null

## ADD PLAYER EMAIL
convert -gravity northwest -pointsize 28 -fill black -draw "text 5,5 \"$PLAYER\"" ~/.zen/tmp/${MOATS}/fond_qrcode.png ~/.zen/game/players/${PLAYER}/result_qrcode.png
convert ~/.zen/game/players/${PLAYER}/result_qrcode.png -resize 480 ~/.zen/game/players/${PLAYER}/AstroID.png

ASTROQR="/ipfs/$(ipfs add -q $HOME/.zen/game/players/${PLAYER}/AstroID.png | tail -n 1)"

## DO NOT PIN ASTROID QRCODE
ipfs pin rm ${ASTROQR}

############################################################################ TW
### INITALISATION WIKI dans leurs répertoires de publication IPFS
mkdir -p ~/.zen/game/players/${PLAYER}/ipfs/moa/

[[ ! -s ~/.zen/tmp/${MOATS}/TW/index.html ]] \
    && cp ${MY_PATH}/../templates/twuplanet.html ~/.zen/tmp/${MOATS}/TW/index.html

sed "s~_BIRTHDATE_~${MOATS}~g" ~/.zen/tmp/${MOATS}/TW/index.html \
    > ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html

# INSERT ASTROPORT ADDRESS
tiddlywiki --load ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html --output ~/.zen/tmp/${MOATS} --render '.' 'Astroport.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' 'Astroport'
ASTROPORT=$(cat ~/.zen/tmp/${MOATS}/Astroport.json | jq -r .[].astroport)
sed -i "s~${ASTROPORT}~/ipns/${IPFSNODEID}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html

# TW CHAIN INIT WITH TWMODEL
sed -i "s~_MOATS_~${MOATS}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html
sed -i "s~_CHAIN_~${TWUPLANET}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html
sed -i "s~_TWMODEL_~${TWUPLANET}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html
sed -i "s~_ASTRONAUTENS_~/ipns/${ASTRONAUTENS}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html

## AND HACK QRCODE.sh FOR _PGP KEY_ TO VERIFY LAST HASH OF PROVIDED PASS
HPASS=$(echo $PASS | sha512sum | cut -d ' ' -f 1)
[[ ${HPass} != "" && ${HPass} != "null" ]] && SRCPASS=${HPass} || SRCPASS="_HPASS_"
sed -i "s~${SRCPASS}~${HPASS}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html

## RESET WISHES TO DEPLOY DERIVATED KEYS ON HOST AGAIN ( DONE IN PLAYER_REFRESH )
#~ sed -i "s~G1Voeu~voeu~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html

# INSERT PLAYER DATA
sed -i "s~_PLAYER_~${PLAYER}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html
sed -i "s~_PSEUDO_~${PSEUDO}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html
sed -i "s~_G1PUB_~${G1PUB}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html
#~ sed -i "s~_QRSEC_~${PASsec}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html

# La Clef IPNS porte comme nom G1PUB et ${PLAYER}
sed -i "s~_MEDIAKEY_~${PLAYER}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html
sed -i "s~k2k4r8kxfnknsdf7tpyc46ks2jb3s9uvd3lqtcv9xlq9rsoem7jajd75~${ASTRONAUTENS}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html


## AstroID Tiddler UPGRADE
cat ${MY_PATH}/../templates/data/AstroID.json \
    | sed -e "s~/ipfs/bafybeifbebc3ewnzrzbm44arddedbralegnxklhua5d5ymzaqtf2kaub7i~${ASTROQR}~g" \
            -e "s~_PLAYER_~${PLAYER}~g" \
            -e "s~_MOATS_~${MOATS}~g" \
            -e "s~_G1PUB_~${G1PUB}~g" \
            -e "s~_ASTRONAUTENS_~${ASTRONAUTENS}~g" \
            -e "s~_HPASS_~${HPASS}~g" \
        > ~/.zen/tmp/${MOATS}/AstroID.json

sed -i "s~tube.copylaradio.com~$myTUBE~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html
sed -i "s~ipfs.copylaradio.com~$myTUBE~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html

## PREPARE UMAP LAT LON replacement
[[ ! ${LAT} ]] && LAT="0.00"
[[ ! ${LON} ]] && LON="0.00"

SECTOR="_${LAT::-1}_${LON::-1}" ### SECTOR = 0.1° Planet Slice in MadeInZion Tiddler
echo "UPlanet 0.1° SECTOR : ${SECTOR}"
sed -i "s~_SECTOR_~${SECTOR}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html

# GET ACTUAL GPS VALUES
tiddlywiki --load ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html \
    --output ~/.zen/tmp/${MOATS} \
    --render '.' 'GPS.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' 'GPS'

OLAT=$(cat ~/.zen/tmp/${MOATS}/GPS.json | jq -r .[].lat)
OLON=$(cat ~/.zen/tmp/${MOATS}/GPS.json | jq -r .[].lon)

# REPLACE WITH NEW LAT LON UMAP
sed -i "s~${OLAT}~${LAT}~g" ~/.zen/tmp/${MOATS}/GPS.json
sed -i "s~${OLON}~${LON}~g" ~/.zen/tmp/${MOATS}/GPS.json
## Add _SECTORTW_
cat ~/.zen/tmp/${MOATS}/GPS.json | jq '.[0] + {"sectortw": "_SECTORTW_"}' \
    > ~/.zen/tmp/${MOATS}/GPStw.json \
    && mv ~/.zen/tmp/${MOATS}/GPStw.json ~/.zen/tmp/${MOATS}/GPS.json

###########
## GET OLD16 FROM MadeInZion
tiddlywiki \
    --load ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html \
    --output ~/.zen/tmp/${MOATS} \
    --render '.' 'MIZ.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' 'MadeInZion'
OLD16=$(cat ~/.zen/tmp/${MOATS}/MIZ.json | jq -r ".[].secret")
[[ ${OLD16} == "" || ${OLD16} == "null" ]] && OLD16="_SECRET_"
echo "${OLD16}"

# TODO : MAKE NODE FORGET PASS THEN DECODE ${PLAYER}/secret.june FROM TW # PROD #
MACHINEPUB=$(cat $HOME/.zen/game/myswarm_secret.dunikey | grep pub | cut -d ' ' -f 2)

if [[ "${MACHINEPUB}" != "" ]]; then
    #~ echo "# CRYPTO ENCODING PLAYER KEY WITH MACHINEPUB
    ${MY_PATH}/../tools/natools.py encrypt \
        -p ${MACHINEPUB} \
        -i $HOME/.zen/game/players/${PLAYER}/secret.june \
        -o $HOME/.zen/tmp/${MOATS}/secret.june.${G1PUB}.enc
    ENCODING=$(cat ~/.zen/tmp/${MOATS}/secret.june.$G1PUB.enc | base16)
    sed -i "s~${OLD16}~${ENCODING}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html
    echo "ENCODING: ${ENCODING}"

    # GIVE ZEN STATION TW ACCESS #
###########
    #~ echo "# CRYPTO DECODING TESTING..."
    tiddlywiki \
        --load ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html \
        --output ~/.zen/tmp/${MOATS} \
        --render '.' 'MadeInZion.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' 'MadeInZion'

    cat ~/.zen/tmp/${MOATS}/MadeInZion.json \
        | jq -r ".[].secret" | base16 -d \
        > ~/.zen/tmp/${MOATS}/crypto.$G1PUB.enc.2

    ${MY_PATH}/../tools/natools.py decrypt \
        -f pubsec \
        -k $HOME/.zen/game/myswarm_secret.dunikey \
        -i $HOME/.zen/tmp/${MOATS}/crypto.$G1PUB.enc.2 \
        -o $HOME/.zen/tmp/${MOATS}/crypto.2
    #~ echo "DEBUG : $(cat $HOME/.zen/tmp/${MOATS}/crypto.2)"
###########
    ## CRYPTO PROCESS VALIDATED
    [[ -s ~/.zen/tmp/${MOATS}/crypto.2 ]] \
        && echo "NATOOLS LOADED STATION TW KEY " \
        || echo "NATOOLS ERRORS - CHECK STATION" # MACHINEPUB CRYPTO ERROR

else
    echo " - WARNING - MISSING ~/.zen/game/myswarm_secret.dunikey - WARNING -"
fi
########### SECTOR = 0.1° UPLANET SLICE
OSECTOR=$(cat ~/.zen/tmp/${MOATS}/MadeInZion.json | jq -r .[].sector)
[[ ${OSECTOR} != "null" ]] && sed -i "s~${OSECTOR}~${SECTOR}~g" ~/.zen/tmp/${MOATS}/MadeInZion.json

### CREATE ${NID} ADDRESS FOR API & ROUND ROBIN FOR GW
cat ${MY_PATH}/../templates/data/local.api.json | sed "s~_NID_~${WID}~g" > ~/.zen/tmp/${MOATS}/local.api.json
cat ${MY_PATH}/../templates/data/local.gw.json | sed "s~_NID_~${NID}~g" > ~/.zen/tmp/${MOATS}/local.gw.json

# Create"${PLAYER}_feed" Key ! DERIVATED !  "$SALT" "$PEPPER $G1PUB"
ipfs key rm "${PLAYER}_feed" 2>/dev/null
${MY_PATH}/../tools/keygen -t ipfs -o ~/.zen/tmp/${MOATS}/feed.ipfskey "$SALT" "$PEPPER $G1PUB"
FEEDNS=$(ipfs key import "${PLAYER}_feed" -f pem-pkcs8-cleartext ~/.zen/tmp/${MOATS}/feed.ipfskey)

## MAKE LightBeam Plugin Tiddler ${PLAYER}_feed
# $:/plugins/astroport/lightbeams/saver/ipns/lightbeam-key
echo '[{"title":"$:/plugins/astroport/lightbeams/saver/ipns/lightbeam-name","text":"'${PLAYER}_feed'","tags":""}]' > ~/.zen/tmp/${MOATS}/lightbeam-name.json
echo '[{"title":"$:/plugins/astroport/lightbeams/saver/ipns/lightbeam-key","text":"'${FEEDNS}'","tags":""}]' > ~/.zen/tmp/${MOATS}/lightbeam-key.json

    ## ADD SYSTEM TW
tiddlywiki  --load ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html \
                    --import ~/.zen/tmp/${MOATS}/lightbeam-name.json "application/json" \
                    --import ~/.zen/tmp/${MOATS}/lightbeam-key.json "application/json" \
                    --import ~/.zen/tmp/${MOATS}/local.api.json "application/json" \
                    --import ~/.zen/tmp/${MOATS}/local.gw.json "application/json" \
                    --import ~/.zen/tmp/${MOATS}/GPS.json "application/json" \
                    --import ~/.zen/tmp/${MOATS}/AstroID.json "application/json" \
                    --import ~/.zen/tmp/${MOATS}/MadeInZion.json "application/json" \
--import "${MY_PATH}/../templates/tw/\$ _ipfs_saver_api.json" "application/json" \
--import "${MY_PATH}/../templates/tw/\$ _ipfs_saver_gateway.json" "application/json" \
                    --output ~/.zen/tmp/${MOATS} --render "$:/core/save/all" "tw.html" "text/plain"

    ## COPY TO LOCAL & 12345 IPFSNODEID MAP
    [[ -s ~/.zen/tmp/${MOATS}/tw.html ]] \
    && cp -f ~/.zen/tmp/${MOATS}/tw.html ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html \
    && mkdir -p ~/.zen/tmp/${IPFSNODEID}/TW/${PLAYER} \
    && cp ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html ~/.zen/tmp/${IPFSNODEID}/TW/${PLAYER}/ \
    || ( echo "Problem with TW - EXIT" && exit 1 )

############################################################################ G1TW
#### MAKE G1TW
    [[ -s ~/.zen/G1BILLET/MAKE_G1BILLET.sh ]] && \
    ~/.zen/G1BILLET/MAKE_G1BILLET.sh "$SALT" "$PEPPER" "___" "$G1PUB" "${PASS}" "${PSEUDO-xastro}" "$ASTRONAUTENS" "$PLAYER"
#### MADE # BILLETNAME=$(echo "$SALT" | sed 's/ /_/g') ##
# IMAGE ~/.zen/G1BILLET/tmp/g1billet/${PASS}/${BILLETNAME}.BILLET.jpg
############################################################################

    ## MAKE IMAGE AVATAR WITH G1PUB QRCODE
    if [[ $(which amzqr) ]]; then

        GIMG="${MY_PATH}/../images/moa_net.png"
        CIMG="${MY_PATH}/../images/zenticket.png"

        # QRG1avatar.png
        [[ ! -s ~/.zen/game/players/${PLAYER}/QRG1avatar.png ]] && amzqr "${G1PUB}" -l H -p "$CIMG" -c -n QRG1avatar.png -d ~/.zen/game/players/${PLAYER}/ 1>/dev/null
        # QRTWavatar.png
        [[ ! -s ~/.zen/game/players/${PLAYER}/QRTWavatar.png ]] && amzqr "${myIPFSGW}/ipns/${ASTRONAUTENS}" -l H -p "$GIMG" -c -n QRTWavatar.png -d ~/.zen/game/players/${PLAYER}/ 1>/dev/null

    else

        [[ ! -s ~/.zen/game/players/${PLAYER}/QRG1avatar.png ]] \
        && cp ~/.zen/game/players/${PLAYER}/QR.png ~/.zen/game/players/${PLAYER}/QRG1avatar.png

        [[ ! -s ~/.zen/game/players/${PLAYER}/QRTWavatar.png ]] \
        && cp ~/.zen/game/players/${PLAYER}/QR.ASTRONAUTENS.png ~/.zen/game/players/${PLAYER}/QRTWavatar.png

    fi

    ## ID CARD & QRCODE
    convert ~/.zen/game/players/${PLAYER}/QRG1avatar.png -resize 300 ~/.zen/tmp/${MOATS}/QR.png  2>/dev/null
    convert ~/.zen/game/players/${PLAYER}/QRTWavatar.png -resize 240 ~/.zen/tmp/${MOATS}/TW.png 2>/dev/null
    convert ${MY_PATH}/../images/astroport.jpg  -resize 240 ~/.zen/tmp/${MOATS}/ASTROPORT.png 2>/dev/null


    composite -compose Over -gravity SouthEast -geometry +5+5 ~/.zen/tmp/${MOATS}/ASTROPORT.png ${MY_PATH}/../images/Brother_600x400.png ~/.zen/tmp/${MOATS}/astroport.png 2>/dev/null
    composite -compose Over -gravity NorthEast -geometry +10+55 ~/.zen/tmp/${MOATS}/TW.png ~/.zen/tmp/${MOATS}/astroport.png ~/.zen/tmp/${MOATS}/astroport2.png 2>/dev/null
    composite -compose Over -gravity NorthWest -geometry +0+0 ~/.zen/tmp/${MOATS}/QR.png ~/.zen/tmp/${MOATS}/astroport2.png ~/.zen/tmp/${MOATS}/one.png 2>/dev/null
    convert -gravity SouthWest -pointsize 12 -fill black -draw "text 5,3 \"$G1PUB\"" ~/.zen/tmp/${MOATS}/one.png ~/.zen/tmp/${MOATS}/txt.png

    # composite -compose Over -gravity NorthWest -geometry +280+280 ~/.zen/game/players/.current/QRsec.png ~/.zen/tmp/${MOATS}/one.png ~/.zen/tmp/${MOATS}/image.png

    convert -gravity northwest -pointsize 25 -fill black -draw "text 50,300 \"$PSEUDO\"" ~/.zen/tmp/${MOATS}/txt.png ~/.zen/tmp/${MOATS}/image.png
    convert -gravity northwest -pointsize 20 -fill black -draw "text 300,40 \"${PLAYER}\"" ~/.zen/tmp/${MOATS}/image.png ~/.zen/tmp/${MOATS}/pseudo.png


    ## WITH CONFIDENTIAL (LOCAL PRINT)
    convert -gravity northeast -pointsize 25 -fill black -draw "text 20,180 \"$PASS\"" ~/.zen/tmp/${MOATS}/pseudo.png ~/.zen/tmp/${MOATS}/pass.png
    convert -gravity northwest -pointsize 25 -fill black -draw "text 300,100 \"$SALT\"" ~/.zen/tmp/${MOATS}/pass.png ~/.zen/tmp/${MOATS}/salt.png
    convert -gravity northwest -pointsize 25 -fill black -draw "text 300,140 \"$PEPPER\"" ~/.zen/tmp/${MOATS}/salt.png ~/.zen/game/players/${PLAYER}/ID.png

    # INSERTED IMAGE IPFS
    # IASTRO=$(ipfs add -Hq ~/.zen/game/players/${PLAYER}/ID.png | tail -n 1) ## ZENCARD PUBLIC / PRIVATE
    IASTRO="/ipfs/$(ipfs add -Hq ~/.zen/tmp/${MOATS}/pseudo.png | tail -n 1)" ## ZENCARD PUBLIC ONLY

    ## Update ZenCard
    [[ ! $ZenCard ]] && ZenCard="/ipfs/bafybeidhghlcx3zdzdah2pzddhoicywmydintj4mosgtygr6f2dlfwmg7a"
    sed -i "s~${ZenCard}~${IASTRO}~g" ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html

echo
echo "♥ IPFS Ŋ1 TW INIT ♥"
echo "TW ${NID}/ipns/${ASTRONAUTENS}/"
IPUSH=$(ipfs add -Hq ~/.zen/game/players/${PLAYER}/ipfs/moa/index.html | tail -n 1)
echo $IPUSH > ~/.zen/game/players/${PLAYER}/ipfs/moa/.chain # Contains last IPFS backup PLAYER KEY
echo $MOATS > ~/.zen/game/players/${PLAYER}/ipfs/moa/.moats

(
    #~ echo "$MOATS :: /ipfs/$IPUSH"
    ipfs name publish --key=${PLAYER} /ipfs/$IPUSH
    #~ echo "TW PUBLISHING DONE"
) &

## MEMORISE PLAYER Ŋ1 ZONE
echo "${PLAYER}" > ~/.zen/game/players/${PLAYER}/.player
echo "$PSEUDO" > ~/.zen/game/players/${PLAYER}/.pseudo
echo "$G1PUB" > ~/.zen/game/players/${PLAYER}/.g1pub

echo "${ASTRONAUTENS}" > ~/.zen/game/players/${PLAYER}/.playerns

#~ echo; echo "Création Clefs et QR codes pour accès au niveau Astroport Ŋ1"; sleep 1

echo "--- PLAYER : ${PLAYER} - DATA PROTOCOL LAYER LOADED";
# ls ~/.zen/game/players/${PLAYER}

[[ $XDG_SESSION_TYPE == 'x11' || $XDG_SESSION_TYPE == 'wayland' ]] && xdg-open "${myIPFS}/ipns/${ASTRONAUTENS}" && espeak "YOUR PASS IS $PASS"

####### NO CURRENT ? PLAYER = .current
[[ ! -e ~/.zen/game/players/.current ]] \
    && rm ~/.zen/game/players/.current 2>/dev/null \
    && ln -s ~/.zen/game/players/${PLAYER} ~/.zen/game/players/.current

. "${MY_PATH}/../tools/my.sh"

#################################################################
#### make player ipfs docker ## TODO
# [[ $USER == 'zen' ]] && make player MAIL=$(myPlayer) USER_HOST=$(myPlayerHost) > /dev/null 2>&1
## 1ST RELEASE BASED ON DIRECT NODE IPFSNODEID KEY "ADD / DEL" API
#################################################################

#################################################
# !! TODO !! # DEMO MODE. REMOVE FOR PRODUCTION - RECALCULATE AND RENEW AFTER EACH NEW KEY DELEGATION
echo "$PASS" > ~/.zen/game/players/${PLAYER}/.pass
# ~/.zen/game/players/${PLAYER}/secret.june SECURITY TODO
# Astronaut QRCode + PASS = LOGIN (=> DECRYPTING CRYPTO IPFS INDEX)
# TODO : Allow Astronaut PASS change ;)
#####################################################

## MANAGE GCHANGE+ & Ŋ1 EXPLORATION
${MY_PATH}/../tools/Connect_PLAYER_To_Gchange.sh "${PLAYER}"

### IF PRINTER -> PRINT VISA
LP=$(ls /dev/usb/lp* 2>/dev/null)
[[ $LP ]] && ${MY_PATH}/../tools/VISA.print.sh "${PLAYER}" &

## INIT FRIENDSHIP CAPTAIN/ASTRONAUTS (LATER THROUGH GCHANGE)
## ${MY_PATH}/FRIENDS.init.sh
## NO. GCHANGE+ IS THE MAIN INTERFACE, astrXbian manage
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "$(${MY_PATH}/../tools/face.sh cool)"
echo " 'Astronaut'  $PSEUDO"
echo
echo "* ZenCard : Public Key and Wallet
${NID}/ipns/${ASTRONAUTENS}#ZenCard"
echo "   "
echo "* AstroID : with PASS : $PASS"
echo "${NID}/ipns/${ASTRONAUTENS}#AstroID"
echo
echo "* UMap : registration at ${LAT}, ${LON}"
echo
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo ""

####tools##########################################getUMAP_ENV.sh
$(${MY_PATH}/../tools/getUMAP_ENV.sh "${LAT}" "${LON}" | tail -n 1)
####################################################### EMAIL
[[ -s ${MY_PATH}/../templates/UPlanetZine/index.${LANG}.html ]] \
    && ZINE="${MY_PATH}/../templates/UPlanetZine/index.${LANG}.html" \
    || ZINE="${MY_PATH}/../templates/UPlanetZine/index.html"
##UPlanetZine::/ipfs/QmUjgQYK74UgRoyLFfmR2LMX7rd6vNxmtWeUtRxjemELuZ - chained release -
cat ${ZINE} \
    | sed -e "s~/ipfs/QmdmeZhD8ncBFptmD5VSJoszmu41edtT265Xq3HVh8PhZP~${ASTROQR}~g" \
            -e "s~/ipfs/QmTL7VDgkYjpYC2qiiFCfah2pSqDMkTANMeMtjMndwXq9y~${IASTRO}~g" \
            -e "s~_MOATS_~${MOATS}~g" \
            -e "s~_G1PUB_~${G1PUB}~g" \
            -e "s~_ASTRONAUTENS_~${ASTRONAUTENS}~g" \
            -e "s~0448~${PASS}~g" \
            -e "s~_IPFSNODEID_~${IPFSNODEID}~g" \
            -e "s~_EARTHCID_~${EARTHCID}~g" \
            -e "s~_SECTOR_~${SECTOR}~g" \
            -e "s~_SLAT_~${SLAT}~g" \
            -e "s~_SLON_~${SLON}~g" \
        > ~/.zen/tmp/${MOATS}/UPlanetZine.html


$MY_PATH/../tools/mailjet.sh "${PLAYER}"  ~/.zen/tmp/${MOATS}/UPlanetZine.fr.html "UPlanet Zine"

#####################################################################"_EARTHCID_

#~ echo "<html><head>
#~ <style>
    #~ body {
        #~ font-family: 'Courier New', monospace;
    #~ }
    #~ pre {
        #~ white-space: pre-wrap;
    #~ }
#~ </style></head>
#~ <body>
#~ <center>
#~ <h3><a href='${myUPLANET}'>UPlanet</a></h3>
#~ <h1>\"<a target='TW' href='$(myIpfsGw)/ipns/${ASTRONAUTENS}'>TW5</a>\"</h1>
#~ did:/ipns/${ASTRONAUTENS}
#~ <hr>
#~ <hr><a target='TW' href='$(myIpfsGw)/ipns/${ASTRONAUTENS}#AstroID'>AstroID<br>
#~ <img width=300px src='$(myIpfsGw)${ASTROQR}'\></a><br>
#~ <h2>SECRET1=\"$SALT\"<br>SECRET2=\"$PEPPER\"</h2>
#~ <h2> CODE : $PASS </h2>
#~ <hr>
#~ <a target='TW' href='$(myIpfsGw)/ipns/${ASTRONAUTENS}#ZenCard' title='${G1PUB}'>ZenCard</a><br>
#~ <img src='$(myIpfsGw)${IASTRO}'\><br><hr>
#~ ${G1PUB}" > ~/.zen/tmp/${MOATS}/AstroID.html

#~ echo "
#~ <h3> /-> ASTROPORT : <a href='$(myIpfsGw)/ipns/${IPFSNODEID}'>/ipns/${IPFSNODEID}</a></h3>
#~ <h3> /--> SECTOR : <a href='${EARTHCID}/map_render.html?southWestLat=${LAT::-1}&southWestLon=${LON::-1}&deg=0.1'>${SECTOR}</a></h3>
#~ " >> ~/.zen/tmp/${MOATS}/AstroID.html

#~ asciiart="${MY_PATH}/../images/logoastro.art"
#~ while IFS= read -r line
#~ do
    #~ echo "$line" | sed "s~ ~\&nbsp;~g" >> ~/.zen/tmp/${MOATS}/AstroID.html
    #~ echo "<br>" >> ~/.zen/tmp/${MOATS}/AstroID.html
#~ done <"$asciiart"

#~ echo "<br>${MOATS}<br>- print a copy -</center></body></html>" >> ~/.zen/tmp/${MOATS}/AstroID.html

#~ $MY_PATH/../tools/mailjet.sh "${PLAYER}"  ~/.zen/tmp/${MOATS}/AstroID.html "TW5 & AstroID"

#~ mpack -a -s "✅ UPlanet : AstroID ($PASS)" -d ~/.zen/tmp/${MOATS}/intro.txt \
    #~ $HOME/.zen/game/players/${PLAYER}/AstroID.png ${PLAYER}

## CLEANING CACHE
rm -Rf ~/.zen/tmp/${MOATS}


#####################################################################"

## CHECK .current
[[ ! -d $(readlink ~/.zen/game/players/.current) ]] \
&& rm ~/.zen/game/players/.current 2>/dev/null \
&& ln -s ~/.zen/game/players/${PLAYER} ~/.zen/game/players/.current


echo $PSEUDO > ~/.zen/tmp/PSEUDO ## Return data to command.sh # KEEP IT
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
################################################ LAST LINE REPORT VALUES TO CALLING SCRIPT | tail -n 1
echo "export ASTROTW=/ipns/$ASTRONAUTENS ASTROG1=$G1PUB ASTROMAIL=$PLAYER ASTROFEED=$FEEDNS PASS=$PASS"
exit 0
