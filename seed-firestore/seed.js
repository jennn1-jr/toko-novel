// seed.js
// Script sekali jalan untuk memasukkan data novel ke Firestore
// Data sumber: novels.json (array novel lengkap)
// Firestore target: collection "novels"

const fs = require('fs');
const admin = require('firebase-admin');

// 1. Init Firebase Admin pakai service account
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// 2. Load data novels.json
const raw = fs.readFileSync('./novels.json', 'utf8');
const novels = JSON.parse(raw);

// 3. Helper opsional: normalisasi struktur biar rapi di Firestore
function toFirestoreDoc(novel) {
  return {
    title: novel.title,
    description: novel.description,
    isbn: novel.isbn,
    price: novel.price,
    published_at: novel.published_at, // bisa kamu ubah ke Timestamp kalau mau
    author: {
      author_id: novel.author.author_id,
      name: novel.author.name,
      bio: novel.author.bio,
    },
    publisher: {
      publisher_id: novel.publisher.publisher_id,
      name: novel.publisher.name,
      address: novel.publisher.address,
      contact_email: novel.publisher.contact_email,
    },
    inventory: {
      stock: novel.inventory.stock,
      last_update: novel.inventory.last_update,
    },
    genres: novel.genres.map((g) => ({
      genre_id: g.genre_id,
      name: g.name,
    })),
    ratings: novel.ratings.map((r) => ({
      user_id: r.user_id,
      rating: r.rating,
      created_at: r.created_at,
    })),
    reviews: novel.reviews.map((rv) => ({
      user_id: rv.user_id,
      review_text: rv.review_text,
      created_at: rv.created_at,
    })),
    favorites_by: novel.favorites_by, // array of user_id yang nge-favorite
    // metadata tambahan
    source_id: novel._id, // simpan _id asli dari dataset
    created_at_seed: new Date().toISOString(),
  };
}

// 4. Upload berurutan
async function seed() {
  console.log(`Seeding ${novels.length} novel...`);

  for (const novel of novels) {
    // strategy doc id:
    // - pakai _id dari sumber agar konsisten
    //   -> collection: novels
    //   -> doc id: "1", "2", "3", ...
    const docId = String(novel._id);

    const docData = toFirestoreDoc(novel);

    await db.collection('novels').doc(docId).set(docData);

    console.log(`OK -> novels/${docId} (${novel.title})`);
  }

  console.log('SELESAI.');
  process.exit(0);
}

// 5. Jalankan
seed().catch((err) => {
  console.error('GAGAL SEED:', err);
  process.exit(1);
});
