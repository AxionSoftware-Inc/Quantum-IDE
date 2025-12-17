import 'package:flutter/material.dart';

class ExtensionsPanel extends StatelessWidget {
  const ExtensionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFF252526),
            width: double.infinity,
            child: const Text("EXTENSIONS", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          ),

          // INSTALLED LIST
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("INSTALLED", style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)),
          ),

          _buildExtensionItem(
              "Quantum Core",
              "Built-in Qiskit support & Visualization.",
              "v1.0.0",
              true
          ),

          const Divider(color: Colors.white10),

          // MARKETPLACE (PLACEHOLDER)
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("MARKETPLACE (Coming Soon)", style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)),
          ),

          // CALL TO ACTION (Open Source Signal)
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Want to contribute?", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(height: 5),
                Text(
                  "Fork this repo and implement 'SciencePlugin' to add AI or Bio support.",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionItem(String title, String desc, String version, bool isActive) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: const Icon(Icons.extension, color: Colors.purpleAccent),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Text("v$version", style: const TextStyle(color: Colors.white30, fontSize: 10)),
              const Spacer(),
              if (isActive)
                const Text("Active", style: TextStyle(color: Colors.green, fontSize: 10))
            ],
          )
        ],
      ),
    );
  }
}