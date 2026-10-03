
import 'package:flutter/material.dart';
import '../carrinho_screens/historico_sql_helper.dart';

class HistoricoComprasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Compras'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: HistoricoSQLHelper.obterCompras(),  // Obtendo o histórico do banco
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar histórico.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma compra encontrada.'));
          }

          // Lista de compras
          final compras = snapshot.data!;

          return ListView.builder(
            itemCount: compras.length,
            itemBuilder: (context, index) {
              final compra = compras[index];
              return ListTile(
                title: Text('Compra em: ${compra['data']}'),
                subtitle: Text('Itens: ${compra['itens']}'),
                trailing: Text('R\$ ${compra['valor_total'].toStringAsFixed(2)}'),
                onLongPress: () {
                  // Deletar a compra
                  _confirmarDeletar(context, compra['id']);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _confirmarDeletar(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Deletar Compra'),
          content: Text('Tem certeza que deseja excluir esta compra?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                HistoricoSQLHelper.deletarCompra(id); // Deletar compra
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Compra deletada com sucesso!')),
                );
              },
              child: Text('Deletar'),
            ),
          ],
        );
      },
    );
  }
}
