# Konfigurasi Claude Code Pribadi

Repo ini menyimpan pengaturan Claude Code supaya bisa dipasang dengan cepat di komputer mana pun. Tujuannya: **pemilihan model dan tingkat usaha berpikir (effort) berjalan otomatis sesuai tingkat kesulitan tugas**, tanpa perlu memilih manual setiap kali.

---

## 1. Apa yang dilakukan konfigurasi ini?

Claude Code belum punya mode "otomatis penuh" yang menilai kesulitan tiap perintah lalu memilih model sendiri. Konfigurasi ini mendekatinya dengan tiga lapis:

| Lapis | Cara kerja | Hasil |
|---|---|---|
| **Model `opusplan`** | Saat Claude merencanakan (plan mode), dipakai **Opus** (paling pintar). Saat mengerjakan, otomatis pindah ke **Sonnet** (lebih cepat dan hemat). | Perencanaan berkualitas, eksekusi efisien. |
| **Subagent `quick-task`** | Asisten khusus memakai **Haiku** dengan effort **low**. | Tugas ringan selesai cepat dan murah. |
| **Subagent `deep-task`** | Asisten khusus memakai **Opus** dengan effort **high**. | Tugas sulit dikerjakan dengan penalaran mendalam. |
| **Hook auto-routing** (`hooks/route-task.js`) | Setiap kamu mengirim prompt, skrip kecil menilai kesulitannya lewat kata kunci dan panjang prompt, lalu menyisipkan saran ke Claude: "ini SULIT, delegasikan ke `deep-task`" atau "ini RINGAN, delegasikan ke `quick-task`". Prompt menengah tidak diberi saran. | Ada penilai kesulitan otomatis, gratis, dan cepat (tanpa memanggil API). |
| **Aturan di `CLAUDE.md`** | Menyuruh Claude utama menyerahkan tugas ringan ke `quick-task`, tugas sulit ke `deep-task`, dan mengerjakan tugas menengah sendiri. | Pembagian tugas berjalan otomatis. |

Istilah singkat:
- **Model**: "otak" yang dipakai. Haiku = cepat dan murah, Sonnet = seimbang, Opus = paling kuat.
- **Effort**: seberapa keras model berpikir. Makin tinggi makin teliti, tapi makin lambat dan mahal.
- **Subagent**: asisten kecil yang dipanggil Claude untuk mengerjakan satu tugas dengan model dan effort miliknya sendiri.

### Batasan yang perlu diketahui
- Ini **bukan** deteksi kesulitan yang sempurna. Claude utama yang memutuskan kapan mendelegasikan, jadi kadang ia mengerjakan sendiri tugas yang seharusnya didelegasikan. Solusinya: tulis langsung, misalnya *"pakai deep-task untuk ini"*.
- Effort `auto` di Claude Code hanya berarti "pakai bawaan model", **bukan** menyesuaikan kesulitan. Karena itu effort tidak diatur di repo ini.
- Hook tidak bisa mengganti model atau effort secara langsung. Ia hanya memberi saran ke Claude, dan Claude yang memutuskan mengikutinya atau tidak.
- Penilaian hook memakai kata kunci sederhana (mis. `bug`, `refactor`, `keamanan` = sulit; `cari file`, `rename` = ringan), jadi bisa keliru. Kamu bisa menyunting daftar kata di `hooks/route-task.js`.

---

## 2. Isi repo

| File / folder | Fungsi |
|---|---|
| `agents/quick-task.md` | Definisi subagent untuk tugas ringan (Haiku, effort low). |
| `agents/deep-task.md` | Definisi subagent untuk tugas sulit (Opus, effort high). |
| `hooks/route-task.js` | Hook penilai kesulitan prompt (butuh Node.js). |
| `CLAUDE.md` | Aturan routing tugas untuk Claude utama. |
| `install.ps1` | Skrip pemasang otomatis untuk Windows. |
| `README.md` | Dokumen ini. |

Repo ini **tidak** berisi `settings.json` lengkap, kredensial, atau data proyek apa pun.

---

## 3. Cara memasang di perangkat baru (Windows)

### Prasyarat
1. **Claude Code** sudah terpasang.
2. **Git** sudah terpasang (cek dengan mengetik `git --version` di PowerShell).
2b. **Node.js** sudah terpasang (cek dengan `node --version`). Dibutuhkan untuk hook auto-routing.
3. Login GitHub di perangkat itu, karena repo ini **private**. Cara termudah: instal GitHub CLI lalu jalankan `gh auth login`. Saat `git clone`, Windows juga bisa memunculkan jendela login GitHub.

### Langkah
1. Buka **PowerShell**.
2. Unduh repo:
   ```
   git clone https://github.com/kvnlhm/claude-config
   ```
3. Jalankan pemasang:
   ```
   powershell -ExecutionPolicy Bypass -File claude-config\install.ps1
   ```
4. Jika muncul tulisan **"Selesai"**, **tutup lalu buka ulang Claude Code**. Perubahan baru terbaca di sesi baru.

### Apa yang dilakukan `install.ps1`?
- Menyalin `quick-task.md` dan `deep-task.md` ke `C:\Users\<nama-kamu>\.claude\agents\`.
- **Menambahkan** aturan routing ke `CLAUDE.md` yang sudah ada, tanpa menghapus isi lamanya. Jika `CLAUDE.md` belum ada, file dibuat baru. Kalau aturannya sudah pernah ditambahkan, tidak akan ditambah dua kali.
- Menyalin `route-task.js` ke `.claudehooks`.
- Mengubah `settings.json` hanya untuk dua hal: `"model": "opusplan"` dan mendaftarkan hook `UserPromptSubmit`. Pengaturan lain tetap.
- Sebelum mengubah `CLAUDE.md` dan `settings.json`, skrip membuat cadangan `CLAUDE.md.bak` dan `settings.json.bak` di folder yang sama.

Skrip aman dijalankan berulang kali.

---

## 4. Cara memastikan sudah aktif

Di sesi Claude Code yang baru:
- Ketik `/model`. Harus tertulis **Opus in plan mode, else Sonnet**.
- Ketik `/agents`. Harus terlihat `quick-task` dan `deep-task`.
- Ketik `/hooks`. Harus ada hook `UserPromptSubmit` yang menjalankan `route-task.js`.
- Coba prompt "cari file config.php". Claude seharusnya memakai `quick-task`.

---

## 5. Cara memakai sehari-hari

Kamu tidak perlu berbuat apa-apa. Cukup beri tugas seperti biasa. Kalau ingin memaksa:
- *"Pakai quick-task untuk mengganti nama file ini."*
- *"Pakai deep-task untuk mencari penyebab bug ini."*

---

## 6. Cara mengubah konfigurasi

Contoh: ingin `quick-task` memakai Sonnet, bukan Haiku.
1. Buka `agents/quick-task.md` dan ubah baris `model: haiku` menjadi `model: sonnet`.
2. Nilai `model` yang bisa dipakai: `haiku`, `sonnet`, `opus`, atau `inherit` (ikut model sesi utama).
3. Nilai `effort` yang bisa dipakai: `low`, `medium`, `high`, `xhigh`, `max`.
4. Simpan ke GitHub:
   ```
   git add .
   git commit -m "Ubah model quick-task"
   git push
   ```
5. Di perangkat lain: `git pull`, lalu jalankan `install.ps1` lagi.

Catatan: mengubah file di folder repo **tidak otomatis** mengubah folder `C:\Users\<nama-kamu>\.claude\`. Jalankan `install.ps1` setelahnya agar perubahan tersalin.

---

## 7. Cara mengembalikan ke semula

- Hapus `quick-task.md` dan `deep-task.md` dari `C:\Users\<nama-kamu>\.claude\agents\`.
- Pulihkan `CLAUDE.md` dan `settings.json` dari file `.bak`, atau ketik `/model` di Claude Code lalu pilih model lain.

---

## 8. Pemecahan masalah

| Masalah | Penyebab dan solusi |
|---|---|
| `git clone` meminta login atau gagal "not found" | Repo private. Login dulu dengan akun GitHub pemiliknya (`gh auth login`). |
| Muncul "running scripts is disabled" | Jalankan skrip dengan tambahan `-ExecutionPolicy Bypass` seperti pada langkah 3. |
| Subagent tidak muncul di `/agents` | Claude Code belum dibuka ulang. Tutup total lalu buka lagi. |
| Model tidak berubah | Cek `settings.json` di folder `.claude`. Harus ada baris `"model": "opusplan"`. Atau ketik `/model opusplan`. |
| Hook tidak jalan | Pastikan Node.js terpasang (`node --version`). Tes manual: `echo {"prompt":"debug error login"} | node hooksoute-task.js` harus mengeluarkan teks JSON berisi `Auto-routing`. |
| Claude tidak mendelegasikan tugas otomatis | Wajar, lihat bagian Batasan. Panggil agent secara langsung. |
| `settings.json` tampak rusak setelah instalasi | Salin `settings.json.bak` kembali menjadi `settings.json`. |

---

## 9. Keamanan

Repo ini private dan hanya berisi file konfigurasi. Jangan menambahkan kunci API, kata sandi, atau isi `settings.json` yang memuat informasi proyek ke repo ini.
