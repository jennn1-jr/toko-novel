// seed-firestore/seed_books_genres.js
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();

// helper: parse number aman
const toNumber = (v, d = 0) => {
  if (typeof v === 'number') return v;
  if (typeof v === 'string' && v.trim() !== '') {
    const n = Number(v);
    return Number.isFinite(n) ? n : d;
  }
  return d;
};

async function seedGenres(genresPath) {
  const raw = fs.readFileSync(genresPath, 'utf8');
  // file export phpMyAdmin biasanya array berisi beberapa objek.
  // Kita cari objek {type:'table', name:'genres', data:[...]}
  const arr = JSON.parse(raw);
  const table = arr.find(x => x.type === 'table' && x.name === 'genres');
  if (!table) throw new Error('genres table not found in JSON');
  const data = table.data;

  const batch = db.batch();
  for (const g of data) {
    const docId = String(g.id); // gunakan id angka sebagai string
    const ref = db.collection('genres').doc(docId);
    batch.set(ref, {
      name: g.name || '',
      slug: g.slug || '',
      created_at: g.created_at ? new Date(g.created_at) : admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
  }
  await batch.commit();
  console.log(`✅ Seeded ${data.length} genres`);
}

async function seedBooks(booksPath) {
  const raw = fs.readFileSync(booksPath, 'utf8');
  const arr = JSON.parse(raw);
  const table = arr.find(x => x.type === 'table' && x.name === 'books');
  if (!table) throw new Error('books table not found in JSON');
  const data = table.data;

  const BATCH_LIMIT = 450; // jaga-jaga di bawah 500 op
  let batch = db.batch();
  let countInBatch = 0;
  let total = 0;

  for (const b of data) {
    // pakai slug sebagai docId yang stabil; fallback ke sku
    const docId = (b.slug && String(b.slug)) || String(b.sku);
    const ref = db.collection('books').doc(docId);

    const payload = {
      sku: b.sku || null,
      slug: b.slug || null,
      title: b.title || '',
      image_url: b.image_url || '',
      description: b.description || '',
      author: b.author || '',
      publisher: b.publisher || '',
      isbn: b.isbn || '',
      price: toNumber(b.price, 0),
      published_date: b.published_date ? new Date(b.published_date) : null,
      format: b.format || '',
      source_url: b.source_url || '',
      // relasi genre: simpan id (string) & ref, biar query gampang
      genre_id: b.genre_id ? String(b.genre_id) : null,
      genre_ref: b.genre_id ? db.collection('genres').doc(String(b.genre_id)) : null,
      created_at: b.created_at && b.created_at !== '0000-00-00 00:00:00.000'
        ? new Date(b.created_at)
        : admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    };

    batch.set(ref, payload, { merge: true });
    countInBatch++; total++;

    if (countInBatch >= BATCH_LIMIT) {
      await batch.commit();
      console.log(`...committed ${total} books so far`);
      batch = db.batch();
      countInBatch = 0;
    }
  }

  if (countInBatch > 0) {
    await batch.commit();
  }
  console.log(`✅ Seeded ${total} books`);
}

(async () => {
  try {
    await seedGenres(path.join(__dirname, 'genres.json'));
    await seedBooks(path.join(__dirname, 'books.json'));
    console.log('🎉 All done');
    process.exit(0);
  } catch (e) {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  }
})();
