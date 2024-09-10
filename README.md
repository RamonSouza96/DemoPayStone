# DemoPayStone


# DemoPayStone

**DemoPayStone** é um projeto de demonstração para integração com a API de pagamentos e cancelamentos da **Stone** utilizando **DeepLink**. Este projeto foi desenvolvido com **Delphi FireMonkey** para Android, demonstrando a implementação de operações de pagamento e cancelamento através de intents.

# Doc: https://sdkandroid.stone.com.br/reference/explicacao-deeplink

## Funcionalidades

- **Efetuar Pagamento**: Realiza uma transação de pagamento utilizando a API da Stone.
- **Cancelar Pagamento**: Cancela uma transação previamente realizada, fornecendo o código da transação (ATK) como parâmetro.

### Estrutura de Retorno

#### Retorno de Pagamento (`TStoneRetornoPay`)
Após o processamento do pagamento, as seguintes informações são retornadas:

- **StatusTransacao**: Indica se a transação foi bem-sucedida ou falhou.
- **MensagemErro**: Em caso de erro, a mensagem associada.
- **NomeTitularCartao**: Nome do titular do cartão usado.
- **ChaveTransacaoIniciador (itk)**: Chave de transação gerada pelo iniciador.
- **ChaveTransacaoAutorizador (atk)**: Código gerado pelo autorizador da Stone.
- **DataHoraAutorizacao**: Data e hora em que a autorização foi feita.
- **BandeiraCartao**: Bandeira do cartão usado.
- **IdentificadorPedido**: Código do pedido associado à transação.
- **CódigoAutorizacao (NSU)**: Código de autorização da transação.
- **QuantidadeParcelas**: Número de parcelas no caso de pagamento parcelado.
- **SequenciaPAN**: Sequência do PAN (Parcial do número do cartão).
- **TipoTransacao**: Tipo da transação (Crédito, Débito, PIX, etc.).
- **ModoEntradaPontoVenda**: Como o cartão foi inserido (Tarja, CHIP & PIN, etc.).
- **IdentificadorCarteiraDigital**: Se usado, o ID da carteira digital.
- **IdentificadorProviderCarteiraDigital**: O identificador do provedor da carteira digital.
- **Código**: Código de status do retorno (sucesso ou erro).

#### Retorno de Cancelamento (`TStoneRetornoCancelamento`)
Após o processamento do cancelamento, as seguintes informações são retornadas:

- **StatusTransacao**: Indica se o cancelamento foi bem-sucedido.
- **MensagemErro**: Em caso de erro, a mensagem associada.
- **ChaveTransacao (ATK)**: Código único da transação gerado pela Stone.
- **ValorCancelado**: O valor que foi cancelado (em centavos).
- **TipoPagamento**: Tipo de pagamento original (Ex: crédito).
- **ValorTransacao**: Valor original da transação (em centavos).
- **IdentificadorPedido**: Código do pedido associado à transação.
- **CódigoAutorizacao (NSU)**: Código de autorização da transação.
- **Motivo**: Motivo do cancelamento.
- **CódigoResposta**: Código de resposta da operação de cancelamento.

## Configuração do AndroidManifest.xml

Para o funcionamento correto do projeto **DemoPayStone**, é necessário configurar os `intent-filters` no arquivo `AndroidManifest.xml` do seu projeto Android. Esses intents são responsáveis por definir as ações e esquemas de dados que o app pode processar, tanto para operações de pagamento quanto de cancelamento.

Adicione os seguintes `intent-filters` no arquivo `AndroidManifest.xml`:


Aqui está o conteúdo sugerido para o seu arquivo README.md no repositório DemoPayStone. Ele explica o funcionamento do projeto e como configurar os intent-filters no AndroidManifest.xml para funcionar corretamente:

markdown
Copiar código
# DemoPayStone

**DemoPayStone** é um projeto de demonstração para integração com a API de pagamentos e cancelamentos da **Stone** utilizando **DeepLink**. Este projeto foi desenvolvido com **Delphi FireMonkey** para Android, demonstrando a implementação de operações de pagamento e cancelamento através de intents.

## Funcionalidades

- **Efetuar Pagamento**: Realiza uma transação de pagamento utilizando a API da Stone.
- **Cancelar Pagamento**: Cancela uma transação previamente realizada, fornecendo o código da transação (ATK) como parâmetro.

### Estrutura de Retorno

#### Retorno de Pagamento (`TStoneRetornoPay`)
Após o processamento do pagamento, as seguintes informações são retornadas:

- **StatusTransacao**: Indica se a transação foi bem-sucedida ou falhou.
- **MensagemErro**: Em caso de erro, a mensagem associada.
- **NomeTitularCartao**: Nome do titular do cartão usado.
- **ChaveTransacaoIniciador (itk)**: Chave de transação gerada pelo iniciador.
- **ChaveTransacaoAutorizador (atk)**: Código gerado pelo autorizador da Stone.
- **DataHoraAutorizacao**: Data e hora em que a autorização foi feita.
- **BandeiraCartao**: Bandeira do cartão usado.
- **IdentificadorPedido**: Código do pedido associado à transação.
- **CódigoAutorizacao (NSU)**: Código de autorização da transação.
- **QuantidadeParcelas**: Número de parcelas no caso de pagamento parcelado.
- **SequenciaPAN**: Sequência do PAN (Parcial do número do cartão).
- **TipoTransacao**: Tipo da transação (Crédito, Débito, PIX, etc.).
- **ModoEntradaPontoVenda**: Como o cartão foi inserido (Tarja, CHIP & PIN, etc.).
- **IdentificadorCarteiraDigital**: Se usado, o ID da carteira digital.
- **IdentificadorProviderCarteiraDigital**: O identificador do provedor da carteira digital.
- **Código**: Código de status do retorno (sucesso ou erro).

#### Retorno de Cancelamento (`TStoneRetornoCancelamento`)
Após o processamento do cancelamento, as seguintes informações são retornadas:

- **StatusTransacao**: Indica se o cancelamento foi bem-sucedido.
- **MensagemErro**: Em caso de erro, a mensagem associada.
- **ChaveTransacao (ATK)**: Código único da transação gerado pela Stone.
- **ValorCancelado**: O valor que foi cancelado (em centavos).
- **TipoPagamento**: Tipo de pagamento original (Ex: crédito).
- **ValorTransacao**: Valor original da transação (em centavos).
- **IdentificadorPedido**: Código do pedido associado à transação.
- **CódigoAutorizacao (NSU)**: Código de autorização da transação.
- **Motivo**: Motivo do cancelamento.
- **CódigoResposta**: Código de resposta da operação de cancelamento.

## Configuração do AndroidManifest.xml

Para o funcionamento correto do projeto **DemoPayStone**, é necessário configurar os `intent-filters` no arquivo `AndroidManifest.xml` do seu projeto Android. Esses intents são responsáveis por definir as ações e esquemas de dados que o app pode processar, tanto para operações de pagamento quanto de cancelamento.

Adicione os seguintes `intent-filters` no arquivo `AndroidManifest.xml`:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:host="pay-response" android:scheme="AppPay" />
</intent-filter>

<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:host="cancel" android:scheme="AppCancel" />
</intent-filter>

** Explicação dos Intent Filters **
O primeiro intent-filter processa as respostas de pagamento (pay-response) com o esquema AppPay.
O segundo intent-filter processa os cancelamentos de transações (cancel) com o esquema AppCancel.

Licença
Este projeto é distribuído sob a licença MIT.

Autor
Desenvolvido por Ramon Souza.
