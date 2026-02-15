// Importa el paquete de Material Design de Flutter
import 'package:flutter/material.dart';

// Punto de entrada principal de la aplicación
void main() {
  // Ejecuta la aplicación iniciando el widget MyApp
  runApp(const MyApp());
}

// Widget principal de la aplicación (sin estado)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Este widget es la raíz de tu aplicación
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // Este es el tema de tu aplicación
        //
        // PRUEBA ESTO: Intenta ejecutar tu aplicación con "flutter run". Verás
        // que la aplicación tiene una barra de herramientas púrpura. Luego, sin cerrar la app,
        // intenta cambiar el seedColor en el colorScheme de abajo a Colors.green
        // y luego invoca "hot reload" (guarda tus cambios o presiona el botón de "hot
        // reload" en un IDE compatible con Flutter, o presiona "r" si usaste
        // la línea de comandos para iniciar la app).
        //
        // Observa que el contador no se reinició a cero; el estado de la aplicación
        // no se pierde durante la recarga. Para reiniciar el estado, usa hot
        // restart en su lugar.
        //
        // Esto funciona también para el código, no solo valores: La mayoría de cambios de código
        // pueden probarse con solo hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Widget de la página principal (con estado)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // Este widget es la página de inicio de tu aplicación. Es stateful, lo que significa
  // que tiene un objeto State (definido abajo) que contiene campos que afectan
  // cómo se ve.

  // Esta clase es la configuración para el estado. Mantiene los valores (en este
  // caso el título) proporcionados por el padre (en este caso el widget App) y
  // usados por el método build del State. Los campos en una subclase de Widget siempre
  // se marcan como "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Clase de estado privada para MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  // Variable que mantiene el contador
  int _counter = 0;

  // Método que incrementa el contador
  void _incrementCounter() {
    setState(() {
      // Esta llamada a setState le dice al framework de Flutter que algo ha
      // cambiado en este State, lo que hace que se vuelva a ejecutar el método build de abajo
      // para que la pantalla pueda reflejar los valores actualizados. Si cambiáramos
      // _counter sin llamar a setState(), entonces el método build no se
      // llamaría de nuevo, y por lo tanto nada parecería suceder.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Este método se vuelve a ejecutar cada vez que se llama a setState, por ejemplo como lo hace
    // el método _incrementCounter de arriba.
    //
    // El framework de Flutter ha sido optimizado para hacer que la reejecución de métodos build sea
    // rápida, de modo que puedas simplemente reconstruir cualquier cosa que necesite actualizarse en lugar
    // de tener que cambiar individualmente instancias de widgets.
    return Scaffold(
      appBar: AppBar(
        // PRUEBA ESTO: Intenta cambiar el color aquí a un color específico (a
        // Colors.amber, ¿tal vez?) y activa un hot reload para ver el AppBar
        // cambiar de color mientras los otros colores permanecen igual.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Aquí tomamos el valor del objeto MyHomePage que fue creado por
        // el método App.build, y lo usamos para establecer el título de nuestra appbar.
        title: Text(widget.title),
      ),
      body: Center(
        // Center es un widget de diseño. Toma un único hijo y lo posiciona
        // en el centro del padre.
        child: Column(
          // Column es también un widget de diseño. Toma una lista de hijos y
          // los organiza verticalmente. Por defecto, se dimensiona para ajustarse a sus
          // hijos horizontalmente, e intenta ser tan alto como su padre.
          //
          // Column tiene varias propiedades para controlar cómo se dimensiona
          // y cómo posiciona a sus hijos. Aquí usamos mainAxisAlignment para
          // centrar los hijos verticalmente; el eje principal aquí es el eje vertical
          // porque las Columns son verticales (el eje transversal sería
          // horizontal).
          //
          // PRUEBA ESTO: Invoca "debug painting" (elige la acción "Toggle Debug Paint"
          // en el IDE, o presiona "p" en la consola), para ver el
          // esquema de cada widget.
          mainAxisAlignment: .center,
          children: [
            const Text('Has presionado el botón esta cantidad de veces:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      // Botón de acción flotante en la esquina inferior derecha
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Incrementar',
        child: const Icon(Icons.add),
      ),
    );
  }
}
