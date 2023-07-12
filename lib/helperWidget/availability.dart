import 'package:flutter/material.dart';

class AvailabilityScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  AvailabilityScreen({required this.data, required Map<String, dynamic> product});

  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Availability'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: Text('Select Dates'),
              onPressed: () {
                _showDateRangePicker(context);
              },
            ),
            SizedBox(height: 20),
            Text(
              'Selected Range: ${startDate?.toString() ?? 'Not selected'} - ${endDate?.toString() ?? 'Not selected'}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final initialDate = startDate ?? DateTime.now();
    final firstDate = DateTime(DateTime.now().year - 1);
    final lastDate = DateTime(DateTime.now().year + 1);

    final picked = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Date Range'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Start Date'),
                    subtitle: Text(startDate?.toString() ?? 'Not selected'),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: firstDate,
                        lastDate: lastDate,
                      );

                      if (pickedDate != null) {
                        setState(() {
                          startDate = pickedDate;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text('End Date'),
                    subtitle: Text(endDate?.toString() ?? 'Not selected'),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? initialDate,
                        firstDate: startDate ?? firstDate,
                        lastDate: lastDate,
                      );

                      if (pickedDate != null) {
                        setState(() {
                          endDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop([startDate, endDate]);
              },
            ),
          ],
        );
      },
    );

    if (picked != null && picked.length == 2) {
      setState(() {
        startDate = picked[0];
        endDate = picked[1];
      });
    }
  }
}
