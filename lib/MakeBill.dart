//import 'dart:js';
//import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:card_settings/card_settings.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class MakeBill extends StatefulWidget {
  MakeBill({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MakeBillState createState() => _MakeBillState();
}

class _MakeBillState extends State<MakeBill> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> types = ['Gold', 'Silver', 'Bronze'];
  String defaultType = 'Gold';
  final _Name = TextEditingController();
  final _Item = TextEditingController();

  String defaultItem = '';
  String defaultName = '';
  String defaultNote = '';

  String searchString;
  bool activateSuggestion = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        print("show");

      } else {
        print("removed");
        _focusNode.unfocus();
        activateSuggestion = false;
        print(activateSuggestion);
      }
    });
  }

  @override
  void dispose(){
    _Name.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Flexible(
                  flex: 5,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: CardSettings(
                          children: <CardSettingsSection>[
                            CardSettingsSection(
                              header: CardSettingsHeader(
                                label: 'Create order',
                                labelAlign: TextAlign.center,
                              ),
                              children: <CardSettingsWidget>[
                                CardSettingsText(
                                  focusNode: this._focusNode,
                                  controller: _Name,
                                  onChanged: (value){
                                    setState(() {
                                      searchString = value.toLowerCase();
                                      activateSuggestion = true;
                                    });
                                  },
                                  label: 'Buyer',
                                  requiredIndicator: Text('*', style: TextStyle(color: Colors.red)), // puts an optional indicator to the right of the label
                                  textCapitalization: TextCapitalization.words,
                                  initialValue: defaultName,
                                  validator: (value) {
                                    if (value == null || value.isEmpty){
                                      return 'Name is required.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) => defaultName = value,
                                ),
                                CardSettingsListPicker(
                                  label: 'Type',
                                  options: types,
                                  initialValue: defaultType,
                                  requiredIndicator: Text('*', style: TextStyle(color: Colors.red)), // puts an optional indicator to the right of the label
                                  onSaved: (value) => defaultType = value,
                                ),
                                CardSettingsText(
                                  label: 'Item',
                                  controller: _Item,
                                  textCapitalization: TextCapitalization.sentences,
                                  initialValue: defaultItem,
                                  onChanged: (value){
                                    setState(() {
                                      activateSuggestion = false;
                                    });
                                  },
                                  requiredIndicator: Text('*', style: TextStyle(color: Colors.red)), // puts an optional indicator to the right of the label
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Item is required.';
                                    return null;
                                  },
                                  onSaved: (value) => defaultItem = value,
                                ),

                                CardSettingsText(
                                  label: 'Notes',
                                  onSaved: (value) => defaultNote = value,
                                ),

                                CardSettingsButton(
                                  label: 'Create',
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  showMaterialonIOS: true,
                                  onPressed: (){
                                    if(_Name.text == null || _Name.text.isEmpty || _Item.text == null || _Item.text.isEmpty ){
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.ERROR,
                                        animType: AnimType.BOTTOMSLIDE,
                                        title: 'OOPS!',
                                        desc: 'something is missing',
//                                        btnOk: FlatButton(
//                                          child: Text(
//                                            "Ok",
//                                            style: TextStyle(fontSize: 20.0, color: Colors.white),
//                                          ),
//                                          textColor: Colors.white,
//                                          disabledColor: Colors.black,
//                                          color: Colors.white,
//                                          splashColor: Colors.white,
//                                        ),
//                                        btnOkOnPress: () {
//                                        },
                                        btnCancelOnPress: (){
                                        }
                                      )..show();
                                    }
                                    else {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.SUCCES,
                                        animType: AnimType.BOTTOMSLIDE,
                                        title: 'Dialog Title',
                                        desc: 'Dialog description here.............',
                                        btnCancelOnPress: () {},
                                        btnOkOnPress: () {},
                                      )..show();
                                      _createOrder(_Name.text);
                                    }
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _focusNode.hasFocus && _Name.text != "" && activateSuggestion?
                Flexible(
                  flex: 1,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: (searchString == null || searchString.trim() == "") ?
                    Firestore.instance.collection("users").snapshots()
                        : Firestore.instance.collection("users")
                        .where("searchIndex", arrayContains: searchString)
                        .snapshots(),
                    builder: (context, snapshot){
                      if(snapshot.hasError)
                        return  Text('Error: ${snapshot.error}');
                      switch (snapshot.connectionState){
                        case ConnectionState.waiting:
                          return  Center(child: CircularProgressIndicator());
                        case ConnectionState.active:
                          return  _focusNode.hasFocus ? ListView(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: snapshot.data.documents.map((DocumentSnapshot document){
                              return new ListTile(
                                title: new Text(document['name']),
                                leading: Icon(Icons.arrow_forward),
                                onTap: (){
                                  setState(() {
                                    _Name.text = document['name'];
                                    activateSuggestion = false;
                                  });
                                },
                              );
                            }).toList(),
                          ) : Container();
                        default:
                          return Container();
                      }
                    },
                  ),
                )
                    : Container(color: Colors.blue,)
              ],
            ),
          )
        ],
      ),
    );
  }
}


void _createOrder(String name){
  List<String> splitList = name.split(" ");

  List<String> indexList = [];

  for(int i = 0; i < splitList.length; i++){
    for(int j = 1; j < splitList[i].length+1; j++){
      indexList.add(splitList[i].substring(0, j).toLowerCase());
    }
  }
  print(indexList);

//  Firestore.instance.runTransaction((transaction) async {
//    DocumentSnapshot freshSnap = await transaction.get(document.reference);
//  })

//  Firestore.instance.collection('users').document().setData({
//    'name': name,
//    'searchIndex' : indexList
//  });

}

