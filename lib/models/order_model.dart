import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokonovel/models/book_model.dart'; // Assuming you have a Book model

class OrderItem {
  final String bookId;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;

  OrderItem({
    required this.bookId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      bookId: data['bookId'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: (data['quantity'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final String? id; // Document ID
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String shippingAddress;
  final DateTime orderDate;
  String status; // e.g., 'pending', 'packaging', 'shipping', 'completed'

  OrderModel({
    this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.orderDate,
    this.status = 'pending',
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      shippingAddress: data['shippingAddress'] ?? '',
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? totalAmount,
    String? shippingAddress,
    DateTime? orderDate,
    String? status,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
    );
  }
}