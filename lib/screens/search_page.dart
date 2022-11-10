import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pocket_ktv/model/language.dart';
import 'package:pocket_ktv/model/stt_result.dart';

import 'package:pocket_ktv/screens/result_page.dart';
import 'package:pocket_ktv/screens/stt_page.dart';
import 'package:pocket_ktv/widgets/my_color.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 140.h, left: 37.w, right: 37.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              " 搜尋",
              style: TextStyle(fontSize: 24.sp),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 14.h),
            SearchBar(),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  SearchBar({Key? key}) : super(key: key);

  @override
  _SearchBar createState() => _SearchBar();
}

class _SearchBar extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;
  String hintText = "歌手,歌名,歌號 搜尋";

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _isTyping = true;
          hintText = "";
        });
      } else {
        setState(() {
          _isTyping = false;
          hintText = "歌手,歌名,歌號 搜尋";
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55.h,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: MyColors.orange,
                  width: 3.r,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10.r),
                ),
              ),
              child: TextField(
                focusNode: _focusNode,
                onSubmitted: (text) {
                  if (text != "") {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => ResultPage(
                          songName: _searchController.text,
                          from: 'typing',
                        ),
                      ),
                    );
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
                controller: _searchController,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: (_isTyping || _searchController.text != "")
                      ? null
                      : Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                  prefixIconConstraints: BoxConstraints(
                    minHeight: 15.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () async {
              SttResult? result =
                  await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => SttPage(),
                ),
              );
              if (result != null) {
                await Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => ResultPage(
                      songName: result.result,
                      // TODO: REMOVE this.
                      from: 'search-page-voice',
                      sttLanguage: result.language,
                    ),
                  ),
                );
              }
            },
            child: Container(
              height: 56.w,
              width: 56.w,
              padding: EdgeInsets.all(10.0.w),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 5.0,
                    spreadRadius: 0.0,
                    offset: Offset(0.0, 6.0), // shadow direction: bottom right
                  )
                ],
                shape: BoxShape.circle,
                color: MyColors.orange,
              ),
              child: FittedBox(
                child: Image.asset('assets/images/search_bar_mic.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
