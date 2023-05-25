import 'package:flutter/material.dart';
import 'package:shop_app_vendor/widget/custom_drawer.dart';
import 'package:shop_app_vendor/widget/products/published_product.dart';
import 'package:shop_app_vendor/widget/products/un_published.dart';

class ProductScreen extends StatelessWidget {
  static const String id='product-screen';
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Product List"),
          elevation: 0,
          bottom: const TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 6,
                color:Colors.deepOrange
              ),
            ),
            tabs: [
              Tab(
                child: Text('Un Published'),
              ),
              Tab(
                child: Text("Published"),
              ),
            ],
          ),
        ),
        drawer: const CustomDrawer(),
        body: TabBarView(
          children: [
            UnPublishedProduct(),
            PublishedProduct(),
          ]),
      ),
    );
  }
}