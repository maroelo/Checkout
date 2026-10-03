import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'PagamentoScreen.dart';

class Carrinho extends StatefulWidget {
  @override
  _CarrinhoState createState() => _CarrinhoState();
}

class _CarrinhoState extends State<Carrinho> {
  List<Map<String, dynamic>> produtos = [];
  List<Map<String, dynamic>> catalogoProdutos = [];
  List<Map<String, dynamic>> produtosFiltrados = [];
  bool exibirCatalogo = false;
  TextEditingController pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarProdutosDoBanco();
  }

  Future<void> carregarProdutosDoBanco() async {
    final String response = await rootBundle.loadString('lib/bd_produtos/banco_de_dados_produtos.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      catalogoProdutos = List<Map<String, dynamic>>.from(data);
      produtosFiltrados = catalogoProdutos;
    });
  }

  double calcularTotal() {
    return produtos.fold(0.0, (total, produto) {
      return total + (produto['preco_total'] ?? produto['preco'] * produto['quantidade']);
    });
  }

  Future<void> escanearCodigoBarras() async {
    try {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
        if (!status.isGranted) return;
      }

      var result = await BarcodeScanner.scan();

      if (result.type == ResultType.Barcode) {
        final codigoBarras = result.rawContent;
        final produtoEncontrado = catalogoProdutos.firstWhere(
              (produto) => produto['codigo_barras'] == codigoBarras,
          orElse: () => {},
        );

        if (produtoEncontrado != null) {
          setState(() {
            final indexExistente = produtos.indexWhere(
                    (p) => p['nome'] == produtoEncontrado['nome']);
            if (indexExistente >= 0) {
              produtos[indexExistente]['quantidade']++;
            } else {
              produtos.add({
                'nome': produtoEncontrado['nome'],
                'codigo_barras': produtoEncontrado['codigo_barras'],
                'preco': produtoEncontrado['preco'],
                'quantidade': 1,
              });
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${produtoEncontrado['nome']} adicionado ao carrinho!'),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Produto não encontrado!'),
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao escanear o código de barras: $e'),
      ));
    }
  }

  void adicionarProduto(int index) {
    final produtoCatalogo = produtosFiltrados[index];
    if (produtoCatalogo.containsKey('preco_por_kg')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final pesoController = TextEditingController();
          return AlertDialog(
            title: Text('Informe o peso (kg)'),
            content: TextField(
              controller: pesoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(hintText: 'Peso em kg'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  final peso = double.tryParse(pesoController.text) ?? 0.0;
                  if (peso > 0) {
                    setState(() {
                      produtos.add({
                        'nome': produtoCatalogo['nome'],
                        'codigo_barras': produtoCatalogo['codigo_barras'],
                        'peso': peso,
                        'preco_por_kg': produtoCatalogo['preco_por_kg'],
                        'preco_total': peso * produtoCatalogo['preco_por_kg'],
                      });
                      exibirCatalogo = false;
                    });
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Adicionar'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        final indexExistente = produtos.indexWhere((p) => p['nome'] == produtoCatalogo['nome']);
        if (indexExistente >= 0) {
          produtos[indexExistente]['quantidade']++;
        } else {
          produtos.add({
            'nome': produtoCatalogo['nome'],
            'codigo_barras': produtoCatalogo['codigo_barras'],
            'preco': produtoCatalogo['preco'],
            'quantidade': 1,
          });
        }
        exibirCatalogo = false;
      });
    }
  }

  void selecionarBalanca() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final codigoBalancaController = TextEditingController();
        bool mostrarPeso = false;
        int? pesoGerado; // Inicializa como nulo

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void iniciarProcessoBalanca() {
              setState(() {
                mostrarPeso = false;
              });

              Timer(Duration(seconds: 5), () {
                setState(() {
                  pesoGerado = Random().nextInt(4) + 1; // Gera apenas um número
                  mostrarPeso = true;
                });
              });
            }

            return AlertDialog(
              title: Text('Selecionar Balança'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codigoBalancaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Digite o código da balança'),
                  ),
                  SizedBox(height: 20),
                  if (mostrarPeso && pesoGerado != null)
                    Text('Peso Total: $pesoGerado kg'),
                ],
              ),
              actions: [
                if (mostrarPeso && pesoGerado != null)
                  TextButton(
                    onPressed: () {
                      exibirProdutosVariaveis(pesoGerado!);
                    },
                    child: Text('Produto'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
                if (!mostrarPeso)
                  TextButton(
                    onPressed: iniciarProcessoBalanca,
                    child: Text('Conectar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }


  void exibirProdutosVariaveis(int pesoGerado) {
    setState(() {
      produtosFiltrados = catalogoProdutos.where((produto) => produto.containsKey('preco_por_kg')).toList();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Produtos com Peso Variável'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: produtosFiltrados.length,
              itemBuilder: (context, index) {
                final produto = produtosFiltrados[index];
                return ListTile(
                  title: Text(produto['nome']),
                  subtitle: Text('R\$ ${produto['preco_por_kg'].toStringAsFixed(2)}/kg'),
                  onTap: () {
                    setState(() {
                      produtos.add({
                        'nome': produto['nome'],
                        'codigo_barras': produto['codigo_barras'],
                        'peso': pesoGerado,
                        'preco_por_kg': produto['preco_por_kg'],
                        'preco_total': pesoGerado * produto['preco_por_kg'],
                      });
                    });
                    Navigator.of(context).pop(); // Fecha o pop-up de produtos
                    Navigator.of(context).pop(); // Fecha o pop-up de seleção da balança
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }


  void incrementarQuantidade(int index) {
    setState(() {
      produtos[index]['quantidade']++;
    });
  }

  void decrementarQuantidade(int index) {
    setState(() {
      if (produtos[index]['quantidade'] > 1) {
        produtos[index]['quantidade']--;
      } else {
        produtos.removeAt(index);
      }
    });
  }

  void filtrarProdutos(String texto) {
    setState(() {
      produtosFiltrados = catalogoProdutos.where((produto) {
        return produto['nome'].toLowerCase().contains(texto.toLowerCase());
      }).toList();
    });
  }

  void removerProduto(int index) {
    setState(() {
      produtos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: escanearCodigoBarras,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                exibirCatalogo = true;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.scale),
            onPressed: selecionarBalanca,
          ),
        ],
      ),
      body: Column(
        children: [
          if (exibirCatalogo)
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: pesquisaController,
                      onChanged: filtrarProdutos,
                      decoration: InputDecoration(
                        labelText: 'Pesquisar produtos',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: produtosFiltrados.length,
                      itemBuilder: (context, index) {
                        final produto = produtosFiltrados[index];
                        final precoExibido = produto.containsKey('preco_por_kg')
                            ? 'R\$ ${produto['preco_por_kg'].toStringAsFixed(2)}/kg'
                            : 'R\$ ${produto['preco'].toStringAsFixed(2)}';
                        final imagemPath = 'lib/bd_produtos/fotos/${produto['codigo_barras']}.jpg';

                        return ListTile(
                          leading: Image.asset(imagemPath, fit: BoxFit.cover, width: 50, height: 50),
                          title: Text(produto['nome']),
                          subtitle: Text(precoExibido),
                          trailing: ElevatedButton(
                            onPressed: () => adicionarProduto(index),
                            child: Text('Adicionar'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: produtos.isEmpty
                  ? Center(child: Text('O carrinho está vazio'))
                  : ListView.builder(
                itemCount: produtos.length,
                itemBuilder: (context, index) {
                  final produto = produtos[index];
                  final precoTotal = produto.containsKey('preco_total')
                      ? produto['preco_total']
                      : produto['preco'] * produto['quantidade'];
                  final imagemPath = 'lib/bd_produtos/fotos/${produto['codigo_barras']}.jpg';

                  return ListTile(
                    leading: Image.asset(imagemPath, fit: BoxFit.cover, width: 50, height: 50),
                    title: Text(produto['nome']),
                    subtitle: Text(
                      produto.containsKey('peso')
                          ? 'Peso: ${produto['peso']}kg - Total: R\$ ${precoTotal.toStringAsFixed(2)}'
                          : 'Quantidade: ${produto['quantidade']} - Total: R\$ ${precoTotal.toStringAsFixed(2)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (produto.containsKey('peso'))
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => removerProduto(index),
                          ),
                        if (!produto.containsKey('peso')) ...[
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => decrementarQuantidade(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => incrementarQuantidade(index),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'R\$ ${calcularTotal().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: produtos.isEmpty
                  ? null
                  : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PagamentoScreen(
                      produtos: produtos,
                      total: calcularTotal(),
                    ),
                  ),
                );
              },
              child: Text('Finalizar Compra'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
