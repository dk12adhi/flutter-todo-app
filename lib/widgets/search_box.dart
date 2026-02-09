import 'package:flutter/material.dart';

import '../constants/colors.dart';

class searchBox extends StatelessWidget {
  final TextEditingController controller;
  const searchBox({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
      return Container(
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tdBlack),
          color: tdWhite,
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search,color: tdBlack,size: 22,),
              prefixIconConstraints: BoxConstraints(maxHeight: 22,maxWidth: 25),
              border: InputBorder.none,
              hintText: "search",
              hintStyle: TextStyle(color: tdGrey,fontSize: 17)
          ),
        ),
      );
    }
}
