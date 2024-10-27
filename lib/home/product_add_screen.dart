import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jae_market/home/camera_example_page.dart';
import 'package:jae_market/model/category.dart';
import 'package:jae_market/model/product.dart';


class ProductAddScreen extends StatefulWidget {
  const ProductAddScreen({super.key});

  @override
  State<ProductAddScreen> createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends State<ProductAddScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isSale = false;

  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  Uint8List? imageData;
  XFile? image;

  Category? selectedCategory;

  TextEditingController titleText = TextEditingController();
  TextEditingController descriptionText = TextEditingController();
  TextEditingController priceText = TextEditingController();
  TextEditingController stockText = TextEditingController();
  TextEditingController salePercentText = TextEditingController();
  List<Category> categoryItems = [];

  Future<List<Category>> _fetchCategories() async {
    final resp = await db.collection("category").get();
    for (var doc in resp.docs) {
      categoryItems.add(Category(
        docId: doc.id,
        title: doc.data()['title'],
      ));
    }
    setState(() {
      selectedCategory = categoryItems.first;
    });
    return categoryItems;
  }

  Future<Uint8List> imageCompressList(Uint8List list)async{
    var result = await FlutterImageCompress.compressWithList(list,
      quality: 50
    );
    return result;
  }

  Future addProduct() async{
    if(imageData != null){
      final storageRef = storage.ref().child("${DateTime.now().microsecondsSinceEpoch}_${
      image?.name ?? "??"
      }.jpg");
      final compressedData = await imageCompressList(imageData!);
      await storageRef.putData(compressedData!);
      final downloadLink = await storageRef.getDownloadURL();
      final sampleData = Product(
        title: titleText.text,
        description : descriptionText.text,
        price: int.parse(priceText.text),
        stock: int.parse(stockText.text),
        isSale : isSale,
        saleRate : salePercentText.text.isNotEmpty
          ? double.parse(salePercentText.text)
            : 0,
        imgUrl : downloadLink,
        timestamp:  DateTime.now().microsecondsSinceEpoch,
      );
      final doc = await db.collection("products").add(sampleData.toJson());
      await doc.collection("category").add(selectedCategory?.toJson() ?? {});
      final categoRef = db.collection("category").doc(selectedCategory?.docId);
      await categoRef.collection("products").add({"docId": doc.id});
    }
  }

  Future addProducts() async{
    if(imageData != null){
      final storageRef = storage.ref().child("${DateTime.now().microsecondsSinceEpoch}_${
          image?.name ?? "??"
      }.jpg");
      final compressedData = await imageCompressList(imageData!);
      await storageRef.putData(compressedData!);
      final downloadLink = await storageRef.getDownloadURL();
      for(var i = 0; i< 10; i++){
        final sampleData = Product(
          title: titleText.text+"${i}",
          description : descriptionText.text,
          price: int.parse(priceText.text),
          stock: int.parse(stockText.text),
          isSale : isSale,
          saleRate : salePercentText.text.isNotEmpty
              ? double.parse(salePercentText.text)
              : 0,
          imgUrl : downloadLink,
          timestamp:  DateTime.now().microsecondsSinceEpoch,
        );
        final doc = await db.collection("products").add(sampleData.toJson());
        await doc.collection("category").add(selectedCategory?.toJson() ?? {});
        final categoRef = db.collection("category").doc(selectedCategory?.docId);
        await categoRef.collection("products").add({"docId": doc.id});
      }

    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("상품추가"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return CameraExamplePage();
                  },
                ),
              );
            },
            icon: Icon(Icons.camera),
          ),
          IconButton(
            onPressed: () {
              addProducts();
            },
            icon: Icon(Icons.batch_prediction),
          ),
          IconButton(
            onPressed: () {
              addProduct();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  image = await picker.pickImage(source: ImageSource.gallery);
                  print(image?.name);
                  imageData = await image?.readAsBytes();
                  setState(() {});
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 240,
                    width: 240,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: imageData == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.add), Text("제품(상품) 이미지 추가")],
                          )
                        : Image.memory(
                            imageData!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "기본정보",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "상품명",
                        hintText: "제품명을 입력하세요.",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "필수 입력 항목입니다.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: descriptionText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "상품 설명",
                      ),
                      maxLength: 254,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "필수 입력 항목입니다.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: priceText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "가격(단가)",
                        hintText: "1개 가격 입력",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "필수 입력 항목입니다.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: stockText,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "수량",
                        hintText: "입고 및 재고 수량",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "필수 입력 항목입니다.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SwitchListTile.adaptive(
                      value: isSale,
                      onChanged: (v) {
                        setState(() {
                          isSale = v;
                        });
                      },
                      title: Text("할인여부"),
                    ),
                    if (isSale)
                      TextFormField(
                        controller: salePercentText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "할인율",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          return null;
                        },
                      ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "카테고리 선택",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    categoryItems.isNotEmpty
                        ? DropdownButton<Category>(
                            value: selectedCategory,
                            items: categoryItems
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text("${e.title}"),
                                  ),
                                )
                                .toList(),
                            onChanged: (s) {
                              setState(() {
                                selectedCategory =s;
                              });
                            },
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
