import 'package:flutter/material.dart';

class CatalogPage extends StatelessWidget {
  final List<Map<String, String>> chapters;
  final Function(String) onChapterSelected;
  final Function() onClose;
  const CatalogPage({required this.chapters, required this.onChapterSelected, required this.onClose, super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('目录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return ListTile(
                  title: Text(chapter['title']!),
                  onTap: () {
                    onChapterSelected(chapter['path']!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
