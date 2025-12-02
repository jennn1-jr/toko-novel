import 'package:flutter/material.dart';
import 'package:tokonovel/models/book_model.dart';
import 'package:tokonovel/services/firestore_service.dart';

class AddEditNovelDialog extends StatefulWidget {
  final BookModel? book;

  const AddEditNovelDialog({Key? key, this.book}) : super(key: key);

  @override
  _AddEditNovelDialogState createState() => _AddEditNovelDialogState();
}

class _AddEditNovelDialogState extends State<AddEditNovelDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _genreIdController;
  late TextEditingController _isbnController;
  late TextEditingController _publisherController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
    _descController = TextEditingController(text: widget.book?.description ?? '');
    _priceController = TextEditingController(text: widget.book?.price?.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.book?.imageUrl ?? '');
    _genreIdController = TextEditingController(text: widget.book?.genreId ?? '');
    _isbnController = TextEditingController(text: widget.book?.isbn ?? '');
    _publisherController = TextEditingController(text: widget.book?.publisher ?? 'Kelompok 4');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _genreIdController.dispose();
    _isbnController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      // Generate slug only if adding a new book or if slug was not present
      final String generatedSlug = _titleController.text
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '-')
          .replaceAll(RegExp(r'[^\w-]'), '');

      final bookData = BookModel(
        id: widget.book?.id ?? '',
        title: _titleController.text,
        author: _authorController.text,
        description: _descController.text,
        price: int.tryParse(_priceController.text),
        imageUrl: _imageUrlController.text,
        genreId: _genreIdController.text,
        slug: widget.book?.slug ?? generatedSlug, // Use existing slug or generated one
        publisher: _publisherController.text,
        isbn: _isbnController.text,
        
        // Preserve existing fields not edited by the form
        format: widget.book?.format,
        sourceUrl: widget.book?.sourceUrl,
        rating: widget.book?.rating,
        voters: widget.book?.voters,
        createdAt: widget.book?.createdAt,
      );

      try {
        if (widget.book == null) {
          // Add new book
          await _firestoreService.addBook(bookData);
        } else {
          // Update existing book
          await _firestoreService.updateBook(bookData);
        }
        Navigator.of(context).pop(); // Close dialog on success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving book: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.book == null ? 'Tambah Novel Baru' : 'Edit Novel'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField(controller: _titleController, label: 'Judul'),
                _buildTextFormField(controller: _authorController, label: 'Penulis'),
                _buildTextFormField(controller: _descController, label: 'Deskripsi', maxLines: 3),
                _buildTextFormField(controller: _priceController, label: 'Harga', isNumber: true),
                _buildTextFormField(controller: _imageUrlController, label: 'URL Gambar'),
                _buildTextFormField(controller: _genreIdController, label: 'Genre ID'),
                _buildTextFormField(controller: _isbnController, label: 'ISBN'),
                _buildTextFormField(controller: _publisherController, label: 'Penerbit'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          if (isNumber && int.tryParse(value) == null) {
            return 'Mohon masukkan angka yang valid';
          }
          return null;
        },
      ),
    );
  }
}