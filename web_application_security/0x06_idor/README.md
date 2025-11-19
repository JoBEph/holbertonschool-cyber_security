# CyberBank — Comprehensive Vulnerability Report

  

## **1\. Introduction**

  

Ce rapport présente les résultats d’une évaluation de sécurité menée sur l’application CyberBank, une plateforme bancaire simulée conçue pour sensibiliser aux vulnérabilités de type IDOR (Insecure Direct Object References) et aux failles de logique applicative dans les environnements financiers.

L’objectif de cette analyse est d’identifier les vulnérabilités présentes, d’en démontrer l’exploitation et de fournir des recommandations visant à améliorer la sécurité globale du système.

Ce document suit les standards professionnels utilisés lors d’audits de sécurité dans le secteur financier.

  

## **2\. Méthodologie**

  

### **Approche**
<img width="1763" height="661" alt="Screenshot 2025-11-14 145509" src="https://github.com/user-attachments/assets/5a63a818-49e0-484b-b014-a4797d70351d" />

Une approche manuelle a été utilisée afin d’explorer en profondeur les comportements de l’application et ses mécanismes d’autorisation.

Les tests se sont concentrés sur :

-   les interactions utilisateurs (customer\_id)
-   les endpoints exposés
-   la validation côté serveur

###   

### **Outils Utilisés**

  

#### **Burp Suite (Community Edition)**

-   **Proxy Interception** : capture des requêtes et réponses HTTP
-   **Repeater** : reproduction et modification de requêtes pour tester des IDOR
-   **Intruder** : tests d’énumération et modification de paramètres

  

#### **Navigateurs & DevTools (Chrome/Firefox)**

  

-   Inspection du DOM
-   Analyse du trafic dans l’onglet Network
-   Consultation et manipulation du JavaScript exposé
-   Observation des paramètres sensibles visibles côté client
-   Récupération d’identifiants (customer\_id, account\_id)


###   

### **Vulnérabilité 1 — Exposition et Manipulation des User IDs (IDOR)**

####   

#### **Description**

  

L’application expose les identifiants utilisateurs (User IDs) dans les URLs, dans les requêtes API visibles via DevTools et dans certaines

données front-end. Aucun contrôle serveur ne valide que l’utilisateur a le droit d’accéder aux ressources associées à ces IDs.

####   

#### **Impact**

-   Accès non autorisé aux informations d’autres utilisateurs
-   Atteinte majeure à la confidentialité
-   Point d’entrée pour des attaques plus avancées

  

#### **Étapes de reproduction**

  

1.  Se connecter au site de  CyberBank.
2.  Ouvrir DevTools(f12) → Network.
3.  Identifier des requêtes API contenant /customer\_id , account\_id ou id.
4.  Collecter tous les contacts/transactions de l’utilisateur (http://web0x06.hbtn/api/customer/info/me)
5.  Observer les données utilisateur non autorisées.
6.  Récupérer le flag sur une page utilisateur (_0-flag.txt_).

  

#### **Preuves**

  
<img width="603" height="645" alt="Screenshot 2025-11-14 161733" src="https://github.com/user-attachments/assets/af5edcb0-5726-4b6a-a94a-e7c59e740794" />
<img width="851" height="433" alt="Screenshot 2025-11-15 171359" src="https://github.com/user-attachments/assets/ad1a0db2-4b75-4647-83b3-6b626a74f23c" />


#### **Recommandations**

  

-   Contrôle d’accès strict côté serveur
-   Ne pas exposer d’IDs sensibles dans les URLs
-   Utiliser des UUID non incrémentaux
-   Ajouter des tests automatisés sur les permissions

###   

**Vulnérabilité 2 — Énumération des Comptes & Fuite de Soldes (IDOR sur /accounts)**

####   

#### **Description**

Les numéros de compte sont prévisibles et accessibles sans vérification robuste. L’endpoint /accounts/account\_id> renvoie le solde même si l’utilisateur n’est pas propriétaire du compte.

#### **Impact**

-   Fuite de données financières critiques
-   Possibilité de profiling bancaire
-   Violation grave de confidentialité

  

#### **Étapes de reproduction**

  

1.  Récupérer des user IDs grâce à la vulnérabilité précédente.
2.  Observer des requêtes /accounts/<id> dans DevTools.
3.  Intercepter dans Burp Repeater.
4.  Tester d’autres IDs prévisibles.
5.  Obtenir les soldes d’autres comptes.
6.  Récupérer le flag (_1-flag.txt_).

####   

**Preuves**

  
<img width="823" height="436" alt="Screenshot 2025-11-15 170440" src="https://github.com/user-attachments/assets/bb564b6f-1174-4eff-9ca2-6086deed187a" />

  

#### **Recommandations**

-   Vérification serveur de la propriété du compte
-   Utilisation d’identifiants de compte non prédictibles
-   Masquage des données non essentielles dans les réponses
-   Détection d’énumération (rate limiting + alertes)

  

### **Vulnérabilité 3 — Manipulation des Transferts pour Gonfler un Solde (Logic Flaw)**

####   

#### **Description**

  

La plateforme ne valide pas correctement :

-   la propriété du compte source
-   la cohérence entre les comptes
-   les montants autorisés
-   augmentation artificiellement le solde d’un compte

  

#### **Impact**

-   Création d’argent virtuel
-   Altération de l’intégrité financière
-   Fraude potentielle à grande échelle
-   Vulnérabilité critique dans tout environnement bancaire

#### **Étapes de reproduction**

1.  Effectuer un transfert légitime.
2.  Intercepter la requête dans Burp.
3.  Modifier montant ou IDs de comptes.
4.  Réémettre la requête.
5.  Observer le solde frauduleusement augmenté.
6.  Dépasser 10 000 $ pour obtenir le flag (_2-flag.txt_).

#### **Preuves**

<img width="819" height="648" alt="Screenshot 2025-11-15 173208" src="https://github.com/user-attachments/assets/037a3f07-2e88-4bfc-91ac-e6e124356bdb" />


#### **Recommandations**

-   Validation stricte de la propriété du compte source
-   Limites de montant et contrôles anti-fraude
-   Transactions atomiques et sécurisées
-   Surveillance renforcée des transferts

###   

### **Vulnérabilité 4 — Contournement du 3D Secure pour Paiements Non Autorisés**

####   

#### **Description**

  

L’OTP 3D Secure n’est pas lié cryptographiquement au véritable propriétaire du compte.

Il est donc possible d’initier un paiement avec les données d’un autre utilisateur tout en validant l’OTP avec son propre compte.

####   

#### **Impact**

-   Paiements frauduleux validés
-   Contournement total du 3D Secure
-   Risque financier majeur

  

#### **Étapes de reproduction**

  

1.  Aller sur /upgrade et initier un paiement avec un compte tiers.
2.  Sur la page 3D Secure, observer la requête OTP via DevTools.
3.  Intercepter la requête dans Burp.
4.  Modifier les paramètres sensibles (user\_id, session\_id, account\_id).
5.  Réémettre.
6.  Le paiement est validé sur un compte qui n’est pas autorisé.
7.  Récupérer le flag (_3-flag.txt_).

####   

#### **Recommandations**

-   Lier l’OTP au titulaire réel du compte
-   Signer cryptographiquement les paramètres critiques
-   Utiliser des tokens non manipulables (HMAC, JWT)
-   Bloquer toute validation d’OTP provenant d’un autre compte
-   Surveillance renforcée des paiements sensibles

##   

## **4\. Additional Findings**

  

### **A. Informations sensibles dans les réponses API**

Plusieurs endpoints exposent des champs inutiles (IDs internes, données de debug…).

  

### **B. Absence de rate limiting**

Les endpoints peuvent être énumérés sans aucune restriction.

  

### **C. Mauvaise gestion des erreurs**

Les erreurs divulguent des informations techniques exploitables.

  

## **5\. Recommandations Globales**

  

### **Sécurité Applicative**

  

-   RBAC/ABAC
-   Vérification systématique de la propriété des ressources
-   Identifiants non prédictible
-   Minimisation des données envoyées

  

### **Sécurité Financière**

  

-   Validation renforcée des transferts
-   Refonte du 3D Secure
-   Monitoring anti-fraude

### **Sécurité Serveur**

  

-   Signature HMAC/JWT des paramètres sensibles
-   Protection contre manipulation client-side
-   Logging et alertes avancées

## **6\. Conclusion**

  

L’analyse de CyberBank révèle plusieurs vulnérabilités critiques permettant l’accès non autorisé à des données sensibles, la manipulation de transactions financières et le contournement complet du 3D Secure.

La correction rapide de ces failles est indispensable pour prévenir des pertes financières, préserver l’intégrité du système et protéger les utilisateurs.

  

## **7\. References**

  

### **Documentation & Guides sur les IDOR**

  

-   _Insecure Direct Object References (IDOR)_
-   _All About Insecure Direct Object Reference (IDOR)_
-   _Insecure Direct Object Reference (IDOR) Explained_
-   _IDOR? Ok but what is it finally?_
-   _OWASP Top 10: Insecure Direct Object Reference_
-   _Insecure Direct Object Reference (IDOR) – A Deep Dive_
-   _Everything You Need to Know About IDOR_
-   _Types of IDOR_
-   _How to Find More IDORs_
-   _IDOR Mitigation Best Practices_

  

### **Cheat Sheets & OWASP**

  

-   _IDOR (OWASP)_
-   _Testing for IDOR_
-   _IDOR Cheat Sheet_

  

### **Outils et Documentation Technique**

  

-   Burp Suite — User Guide
-   Chrome & Firefox DevTools Documentation
-   OWASP API Security Top 10
