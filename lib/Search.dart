import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String searchString;
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: _isSearching ? const BackButton() : Container(),
        title: _buildSearchField(),
        //actions: _buildActions(),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                      hintText: "Search customers...",
                      border: new OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(const Radius.circular(20)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),

                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      fillColor: Colors.white70),
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                  onChanged: (value) {
                    setState(() {
                      searchString = value.toLowerCase();
                      _isSearching = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _isSearching == true
              ? Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: (searchString == null ||
                                  searchString.trim() == "")
                              ? Firestore.instance
                                  .collection("users")
                                  .snapshots()
                              : Firestore.instance
                                  .collection("users")
                                  .where("searchIndex",
                                      arrayContains: searchString)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return Text('Error: ${snapshot.error}');
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Center(
                                    child: CircularProgressIndicator());
                              default:
                                return new ListView(
                                  children: snapshot.data.documents
                                      .map((DocumentSnapshot document) {
                                    return new ListTile(
                                      title: new Text(document['name']),
                                    );
                                  }).toList(),
                                );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget _buildSearchField() {
//    return TextField(
//      controller: _searchQueryController,
//      autofocus: true,
//      decoration: InputDecoration(
//          hintText: "Search customers...",
//          border: new OutlineInputBorder(
//              borderRadius: const BorderRadius.all(const Radius.circular(20)),
//              borderSide: BorderSide.none),
//          prefixIcon: Icon(
//            Icons.search,
//            color: Colors.grey,
//          ),
//          filled: true,
//          hintStyle: new TextStyle(color: Colors.grey[800]),
//          fillColor: Colors.white70),
//      style: TextStyle(color: Colors.black, fontSize: 16.0),
//      onChanged: (query) => updateSearchQuery,
//    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(
            Icons.clear,
            color: Colors.black,
            size: 35.0,
          ),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }
    return <Widget>[
//      RawMaterialButton(
//        child: Icon(
//          Icons.search,
//          color: Colors.grey,
//          size: 35.0,
//        ),
//        onPressed: _startSearch,
//      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      searchString = newQuery.toLowerCase();
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }
}
