📱 Desafio Mobile - Aplicativo de Pedidos
🚀 Como Rodar a Aplicação
Pré-requisitos Necessários
Antes de começar, você precisa ter instalado:

Git - para clonar o repositório

Flutter SDK - versão 3.0.0 ou superior

Google Chrome (para testar na web) ou emulador/dispositivo

📥 Passo 1: Clonar o Repositório
Abra o terminal e execute:

bash
git clone https://github.com/seu-usuario/desafio_mobile.git
cd desafio_mobile
🔧 Passo 2: Instalar Dependências
bash
# Instala todas as dependências do projeto
flutter pub get
🏗️ Passo 3: Gerar Código do Banco de Dados
bash
# Gera os arquivos necessários para o Hive funcionar
flutter packages pub run build_runner build --delete-conflicting-outputs
▶️ Passo 4: Rodar a Aplicação
Opção Recomendada: No Navegador (Mais Fácil e Rápido)
bash
# Executa no Google Chrome - como desenvolvi e testei
flutter run -d chrome
Opção Android/iOS (Também Funciona):
bash
# Para Android (se tiver emulador/dispositivo)
flutter run -d emulator

# Para iOS (se tiver Mac)
flutter run -d iPhone
✅ Teste Rápido
Após rodar, teste estas funcionalidades:

Lista de pedidos - role para baixo para carregar mais (scroll infinito)

Clique em um pedido - veja detalhes e mapa com rota de entrega

Botão "Novo pedido" - crie um novo pedido com formulário validado

Puxe para atualizar - puxe a lista para baixo para recarregar dados

💻 Sobre o Desenvolvimento
Desenvolvi este projeto diretamente pelo VSCODE pois tive dificuldades com virtualização em minha máquina. Testei principalmente pelo flutter run -d chrome, que me permitiu um desenvolvimento rápido e eficiente com hot reload.

🎯 IMPORTANTE: O app foi desenvolvido para funcionar em AMBOS
✅ Navegador Web (testado extensivamente)

✅ Android/iOS (pronto para build, mesmo desenvolvido no navegador)

Minha Configuração de Desenvolvimento:
Editor: VSCODE com extensões Flutter/Dart

Teste: Principalmente no Google Chrome (flutter run -d chrome)

Debug: Console do navegador e logs do Flutter

Persistência: Hive funcionando perfeitamente na web via IndexedDB

🛠️ Caso Encontre Problemas
Problema: "HiveError: Box not found"
bash
# Execute com force rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
Problema: App não abre no navegador
bash
# Ative suporte web no Flutter
flutter config --enable-web
Problema: Dependências conflitantes
bash
# Atualize todas as dependências
flutter pub upgrade
📱 Testando em Diferentes Plataformas
Para Web (Como Testei):
bash
# Funciona perfeitamente!
flutter run -d chrome
Para Android:
bash
# Precisa de emulador ou dispositivo
flutter run -d emulator-5554
Para Build de Release:
bash
# Web
flutter build web

# Android
flutter build apk --release

# iOS
flutter build ios --release
🎨 Por Que Desenvolvi na Web?
Hot Reload mais rápido que em emuladores

Debug mais fácil com DevTools do navegador

Sem problemas de virtualização na minha máquina

Mesmo código funciona em todas plataformas (magia do Flutter! ✨)

🔍 Verificando se Está Funcionando
No Navegador (Chrome):
App abre em localhost:XXXX

Banco de dados funciona (verifique IndexedDB no DevTools)

Mapa carrega com OpenStreetMap

API requests funcionam (JSONPlaceholder)

No Celular/Emulador:
Mesma interface e funcionalidades

Dados persistem localmente

Mapa funciona normalmente

🚀 Dica Rápida:
Se quiser testar rápido, use flutter run -d chrome - é assim que desenvolvi e garanto que funciona perfeitamente!
