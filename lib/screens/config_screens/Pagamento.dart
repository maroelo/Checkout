import 'package:flutter/material.dart';
import 'sql_helper.dart';

class Pagamento extends StatefulWidget {
  @override
  _PagamentoState createState() => _PagamentoState();
}

class _PagamentoState extends State<Pagamento> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final data = await SQLHelper.getPayments();
      setState(() {
        _payments = data;
      });
      print('Pagamentos carregados: $_payments');
    } catch (e) {
      print('Erro ao carregar pagamentos: $e');
    }
  }

  Future<void> _addPayment() async {
    try {
      print('Tentando salvar pagamento: ${_nameController.text}, ${_nicknameController.text}, ${_numberController.text}, ${_expiryDateController.text}, ${_cvvController.text}');
      await SQLHelper.savePayment(
        name: _nameController.text,
        nickname: _nicknameController.text,
        number: _numberController.text,
        expiryDate: _expiryDateController.text,
        cvv: _cvvController.text,
      );
      print('Pagamento salvo com sucesso!');
      _clearInputs();
      await _loadPayments();
    } catch (e) {
      print('Erro ao salvar pagamento: $e');
    }
  }

  Future<void> _deletePayment(int id) async {
    try {
      await SQLHelper.deletePayment(id);
      print('Pagamento com ID $id deletado com sucesso!');
      await _loadPayments();
    } catch (e) {
      print('Erro ao deletar pagamento: $e');
    }
  }

  void _clearInputs() {
    _nameController.clear();
    _nicknameController.clear();
    _numberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Adicionar Método de Pagamento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome no Cartão',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Apelido do Cartão',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: 'Número do Cartão',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _expiryDateController,
                        decoration: InputDecoration(
                          labelText: 'Data de Validade',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addPayment();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  String _maskCardNumber(String number) {
    return '**** **** **** ' + number.substring(number.length - 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Métodos de Pagamento', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Container(
        color: Color(0xFFF5F5F5),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            if (_payments.isEmpty)
              Center(
                child: Text(
                  'Nenhum método de pagamento adicionado.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ..._payments.map((payment) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.credit_card, color: Colors.white),
                  ),
                  title: Text(payment['nickname'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_maskCardNumber(payment['number'])),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _deletePayment(payment['id']);
                    },
                  ),
                  onTap: () {},
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.add, color: Colors.black),
              ),
              title: Text(
                'Adicionar Método de Pagamento',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              onTap: _showAddPaymentDialog,
            ),
          ],
        ),
      ),
    );
  }
}