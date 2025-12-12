# cookies_h.py

# Étape 1 : Charger les cookies générés par Burp Sequencer
with open("tokens_sequencer.txt", "r") as f:
    brut = f.read().split()
    tokens = sorted(set(brut))

# Étape 2 : Extraire les timestamps
prefix = tokens[0].rsplit("-", 1)[0]  # partie fixe avant le timestamp
timestamps = sorted(int(token.rsplit("-", 1)[1]) for token in tokens)

# Étape 3 : Détecter les timestamps manquants
min_ts = min(timestamps)
max_ts = max(timestamps)
manquants = []

for ts in range(min_ts, max_ts + 1):
    if ts not in timestamps:
        manquants.append(f"{prefix}-{ts}")

# Étape 4 : Afficher les résultats
print(f"📡 Capturés par Sequencer : {len(tokens)}")
print(f"🎯 Timestamps manquants : {len(manquants)}\n")

for cookie in manquants:
    print(cookie)

# Étape 5 : Sauvegarder les cookies manquants
with open("cookies_manquants.txt", "w") as f:
    for cookie in manquants:
        f.write(cookie + "\n")

print("\n✅ Résultat enregistré dans cookies_manquants.txt")
