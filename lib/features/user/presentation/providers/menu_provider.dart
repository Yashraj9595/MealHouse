import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mess_owner/domain/models/menu_model.dart';
import '../../../mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/core/di/service_locator.dart';

final menuProvider = FutureProvider.autoDispose.family<MenuModel?, String>((ref, messId) async {
  final repository = sl<MessRepository>();
  return await repository.getMenu(messId);
});

class CartItem {
  final MenuItemModel item;
  final int quantity;
  final String? selectedMealType;

  CartItem({required this.item, this.quantity = 1, this.selectedMealType});

  CartItem copyWith({MenuItemModel? item, int? quantity, String? selectedMealType}) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      selectedMealType: selectedMealType ?? this.selectedMealType,
    );
  }
}

class CartState {
  final Map<String, CartItem> items;
  final String? messId;

  CartState({this.items = const {}, this.messId});

  int get totalAmount => items.values.fold(0, (int sum, item) => sum + (item.item.price * item.quantity).toInt());
  int get totalCount => items.values.fold(0, (int sum, item) => sum + item.quantity);

  CartState copyWith({Map<String, CartItem>? items, String? messId}) {
    return CartState(
      items: items ?? this.items,
      messId: messId ?? this.messId,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState();
  }

  void addItem(MenuItemModel item, String messId, {int quantity = 1, String? selectedMealType}) {
    if (state.messId != null && state.messId != messId) {
      // Clear cart if adding from a different mess
      state = CartState(messId: messId, items: {
        item.name: CartItem(item: item, quantity: quantity, selectedMealType: selectedMealType),
      });
      return;
    }
 
    final items = Map<String, CartItem>.from(state.items);
    if (items.containsKey(item.name)) {
      items[item.name] = items[item.name]!.copyWith(
        quantity: items[item.name]!.quantity + quantity,
        selectedMealType: selectedMealType, // Update to latest selected if re-added
      );
    } else {
      items[item.name] = CartItem(item: item, quantity: quantity, selectedMealType: selectedMealType);
    }
    state = state.copyWith(items: items, messId: messId);
  }

  void removeItem(String itemName) {
    final items = Map<String, CartItem>.from(state.items);
    if (!items.containsKey(itemName)) return;

    if (items[itemName]!.quantity > 1) {
      items[itemName] = items[itemName]!.copyWith(
        quantity: items[itemName]!.quantity - 1,
      );
    } else {
      items.remove(itemName);
    }
    
    if (items.isEmpty) {
      state = CartState();
    } else {
      state = state.copyWith(items: items);
    }
  }

  void clearCart() {
    state = CartState();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});
