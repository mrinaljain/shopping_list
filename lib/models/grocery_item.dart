import 'package:shopping_list/models/category.dart';

// class GroceryItem {
//   final String id;
//   final String name;
//   final int quantity;
//   final Category category;

//   const GroceryItem({
//     required this.id,
//     required this.name,
//     required this.quantity,
//     required this.category,
//   });
// }

class GroceryItem {
  final String id; // Unique identifier for the item
  final Category category; // Category of the item (e.g., "Vegetables")
  final String name; // Name of the item (e.g., "Tomato")
  final int quantity; // Quantity of the item (e.g., 2)

  // Constructor
 const GroceryItem({
    required this.id,
    required this.category,
    required this.name,
    required this.quantity,
  });

  // Factory constructor to create a GroceryItem from a JSON map
  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      category: json['category'],
      name: json['name'],
      quantity: json['quantity'],
    );
  }

  // Convert the GroceryItem to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'quantity': quantity,
    };
  }
}
