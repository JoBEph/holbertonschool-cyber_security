# Securing Your Shop’s Admin Dashboard

### Charting a Course through Vulnerability Waters

Ce projet consiste à analyser et sécuriser l’application interne **ShopAdmin**, accessible via [**http://web0x08.hbtn/**](http://web0x08.hbtn/)

.

Lors de l’exploration du site, il apparaît que la fonctionnalité de **réduction des chèques** s’appuie sur un paramètre nommé `**articleApi**`, présentant un risque potentiel de **Server-Side Request Forgery (SSRF)**.

Lorsque l’utilisateur sélectionne un article, ce mécanisme peut rediriger certaines requêtes vers le **port 3000**, révélant ainsi une surface d’attaque supplémentaire.

L’objectif de cette mission est d’identifier ce comportement, de comprendre les implications possibles et de proposer les correctifs nécessaires pour renforcer la sécurité du tableau de bord d’administration.

## Étapes d’Analyse

### **1\. Observation du paramètre** `**articleApi**`

Lors de l’interaction avec la fonctionnalité de réduction, le paramètre `articleApi` peut être modifié.

Cette étape consiste à analyser son comportement en conditions contrôlées, notamment lorsqu’il pointe vers une ressource locale ou interne, afin d’évaluer les risques SSRF potentiels.

<img width="1056" height="473" alt="task1SSF" src="https://github.com/user-attachments/assets/960baedb-7462-406e-bf3e-1387b8b0f5a5" />


### **2\. Analyse des ressources internes appelées**

En poursuivant l’investigation, l’étude du chemin retrouvé dans l’URL (`/list-of-items`) permet d’inspecter la structure HTML renvoyée et d’identifier la présence éventuelle d’éléments sensibles (comme une colonne `flag` dans un contexte de test ou de CTF).

<img width="1043" height="522" alt="task1_2ssf" src="https://github.com/user-attachments/assets/de40a8c1-ec4c-43fb-86cb-5ea62347332b" />

## Is our security a fortress or a sieve? Let's SSRF and find out!


L’application cible est accessible via [**http://web0x08.hbtn/app2/**](http://web0x08.hbtn/app2/)

.

Après connexion, il est possible de parcourir les articles du site et d’utiliser la fonctionnalité de réduction de chèque, déjà identifiée auparavant comme sensible aux attaques SSRF.

Dans cette nouvelle version, un filtre supplémentaire a été ajouté : l’objectif est de vérifier s’il bloque réellement les contournements possibles.

L’application redirige également certains traitements vers le **port 3001**, ce qui constitue un point important à examiner.

  

1 – Modifier l’adresse Localhost en utilisant une représentation hexadécimale pour contourner le filtre

  

/\*image \*/

  

2- Comme dans le “flag 0”, utiliser l’un des chemins proposés, ici « /list-of-items »

  

> /\*image \*/