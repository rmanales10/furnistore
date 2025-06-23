import 'package:flutter/material.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              height: size.height * 0.7,
              width: size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildAddProductButton(),
                  SizedBox(height: 20),
                  _buildProductHeader(size),
                  SizedBox(height: 20),
                  _buildProductItem(size),
                  _buildProductItem(size),
                  _buildProductItem(size),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(top: 20, left: 25),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: const Color(0xFF3E6BE0),
            borderRadius: BorderRadius.circular(5)),
        child: TextButton(
          onPressed: () {},
          child: const Text(
            'Add Product',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      width: size.width * 0.9,
      height: size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: 40), // Space for checkbox
          SizedBox(width: 40), // Space for image
          Expanded(
            flex: 2,
            child: Text(
              'Products',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Stock',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Price',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Action',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Size size) {
    return Container(
      margin: EdgeInsets.only(left: 25, right: 25, bottom: 25),
      width: size.width * 0.9,
      height: size.height * 0.06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(value: true, onChanged: (value) {}),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              'assets/products/wood_frame.png',
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Gray Blue Modern Chair',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '100',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '₱ 2,000',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit),
                SizedBox(width: 10),
                Icon(Icons.delete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
