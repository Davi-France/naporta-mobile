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
https://github.com/Davi-France/naporta-mobile.git
cd naportamobile
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

# 💻 Sobre o Desenvolvimento
Desenvolvi este projeto diretamente pelo VSCODE utilizando flutter run -d chrome para testes, pois enfrentei dificuldades com virtualização em minha máquina. Apesar disso, o aplicativo foi cuidadosamente desenvolvido para funcionar em ambas as plataformas (web e mobile), mantendo toda a funcionalidade offline-first e persistência de dados.

## 🗺️ Escolha do Mapa
No desenvolvimento, precisei optar por uma solução de mapas gratuita - OpenStreetMap via Flutter Map - em vez de APIs como Google Maps ou MapBox, que exigem custos para uso em produção. Essa decisão técnica permitiu manter o projeto funcional sem incorrer em despesas, enquanto ainda oferece uma experiência de mapa completa com rotas e marcadores.

## 🛠️ Ferramentas e Aprendizado
Gostei muito do desafio e foi uma excelente oportunidade para aprimorar meus conhecimentos em Flutter, uma tecnologia que considero incrível e tenho grande vontade de me aprofundar. Durante o desenvolvimento:
- Utilizei bibliotecas especializadas como Hive, Flutter Map e HTTP para implementar funcionalidades específicas
- Pesquisei extensivamente com auxílio de IAs para solucionar desafios técnicos e otimizar o código
- Aprendi na prática conceitos importantes como offline-first, paginação infinita e integração de mapas

## 🎯 Desafios Superados
- Implementar scroll infinito eficiente com cache local
- Criar sistema de rota no mapa sem APIs pagas
- Garantir funcionamento offline com sincronização inteligente
- Manter código limpo e organizado mesmo sendo um projeto complexo
Este projeto representa não apenas a entrega de um desafio técnico, mas meu compromisso em aprender e evoluir com uma tecnologia que admiro profundamente. Cada funcionalidade implementada foi um passo a mais na minha jornada de dominar o ecossistema Flutter! 🚀
