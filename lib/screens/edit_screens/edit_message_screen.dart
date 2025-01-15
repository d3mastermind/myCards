import 'package:flutter/material.dart';
import 'package:mycards/screens/card_screens/custom_text_view.dart';

class EditMessageView extends StatefulWidget {
  const EditMessageView({super.key});

  @override
  State<EditMessageView> createState() => _EditMessageViewState();
}

class _EditMessageViewState extends State<EditMessageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: CustomTextView(
                    toMessage: "to Message",
                    fromMeassage: "from Message",
                    customMessage: "custom Message",
                    bgImageUrl: "assets/images/3.jpg"),
              ),
            ],
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.orange),
              height: 50,
              width: 50,
              child: Icon(
                Icons.edit_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
