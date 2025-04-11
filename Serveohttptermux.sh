#!/data/data/com.termux/files/usr/bin/bash

BOT_TOKEN="7450852198:AAEJrO8y3gqaWFECOW87VtOpOtx13_WwrXg"
CHAT_ID="8107240151"

while true; do
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo "[+] Koneksi tersedia, jalankan Serveo"

        # Jalankan SSH Serveo di background dan simpan log-nya
        ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 serveo.net > serveo_log.txt 2>&1 &
        SSH_PID=$!

        # Tunggu beberapa detik agar log terisi
        sleep 5

        # Ambil URL Serveo dari log
        URL=$(grep -m 1 -o "https://[a-zA-Z0-9]*\.serveo.net" serveo_log.txt)

        if [ -n "$URL" ]; then
            echo "[+] Serveo URL ditemukan: $URL"
            curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
                -d chat_id=$CHAT_ID \
                -d text="Serveo aktif: $URL"
        else
            echo "[!] Serveo URL tidak ditemukan."
        fi

        echo "[!] Menunggu Serveo mati..."
        wait $SSH_PID

        echo "[!] Serveo disconnected, ulangi..."
    else
        echo "[!] Tidak ada koneksi internet. Coba lagi 10 detik..."
        sleep 10
    fi
done
