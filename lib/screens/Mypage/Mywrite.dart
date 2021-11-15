import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// provider listener 이용
import 'package:flutter/foundation.dart';
import 'package:today_dinner/providers/recipe.dart';
import 'package:today_dinner/providers/reply.dart';
import 'package:today_dinner/screens/Home/index.dart';
import 'package:today_dinner/screens/Product/index.dart';
import 'package:today_dinner/screens/Scrap/index.dart';
import 'package:today_dinner/screens/Recipe/index.dart';
import 'package:today_dinner/screens/Shopping/index.dart';
import 'package:today_dinner/screens/Write/index.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:today_dinner/screens/Reply/index.dart';
import 'package:today_dinner/screens/Mypage/index.dart';

// provider => watch는 값이 변화할 때 리렌더링, read는 값이 변화해도 렌더링 x
// => watch는 값을 보여주는 UI에 read는 변경이 필요없는 함수에 주로 사용
import 'package:today_dinner/providers/mypage.dart';
import 'package:today_dinner/providers/write.dart';

// firestorage.List feed_image = firestorage.ref('20210917_164240.jpg');
// var url = firestorage.ref('20210917_164240.jpg').getDownloadURL();

// firebase auth
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;

// Feed 기본 Class => 피드 / 자유 게시판 / 식사
class Feed extends StatefulWidget {
  final int index;
  Feed(this.index);
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  // 좋아요 함수
  void Like_Click(like_check, index) async {
    var id = "";
    // 좋아요 되어 있지 않은 경우
    if (like_check == false) {
      // Feed
      if (context.read<Mypage>().top_index == 1) {
        id = context.read<Mypage>().Feed[index]['id'];
      }
      if (context.read<Mypage>().top_index == 2) {
        id = context.read<Mypage>().Freetalk[index]['id'];
      }
      context
          .read<Mypage>()
          .add_like(auth, auth.currentUser?.email, id)
          .then((_) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("좋아요 완료"),
                content: new Text("해당 글에 좋아요 했습니다."),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: new Text("닫기"),
                  ),
                ],
              );
            });
      });
    }
    // 이미 좋아요 되어 있는 경우
    if (like_check == true) {
      // Feed
      if (context.read<Mypage>().top_index == 1) {
        id = context.read<Mypage>().Feed[index]['id'];
      }
      if (context.read<Mypage>().top_index == 2) {
        id = context.read<Mypage>().Freetalk[index]['id'];
      }
      context
          .read<Mypage>()
          .remove_like(auth, auth.currentUser?.email, id)
          .then((_) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("좋아요 취소 완료"),
                content: new Text("해당 글에 좋아요 취소했습니다."),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: new Text("닫기"),
                  ),
                ],
              );
            });
      });
    }
  }

  // 피드 이미지 저장하는 함수
  Future<void> Bookmark_Click(bookmark_check, index) async {
    var id = "";
    // 좋아요 되어 있지 않은 경우
    if (bookmark_check == false) {
      // Feed
      if (context.read<Mypage>().top_index == 1) {
        id = context.read<Mypage>().Feed[index]['id'];
      }
      if (context.read<Mypage>().top_index == 2) {
        id = context.read<Mypage>().Freetalk[index]['id'];
      }
      if (context.read<Mypage>().top_index == 3) {
        id = context.read<Mypage>().Recipe[index]['id'];
      }
      context
          .read<Mypage>()
          .add_bookmark(auth, auth.currentUser?.email, id)
          .then((_) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("스크랩 완료"),
                content: new Text("해당 글을 스크랩 했습니다."),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: new Text("닫기"),
                  ),
                ],
              );
            });
      });
    }
    // 이미 좋아요 되어 있는 경우
    if (bookmark_check == true) {
      // Feed
      if (context.read<Mypage>().top_index == 1) {
        id = context.read<Mypage>().Feed[index]['id'];
      }
      if (context.read<Mypage>().top_index == 2) {
        id = context.read<Mypage>().Freetalk[index]['id'];
      }
      if (context.read<Mypage>().top_index == 3) {
        id = context.read<Mypage>().Recipe[index]['id'];
      }

      context
          .read<Mypage>()
          .remove_bookmark(auth, auth.currentUser?.email, id)
          .then((_) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("스크랩 취소 완료"),
                content: new Text("해당 글을 스크랩 취소했습니다."),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: new Text("닫기"),
                  ),
                ],
              );
            });
      });
    }
  }

  // 선택된 필터가 있으면 필터에 부합하는 데이터만 노출
  void checkfilter(int index) async {
    // true 값으로 init
    context.watch<Mypage>().check = true;
    if (context.watch<Mypage>().Selected_list.length > 0) {
      // 필터가 있으면 false로 바꾸기
      context.watch<Mypage>().check = false;

      // Feed의 경우
      if (context.watch<Mypage>().top_index == 1) {
        for (var data in context.watch<Mypage>().Feed[index]['filter']) {
          for (var selected in context.watch<Mypage>().Selected_list) {
            // print(data);

            // print(selected);
            if (data.indexOf(selected) == 0) {
              // 피드에 포함된 필터가 선택되어 있는 경우에는 다시 true로 return
              context.watch<Mypage>().check = true;
            }
          }
        }
      }
      // Freetalk의 경우
      if (context.watch<Mypage>().top_index == 2) {
        for (var data in context.watch<Mypage>().Freetalk[index]['filter']) {
          for (var selected in context.watch<Mypage>().Selected_list) {
            // print(data);
            // print(selected);
            if (data.indexOf(selected) == 0) {
              // 피드에 포함된 필터가 선택되어 있는 경우에는 다시 true로 return
              context.watch<Mypage>().check = true;
            }
          }
        }
      }
      // Recipe의 경우
      if (context.watch<Mypage>().top_index == 3) {
        for (var data in context.watch<Mypage>().Recipe[index]['filter']) {
          for (var selected in context.watch<Mypage>().Selected_list) {
            // print(data);
            // print(selected);
            if (data.indexOf(selected) == 0) {
              // 피드에 포함된 필터가 선택되어 있는 경우에는 다시 true로 return
              context.watch<Mypage>().check = true;
            }
          }
        }
      }
    }
  }

  //init
  bool like_check = false;
  bool bookmark_check = false;
  @override
  Widget build(BuildContext context) {
    // 데이터 로딩이 완료된 후에 렌더링
    if (context.watch<Mypage>().Feed_image_loading == true) {
      if (context.watch<Mypage>().top_index == 1) {
        if (context.watch<Mypage>().Feed[widget.index]['like'] != null) {
          for (var like_id in context.watch<Mypage>().Feed[widget.index]
              ['like']) {
            if (like_id['value'] == auth.currentUser?.email) {
              like_check = true;
            }
          }
        }
        if (context.watch<Mypage>().Feed[widget.index]['bookmark'] != null) {
          // print(context.watch<Mypage>().Feed[widget.index]['bookmark']);
          for (var bookmark_id in context.watch<Mypage>().Feed[widget.index]
              ['bookmark']) {
            if (bookmark_id['value'] == auth.currentUser?.email) {
              bookmark_check = true;
            }
          }
        }
      }

      if (context.watch<Mypage>().top_index == 2) {
        if (context.watch<Mypage>().Freetalk[widget.index]['like'] != null) {
          for (var like_id in context.watch<Mypage>().Freetalk[widget.index]
              ['like']) {
            if (like_id['value'] == auth.currentUser?.email) {
              like_check = true;
            }
          }
        }
        if (context.watch<Mypage>().Freetalk[widget.index]['bookmark'] !=
            null) {
          // print(context.watch<Mypage>().Freetalk[widget.index]['bookmark']);
          for (var bookmark_id in context.watch<Mypage>().Freetalk[widget.index]
              ['bookmark']) {
            if (bookmark_id['value'] == auth.currentUser?.email) {
              bookmark_check = true;
            }
          }
        }
      }
      if (context.watch<Mypage>().top_index == 3) {
        if (context.watch<Mypage>().Recipe[widget.index]['like'] != null) {
          for (var like_id in context.watch<Mypage>().Recipe[widget.index]
              ['like']) {
            if (like_id['value'] == auth.currentUser?.email) {
              like_check = true;
            }
          }
        }
        if (context.watch<Mypage>().Recipe[widget.index]['bookmark'] != null) {
          // print(context.watch<Mypage>().Recipe[widget.index]['bookmark']);
          for (var bookmark_id in context.watch<Mypage>().Recipe[widget.index]
              ['bookmark']) {
            if (bookmark_id['value'] == auth.currentUser?.email) {
              bookmark_check = true;
            }
          }
        }
      }

      return Column(
        children: <Widget>[
          // 이미지
          GestureDetector(
            onTap: () async {
              if (context.read<Mypage>().top_index == 3) {
                // 데이터 전달하기
                context
                    .read<Recipe>()
                    .select_data(context.read<Mypage>().Recipe[widget.index]);
                // 페이지 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecipePage()),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.only(left: 20),
              height: 350,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                ),
                itemCount: context.watch<Mypage>().top_index == 1
                    ? context.watch<Mypage>().Feed[widget.index]['image'].length
                    : (context.watch<Mypage>().top_index == 2
                        ? context
                            .watch<Mypage>()
                            .Freetalk[widget.index]['image']
                            .length
                        : context
                            .watch<Mypage>()
                            .Recipe[widget.index]['image']
                            .length),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return Container(
                    child: Image.network(context.watch<Mypage>().top_index == 1
                        ? (context.watch<Mypage>().Feed[widget.index]['image']
                            [index]['value'])
                        : (context.watch<Mypage>().top_index == 2
                            ? context.watch<Mypage>().Freetalk[widget.index]
                                ['image'][index]['value']
                            : context.watch<Mypage>().Recipe[widget.index]
                                ['image'][index]['value'])),
                  );
                  return Container();
                },
              ),
            ),
          ),
          // 제목
          if (context.watch<Mypage>().top_index == 3)
            Text(
              context.watch<Mypage>().Recipe[widget.index]['title'],
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          // 레시피 작성자
          if (context.watch<Mypage>().top_index == 3)
            Text(
              context.watch<Mypage>().Recipe[widget.index]['user'],
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),

          // 피드 아이콘 => 좋아요 / 댓글 / 북마크
          if (context.watch<Mypage>().top_index != 3)
            Row(
              children: <Widget>[
                IconButton(
                  icon: like_check == true
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border),
                  onPressed: () {
                    Like_Click(like_check, widget.index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.question_answer_outlined),
                  onPressed: () {
                    // index 설정
                    context.read<Reply>().select_index(widget.index);
                    // 페이지 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReplyPage()),
                    );
                  },
                ),
                IconButton(
                  icon: bookmark_check == true
                      ? Icon(Icons.bookmark_add)
                      : Icon(Icons.bookmark_add_outlined),
                  onPressed: () {
                    Bookmark_Click(bookmark_check, widget.index);
                  },
                ),
              ],
            ),
          // 좋아요 개수
          if (context.watch<Mypage>().top_index != 3 &&
              context.watch<Mypage>().Feed[widget.index]['like'] != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  context.watch<Mypage>().top_index == 1
                      ? ("좋아요" +
                          context
                              .watch<Mypage>()
                              .Feed[widget.index]['like']
                              .length
                              .toString() +
                          "개")
                      : (context.watch<Mypage>().top_index == 2
                          ? ("좋아요" +
                              context
                                  .watch<Mypage>()
                                  .Freetalk[widget.index]['like']
                                  .length
                                  .toString() +
                              "개")
                          : ("좋아요" +
                              context
                                  .watch<Mypage>()
                                  .Recipe[widget.index]['like']
                                  .length
                                  .toString() +
                              "개")),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          // 아이디
          if (context.watch<Mypage>().top_index != 3)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  context.watch<Mypage>().top_index == 1
                      ? (context.watch<Mypage>().Feed[widget.index]['nickname'])
                      : (context.watch<Mypage>().Freetalk[widget.index]
                          ['nickname']),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          // 본문 내용
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                context.watch<Mypage>().top_index == 1
                    ? (context.watch<Mypage>().Feed[widget.index]['content'])
                    : (context.watch<Mypage>().top_index == 2
                        ? context.watch<Mypage>().Freetalk[widget.index]
                            ['content']
                        : context.watch<Mypage>().Recipe[widget.index]
                            ['content']),
                style: TextStyle(fontSize: 14, color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          // Feed 댓글 2개 이상일 때
          if (context.watch<Mypage>().top_index == 1 &&
              context.watch<Mypage>().Feed[widget.index]['reply'] != null &&
              context.watch<Mypage>().Feed[widget.index]['reply'].length > 2)
            GestureDetector(
              onTap: () async {
                // index 설정
                context.read<Reply>().select_index(widget.index);
                // 페이지 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReplyPage()),
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                      '댓글 ${context.watch<Mypage>().Feed[widget.index]['reply'].length}개 모두 보기'),
                ),
              ),
            ),

          // Start : Feed 댓글 2개 미리보기 => 2개 이하인 경우에는 전부 / 2개 이상인 경우에는 2개만
          if (context.watch<Mypage>().top_index == 1 &&
              context.watch<Mypage>().Feed[widget.index]['reply'] != null &&
              context.watch<Mypage>().Feed[widget.index]['reply'].length != 0 &&
              context.watch<Mypage>().Feed[widget.index]['reply'].length < 3)
            for (var reply in context.watch<Mypage>().Feed[widget.index]
                ['reply'])
              Align(
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('${reply['nickname']} ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('${reply['content']}'),
                  ),
                ]),
              ),
          if (context.watch<Mypage>().top_index == 1 &&
              context.watch<Mypage>().Feed[widget.index]['reply'] != null &&
              context.watch<Mypage>().Feed[widget.index]['reply'].length != 0 &&
              context.watch<Mypage>().Feed[widget.index]['reply'].length > 2)
            Align(
              alignment: Alignment.centerLeft,
              child: Column(children: [
                Row(children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        '${context.watch<Mypage>().Feed[widget.index]['reply'][0]['nickname']} ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        '${context.watch<Mypage>().Feed[widget.index]['reply'][0]['content']}'),
                  ),
                ]),
                Row(children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        '${context.watch<Mypage>().Feed[widget.index]['reply'][1]['nickname']} ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        '${context.watch<Mypage>().Feed[widget.index]['reply'][1]['content']}'),
                  ),
                ]),
              ]),
            ),

          // End : Feed 댓글 2개 미리보기 => 2개 이하인 경우에는 전부 / 2개 이상인 경우에는 2개만

          // Freetalk 댓글
          if (context.watch<Mypage>().top_index == 2 &&
              context.watch<Mypage>().Freetalk[widget.index]['reply'] != null &&
              context.watch<Mypage>().Freetalk[widget.index]['reply'].length >
                  2)
            GestureDetector(
              onTap: () async {
                // 페이지 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReplyPage()),
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                      '댓글 ${context.watch<Mypage>().Freetalk[widget.index]['reply'].length}개 모두 보기'),
                ),
              ),
            ),

          // Start : Freetalk 댓글 2개 미리보기 => 2개 이하인 경우에는 전부 / 2개 이상인 경우에는 2개만
          if (context.watch<Mypage>().top_index == 2 &&
              context.watch<Mypage>().Freetalk[widget.index]['reply'] != null &&
              context.watch<Mypage>().Freetalk[widget.index]['reply'].length !=
                  0 &&
              context.watch<Mypage>().Freetalk[widget.index]['reply'].length <
                  3)
            for (var reply in context.watch<Mypage>().Freetalk[widget.index]
                ['reply'])
              Align(
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('${reply['nickname']} ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('${reply['content']}'),
                  ),
                ]),
              ),
          if (context.watch<Mypage>().top_index == 2 &&
              context.watch<Mypage>().Freetalk[widget.index]['reply'] != null &&
              context.watch<Mypage>().Freetalk[widget.index]['reply'].length !=
                  0 &&
              context.watch<Mypage>().Freetalk[widget.index]['reply'].length >
                  2)
            Align(
              alignment: Alignment.centerLeft,
              child: Column(children: [
                Row(children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        '${context.watch<Mypage>().Freetalk[widget.index]['reply'][0]['nickname']} ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        '${context.watch<Mypage>().Freetalk[widget.index]['reply'][0]['content']}'),
                  ),
                ]),
                Row(children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        '${context.watch<Mypage>().Freetalk[widget.index]['reply'][1]['nickname']} ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        '${context.watch<Mypage>().Freetalk[widget.index]['reply'][1]['content']}'),
                  ),
                ]),
              ]),
            ),

          // End : Freetalk 댓글 2개 미리보기 => 2개 이하인 경우에는 전부 / 2개 이상인 경우에는 2개만
        ],
      );
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }
}

// TopBar 기본 class
class TopBar extends StatefulWidget {
  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 7, 0, 7),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                context.read<Mypage>().select_top(1);
                setState(() {});
              },
              child: Column(
                children: <Widget>[
                  Text(
                    '식사',
                    style: TextStyle(
                        fontSize: 18,
                        color: context.watch<Mypage>().top_index == 1
                            ? Colors.purple
                            : Colors.grey),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border(
                          bottom: BorderSide(
                              width: context.watch<Mypage>().top_index == 1
                                  ? 3.0
                                  : 2.0,
                              color: context.watch<Mypage>().top_index == 1
                                  ? Colors.purple
                                  : Colors.grey)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                context.read<Mypage>().select_top(2);
                setState(() {});
              },
              child: Column(
                children: <Widget>[
                  Text(
                    '자유 수다방',
                    style: TextStyle(
                        fontSize: 18,
                        color: context.watch<Mypage>().top_index ==
                                2 // 수정 시 재빌드하기 위해서는 watch를 사용
                            ? Colors.purple
                            : Colors.grey),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border(
                          bottom: BorderSide(
                              width: context.watch<Mypage>().top_index == 2
                                  ? 3.0
                                  : 2.0,
                              color: context.watch<Mypage>().top_index == 2
                                  ? Colors.purple
                                  : Colors.grey)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 로그인 기본 class
class MywritePage extends StatefulWidget {
  @override
  _MywritePageState createState() => _MywritePageState();
}

class _MywritePageState extends State<MywritePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // 로그인 상태인지 확인
    // print(auth.currentUser);
    if (auth.currentUser != null) {
      // print(auth.currentUser!.email);
    }

    context.read<Mypage>().get_data(auth.currentUser?.email);
    // listener를 추가하여 비동기 변경이 발생했을 때 수정할 수 있도록 changeNotifier를 듣고 있음
    Provider.of<Mypage>(context, listen: false).addListener(() => setState(() {
          print("리렌더링2");
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(backgroundColor: Colors.transparent, title: Text("내가 쓴 글")),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 메인 상단 메뉴
            TopBar(),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: context.read<Mypage>().top_index == 1
                    ? (context.read<Mypage>().Feed.length)
                    : (context.read<Mypage>().top_index == 2
                        ? context.read<Mypage>().Freetalk.length
                        : context.read<Mypage>().Recipe.length),
                itemBuilder: (BuildContext context, int index) {
                  return Feed(index);
                }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (index) => {
                // 홈
                if (index == 0)
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    ),
                  },

                // 글쓰기
                if (auth.currentUser != null && index == 1)
                  {
                    context.read<Write>().init(), // 글 쓸 때 이미지 초기화
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WritePage()),
                    ),
                  },

                // 스크랩
                if (index == 2)
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScrapPage()),
                    ),
                  },

                // 마이페이지
                if (index == 3)
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPage()),
                    ),
                  },
              },
          currentIndex: 0,
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('홈'),
            ),
            if (auth.currentUser != null)
              new BottomNavigationBarItem(
                icon: Icon(Icons.add),
                title: Text('글쓰기'),
              ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              title: Text('스크랩'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('마이페이지'),
            )
          ]),
    );
  }
}
