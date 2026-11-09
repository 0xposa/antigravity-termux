#!/usr/bin/env bash
# ==============================================================================
# Antigravity CLI - Termux Native Uninstaller
# Repository: https://github.com/0xposa/antigravity-termux
#
# Menghapus instalasi Antigravity CLI secara bersih dari Termux.
# ==============================================================================

set -euo pipefail

# Warna Output
if [ -t 1 ]; then
    C_RESET="\033[0m"
    C_BOLD="\033[1m"
    C_GREEN="\033[1;32m"
    C_YELLOW="\033[1;33m"
    C_RED="\033[1;31m"
    C_CYAN="\033[1;36m"
else
    C_RESET=""
    C_BOLD=""
    C_GREEN=""
    C_YELLOW=""
    C_RED=""
    C_CYAN=""
fi

echo -e "${C_RED}====================================================${C_RESET}"
echo -e "${C_RED}${C_BOLD}     Uninstall Google Antigravity CLI (Termux)     ${C_RESET}"
echo -e "${C_RED}====================================================${C_RESET}"
echo ""

read -r -p "Apakah Anda yakin ingin menghapus Antigravity CLI dari Termux? [y/N]: " confirm || true
case "${confirm:-N}" in
    [yY][eE][sS]|[yY]) ;;
    *) echo -e "${C_YELLOW}Pembatalan: Antigravity CLI tidak dihapus.${C_RESET}"; exit 0 ;;
esac

echo ""
echo -e "${C_CYAN}➜${C_RESET} Menghapus berkas biner..."

# Hapus biner & symlink dari $PREFIX/bin jika ada
if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX/bin" ]; then
    rm -f "$PREFIX/bin/antigravity" "$PREFIX/bin/agy"
fi

# Hapus dari ~/.local/bin jika ada
rm -f "$HOME/.local/bin/antigravity" "$HOME/.local/bin/agy"

# Hapus cache staging
echo -e "${C_CYAN}➜${C_RESET} Membersihkan cache sementara..."
rm -rf "$HOME/.cache/antigravity"

echo -e "${C_GREEN}✔${C_RESET} Berkas biner dan cache berhasil dihapus."
echo ""

# Opsi pembersihan data login dan konfigurasi
read -r -p "Hapus juga seluruh data konfigurasi dan login akun (~/.gemini/antigravity-cli)? [y/N]: " wipe_data || true
case "${wipe_data:-N}" in
    [yY][eE][sS]|[yY])
        echo -e "${C_CYAN}➜${C_RESET} Menghapus data konfigurasi..."
        rm -rf "$HOME/.gemini/antigravity-cli"
        echo -e "${C_GREEN}✔${C_RESET} Konfigurasi berhasil dihapus."
        ;;
    *)
        echo -e "${C_YELLOW}ℹ${C_RESET} Data konfigurasi tetap disimpan untuk instalasi mendatang."
        ;;
esac

echo ""
echo -e "${C_GREEN}====================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}   Google Antigravity CLI berhasil di-uninstall!    ${C_RESET}"
echo -e "${C_GREEN}====================================================${C_RESET}"
echo ""
