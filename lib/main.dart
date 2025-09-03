import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Home()
));

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
      title: Text('My first app'),
      centerTitle: true,
      backgroundColor: Colors.red[600],

      ),
      body: Center(
        child:  ElevatedButton.icon(
          onPressed: () {
            print('you clicked the button in the middle');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          icon: Icon(Icons.mail),
          label: Text('Mail'),
        )
,
      //  yo icon banauna ko lagi 
      //  Icon(
      //   Icons.airport_shuttle,
      //   color: Colors.lightBlue,
      //   size: 100.0
      //  ),

       // yo code device ma vako image add garna ko lagi
      //  Image.asset('lib/assets/login.png'),

      // yo chai network bata image lina ko lagi
      // Image.network('c:\Users\Acer\OneDrive\Pictures\Screenshots\Screenshot 2025-08-14 170829.png'),
     
      // text haru ko size style haru sabi milauna
      //  Text(
      //   'Hello Bikrant',
      //    style: TextStyle(
      //     fontSize: 20.0,
      //     fontWeight: FontWeight.bold,
      //     letterSpacing: 3.0,
      //     color: Colors.red[600],
      //   ),
      //  ),
     ),
     floatingActionButton: FloatingActionButton(
      onPressed: () {},
      child: Text('Click me'),
      backgroundColor: Colors.red[600],
     ),
    );
  }
}