import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingWidget extends StatefulWidget {
  Function handleSubmit;

  BookingWidget({
    required this.handleSubmit,
  });

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  List<DateTime> _hourSlots = [];
  List<DateTime> _availableSlots = [];
  DateFormat timeFormatter = DateFormat('HH:mm');
  final _addressController = TextEditingController(text: "");
  final _descriptionController = TextEditingController(text: "");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Address',
          ),
        ),
        SizedBox(
            height:
                10), // Add spacing between the TextFormField and the list tiles
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description',
          ),
        ),
        SizedBox(
            height:
                10), // Add spacing between the TextFormField and the list tiles

        ElevatedButton(
          onPressed: () {
            widget.handleSubmit(
              _addressController.text,
              _descriptionController.text,
            );
          },
          child: Text('Book'),
        ),
      ],
    ));
  }
}
