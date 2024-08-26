import 'package:flutter/material.dart';

class AlarmTile extends StatelessWidget {
  const AlarmTile({
    required this.title,
    required this.subTitle,
    required this.lapLai,
    required this.onPressed,
    required this.isActive, // Add a parameter to indicate if the alarm is active
    required this.onToggle, // Add a callback for toggling the alarm
    super.key,
    this.onDismissed,
  });

  final String title;
  final String subTitle;
  final String lapLai;
  final void Function() onPressed;
  final void Function()? onDismissed;
  final bool isActive; // Add a parameter to manage the alarm state
  final void Function(bool) onToggle; // Add a callback to handle toggle action

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: onDismissed != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        child: const Icon(
          Icons.delete,
          size: 30,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.normal)), // Adjusted font size
        subtitle: Container(
          width: 200,
          child: Row(
            children: [
              Text(
                subTitle,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                width: 5,
              ),
              Text(lapLai)
            ],
          ),
        ),
        trailing: Switch(
          value: isActive,
          onChanged: onToggle, // Use the toggle callback to change alarm state
        ),
        onTap: onPressed,
      ),
    );
  }
}
