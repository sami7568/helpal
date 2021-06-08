import 'package:flutter/material.dart';

class SearchboxSlide extends StatefulWidget {
  @override
  _SearchboxSlideState createState() => _SearchboxSlideState();
}

class _SearchboxSlideState extends State<SearchboxSlide> {
  TextEditingController _searchQueryController = TextEditingController();
  //Animated search box
  bool isSearching = false;
  Widget _buildSearchField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            child: TextField(
              controller: _searchQueryController,
              autofocus: true,
              onEditingComplete: () {
                setState(() {
                  isSearching = false;
                });
              },
              decoration: InputDecoration(
                hintText: "Search Location...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
              onChanged: (query) => {print(MediaQuery.of(context).size.height)},
            ),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.only(left: 5),
          child: InkWell(
            child: Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery.of(context).size.height);
    double screenWidth = (MediaQuery.of(context).size.width);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.linearToEaseOut,
            top: isSearching ? 60 : screenHeight - 100,
            left: isSearching ? 60 : 15,
            right: 15,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[500],
                      blurRadius: 0,
                      offset: Offset(0, 1),
                    )
                  ],
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                height: 55,
                child: isSearching
                    ? _buildSearchField(context)
                    : InkWell(
                        onTap: () {
                          print("container clicked");
                          if (isSearching)
                            isSearching = false;
                          else
                            isSearching = true;
                          setState(() {});
                        },
                        child: Container(
                          width: 300,
                          color: Colors.blueAccent,
                          height: 40,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
