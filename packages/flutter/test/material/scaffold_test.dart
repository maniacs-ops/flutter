// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  testWidgets('Scaffold control test', (WidgetTester tester) async {
    Key bodyKey = new UniqueKey();
    await tester.pumpWidget(new Scaffold(
      appBar: new AppBar(title: new Text('Title')),
      body: new Container(key: bodyKey)
    ));

    RenderBox bodyBox = tester.renderObject(find.byKey(bodyKey));
    expect(bodyBox.size, equals(new Size(800.0, 544.0)));

    await tester.pumpWidget(new MediaQuery(
      data: new MediaQueryData(padding: new EdgeInsets.only(bottom: 100.0)),
      child: new Scaffold(
        appBar: new AppBar(title: new Text('Title')),
        body: new Container(key: bodyKey)
      )
    ));

    bodyBox = tester.renderObject(find.byKey(bodyKey));
    expect(bodyBox.size, equals(new Size(800.0, 444.0)));

    await tester.pumpWidget(new MediaQuery(
      data: new MediaQueryData(padding: new EdgeInsets.only(bottom: 100.0)),
      child: new Scaffold(
        appBar: new AppBar(title: new Text('Title')),
        body: new Container(key: bodyKey),
        resizeToAvoidBottomPadding: false
      )
    ));

    bodyBox = tester.renderObject(find.byKey(bodyKey));
    expect(bodyBox.size, equals(new Size(800.0, 544.0)));
  });

  testWidgets('Floating action animation', (WidgetTester tester) async {
    await tester.pumpWidget(new Scaffold(
      floatingActionButton: new FloatingActionButton(
        key: new Key("one"),
        onPressed: null,
        child: new Text("1")
      )
    ));

    expect(tester.binding.transientCallbackCount, 0);

    await tester.pumpWidget(new Scaffold(
      floatingActionButton: new FloatingActionButton(
        key: new Key("two"),
        onPressed: null,
        child: new Text("2")
      )
    ));

    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.pumpWidget(new Container());
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(new Scaffold());
    expect(tester.binding.transientCallbackCount, 0);

    await tester.pumpWidget(new Scaffold(
      floatingActionButton: new FloatingActionButton(
        key: new Key("one"),
        onPressed: null,
        child: new Text("1")
      )
    ));

    expect(tester.binding.transientCallbackCount, greaterThan(0));
  });

  testWidgets('Drawer scrolling', (WidgetTester tester) async {
    GlobalKey<ScrollableState<Scrollable>> drawerKey =
        new GlobalKey<ScrollableState<Scrollable>>(debugLabel: 'drawer');
    Key appBarKey = new Key('appBar');
    const double appBarHeight = 256.0;

    await tester.pumpWidget(
      new MaterialApp(
        home: new Scaffold(
          appBarBehavior: AppBarBehavior.under,
          appBar: new AppBar(
            key: appBarKey,
            expandedHeight: appBarHeight,
            title: new Text('Title'),
            flexibleSpace: new FlexibleSpaceBar(title: new Text('Title')),
          ),
          drawer: new Drawer(
            child: new Block(
              scrollableKey: drawerKey,
              children: new List<Widget>.generate(10,
                (int index) => new SizedBox(height: 100.0, child: new Text('D$index'))
              )
            )
          ),
          body: new Block(
            padding: const EdgeInsets.only(top: appBarHeight),
            children: new List<Widget>.generate(10,
              (int index) => new SizedBox(height: 100.0, child: new Text('B$index'))
            ),
          ),
        )
      )
    );

    ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openDrawer();

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(drawerKey.currentState.scrollOffset, equals(0));

    const double scrollDelta = 80.0;
    await tester.scroll(find.byKey(drawerKey), const Offset(0.0, -scrollDelta));
    await tester.pump();

    expect(drawerKey.currentState.scrollOffset, equals(scrollDelta));

    RenderBox renderBox = tester.renderObject(find.byKey(appBarKey));
    expect(renderBox.size.height, equals(appBarHeight));
  });

  testWidgets('Tapping the status bar scrolls to top on iOS', (WidgetTester tester) async {
    final GlobalKey<ScrollableState> scrollableKey = new GlobalKey<ScrollableState>();
    final Key appBarKey = new UniqueKey();

    await tester.pumpWidget(
      new MaterialApp(
        theme: new ThemeData(platform: TargetPlatform.iOS),
        home: new MediaQuery(
          data: new MediaQueryData(padding: const EdgeInsets.only(top: 25.0)), // status bar
          child: new Scaffold(
            scrollableKey: scrollableKey,
            appBar: new AppBar(
              key: appBarKey,
              title: new Text('Title')
            ),
            body: new Block(
              scrollableKey: scrollableKey,
              initialScrollOffset: 500.0,
              children: new List<Widget>.generate(20,
                (int index) => new SizedBox(height: 100.0, child: new Text('$index'))
              )
            )
          )
        )
      )
    );

    expect(scrollableKey.currentState.scrollOffset, equals(500.0));
    await tester.tapAt(const Point(100.0, 10.0));
    await tester.pump();
    await tester.pump(new Duration(seconds: 1));
    expect(scrollableKey.currentState.scrollOffset, equals(0.0));
  });

  testWidgets('Tapping the status bar does not scroll to top on Android', (WidgetTester tester) async {
    final GlobalKey<ScrollableState> scrollableKey = new GlobalKey<ScrollableState>();
    final Key appBarKey = new UniqueKey();

    await tester.pumpWidget(
      new MaterialApp(
        theme: new ThemeData(platform: TargetPlatform.android),
        home: new MediaQuery(
          data: new MediaQueryData(padding: const EdgeInsets.only(top: 25.0)), // status bar
          child: new Scaffold(
            scrollableKey: scrollableKey,
            appBar: new AppBar(
              key: appBarKey,
              title: new Text('Title')
            ),
            body: new Block(
              scrollableKey: scrollableKey,
              initialScrollOffset: 500.0,
              children: new List<Widget>.generate(20,
                (int index) => new SizedBox(height: 100.0, child: new Text('$index'))
              )
            )
          )
        )
      )
    );

    expect(scrollableKey.currentState.scrollOffset, equals(500.0));
    await tester.tapAt(const Point(100.0, 10.0));
    await tester.pump();
    await tester.pump(new Duration(seconds: 1));
    expect(scrollableKey.currentState.scrollOffset, equals(500.0));
  });

  testWidgets('Bottom sheet cannot overlap app bar', (WidgetTester tester) async {
    Key sheetKey = new UniqueKey();

    await tester.pumpWidget(
      new MaterialApp(
        theme: new ThemeData(platform: TargetPlatform.android),
        home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Title')
          ),
          body: new Builder(
            builder: (BuildContext context) {
              return new GestureDetector(
                onTap: () {
                  Scaffold.of(context).showBottomSheet((BuildContext context) {
                    return new Container(
                      key: sheetKey,
                      decoration: new BoxDecoration(backgroundColor: Colors.blue[500])
                    );
                  });
                },
                child: new Text('X')
              );
            }
          )
        )
      )
    );

    await tester.tap(find.text('X'));
    await tester.pump(); // start animation
    await tester.pump(const Duration(seconds: 1));

    RenderBox appBarBox = tester.renderObject(find.byType(AppBar));
    RenderBox sheetBox = tester.renderObject(find.byKey(sheetKey));

    Point appBarBottomRight = appBarBox.localToGlobal(appBarBox.size.bottomRight(Point.origin));
    Point sheetTopRight = sheetBox.localToGlobal(sheetBox.size.topRight(Point.origin));

    expect(appBarBottomRight, equals(sheetTopRight));
  });
}
