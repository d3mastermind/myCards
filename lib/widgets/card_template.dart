import 'package:flutter/material.dart';
import 'package:mycards/screens/pre_edit_card_screens/pre_edit_card_preview_page.dart';

class TemplateCard extends StatefulWidget {
  const TemplateCard({
    super.key,
    required this.template,
  });

  final Map<String, dynamic> template;

  @override
  State<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<TemplateCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Tapped on template ${widget.template["id"]}");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PreEditCardPreviewPage(template: widget.template)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card with shadow, image, and icons
              Container(
                //width: 250,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(70),
                      blurRadius: 8,
                      offset: Offset(10, -10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.template["frontCoverImageUrl"],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    // Premium icon
                    if (widget.template["isPremium"])
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 20,
                          ),
                        ),
                      ),
                    // Favorite icon
                    Positioned(
                      top: 8,
                      left: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Template name below the image
              SizedBox(height: 8),
              Text(
                widget.template["name"],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis, // Ensures text doesn't overflow
              ),
            ],
          ),
        ),
      ),
    );
  }
}
