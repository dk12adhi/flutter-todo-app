import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:to_do_list/widgets/tab_bar.dart';
import '../constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/todo.dart';
import '../widgets/search_box.dart';
import '../widgets/todo_Item.dart';
import 'package:image_picker/image_picker.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin{
  // before final todoList = ToDo.todoList();
  late Box<ToDo> todoBox;
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  var progress;
  var activeCount;
  var allCount;
  var doneCount;
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProfile();
    todoBox = Hive.box<ToDo>('todos');

    _tabController = TabController(length: 3, vsync: this);

    //search
    _searchController.addListener((){
      setState(() {
      });
    });
  }

  void loadProfile(){
    var userprof = Hive.box("userBox");
    String? path = userprof.get("profilepath");

    if(path != null){
      setState(() {
        profileImage = File(path);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _todoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addToDo(String val) {
    if (val.trim().isEmpty) return;
    final todo =
      ToDo(id: DateTime.now().millisecondsSinceEpoch.toString(), todoText: val);
    todoBox.add(todo);
    _todoController.clear();
  }

  void _deleteToDo(ToDo todo) {
      // todoList.removeWhere((t) => t.id == todo.id);
      todo.delete();
  }

  File? profileImage;

  Future<void> pickprofile() async{
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if(picked != null){
      profileImage = File(picked.path);

      var box = Hive.box("userBox");
      await box.put("profilepath", profileImage?.path);

      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: tdBgColor,
      appBar: _buildAppBar(),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                searchBox(controller: _searchController),
                SizedBox(height: 15),
                Text(
                  "MyTasks",
                  style: GoogleFonts.inconsolata(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: todoBox.listenable(),
                  builder: (context, Box<ToDo> box, _){
                    final allTodos = box.values.toList();
                    final completed = allTodos.where((todo) => todo.isChecked
                    ).length;
                    final progress = allTodos.isEmpty? 0.0 : completed / allTodos.length;
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: LinearProgressIndicator(
                            value: progress,
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.deepOrange,
                            backgroundColor: tdOrange,
                          ),
                        ),
                        SizedBox(height: 6,),
                        Text("${(progress * 100).toStringAsFixed(0)}%", style: TextStyle(color: tdBlack)),
                      ],
                    );
                  }
                ), // Linear progress Indicator
                SizedBox(height: 20),

                Expanded(
                  child: ValueListenableBuilder<Box<ToDo>>(
                    valueListenable: todoBox.listenable(),
                    builder: (context,box,_){
                      final alltodos = box.values.toList();
                      final searchText = _searchController.text.toLowerCase();

                      final allfiltered = alltodos.where((t) => t.todoText.toLowerCase().contains(searchText)).toList();
                      final activeTodo = allfiltered.where((t) => !t.isChecked).toList();
                      final doneTodo = allfiltered.where((t) => t.isChecked).toList();

                      return Column(
                        children: [
                          TabBar_Bar(
                              tabController: _tabController,
                              activeCount: activeTodo.length,
                              allCount: allfiltered.length,
                              doneCount: doneTodo.length
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                buildToDoList(allfiltered),
                                buildToDoList(activeTodo),
                                buildToDoList(doneTodo)
                              ]
                            )
                          )
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 23, left: 23, right: 20),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: tdBlack,
                          spreadRadius: 3,
                          blurRadius: 20,
                        ),
                      ],
                      color: tdWhite,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: InputDecoration(
                        hintText: "Enter Task...",
                        hintStyle: TextStyle(color: tdGrey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    _addToDo(_todoController.text);
                  },
                  child: Text("+"),
                  backgroundColor: tdWhite,
                ),
              ],
            ),
          ), //floating action button
        ],
      ),
    );
  }

  //buildToDoList (Listview Builder)
  Widget buildToDoList(List<ToDo> todos){
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index){
        final todo = todos[index];
        return Dismissible(
            key: Key(todo.id),
            direction:  DismissDirection.horizontal,
            background: Container(
              height: 50,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: tdRed,
              child: const Icon(Icons.delete,color: tdWhite,size: 30,),
            ),
            onDismissed: (_) => _deleteToDo(todo),
            child: TodoItem(
                todo: todo,
                onToggle: (){
                  todo.isChecked = !todo.isChecked;
                  todo.save();
                },
                onDelete: (){
                  _deleteToDo(todo);
                })
        );
      },
    );
}


  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: tdBgColor,
      surfaceTintColor: tdBgColor,
      title: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GestureDetector(
                  onTap: pickprofile,
                    child: profileImage != null? Image.file(profileImage!,fit: BoxFit.cover,) : Image.asset("assets/unnamed.jpg")
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TabBar_Bar(
  //   tabController: _tabController,
  //   activeCount: activeCount,
  //   doneCount: doneCount,
  //   allCount: allCount,
  // ),
  // SizedBox(height: 12,),
  // Expanded(
  //   child: TabBarView(
  //     controller: _tabController,
  //     children:[
  //       buildValueListenableBuilderAll(),
  //       buildValueListenableBuilderActive(),
  //       Text("data")
  //     ]
  //   ),
  // ),
  // Expanded(
  //   child:
  // ),
  
  // ValueListenableBuilder<Box<ToDo>> buildValueListenableBuilderAll() {
  //   return ValueListenableBuilder(
  //       valueListenable: todoBox.listenable(),
  //       builder: (context, Box<ToDo> box, _) {
  //         final alltodos = box.values.toList();
  //         final searchtext = _searchController.text.toLowerCase();
  //         final filteredTodos = alltodos.where((todo){
  //           return todo.todoText.toLowerCase().contains(searchtext);
  //         }).toList();
  //         allCount = filteredTodos.length;
  //         return ListView.builder(
  //             itemCount: filteredTodos.length,
  //             itemBuilder: (context, index){
  //               final todo = filteredTodos[index];
  //               return Dismissible(
  //                 key: Key(todo.id),
  //                 direction: DismissDirection.endToStart,
  //                 background: Container(
  //                   alignment: Alignment.centerRight,
  //                   padding: EdgeInsets.only(right: 20),
  //                   color: tdRed,
  //                   child: Icon(Icons.delete, color: tdWhite, size: 30),
  //                 ),
  //                 onDismissed: (_) => _deleteToDo(todo),
  //                 child: TodoItem(
  //                   todo: todo,
  //                   onToggle: () {
  //                     setState(() {
  //                       todo.isChecked = !todo.isChecked;
  //                       todo.save();
  //                     });
  //                     },
  //                   onDelete: () {
  //                     showDialog(
  //                       barrierColor: tdBlack,
  //                       context: context,
  //                       builder: (_) => AlertDialog(
  //                         title: Text("Delete the task?"),
  //                         content: Text("This can't be undone"),
  //                         actions: [
  //                           TextButton(
  //                             onPressed: () => Navigator.pop(context),
  //                             child: Text("cancel"),
  //                           ),
  //                           TextButton(
  //                             onPressed: () {
  //                               _deleteToDo(todo);
  //                               Navigator.pop(context);
  //                               },
  //                             child: Text("Delete"),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                     },
  //                 ),
  //               );
  //             }
  //             );
  //       }
  //       );
  // }

  // ValueListenableBuilder<Box<ToDo>> buildValueListenableBuilderActive() {
  //   return ValueListenableBuilder(
  //       valueListenable: todoBox.listenable(),
  //       builder: (context, Box<ToDo> box, _) {
  //         final alltodos = box.values.toList();
  //
  //         final searchtext = _searchController.text.toLowerCase();
  //         final filteredTodos = alltodos.where((todo){
  //           return todo.todoText.toLowerCase().contains(searchtext) && !todo.isChecked;
  //         }).toList();
  //         activeCount = filteredTodos.length;
  //         return ListView.builder(
  //             itemCount: filteredTodos.length,
  //             itemBuilder: (context, index){
  //               final todo = filteredTodos[index];
  //               return Dismissible(
  //                 key: Key(todo.id),
  //                 direction: DismissDirection.endToStart,
  //                 background: Container(
  //                   alignment: Alignment.centerRight,
  //                   padding: EdgeInsets.only(right: 20),
  //                   color: tdRed,
  //                   child: Icon(Icons.delete, color: tdWhite, size: 30),
  //                 ),
  //                 onDismissed: (_) => _deleteToDo(todo),
  //                 child: TodoItem(
  //                   todo: todo,
  //                   onToggle: () {
  //                     setState(() {
  //                       todo.isChecked = !todo.isChecked;
  //                       todo.save();
  //                     });
  //                   },
  //                   onDelete: () {
  //                     showDialog(
  //                       barrierColor: tdBlack,
  //                       context: context,
  //                       builder: (_) => AlertDialog(
  //                         title: Text("Delete the task?"),
  //                         content: Text("This can't be undone"),
  //                         actions: [
  //                           TextButton(
  //                             onPressed: () => Navigator.pop(context),
  //                             child: Text("cancel"),
  //                           ),
  //                           TextButton(
  //                             onPressed: () {
  //                               _deleteToDo(todo);
  //                               Navigator.pop(context);
  //                             },
  //                             child: Text("Delete"),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               );
  //             }
  //         );
  //       }
  //   );
  // }

}



// import 'package:flutter/material.dart';
// import '../constants/colors.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../model/todo.dart';
// import '../widgets/search_box.dart';
// import '../widgets/todo_Item.dart';
//
//
// class Home extends StatefulWidget {
//   const Home({super.key});
//
//   @override
//   State<Home> createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//
//   final todoList = ToDo.todoList();
//   TextEditingController _todoController = TextEditingController();
//
//   @override
//   void dispose(){
//     _todoController.dispose();
//     super.dispose();
//   }
//
//   void _addToDo(String val){
//     if(val.trim().isEmpty) return;
//
//     setState(() {
//       todoList.add(
//         ToDo(id: DateTime.now().millisecondsSinceEpoch.toString(), todoText: val)
//       );
//     });
//     _todoController.clear();
//   }
//   void _deleteToDo(ToDo todo){
//     setState(() {
//       todoList.removeWhere((t) => t.id == todo.id);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: false,
//       backgroundColor: tdBgColor,
//       appBar: _buildAppBar(),
//       body: Stack(
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
//             child:
//             Column(
//               children: [
//                 searchBox(),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 Text("MyTasks",style: GoogleFonts.inconsolata(fontSize: 40,fontWeight: FontWeight.bold),),
//                 Container(
//                   margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
//                   child: LinearProgressIndicator(
//                     borderRadius: BorderRadius.circular(15),
//                     color: Colors.deepOrange,
//                     backgroundColor: tdOrange,
//                   ),
//                 ),
//                 SizedBox(height: 20,),
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       for( ToDo todo in todoList)
//                         Dismissible(key: Key(todo.id!),
//                             direction: DismissDirection.endToStart,
//                             background: Container(
//                               alignment: Alignment.centerRight,
//                               padding: EdgeInsets.only(right: 20),
//                               color: tdRed,
//                               child: Icon(Icons.delete,color: tdWhite,size: 30,),
//                             ),
//                             onDismissed: (_) => _deleteToDo(todo),
//                             child: TodoItem(
//                                 todo: todo,
//                                 onToggle: (){
//                                   setState(() {
//                                     todo.isChecked = !todo.isChecked;
//                                   });
//                                 },
//                                 onDelete: (){
//                                   showDialog(
//                                       barrierColor: tdBlack,
//                                       context: context,
//                                       builder: (_) => AlertDialog(
//                                         title: Text("Delete the task?"),
//                                         content: Text("This can't be undone"),
//                                         actions: [
//                                           TextButton(onPressed: () => Navigator.pop(context), child: Text("cancel")),
//                                           TextButton(onPressed:(){
//                                             _deleteToDo(todo);
//                                             Navigator.pop(context);
//                                           }, child: Text("Delete"),),
//                                         ],
//                                       )
//                                   );
//                                 }
//                                 )
//                         ),
//                     ]
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Row(
//               children: [
//                 Expanded(
//                     child: Container(
//                       margin: EdgeInsets.only(
//                         bottom: 23,
//                         left: 23,
//                         right: 20
//                       ),
//                       padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
//                       decoration: BoxDecoration(
//                         boxShadow: const[BoxShadow(
//                           color: tdBlack,
//                           spreadRadius: 3,
//                           blurRadius: 20,
//                         )],
//                         color: tdWhite,
//                         shape: BoxShape.rectangle,
//                         borderRadius: BorderRadius.circular(20)
//                       ),
//                       child: TextField(
//                         controller: _todoController,
//                         decoration: InputDecoration(
//                           hintText: "Enter Task...",
//                           hintStyle: TextStyle(
//                             color: tdGrey
//                           ),
//                           border: InputBorder.none
//                         ),
//                       ),
//                     ),
//                   ),
//                   FloatingActionButton(
//                     onPressed: (){
//                       _addToDo(_todoController.text);
//                     },
//                     child: Text("+"),
//                     backgroundColor: tdWhite,
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//
//
//   AppBar _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: tdBgColor,
//       surfaceTintColor: tdBgColor,
//       title: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             SizedBox(
//               height: 40,
//               width: 40,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: Image.asset("assets/unnamed.jpg"),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
