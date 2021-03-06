import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdmzj/component/LoadingRow.dart';
import 'package:flutterdmzj/component/LoadingTile.dart';
import 'package:flutterdmzj/http/http.dart';
import 'package:flutterdmzj/view/ranking_page.dart';

class LatestUpdatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LatestUpdatePage();
  }
}

class _LatestUpdatePage extends State<LatestUpdatePage> {
  int filterTag = 100;
  int page = 0;
  bool refreshState = false;
  List list = <Widget>[LoadingTile()];
  Map tagTypeList = <int, String>{100: '全部漫画', 1: '原创漫画', 0: '译制漫画'};
  ScrollController _controller = ScrollController();

  getLatestList() async {
    CustomHttp http = CustomHttp();
    var response = await http.getLatestList(filterTag, page);
    if (response.statusCode == 200 && mounted) {
      setState(() {
        if (page == 0) {
          list.clear();
        } else {
          list.removeLast();
        }
        if (response.data.length == 0) {
          refreshState = true;
          return;
        }
        for (var item in response.data) {
          list.add(CustomListTile(item['cover'], item['title'], item['types'],
              item['last_updatetime'], item['id'].toString(), item['authors']));
        }
        refreshState = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLatestList();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent &&
          !refreshState) {
        setState(() {
          refreshState = true;
          page++;
          list.add(LoadingTile());
        });
        getLatestList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RefreshIndicator(
      onRefresh: () async {
        if (!refreshState) {
          setState(() {
            refreshState = true;
            page = 0;
            list.clear();
            list.add(LoadingTile());
          });
          await getLatestList();
        }
        return;
      },
      child: Scrollbar(
        child: SingleChildScrollView(
          controller: _controller,
          child: Container(
              margin: EdgeInsets.fromLTRB(3, 0, 0, 10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('当前:${tagTypeList[filterTag]}'),
                      ),
                      FlatButton(
                        child: Icon(Icons.filter_list),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                    height: 100,
                                    child: ListView(
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(Icons.list),
                                          title: Text('按分类'),
                                          subtitle:
                                              Text(tagTypeList[filterTag]),
                                          trailing: PopupMenuButton(
                                            child: Icon(Icons.arrow_drop_down),
                                            onSelected: (int value) {
                                              setState(() {
                                                filterTag = value;
                                                setState(() {
                                                  list.clear();
                                                  page = 0;
                                                });
                                                getLatestList();
                                                Navigator.pop(context);
                                              });
                                            },
                                            itemBuilder: (context) {
                                              var data = <PopupMenuItem<int>>[];
                                              tagTypeList.forEach((key, value) {
                                                data.add(PopupMenuItem(
                                                    child: Text(value),
                                                    value: key));
                                              });
                                              return data;
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              });
                        },
                      )
                    ],
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return list[index];
                    },
                  )
                ],
              )),
        ),
      ),
    );
  }
}
