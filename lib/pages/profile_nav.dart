import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:journey2/constants.dart';

//Functions
class Rider {
  String username;
  String profileImg;
  String bio;
  String riderType;
  String prompt;
  String PostsNum;
  String FriendsNum;

  Rider({
    required this.username,
    required this.profileImg,
    required this.bio,
    required this.riderType,
    required this.prompt,
    required this.PostsNum,
    required this.FriendsNum,
  });
}

Future<Rider> getUser(userKey) async {
  print("GetUser Called: " + userKey);
  var user;

  //Handle the postsNum instance
  QuerySnapshot tempPostsNum = await FirebaseFirestore.instance
      .collection("posts")
      .where('userkey', isEqualTo: userKey)
      .get();
  int postsNum = tempPostsNum.size;

  //Handle LegacyNum Instance
  QuerySnapshot tempLegacyNum = await FirebaseFirestore.instance
      .collection("users")
      .doc(userKey)
      .collection("Legacies")
      .get();
  int legacyNum = tempLegacyNum.size;

  //Handle FriendsNum Instance
  QuerySnapshot tempFriendsNum = await FirebaseFirestore.instance
      .collection("users")
      .doc(userKey)
      .collection("Friends")
      .get();
  int FriendsNum = tempFriendsNum.size;

  //Handle FriendsNum Instance
  QuerySnapshot tempRunesNum = await FirebaseFirestore.instance
      .collection("users")
      .doc(userKey)
      .collection("Runes")
      .get();
  int RunesNum = tempRunesNum.size;

  //Handle First instance
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userKey)
      .get()
      .then((doc) {
    user = Rider(
      username: doc.data()!['displayName'],
      profileImg: doc.data()!['photoURL'],
      bio: doc.data()!['bio'],
      prompt: doc.data()!['prompt'],
      PostsNum: postsNum.toString(),
      FriendsNum: FriendsNum.toString(),
      riderType: doc.data()!['riderType'],
    );
  }).whenComplete(() {
    print("Data Collected!!");
  });

  print("User Created");
  print(user.username);
  print(user.profileImg);
  return user;
}

// ignore: must_be_immutable
class ProfileNavBarHeader extends StatefulWidget
    implements PreferredSizeWidget {
  @override
  _ProfileAppBarState createState() => _ProfileAppBarState();

  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ProfileAppBarState extends State<ProfileNavBarHeader> {
  //Firebase Variables
  var userID = FirebaseAuth.instance.currentUser?.uid;
  var userEmail = FirebaseAuth.instance.currentUser?.email;
  var profileImg = FirebaseAuth.instance.currentUser!.photoURL;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AppBar(
      elevation: 1,
      automaticallyImplyLeading: false,
      backgroundColor: kBackgroundColor,
      flexibleSpace: SafeArea(
        child: FutureBuilder(
          future: getUser(userID),
          builder: (context, AsyncSnapshot<Rider> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("LOADING USER INFO");
              return Column(
                children: [
                  Center(child: CircularProgressIndicator()),
                ],
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              print("DONE LOADING USER INFO");
            } else {
              print("HERE>>>");
            }

            return Container(
                height: size.height * 0.3,
                padding: EdgeInsets.only(left: 0, right: 10, top: 0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: CircleAvatar(
                          radius: size.width * 0.3,
                          backgroundImage: NetworkImage(profileImg!),
                        ),
                      )
                    ],
                  ),
                ));
          },
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// //Hold
// Container(
//               padding: EdgeInsets.only(left: 0, right: 10, top: 0),
//               child: Column(
//                 children: <Widget>[
//                   Row(
//                     children: <Widget>[
//                       Spacer(),
//                       MaterialButton(
//                         onPressed: () {
//                           Navigator.push(context,
//                               MaterialPageRoute(builder: (context) {
//                             return Settings();
//                           }));
//                         },
//                         textColor: Color(0xff939FD8),
//                         child: Icon(
//                           Icons.menu,
//                           size: 29,
//                         ),
//                       )
//                     ],
//                   ),
//                   Row(
//                     children: <Widget>[
//                       Spacer(),
//                       Column(
//                         children: <Widget>[
//                           CircleAvatar(
//                             backgroundImage: NetworkImage(
//                                 "https://firebasestorage.googleapis.com/v0/b/obsidianrune-vuejs.appspot.com/o/RuiLogo.png?alt=media&token=2a00ea98-57ac-45ee-9da9-008127c19d2a"),
//                             radius: 30,
//                           ),
//                           Text(
//                             "Lord Atakora",
//                             style:
//                                 TextStyle(color: Color(0xff939FD8), fontSize: 35),
//                           ),
//                           Text(
//                             "Constant Development",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ],
//                       ),
//                       Spacer(),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 15,
//                   ),
//                   Row(children: <Widget>[
//                     Spacer(),
//                     Row(
//                       children: <Widget>[
//                         Container(
//                           height: 70,
//                           width: 70,
//                           decoration: BoxDecoration(
//                               color: Colors.blueGrey[700],
//                               borderRadius: BorderRadius.circular(10)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(children: <Widget>[
//                               Text(
//                                 "55",
//                                 style:
//                                     TextStyle(color: Colors.white, fontSize: 25),
//                               ),
//                               Text(
//                                 "Posts",
//                                 style:
//                                     TextStyle(color: Colors.white, fontSize: 12),
//                               ),
//                             ]),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 15,
//                         ),
//                         Container(
//                           height: 70,
//                           width: 70,
//                           decoration: BoxDecoration(
//                               color: Colors.blueGrey[700],
//                               borderRadius: BorderRadius.circular(10)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(children: <Widget>[
//                               Text(
//                                 "3",
//                                 style:
//                                     TextStyle(color: Colors.white, fontSize: 25),
//                               ),
//                               Text(
//                                 "Legacies",
//                                 style:
//                                     TextStyle(color: Colors.white, fontSize: 12),
//                               ),
//                             ]),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 15,
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) {
//                                   return ViewFriends();
//                                 },
//                               ),
//                             );
//                           },
//                           child: Container(
//                             height: 70,
//                             width: 70,
//                             decoration: BoxDecoration(
//                                 color: Colors.blueGrey[700],
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(children: <Widget>[
//                                 Text(
//                                   "1",
//                                   style: TextStyle(
//                                       color: Colors.white, fontSize: 25),
//                                 ),
//                                 Text(
//                                   "Friend",
//                                   style: TextStyle(
//                                       color: Colors.white, fontSize: 12),
//                                 ),
//                               ]),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 15,
//                         ),
//                         Container(
//                           height: 70,
//                           width: 70,
//                           decoration: BoxDecoration(
//                               color: Colors.blueGrey[700],
//                               borderRadius: BorderRadius.circular(10)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(children: <Widget>[
//                               Text(
//                                 "1",
//                                 style:
//                                     TextStyle(color: Colors.white, fontSize: 25),
//                               ),
//                               Text(
//                                 "Rune",
//                                 style:
//                                     TextStyle(color: Colors.white, fontSize: 12),
//                               ),
//                             ]),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Spacer(),
//                   ]),
//                 ],
//               )),