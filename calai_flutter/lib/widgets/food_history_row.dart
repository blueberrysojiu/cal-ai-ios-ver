import 'dart:io';
import 'package:flutter/material.dart';
import '../models/food_item.dart';

/// A row widget that displays a food item in the history list.
/// Replicates the iOS FoodHistoryRow design from FoodHistoryView.swift
class FoodHistoryRow extends StatelessWidget {
  final FoodItem foodItem;

  const FoodHistoryRow({
    super.key,
    required this.foodItem,
  });

  /// Formats time from DateTime (e.g., "12:30 PM")
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Image or fallback icon (60x60, rounded corners)
          _buildImage(),
          const SizedBox(width: 12),

          // Food name and calories
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodItem.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${foodItem.calories.toInt()} calories',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Time display
          Text(
            _formatTime(foodItem.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the image widget with fallback icon
  Widget _buildImage() {
    // Check if imagePath is not empty and file exists
    if (foodItem.imagePath.isNotEmpty) {
      final imageFile = File(foodItem.imagePath);
      if (imageFile.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            imageFile,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    // Fallback: gray icon (matches iOS "photo" system icon)
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.photo,
        size: 30,
        color: Colors.grey,
      ),
    );
  }
}
