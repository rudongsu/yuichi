import 'package:flutter/material.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'Summary.dart';
import 'MakeBill.dart';
import 'Search.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex;
  PageController _pageController;

  @override
  void initState(){
    super.initState();
    _pageController = PageController(initialPage: 1);
    selectedIndex = 1;
  }

  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  pageChange(int pageIndex){
    setState(() {
      this.selectedIndex = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
           children: <Widget>[
             Search(),
             MakeBill(),
             Summary(),
           ],
           controller: _pageController,
           onPageChanged: pageChange,
      ),

      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          selectedItemBorderColor: Colors.white,
          selectedItemBackgroundColor: Colors.black,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
        ),
        selectedIndex: selectedIndex,
        onSelectTab: (index) {
          setState(() {
            selectedIndex = index;
            _pageController.animateToPage(index, duration: Duration(milliseconds: 400), curve: Curves.fastOutSlowIn);
          });
        },
        items: [
          FFNavigationBarItem(
            iconData: Icons.people,
            label: 'Customers',
          ),
          FFNavigationBarItem(
            iconData: Icons.attach_money,
            label: 'Order',
          ),
          FFNavigationBarItem(
            iconData: Icons.note,
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}
