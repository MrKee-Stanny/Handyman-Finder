import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:handyman_finder/ui/progress_dialog.dart';
import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/widgets/customer/booking_widget.dart';
import 'package:intl/intl.dart';

class HandymanProfile extends StatefulWidget {
  final Map<dynamic, dynamic> handyman;
  const HandymanProfile(this.handyman);

  @override
  State<HandymanProfile> createState() => _HandymanProfileState();
}

class _HandymanProfileState extends State<HandymanProfile> {
  List _imageUrlList = [];
  bool _loadingImages = false;
  bool _isBooking = false;
  List<DateTime> _bookedSlots = [];
  DateTime _selectedDate = DateTime.now();
  String address = "";

  loadGallery() async {
    setState(() {
      _loadingImages = true;
    });
    final ref = FirebaseStorage.instance
        .ref()
        .child(widget.handyman['uid'])
        .child('gallery');

    final result = await ref.listAll();

    for (final item in result.items) {
      final url = await item.getDownloadURL();
      final path = item.fullPath;
      _imageUrlList.add(url);
    }
    setState(() {
      if (mounted) {
        _loadingImages = false;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadGallery();
  }

  @override
  void dispose() {
    super.dispose();
  }

  handleSubmit(
      String address, String description, DateTime selectedDate) async {
    setState(() {
      _isBooking = true;
      _selectedDate = selectedDate;
    });
    DatabaseReference handymanBookingsRef =
        FirebaseDatabase.instance.ref().child('bookings').child('handyman');
    DatabaseReference customerBookingsRef =
        FirebaseDatabase.instance.ref().child('bookings').child('customer');

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print(formattedDate);

    Map<String, dynamic> handymanMap = {
      "time": _selectedDate.toIso8601String(),
      "customerName":
          "${userModelCurrentInfo!.firstName} ${userModelCurrentInfo!.lastName}",
      "userId": currentFirebaseUser!.uid,
      "phone": "${userModelCurrentInfo!.phone}",
      "email": "${userModelCurrentInfo!.email}",
      "address": address,
      "description": description,
      "status": "Pending"
    };

    Map<String, dynamic> customerMap = {
      "time": _selectedDate.toIso8601String(),
      "handymanName": "${widget.handyman["businessName"]}",
      "handymanId": widget.handyman['uid'],
      "address": address,
      "description": description,
      "status": "Pending"
    };

    // Perform the handyman booking
    final handymanBookingRef =
        handymanBookingsRef.child(widget.handyman['uid']).child(now).push();
    await handymanBookingRef.set(handymanMap);

    // Retrieve the generated ID of the handyman booking
    final handymanBookingId = handymanBookingRef.key;

    // Add the handyman booking ID to the customer map
    customerMap["handymanBookingId"] = handymanBookingId;

    // Perform the customer booking
    final customerBookingRef =
        customerBookingsRef.child(currentFirebaseUser!.uid).child(now).push();
    await customerBookingRef.set(customerMap);

    // Retrieve the generated ID of the customer booking
    final customerBookingId = customerBookingRef.key;

    // Update the handyman object with the customer booking ID
    final handymanRef = handymanBookingsRef
        .child(widget.handyman['uid'])
        .child(now)
        .child(handymanBookingId!)
        .child('customerBookingId');
    await handymanRef.set(customerBookingId);

    Fluttertoast.showToast(msg: 'Booked successfully!');

    setState(() {
      if (mounted) {
        _isBooking = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          titleSpacing: 0.0, title: Text(widget.handyman['businessName'])),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _imageUrlList.isNotEmpty
                        ? NetworkImage(_imageUrlList[0])
                        : widget.handyman['displayPhotoUrl'] != ""
                            ? NetworkImage(widget.handyman['displayPhotoUrl'])
                            : AssetImage('assets/images/handyman.jpg')
                                as ImageProvider<Object>,
                    fit: BoxFit.cover,
                  ),
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey),
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.black.withOpacity(0.8),
                    ),
                    Positioned(
                      bottom: 25,
                      left: 0,
                      right: 0,
                      child: CustomPaint(
                        painter: MyPainter(),
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: SizedBox(
                              width: 150,
                              height: 150,
                              child: widget.handyman['displayPhotoUrl'] != ""
                                  ? Image.network(
                                      widget.handyman['displayPhotoUrl'],
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/dark-logo.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${widget.handyman['firstName']} ${widget.handyman['lastName']}",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${widget.handyman['skill']}",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            Duration(days: 30),
                          ),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.deepPurple,
                                  onPrimary: Colors.white,
                                  surface: Colors.grey,
                                  onSurface: Colors.black,
                                ),
                                dialogBackgroundColor: Colors.white,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (selectedDate != null) {
                          // Show available slots for booking
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Booking Details',
                                ),
                                content: _isBooking
                                    ? Container(
                                        height: 100,
                                        child: ProgressDialog(
                                          message: 'Booking, please wait...',
                                        ),
                                      )
                                    : Container(
                                        width: double.maxFinite * 0.9,
                                        child: BookingWidget(
                                          handleSubmit: (address, description) {
                                            handleSubmit(address, description,
                                                selectedDate);
                                            Navigator.of(context)
                                                .pop(); // Dismiss the dialog
                                          },
                                        ),
                                      ),
                              );
                            },
                          );
                        }
                      },
                      child: Text('Book'),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red),
                        // Text("Available")
                        Text(widget.handyman['address'])
                      ],
                    )
                  ],
                ),
              ),

              // Image grid
              if (_imageUrlList.length == 0 && !_loadingImages)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No images uploaded yet!',
                        style: TextStyle(
                          fontSize: 20,
                        )),
                  ),
                ),

              Divider(
                thickness: 1,
              ),

              SizedBox(
                height: 300,
                child: GridView.builder(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                  itemCount: _imageUrlList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: _imageUrlList[index],
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final left = Offset(0, size.height / 2);
    final right = Offset(size.width, size.height / 2);

    canvas.drawLine(center, left, paint);
    canvas.drawLine(center, right, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
