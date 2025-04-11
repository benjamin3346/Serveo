#!/data/data/com.termux/files/usr/bin/bash

BOT_TOKEN="7450852198:AAEJrO8y3gqaWFECOW87VtOpOtx13_WwrXg"
CHAT_ID="8107240151"

while true; do
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo "[+] Koneksi tersedia, jalankan Serveo"

        ssh -o StrictHostKeyChecking=no -R 0:localhost:8022 serveo.net > serveo_log.txt 2>&1 &
        SSH_PID=$!

        sleep 5

        # Coba ambil subdomain HTTPS
        HTTPS_URL=$(grep -m 1 -o "https://[a-zA-Z0-9]*\.serveo.net" serveo_log.txt)

        # Coba ambil port TCP forwarding (untuk SSH)
        TCP_URL=$(grep -m 1 -o "serveo.net:[0-9]*" serveo_log.txt)

        if [ -n "$HTTPS_URL" ]; then
            echo "[+] HTTPS URL ditemukan: $HTTPS_URL"
            curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
                -d chat_id=$CHAT_ID \
                -d text="Serveo HTTPS aktif: $HTTPS_URL"
        fi

        if [ -n "$TCP_URL" ]; then
            echo "[+] TCP Forward ditemukan: $TCP_URL"
            curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
                -d chat_id=$CHAT_ID \
                -d text="Serveo TCP aktif: $TCP_URL (forward ke localhost:8022)"
        fi

        if [ -z "$HTTPS_URL" ] && [ -z "$TCP_URL" ]; then
            echo "[!] Tidak ada URL Serveo ditemukan."
        fi

        echo "[!] Menunggu Serveo mati..."
        wait $SSH_PID

        echo "[!] Serveo disconnected, ulangi..."
    else
        echo "[!] Tidak ada koneksi internet. Coba lagi 10 detik..."
        sleep 10
    fi
done
