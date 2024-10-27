import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jae_market/home/cart_screen.dart';
import 'package:jae_market/home/product_add_screen.dart';
import 'package:jae_market/home/widgets/home_widget.dart';
import 'package:jae_market/home/widgets/seller_widget.dart';
import 'package:jae_market/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _menuIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("재혁마켓"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.logout,
            ),
          ),
          if (_menuIndex == 0)
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _menuIndex,
        children: [
          HomeWidget(),
          SellerWidget(),
        ],
      ),
      floatingActionButton: (() {
        switch (_menuIndex) {
          case 0:
            return FloatingActionButton(
              onPressed: () {
                final uid = userCredential?.user?.uid;
                if(uid == null){
                  return;
                }
                context.go("/cart/$uid");
              },
              child: Icon(Icons.shopping_cart_outlined),
            );
          case 1:
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductAddScreen(),
                  ),
                );
              },
              child: Icon(Icons.add),
            );
          default:
            return SizedBox(); // 기본값 처리
        }
      })(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _menuIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _menuIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store_outlined), label: "홈"),
          NavigationDestination(
              icon: Icon(Icons.storefront), label: "사장님(판매자)"),
        ],
      ),
    );
  }
}
