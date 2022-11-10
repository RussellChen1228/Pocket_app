import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color_loader_4.dart';

class Loading extends StatelessWidget {
  const Loading({
    Key? key,
    this.onBack
  }) : super(key: key);
  final void Function()? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              onBack!();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);

            },
            icon: Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 110.w,
          right: 110.w,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              SizedBox(height: 100.h),
              Text(
                '正在搜尋...',
                style: TextStyle(
                  fontSize: 24.sp,
                ),
              ),
              SizedBox(height: 482.h),
              ColorLoader4(),
            ],
          ),
        ),
      ),
    );
  }
}