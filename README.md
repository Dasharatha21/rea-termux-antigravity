# 🤖 REA + Antigravity CLI for Android Termux (ARM64)

[![Platform: Android Termux](https://img.shields.io/badge/Platform-Android%20Termux%20(ARM64)-00D26A?logo=android&logoColor=white)](https://termux.dev)
[![REA Agents](https://img.shields.io/badge/REA%20Agents-v6.8.0-blue?logo=npm)](https://github.com/reverse-engineer-anything/rea)
[![MCP Enabled](https://img.shields.io/badge/MCP-Standard%20Stdio%20(Compact)-8A2BE2)](https://modelcontextprotocol.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An all-in-one, beginner-friendly automation kit to turn your Android phone into an AI-powered Reverse Engineering & Binary Inspection workstation using **REA CLI (`rea-agents`)** and **Antigravity CLI** via the **Model Context Protocol (MCP)**.

---

## 📖 Table of Contents
1. [📱 Step 1: Install Termux Safely](#-step-1-install-termux-safely)
2. [⚡ Step 2: One-Click Automatic Installation](#-step-2-one-click-automatic-installation)
3. [🤖 Step 3: Connect & Use with Antigravity CLI](#-step-3-connect--use-with-antigravity-cli)
4. [🎮 Step 4: Interactive Menu for Non-Technical Users](#-step-4-interactive-menu-for-non-technical-users)
5. [📊 Step 5: Android ARM64 Compatibility Matrix](#-step-5-android-arm64-compatibility-matrix)
6. [🛠️ Step 6: Troubleshooting & 1-Command Fixes](#-step-6-troubleshooting--1-command-fixes)
7. [📜 License](#-license)

---

## 📱 Step 1: Install Termux Safely

> [!CAUTION]
> **DO NOT install Termux from Google Play Store!** The Play Store version has been deprecated since 2020 due to Android SDK restrictions and will fail to install packages.

Download and install the official modern Termux build from either:
- **F-Droid (Recommended):** [Download Termux on F-Droid](https://f-droid.org/en/packages/com.termux/)
- **Official GitHub Releases:** [Termux GitHub Releases (Select `arm64-v8a`)](https://github.com/termux/termux-app/releases)

---

## ⚡ Step 2: One-Click Automatic Installation

Open Termux on your phone, copy the command below, and paste it:

```bash
pkg install -y git && git clone https://github.com/your-username/rea-termux-antigravity.git ~/rea-termux-antigravity && cd ~/rea-termux-antigravity && bash install.sh
```

### What `install.sh` automatically does for you:
1. **Configures Storage:** Prompts for Android storage access so you can access `/sdcard/Download`.
2. **Updates Package Lists:** Syncs Termux APT repositories.
3. **Installs Native Packages:**
   - `nodejs` (v22+ / v26+ modern JavaScript runtime)
   - `procps` (Required for REA process tree checks)
   - `binutils` (`objdump`, `readelf` for binary header inspection)
   - `rizin` (ARM64 native disassembler & static analysis)
   - `android-tools` (`adb` Android debug bridge)
   - `apktool` (Android manifest & resource decoder)
   - `jq`, `curl`, `git` (Core command-line tools)
4. **Installs REA Globally:** Automatically runs `npm install -g rea-agents` and applies the Termux shebang fix.
5. **Configures MCP with Compact Profile:** Automatically generates `~/.gemini/config/mcp_config.json` with `REA_MCP_INPUT_SCHEMA_PROFILE="compact"` and `REA_MCP_OUTPUT_SCHEMA_PROFILE="off"` to prevent context token overflow.
6. **Mounts the Bundled Skill:** Installs all 229 tool definitions into `~/.gemini/config/skills/reverse-engineer-anything/`.

---

## 🤖 Step 3: Connect & Use with Antigravity CLI

Once installed, start the **Antigravity CLI** in any directory:

```bash
antigravity
```

Because REA is registered as a global MCP server, Antigravity has direct access to all REA capabilities. You can speak to it in plain English or Hinglish without memorizing CLI syntax!

### 5 Ready-to-Use Copy-Paste Prompts:

#### 1. APK Manifest & Permissions Audit
> *"Inspect the APK located at `/sdcard/Download/sample.apk`. Read its AndroidManifest.xml, list all requested dangerous permissions, and identify exported components (Activities, Services, Receivers)."*

#### 2. JavaScript / React Native Bundle Inspection
> *"Analyze the bundled JavaScript file at `~/storage/downloads/index.android.bundle`. Extract API endpoints, hardcoded credentials, and exported route names."*

#### 3. Flutter App Architecture Analysis
> *"Check the Flutter APK at `/sdcard/Download/flutter_app.apk`. Locate the `libapp.so` and `libflutter.so` binary assets and tell me which Flutter engine and architecture it targets."*

#### 4. Native Shared Object (`.so`) Symbols Inspection
> *"Inspect the ARM64 shared library `/data/data/com.termux/files/usr/lib/libsqlite3.so` using objdump and rizin. List all exported dynamic functions and external imported dependencies."*

#### 5. Local App Database Schema Inspection
> *"Use the REA sqlite inspector to inspect the database file at `~/storage/downloads/app_data.db`. Show me table names, columns, and foreign key relationships without executing unauthorized queries."*

---

## 🎮 Step 4: Interactive Menu for Non-Technical Users

Don't want to type terminal commands? Use our built-in guided interactive menu:

```bash
cd ~/rea-termux-antigravity
bash examples/quick-demo.sh
```

```text
  ╔════════════════════════════════════════════════════════════════╗
  ║            REA + Antigravity Interactive Quick Menu            ║
  ║         One-Touch Reverse Engineering & Artifact Inspection    ║
  ╚════════════════════════════════════════════════════════════════╝

  1. Check APK / Binary Signature & Details
  2. Decode APK Resources (Layouts, Manifest, Drawables)
  3. Inspect Web / JavaScript / React Native Bundle
  4. Inspect Native Shared Object (.so / ELF Library)
  5. Run REA Diagnostics & Provider Audit (rea doctor)
  6. Exit
```

Just press `1`, `2`, `3`, or `4`, paste the path to your file (e.g. `/sdcard/Download/app.apk`), and the script will automatically process the file and save clean reports to `~/rea-demo-output/`.

---

## 📊 Step 5: Android ARM64 Compatibility Matrix

| Analysis Engine / Feature | Android Phone (ARM64 Termux) | Host PC (x86_64 Linux/Mac) | Notes |
| :--- | :---: | :---: | :--- |
| **REA Core Agent & MCP** | ✅ **100% Native** | ✅ **Supported** | Full 229 MCP tools via Node.js v22/26 |
| **Artifact Graph Inspector** | ✅ **100% Native** | ✅ **Supported** | Fast ELF, APK, ZIP, ASAR inspection |
| **Apktool Resource Decoding** | ✅ **100% Native** | ✅ **Supported** | Powered by OpenJDK 21 + aapt2 in Termux |
| **Rizin Disassembly (ARM64)** | ✅ **100% Native** | ✅ **Supported** | Native ARM64 binary disassembly |
| **Objdump / Binutils** | ✅ **100% Native** | ✅ **Supported** | Fast symbol tables and headers extraction |
| **SQLite Inspector** | ✅ **100% Native** | ✅ **Supported** | Built into Node.js 24/26 DatabaseSync |
| **Hopper Disassembler** | ❌ *Unsupported on ARM64* | ✅ *x86_64 only* | Proprietary x86_64 Linux/macOS engine |
| **Ghidra Headless** | ⚠️ *Optional (Resource heavy)* | ✅ *Recommended* | Requires 8GB+ RAM; run via proot-distro |
| **IDA Pro MCP Bridge** | ❌ *Requires IDA license* | ✅ *Windows / macOS* | Connects remotely via JSON-RPC bridge |

---

## 🛠️ Step 6: Troubleshooting & 1-Command Fixes

### 1. Simple Health Audit
Run our diagnostic troubleshooter anytime to test your entire stack:
```bash
bash ~/rea-termux-antigravity/check-health.sh
```

### 2. Fix `/usr/bin/env: bad interpreter` (Shebang Issue)
If running `rea` gives an `env: bad interpreter` error:
```bash
termux-fix-shebang $(which rea)
```

### 3. Missing Storage Access (`Permission Denied` on `/sdcard`)
Ensure Termux has permission to read files from your Android Download folder:
```bash
termux-setup-storage
```

### 4. Reset & Re-align MCP Registration
If Antigravity cannot find REA tools, run:
```bash
bash ~/rea-termux-antigravity/install.sh
```

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
