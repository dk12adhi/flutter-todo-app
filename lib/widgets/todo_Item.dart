import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do_list/constants/colors.dart';

import '../model/todo.dart';

class TodoItem extends StatelessWidget {
  final ToDo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const TodoItem({super.key, required this.todo, required this.onToggle, required this.onDelete});

  @override
  //bool ischecked = false;
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      // decoration: BoxDecoration(
      //   boxShadow: [BoxShadow(color: tdBlack,spreadRadius: 1,blurRadius: 5)]
      // ),
      child: ListTile(
        onTap: onToggle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: tdWhite,
        leading: todo.isChecked? Icon(Icons.check_circle,color: tdGreen,size: 29,shadows: [Shadow(color: tdBlack,blurRadius: 20)],) : Icon(Icons.circle_outlined,color: tdGreen,size: 20,),
        title: Text(todo.todoText,
          style: GoogleFonts.inconsolata(
              fontSize: 22,
              color: tdBlack,
              decoration: todo.isChecked? TextDecoration.lineThrough : null,
          ),),
        trailing: IconButton(onPressed: onDelete, icon: Icon(Icons.delete,color: tdRed,size: 25,)),
      ),
    );
  }
}
