import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bitki Yönetimi"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/plants'); // PlantsView'e yönlendirme
          },
          child: Text("Bitkilerim"),
        ),
      ),
    );
  }
}
