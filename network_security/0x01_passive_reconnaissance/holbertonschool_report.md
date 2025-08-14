# Passive Reconnaissance Report: holbertonschool.com

This report is a passive reconnaissance using public information from Shodan.io.

## 1. Active IPs and Subdomains
- **35.180.27.154** (ec2-35-180-27-154.eu-west-3.compute.amazonaws.com)
- **52.47.143.83** (ec2-52-47-143-83.eu-west-3.compute.amazonaws.com)
- **yriry2.holbertonschool.com**

## 2. Hosting
- Amazon Data Services France
- Location: France, Paris

## 3. Web Servers and Versions
- nginx/1.18.0 (Ubuntu)
- nginx

## 4. SSL Certificates and Supported Protocols
- Certificate: Let’s Encrypt
- SSL Protocols: TLSv1.2, TLSv1.3

## 5. HTTP Responses and Page Titles
- **35.180.27.154**: HTTP/1.1 301 Moved Permanently, Title: "301 Moved Permanently"
- **yriry2.holbertonschool.com**: HTTP/1.1 200 OK, Title: "Holberton School Level2 Forum"

## 6. Security
- Modern SSL protocols in use (TLSv1.2, TLSv1.3)
- Let’s Encrypt certificates
- Secure cloud hosting (AWS)


## 8. Vulnerabilities by IP

- **35.180.27.154**: 3 vulnerabilities found
  - CVE-2023-44487 (2023): HTTP/2 DoS via rapid stream resets
  - CVE-2021-23017 (2021): nginx resolver 1-byte overwrite
  - CVE-2021-3618 (2021): ALPACA TLS cross-protocol attack

- **52.47.143.83**: 3 vulnerabilities found
  - CVE-2023-44487 (2023): HTTP/2 DoS via rapid stream resets
  - CVE-2021-23017 (2021): nginx resolver 1-byte overwrite
  - CVE-2021-3618 (2021): ALPACA TLS cross-protocol attack
