#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# REA + Antigravity CLI Health & Diagnostic Troubleshooter
# ==============================================================================
# Repository: rea-termux-antigravity
# License: MIT
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo -e "\n${BOLD}${CYAN}🔍 REA + Antigravity CLI Environment Health Audit${NC}"
echo -e "${CYAN}===================================================================${NC}"

print_ok() {
    printf "  %-32s [ %bOK%b ] %b\n" "$1" "$GREEN" "$NC" "$2"
}

print_missing() {
    printf "  %-32s [%bMISSING%b] %b\n" "$1" "$RED" "$NC" "$2"
    ERRORS=$((ERRORS + 1))
}

print_warn() {
    printf "  %-32s [%bWARNING%b] %b\n" "$1" "$YELLOW" "$NC" "$2"
    WARNINGS=$((WARNINGS + 1))
}

# 1. Architecture Check
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
    print_ok "Architecture: ARM64" "($ARCH - Native Android)"
else
    print_warn "Architecture: $ARCH" "(Recommended: aarch64)"
fi

# 2. Node.js Check
if command -v node &>/dev/null; then
    NODE_V=$(node -v)
    MAJOR=$(echo "$NODE_V" | sed 's/v//' | cut -d. -f1)
    if [ "$MAJOR" -ge 22 ]; then
        print_ok "Node.js Runtime" "($NODE_V >= 22.x)"
    else
        print_warn "Node.js Runtime" "($NODE_V - Node 22+ recommended for REA)"
    fi
else
    print_missing "Node.js Runtime" "(Run: pkg install nodejs)"
fi

# 3. REA CLI Check
if command -v rea &>/dev/null; then
    REA_V=$(rea --version 2>/dev/null || echo "error")
    if [ "$REA_V" != "error" ]; then
        print_ok "REA CLI (rea-agents)" "(v$REA_V)"
    else
        print_missing "REA CLI Shebang" "(Run: termux-fix-shebang \$(which rea))"
    fi
else
    print_missing "REA CLI (rea-agents)" "(Run: npm install -g rea-agents)"
fi

# 4. Process Inspection (procps)
if command -v ps &>/dev/null && ps --version &>/dev/null; then
    PS_V=$(ps --version | head -n 1 | awk '{print $NF}')
    print_ok "Procps (ps inspection)" "(v$PS_V)"
else
    print_missing "Procps (ps)" "(Run: pkg install procps)"
fi

# 5. Binutils (objdump)
if command -v objdump &>/dev/null; then
    OBJ_V=$(objdump -v 2>&1 | head -n 1 | awk '{print $NF}')
    print_ok "Binutils (objdump)" "(v$OBJ_V)"
else
    print_missing "Binutils (objdump)" "(Run: pkg install binutils)"
fi

# 6. Rizin (ARM64 Native Disassembler)
if command -v rizin &>/dev/null; then
    RZ_V=$(rizin -v | head -n 1 | awk '{print $2}')
    print_ok "Rizin Disassembler" "(v$RZ_V)"
else
    print_missing "Rizin Disassembler" "(Run: pkg install rizin)"
fi

# 7. Apktool (Android APK Decoder)
if command -v apktool &>/dev/null; then
    APK_V=$(apktool --version 2>/dev/null || echo "ok")
    print_ok "Apktool" "(v$APK_V)"
else
    print_missing "Apktool" "(Run: pkg install apktool)"
fi

# 8. Android Debug Bridge (adb)
if command -v adb &>/dev/null; then
    ADB_V=$(adb --version | head -n 1 | awk '{print $NF}')
    print_ok "Android ADB Tools" "(v$ADB_V)"
else
    print_missing "Android ADB Tools" "(Run: pkg install android-tools)"
fi

# 9. Utilities (Git, Curl, JQ)
for util in git curl jq; do
    if command -v "$util" &>/dev/null; then
        print_ok "Utility: $util" "(Installed)"
    else
        print_missing "Utility: $util" "(Run: pkg install $util)"
    fi
done

echo -e "${CYAN}-------------------------------------------------------------------${NC}"
echo -e "${BOLD}MCP Configuration Status:${NC}"

# 10. Antigravity MCP Config
MCP_FILE="$HOME/.gemini/config/mcp_config.json"
if [ -f "$MCP_FILE" ]; then
    if grep -q "\"rea\"" "$MCP_FILE" && grep -q "REA_MCP_INPUT_SCHEMA_PROFILE" "$MCP_FILE"; then
        print_ok "Antigravity MCP Server" "($MCP_FILE - Compact Mode Enabled)"
    else
        print_warn "Antigravity MCP Server" "(Needs compact schema env vars)"
    fi
else
    print_missing "Antigravity MCP Config" "(Run: bash install.sh)"
fi

# 11. Gemini CLI Config
GEMINI_FILE="$HOME/.gemini/settings.json"
if [ -f "$GEMINI_FILE" ]; then
    if grep -q "\"rea\"" "$GEMINI_FILE"; then
        print_ok "Gemini CLI MCP Server" "($GEMINI_FILE)"
    else
        print_warn "Gemini CLI MCP Server" "(Config present but REA server missing)"
    fi
else
    print_warn "Gemini CLI MCP Config" "(Optional: $GEMINI_FILE)"
fi

# 12. Bundled Skill Directory
SKILL_DIR="$HOME/.gemini/config/skills/reverse-engineer-anything"
if [ -f "$SKILL_DIR/SKILL.md" ]; then
    print_ok "REA Bundled Skill" "($SKILL_DIR/SKILL.md)"
else
    print_warn "REA Bundled Skill" "(Optional: run bash install.sh to copy SKILL.md)"
fi

echo -e "${CYAN}===================================================================${NC}"

# Final Verdict
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}🎉 ALL ESSENTIAL COMPONENTS ARE OPERATIONAL!${NC}"
    echo -e "${GREEN}Aapka Termux environment REA aur Antigravity ke liye bilkul tayar hai.${NC}\n"
    exit 0
else
    echo -e "${RED}${BOLD}⚠️  $ERRORS ESSENTIAL ITEM(S) MISSING OR NEED ATTENTION!${NC}"
    echo -e "${YELLOW}To automatically fix missing dependencies, simply run:${NC}"
    echo -e "  ${CYAN}bash install.sh${NC}\n"
    exit 1
fi
