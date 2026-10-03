import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Promocoes extends StatefulWidget {
  @override
  _PromocoesState createState() => _PromocoesState();
}

class _PromocoesState extends State<Promocoes> {
  List<Map<String, dynamic>> produtosPromocao = [];

  @override
  void initState() {
    super.initState();
    carregarProdutosPromocao();
  }

  // Carrega os produtos em promoção
  Future<void> carregarProdutosPromocao() async {
    try {
      // Carregar o arquivo JSON
      final String response = await rootBundle.loadString('lib/bd_produtos/banco_de_dados_produtos.json');
      final List<dynamic> data = json.decode(response);

      setState(() {
        // Filtra os produtos com 'promocao': true
        produtosPromocao = List<Map<String, dynamic>>.from(data)
            .where((produto) => produto['promocao'] == true)
            .toList();
      });
    } catch (e) {
      print("Erro ao carregar produtos em promoção: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Promoções"),
      ),
      body: produtosPromocao.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: produtosPromocao.length,
        itemBuilder: (context, index) {
          final produto = produtosPromocao[index];

          // Caminho para a imagem
          final imagemPath = 'lib/bd_produtos/fotos/${produto['codigo_barras']}.jpg';

          // Exibição do preço
          final precoExibido = produto.containsKey('preco_por_kg')
              ? 'R\$ ${produto['preco_por_kg'].toStringAsFixed(2)}/kg'
              : 'R\$ ${produto['preco'].toStringAsFixed(2)}';

          return Card(
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.asset(
                    imagemPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported, size: 50);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto['nome'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(precoExibido),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
