import 'package:flutter/material.dart';
import 'package:to_do_list/model/todo.dart';
import '../screens/homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ToDoAdapter());
  await Hive.openBox<ToDo>('todos');
  await Hive.openBox("userBox");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
    //final size = MediaQuery.of(context).size;
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context,child){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Home(),
        );
      },
    );
  }
}

