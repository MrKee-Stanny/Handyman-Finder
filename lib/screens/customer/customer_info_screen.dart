import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:handyman_finder/ui/handyman_chip.dart';
import 'package:handyman_finder/ui/progress_dialog.dart';
import 'package:handyman_finder/utils/global.dart';
import 'package:handyman_finder/widgets/customer/customer_drawer.dart';

import 'package:handyman_finder/widgets/customer/handyman_card.dart';

class CustomerInfoScreen extends StatefulWidget {
  const CustomerInfoScreen({Key? key}) : super(key: key);

  @override
  State<CustomerInfoScreen> createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends State<CustomerInfoScreen> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  List _handymenList = [];
  List<String> _selectedChips = [];
  bool _loading = false;

  void getData() async {
    setState(() {
      _loading = true;
    });
    databaseReference.child('users').once().then((DatabaseEvent snapshot) {
      if (snapshot.snapshot.value != null) {
        _handymenList.clear();
        Map<dynamic, dynamic> values =
            snapshot.snapshot.value as Map<Object?, Object?>;
        values.forEach((key, value) async {
          value['uid'] = key;
          if (value['role'] == 'Handyman' &&
              (_selectedChips.isEmpty ||
                  _selectedChips.contains(value['skill']))) {
            _handymenList.add(value);
          }
        });
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      backgroundColor: Colors.white,
      //------------------Paavo----------------------------
      drawer: Theme(
        data: Theme.of(context)
            .copyWith(canvasColor: Theme.of(context).colorScheme.primary),
        child: CustomerDrawer(
          firstName: userModelCurrentInfo!.firstName,
          email: userModelCurrentInfo!.email,
          // role: userModelCurrentInfo!.role,
        ),
      ),
      //-------------------Paavo------------------------------
      body: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Handyman Finder!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Browse our list of expert handymen!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // HandymanChip(
                //     selectedChips: _selectedChips,
                //     getData: getData,
                //     skill: "Electrician"),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedChips.contains('Electrician')) {
                        _selectedChips.remove('Electrician');
                      } else {
                        _selectedChips.add('Electrician');
                      }
                      getData();
                    });
                  },
                  child: Chip(
                    label: Text('Electricians'),
                    backgroundColor: _selectedChips.contains('Electrician')
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                        : Colors.transparent,
                    labelStyle: TextStyle(
                      color: _selectedChips.contains('Electrician')
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: _selectedChips.contains('Electrician')
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: _selectedChips.contains('Electrician')
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8)
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedChips.contains('Plumber')) {
                        _selectedChips.remove('Plumber');
                      } else {
                        _selectedChips.add('Plumber');
                      }
                      getData();
                    });
                  },
                  child: Chip(
                    label: Text('Plumbers'),
                    backgroundColor: _selectedChips.contains('Plumber')
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                        : Colors.transparent,
                    labelStyle: TextStyle(
                      color: _selectedChips.contains('Plumber')
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: _selectedChips.contains('Plumber')
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: _selectedChips.contains('Plumber')
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8)
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedChips.contains('Gardener')) {
                        _selectedChips.remove('Gardener');
                      } else {
                        _selectedChips.add('Gardener');
                      }
                      getData();
                    });
                  },
                  child: Chip(
                    label: Text('Gardeners'),
                    backgroundColor: _selectedChips.contains('Gardener')
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                        : Colors.transparent,
                    labelStyle: TextStyle(
                      color: _selectedChips.contains('Gardener')
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: _selectedChips.contains('Gardener')
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: _selectedChips.contains('Gardener')
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8)
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedChips.contains('Carpenter')) {
                        _selectedChips.remove('Carpenter');
                      } else {
                        _selectedChips.add('Carpenter');
                      }
                      getData();
                    });
                  },
                  child: Chip(
                    label: Text('Carpenters'),
                    backgroundColor: _selectedChips.contains('Carpenter')
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                        : Colors.transparent,
                    labelStyle: TextStyle(
                      color: _selectedChips.contains('Carpenter')
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: _selectedChips.contains('Carpenter')
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: _selectedChips.contains('Carpenter')
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8)
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedChips.contains('Cleaner')) {
                        _selectedChips.remove('Cleaner');
                      } else {
                        _selectedChips.add('Cleaner');
                      }
                      getData();
                    });
                  },
                  child: Chip(
                    label: Text('Cleaners'),
                    backgroundColor: _selectedChips.contains('Cleaner')
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                        : Colors.transparent,
                    labelStyle: TextStyle(
                      color: _selectedChips.contains('Cleaner')
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: _selectedChips.contains('Cleaner')
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: _selectedChips.contains('Cleaner')
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8)
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          if (_loading)
            ProgressDialog(
              message: "Loading, please wait...",
            ),
          if (_handymenList.isNotEmpty)
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(_handymenList.length,
                    (index) => HandymanCard(handyman: _handymenList[index])),
              ),
            )
        ],
      ),
    );
  }
}
