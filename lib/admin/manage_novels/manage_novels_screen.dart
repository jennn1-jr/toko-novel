import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:tokonovel/models/book_model.dart';
import 'package:tokonovel/services/firestore_service.dart';
import '../dashboard/components/header.dart';
import 'components/add_edit_novel_dialog.dart';

class ManageNovelsScreen extends StatelessWidget {
  const ManageNovelsScreen({Key? key}) : super(key: key);

  void _showAddEditDialog(BuildContext context, {BookModel? book}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEditNovelDialog(book: book);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Header(title: "Kelola Novel"),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16 * 1.5, vertical: 16),
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showAddEditDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah Novel Baru"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<BookModel>>(
              stream: firestoreService.getAllBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Belum ada novel."));
                }

                final books = snapshot.data!;
                final BookDataSource dataSource = BookDataSource(
                  books: books,
                  onEdit: (book) => _showAddEditDialog(context, book: book),
                  onDelete: (bookId) {
                    // Show confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Konfirmasi Hapus'),
                          content: const Text('Apakah Anda yakin ingin menghapus novel ini?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Batal'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                              onPressed: () async {
                                try {
                                  await firestoreService.deleteBook(bookId);
                                  Navigator.of(context).pop(); // Close confirmation dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Novel berhasil dihapus.'), backgroundColor: Colors.green),
                                  );
                                } catch (e) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal menghapus novel: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );

                return Container(
                   height: 600, // Explicit height for PaginatedDataTable2
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: const BorderRadius.all(Radius.circular(10)),
                       border: Border.all(color: Colors.grey.shade200),
                   ),
                  child: PaginatedDataTable2(
                    columnSpacing: 16,
                    minWidth: 600,
                    source: dataSource,
                    columns: const [
                      DataColumn(label: Text("Judul")),
                      DataColumn(label: Text("Penulis")),
                      DataColumn(label: Text("Harga")),
                      DataColumn(label: Text("Aksi")),
                    ],
                    rowsPerPage: 10,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BookDataSource extends DataTableSource {
  final List<BookModel> books;
  final Function(BookModel) onEdit;
  final Function(String) onDelete;

  BookDataSource({
    required this.books,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= books.length) {
      return null;
    }
    final book = books[index];
    return DataRow(cells: [
      DataCell(Text(book.title)),
      DataCell(Text(book.author)),
      DataCell(Text("Rp ${book.price ?? 0}")),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => onEdit(book),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(book.id),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => books.length;

  @override
  int get selectedRowCount => 0;
}
