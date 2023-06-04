import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:handyman_finder/ui/progress_dialog.dart';

import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/widgets/handyman/handyman_drawer.dart';
import 'package:intl/intl.dart';

class HandymanBookingsScreen extends StatefulWidget {
  @override
  _HandymanBookingsScreenState createState() => _HandymanBookingsScreenState();
}

class _HandymanBookingsScreenState extends State<HandymanBookingsScreen> {
  Map<String, Map<String, dynamic>> bookings = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  void fetchDataFromFirebase() async {
    setState(() {
      if (mounted) {
        _loading = true;
      }
    });
    DatabaseReference handymanBookingsRef =
        FirebaseDatabase.instance.ref().child('bookings').child('handyman');

    String userId = currentFirebaseUser!.uid;

    DatabaseEvent snap = await handymanBookingsRef.child(userId).once();

    if (snap.snapshot.value != null) {
      Map<dynamic, dynamic> data = snap.snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        bookings = data.map((key, value) {
          String type = key;
          Map<String, dynamic> formattedBookings = {};

          // inspect(value);
          print(key);

          value.forEach((item, booking) {
            print(booking);

            formattedBookings[item] = booking;
          });

          return MapEntry(type, formattedBookings);
        });
      });

      if (mounted) {
        _loading = false;
      }
    }
  }

  String formattedDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String newDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return newDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Bookings'),
      ),
      drawer: Theme(
        data: Theme.of(context)
            .copyWith(canvasColor: Theme.of(context).colorScheme.primary),
        child: HandymanDrawer(
          firstName: userModelCurrentInfo!.firstName,
          email: userModelCurrentInfo!.email,
          // role: userModelCurrentInfo!.role,
        ),
      ),
      body: _loading
          ? ProgressDialog(
              message: "Loading",
            )
          : bookings.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('No bookings yet'),
                  ),
                )
              : ListView(
                  children: bookings.keys.map((day) {
                    return ExpansionTile(
                      title: Text(
                        day,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      children: bookings[day]!.values.map((
                        item,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["customerName"],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${formattedDate(item["time"])}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    ", ${item["address"]}",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                item["description"],
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item["phone"],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  Text(
                                    item["email"],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Divider()
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
    );
  }
}
