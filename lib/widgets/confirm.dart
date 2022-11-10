import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pocket_ktv/model/reduce_string.dart';

class Confirm extends StatelessWidget {
  const Confirm({
    Key? key,
    required this.highlightText,
    required this.actionText,
    required this.onConfirm,
  }) : super(key: key);

  final String highlightText;
  final String actionText;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, -0.1),
      child: AspectRatio(
        aspectRatio: 214 / 215,
        child: FractionallySizedBox(
          widthFactor: 0.6,
          heightFactor: 0.6,
          child: Container(
            padding: EdgeInsets.all(17.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.grey,
            ),
            child: Column(
              children: [
                Text(
                  '確定要將',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '「${Reduce.reduce(highlightText, 13)}」',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$actionText',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel
                    ElevatedButton(
                      child: Text(
                        '取消',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp
                        ),
                      ),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(6.r),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xffe58e46)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Confirm
                    ElevatedButton(
                      child: Text(
                        '確定',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp
                        ),
                      ),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(6.r),
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xff34bacc)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                      ),
                      onPressed: onConfirm,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
