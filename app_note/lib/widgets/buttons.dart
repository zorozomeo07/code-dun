import 'package:flutter/material.dart';
import 'package:note/global/my_color.dart';

class SelectedPageButton extends StatelessWidget {
  const SelectedPageButton({
    Key? key,
    required this.onPressed,
    required this.label,
    required this.isSelected,
    required this.icon,
  }) : super(key: key);
  final VoidCallback? onPressed;
  final String label;
  final bool isSelected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color:
            isSelected ? Color.fromARGB(255, 0, 235, 215) : Colors.transparent,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child:
                    Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              ),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: isSelected ? Colors.white : Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NgayThuButton extends StatelessWidget {
  final bool isSelected;
  final String title;
  final VoidCallback onPressed;

  const NgayThuButton({
    super.key,
    required this.isSelected,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: isSelected ? Colors.grey[300] : Colors.white,
          ),
          child: Text(title,
              style:
                  TextStyle(color: isSelected ? MyColors.color : Colors.black)),
          onPressed: onPressed),
    );
  }
}
