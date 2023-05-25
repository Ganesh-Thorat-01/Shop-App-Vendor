import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterfire_ui/firestore.dart';
import '../../firebase_services.dart';
import '../../model/product_model.dart';
import 'product_card.dart';

class UnPublishedProduct extends StatelessWidget {
  const UnPublishedProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return FirestoreQueryBuilder<Product>(
      query: productQuery(false),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return Center(child: const CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }

        if(snapshot.docs.isEmpty){
          return Center(
            child: Text('No Un Pulished Products'),
          );
        }
        return ProductCard(snapshot: snapshot,);
      },
    );
  }
}

