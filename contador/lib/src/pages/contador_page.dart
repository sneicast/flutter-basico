import 'package:flutter/material.dart';

class ContadorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContadorPageState();
  }
}

class _ContadorPageState extends State<ContadorPage> {
  final _estiloTexto = new TextStyle(fontSize: 25);

  int _conteo = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contandor'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Número de clicks', style: _estiloTexto),
            Text('$_conteo', style: _estiloTexto)
          ],
        ),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _crearBotones(),
    );
  }

  Widget _crearBotones() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(width: 30),
        FloatingActionButton(
            child: Icon(Icons.exposure_zero), onPressed: _resetContador),
        Expanded(child: SizedBox()),
        FloatingActionButton(child: Icon(Icons.remove), onPressed: _quitar),
        SizedBox(width: 5.0),
        FloatingActionButton(child: Icon(Icons.add), onPressed: _agregar)
      ],
    );
  }

  void _agregar() {
    setState(() {
      _conteo++;
    });
  }

  void _quitar() {
    setState(() {
      _conteo--;
    });
  }

  void _resetContador() {
    setState(() {
      _conteo = 0;
    });
  }
}
