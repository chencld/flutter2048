/*
 * @Author: lidan6
 * @Date: 2020-10-13 14:41:47
 * @LastEditors: lidan6
 * @LastEditTime: 2020-10-20 17:46:28
 * @Description: 
 */
import 'dart:ui';
import 'package:flutter/material.dart';

final chessColors = < int, Color > {
  0: Color.fromRGBO(238, 228, 218, 0.35),
  2: Color(0xffeee4da),
  4: Color(0xffede0c8),
  8: Color(0xfff2b179),
  16: Color(0xfff59563),
  32: Color(0xfff67c5f),
  64: Color(0xfff65e3b),
  128: Color(0xffedcf72),
  256: Color(0xffedcc61),
  512: Color(0xffedc850),
  1024: Color(0xffedc53f),
  2048: Color(0xffedc22e),
};

class ChessMan extends StatelessWidget  {
  double left;
  double top;
  double size;
  double ratio;
  int number;

  ChessMan({
    this.left,
    this.top,
    this.size,
    this.ratio,
    this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      width: size,
      height: size,
      child: AnimatedContainer(
        alignment: Alignment.center,
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: chessColors.containsKey(number) ?
          chessColors[number] :
          Color.fromRGBO(238, 228, 218, 0.35),
          borderRadius: BorderRadius.all(Radius.circular(3))
        ),
        child: Text(
          number == 0 ? '' : number.toString(),
          style: TextStyle(
            color: Color(0xFF776e65),
            fontWeight: FontWeight.bold,
            fontSize: 40 * ratio,
          ),
        ),
      ),
    );
  }
}