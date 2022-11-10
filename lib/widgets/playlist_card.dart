import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    required this.name,
    this.isNew = false,
    Key? key,
  }) : super(key: key);

  final bool isNew;
  final String name;

  @override
  Widget build(BuildContext context) {
    return isNew ? NewBadget(child: MyCard(name: name)) : MyCard(name: name);
  }
}

class NewBadget extends StatelessWidget {
  const NewBadget({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 43.w,
            height: 43.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffe58e46),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 0.1,
                  blurRadius: 3,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Center(
              child: Text(
                '新',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class MyCard extends StatelessWidget {
  const MyCard({
    Key? key,
    required this.name,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          // padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.cyan.shade200,
                Colors.lightBlue.shade800,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddPlaylistCard extends StatelessWidget {
  const AddPlaylistCard({required this.name, Key? key}) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade700,
              ],
            ),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
