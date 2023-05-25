import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shop_app_vendor/firebase_services.dart';
import 'package:shop_app_vendor/model/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? product;
  final String? productId;
  const ProductDetailsScreen({this.product, this.productId, Key? key})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final FirebaseServices _services = FirebaseServices();
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  bool _editable = true;
  final _productName = TextEditingController();
  final _brand = TextEditingController();
  final _salesPrice = TextEditingController();
  final _regularPrice = TextEditingController();
  final _description = TextEditingController();
  final _soh = TextEditingController();
  final _reorderLevel = TextEditingController();
  final _shippingCharge = TextEditingController();
  final _otherDetails = TextEditingController();
  final _sizeText = TextEditingController();

  String? taxStatus;
  String? taxAmount;
  DateTime? scheduledDate;
  bool? manageInventory;
  bool? chargeShipping;
  List _sizeList = [];
  bool _addList = false;

  Widget _taxStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: taxStatus,
      hint: const Text(
        'Tax status',
        style: TextStyle(fontSize: 16),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          taxStatus = value!;
        });
      },
      items: ['Taxable', 'Non Taxable']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Select tax status';
        }
      },
    );
  }

  Widget _taxAmount() {
    return DropdownButtonFormField<String>(
      value: taxAmount,
      hint: const Text(
        'Tax amount',
        style: TextStyle(fontSize: 16),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          taxAmount = value!;
        });
      },
      items:
          ['GST-10%', 'GST-12%'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Select tax amount';
        }
      },
    );
  }

  Widget _textField(
      {TextEditingController? controller,
      String? label,
      TextInputType? inputType,
      String? Function(String?)? validator,}) {
    return TextFormField(
        minLines: null,
        maxLines: null,
        controller: controller,
        keyboardType: inputType,
        validator: validator ?? (value) {
                if (value!.isEmpty) {
                  return 'Enter $label';
                }
              },
          );
  }

  updateProduct() {
    EasyLoading.show();
    _services.products.doc(widget.productId).update({
      'brand': _brand.text,
      'productName': _productName.text,
      'description': _description.text,
      'otherDetails': _otherDetails.text,
      'salesPrice': int.parse(_salesPrice.text),
      'regularPrice':int.parse( _regularPrice.text),
      'size': _sizeList,
      'taxStatus': taxStatus,
      'taxValue': taxAmount == 'GST-10%' ? 10.00 : 12.00,
      'manageInventory': manageInventory,
      'soh': int.parse(_soh.text),
      'reOrderLevel': int.parse(_reorderLevel.text),
      'chargeShipping': chargeShipping,
      'shippingCharge': int.parse(_shippingCharge.text),
    }).then((value) {
      setState(() {
        _editable = true;
        _addList = false;
      });
      EasyLoading.dismiss();
    });
  }

  @override
  void initState() {
    setState(() {
      _productName.text = widget.product!.productName!;
      _brand.text = widget.product!.brand!;
      _salesPrice.text = widget.product!.salesPrice!.toString();
      _regularPrice.text = widget.product!.regularPrice!.toString();
      taxStatus = widget.product!.taxStatus;
      taxAmount = widget.product!.taxValue == 10 ? 'GST-10%' : 'GST-12%';
      _description.text = widget.product!.description!;
      _soh.text = widget.product!.soh!.toString();
      _reorderLevel.text = widget.product!.reOrderLevel!.toString();
      _shippingCharge.text = widget.product!.shippingCharge!.toString();
      _otherDetails.text = widget.product!.otherDetails!;
      if (widget.product!.scheduleDate != null) {
        scheduledDate = DateTime.fromMicrosecondsSinceEpoch(
            widget.product!.scheduleDate!.microsecondsSinceEpoch);
      }
      manageInventory = widget.product!.manageInventory;
      chargeShipping = widget.product!.chargeShipping;
      if (widget.product!.size!=null) {
        _sizeList = widget.product!.size!;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          title: Text(widget.product!.productName!),
          actions: [
            _editable
                ? IconButton(
                    icon: Icon(Icons.edit_outlined),
                    onPressed: () {
                      setState(() {
                        _editable = false;
                      });
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.amber)),
                      child: const Text('Save'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          updateProduct();
                        }
                      },
                    ),
                  )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: ListView(
            children: [
              AbsorbPointer(
                absorbing: _editable,
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: widget.product!.imageUrls!.map((e) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CachedNetworkImage(imageUrl: e),
                            );
                          }).toList()),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text('Brand : ',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: _textField(
                                label: 'Brand',
                                inputType: TextInputType.text,
                                controller: _brand)),
                      ],
                    ),
                    _textField(
                        label: 'Product name',
                        inputType: TextInputType.text,
                        controller: _productName),
                    _textField(
                        label: 'Description',
                        inputType: TextInputType.multiline,
                        controller: _description),
                    _textField(
                        label: 'Other details',
                        inputType: TextInputType.text,
                        controller: _otherDetails),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        children: [
                          const Text('Unit : '),
                          Text(widget.product!.unit!),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                if (widget.product!.salesPrice != null)
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Sales Price : ',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: _textField(
                                              label: 'Sales Price',
                                              inputType: TextInputType.number,
                                              controller: _salesPrice,
                                              validator: (value){
                                                if(value!.isEmpty){
                                                  return 'Enter sales price';
                                                }
                                                if(int.parse(value)>int.parse(_regularPrice.text)){
                                                  return 'Sales price < regular price';
                                                }

                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Regular Price : ',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                          child: _textField(
                                        label: 'Regular Price',
                                        inputType: TextInputType.text,
                                        controller: _regularPrice,
                                        validator: (value) {
                                          if(value!.isEmpty){
                                            return 'Enter regular price';
                                          }
                                          if (int.parse(value) <
                                              int.parse(_salesPrice.text)) {
                                            return 'Enter less than regular price';
                                          }
                                        },
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (scheduledDate != null)
                              Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Sales price until : '),
                                    Text(
                                        _services.formattedDate(scheduledDate)),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (_editable == false)
                                  ElevatedButton(
                                    child: const Text('Change Date'),
                                    onPressed: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: scheduledDate!,
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(5000))
                                          .then((value) {
                                        setState(() {
                                          scheduledDate = value;
                                        });
                                      });
                                    },
                                  )
                              ])
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Size list : ${_sizeList.isEmpty ? 0: ""}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (_editable == false)
                                TextButton(
                                  child: const Text('Add list'),
                                  onPressed: () {
                                    setState(() {
                                      _addList = true;
                                    });
                                  },
                                )
                            ],
                          ),
                          if (_addList == true)
                            Form(
                              key: _formKey1,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter a value';
                                      }
                                    },
                                    controller: _sizeText,
                                    decoration: const InputDecoration(
                                        filled: true, fillColor: Colors.white),
                                  )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    child: const Text('Add'),
                                    onPressed: () {
                                      if (_formKey1.currentState!.validate()) {
                                        _sizeList.add(_sizeText);
                                        setState(() {
                                          _sizeText.clear();
                                        });
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          if (_sizeList.isNotEmpty)
                            SizedBox(
                              height: 40,
                              child: ListView.builder(
                                  itemCount: _sizeList.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: InkWell(
                                        onLongPress: () {
                                          setState(() {
                                            _sizeList.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: Colors.amber,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                  child:
                                                      Text(_sizeList[index])),
                                            )),
                                      ),
                                    );
                                  }),
                            ),
                        ]),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(child: _taxStatusDropdown()),
                        const SizedBox(
                          width: 10,
                        ),
                        if (taxStatus == 'Taxable')
                          Expanded(child: _taxAmount())
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(widget.product!.category!),
                        ],
                      ),
                    ),
                    if (widget.product!.mainCategory != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          children: [
                            const Text(
                              'Main Category',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(widget.product!.mainCategory!),
                          ],
                        ),
                      ),
                    if (widget.product!.subCategory != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          children: [
                            const Text(
                              'Sub Category',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(widget.product!.subCategory!),
                          ],
                        ),
                      ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Manage Inventory ? '),
                                value: manageInventory,
                                onChanged: (value) {
                                  setState(() {
                                    manageInventory = value;
                                    if (value == false) {
                                      _soh.clear();
                                      _reorderLevel.clear();
                                    }
                                  });
                                }),
                            if (manageInventory == true)
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Text(
                                          'SOH : ',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: _textField(
                                              label: 'SOH',
                                              inputType: TextInputType.number,
                                              controller: _soh),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Re-order Level : ',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                            child: _textField(
                                                label: 'Reorder level',
                                                inputType: TextInputType.number,
                                                controller: _reorderLevel)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('Charge shipping ? '),
                                value: chargeShipping,
                                onChanged: (value) {
                                  setState(() {
                                    chargeShipping = value;
                                    if (value == false) {
                                      _shippingCharge.clear();
                                    }
                                  });
                                }),
                            if (chargeShipping == true)
                              Row(
                                children: [
                                  const Text('Shipping Charge : '),
                                  Expanded(
                                    child: _textField(
                                        label: 'Shipping charge',
                                        inputType: TextInputType.number,
                                        controller: _shippingCharge),
                                  )
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        children: [
                          const Text(
                            'SKU : ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(widget.product!.sku!),
                        ],
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
