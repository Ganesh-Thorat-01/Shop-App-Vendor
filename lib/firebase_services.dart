import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_vendor/provider/product_provider.dart';

class FirebaseServices {
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference vendor =
      FirebaseFirestore.instance.collection('vendor');
  final CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference mainCategories =
      FirebaseFirestore.instance.collection('mainCategories');
  final CollectionReference subCategories =
      FirebaseFirestore.instance.collection('subCategories');
  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String> uploadImage(XFile? file, String? reference) async {
    File _file = File(file!.path);
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref(reference);

    await ref.putFile(_file);

    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }


  Future<List> uploadFiles({List<XFile>? images,String? ref,ProductProvider? provider}) async{
    var imageUrls=await Future.wait(images!.map((_image) => uploadFile(
      image: File(_image.path),
      reference: ref
    )));

    provider!.getFormData(
      imageUrls: imageUrls);

    return imageUrls;
  }

  Future uploadFile({File? image,String? reference}) async{
    firebase_storage.Reference storageReference=storage.ref().child('$reference/${DateTime.now().microsecondsSinceEpoch}');
    firebase_storage.UploadTask uploadTask=storageReference.putFile(image!);
    await uploadTask;
    return storageReference.getDownloadURL();
  }

  Future<void> addVendor({Map<String, dynamic>? data}) {
    // Call the user's CollectionReference to add a new user
    return vendor
        .doc(user!.uid)
        .set(data)
        .then((value) => print("Vendor Added"));
        
  }

  Future<void> saveToDb({Map<String, dynamic>? data,BuildContext? context}) {
    // Call the user's CollectionReference to add a new user
    return products
        .add(data)
        .then((value) => scaffold(context, 'Product Saved'));
        
  }


  

  /*

  Future<void> saveToDb({BuildContext? context,CollectionReference? collection,Map<String, dynamic>? data}) {
    // Call the user's CollectionReference to add a new user
    return collection!
        .add(data)
        .then((value) => scaffold(context, 'This product is saved'))
        .catchError((error) => scaffold(context, "Failed to save Product: $error"));
  }
*/
  String formattedDate(date) {
    var outputFormat = DateFormat('dd/MM/yyyy hh:mm aa');
    var outputDate = outputFormat.format(date);
    return outputDate;
  }

  String formattedNumber(number){
    var f=NumberFormat('##,##,###');
    String formattedNumber=f.format(number);
    return formattedNumber;
  }

  Widget formField(
      {String? label,
      TextInputType? inputType,
      void Function(String)? onChanged,
      int? minLine,
      int? maxLine}) {
    return TextFormField(
      keyboardType: inputType,
      decoration: InputDecoration(
        label: Text(label!),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return label;
        }
        return null;
      },
      onChanged: onChanged,
      minLines: minLine,
      maxLines: maxLine,
    );
  }

   scaffold(context,message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
        },
      ),
    ));
  }
}
