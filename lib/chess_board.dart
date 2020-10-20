/*
 * @Author: lidan6
 * @Date: 2020-10-13 14:41:38
 * @LastEditors: lidan6
 * @LastEditTime: 2020-10-20 17:43:11
 * @Description: 
 */
//import 'dart:ui' as dartUi;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter2048/chess_model.dart';
import 'package:flutter2048/chess_man.dart';

class ChessBoard extends StatefulWidget {
  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State < ChessBoard >{
  bool _isDragging = false;
  @override
  Widget build(BuildContext context) {
    final double aWidth = window.physicalSize.width - 100;
    final double width = aWidth / window.devicePixelRatio;
    final double ratio = width / 500;
    final double itemSpace = 15 * ratio;
    final double itemWidth = (width - itemSpace * 5) / 4;

    var chessmodel = Provider.of<ChessModel>(context,listen: false);
    //初始化棋盘数据
    chessmodel.loadBest();
    chessmodel.creatList();
    int size = chessmodel.chessdata["size"];
    
    return Center(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Container(
            height: 112*ratio,
            margin: EdgeInsets.all(25),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  margin: EdgeInsets.only(right:10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xffbbada0),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Text(
                        "SCORE",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffeee4da)
                        ),
                      ),
                      Consumer < ChessModel > (
                        builder: (context, ChessModel chessmodel, _) {
                          return Text(
                            chessmodel.chessdata["score"].toString(),
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white
                            ),
                          );
                        }
                      )
                    ]
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  margin: EdgeInsets.only(right:25),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xffbbada0),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Text(
                        "BEST",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffeee4da)
                        ),
                      ),
                      Consumer < ChessModel > (
                        builder: (context, ChessModel chessmodel, _) {
                          return Text(
                            chessmodel.chessdata["bestScore"].toString(),
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white
                            ),
                          );
                        }
                      )
                    ]
                  ),
                ),
                Expanded(
                  child:FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () { 
                      chessmodel.initList();
                    },
                    child: Container(
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Color(0xff8f7a66),
                      ),
                      child: Text(
                        "New Game",
                        style: TextStyle(
                          color: Color(0xfff9f6f2),
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),
                      ),
                    ),
                  )
                )
              ],
            )
          ),
          GestureDetector(
            onVerticalDragUpdate: (detail) {
              if (detail.delta.distance == 0 || _isDragging) return;
              _isDragging = true;
              if (detail.delta.direction > 0) chessmodel.moveDown();
              else chessmodel.moveUp();
            },
            onVerticalDragEnd: (detail) {
              _isDragging = false;
            },
            onVerticalDragCancel: () {
              _isDragging = false;
            },
            onHorizontalDragUpdate: (detail) {
              if (detail.delta.distance == 0 || _isDragging) return;
              _isDragging = true;
              if (detail.delta.direction > 0) chessmodel.moveLeft();
              else chessmodel.moveRight();
            },
            onHorizontalDragDown: (detail) {
              _isDragging = false;
            },
            onHorizontalDragCancel: () {
              _isDragging = false;
            },
            child: Stack(
              children:[
                //棋盘
                Container(
                  padding: EdgeInsets.all(itemSpace),
                  width: width,
                  height: width,
                  decoration: BoxDecoration(
                    color: Color(0xFFbbada0),
                    borderRadius: BorderRadius.all(Radius.circular(6))
                  ),
                  child: GridView.count(
                    padding: EdgeInsets.all(0),
                    crossAxisCount: size,
                    mainAxisSpacing: itemSpace,
                    crossAxisSpacing: itemSpace,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(16, (i) {
                      return Container(
                        color: Color.fromRGBO(238, 228, 218, 0.35)
                      );
                    }),
                  ),
                ),
                //棋子
                Positioned(
                  left: 0,
                  top: 0,
                  width: width,
                  height: width,
                  child: Consumer < ChessModel > (
                    builder: (context, ChessModel chessmodel, _) {
                      var _chessList = chessmodel.chessdata["chessList"];
                      List<Widget> _widgets=[];
                      for(int i=0;i<size;i++){
                        for(int j=0;j<size;j++){
                          Chess _chess = _chessList[i][j];
                          //if(_chess.number>0){
                            _widgets.add(ChessMan(
                              left: (itemSpace + itemWidth) * _chess.column + itemSpace,
                              top: (itemSpace + itemWidth) * _chess.row + itemSpace,
                              size: itemWidth,
                              number:_chess.number,
                              ratio:ratio,
                            ));
                          //}
                        }
                      }
                      return Stack(
                        children:_widgets
                      );
                    }
                  )
                ),
                //成功弹框
                Consumer < ChessModel > (
                  builder: (context, ChessModel chessmodel, _) {
                    return ChessDialog(
                      wcontext:context,
                      width: width,
                      height: width,
                      show: chessmodel.chessdata["succtag"] != 1,
                      titleStr: "Congratulations!",
                      buttonStr: "Keep Going",
                      callback: (){
                        chessmodel.setSuccTag();

                      }
                    );
                  }
                ),
                //失败弹框
                Consumer < ChessModel > (
                  builder: (context, ChessModel chessmodel, _) {
                    return ChessDialog(
                      width: width,
                      height: width,
                      wcontext:context,
                      show: !chessmodel.chessdata["failtag"],
                      titleStr: "Game over!",
                      buttonStr: "New Game",
                      callback: (){
                        chessmodel.initList();

                      }
                    );
                  }
                )
              ]
            )
          ),
        ]
      )
    );
  }
}

class ChessDialog extends StatelessWidget{
  BuildContext wcontext;
  bool show;
  double width;
  double height;
  String titleStr;
  String buttonStr;
  Function callback;

  ChessDialog({
    this.wcontext,
    this.show,
    this.width,
    this.height,
    this.titleStr,
    this.buttonStr,
    this.callback
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: width,
      height: width,
      left: 0,
      top: 0,
      child: Offstage(
        offstage:show,
        child:Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.fromRGBO(238, 228, 218, 0.5)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Text(
                titleStr,
                style: TextStyle(
                  color: Color(0xff776e65),
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ),
              ),
              FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: () { 
                  callback();
                },
                child:Container(
                  width: 120,
                  height:40,
                  margin: EdgeInsets.only(top:20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Color(0xff8f7a66),
                  ),
                  child: Text(
                    buttonStr,
                    style: TextStyle(
                      color: Color(0xfff9f6f2),
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                )
              )
            ]
          ),
        )
      )
    );
  }
}