import 'package:flutter/material.dart';
import 'historico_sql_helper.dart';
import '../config_screens/sql_helper.dart';
import '../../main.dart';


class PagamentoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> produtos;
  final double total;

  PagamentoScreen({required this.produtos, required this.total});

  @override
  _PagamentoScreenState createState() => _PagamentoScreenState();
}

class _PagamentoScreenState extends State<PagamentoScreen> {
  String? selectedCard;

  Future<List<Map<String, dynamic>>> _getPayments() async {
    return await SQLHelper.getPayments();
  }

  Future<void> finalizarPagamento(BuildContext context) async {
    if (selectedCard == null) {
      // Exibe um alerta se nenhum cartão foi selecionado
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Selecione um cartão'),
          content: Text('Por favor, selecione um cartão para continuar com o pagamento.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final itens = widget.produtos.map((produto) {
      return '${produto['nome']} x${produto['quantidade']}';
    }).join(', ');

    final dataAtual = DateTime.now().toIso8601String();

    // Salvar no banco de dados do histórico
    await HistoricoSQLHelper.salvarCompra(
      data: dataAtual,
      itens: itens,
      valorTotal: widget.total,
    );

    // Mostrar tela de pagamento aprovado
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PagamentoAprovadoScreen(),
    ));
  }

  String _maskCardNumber(String number) {
    return '**** **** **** ' + number.substring(number.length - 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itens no carrinho:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...widget.produtos.map((produto) {
              final precoTotal = produto['preco_total'] ?? produto['preco'] * produto['quantidade'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3, // Alinha o nome do produto à esquerda e dá um espaço proporcional
                      child: Text(
                        '${produto['nome']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1, // Ajusta a quantidade para um espaço menor
                      child: Text(
                        'x${produto['quantidade']}',
                      ),
                    ),
                    Expanded(
                      flex: 2, // Preço terá mais espaço proporcional
                      child: Text(
                        'R\$ ${precoTotal.toStringAsFixed(2)}',
                        textAlign: TextAlign.end, // Alinha o preço à direita
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'R\$ ${widget.total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Selecione um cartão para pagamento:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getPayments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum cartão salvo.');
                }

                final payments = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final card = payments[index];
                    return ListTile(
                      title: Text(card['nickname']),
                      subtitle: Text(_maskCardNumber(card['number'])),
                      leading: Radio<String>(
                        value: card['number'],
                        groupValue: selectedCard,
                        onChanged: (value) {
                          setState(() {
                            selectedCard = value;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => finalizarPagamento(context),
              child: Text('Concluir Pagamento'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PagamentoAprovadoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Inicio()), // Retorna para a tela inicial definida na main
                (route) => false, // Remove todas as rotas anteriores
          );
        },
        child: Container(
          color: Colors.green,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 100,
                ),
                SizedBox(height: 16),
                Text(
                  'Pagamento Aprovado!',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  'Toque para voltar à tela inicial',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}