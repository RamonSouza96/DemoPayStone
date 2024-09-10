unit StoneApi;

// *****************************************************************************
// Autor: Ramon Souza
// Descrição: Implementação de funcionalidades para integração com a Stone
// API utilizando o modelo de DeepLink para pagamentos e cancelamentos.
// Data: 2024
// Git: https://github.com/RamonSouza96
// Doc: https://sdkandroid.stone.com.br/reference/pagamento-deeplink
// *****************************************************************************

interface

uses
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Net,
  Androidapi.JNI.Os,
  Androidapi.Jni.App,
  Androidapi.Jni.JavaTypes,
  Androidapi.Jni,
  Androidapi.IOUtils,
  Androidapi.Helpers,
  FMX.Helpers.Android,
  FMX.Platform,
  FMX.Platform.Android,
  FMX.Dialogs,
  System.SysUtils,
  System.Messaging,
  IdURI;

type
  TStoneRetornoPay = record
    StatusTransacao: string;                 // Status da operação
    MensagenError: string;                   // Mensagem de erro caso ocorra
    NomeTitularCartao: string;               // cardholderName: Nome do titular do cartão
    ChaveTransacaoIniciador: string;         // itk: Chave de transação do iniciador
    ChaveTransacaoAutorizador: string;       // atk: Código único da transação gerado pelo autorizador da Stone
    DataHoraAutorizacao: string;             // authorizationDateTime: Data/hora da autorização
    BandeiraCartao: string;                  // brand: Bandeira do cartão
    IdentificadorPedido: string;             // orderID: Identificador do pedido
    CodigoAutorizacao: string;               // NSU authorizationCode: Código da autorização da transação
    QuantidadeParcelas: string;              // installmentCount: Quantidade de parcelas
    SequenciaPAN: string;                    // pan: Sequência do PAN
    TipoTransacao: string;                   // type: Tipo da transação (Débito, Crédito, Voucher, Pagamento Instantâneo e PIX)
    ModoEntradaPontoVenda: string;           // entryMode: Identifica o modo de entrada do ponto de venda (Tarja, CHIP & PIN, etc.)
    IdentificadorCarteiraDigital: string;    // accountID: Identificador da carteira digital
    IdentificadorProviderCarteiraDigital: string;  // customerWalletProviderID: Identificador do Provider da carteira digital
    Codigo: Integer;                         // code: Código de sucesso ou erro
  end;

type
  TStoneRetornoCancelamento = record
    StatusTransacao: string;      // Indica se o cancelamento foi bem-sucedido
    MensagenError: string;        // Mensagem de erro caso ocorra
    ChaveTransacao: string;       // Código único da transação gerado pelo autorizador da Stone (ATK)
    ValorCancelado: string;       // Valor cancelado, em centavos
    TipoPagamento: string;        // Tipo de pagamento (2 para crédito)
    ValorTransacao: string;       // Valor da transação original, em centavos
    IdentificadorPedido: string;  // Identificador do pedido
    CodigoAutorizacao: string;    // Código de autorização da transação
    Motivo: string;               // Motivo do cancelamento
    CodigoResposta: string;       // Código de resposta da operação
  end;

type
  TParseData = record
    TipoTransacao: string;
    TipoParcelamento: string;
  end;

type
  TStoneTransactionHandlerPay = procedure(const RetornoStone: TStoneRetornoPay) of object;
  TStoneTransactionHandlerCancel = procedure(const RetornoStone: TStoneRetornoCancelamento) of object;

type
  TTipoTransacao = (ttDebit, ttCredit, ttVoucher, ttInstantPayment, ttPix);
  TTipoParcelamento = (ttSemJuros, ttComJuros, ttAVista);

type
  TFuncoesStone = class
  private
    class var RetornoStonePay: TStoneRetornoPay;
    class var RetornoStoneCancel: TStoneRetornoCancelamento;
    class var FProcResultPay: TStoneTransactionHandlerPay;
    class var FProcResultCancel: TStoneTransactionHandlerCancel;
    class var FScheme: string;
    class procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
    class procedure SetProcValidacaoHandlerPay(AHandler: TStoneTransactionHandlerPay);
    class procedure SetProcValidacaoHandlerCancel(AHandler: TStoneTransactionHandlerCancel);
    class function ValideTypeInternal(ATransaction: Integer; AInstallment_type: TTipoParcelamento): TParseData;
    class function OnActivityResult(const Data: JIntent): Boolean;
  public
    class procedure EfetuarPagamento(AProcFinish: TStoneTransactionHandlerPay;
      AValorPagamento: string; ATipoTransacao: Integer; ATipoParcelamento: TTipoParcelamento;
      AQuantidadeParcelas: Integer; APermitirEdicao: Boolean; ARetornoEsquema: string);
    class procedure CancelarPagamento(AProcFinish: TStoneTransactionHandlerCancel;
      AATK: string; AValorCancelamento: Integer; APermitirEdicao: Boolean; ARetornoEsquema: string);
  end;

implementation

{ TFuncoesStone }

class procedure TFuncoesStone.HandleActivityMessage(const Sender: TObject; const M: TMessage);
begin
  if M is TMessageReceivedNotification then
    TFuncoesStone.OnActivityResult(TMessageReceivedNotification(M).Value);
end;

class procedure TFuncoesStone.SetProcValidacaoHandlerPay(AHandler: TStoneTransactionHandlerPay);
begin
  FProcResultPay := AHandler;
end;

class procedure TFuncoesStone.SetProcValidacaoHandlerCancel(AHandler: TStoneTransactionHandlerCancel);
begin
  FProcResultCancel := AHandler;
end;

class function TFuncoesStone.ValideTypeInternal(ATransaction: Integer; AInstallment_type: TTipoParcelamento): TParseData;
begin
  case ATransaction of
    0: Result.TipoTransacao := 'null';
    3: Result.TipoTransacao := 'credit';
    4: Result.TipoTransacao := 'debit';
    5: Result.TipoTransacao := 'pix';
    6: Result.TipoTransacao := 'voucher';
  else
    Result.TipoTransacao := 'null';
  end;

  case AInstallment_type of
    ttSemJuros: Result.TipoParcelamento := 'merchant';
    ttComJuros: Result.TipoParcelamento := 'issuer';
    ttAVista: Result.TipoParcelamento := 'none';
  end;
end;

class procedure TFuncoesStone.EfetuarPagamento(AProcFinish: TStoneTransactionHandlerPay;
  AValorPagamento: string; ATipoTransacao: Integer; ATipoParcelamento: TTipoParcelamento;
  AQuantidadeParcelas: Integer; APermitirEdicao: Boolean; ARetornoEsquema: string);
var
  LUriBuilder: JUri_Builder;
  LIntent: JIntent;
  LValidation: TParseData;
begin
  try
    MainActivity.RegisterIntentAction(TJIntent.JavaClass.ACTION_VIEW);
    TMessageManager.DefaultManager.SubscribeToMessage(TMessageReceivedNotification, HandleActivityMessage);
    SetProcValidacaoHandlerPay(AProcFinish);
    LValidation := TFuncoesStone.ValideTypeInternal(ATipoTransacao, ATipoParcelamento);
    FScheme := ARetornoEsquema;

    LUriBuilder := TJUri_Builder.JavaClass.init;
    LUriBuilder.authority(StringToJString('pay'));
    LUriBuilder.scheme(StringToJString('payment-app'));
    LUriBuilder.appendQueryParameter(StringToJString('return_scheme'), StringToJString(ARetornoEsquema));
    LUriBuilder.appendQueryParameter(StringToJString('amount'), StringToJString(AValorPagamento));
    LUriBuilder.appendQueryParameter(StringToJString('editable_amount'), StringToJString(BoolToStr(APermitirEdicao, True)));

    if LValidation.TipoTransacao <> 'null' then
      LUriBuilder.appendQueryParameter(StringToJString('transaction_type'), StringToJString(LValidation.TipoTransacao));

    if LValidation.TipoTransacao = 'credit' then
      if (AQuantidadeParcelas >= 2) and (AQuantidadeParcelas <= 12) then
        LUriBuilder.appendQueryParameter(StringToJString('installment_count'), StringToJString(IntToStr(AQuantidadeParcelas)));

    LIntent := TJIntent.JavaClass.init;
    LIntent.setAction(TJIntent.JavaClass.ACTION_VIEW);
    LIntent.addFlags(TJIntent.JavaClass.FLAG_ACTIVITY_NEW_TASK);
    LIntent.setData(LUriBuilder.build);
    TAndroidHelper.Activity.StartActivity(LIntent);
  except
    on E: Exception do
      ShowMessage('Erro ao efetuar o pagamento: ' + E.Message);
  end;
end;

class procedure TFuncoesStone.CancelarPagamento(AProcFinish: TStoneTransactionHandlerCancel;
  AATK: string; AValorCancelamento: Integer; APermitirEdicao: Boolean; ARetornoEsquema: string);
var
  LUriBuilder: JUri_Builder;
  LIntent: JIntent;
begin
  try
    MainActivity.RegisterIntentAction(TJIntent.JavaClass.ACTION_VIEW);
    TMessageManager.DefaultManager.SubscribeToMessage(TMessageReceivedNotification, HandleActivityMessage);
    SetProcValidacaoHandlerCancel(AProcFinish);
    FScheme := ARetornoEsquema;

    LUriBuilder := TJUri_Builder.JavaClass.init;
    LUriBuilder.authority(StringToJString('cancel'));
    LUriBuilder.scheme(StringToJString('cancel-app'));
    LUriBuilder.appendQueryParameter(StringToJString('returnscheme'), StringToJString(ARetornoEsquema)); // [CAMPO OBRIGATÓRIO]

    // Caso deseje adicionar outros parâmetros, você pode descomentar as linhas abaixo
    // LUriBuilder.appendQueryParameter(StringToJString('atk'), StringToJString(AATK));
    // LUriBuilder.appendQueryParameter(StringToJString('amount'), StringToJString(IntToStr(AValorCancelamento)));
    // LUriBuilder.appendQueryParameter(StringToJString('editable_amount'), StringToJString(BoolToStr(APermitirEdicao, True)));

    LIntent := TJIntent.JavaClass.init;
    LIntent.setAction(TJIntent.JavaClass.ACTION_VIEW);
    LIntent.addFlags(TJIntent.JavaClass.FLAG_ACTIVITY_NEW_TASK);
    LIntent.setData(LUriBuilder.build);
    TAndroidHelper.Activity.StartActivity(LIntent);
  except
    on E: Exception do
      ShowMessage('Erro ao cancelar o pagamento: ' + E.Message);
  end;
end;

class function TFuncoesStone.OnActivityResult(const Data: JIntent): Boolean;
var
  LCodeResult: Integer;
begin
  Result := False;
  try
    if Data <> nil then
    begin
      if FScheme = 'AppPay' then
      begin
        LCodeResult := JStringToString(Data.getData.getQueryParameter(StringToJString('code'))).ToInteger;

        if LCodeResult = 0 then // Pagamento feito com sucesso!
        begin
          RetornoStonePay.StatusTransacao                      := 'Sucesso';
          RetornoStonePay.MensagenError                        := 'Transação efetuada com Sucesso!';
          RetornoStonePay.NomeTitularCartao                    := JStringToString(Data.getData.getQueryParameter(StringToJString('cardholder_name')));
          RetornoStonePay.ChaveTransacaoIniciador              := JStringToString(Data.getData.getQueryParameter(StringToJString('itk')));
          RetornoStonePay.ChaveTransacaoAutorizador            := JStringToString(Data.getData.getQueryParameter(StringToJString('atk')));
          RetornoStonePay.DataHoraAutorizacao                  := JStringToString(Data.getData.getQueryParameter(StringToJString('authorization_date_time')));
          RetornoStonePay.BandeiraCartao                       := JStringToString(Data.getData.getQueryParameter(StringToJString('brand')));
          RetornoStonePay.IdentificadorPedido                  := JStringToString(Data.getData.getQueryParameter(StringToJString('order_id')));
          RetornoStonePay.CodigoAutorizacao                    := JStringToString(Data.getData.getQueryParameter(StringToJString('authorization_code')));
          RetornoStonePay.QuantidadeParcelas                   := JStringToString(Data.getData.getQueryParameter(StringToJString('installment_count')));
          RetornoStonePay.SequenciaPAN                         := JStringToString(Data.getData.getQueryParameter(StringToJString('pan')));
          RetornoStonePay.TipoTransacao                        := JStringToString(Data.getData.getQueryParameter(StringToJString('type')));
          RetornoStonePay.ModoEntradaPontoVenda                := JStringToString(Data.getData.getQueryParameter(StringToJString('entry_mode')));
          RetornoStonePay.IdentificadorCarteiraDigital         := JStringToString(Data.getData.getQueryParameter(StringToJString('account_id')));
          RetornoStonePay.IdentificadorProviderCarteiraDigital := JStringToString(Data.getData.getQueryParameter(StringToJString('customer_wallet_provider_id')));
          RetornoStonePay.Codigo                               := JStringToString(Data.getData.getQueryParameter(StringToJString('code'))).ToInteger;
        end
        else // Se diferente de 0, ocorreu um erro
        begin
          RetornoStonePay.StatusTransacao := 'Erro';
          RetornoStonePay.MensagenError := JStringToString(Data.getData.getQueryParameter(StringToJString('message')));
        end;

        if Assigned(FProcResultPay) then
          FProcResultPay(RetornoStonePay);
      end
      else if FScheme = 'AppCancel' then
      begin
        if JStringToString(Data.getData.getQueryParameter(StringToJString('code'))) <> '-2' then // Cancelamento feito com sucesso!
        begin
          RetornoStoneCancel.StatusTransacao       := 'Sucesso';
          RetornoStoneCancel.ChaveTransacao        := JStringToString(Data.getData.getQueryParameter(StringToJString('atk')));
          RetornoStoneCancel.ValorCancelado        := JStringToString(Data.getData.getQueryParameter(StringToJString('canceledamount')));
          RetornoStoneCancel.TipoPagamento         := JStringToString(Data.getData.getQueryParameter(StringToJString('paymenttype')));
          RetornoStoneCancel.ValorTransacao        := JStringToString(Data.getData.getQueryParameter(StringToJString('transactionamount')));
          RetornoStoneCancel.IdentificadorPedido   := JStringToString(Data.getData.getQueryParameter(StringToJString('orderid')));
          RetornoStoneCancel.CodigoAutorizacao     := JStringToString(Data.getData.getQueryParameter(StringToJString('authorizationcode')));
          RetornoStoneCancel.Motivo                := JStringToString(Data.getData.getQueryParameter(StringToJString('reason')));
          RetornoStoneCancel.CodigoResposta        := JStringToString(Data.getData.getQueryParameter(StringToJString('responsecode')));
        end
        else
        begin
          RetornoStoneCancel.StatusTransacao := 'Erro';
          RetornoStoneCancel.MensagenError := 'Cancelamento abortado.';
        end;

        if Assigned(FProcResultCancel) then
          FProcResultCancel(RetornoStoneCancel);
      end;
      TMessageManager.DefaultManager.Unsubscribe(TMessageReceivedNotification, HandleActivityMessage);
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Erro Retorno Stone: ' + E.Message);
      Result := False;
    end;
  end;
  TMessageManager.DefaultManager.Unsubscribe(TMessageReceivedNotification, HandleActivityMessage);
end;

end.

