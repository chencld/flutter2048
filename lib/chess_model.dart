/*
 * @Author: lidan6
 * @Date: 2020-10-13 14:41:38
 * @LastEditors: lidan6
 * @LastEditTime: 2020-10-20 17:50:54
 * @Description: 
 */
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChessModel with ChangeNotifier {
  List < List < Chess >> _chesslist = List < List < Chess >>();
  final int _size = 4;
  int _chessScore = 0;
  int _bestScore = 0;
  int _succtag = 0;
  bool _failtag = false;
  Map get chessdata => {
    "chessList": _chesslist,
    "size": _size,
    "score": _chessScore,
    "bestScore": _bestScore,
    "succtag":_succtag,
    "failtag":_failtag
  };
  void creatList(){
    _chesslist = List < List < Chess >>();
    for (int r = 0; r < _size; ++r) {
      _chesslist.add(List < Chess > ());
      for (int c = 0; c < _size; ++c) {
        _chesslist[r].add(Chess(
          row: r,
          column: c,
          number: 0,
        ));
      }
    }
    resetMergeStatus();
    getRandomChess(2);
  }
  void initList() {
    creatList();
    _chessScore = 0;
    _failtag = false;
    _succtag = 0;
    notifyListeners();
  }

  //Loading counter value on start
  loadBest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _bestScore = (prefs.getInt('bestscore') ?? 0);
    notifyListeners();
  }

  setBest(score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _bestScore = score;
    prefs.setInt('bestscore', score);
  }

  setSuccTag(){
    _succtag = 2;
    notifyListeners();
  }
  int chessNum() {
    final Random r = Random();
    return r.nextInt(10) >=7 ? 4 : 2;
  }
  void getRandomChess(int num) {
    List<Chess> randomChess = [];
    _chesslist.forEach((chessItem) {
      randomChess.addAll(chessItem.where((chess) {
        return chess.isEmpty();
      }));
    });
    if (randomChess.isEmpty) {
      return;
    }
    Random r = Random();
    for (int i = 0; i < num&&randomChess.isNotEmpty; i++) {
      int index = r.nextInt(randomChess.length);
      randomChess[index].number = chessNum();
      randomChess.removeAt(index);
    }
  }
  void resetMergeStatus() {
    _chesslist.forEach((chessItem) {
      chessItem.forEach((cell) {
        cell.isMerged = false;
      });
    });
  }
  
  bool canMerge(Chess a, Chess b) {
    return !a.isMerged&&((a.number==0 && b.number>0) || (a.number>0 && a.number == b.number));
  }

  bool canMoveLeft() {
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size-1; c++) {
        if (canMerge(_chesslist[r][c], _chesslist[r][c + 1])) {
          return true;
        }
      }
    }
    return false;
  }
  bool canMoveRight() {
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size-1; c++) {
        if (canMerge(_chesslist[r][c+1], _chesslist[r][c])) {
          return true;
        }
      }
    }
    return false;
  }
  bool canMoveUp() {
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size-1; c++) {
        if (canMerge(_chesslist[c][r],_chesslist[c+1][r])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveDown() {
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size-1; c++) {
        if (canMerge(_chesslist[c+1][r], _chesslist[c][r])) {
          return true;
        }
      }
    }
    return false;
  }

  void mergeChess(Chess a, Chess b) {
    if (!canMerge(a, b)) {
      if (!b.isEmpty() && !a.isMerged) {
        a.isMerged = true;
      }
      return;
    }
    if (a.isEmpty()) {
      a.number = b.number;
      b.number = 0;
      if(a.number >= 2048 && _succtag == 0) _succtag = 1;
    } else if (a.number == b.number) {
      a.number = a.number * 2;
      b.number = 0;
      _chessScore += a.number;
      if(_chessScore > _bestScore) setBest(_chessScore);
      if(a.number >= 2048 && _succtag == 0) _succtag = 1;
      a.isMerged = true;
    } else {
      a.isMerged = true;
    }
  }
  void mergeLeft(int r, int c) {
    while (c > 0) {
      mergeChess(_chesslist[r][c - 1], _chesslist[r][c]);
      c--;
    }
  }
  void mergeRight(int r, int c) {
    while (c < _size - 1) {
      mergeChess(_chesslist[r][c + 1], _chesslist[r][c]);
      c++;
    }
  }
  void mergeUp(int r, int c) {
    while (r > 0) {
      mergeChess(_chesslist[r - 1][c], _chesslist[r][c]);
      r--;
    }
  }

  void mergeDown(int r, int c) {
    while (r < _size - 1) {
      mergeChess(_chesslist[r + 1][c], _chesslist[r][c]);
      r++;
    }
  }
  void moveLeft() {
    if (!canMoveLeft()) {
      return;
    }
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        mergeLeft(r, c);
      }
    }
    getRandomChess(1);
    resetMergeStatus();
    _failtag = isGameOver();
    notifyListeners();
  }

  void moveRight() {
    if (!canMoveRight()) {
      return;
    }
    for (int r = 0; r < _size; r++) {
      for (int c = _size - 2; c >= 0; c--) {
        mergeRight(r, c);
      }
    }
    getRandomChess(1);
    resetMergeStatus();
    _failtag = isGameOver();
    notifyListeners();
  }
  void moveUp() {
    if (!canMoveUp()) {
      return;
    }
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        mergeUp(r, c);
      }
    }
    getRandomChess(1);
    resetMergeStatus();
    _failtag = isGameOver();
    notifyListeners();
  }

  void moveDown() {
    if (!canMoveDown()) {
      return;
    }
    for (int r = _size - 2; r >= 0; r--) {
      for (int c = 0; c < _size; c++) {
        mergeDown(r, c);
      }
    }
    getRandomChess(1);
    resetMergeStatus();
    _failtag = isGameOver();
    notifyListeners();
  }

  bool isGameOver() {
    return !canMoveLeft() && !canMoveRight() && !canMoveUp() && !canMoveDown();
  }
}

class Chess {
  int row;
  int column;
  int number = 0;
  bool isMerged = false;
  Chess({
    this.row,
    this.column,
    this.number,
  });
  bool isEmpty() {
    return number == 0;
  }
}