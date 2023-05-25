import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:shop_app_vendor/widget/products/product_card.dart';

import '../../firebase_services.dart';
import '../../model/product_model.dart';

class PublishedProduct extends StatelessWidget {
  const PublishedProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return FirestoreQueryBuilder<Product>(
      query: productQuery(true),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return Center(child: const CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }
        if(snapshot.docs.isEmpty){
          return Center(
            child: Text('No Products Pulished yet'),
          );
        }
        return ProductCard(snapshot: snapshot); 
        },
    );
  }
}