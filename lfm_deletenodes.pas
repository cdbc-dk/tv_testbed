unit lfm_deletenodes;
{$mode ObjFPC}{$H+}
{$define debug}

interface

uses
  bc_errorlog, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls;

type
  { TfrmDeleteNodes }
  TfrmDeleteNodes = class(TForm)
    gbxData: TGroupBox;
    gbxAction: TGroupBox;
    imlGlyphs: TImageList;
    memAction: TMemo;
    pnlTop: TPanel;
    Splitter1: TSplitter;
    tlbActions: TToolBar;
    btnClose: TToolButton;
    Separator: TToolButton;
    btnDelete: TToolButton;
    btnClearTrv: TToolButton;
    Divider: TToolButton;
    btnAddNode: TToolButton;
    trvData: TTreeView;
    procedure btnAddNodeClick(Sender: TObject);
    procedure btnClearTrvClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure trvDataChange(Sender: TObject; Node: TTreeNode);
    procedure trvDataChanging(Sender: TObject; Node: TTreeNode;var AllowChange: Boolean);
    procedure trvDataClick(Sender: TObject);
    procedure trvDataSelectionChanged(Sender: TObject);
  protected
    fRootNode: TTreeNode;
    fLevel1: TTreeNode;
    fPrevSelection: TTreeNode;
    fDeleting: boolean;
    procedure SetRootNode(const aCaption: string;aData: pointer);
  public

  end;

var
  frmDeleteNodes: TfrmDeleteNodes;

implementation
uses
  bc_trvhelp;
  {$ifdef debug} var Dt: string; {$endif}
{$R *.lfm}

{ TfrmDeleteNodes }

procedure TfrmDeleteNodes.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDeleteNodes.btnAddNodeClick(Sender: TObject);
var
  S: string;
  Node: TTreeNode;
begin
  S:= InputBox('Add a new node','Please enter a name','2022');
  if trvData.Selected <> nil then begin { we have a selection }
    if trvData.Selected = fRootNode then Node:= bc_trvhelp.AddChildNodeWithData(trvData,trvData.Selected,S,nil)
    else Node:= bc_trvhelp.AddSiblingNodeWithData(trvData,trvData.Selected,S,nil);
    Node.Selected:= true;
  end else if fRootNode = nil then begin { no root, 1.st sibling }
    SetRootNode('Dates:',nil);
    fLevel1:= bc_trvhelp.AddChildNodeWithData(trvData,fRootNode,S,nil);
    fLevel1.Selected:= true;
  end else if trvData.Items.Count > 1 then begin { n.th sibling, root assigned }
    if fLevel1 <> nil then Node:= bc_trvhelp.AddSiblingNodeWithData(trvData,fLevel1,S,nil);
    if assigned(Node) then Node.Selected:= true;    // todo avoid multible root nodes
    {$ifdef debug}
      if assigned(fLevel1) then memAction.Lines.Add('%s - fLevel1: %s',[Dt,fLevel1.Text]);
      Dt:= DateTimeToStr(Now);
      memAction.Lines.Add('%s - Root assigned, no selection, Sibling-node added: %s with data',[Dt,S]);
      ErrorLog.LogLn(Dt+' - Sibling-node added: '+S+' with data');
    {$endif}
  end;
end;

procedure TfrmDeleteNodes.btnClearTrvClick(Sender: TObject);
begin
  fDeleting:= true;
  bc_trvhelp.ClearTreeview(trvData,false);
  fRootNode:= nil;
  fLevel1:= nil;
  fDeleting:= false;
end;

procedure TfrmDeleteNodes.btnDeleteClick(Sender: TObject);
begin
  if trvData.Selected = nil then raise Exception.Create('You must select a node before you can delete it!');
  if messagedlg('Delete node '+trvData.Selected.Text+' and all children ?',
                mtConfirmation,
                [mbNo,mbYes],
                0) = mrYes then begin
    fDeleting:= true;
    bc_trvhelp.DeleteSelectedTreeNode(trvData);
    fDeleting:= false;
  end;
end;

procedure TfrmDeleteNodes.FormShow(Sender: TObject);
var
  Node: TTreeNode;
begin
  SetRootNode('Dates:',nil);
  if trvData.Items.Count > 1 then fLevel1:= trvData.Items[0];
  for Node in trvData.Items do Node.ImageIndex:= 9;
  fRootNode.ImageIndex:= 8;
end;

procedure TfrmDeleteNodes.trvDataChange(Sender: TObject; Node: TTreeNode);
begin   {
  //todo
  if not fDeleting then begin
    trvData.Selected.ImageIndex:= 8;
  end; }
end;

procedure TfrmDeleteNodes.trvDataChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin {
  if not fDeleting then begin
    Node.ImageIndex:= 9;
    AllowChange:= true;
  end; }
end;

procedure TfrmDeleteNodes.trvDataClick(Sender: TObject);
begin
  //todo
end;

procedure TfrmDeleteNodes.trvDataSelectionChanged(Sender: TObject);
var
  Node: TTreeNode;
begin
  if not fDeleting then begin
    memAction.Lines.Add('fDeleting = false');
    if assigned(trvData.Selected) then begin
      trvData.Selected.SelectedIndex:= 8;
      Node:= trvData.Selected.GetPrevVisible;
      if assigned(Node) then Node.ImageIndex:= 9;
      Node:= trvData.Selected.GetNextVisible;
      if assigned(Node) then Node.ImageIndex:= 9;
    end;
  end else memAction.Lines.Add('fDeleting = true');
end;

procedure TfrmDeleteNodes.SetRootNode(const aCaption: string; aData: pointer);
begin
  if trvData.Items.Count = 0 then fRootNode:= bc_trvhelp.AddRootNode(trvData,aCaption,aData)
  else fRootNode:= trvData.Items[0];
end;

end.

