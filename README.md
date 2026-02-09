
# SECOMP App - ICEA/UFOP

Este projeto consiste em um aplicativo móvel desenvolvido para as plataformas Android e iOS, destinado à gestão e acompanhamento da Semana de Computação (SECOMP) do ICEA - UFOP. O software foi concebido como parte integrante das atividades da disciplina de Gerência de Projetos de Software.

## 📱 Sobre o Projeto

O **SECOMP App** visa centralizar as informações do evento, facilitando a interação entre organizadores e participantes. O projeto utiliza o framework Flutter para garantir uma experiência nativa em múltiplas plataformas com um único código-base.

## 🛠️ Tecnologias Utilizadas

* **Linguagem:** Dart
* **Framework:** Flutter (SDK ^3.10.7)
* **Bibliotecas Principais:**
* `flutter_svg`: Para renderização de ícones e ilustrações vetoriais.
* `cupertino_icons`: Para componentes visuais no estilo iOS.



## 📂 Estrutura de Pastas

* `lib/`: Contém o código-base em Dart, incluindo a lógica principal e a inicialização do app (`main.dart`).
* `lib/screens/`: Armazena as telas do aplicativo, como a `SplashScreen`.
* `public/`: Diretório que contém os recursos de imagem e ativos estáticos do projeto.
* `android/` & `ios/`: Pastas contendo as configurações específicas para build nativo em cada plataforma.

## 🚀 Como Executar o Projeto

### Pré-requisitos

1. Ter o Flutter SDK instalado.
2. Configurar um emulador Android ou simulador iOS, ou conectar um dispositivo físico.

### Instalação

1. Clone este repositório.
2. Navegue até a pasta raiz do projeto.
3. Execute o comando para baixar as dependências:
```bash
flutter pub get

```

4. Inicie o aplicativo:
```bash
flutter run

```


## 📝 Detalhes de Versão

* **Versão Atual:** 1.0.0+1
* **Ambiente de Desenvolvimento:** Configurado para evitar publicação acidental no pub.dev (`publish_to: 'none'`).

