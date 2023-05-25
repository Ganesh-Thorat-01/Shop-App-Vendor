import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:shop_app_vendor/widget/products/product_details_screen.dart';

import '../../firebase_services.dart';
import '../../model/product_model.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    Key? key,
    this.snapshot,
  }) : super(key: key);

  final FirestoreQueryBuilderSnapshot? snapshot;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  List<Product> _productList = [];

  @override
  void initState() {
    getProductList();
    super.initState();
  }

  getProductList() {
    widget.snapshot!.docs.forEach((element) {
      Product product = element.data();
      setState(() {
        _productList.add(Product(
            taxValue: product.taxValue,
            reOrderLevel: product.reOrderLevel,
            approved: product.approved,
            regularPrice: product.regularPrice,
            salesPrice: product.salesPrice,
            taxStatus: product.taxStatus,
            mainCategory: product.mainCategory,
            subCategory: product.subCategory,
            size: product.size,
            description: product.description,
            scheduleDate: product.scheduleDate,
            sku: product.sku,
            manageInventory: product.manageInventory,
            soh: product.soh,
            chargeShipping: product.chargeShipping,
            shippingCharge: product.shippingCharge,
            brand: product.brand,
            otherDetails: product.otherDetails,
            unit: product.unit,
            imageUrls: product.imageUrls,
            seller: product.seller,
            productName: product.productName,
            category: product.category,
            productId: element.id
            ));
      });
    });
  }

  Widget _products() {
    FirebaseServices services = FirebaseServices();
    return ListView.builder(
        itemCount: widget.snapshot!.docs.length,
        itemBuilder: (context, index) {
          Product product = widget.snapshot!.docs[index].data();
          String id = widget.snapshot!.docs[index].id;
          var discount = (product.regularPrice! - product.salesPrice!) /
              product.regularPrice! *
              100;
          return Slidable(
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ProductDetailsScreen(
                        product: product,
                        productId: id,
                      ),
                    ));
              },
              child: Card(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            CachedNetworkImage(imageUrl: product.imageUrls![0]),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.productName!),
                        Row(
                          children: [
                            if (product.salesPrice != null)
                              Text(
                                  services.formattedNumber(product.salesPrice)),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              services.formattedNumber(product.regularPrice),
                              style: TextStyle(
                                  decoration: product.salesPrice != null
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: Colors.red),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '${discount.toInt()}%',
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ),
            endActionPane: ActionPane(motion: const ScrollMotion(), children: [
              SlidableAction(
                flex: 1,
                onPressed: (context) {
                  //services.products.doc(id).delete();
                },
                backgroundColor: Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
              SlidableAction(
                flex: 1,
                onPressed: (context) {
                  services.products.doc(id).update(
                      {'approved': product.approved == false ? true : false});
                },
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.approval,
                label: product.approved == false ? 'Approve' : 'Inactive',
              ),
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseServices services = FirebaseServices();
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    onTap: () {
                      showSearch(
                        context: context,
                        delegate: SearchPage<Product>(
                          items: _productList,
                          searchLabel: 'Search product',
                          suggestion: _products(),
                          failure: const Center(
                            child: Text('No product found :('),
                          ),
                          filter: (product) => [
                            product.productName,
                            product.category,
                            product.mainCategory,
                            product.subCategory
                          ],
                          builder: (product) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ProductDetailsScreen(
                                        product: product,
                                        productId: product.productId,
                                      ),
                                    )).whenComplete(() {
                                      setState(() {
                                        _productList.clear();
                                        getProductList();
                                      });
                                    });
                              },
                              child: Card(
                                  child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height: 80,
                                      width: 80,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CachedNetworkImage(
                                            imageUrl: product.imageUrls![0]),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(product.productName!),
                                        Row(
                                          children: [
                                            if (product.salesPrice != null)
                                              Text(services.formattedNumber(
                                                  product.salesPrice)),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              services.formattedNumber(
                                                  product.regularPrice),
                                              style: TextStyle(
                                                  decoration:
                                                      product.salesPrice != null
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : null,
                                                  color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                            ),
                          ),
                        ),
                      );
                    },
                    decoration: InputDecoration(
                        hintText: "Search products",
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.only(
                            bottom: 10, left: 10, right: 10),
                        fillColor: Colors.white,
                        filled: true,
                        border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(4))),
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey.shade400,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Total products : ${widget.snapshot!.docs.length}'),
                    ),
                  ),
                  Expanded(child: _products()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
