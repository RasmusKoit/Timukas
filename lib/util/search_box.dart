import 'package:flutter/material.dart';

import 'const.dart';

class SearchBox extends StatefulWidget {
  final TextEditingController controller;
  final String msg;
  final Function onSearchTap;

  const SearchBox({
    Key? key,
    required this.controller,
    required this.msg,
    required this.onSearchTap,
  }) : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  String message = '';
  void updateMsg(String newMsg) {
    setState(() {
      message = newMsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.controller.text.isEmpty
                      ? 'Enter a search term'
                      : widget.controller.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: widget.controller.text.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: widget.controller.text.isEmpty
                        ? Colors.grey[600]
                        : Colors.black,
                  ),
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(
                        Icons.backspace,
                        color: estBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          // delete last character
                          widget.controller.text = widget.controller.text
                              .substring(0, widget.controller.text.length - 1);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          message = '';
                          widget.controller.clear();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(Icons.search, color: estBlue),
                      onPressed: () {
                        setState(() {
                          widget.onSearchTap();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
