## 📱 Desafio Mobile – Aplicativo de Pedidos
🚀 Como Rodar a Aplicação
### ✅ Pré-requisitos Necessários

## Antes de começar, você precisa ter instalado:

- Git — para clonar o repositório
- Flutter SDK — Tools • Dart 3.9.2 • DevTools 2.48.0
- Google Chrome (para testar na Web) ou emulador/dispositivo Android/iOS

###  Importante: O projeto foi desenvolvido e testado com
- Dart 3.9.2 e DevTools 2.48.0, garantindo compatibilidade com essa configuração.

## 📥 Passo 1: Clonar o Repositório
```bash
git clone https://github.com/seu-usuario/desafio_mobile.git
cd desafio_mobile
```

## 🔧 Passo 2: Instalar Dependências
```bash
flutter pub get
```

## 🏗️ Passo 3: Gerar Código do Banco de Dados (Hive)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## ▶️ Passo 4: Rodar a Aplicação
✔️ Opção Recomendada: Navegador (Chrome)
```bash
flutter run -d chrome
```

ou

```bash
flutter run -d emulator
```

## ✅ Teste Rápido

- Lista de pedidos com scroll infinito
- Detalhe do pedido com mapa + rota
- Criar novo pedido (formulário validado)
- Puxe para atualizar (pull-to-refresh)

## 💻 Sobre o Desenvolvimento

Desenvolvido no VS Code com extensões Flutter/Dart.
Testado principalmente via:
flutter run -d chrome

Configurações utilizadas:
- Dart: 3.9.2
- DevTools: 2.48.0
- Hive: persistência funcionando perfeitamente na Web via IndexedDB

## 🛠️ Problemas Comuns e Soluções

###❌ HiveError: Box not found
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

###❌ App não abre no navegador
```bash
flutter config --enable-web
```

###❌ Dependências conflitantes
```bash
flutter pub upgrade
```

## 📱 Testando em Diferentes Plataformas
- Web (TESTADO E FUNCIONANDO)
- flutter run -d chrome

## Android
```bash
flutter run -d (emulador que voce tivr instalado)
```


## 🎨 Por Que Desenvolvi na Web?
- Hot reload mais rápido
- Debug direto no navegador
- Evita problemas de virtualização
- Mesmo código funciona em todas as plataformas


## 🚀 Dica Final

Para testar rapidamente:
```bash
flutter run -d chrome
```
