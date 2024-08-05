import 'package:flutter/material.dart';

import '../models/sellers.dart';

class InfoDesignWidget extends StatefulWidget {
  Sellers sellers;
  BuildContext context;
  InfoDesignWidget({
    super.key,
    required this.sellers,
    required this.context,
  });

  @override
  State<InfoDesignWidget> createState() => _InfoDesignWidgetState();
}

class _InfoDesignWidgetState extends State<InfoDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SizedBox(
            height: 280,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Divider(
                  height: 4,
                  thickness: 3,
                  color: Colors.grey[300],
                ),
                const SizedBox(
                  height: 5,
                ),
                Image.network(
                  height: 210,
                  fit: BoxFit.cover,
                  widget.sellers.sellerAvatarUrl ??
                      "https://picsum.photos/250?image=9",
                ),
                const SizedBox(
                  height: 1,
                ),
                Text(
                  widget.sellers.sellerName ?? "Name not available",
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontSize: 20,
                    fontFamily: "Train",
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  widget.sellers.sellerEmail ?? "Email not available",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: "Train",
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Divider(
                  height: 4,
                  thickness: 3,
                  color: Colors.grey[300],
                ),
              ],
            )),
      ),
    );
  }
}
