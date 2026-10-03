// lib/screens/config_screens/Config.dart
import 'package:flutter/material.dart';
import 'Pagamento.dart';
import '../historico_screens/HistoricoComprasScreen.dart';  // Importando a tela de histórico

class Config extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300], // Placeholder color
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Bruce Wayne',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@emogotico',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Informações da conta'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar para a tela de Informações da conta
                  },
                ),
                ListTile(
                  title: Text('Histórico de compras'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar para a tela de Histórico de Compras
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoricoComprasScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Favoritos'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar para Favoritos
                  },
                ),
                ListTile(
                  title: Text('Notificações'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar para Notificações
                  },
                ),
                ListTile(
                  title: Text('Métodos de pagamento'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Ao clicar, navega para a tela de Pagamento
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Pagamento(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Idioma'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar para Idioma
                  },
                ),
                ListTile(
                  title: Text('Privacidade e Segurança'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar para Privacidade e Segurança
                  },
                ),
                ListTile(
                  title: Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: Icon(Icons.exit_to_app, color: Colors.red),
                  onTap: () {
                    // Ação para sair
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
