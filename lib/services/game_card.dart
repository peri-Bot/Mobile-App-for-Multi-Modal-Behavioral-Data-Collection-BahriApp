import 'package:flutter/material.dart';

class GameCard extends StatefulWidget {
  final String title;
  final String description;
  final VoidCallback onPlayPressed;

  const GameCard({super.key, 
    required this.title,
    required this.description,
    required this.onPlayPressed,
  });

  @override
  _GameCardState createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  Color _cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _cardColor = Colors.tealAccent.withOpacity(0.3); // Add hover effect
        });
      },
      onExit: (_) {
        setState(() {
          _cardColor = Colors.white; // Reset color when not hovering
        });
      },
      child: Card(
        color: _cardColor,
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: widget.onPlayPressed,
          splashColor: Colors.blueAccent.withOpacity(0.2),
          highlightColor: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: widget.onPlayPressed,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.tealAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Play'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
