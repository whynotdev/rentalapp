import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BorrowedPage extends StatefulWidget {
  final String sendUid;
  final String borrowerName;
  final String borrowerPhone;

  const BorrowedPage({
    Key? key,
    required this.sendUid,
    required this.borrowerName,
    required this.borrowerPhone,
  }) : super(key: key);

  @override
  State<BorrowedPage> createState() => _BorrowedPageState();
}

class _BorrowedPageState extends State<BorrowedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Borrowed Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Successfully Borrowed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'You can contact the owner for further discussion.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Borrower Name: ${widget.borrowerName}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Borrower Phone: ${widget.borrowerPhone}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
