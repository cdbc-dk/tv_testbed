unit lfm_dataaware;
{$mode ObjFPC}{$H+}
{$define debug}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls;

type
  { TfrmDataAware }
  TfrmDataAware = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StatusBar1: TStatusBar;
  private

  public

  end;

var
  frmDataAware: TfrmDataAware;

implementation

{$R *.lfm}

end.

