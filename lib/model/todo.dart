import 'package:hive/hive.dart';


part 'todo.g.dart';

@HiveType(typeId: 0)
class ToDo extends HiveObject{
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String todoText;
  
  @HiveField(2)
  bool isChecked;

  ToDo({
    required this.id,
    required this.todoText,
    this.isChecked = false,
  });

  // static List<ToDo> todoList() {
  //   return [
  //     // ToDo(id: '01', todoText: 'Gym',isChecked: true),
  //     // ToDo(id: '02', todoText: 'writing',isChecked: true),
  //     // ToDo(id: '03', todoText: 'Book read',isChecked: true),
  //     // ToDo(id: '04', todoText: 'speaking'),
  //     // ToDo(id: '05', todoText: 'Oli buying',isChecked: true),
  //     // ToDo(id: '06', todoText: 'Motor on'),
  //     // ToDo(id: '07', todoText: 'petrol',isChecked: true),
  //     // ToDo(id: '08', todoText: 'Meat',isChecked: true),
  //   ];
  // }
}