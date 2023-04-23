import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';

class CreateScheduledAlert extends StatefulWidget {
  const CreateScheduledAlert({super.key});

  @override
  State<CreateScheduledAlert> createState() => _CreateScheduledAlertState();
}

class _CreateScheduledAlertState extends State<CreateScheduledAlert> {
  final TextEditingController _alertNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog();
  }
}
