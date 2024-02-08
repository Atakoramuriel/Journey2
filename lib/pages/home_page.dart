import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:journey2/pages/MapView.dart';
import 'package:journey2/pages/ProfileView.dart';
import 'package:journey2/pages/newPost.dart';
import 'package:journey2/pages/newRide.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

// Future getProfileImg() async {
//   var userID = FirebaseAuth.instance.currentUser?.uid;
//   String profileImg;
//   await FirebaseFirestore.instance
//       .collection("Riders")
//       .doc(userID)
//       .get()
//       .then((value) {
//         if(value.exists){
//           profileImg = value.data()?["profileImg"];
//         }

//   });
// }

class _HomePageState extends State<HomePage> {
  //Current User
  var userProfileImage = FirebaseAuth.instance.currentUser?.photoURL.toString();
  final User? user = Auth().currentUser;
  int currentTab = 3;
  final List<Widget> screens = [const MapView(), ProfileView()];
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = ProfileView();

  //Some functions
  Future<void> signOut() async {
    await Auth().signOut();
  }

  //Set up structure
  Widget _title() {
    return const Text("Ride Along");
  }

  Widget _userUid() {
    return Text(user?.email ?? 'user email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Some additional info required
    Size size = MediaQuery.of(context).size; //For screen size

    //For bottom nav

    return Scaffold(
      body: PageStorage(bucket: bucket, child: currentScreen),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            if (currentTab == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return NewRide();
                  },
                ),
              );

              print("Bring up New Ride option or Join Button");
            } else if (currentTab == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return NewPost();
                  },
                ),
              );
              print("Bring up New Post from Profile Page");
            }
          });
        },
        backgroundColor: Color.fromARGB(255, 0, 98, 255),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: Colors.purple[900],
        child: Container(
          height: size.height * 0.07,
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MaterialButton(
                      minWidth: 30,
                      onPressed: () {
                        setState(() {
                          currentScreen = const MapView();
                          currentTab = 0;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            currentTab == 0 ? Icons.home : Icons.home_outlined,
                            size: 35,
                            color: currentTab == 0 ? Colors.amber : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.02,
                    ),
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          currentTab = 1;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            currentTab == 1
                                ? Icons.favorite
                                : Icons.favorite_outlined,
                            size: 35,
                            color: currentTab == 1 ? Colors.amber : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   width: size.width * 0.3,
                    // ),
                    Spacer(),
                    MaterialButton(
                        minWidth: 30,
                        onPressed: () {
                          setState(() {
                            currentTab = 2;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat,
                              size: 35,
                              color:
                                  currentTab == 2 ? Colors.amber : Colors.grey,
                            ),
                          ],
                        )),
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          // currentScreen = Profile();
                          currentScreen = ProfileView();
                          currentTab = 3;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon(
                          //   Icons.account_circle,
                          //   color: currentTab == 1 ? Colors.amber : Colors.blueGrey,
                          // ),
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(userProfileImage!),
                          ),
                        ],
                        //remove beloow

                        //end of removal
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
