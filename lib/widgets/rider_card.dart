import 'package:flutter/material.dart';

class RiderCard extends StatelessWidget {
  final String title;
  final String desc;
  final String imageUrl;
  final VoidCallback? onTap;
  final Color cardColor;  // Added this to customize the background color of the Card

  const RiderCard({
    Key? key,
    required this.title,
    required this.desc,
    required this.imageUrl,
    this.onTap,
    this.cardColor = Colors.white,  // Default to white background color
  }) : super(key: key);

  // Helper method to determine if the color is dark or light
  bool isDarkColor(Color color) {
    // Calculate luminance of the color to determine if it's dark or light
    double luminance = color.computeLuminance();
    return luminance < 0.5; // If luminance is less than 0.5, it's dark
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // Set the size for the CircleAvatar
    double avatarSize = size.width * 0.25;  // 25% of screen width for the avatar

    // Determine the border color based on the background color luminance
    Color borderColor = isDarkColor(cardColor) ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor,  // Apply dynamic border color around the entire card
            width: 1,  // Border width for the card
          ),
        ),
        color: cardColor,  // Apply the dynamic background color to the Card
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: avatarSize,  // Explicit width for the CircleAvatar
                height: avatarSize, // Explicit height for the CircleAvatar
                decoration: BoxDecoration(
                  shape: BoxShape.circle,  // Ensures circular shape
                  border: Border.all(
                    color: borderColor, // Set the border color dynamically for the image
                    width: 1,  // Border width (optional)
                  ),
                ),
                child: CircleAvatar(
                  radius: avatarSize / 2, // Half the size of the width/height for a perfect circle
                  backgroundImage: NetworkImage(imageUrl),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(width: 16), // Add space between image and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.06, // Adjust font size as a percentage of screen width
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      desc, // Use the actual description passed to the card
                      style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: size.width * 0.045,  // Adjust font size for the description
                      ),
                      maxLines: 1,  // If you want to limit the description lines
                      overflow: TextOverflow.ellipsis,  // Handle overflow gracefully
                    ),       Text(
                      "Kawasaki Ninja Z 650", // Use the actual description passed to the card
                      style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: size.width * 0.045,  // Adjust font size for the description
                      ),
                      maxLines: 3,  // If you want to limit the description lines
                      overflow: TextOverflow.ellipsis,  // Handle overflow gracefully
                    ),
                  ],
                ),
              ),
         
            ],
          ),
        ),
      ),
    );
  }
}
