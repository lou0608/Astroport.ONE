# Préambule
Quand pourrons nous sortir de ce Méchant Cloud qui nous profile, nous scrute, nous analyse... Pour au final nous faire consommer.
Je n'ai pas suivi la formation d’ingénieur réseau pour fabriquer ça!
Alors j'ai fait autre chose.

Astroport est basé sur IPFS pour former nos Cloud personnels échangés entre amis d'amis à l’abri des algorithmes de l'IA et du datamining sauvage qui règne ici bas.
L'avantage de ce système, une consommation énergétique divisé par 100, une répartition des données qui permet de fonctionner déconnecté, un système d'information pair à pair inaltérable, inviolable.
S'il vous plaît arrêtons cet Internet Supermarché de nous même...
C'est une bibliothèque du savoir à la base.

https://astroport.com
Avec cette technologie, nous devenons chacun hébergeur et fournisseur d'accès, souverain monétaire et médiatique.
Avec cette technologie, nous établissons une "Crypto Nation" dont la carte relie les territoires au delà des frontières et des pays.
Astroport ONE est une ambassade.

# Astroport.ONE

Il s'agit d'un Jeu de société grandeur nature qui consiste à répertorier, inventer, enseigner, diffuser les meilleures façons d'habiter la planète Terre.
Ce programme introduit des données multimédia (page web, audio, vidéo) en tant que chaines de données (blockchain) inscrites dans le réseau IPFS
que les joueurs échangent au travers des Oasis.

Astroport One c'est aussi une performance scientifique et artistique néé le 25 oct 2021.
Dans une forêt de 8ha située en France, dans le Tarn et Garonne, une groupe de bénéficiaires du RSA
s'est réuni, pour jouer le rôle de membres d'une "NASA Extraterrestes" installés en forêt qu'ils transforment en jardin.

Cette exploration met en oeuvre l'usage de "Monnaie Libre" appliquée à ce JEu de société.
Chaque nouveau joueur reçoit 300 LOVE (correspondant à 3 DU(G1) afin dévaluer sa capacité à pratiquer des activités ayant une valeur pour le commun.

Chacun est invité à enregistrer ses idées et propositions pour améliorer la qualité de vie du lieu.
Ces publications sont enregistrées comme REVES du lieu.

Chaque joueur aura pour mission, de répartir le montant de sa production monétaire journalière, 100 LOVE entre les ACTIONS et les REVES déclarés.
Il devra également s'acquiter du montant établi pour assurer sa pension complête, montant réduit au 1/3 quand le joueur aura offert un nouvel habitat.

Les règles évoluent encore... Pour rejoindre l'expérience :

Astroport One, Sorris, Lavaurette, France
Latitude: 44.22986344
Longitude: 1.65397188

---

Bienvenue dans la confédération intergalactique.

Ambassade des Astronautes Terraformeurs.

Avant de commencer l'aventure, découvrez cet ouvrage "The Barefoot Architect" de Johan Van Lengen.
```
ipfs ls Qme6a6RscGHTg4e1XsRrpRoNbfA6yojC6XNCBrS8nPSEox/
ipfs cat QmbfVUAyX6hsxTMAZY7MhvUmB3AkfLS7KqWihjGfu327yG /tmp/vdoc.pub_the-barefoot-architect.pdf
```

Le JEu est constitué de Stations IPFS localisés à des cooordonnées précises.
Ces stations acceuillent des joueurs.  Leur mission, réaliser des rêves.

Dans IPFS, chaque Astroport fédère des Astronautes autour du lieu en cours de "mise à jour".
Un canal de communication Tiddlywiki (TW) est attribué à chaque participant, le "Journal de Notes MOA" contient son G1Visa

Il suffit de disposer de G1 pour commencer à jouer!!

Nous utilisons la monnaie libre pour estimer la valeur des idées et voeux de chacun afin d’organiser au mieux les actions qui garantissent une meilleure amélioration pour le plus grand nombre.
Cela se matérialise au travers des G1Voeux, à la fois porte-monnaie et TW, il permet de coller des QRCODE aux endroits, objets pour lesquels vous proposez une amélioration pour un meilleur usage **(plus simple, moins de maintenance)**

https://forum.monnaie-libre.fr/t/les-explorateurs-du-libre-rencontre-et-partage-des-constructeurs-du-monde-libre/24040

# INSTALLATION (Debian/Ubuntu/Mint ou Xbian)

```
bash <(wget -qO- https://git.p2p.legal/qo-op/Astroport.ONE/raw/branch/master/install.sh)
```

# LANCEMENT

```
~/.zen/Astroport.ONE/start.sh
```

Hommage au jeu des origines de la bureautique ludique, essayez, enrichissez le script ```~/.zen/Astroport.ONE/aventure.sh```

# USAGE

L'utilisation du cryptosystème signifie que tout hôte possédant une clé privée peut modifier "quelque chose", la clé publique étant l'adresse de cette "chose". Quand on se concentre sur le hachage des données comme le fait IPFS, on peut stocker n'importe quoi partout.

Astroport.ONE attache une clé (2 pass phrase NaCl generattion) et un email à un modèle TW. Chaque ordinateur sert l'API sur le port 1234. Il peut héberger plusieurs clés PLAYER et gérer leurs TW.

Chaque jour, à 20h12, tous les noeuds synchronisent leur TW en fonction des niveaux de confiance exprimés. Le niveau de confiance est défini en échangeant des étoiles via l'application https://gchange.fr.

N'importe qui (avec une connexion par fibre optique) peut créer un nœud chez lui, inviter des amis et partager des "tiddlers" et des "G1Tags" ensemble.
Vous pouvez rejoindre le swam#0 officiel d'Astroport, en devenant bootstrap et hôte dans http://copylaradio.com:1234 TestNet "DNS Round Robin".

Bien entendu, le mieux est que chacun héberge et publie ses propres données sur son ordinateur "localhost" (pas de délégation de clé privée dans ce cas), de sorte que le protocole de réplication Astroport Ŋ1 peut être utilisé à tout moment. Mais il est préférable de garder une heure de connexion commune afin que les hôtes soient tous disponibles pour un torrent bit massif.

TW est la première application disponible pour les personnes décentralisées.
L'utilisateur peut écrire des notes personnelles, et quelques "tiddlers de commande" pour activer la copie des tiddlers entre les TW d'amis et exécuter des pré et/ou post traitements.

[20H12.sh](/qo-op/Astroport.ONE/src/branch/master/20h12.sh)


# API

Astroport n'utilise pas de serveur web! **netcat** publie un dcoument de bienvenu sur le port 1234... Il redirige le visiteur vers le $PORT du retour de l'exécution de l'API. Ce processus rend tout DDOS impossible. Le Round Robin DNS réparti les délégations de clefs.

Chaque appel API comporte "salt" et "pepper", correspondance NaCl de la clef en usage.

```
# TYPE = official, g1pub, messaging, testcraft, ....
http://127.0.0.1:1234/?salt=${SALT}&pepper=${PEPPER}&${TYPE}=?&...
```
[12345.sh](/qo-op/Astroport.ONE/src/branch/master/12345.sh)

# TIDDLYWIKI

Les données produites par chaque clef sont stockées en tant que tiddlers dans des Tiddlywiki.
Le tag "voeu" déclenche la transformation du tiddler en "G1Voeu".
Son Titre  devient un tag qui permet d'échanger les tiddlers correspondant au même voeu que ses TW amis.

> [https://ncase.me/loopy/v1.1/?data=%5B3%2C646%2C229%2C0.5%2C%2522Astronaute%2522%2C5%5D%2C%5B4%2C806%2C372%2C0.16%2C%2522G1Voeu%2522%2C3%5D%2C%5B5%2C449%2C133%2C0.83%2C%2522G1Talent%2522%2C1%5D%2C%5B6%2C928%2C124%2C0.5%2C%2522Astronaute%2522%2C0%5D%2C%5B7%2C1055%2C293%2C0.5%2C%2522Astronaute%2522%2C0%5D%2C%5B8%2C883%2C587%2C0.5%2C%2522Astronaute%2522%2C0%5D%2C%5B10%2C691%2C54%2C0.5%2C%2522G1Voeu%2522%2C3%2C3%2C5%2C82%2C1%2C0%5D%2C%5B3%2C4%2C-87%2C1%2C0%5D%2C%5B6%2C4%2C83%2C1%2C0%5D%2C%5B4%2C5%2C176%2C1%2C0%5D%2C%5B8%2C8%2C85%2C1%2C12%5D%2C%5B8%2C4%2C-45%2C1%2C0%5D%2C%5B7%2C4%2C34%2C1%2C0%5D%2C%5B5%2C3%2C49%2C1%2C0%5D%2C%5B7%2C7%2C101%2C1%2C225%5D%2C%5B6%2C6%2C113%2C1%2C-84%5D%2C%5B3%2C3%2C90%2C1%2C75%5D%2C%5B5%2C4%2C-293%2C1%2C0%5D%2C%5B3%2C10%2C34%2C1%2C0%2C%5B%5D%2C10%255D%5D](Simulateur Astronaute/Voeux)

## DO YOU TALK TW ? https://talk.tiddlywiki.org

```
# TiddlyWiki #
sudo apt install npm
sudo npm install -g tiddlywiki
added 1 package, and audited 2 packages in 10s
found 0 vulnerabilities
```
Proposez vos "Templates"...

---

# TODO
* Ajouter des worlists au choix par oasis https://diceware.readthedocs.io/en/stable/wordlists.html
