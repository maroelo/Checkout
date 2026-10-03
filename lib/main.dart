import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'screens/promocoes_screen.dart';
import 'screens/lista_de_compras_screens/list_screen.dart';
import 'screens/carrinho_screens/Carrinho.dart';
import 'screens/config_screens/Config.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Inicio(),
  ));
}

class Inicio extends StatefulWidget {
  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  int _indiceAtual = 0;

  final List<Widget> _telas = [
    Promocoes(), // Página inicial com promoções
    ListScreen(),
    Carrinho(),
    Config(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _indiceAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text("Checkout"),
      ),*/
      body: _telas[_indiceAtual],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _indiceAtual,
        onTap: onTabTapped,
        items: [
          // Promoções
          SalomonBottomBarItem(
            icon: Icon(Icons.local_offer),
            title: Text("Promoções"),
            selectedColor: Colors.blue,
          ),
          // Lista de Compras
          SalomonBottomBarItem(
            icon: Icon(Icons.list_alt_rounded),
            title: Text("Lista de Compras"),
            selectedColor: Colors.blue,
          ),
          // Carrinho
          SalomonBottomBarItem(
            icon: Icon(Icons.shopping_cart),
            title: Text("Carrinho"),
            selectedColor: Colors.blue,
          ),
          // Configurações
          SalomonBottomBarItem(
            icon: Icon(Icons.settings),
            title: Text("Configurações"),
            selectedColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
