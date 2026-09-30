// Hook UserPromptSubmit: menilai tingkat kesulitan prompt (heuristik sederhana)
// lalu menyuntikkan saran routing ke Claude. Tidak memanggil API, gratis dan cepat.
// Hook tidak bisa mengganti model secara langsung; ia hanya memberi petunjuk
// agar Claude mendelegasikan ke subagent quick-task atau deep-task.
let raw = "";
process.stdin.on("data", (d) => (raw += d));
process.stdin.on("end", () => {
  let prompt = "";
  try {
    prompt = String(JSON.parse(raw).prompt || "");
  } catch (e) {
    return; // input tak terbaca: diam saja
  }
  const text = prompt.toLowerCase().trim();
  if (!text || text.startsWith("/")) return; // abaikan slash command

  const deep = [
    "bug", "error", "debug", "kenapa gagal", "tidak jalan", "root cause", "penyebab",
    "refactor", "arsitektur", "architecture", "rancang", "desain sistem", "design",
    "security", "keamanan", "vulnerab", "performance", "performa", "optimasi", "optimize",
    "migrasi", "migration", "investigasi", "investigate", "seluruh proyek", "semua file",
    "multi-file", "race condition", "memory leak",
  ];
  const quick = [
    "cari file", "cari di", "find file", "rename", "ganti nama", "format", "rapikan",
    "baca file", "tampilkan", "list ", "daftar file", "apa isi", "buka file", "jalankan",
    "cek versi", "ls ", "typo",
  ];

  const hasDeep = deep.some((k) => text.includes(k));
  const hasQuick = quick.some((k) => text.includes(k));
  const length = text.length;

  let level = "medium";
  if (hasDeep || length > 600) level = "hard";
  else if (hasQuick && length < 200) level = "easy";

  if (level === "medium") return; // tugas menengah: tanpa saran, Claude utama mengerjakan

  const note =
    level === "hard"
      ? "[Auto-routing] Prompt ini terdeteksi SULIT (debugging/arsitektur/refactor/keamanan/performa). Delegasikan pekerjaan utamanya ke subagent `deep-task` lewat Agent tool, kecuali ini sebenarnya pertanyaan singkat yang bisa dijawab langsung."
      : "[Auto-routing] Prompt ini terdeteksi RINGAN (pencarian/edit kecil/perintah tunggal). Delegasikan ke subagent `quick-task` lewat Agent tool, kecuali kamu bisa menjawab langsung tanpa memakai tool.";

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: { hookEventName: "UserPromptSubmit", additionalContext: note },
    })
  );
});
