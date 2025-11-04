/**
 * seed_book_tambahan.js
 * Seed tambahan 5 buku ke Firestore (collection: 'books')
 * - Format mengikuti data books kamu (genre_id, sku, slug, title, image_url, description, author, publisher, isbn, price, published_date, format, source_url)
 * - DocID = slug (idempotent/upsert)
 *
 * Cara pakai:
 * 1) npm i firebase-admin
 * 2) Siapkan kredensial service account: serviceAccount.json (Firebase Admin SDK)
 * 3) node seed_book_tambahan.js
 */

const admin = require("firebase-admin");

// ====== CONFIG FIREBASE ADMIN ======
try {
  admin.initializeApp({
    credential: admin.credential.cert(require("./serviceAccount.json")),
  });
} catch (e) {
  console.error("Gagal init Firebase Admin. Pastikan serviceAccount.json ada.", e);
  process.exit(1);
}

const db = admin.firestore();

// ====== DATA SEED ======
// Catatan: genre_id diset "1" (Fantasi) agar konsisten & aman untuk tampil di kategori default.
// Silakan ganti sesuai mapping genre di tabel `genres` kamu bila perlu.
const books = [
  {
    genre_id: "1",
    sku: "900100001",
    slug: "laskar-pelangi-edisi-50",
    title: "Laskar Pelangi (Edisi ke-50)",
    image_url: "https://cdn.gramedia.com/uploads/items/laskarpelangi.jpg",
    description:
      "Ikal, Lintang, Mahar, dan kawan-kawan dari SD Muhammadiyah Gantong kembali mengajarkan bahwa harapan bisa tumbuh di tanah yang paling sederhana. Dalam edisi ke-50 yang istimewa ini, kisah perjuangan anak-anak Belitung menghadapi keterbatasan ekonomi, stigma sosial, dan fasilitas yang serba minim dituturkan dengan hangat namun tajam. Ikal menyadari bahwa mimpi tidak selalu datang lewat jalan lebar; terkadang ia menyelinap dari celah-celah dinding sekolah yang retak, dari perahu kecil di sungai keruh, atau dari papan tulis yang catnya mengelupas. Satu per satu ujian datang—mulai dari ancaman penutupan sekolah, kompetisi melawan sekolah favorit, hingga pergulatan batin tiap anak dengan rasa takut dan percaya diri. Namun, persahabatan dan keberanian membuat mereka menolak menyerah, dan guru-guru sederhana yang penuh dedikasi menjadi mercusuar kecil yang tak padam di tengah angin kencang. Edisi ini juga merangkum refleksi perjalanan Laskar Pelangi sebagai ikon literasi yang menyalakan semangat belajar hingga jauh melampaui Belitung, menegaskan bahwa pendidikan adalah tangga yang tak pernah selesai didaki.\n\nPernahkah Anda terpikir betapa menariknya dunia yang terbuka lebar lewat lembaran buku? Membaca bukan hanya kegiatan rutin, tetapi juga petualangan tak terbatas ke dalam imajinasi dan pengetahuan. Membaca mengasah pikiran, membuka wawasan, dan memperkaya kosakata. Ini adalah pintu menuju dunia di luar kita yang tak terbatas. Tetapkan waktu khusus untuk membaca setiap hari. Dari membaca sebelum tidur hingga menyempatkan waktu di pagi hari, kebiasaan membaca dapat dibentuk dengan konsistensi. Pilih buku sesuai minat dan level literasi. Mulailah dengan buku yang sesuai dengan keinginan dan kemampuan membaca. Temukan tempat yang tenang dan nyaman untuk membaca. Lampu yang cukup, kursi yang nyaman, dan sedikit musik pelataran bisa menciptakan pengalaman membaca yang lebih baik. Buat catatan atau jurnal tentang buku yang telah Anda baca. Tuliskan pemikiran, kesan, dan pelajaran yang Anda dapatkan.",
    author: "Andrea Hirata",
    publisher: "Bentang Pustaka",
    isbn: "9786028811705",
    price: "99000",
    published_date: null,
    format: "soft-cover",
    source_url: "",
    created_at: null,
    updated_at: null,
  },
  {
    genre_id: "1",
    sku: "900100002",
    slug: "dilan-dia-adalah-dilanku-tahun-1990",
    title: "Dilan: Dia adalah Dilanku Tahun 1990",
    image_url: "https://cdn.gramedia.com/uploads/items/dilan1990.jpg",
    description:
      "Bandung, 1990. Jalanan basah selepas hujan dan udara yang tajam oleh wangi tanah menuntun Milea pada seorang remaja nyentrik bernama Dilan—pemimpin geng motor yang lebih suka merangkai kata-kata aneh ketimbang mengancam dengan tinju. Cerita ini menelusuri hari-hari mereka yang ganjil sekaligus manis: surat-surat pendek dengan ejaan jenaka, telepon umum yang minta koin receh, angkot yang berdesak-desakan, dan kecanggungan remaja yang sulit mengaku rindu. Saat konflik antar-geng memanas, Milea belajar bahwa keberanian tidak selalu bising; kadang ia berupa kesediaan menunggu, memaafkan, atau sekadar duduk di kursi taman sambil berbagi keheningan. Dilan yang sembrono namun peka membawa Milea memahami bahwa cinta remaja punya cara sendiri untuk memahat ingatan. Dengan humor khas dan dialog yang akrab, kisah ini menawarkan nostalgia yang membuat pembaca tersenyum sekaligus meringis—sebuah potret masa muda yang rapuh namun tak terlupakan.\n\nPernahkah Anda terpikir betapa menariknya dunia yang terbuka lebar lewat lembaran buku? Membaca bukan hanya kegiatan rutin, tetapi juga petualangan tak terbatas ke dalam imajinasi dan pengetahuan. Membaca mengasah pikiran, membuka wawasan, dan memperkaya kosakata. Ini adalah pintu menuju dunia di luar kita yang tak terbatas. Tetapkan waktu khusus untuk membaca setiap hari. Dari membaca sebelum tidur hingga menyempatkan waktu di pagi hari, kebiasaan membaca dapat dibentuk dengan konsistensi. Pilih buku sesuai minat dan level literasi. Mulailah dengan buku yang sesuai dengan keinginan dan kemampuan membaca. Temukan tempat yang tenang dan nyaman untuk membaca. Lampu yang cukup, kursi yang nyaman, dan sedikit musik pelataran bisa menciptakan pengalaman membaca yang lebih baik. Buat catatan atau jurnal tentang buku yang telah Anda baca. Tuliskan pemikiran, kesan, dan pelajaran yang Anda dapatkan.",
    author: "Pidi Baiq",
    publisher: "Pastel Books",
    isbn: "9786027870413",
    price: "89000",
    published_date: null,
    format: "soft-cover",
    source_url: "",
    created_at: null,
    updated_at: null,
  },
  {
    genre_id: "1",
    sku: "900100003",
    slug: "solo-leveling",
    title: "Solo Leveling",
    image_url: "https://cdn.gramedia.com/uploads/items/sololeveling.jpg",
    description:
      "Sung Jin-Woo dikenal sebagai hunter E-rank paling lemah—nyaris menjadi beban di setiap raid, selalu berada di garis paling belakang, dan selangkah lagi menyerah. Namun, sebuah insiden di dungeon ganda mengubah segalanya: sebuah ‘Sistem’ misterius memberinya misi harian, penalti maut, dan hadiah peningkatan atribut yang tak dimiliki hunter lain. Dari sit-up yang tak putus hingga pertarungan solo melawan monster, Jin-Woo mendaki levelnya sendirian, mengasah ketenangan dan kejamnya perhitungan. Dunia pun bergeser: guild-guild raksasa mulai memperhatikannya, dungeon tak stabil bermunculan, dan rahasia kelam tentang hubungan manusia–monster tersibak perlahan. Dengan pace aksi yang kencang, pertarungan strategis, dan transformasi karakter yang memuaskan, Solo Leveling bukan hanya tentang menjadi kuat, melainkan tentang menuntaskan hutang pada diri sendiri—membuktikan bahwa batasan yang paling keras sering kali kita ciptakan sendiri.\n\nPernahkah Anda terpikir betapa menariknya dunia yang terbuka lebar lewat lembaran buku? Membaca bukan hanya kegiatan rutin, tetapi juga petualangan tak terbatas ke dalam imajinasi dan pengetahuan. Membaca mengasah pikiran, membuka wawasan, dan memperkaya kosakata. Ini adalah pintu menuju dunia di luar kita yang tak terbatas. Tetapkan waktu khusus untuk membaca setiap hari. Dari membaca sebelum tidur hingga menyempatkan waktu di pagi hari, kebiasaan membaca dapat dibentuk dengan konsistensi. Pilih buku sesuai minat dan level literasi. Mulailah dengan buku yang sesuai dengan keinginan dan kemampuan membaca. Temukan tempat yang tenang dan nyaman untuk membaca. Lampu yang cukup, kursi yang nyaman, dan sedikit musik pelataran bisa menciptakan pengalaman membaca yang lebih baik. Buat catatan atau jurnal tentang buku yang telah Anda baca. Tuliskan pemikiran, kesan, dan pelajaran yang Anda dapatkan.",
    author: "Chugong",
    publisher: "D&C Media",
    isbn: "9786230401238",
    price: "150000",
    published_date: null,
    format: "soft-cover",
    source_url: "",
    created_at: null,
    updated_at: null,
  },
  {
    genre_id: "1",
    sku: "900100004",
    slug: "seporsi-mie-ayam-sebelum-mati",
    title: "Seporsi Mie Ayam Sebelum Mati",
    image_url: "https://cdn.gramedia.com/uploads/items/mieayamsebelummati.jpg",
    description:
      "Di sebuah gang sempit yang kerap terlewat, berdiri gerobak mie ayam yang hanya buka menjelang tengah malam. Konon, semangkuk mie di situ mampu menajamkan ingatan—membuat orang-orang menatap ulang keputusan yang pernah mereka ambil, baik yang disesali maupun yang disyukuri. Lewat kisah-kisah yang saling berkelindan—seorang perantau yang rindu pulang, peretas yang mencari tebusan, seorang ibu yang menimbang ulang amarah, serta anak yang takut melupakan nama ayahnya—buku ini mengajak pembaca duduk di bangku plastik, memegang sumpit, dan menatap uap yang naik dari kuah. Setiap suapan memanggil kenangan, setiap sruput menguji keberanian untuk jujur pada diri sendiri. Dengan bahasa yang hangat, getir, sekaligus jenaka, antologi ini menyoal kesempatan kedua dan kebiasaan manusia menunda kata ‘maaf’—hingga mendadak waktu menjadi barang mewah yang sukar dibeli.\n\nPernahkah Anda terpikir betapa menariknya dunia yang terbuka lebar lewat lembaran buku? Membaca bukan hanya kegiatan rutin, tetapi juga petualangan tak terbatas ke dalam imajinasi dan pengetahuan. Membaca mengasah pikiran, membuka wawasan, dan memperkaya kosakata. Ini adalah pintu menuju dunia di luar kita yang tak terbatas. Tetapkan waktu khusus untuk membaca setiap hari. Dari membaca sebelum tidur hingga menyempatkan waktu di pagi hari, kebiasaan membaca dapat dibentuk dengan konsistensi. Pilih buku sesuai minat dan level literasi. Mulailah dengan buku yang sesuai dengan keinginan dan kemampuan membaca. Temukan tempat yang tenang dan nyaman untuk membaca. Lampu yang cukup, kursi yang nyaman, dan sedikit musik pelataran bisa menciptakan pengalaman membaca yang lebih baik. Buat catatan atau jurnal tentang buku yang telah Anda baca. Tuliskan pemikiran, kesan, dan pelajaran yang Anda dapatkan.",
    author: "—",
    publisher: "Gramedia Pustaka Utama",
    isbn: "9786020629193",
    price: "75000",
    published_date: null,
    format: "soft-cover",
    source_url: "",
    created_at: null,
    updated_at: null,
  },
  {
    genre_id: "1",
    sku: "900100005",
    slug: "the-lord-of-the-rings-kembalinya-sang-raja-the-return-of-the-king",
    title: "The Lord Of The Rings: Kembalinya Sang Raja (The Return Of The King)",
    image_url: "https://cdn.gramedia.com/uploads/items/lotr-returnking.jpg",
    description:
      "Bayang-bayang Mordor kian pekat saat Gondor menyiapkan diri menghadapi serbuan terakhir Sauron. Aragorn, pewaris takhta yang lama tersisih, dipaksa menimbang apakah keberanian pribadi cukup untuk menyalakan harapan seluruh negeri. Di jalur lain, Frodo dan Sam merayap menembus tanah tandus menuju Gunung Doom, ditemani Gollum yang licin—pemandu yang sama tak pastinya dengan nasib dunia. Pertempuran Minas Tirith meledak bagai badai, Rohirrim menunggang fajar, dan keputusan-keputusan kecil para tokoh—loyalitas, pengkhianatan, belas kasih—membentuk riak yang menentukan gelombang besar. Ini adalah penutup agung tentang persahabatan yang diuji habis-habisan, tentang beban kuasa yang harus dihancurkan agar tidak dimiliki siapa pun, dan tentang pulang—sebab bahkan pahlawan mesti kembali ke halaman rumah yang berubah.\n\nPernahkah Anda terpikir betapa menariknya dunia yang terbuka lebar lewat lembaran buku? Membaca bukan hanya kegiatan rutin, tetapi juga petualangan tak terbatas ke dalam imajinasi dan pengetahuan. Membaca mengasah pikiran, membuka wawasan, dan memperkaya kosakata. Ini adalah pintu menuju dunia di luar kita yang tak terbatas. Tetapkan waktu khusus untuk membaca setiap hari. Dari membaca sebelum tidur hingga menyempatkan waktu di pagi hari, kebiasaan membaca dapat dibentuk dengan konsistensi. Pilih buku sesuai minat dan level literasi. Mulailah dengan buku yang sesuai dengan keinginan dan kemampuan membaca. Temukan tempat yang tenang dan nyaman untuk membaca. Lampu yang cukup, kursi yang nyaman, dan sedikit musik pelataran bisa menciptakan pengalaman membaca yang lebih baik. Buat catatan atau jurnal tentang buku yang telah Anda baca. Tuliskan pemikiran, kesan, dan pelajaran yang Anda dapatkan.",
    author: "J.R.R. Tolkien",
    publisher: "HarperCollins",
    isbn: "9780261102378",
    price: "199000",
    published_date: null,
    format: "soft-cover",
    source_url: "",
    created_at: null,
    updated_at: null,
  },
];

// ====== HELPER ======
function nowIso() {
  return new Date().toISOString();
}

// Tambahkan created_at/updated_at jika null
const normalized = books.map((b) => ({
  ...b,
  created_at: b.created_at || nowIso(),
  updated_at: b.updated_at || nowIso(),
}));

(async () => {
  const col = db.collection("books");
  let ok = 0, fail = 0;

  for (const item of normalized) {
    try {
      const docId = item.slug;
      await col.doc(docId).set(item, { merge: true });
      ok++;
      console.log(`✔ upsert ${docId}`);
    } catch (e) {
      fail++;
      console.error(`✖ gagal upsert ${item.slug}`, e.message);
    }
  }

  console.log(`Selesai. Berhasil: ${ok}, Gagal: ${fail}`);
  process.exit(0);
})();
