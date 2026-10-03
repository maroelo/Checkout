import 'package:flutter/material.dart';
import 'package:checkout/db_helper_files/db_helper_lista_de_compras.dart';

class ProductsScreen extends StatefulWidget {
  final int listId;
  final String listName;

  const ProductsScreen({Key? key, required this.listId, required this.listName}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final products = await _dbHelper.getProducts(widget.listId);
    setState(() {
      _products = products;
    });
  }

  void _addProduct(String name, int quantity) async {
    await _dbHelper.insertProduct(name, quantity, widget.listId);
    _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produto "$name" adicionado com sucesso!')),
    );
  }

  void _deleteProduct(int id, String name) async {
    await _dbHelper.deleteProduct(id);
    _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produto "$name" removido!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: _products.isEmpty
          ? const Center(
        child: Text(
          'Nenhum produto adicionado ainda',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(
                product['name'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Quantidade: ${product['quantity']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteProduct(product['id'], product['name']),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddProductDialog() {
    String productName = '';
    int productQuantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => productName = value,
                decoration: const InputDecoration(
                  hintText: 'Nome do Produto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  final quantity = int.tryParse(value);
                  if (quantity != null) productQuantity = quantity;
                },
                decoration: const InputDecoration(
                  hintText: 'Quantidade',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (productName.isNotEmpty) {
                  _addProduct(productName, productQuantity);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('O nome do produto não pode estar vazio.')),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
