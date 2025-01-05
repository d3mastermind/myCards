import 'package:flutter/material.dart';

class TemplateCard extends StatelessWidget {
  const TemplateCard({
    super.key,
    required this.template,
  });

  final Map<String, dynamic> template;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Tapped on template ${template["id"]}");
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card with shadow, image, and icons
              Container(
                height: 250, // Fixed height for the image area
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(70),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/1.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Premium icon
                    if (template["isPremium"])
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
                template["name"],
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
