import 'package:flutter/material.dart';
import 'package:checkout/db_helper_files/db_helper_lista_de_compras.dart';
import 'package:checkout/screens/lista_de_compras_screens/products_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _shoppingLists = [];

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  void _loadLists() async {
    final lists = await _dbHelper.getLists();
    setState(() {
      _shoppingLists = lists;
    });
  }

  void _addList(String name) async {
    await _dbHelper.insertList(name);
    _loadLists();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lista "$name" adicionada com sucesso!')),
    );
  }

  void _deleteList(int id, String name) async {
    await _dbHelper.deleteList(id);
    _loadLists();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lista "$name" removida!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listas de Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddListDialog(),
          ),
        ],
      ),
      body: _shoppingLists.isEmpty
          ? const Center(
        child: Text(
          'Nenhuma lista criada ainda',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _shoppingLists.length,
        itemBuilder: (context, index) {
          final list = _shoppingLists[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(
                list['name'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteList(list['id'], list['name']),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsScreen(
                    listId: list['id'],
                    listName: list['name'],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddListDialog() {
    String newListName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Lista'),
          content: TextField(
            onChanged: (value) => newListName = value,
            decoration: const InputDecoration(
              hintText: 'Nome da Lista',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newListName.isNotEmpty) {
                  _addList(newListName);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('O nome da lista não pode estar vazio.')),
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

