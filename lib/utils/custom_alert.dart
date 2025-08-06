import 'package:flutter/material.dart';

class CustomAlert extends StatelessWidget {
  final String title;
  final String message;
  final AlertType type;
  final VoidCallback? onClose;

  const CustomAlert({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: _getBackgroundColor(context),
      icon: Icon(_getIcon(), color: _getIconColor()),
      iconColor: _getIconColor(),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _getTextColor(context),
        ),
      ),
      content: Text(
        message,
        style: TextStyle(color: _getTextColor(context)),
      ),
      actions: [
        TextButton(
          onPressed: onClose ?? () => Navigator.of(context).pop(),
          child: Text(
            'Aceptar',
            style: TextStyle(color: _getButtonColor(context)),
          ),
        ),
      ],
    );
  }

  IconData _getIcon() {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.error:
        return Icons.error;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.info:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case AlertType.success:
        return Colors.green;
      case AlertType.error:
        return Colors.red;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.info:
        return Colors.blue;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    switch (type) {
      case AlertType.success:
        return brightness == Brightness.dark 
            ? Colors.green[900]! 
            : Colors.green[50]!;
      case AlertType.error:
        return brightness == Brightness.dark 
            ? Colors.red[900]! 
            : Colors.red[50]!;
      case AlertType.warning:
        return brightness == Brightness.dark 
            ? Colors.orange[900]! 
            : Colors.orange[50]!;
      case AlertType.info:
        return brightness == Brightness.dark 
            ? Colors.blue[900]! 
            : Colors.blue[50]!;
    }
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color _getButtonColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
}

enum AlertType {
  success,
  error,
  warning,
  info,
}