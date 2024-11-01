import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Imagefullscreenview extends StatefulWidget {
  final String imgUrl;
  final String uploadedBy;

  const Imagefullscreenview(
      {super.key, required this.imgUrl, required this.uploadedBy});

  @override
  State<Imagefullscreenview> createState() => _ImagefullscreenviewState();
}

class _ImagefullscreenviewState extends State<Imagefullscreenview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: CachedNetworkImage(imageUrl: widget.imgUrl),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: Colors.white.withOpacity(0.9)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '${widget.uploadedBy}',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
