class CuentaBancaria {
  String titular;
  double saldo;

  CuentaBancaria({required this.titular, this.saldo = 0.0});

  void depositar(double monto) {
    saldo += monto;
    print('Depositado: \$$monto. Nuevo saldo: \$$saldo');
  }

  void retirar(double monto) {
    if (monto <= saldo) {
      saldo -= monto;
      print('Retirado: \$$monto. Saldo restante: \$$saldo');
    } else {
      print('Error: Fondos insuficientes para retirar \$$monto');
    }
  }
}

void main() {
  final miCuenta = CuentaBancaria(titular: 'Carlos Ingeniero', saldo: 500.0);
  miCuenta.depositar(200);
  miCuenta.retirar(800); // Debería fallar
  miCuenta.retirar(100); // Debería funcionar
}
