import 'package:flutter/material.dart';

class NotificationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController timeController;
  final Widget Function(bool) buildDateField;
  final Widget buildTimeField;

  const NotificationForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.startDateController,
    required this.endDateController,
    required this.timeController,
    required this.buildDateField,
    required this.buildTimeField,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Plan',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese un nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: buildDateField(true)),
              const SizedBox(width: 16),
              Expanded(child: buildDateField(false)),
              const SizedBox(width: 16),
              Expanded(child: buildTimeField),
            ],
          ),
        ],
      ),
    );
  }
}
