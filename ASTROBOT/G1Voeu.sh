#!/bin/bash
################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
. "$MY_PATH/../tools/my.sh"
################################################################################
# Create G1VOEU TW for PLAYER
# Mon Titre => G1MonTitre => PEPPER
## PARAM : "TITRE DU VOEU" "PLAYER" "INDEX"
################################################################################
TITRE="$1"
PLAYER="$2"
INDEX="$3"

[[ $PLAYER == "" ]] && PLAYER=$(cat ~/.zen/game/players/.current/.player 2>/dev/null)
[[ $PLAYER == "" ]] && echo "Second paramètre PLAYER manquant" && exit 1
PSEUDO=$(cat ~/.zen/game/players/$PLAYER/.pseudo 2>/dev/null)
[[ $G1PUB == "" ]] && G1PUB=$(cat ~/.zen/game/players/$PLAYER/.g1pub 2>/dev/null)
[[ $G1PUB == "" ]] && echo "Troisième paramètre G1PUB manquant" && exit 1

[[ ! $INDEX ]] && INDEX="$HOME/.zen/game/players/$PLAYER/ipfs/moa/index.html"
echo $INDEX
[[ ! -s $INDEX ]] && echo "TW $PLAYER manquant" && exit 1

echo "Working on $INDEX"

ASTRONAUTENS=$(ipfs key list -l | grep -w "${PLAYER}" | cut -d ' ' -f 1)
[[ $ASTRONAUTENS == "" ]] && echo "CLEF IPNS ASTRONAUTE MANQUANTE - EXIT -" && exit 1

echo "Bienvenue $PSEUDO ($PLAYER) : $G1PUB"
echo

######################################################################
MOATS="$4"
[[ ! $MOATS ]] && MOATS=$(date -u +"%Y%m%d%H%M%S%4N")
mkdir -p ~/.zen/tmp/$MOATS

#####################################################
# CREATION DU TW G1VOEU
#####################################################
    source ~/.zen/game/players/$PLAYER/secret.june ## CLEF DERIVEE ET MEMORISABLE
    [[ $PEPPER ]] && echo "Using PLAYER PEPPER AS WISH SALT" && SALT=$PEPPER ##
    [[ ! $SALT ]] && SALT=$(${MY_PATH}/../tools/diceware.sh 3 | xargs)
    echo "$SALT"

    echo "## TITRE DU G1VOEU ? CapitalGluedWords please"
    [[ ! $TITRE ]] && read TITRE
    PEPPER=$(echo "$TITRE" | sed -r 's/\<./\U&/g' | sed 's/ //g') # CapitalGluedWords
    echo "$PEPPER" && [[ ! $PEPPER ]] && echo "EMPTY PEPPER - ERROR" && exit 1

    echo "## keygen CLEF DE VOEUX from PLAYER : pepper + G1WishName derivation"
    ${MY_PATH}/../tools/keygen  -t duniter -o ~/.zen/tmp/qrtw.dunikey "$SALT" "$PEPPER"
    WISHKEY=$(cat ~/.zen/tmp/qrtw.dunikey | grep "pub:" | cut -d ' ' -f 2)
    echo "WISHKEY (G1PUB) = $WISHKEY"

    echo "# NOUVEAU VOEU"
    mkdir -p ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/
    ${MY_PATH}/../tools/keygen -t ipfs -o ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/qrtw.ipfskey "$SALT" "$PEPPER"
    ipfs key import $WISHKEY -f pem-pkcs8-cleartext ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/qrtw.ipfskey
    VOEUNS=$(ipfs key list -l | grep -w "$WISHKEY" | cut -d ' ' -f 1 )
    echo "/ipns/$VOEUNS"

    ## NATOOLS ENCRYPT
    echo "# NATOOLS ENCODING  qrtw.ipfskey "
    $MY_PATH/../tools/natools.py encrypt -p $G1PUB -i $HOME/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/qrtw.ipfskey -o $HOME/.zen/tmp/${MOATS}/qrtw.ipfskey.$G1PUB.enc
    ENCODING=$(cat $HOME/.zen/tmp/${MOATS}/qrtw.ipfskey.$G1PUB.enc | base16)
    echo $ENCODING

    ## TEST IPFS
    ipfs --timeout=30s cat /ipns/$VOEUNS > ~/.zen/tmp/$VOEUNS.json
    [[ -s ~/.zen/tmp/$VOEUNS.json ]] \
    && echo "HEY !!! UN CHANNEL EXISTE DEJA POUR CE VOEU !  ~/.zen/tmp/$VOEUNS.json  - EXIT -" \
    && exit 1

    echo "# UPGRADING WORLD WHISHKEY DATABASE"

    mkdir -p ~/.zen/game/world/$PEPPER/$WISHKEY/
    ## A la fois Titre du tag et Pepper construction de clef
    echo $PEPPER > ~/.zen/game/world/$PEPPER/$WISHKEY/.pepper
    echo $WISHKEY > ~/.zen/game/world/$PEPPER/$WISHKEY/.wish

    echo "# CREATION QR CODE"

    LIBRA=$(head -n 2 ~/.zen/Astroport.ONE/A_boostrap_nodes.txt | tail -n 1 | cut -d ' ' -f 2)

    qrencode -s 12 -o "$HOME/.zen/game/world/$PEPPER/$WISHKEY/QR.WISHLINK.png" "$LIBRA/ipns/$VOEUNS"

    ## MAKING amrzqr containing G1PUB/SSL[SEC(SALT)].BASE58/PASS.SHA
    ## LE MOT DE PASSE DU PLAYER PEUT DECOUVRIR LE SECRET (
    ## SEC PASS PROTECTED QRCODE : base58 secFromDunikey.openssl(pass)
    secFromDunikey=$(cat ~/.zen/tmp/qrtw.dunikey | grep "sec" | cut -d ' ' -f2)
    echo "$secFromDunikey" > ~/.zen/tmp/${MOATS}/${PSEUDO}.sec
    openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -in ~/.zen/tmp/${MOATS}/${PSEUDO}.sec -out "$HOME/.zen/tmp/${MOATS}/enc.${PSEUDO}.sec" -k "$SALT" 2>/dev/null
    PASsec=$(cat ~/.zen/tmp/${MOATS}/enc.${PSEUDO}.sec | base58)
    HPass=$(echo "$SALT" | sha512sum | cut -d ' ' -f 1 )
    qrencode -s 12 -o $HOME/.zen/game/players/${PLAYER}/QRsec.png $PASsec

    cp ${MY_PATH}/../images/g1magicien.png ~/.zen/tmp/${MOATS}/fond.png
    convert -gravity northwest -pointsize 25 -fill black -draw "text 40,40 \"$PLAYER\"" ~/.zen/tmp/${MOATS}/fond.png ~/.zen/tmp/${MOATS}/layer1.png
    convert -gravity southeast -pointsize 25 -fill black -draw "text 30,30 \"$PEPPER\"" ~/.zen/tmp/${MOATS}/layer1.png ~/.zen/tmp/${MOATS}/result.png

    ## MAKE amzqr WITH astro:// LINK
    amzqr "$myASTRONEF/?qrcode=$WISHKEY&sslpassdunikeysec=$PASsec&asksalt=$HPass&flux=$VOEUNS&tw=$ASTRONAUTENS" \
                -d "$HOME/.zen/game/world/$PEPPER/$WISHKEY" \
                -l H \
               -p ~/.zen/tmp/${MOATS}/result.png -c

    IMAGIC=$(ipfs add -Hq ~/.zen/game/world/$PEPPER/$WISHKEY/result_qrcode.png | tail -n 1)

    qrencode -s 12 -o "$HOME/.zen/game/world/$PEPPER/$WISHKEY/QR.ASTROLINK.png" "$LIBRA/ipns/$ASTRONAUTENS"
    qrencode -s 12 -o "$HOME/.zen/game/world/$PEPPER/$WISHKEY/QR.G1ASTRO.png" "$G1PUB"
    qrencode -s 12 -o "$HOME/.zen/game/world/$PEPPER/$WISHKEY/QR.G1WISH.png" "$WISHKEY"
    qrencode -s 12 -o "$HOME/.zen/game/world/$PEPPER/$WISHKEY/QR.IPNS.png" "/ipns/$VOEUNS"

#################################
    # PREMIER TYPE ~/.zen/tmp/player.png
    convert $HOME/.zen/game/world/$PEPPER/$WISHKEY/QR.WISHLINK.png -resize 300 ~/.zen/tmp/QRWISHLINK.png
    convert ${MY_PATH}/../images/logoastro.png  -resize 220 ~/.zen/tmp/ASTROLOGO.png

composite -compose Over -gravity NorthWest -geometry +350+10 ~/.zen/tmp/ASTROLOGO.png ${MY_PATH}/../images/Brother_600x400.png ~/.zen/tmp/astroport.png
composite -compose Over -gravity NorthWest -geometry +0+0 ~/.zen/tmp/QRWISHLINK.png ~/.zen/tmp/astroport.png ~/.zen/tmp/one.png
convert -gravity northwest -pointsize 20 -fill black -draw "text 320,250 \"$PLAYER\"" ~/.zen/tmp/one.png ~/.zen/tmp/hop.png
convert -gravity northwest -pointsize 30 -fill black -draw "text 20,320 \"$PEPPER\"" ~/.zen/tmp/hop.png ~/.zen/tmp/pseudo.png
convert -gravity northwest -pointsize 30 -fill black -draw "text 320,300 \"$SALT\"" ~/.zen/tmp/pseudo.png ~/.zen/tmp/salt.png
convert -gravity northwest -pointsize 33 -fill black -draw "text 320,350 \"$PEPPER\"" ~/.zen/tmp/salt.png ~/.zen/tmp/player.png

#################################
    # SECOND TYPE ~/.zen/tmp/voeu.png
    convert $HOME/.zen/game/world/$PEPPER/$WISHKEY/QR.G1WISH.png -resize 300 ~/.zen/tmp/G1WISH.png
    convert ${MY_PATH}/../images/logojeu.png  -resize 260 ~/.zen/tmp/MIZLOGO.png

composite -compose Over -gravity NorthWest -geometry +0+0 ~/.zen/tmp/G1WISH.png ${MY_PATH}/../images/Brother_600x400.png ~/.zen/tmp/astroport.png
composite -compose Over -gravity NorthWest -geometry +300+0 ~/.zen/tmp/QRWISHLINK.png ~/.zen/tmp/astroport.png ~/.zen/tmp/one.png
composite -compose Over -gravity NorthWest -geometry +320+280 ~/.zen/tmp/MIZLOGO.png ~/.zen/tmp/one.png ~/.zen/tmp/two.png

convert -gravity northwest -pointsize 28 -fill black -draw "text 32,350 \"Ğ1 VOEU\"" ~/.zen/tmp/two.png ~/.zen/tmp/pep.png
convert -gravity northwest -pointsize 50 -fill black -draw "text 30,300 \"$PEPPER\"" ~/.zen/tmp/pep.png ~/.zen/tmp/voeu.png

    # IMAGE DANS IPFS
    IVOEUPLAY=$(ipfs add -Hq ~/.zen/tmp/player.png | tail -n 1)
    IVOEU=$(ipfs add -Hq ~/.zen/tmp/voeu.png | tail -n 1)

    ### G1VOEU LIGHTBEAM :: ${PLAYER}_${PEPPER} :: /ipns/${VOEUNS}
    echo '[{"title":"$:/plugins/astroport/lightbeams/saver/ipns/lightbeam-name","text":"'${PLAYER}_${PEPPER}'","tags":""}]' > ~/.zen/tmp/${MOATS}/lightbeam-name.json
    echo '[{"title":"$:/plugins/astroport/lightbeams/saver/ipns/lightbeam-key-'${PEPPER}'","text":"'${VOEUNS}'","tags":""}]' > ~/.zen/tmp/${MOATS}/lightbeam-key.json
    echo '[{"title":"$:/plugins/astroport/lightbeams/saver/g1/lightbeam-key-'${PEPPER}'","text":"'${WISHKEY}'","tags":""}]' > ~/.zen/tmp/${MOATS}/lightbeam-g1.json
    echo '[{"title":"$:/plugins/astroport/lightbeams/saver/g1/lightbeam-natools-'${PEPPER}'","text":"'${ENCODING}'","tags":""}]' > ~/.zen/tmp/${MOATS}/lightbeam-natools.json



#    TEXT="<a target='_blank' href='"/ipns/${VOEUNS}"'><img src='"/ipfs/${IVOEUPLAY}"'></a><br><br><a target='_blank' href='"/ipns/${VOEUNS}"'>"${PEPPER}"</a>"
#:[tag[G1CopierYoutube]] [tag[pdf]]
    # Contains QRCode linked to G1VoeuTW and BUTTON listing G1Voeux
    TEXT="<img src='"/ipfs/${IMAGIC}"'><br>
    <a target='_blank' href='#:[tag[G1"$PEPPER"]]' ><img src='"/ipfs/${IVOEUPLAY}"'></a><br>
    <a target='_blank' href='"/ipns/${VOEUNS}"'>TW G1Voeu "$PLAYER"</a><br><br>
    <\$button class='tc-tiddlylink'>
    <\$list filter='[tag[G1"${PEPPER}"]]'>
   <\$action-navigate \$to=<<currentTiddler>> \$scroll=no/>
    </\$list>
    Afficher tous vos G1"${PEPPER}"
    </\$button>"

    # NEW IVEU TIDDLER
    echo "## Creation json tiddler : G1${PEPPER} /ipfs/${IVOEU}"
    echo '[
  {
    "created": "'${MOATS}'",
    "title": "'${PEPPER}'",
    "type": "'text/vnd.tiddlywiki'",
    "astronautens": "'/ipns/${ASTRONAUTENS}'",
    "wishns": "'/ipns/${VOEUNS}'",
    "qrcode": "'/ipfs/${IVOEUPLAY}'",
    "decode": "'/ipfs/${IVOEU}'",
    "wish": "'${WISHKEY}'",
    "g1pub": "'${G1PUB}'",
    "text": "'${TEXT}'",
    "tags": "'G1Voeu G1${PEPPER} ${PLAYER}'",
    "asksalt": "'${HPass}'",
    "sslpassdunikeysec" : "'${ENCODING}'"
  }
]
' > ~/.zen/game/world/$PEPPER/$WISHKEY/${PEPPER}.voeu.json



    rm -f ~/.zen/tmp/newindex.html

    echo "Nouveau Voeu $PEPPER dans MOA $PSEUDO : http://127.0.0.1:8080/ipns/$ASTRONAUTENS"
    tiddlywiki  --load $INDEX \
                        --deletetiddlers '[tag[voeu]]' \
                        --import ~/.zen/tmp/${MOATS}/lightbeam-name.json "application/json" \
                        --import ~/.zen/tmp/${MOATS}/lightbeam-key.json "application/json" \
                        --import ~/.zen/tmp/${MOATS}/lightbeam-g1.json "application/json" \
                        --import ~/.zen/tmp/${MOATS}/lightbeam-natools.json "application/json" \
                        --import ~/.zen/game/world/$PEPPER/$WISHKEY/${PEPPER}.voeu.json "application/json" \
                        --output ~/.zen/tmp --render "$:/core/save/all" "newindex.html" "text/plain"

    echo "PLAYER TW Update..."
    if [[ -s ~/.zen/tmp/newindex.html ]]; then
        echo "$$$ Mise à jour $INDEX"
        cp -f ~/.zen/tmp/newindex.html $INDEX
    else
        echo "ERROR INTO ~/.zen/game/world/$PEPPER/$WISHKEY/${PEPPER}.voeu.json"
    fi

    # PRINTING
    LP=$(ls /dev/usb/lp* | head -n1)
    if [[ ! $LP ]]; then
        echo "NO PRINTER FOUND - Plug a Brother QL700 or Add your printer"
    else
        echo "IMPRESSION VOEU"
        brother_ql_create --model QL-700 --label-size 62 ~/.zen/game/world/$PEPPER/$WISHKEY/g1magicien_qrcode.png > ~/.zen/tmp/toprint.bin 2>/dev/null
        sudo brother_ql_print ~/.zen/tmp/toprint.bin $LP
        brother_ql_create --model QL-700 --label-size 62 ~/.zen/tmp/player.png > ~/.zen/tmp/toprint.bin 2>/dev/null
        sudo brother_ql_print ~/.zen/tmp/toprint.bin $LP
        brother_ql_create --model QL-700 --label-size 62 ~/.zen/tmp/voeu.png > ~/.zen/tmp/toprint.bin 2>/dev/null
        sudo brother_ql_print ~/.zen/tmp/toprint.bin $LP
    fi

    # COPY QR CODE TO PLAYER ZONE
    cp ~/.zen/tmp/player.png ~/.zen/tmp/voeu.png ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/
    echo "$SALT" > ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/.salt
    echo "$PEPPER" > ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/.title

    echo "$LIBRA/ipns/$VOEUNS" > ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/.link
    cp ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/.link /.zen/game/world/$PEPPER/$WISHKEY/
    cp ~/.zen/game/world/$PEPPER/$WISHKEY/*.png ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/

    # PUBLISHING
    echo "ipfs name publish --key=${WISHKEY}"
    banner="## ${PLAYER} G1WISH READY :: G1$PEPPER
    <img src=/ipfs/IMAGIC>
    G1Voeu Astronaute (TW) : $LIBRA/ipns/$ASTRONAUTENS
    $PEPPER FLUX Ŋ1
    G1$PEPPER : $LIBRA/ipns/$VOEUNS
    WHISHKEY(G1PUB) : ${WISHKEY}
     - Only $PLAYER PEPPER used as login or sslpass can make $PEPPER wish evolution"

    IPUSH=$(echo "$banner" | ipfs add -q | tail -n 1)
    ipfs name publish --key=${WISHKEY} /ipfs/$IPUSH 2>/dev/null

    echo $IPUSH > ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/.chain.$MOATS

    echo $banner > ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/banner
    cat ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY/banner

    echo "## TO RECEIVE G1RONDS Creating Cesium+ Profil #### timeout long ... patience ...."
    $MY_PATH/../tools/jaklis/jaklis.py -k ~/.zen/tmp/qrtw.dunikey set --name "G1Voeu $PEPPER" --avatar "$HOME/.zen/game/world/$PEPPER/$WISHKEY/g1magicien_qrcode.png" --site "$LIBRA/ipns/$VOEUNS" #CESIUM+
    [[ ! $? == 0 ]] && echo "G1VOEU CESIUM WALLET PROFILE CREATION FAILED !!!!"

    echo "************************************************************"
    echo "Hop, UNE JUNE pour le Voeu $PEPPER"
    echo $MY_PATH/../tools/jaklis/jaklis.py -k ~/.zen/game/players/$PLAYER/secret.dunikey pay -a 1 -p $WISHKEY -c \'"$VOEUNS G1Voeu $PEPPER"\' -m
    echo "************************************************************"
    echo "************************************************************"

    $MY_PATH/../tools/jaklis/jaklis.py -k ~/.zen/game/players/$PLAYER/secret.dunikey pay -a 1 -p $WISHKEY -c "$VOEUXNS G1Voeu $PEPPER" -m
    [[ ! $? == 0 ]] \
    && echo "SOOOOOOOOOOOORRRRRRRY GUY. YOU CANNOT PAY A G1 FOR A NEW WISH"
    #~ && rm -Rf ~/.zen/game/players/$PLAYER/voeux/$PEPPER/$WISHKEY \
    #~ && rm -Rf ~/.zen/game/world/$PEPPER/$WISHKEY/ \
    #~ && ipfs key rm ${WISHKEY} \
    #~ && tiddlywiki  --load ${INDEX} \
                              #~ --deletetiddlers '${PEPPER}' \
                              #~ --output ~/.zen/tmp --render "$:/core/save/all" "newindex.html" "text/plain" \
    #~ && cp -f ~/.zen/tmp/newindex.html $INDEX \
    #~ && echo "G1${PEPPER} FLUX REMOVED"

    echo "************************************************************"

exit 0
