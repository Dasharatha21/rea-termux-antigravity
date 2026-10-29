#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# REA Interactive Quick Demo - Non-Technical Beginner Assistant
# ==============================================================================
# Repository: rea-termux-antigravity
# License: MIT
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

OUTPUT_DIR="$HOME/rea-demo-output"
mkdir -p "$OUTPUT_DIR"

show_menu() {
    clear || true
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
  ╔════════════════════════════════════════════════════════════════╗
  ║            REA + Antigravity Interactive Quick Menu            ║
  ║         One-Touch Reverse Engineering & Artifact Inspection    ║
  ╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${BOLD}Select an action to perform on your Android phone:${NC}\n"
    echo -e "  ${GREEN}1.${NC} Check APK / Binary Signature & Details"
    echo -e "  ${GREEN}2.${NC} Decode APK Resources (Layouts, Manifest, Drawables)"
    echo -e "  ${GREEN}3.${NC} Inspect Web / JavaScript / React Native Bundle"
    echo -e "  ${GREEN}4.${NC} Inspect Native Shared Object (.so / ELF Library)"
    echo -e "  ${GREEN}5.${NC} Run REA Diagnostics & Provider Audit (rea doctor)"
    echo -e "  ${RED}6.${NC} Exit\n"
}

get_file_path() {
    local prompt_text="$1"
    local sample_hint="$2"
    while true; do
        echo -e "${YELLOW}$prompt_text${NC}"
        echo -e "${CYAN}(Hint: e.g. $sample_hint)${NC}"
        read -r -p "Enter path: " TARGET_PATH
        TARGET_PATH="${TARGET_PATH/#\~/$HOME}"
        TARGET_PATH="${TARGET_PATH%/}"

        if [ -z "$TARGET_PATH" ]; then
            echo -e "${RED}Path cannot be empty. Please try again.${NC}\n"
        elif [ ! -f "$TARGET_PATH" ] && [ ! -d "$TARGET_PATH" ]; then
            echo -e "${RED}File or directory not found at: $TARGET_PATH${NC}\n"
        else
            break
        fi
    done
}

run_option_1() {
    echo -e "\n${BOLD}${CYAN}--- [1] Checking APK / Binary Signature & Metadata ---${NC}"
    get_file_path "Paste the path to your APK or binary file:" "/sdcard/Download/sample.apk"
    echo -e "\n${YELLOW}Running safe artifact inspection via REA...${NC}"
    rea inspect-artifact "$TARGET_PATH" 2>&1 | tee "$OUTPUT_DIR/signature_inspection.log" || {
        echo -e "${YELLOW}Fallback: Using native apksigner / unzip inspection...${NC}"
        unzip -l "$TARGET_PATH" 2>&1 | grep -E "META-INF|AndroidManifest" || true
    }
    echo -e "\n${GREEN}✅ Inspection report saved to: $OUTPUT_DIR/signature_inspection.log${NC}"
    read -r -p "Press [Enter] to return to menu..."
}

run_option_2() {
    echo -e "\n${BOLD}${CYAN}--- [2] Decoding APK Resources via Apktool ---${NC}"
    get_file_path "Paste the path to your APK file:" "/sdcard/Download/app.apk"
    BASENAME=$(basename "$TARGET_PATH" .apk)
    DEST_DIR="$OUTPUT_DIR/decoded_$BASENAME"

    echo -e "\n${YELLOW}Decoding APK resources into $DEST_DIR ...${NC}"
    rm -rf "$DEST_DIR"
    apktool d -f "$TARGET_PATH" -o "$DEST_DIR" || {
        echo -e "${RED}Apktool encountered an error while decoding.${NC}"
    }

    if [ -f "$DEST_DIR/AndroidManifest.xml" ]; then
        echo -e "${GREEN}✅ APK successfully decoded!${NC}"
        echo -e "  • AndroidManifest: $DEST_DIR/AndroidManifest.xml"
        echo -e "  • Res folder:     $DEST_DIR/res"
    fi
    read -r -p "Press [Enter] to return to menu..."
}

run_option_3() {
    echo -e "\n${BOLD}${CYAN}--- [3] Inspecting JS / Web / React Native Bundle ---${NC}"
    get_file_path "Paste the path to your .js, .asar, or web archive:" "$HOME/storage/downloads/index.android.bundle"
    echo -e "\n${YELLOW}Analyzing bundle structure via REA safe graph inspector...${NC}"
    rea inspect-artifact "$TARGET_PATH" 2>&1 | tee "$OUTPUT_DIR/bundle_inspection.log"
    echo -e "\n${GREEN}✅ JS bundle inspection saved to: $OUTPUT_DIR/bundle_inspection.log${NC}"
    read -r -p "Press [Enter] to return to menu..."
}

run_option_4() {
    echo -e "\n${BOLD}${CYAN}--- [4] Inspecting Native Shared Object (.so / ELF) ---${NC}"
    get_file_path "Paste the path to your .so library or ELF binary:" "$PREFIX/bin/jq"
    echo -e "\n${YELLOW}Extracting ELF header and exported dynamic symbols...${NC}"
    
    echo -e "${BOLD}${MAGENTA}--- ELF File Identity ---${NC}"
    file "$TARGET_PATH" 2>/dev/null || readelf -h "$TARGET_PATH" 2>/dev/null | head -n 10 || true
    
    echo -e "\n${BOLD}${MAGENTA}--- Exported Dynamic Symbols (Top 20) ---${NC}"
    if command -v objdump &>/dev/null; then
        objdump -T "$TARGET_PATH" 2>/dev/null | grep -E "g\s+DF|g\s+DO" | head -n 20 || true
    elif command -v rizin &>/dev/null; then
        rizin -qc 'is~[4]' "$TARGET_PATH" 2>/dev/null | head -n 20 || true
    fi

    echo -e "\n${GREEN}✅ Native inspection completed.${NC}"
    read -r -p "Press [Enter] to return to menu..."
}

run_option_5() {
    echo -e "\n${BOLD}${CYAN}--- [5] Running REA Environment & Provider Diagnostics ---${NC}"
    rea doctor
    echo -e "\n${GREEN}Diagnostic finished.${NC}"
    read -r -p "Press [Enter] to return to menu..."
}

# Main Loop
while true; do
    show_menu
    read -r -p "Enter choice [1-6]: " CHOICE
    case "$CHOICE" in
        1) run_option_1 ;;
        2) run_option_2 ;;
        3) run_option_3 ;;
        4) run_option_4 ;;
        5) run_option_5 ;;
        6) echo -e "\n${GREEN}Exiting. Happy reverse engineering!${NC}\n"; exit 0 ;;
        *) echo -e "${RED}Invalid selection. Please choose 1-6.${NC}"; sleep 1 ;;
    esac
done
