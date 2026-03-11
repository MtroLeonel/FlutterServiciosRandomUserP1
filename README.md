# FlutterServiciosRandomUserP1

Proyecto Flutter educativo desarrollado para la clase de introducción a Flutter. Incluye una calculadora matemática, consumo de una API REST de usuarios aleatorios y ejercicios de práctica en Dart.

---

## Índice

- [FlutterServiciosRandomUserP1](#flutterserviciosrandomuserp1)
  - [Índice](#índice)
  - [Descripción](#descripción)
  - [Requisitos previos](#requisitos-previos)
  - [Instalación y ejecución](#instalación-y-ejecución)
    - [1. Clonar el repositorio](#1-clonar-el-repositorio)
    - [2. Entrar al directorio del proyecto](#2-entrar-al-directorio-del-proyecto)
    - [3. Instalar las dependencias](#3-instalar-las-dependencias)
    - [4. Ejecutar la aplicación](#4-ejecutar-la-aplicación)
  - [Estructura del proyecto](#estructura-del-proyecto)
  - [Módulos implementados](#módulos-implementados)
    - [Menú principal](#menú-principal)
    - [Calculadora](#calculadora)
    - [Lista de usuarios (API)](#lista-de-usuarios-api)
  - [Ejercicios de Dart](#ejercicios-de-dart)
  - [Dependencias](#dependencias)
  - [Tecnologías usadas](#tecnologías-usadas)
  - [Recursos adicionales](#recursos-adicionales)

---

## Descripción

Esta aplicación Flutter fue construida como material de clase para enseñar los fundamentos del desarrollo móvil con Flutter y Dart. Se implementaron dos módulos funcionales completos dentro de una arquitectura MVC (Modelo - Vista - Servicio), navegación entre pantallas y consumo de una API REST pública.

---

## Requisitos previos

Antes de clonar y ejecutar el proyecto, asegúrate de tener instalado:

| Herramienta | Versión mínima |
|---|---|
| Flutter SDK | 3.10.8 o superior |
| Dart SDK | ^3.10.8 |
| Android Studio o VS Code | Última versión estable |
| Git | Cualquier versión reciente |

Verifica tu entorno con:

```bash
flutter doctor
```

---

## Instalación y ejecución

### 1. Clonar el repositorio

```bash
git clone https://github.com/MtroLeonel/FlutterServiciosRandomUserP1.git
```

### 2. Entrar al directorio del proyecto

```bash
cd FlutterServiciosRandomUserP1
```

### 3. Instalar las dependencias

```bash
flutter pub get
```

### 4. Ejecutar la aplicación

```bash
# En el emulador o dispositivo conectado por defecto
flutter run

# En un dispositivo específico (lista de dispositivos disponibles)
flutter devices
flutter run -d <device_id>

# Compilar para web
flutter run -d chrome

# Compilar para Windows
flutter run -d windows
```

---

## Estructura del proyecto

```
lib/
├── main.dart                   ← Punto de entrada de la app
├── views/
│   ├── home_page.dart          ← Menú principal con grid de módulos
│   ├── calculator_page.dart    ← Pantalla de la calculadora
│   └── users_page.dart         ← Pantalla de lista de usuarios
├── models/
│   ├── calculator_model.dart   ← Lógica matemática de la calculadora
│   └── user_model.dart         ← Modelos de datos: User, Name, Picture, Location, Dob
├── services/
│   └── user_service.dart       ← Consumo de la API RandomUser via HTTP
└── Ejercicios/
    ├── E1.dart                 ← Variables y tipos
    ├── E1v2.dart               ← Variante del ejercicio 1
    ├── E2.dart                 ← Listas y bucles
    ├── E3.dart                 ← Mapas (Map)
    ├── E4.dart                 ← Clases y objetos
    ├── E5.dart                 ← Herencia
    └── Practica/               ← Carpeta de ejercicios adicionales
```

---

## Módulos implementados

### Menú principal

`home_page.dart` muestra un **GridView** de 2 columnas con tarjetas interactivas (`Card + InkWell`) que navegan a cada módulo usando `Navigator.push` con `MaterialPageRoute`.

- Tarjeta **Calculadora** — ícono azul, navega a `CalculatorPage`
- Tarjeta **Usuarios** — ícono verde, navega a `UsersPage`

---

### Calculadora

`calculator_page.dart` + `calculator_model.dart`

La vista presenta dos campos de texto numéricos y botones por cada operación. El modelo concentra toda la lógica matemática.

**Operaciones con dos números:**

| Operación | Método | Detalle |
|---|---|---|
| Suma | `sumar(a, b)` | `a + b` |
| Resta | `restar(a, b)` | `a - b` |
| Multiplicación | `multiplicar(a, b)` | `a * b` |
| División | `dividir(a, b)` | Lanza excepción si `b == 0` |
| Potencia | `potencia(base, exp)` | Usa `dart:math pow()` |

**Operaciones con un solo número (Número 1):**

| Operación | Método | Detalle |
|---|---|---|
| Raíz cuadrada | `raizCuadrada(n)` | Lanza excepción si `n < 0` |
| Factorial | `factorial(n)` | Solo enteros, rango válido: 0–20 |

**Manejo de errores:** Todos los errores (división entre cero, raíz de negativo, factorial negativo o mayor a 20, texto no numérico) se capturan con `try/catch` y se muestran en pantalla sin romper la app.

**Botón limpiar:** Restablece ambos campos y el resultado a `0` usando `setState`.

---

### Lista de usuarios (API)

`users_page.dart` + `user_service.dart` + `user_model.dart`

Consume la API pública **RandomUser** (`https://randomuser.me/api/`) para obtener 20 usuarios aleatorios y mostrarlos en una lista con tarjetas.

**Flujo de datos:**
1. `initState()` invoca `_loadUsers()` al abrir la pantalla.
2. `UserService.getUsers(results: 20)` realiza un `GET` HTTP.
3. La respuesta JSON se deserializa al modelo `User` con `User.fromJson()`.
4. La lista se renderiza con `ListView.builder`.

**Modelos de datos (`user_model.dart`):**

| Clase | Campos |
|---|---|
| `User` | `gender`, `name`, `email`, `phone`, `picture`, `dob`, `location` |
| `Name` | `title`, `first`, `last` → propiedad calculada `fullName` |
| `Picture` | `large`, `medium`, `thumbnail` |
| `Dob` | `date`, `age` |
| `Location` | `city`, `state`, `country` |

**Cada tarjeta de usuario muestra:**
- Avatar circular cargado desde URL (`NetworkImage`)
- Nombre completo en negrita
- Email con ícono
- Teléfono con ícono
- Edad y ubicación (ciudad, país)

**Estados de la pantalla:**
- `_isLoading = true` → muestra `CircularProgressIndicator` + texto
- `_error != null` → muestra ícono de error, mensaje y botón "Reintentar"
- Lista vacía → mensaje informativo
- Lista con datos → `ListView` con tarjetas

**Botón de recarga** en el `AppBar` vuelve a llamar `_loadUsers()`.

---

## Ejercicios de Dart

Archivos de práctica ubicados en `lib/Ejercicios/` para aprender los fundamentos del lenguaje Dart:

| Archivo | Tema | Descripción |
|---|---|---|
| `E1.dart` | Variables y tipos | Validador de edad: determina si una persona puede votar usando `String`, `int`, `bool` |
| `E1v2.dart` | Variables y tipos | Variante del validador con edad = 18 (caso límite) |
| `E2.dart` | Listas y bucles | Calculadora de promedio de notas con `List<double>` y `for-in`; determina si aprobó o reprobó |
| `E3.dart` | Mapas | Carrito de compras con `Map<String, double>`; aplica descuento del 10% con `forEach` |
| `E4.dart` | Clases y objetos | Modelo `Vehiculo` con atributos `marca` y `modelo`, constructor nombrado y método `mostrarInfo()` |
| `E5.dart` | Herencia | Clase base `Empleado` y clase derivada `Gerente` que sobreescribe `calcularPago()` sumando bono |

---

## Dependencias

Definidas en `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8   # Íconos estilo iOS
  http: ^1.1.0               # Peticiones HTTP a la API REST

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0      # Reglas de estilo y buenas prácticas
```

---

## Tecnologías usadas

- **Flutter 3.x** — Framework UI multiplataforma
- **Dart 3.x** — Lenguaje de programación
- **Material Design 3** — Sistema de diseño (`useMaterial3: true`)
- **http** — Cliente HTTP para consumo de APIs REST
- **RandomUser API** — API pública gratuita de usuarios aleatorios (`https://randomuser.me`)
- **Patrón MVC** — Separación de responsabilidades en Model, View y Service

---

## Recursos adicionales

- [Documentación oficial de Flutter](https://docs.flutter.dev/)
- [API RandomUser](https://randomuser.me/documentation)
- [Pub.dev — paquete http](https://pub.dev/packages/http)
- [Material Design 3](https://m3.material.io/)
