import 'package:flutter/material.dart';

class BookedSlotWidget extends StatelessWidget {
  final String address;
  final String handymanName;
  final VoidCallback onCancel;

  const BookedSlotWidget({
    required this.address,
    required this.handymanName,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address: $address',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Handyman Name: $handymanName'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCancel,
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
