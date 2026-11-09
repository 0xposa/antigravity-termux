#!/usr/bin/env bash
# ==============================================================================
# Antigravity CLI - Termux Native Auto-Installer (Official Release)
# Repository: https://github.com/0xposa/antigravity-termux
#
# Didesain khusus untuk pemula dan instalasi baru Termux tanpa PRoot Distro.
# Mengunduh langsung biner Android Bionic arm64 resmi dari Google.
# ==============================================================================

set -euo pipefail

# --- Warna Output ---
if [ -t 1 ]; then
    C_RESET="\033[0m"
    C_BOLD="\033[1m"
    C_GREEN="\033[1;32m"
    C_BLUE="\033[1;34m"
    C_CYAN="\033[1;36m"
    C_YELLOW="\033[1;33m"
    C_RED="\033[1;31m"
else
    C_RESET=""
    C_BOLD=""
    C_GREEN=""
    C_BLUE=""
    C_CYAN=""
    C_YELLOW=""
    C_RED=""
fi

log_info() {
    echo -e "${C_CYAN}➜${C_RESET} ${1}"
}

log_success() {
    echo -e "${C_GREEN}✔${C_RESET} ${C_BOLD}${1}${C_RESET}"
}

log_warn() {
    echo -e "${C_YELLOW}⚠${C_RESET} ${C_YELLOW}${1}${C_RESET}"
}

log_error() {
    echo -e "${C_RED}✖ ${1}${C_RESET}" >&2
}

# --- Banner Tampilan ---
print_banner() {
    clear 2>/dev/null || true
    echo -e "${C_BLUE}====================================================${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}   Google Antigravity CLI — Termux Native Installer  ${C_RESET}"
    echo -e "${C_BLUE}====================================================${C_RESET}"
    echo -e "   ${C_BOLD}Official Android Release | Zero PRoot Distro${C_RESET}"
    echo -e "   Repository: ${C_CYAN}https://github.com/0xposa/antigravity-termux${C_RESET}"
    echo -e "${C_BLUE}----------------------------------------------------${C_RESET}"
    echo ""
}

print_banner

# --- 1. Validasi Lingkungan & Arsitektur ---
log_info "Memeriksa lingkungan sistem..."

IS_TERMUX=false
if [ -n "${PREFIX:-}" ] && [ -d "${PREFIX:-}" ] && [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=true
fi

# Peringatan jika bukan Termux Native (misal dalam PRoot)
if [ "$IS_TERMUX" = false ]; then
    log_warn "Lingkungan Termux Native tidak terdeteksi secara langsung."
    if [ -f "/etc/debian_version" ] || [ -f "/etc/os-release" ]; then
        log_warn "Anda terdeteksi menjalankan skrip di dalam lingkungan Linux / PRoot Distro."
        log_warn "Skrip ini dioptimalkan khusus untuk lingkungan Native Termux (Android Bionic)."
        echo -e "Untuk Linux biasa/PRoot, Anda disarankan menggunakan:"
        echo -e "  ${C_GREEN}curl -fsSL https://antigravity.google/cli/install.sh | bash${C_RESET}"
        echo ""
        read -r -p "Tetap paksakan instalasi ke sistem ini? [y/N]: " proceed_anyway || true
        case "${proceed_anyway:-N}" in
            [yY][eE][sS]|[yY]) log_info "Melanjutkan instalasi atas permintaan pengguna..." ;;
            *) log_info "Instalasi dibatalkan."; exit 0 ;;
        esac
    fi
fi

# Cek Arsitektur CPU
ARCH="$(uname -m)"
case "$ARCH" in
    aarch64|arm64)
        PLATFORM_MANIFEST="android_arm64.json"
        ;;
    *)
        log_error "Arsitektur CPU '$ARCH' belum didukung."
        echo -e "Google saat ini hanya merilis biner resmi Android Bionic untuk ${C_BOLD}ARM64 (aarch64)${C_RESET}."
        exit 1
        ;;
esac

# Tentukan Direktori Target
if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX/bin" ]; then
    TARGET_DIR="$PREFIX/bin"
else
    TARGET_DIR="$HOME/.local/bin"
    mkdir -p "$TARGET_DIR"
fi

BINARY_PATH="$TARGET_DIR/antigravity"
SYMLINK_PATH="$TARGET_DIR/agy"

# --- 2. Cek & Auto-Install Ketergantungan Paket ---
log_info "Memeriksa paket pendukung (curl, tar, gzip, ca-certificates)..."

NEED_INSTALL=()
for cmd in curl tar gzip sha512sum; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        case "$cmd" in
            sha512sum) NEED_INSTALL+=("coreutils") ;;
            *) NEED_INSTALL+=("$cmd") ;;
        esac
    fi
done

if [ ${#NEED_INSTALL[@]} -gt 0 ]; then
    log_info "Memasang paket prasyarat secara otomatis: ${NEED_INSTALL[*]}..."
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq >/dev/null 2>&1 || true
        apt-get install -y -qq -o Dpkg::Options::="--force-confnew" "${NEED_INSTALL[@]}" >/dev/null 2>&1 || {
            if command -v pkg >/dev/null 2>&1; then
                pkg install -y "${NEED_INSTALL[@]}"
            fi
        }
    elif command -v pkg >/dev/null 2>&1; then
        pkg install -y "${NEED_INSTALL[@]}"
    else
        log_error "Tidak menemukan package manager (pkg / apt-get). Silakan pasang: ${NEED_INSTALL[*]}"
        exit 1
    fi
fi

log_success "Semua paket pendukung siap."

# --- 3. Ambil Metadata Rilis Resmi Google ---
DOWNLOAD_BASE_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app"
MANIFEST_URL="$DOWNLOAD_BASE_URL/manifests/$PLATFORM_MANIFEST"

log_info "Mengambil informasi versi resmi dari Google Cloud..."
MANIFEST_JSON=$(curl -fsSL "$MANIFEST_URL" 2>/dev/null || true)

if [ -z "$MANIFEST_JSON" ]; then
    log_error "Gagal menghubungi server rilis resmi Google."
    echo -e "Silakan periksa koneksi internet Anda atau coba beberapa saat lagi."
    exit 1
fi

# POSIX-Compliant JSON parsing (tanpa ketergantungan jq)
parse_json_key() {
    local payload="$1"
    local key="$2"
    echo "$payload" | sed -n 's/.*"'"$key"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

VERSION=$(parse_json_key "$MANIFEST_JSON" "version")
PAYLOAD_URL=$(parse_json_key "$MANIFEST_JSON" "url")
EXPECTED_SHA512=$(parse_json_key "$MANIFEST_JSON" "sha512")

if [ -z "$PAYLOAD_URL" ] || [ -z "$EXPECTED_SHA512" ]; then
    log_error "Gagal memproses data manifes resmi."
    exit 1
fi

log_success "Versi resmi terbaru terdeteksi: v$VERSION"

# --- 4. Unduh & Verifikasi Keamanan (SHA-512) ---
STAGING_DIR="$HOME/.cache/antigravity/staging"
mkdir -p "$STAGING_DIR"

PAYLOAD_FILE="$STAGING_DIR/cli_android_arm64.tar.gz"
EXTRACTED_FILE="$STAGING_DIR/antigravity"

cleanup() {
    rm -f "$PAYLOAD_FILE" "$EXTRACTED_FILE" 2>/dev/null || true
}
trap cleanup EXIT

log_info "Mengunduh paket biner resmi dari Google Storage..."
echo -e "${C_BLUE}URL: $PAYLOAD_URL${C_RESET}"
echo ""

if ! curl -# -L -o "$PAYLOAD_FILE" "$PAYLOAD_URL"; then
    log_error "Gagal mengunduh biner Antigravity CLI."
    exit 1
fi

log_info "Memverifikasi integritas biner (SHA-512 Checksum)..."
ACTUAL_SHA512=$(sha512sum "$PAYLOAD_FILE" | awk '{print $1}' || true)

if [ "$ACTUAL_SHA512" != "$EXPECTED_SHA512" ]; then
    log_error "Peringatan Keamanan: Checksum SHA-512 tidak cocok!"
    echo -e "File kemungkinan rusak atau tidak lengkap saat diunduh. Instalasi dibatalkan demi keamanan."
    exit 1
fi

log_success "Verifikasi SHA-512 berhasil (100% Asli & Aman)."

# --- 5. Ekstraksi & Pemasangan Biner ---
log_info "Mengekstrak dan memasang biner ke sistem..."

tar -xzf "$PAYLOAD_FILE" -C "$STAGING_DIR" antigravity
mv -f "$EXTRACTED_FILE" "$BINARY_PATH"
chmod 755 "$BINARY_PATH"

# Buat symlink 'agy' agar langsung dapat dipanggil
ln -sf "$BINARY_PATH" "$SYMLINK_PATH"

# Sediakan juga symlink di ~/.local/bin jika pengguna memiliki script yang mencarinya di sana
if [ "$TARGET_DIR" != "$HOME/.local/bin" ]; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$BINARY_PATH" "$HOME/.local/bin/agy"
fi

# Jalankan inisialisasi resmi dari biner agy jika didukung
log_info "Menginisialisasi konfigurasi CLI..."
"$SYMLINK_PATH" install >/dev/null 2>&1 || true

log_success "Pemasangan Google Antigravity CLI berhasil!"

# --- 6. Rekomendasi Fitur Termux untuk Pemula ---
# Cek Izin Penyimpanan
if [ "$IS_TERMUX" = true ] && [ ! -d "$HOME/storage" ] && command -v termux-setup-storage >/dev/null 2>&1; then
    echo ""
    log_info "Penyimpanan Android belum dihubungkan ke Termux."
    echo -e "Apakah Anda ingin menghubungkan penyimpanan internal (/sdcard) sekarang?"
    echo -e "(Ini berguna agar Antigravity CLI dapat membaca proyek Anda di memori HP)."
    read -r -p "Jalankan 'termux-setup-storage'? [Y/n]: " setup_storage || true
    case "${setup_storage:-Y}" in
        [nN][oO]|[nN])
            log_info "Dilewati. Anda dapat menjalankannya nanti dengan: ${C_BOLD}termux-setup-storage${C_RESET}"
            ;;
        *)
            termux-setup-storage || true
            ;;
    esac
fi

# --- 7. Panduan Penggunaan ---
echo ""
echo -e "${C_GREEN}====================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}   🎉 SELAMAT! ANTIGRAVITY CLI SIAP DIGUNAKAN!      ${C_RESET}"
echo -e "${C_GREEN}====================================================${C_RESET}"
echo -e "Lokasi Biner : ${C_BOLD}$SYMLINK_PATH${C_RESET}"
echo -e "Versi Aktif  : ${C_BOLD}v$VERSION (Official Native Android)${C_RESET}"
echo ""
echo -e "${C_BOLD}Cara Memulai (Sangat Mudah):${C_RESET}"
echo -e "  1. Ketik perintah:  ${C_CYAN}${C_BOLD}agy${C_RESET}"
echo -e "  2. Buka link login Google yang muncul di browser Anda."
echo -e "  3. Kembali ke Termux, dan asisten AI Anda siap bekerja!"
echo ""
echo -e "${C_BOLD}Perintah Berguna Lainnya:${C_RESET}"
echo -e "  • Keluar dari CLI   : Tekan ${C_YELLOW}Ctrl + D${C_RESET} dua kali, atau ketik ${C_YELLOW}/exit${C_RESET}"
echo -e "  • Cek Versi         : ${C_CYAN}agy --version${C_RESET}"
echo -e "  • Bantuan Lengkap   : ${C_CYAN}agy --help${C_RESET}"
echo -e "  • Hapus / Uninstall : Jalankan skrip ${C_RED}uninstall.sh${C_RESET}"
echo -e "${C_GREEN}====================================================${C_RESET}"
echo ""
