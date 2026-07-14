<div align="center" width="100%">
    <h1>Keycloak-Enum</h1>
    <img width="300" alt="Picture1" src="https://github.com/user-attachments/assets/5b5db1a7-9785-4ee0-a27b-8c85a6920928" />
    <p>Identify the exact Keycloak version of a live instance by fingerprinting its publicly-served static assets</p><p>
    <a target="_blank" href="https://github.com/l4rm4nd"><img src="https://img.shields.io/badge/maintainer-LRVT-orange" /></a>
    <a target="_blank" href="https://GitHub.com/l4rm4nd/Keycloak-Enum/graphs/contributors/"><img src="https://img.shields.io/github/contributors/l4rm4nd/Keycloak-Enum.svg" /></a>
    <a target="_blank" href="https://github.com/PyCQA/bandit"><img src="https://img.shields.io/badge/security-bandit-yellow.svg"/></a><br>
    <a target="_blank" href="https://GitHub.com/l4rm4nd/Keycloak-Enum/commits/"><img src="https://img.shields.io/github/last-commit/l4rm4nd/Keycloak-Enum.svg" /></a>
    <a target="_blank" href="https://GitHub.com/l4rm4nd/Keycloak-Enum/issues/"><img src="https://img.shields.io/github/issues/l4rm4nd/Keycloak-Enum.svg" /></a>
    <a target="_blank" href="https://github.com/l4rm4nd/Keycloak-Enum/issues?q=is%3Aissue+is%3Aclosed"><img src="https://img.shields.io/github/issues-closed/l4rm4nd/Keycloak-Enum.svg" /></a><br>
    <a target="_blank" href="https://github.com/l4rm4nd/Keycloak-Enum/stargazers"><img src="https://img.shields.io/github/stars/l4rm4nd/Keycloak-Enum.svg?style=social&label=Star" /></a>
    <a target="_blank" href="https://github.com/l4rm4nd/Keycloak-Enum/network/members"><img src="https://img.shields.io/github/forks/l4rm4nd/Keycloak-Enum.svg?style=social&label=Fork" /></a>
    <a target="_blank" href="https://github.com/l4rm4nd/Keycloak-Enum/watchers"><img src="https://img.shields.io/github/watchers/l4rm4nd/Keycloak-Enum.svg?style=social&label=Watch" /></a><br>
    <a target="_blank" href="https://github.com/l4rm4nd/Keycloak-Enum/pkgs/container/keycloak-enum"><img src="https://badgen.net/badge/icon/ghcr.io%2Fl4rm4nd%2Fkeycloak-enum:latest?icon=docker&label" /></a><br><p>
    <a href="https://www.buymeacoffee.com/LRVT" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>
</div>

## 💬 Description

**No installation required.** A single Python 3.9+ script with no third-party dependencies.

Keycloak 22+ ships its admin and account consoles as pre-built Vite bundles with SHA-256-stable, content-hashed filenames. Every version produces a unique set of asset hashes. The script:

1. Probes the target for any Keycloak HTML page (admin console, account console, login page)
2. Extracts the Vite resource hash from the page
3. Fetches the Vite manifest and all 200+ chunk JS/CSS files in parallel (20 workers)
4. Fetches vendor JS files (React, rfc4648, web-crypto-shim) via the resource hash — publicly accessible on all versions
5. Directly probes account and admin Vite manifests using the login resource hash — resolves patch-level ambiguity even when the console redirects to a login page
6. Intersects all observed SHA-256 hashes against `fingerprints.json` and returns the matching version(s)

No ports beyond 80/443 are used. No credentials are required. No pages that require login are accessed.

## ✨ Requirements

- **Python 3.9+** — stdlib only, no `pip install` needed
- **Docker** — only required for `collect`; not needed for fingerprinting

## 🎓 Usage

### 🐳 Example 1 - Docker Run

````bash
docker run --rm -t ghcr.io/l4rm4nd/keycloak-enum:latest fingerprint https://keycloak.example.com

# add missing fingerprints for new releases; requires docker socket as we pull keycloak images and a bind mount volume
wget https://raw.githubusercontent.com/l4rm4nd/Keycloak-Enum/refs/heads/main/fingerprints.json
docker run --rm -t -v /var/run/docker.sock:/var/run/docker.sock:ro -v $(pwd)/fingerprints.json:/app/fingerprints.json ghcr.io/l4rm4nd/keycloak-enum:latest collect --new
````

### 🐍 Example 2 - Native Python

````bash
git clone https://github.com/l4rm4nd/Keycloak-Enum
cd Keycloak-Enum

python3 keycloak-fingerprint.py fingerprint https://keycloak.example.com

# Self-signed / internal certificate
python3 keycloak-fingerprint.py fingerprint https://keycloak.internal --no-verify

# Debug output (shows each probed URL and hash)
python3 keycloak-fingerprint.py fingerprint https://keycloak.example.com -v

# Output full result as JSON
python3 keycloak-fingerprint.py fingerprint https://keycloak.example.com --json

# add missing fingerprints for new releases; requires docker
python3 keycloak-fingerprint.py collect --new
````

**Example output:**

````
Target      : https://keycloak.example.com
Console     : https://keycloak.example.com/realms/master/account/
Keycloak    : Detected

JavaScript  : main-Ct94EjXz.js
CSS         : main-XXXXXXXX.css

Match       : exact_unique
Confidence  : high
Version     : 26.2.5

208/211 hashes uniquely identify Keycloak 26.2.5.
````

**Match values:**

| Match | Meaning |
|-------|---------|
| `exact_unique` | A single version matches all observed hashes |
| `exact_ambiguous` | Multiple versions share the same asset set (identical patch releases) |
| `partial` | Some hashes matched but no single version covers all of them |
| `unknown` | No hashes found in the database — version likely not collected yet |

### ➕ Adding fingerprints for a new version (requires Docker)

````bash
# Single version
python3 keycloak-fingerprint.py collect 26.7.1

# All versions in the built-in list; basically recreate the local fingerprint database
python3 keycloak-fingerprint.py collect --all

# Fetch latest releases from GitHub and collect any not yet fingerprinted
python3 keycloak-enum.py collect --new

# Custom image reference
python3 keycloak-enum.py collect 26.7.1 --image myregistry/keycloak:26.7.1

# Re-collect even if already present
python3 keycloak-enum.py collect 26.7.1 --force
````

Collection pulls the Docker image, creates a stopped container, copies the Keycloak JARs, hashes their assets in memory, then immediately removes the container. No container is ever started.

On each run of `fingerprint` the tool automatically checks GitHub for new Keycloak releases and warns if the local `fingerprints.json` is missing any. Pass `--no-update-check` to suppress this check.

## 💎 Covered Versions

`fingerprints.json` currently contains **59 versions** across Keycloak 24–26:

````
24.0.x  →  24.0.0 – 24.0.5  (6 releases)
25.0.x  →  25.0.0 – 25.0.6  (6 releases; 25.0.3 skipped by upstream)
26.0.x  →  26.0.0 – 26.0.8  (8 releases; 26.0.3 skipped by upstream)
26.1.x  →  26.1.0 – 26.1.5  (6 releases)
26.2.x  →  26.2.0 – 26.2.5  (6 releases)
26.3.x  →  26.3.0 – 26.3.5  (6 releases)
26.4.x  →  26.4.0 – 26.4.7  (7 releases; 26.4.3 skipped by upstream)
26.5.x  →  26.5.0 – 26.5.7  (8 releases)
26.6.x  →  26.6.0 – 26.6.4  (5 releases)
26.7.x  →  26.7.0            (1 release)
````

To add new release versions, run either `collect <version>` or `collect --new` - it appends fingerprints to the local `fingerprints.json`.

## 💥 Limitations

- **Custom themes** — If the target uses a custom admin/account theme, asset hashes will differ from upstream images and the version will not match.
- **Very old versions** — Keycloak < 22 does not ship the Vite-based admin UI. The script may still detect the login page and match login-theme assets for versions ≥ 25.
- **Missing versions** — If a version is not in `fingerprints.json`, the result will be `unknown`. Run `collect <version>` to add it.
