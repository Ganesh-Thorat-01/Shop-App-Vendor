import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/vendor_model.dart';
import '../screens/registration_screen.dart';
import '../screens/login_screen.dart';
import '../firebase_services.dart';
import '../screens/home_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
      stream: _services.vendor.doc(_services.user!.uid).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.data!.exists) {
          return const RegistrationScreen();
        }
        Vendor vendor=Vendor.fromJson(snapshot.data!.data() as Map<String,dynamic>);
        if(vendor.approved==true){
          return HomeScreen();
        }
        return Center(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width:80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: vendor.logo!,
                    placeholder: (context,url)=>Container(
                        height:100,
                        width:100,
                        color:Colors.grey.shade300,
                    ),
                    ),
                ),
              ),
              SizedBox(height: 10,),
              Text(vendor.businessName!,style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              const Text(
                'Your application sent to Shop App\n Admin will contact you soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey
                ),
              ),
              OutlinedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ))),
                  onPressed: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const LoginScreen(),
                        ),
                      );
                    });
                  },
                  child: const Text("Sign Out"))
            ],
          ),
        )
        );
      },
    ));
  }
}

/*
Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your application sent to Shop App\n Admin will contact you soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            OutlinedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ))),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const LoginScreen(),
                      ),
                    );
                  });
                },
                child: const Text("Sign Out"))
          ],
        ),
      )),
*/