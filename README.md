# Script d'installation des outils nécessaires
Le but de ce script est de vous faciliter la transition vers un OS différent de BLinux.

Il vous permettra notamment d'installer tous les outils nécessaires pour réussir votre première et seconde année à Epitech ainsi que différents bonus.


Ce script fonctionne actuellement pour les OS basés sur :
- ArchLinux (Antergos & ApricityOS inclus)
- Debian (Deepin inclus)
- Korora (Toutes versions)
- Gentoo
- OpenSUSE
- Solus Project

Attention :
- Ce script ne fonctionne pas et ne fonctionnera jamais sous Linux Mint Debian Edition (LMDE).


## Utilisation :
./install `prénom.nom@epitech.eu`

Veuillez ne pas exécuter le script en SU.
Ce dernier vous demandera l'accès SuperUser lorsque nécessaire.


## Fonctionnement du script

* Mise à jour de votre système.

* Installation des paquets suivant :
    - blih
    - curl
    - filezilla
    - git
    - glibc
    - libncurses
    - make
    - ocaml
    - tree
    - valgrind
* Paquets optionnels :
    - emacs / vim (au choix)
    - makefile-gen
    - man google
    - zsh ou fish (au choix)
    - terminator

* Génère puis envoie votre clé ssh sur le serveur Epitech.

* Change votre shell de base en zsh ou fish en fonction de votre choix.

* Change votre Terminal de base en Terminator ou RXVT-Unicode selon votre choix.

* Installe les headers Epitech à jours (2017)


## Crédits

* montag_p - Pour le script sur lequel je me suis basé.
* lesell_b - Pour avoir contribué au script créé par montag_p.
* cyril_l - Pour le plugin VIM Epitech.
* giubil_v - Pour m'avoir supplié d'accepter sa pull request.
* wentz_s - Pour avoir raté sa vie de redneck.
