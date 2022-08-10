unit lfm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  lazutf8, LCLIntf, Buttons,
  bc_trvhelp;

type
  { TfrmMain }
  TfrmMain = class(TForm)
    btnGetNodeByText: TButton;
    chbVisible: TCheckBox;
    edtSearchText: TEdit;
    gbxData: TGroupBox;
    gbxAction: TGroupBox;
    memDebug: TMemo;
    sbaStatus: TStatusBar;
    btnDeleteFormShow: TSpeedButton;
    trvDates: TTreeView;
    procedure btnDeleteFormShowClick(Sender: TObject);
    procedure btnGetNodeByTextClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation
uses
  lfm_deletenodes;
{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btnGetNodeByTextClick(Sender: TObject);
var
  Tn: TTreeNode;
begin
  memDebug.Clear;
  Tn:= GetNodeByText(trvDates,edtSearchText.Text,chbVisible.Checked);
  if Tn = nil then ShowMessage(edtSearchText.Text+' Not found!')
  else begin
   trvDates.SetFocus;
   Tn.Selected:= True;
  end;
end;

procedure TfrmMain.btnDeleteFormShowClick(Sender: TObject);
begin
  lfm_deletenodes.frmDeleteNodes.Show;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  Left:= 80;
  Top:= 80;
  trvDates.FullCollapse;
end;

end.

