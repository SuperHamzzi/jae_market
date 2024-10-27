import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jae_market/model/product.dart';

class CartScreen extends StatefulWidget {
  final String uid;

  const CartScreen({super.key, required this.uid});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCartItems() {
    return FirebaseFirestore.instance
        .collection("cart")
        .where(
          "email",
          isEqualTo: widget.uid,
        )
        .orderBy("timestamp")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("장바구니"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: streamCartItems(),
                builder: (context, snapshot) {
                  return StreamBuilder(
                      stream: streamCartItems(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Cart> items = snapshot.data?.docs.map((e) {
                                final foo = Cart.fromJson(e.data());
                                return foo.copyWith(cartDocId: e.id);
                              }).toList() ??
                              [];
                          return ListView.separated(
                            itemBuilder: (context, index) {
                              final item = items[index];
                              num price = (item.product?.isSale ?? false)
                                  ? ((item.product!.price! *
                                          (item.product!.saleRate! / 100)) *
                                      (item.count ?? 1))
                                  : (item.product!.price! * (item.count ?? 1));
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            item.product?.imgUrl ?? "",
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("플러터제목"),
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons.delete,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text('1000000원'),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons.remove_circle_outline,
                                                  ),
                                                ),
                                                Text("12"),
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(Icons
                                                      .add_circle_outline_outlined),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, _) => Divider(),
                            itemCount: 10,
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      });
                }),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "합계",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "100000원",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ],
            ),
          ),
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.red[100],
            ),
            child: Center(
              child: Text(
                "배달 주문",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
