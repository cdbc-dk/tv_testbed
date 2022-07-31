unit lfm_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  lazutf8,
  bc_tvhelp;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    memDebug: TMemo;
    sbaStatus: TStatusBar;
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.Button1Click(Sender: TObject);
var
  Tn: TTreeNode;
begin
  memDebug.Clear; TreeView1.FullCollapse;
  Tn:= GetNodeByText(TreeView1,Edit1.Text,CheckBox1.Checked);
  if Tn = nil then ShowMessage('Not found!')
  else begin
   TreeView1.SetFocus;
   Tn.Selected:= True;
  end;
end;

end.

