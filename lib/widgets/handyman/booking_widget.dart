import 'package:flutter/material.dart';

class BookingWidget extends StatefulWidget {
  const BookingWidget({Key? key}) : super(key: key);

  @override
  _BookingWidgetState createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  bool _isAccepted = false;
  bool _isDone = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.check),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.close),
            ),
            SizedBox(width: 10),
            Text("Status"),
          ],
        ),
        if (_isAccepted)
          _isDone
              ? Text("Done")
              : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isDone = true;
                    });
                  },
                  child: Text("Save"),
                )
      ],
    );
  }
}
