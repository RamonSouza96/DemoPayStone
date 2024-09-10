unit Main.View;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,

  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Helpers,
  System.Messaging,
  Androidapi.JNI.App,
  Androidapi.JNI.JavaTypes,
  FMX.Platform,
  FMX.Platform.Android,
  Androidapi.Jni,
  Androidapi.JniBridge,
  Androidapi.JNI.Os,
  Androidapi.JNI.Net,
  StoneApi, FMX.Edit, FMX.Layouts;

type
  TFormMain = class(TForm)
    Memo1: TMemo;
    Text1: TText;
    BtnPagamento: TButton;
    BtnCancelamento: TButton;
    Layout1: TLayout;
    Label1: TLabel;
    EdtCodigoAtk: TEdit;
    procedure BtnPagamentoClick(Sender: TObject);
    procedure BtnCancelamentoClick(Sender: TObject);
  private
  public
    procedure RetornoStonePagamento(const RetornoStone: TStoneRetornoPay);
    procedure StoneRetornoCancel(const Transacao: TStoneRetornoCancelamento);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.RetornoStonePagamento(const RetornoStone: TStoneRetornoPay);
begin
  Memo1.Lines.Clear;
  if RetornoStone.StatusTransacao = 'Sucesso' then
  begin
    Memo1.Lines.Add('Status: ' + RetornoStone.StatusTransacao);
    Memo1.Lines.Add('Mensagem de Erro: ' + RetornoStone.MensagenError);
    Memo1.Lines.Add('Nome Titular Cartão: ' + RetornoStone.NomeTitularCartao);
    Memo1.Lines.Add('Chave Transação Iniciador (itk): ' + RetornoStone.ChaveTransacaoIniciador);
    Memo1.Lines.Add('Chave Transação Autorizador (atk): ' + RetornoStone.ChaveTransacaoAutorizador);
    Memo1.Lines.Add('Data/Hora Autorização: ' + RetornoStone.DataHoraAutorizacao);
    Memo1.Lines.Add('Bandeira Cartão: ' + RetornoStone.BandeiraCartao);
    Memo1.Lines.Add('Identificador Pedido: ' + RetornoStone.IdentificadorPedido);
    Memo1.Lines.Add('Código Autorização: ' + RetornoStone.CodigoAutorizacao);
    Memo1.Lines.Add('Quantidade Parcelas: ' + RetornoStone.QuantidadeParcelas);
    Memo1.Lines.Add('Sequência PAN: ' + RetornoStone.SequenciaPAN);
    Memo1.Lines.Add('Tipo Transação: ' + RetornoStone.TipoTransacao);
    Memo1.Lines.Add('Modo Entrada Ponto de Venda: ' + RetornoStone.ModoEntradaPontoVenda);
    Memo1.Lines.Add('Identificador Carteira Digital: ' + RetornoStone.IdentificadorCarteiraDigital);
    Memo1.Lines.Add('Identificador Provider Carteira Digital: ' + RetornoStone.IdentificadorProviderCarteiraDigital);
    Memo1.Lines.Add('Código: ' + RetornoStone.Codigo.ToString);
  end
  else
  begin
    Memo1.Lines.Add('Erro: ' + RetornoStone.MensagenError);
  end;
end;

procedure TFormMain.StoneRetornoCancel(const Transacao: TStoneRetornoCancelamento);
begin
  Memo1.Lines.Clear;
  Memo1.Lines.Add('Status: ' + Transacao.StatusTransacao);
  Memo1.Lines.Add('Mensagem de Erro: ' + Transacao.MensagenError);
  Memo1.Lines.Add('Chave Transação (atk): ' + Transacao.ChaveTransacao);
  Memo1.Lines.Add('Valor Cancelado: ' + Transacao.ValorCancelado);
  Memo1.Lines.Add('Tipo Pagamento: ' + Transacao.TipoPagamento);
  Memo1.Lines.Add('Valor Transação: ' + Transacao.ValorTransacao);
  Memo1.Lines.Add('Identificador Pedido: ' + Transacao.IdentificadorPedido);
  Memo1.Lines.Add('Código Autorização: ' + Transacao.CodigoAutorizacao);
  Memo1.Lines.Add('Motivo: ' + Transacao.Motivo);
  Memo1.Lines.Add('Código Resposta: ' + Transacao.CodigoResposta);
end;

procedure TFormMain.BtnCancelamentoClick(Sender: TObject);
begin
  TFuncoesStone.CancelarPagamento(StoneRetornoCancel, EdtCodigoAtk.Text, 100, False, 'AppCancel');
end;

procedure TFormMain.BtnPagamentoClick(Sender: TObject);
begin
  TFuncoesStone.EfetuarPagamento(RetornoStonePagamento, '10000', Ord(TTipoTransacao.ttPix), TTipoParcelamento.ttSemJuros, 0, False, 'AppPay');
end;

end.
