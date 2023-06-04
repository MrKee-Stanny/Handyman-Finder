import 'package:flutter/material.dart';

class HandymanChip extends StatefulWidget {
  List selectedChips;
  String skill;
  Function getData;

  HandymanChip(
      {required this.selectedChips,
      required this.getData,
      required this.skill});

  @override
  State<HandymanChip> createState() => _HandymanChipState();
}

class _HandymanChipState extends State<HandymanChip> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.selectedChips.contains(widget.skill)) {
            widget.selectedChips.remove(widget.skill);
          } else {
            widget.selectedChips.add(widget.skill);
          }
          widget.getData();
        });
      },
      child: Chip(
        label: Text('${widget.skill}s'),
        backgroundColor: widget.selectedChips.contains('Electricians')
            ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
            : Colors.transparent,
        labelStyle: TextStyle(
          color: widget.selectedChips.contains('Electricians')
              ? Colors.white
              : Theme.of(context).colorScheme.primary,
          fontWeight: widget.selectedChips.contains('Electricians')
              ? FontWeight.bold
              : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: widget.selectedChips.contains('Electricians')
                ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
