
import 'package:flutter/material.dart';

class RecentResearch extends StatelessWidget {
  final String text;
const RecentResearch({ super.key, required this.text});

  @override
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.all(4.0),
      child: Chip(
        clipBehavior: Clip.hardEdge,
        label: Text(text),
        avatar: Icon(Icons.history, size: 16.0, color: Theme.of(context).colorScheme.onSurface),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
    );
  }
}