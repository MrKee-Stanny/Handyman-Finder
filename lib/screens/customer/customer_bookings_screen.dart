import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:handyman_finder/ui/progress_dialog.dart';
import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/widgets/customer/customer_drawer.dart';

class CustomerBookingsScreen extends StatefulWidget {
  @override
  _CustomerBookingsScreenState createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  Map<String, Map<String, dynamic>> bookings = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  void fetchDataFromFirebase() async {
    setState(() {
      _loading = true;
    });
    DatabaseReference customerBookingsRef =
        FirebaseDatabase.instance.ref().child('bookings').child('customer');

    String userId = currentFirebaseUser!.uid;

    DatabaseEvent snap = await customerBookingsRef.child(userId).once();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Bookings'),
      ),
      drawer: Theme(
        data: Theme.of(context)
            .copyWith(canvasColor: Theme.of(context).colorScheme.primary),
        child: CustomerDrawer(
          firstName: userModelCurrentInfo!.firstName,
          email: userModelCurrentInfo!.email,
          // role: userModelCurrentInfo!.role,
        ),
      ),
      body: _loading
          ? ProgressDialog(
              message: "Loading, please wait...",
            )
          : bookings.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('You have not made bookings yet'),
                  ),
                )
              : ListView(
                  children: bookings.keys.map((day) {
                    return ExpansionTile(
                      title: Text(day,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
                                item["handymanName"],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                item["address"],
                                style: TextStyle(
                                    fontStyle: FontStyle.italic, fontSize: 14),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                item["description"],
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                item["time"],
                                style: TextStyle(fontSize: 14),
                                textAlign: TextAlign.end,
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
