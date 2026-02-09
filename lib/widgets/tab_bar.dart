import 'package:flutter/material.dart';
// import 'package:to_do_list/screens/homepage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';

class TabBar_Bar extends StatelessWidget {
  final TabController tabController;
  final activeCount;
  final allCount;
  final doneCount;

  const TabBar_Bar({
    super.key,
    required this.tabController,
    required this.activeCount,
    required this.allCount,
    required this.doneCount
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      //clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Container(
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: tdLightGrey
        ),
        child: TabBar(
          //isScrollable: true,
          //tabAlignment: TabAlignment.start,
          labelColor: tdWhite,
          unselectedLabelColor: tdBlack,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
              color: tdOrange,
              borderRadius: BorderRadius.circular(30)
          ),
          controller: tabController,
          tabs: [
            buildTab("All",allCount),
            buildTab("Active",activeCount),
            buildTab("Done",doneCount),
          ],
        ),
      ),
    );
  }

  Tab buildTab(String text,int count) {
    return Tab(
              child: Center(
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: Text(
                          "$text",
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        )),
                    SizedBox(width: 6.w,),
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tdGrey,
                      ),
                      child: Text(count.toString(),style: TextStyle(color: tdBlack),),
                    )
                  ],
                ),
              )
          );
  }
}
