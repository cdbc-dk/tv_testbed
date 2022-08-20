unit lfm_dataaware;
{$mode ObjFPC}{$H+}
{-$define debug}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls, Buttons,
  bom_dd,
  bc_observer,
  bc_datetime,
  bc_trvhelp,
  bc_utilities;

type
  { state modes represented as a set }
  TFormMode = (fmInsert,fmEdit,fmBrowse,fmDelete,fmInactive);
  TFormModes = set of TFormMode;   //bm
  { TObserver derivative }
  TDDObserver = class(TObserver)
  public
    Procedure FPOObservedChanged(aSender: TObject;Operation: TFPObservedOperation;Data: Pointer); override;
  end;
  { TfrmDataAware }
  TfrmDataAware = class(TForm)
    gbxNavigation: TGroupBox;
    gbxText: TGroupBox;
    ImageList1: TImageList;
    memText: TMemo;
    pnlTop: TPanel;
    btnClose: TSpeedButton;
    btnReadData: TSpeedButton;
    btnUpdate: TSpeedButton;
    btnAdd: TSpeedButton;
    btnDelete: TSpeedButton;
    Splitter1: TSplitter;
    stbStatus: TStatusBar;
    trvNav: TTreeView;
    procedure btnAddClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnReadDataClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pnlTopClick(Sender: TObject);
    procedure trvNavSelectionChanged(Sender: TObject);
  private
    fBom: TDDCollection;
    fObserver: TDDObserver;
    fDt: IIsoDateTime;
    fRootNode: TTreeNode;
    fLevel1: TTreeNode;
    fFormModes: TFormModes;
    fNewItem: TDDCollectionItem; { for when we'll add a new entry to our dataset }
    procedure ConcatenateStreams(aStream1, aStream2: TStream);
    procedure PutFormInEditMode(anEditMode: boolean); { lock down controls and focus on memo }
    function SerializeSet(aSet: TFormModes): string;
  public
    procedure FindAndAddYearNode(anItem: TDDCollectionItem);
    procedure ShowDataRead(aDataset: TDDCollection;aCount: ptruint);
  end;

var
  frmDataAware: TfrmDataAware;

implementation

{$R *.lfm}

{ TDDObserver }

procedure TDDObserver.FPOObservedChanged(aSender: TObject;Operation: TFPObservedOperation;Data: Pointer);
var
  Ds: TDDCollection;
  Count: ptruint;
begin
  Ds:= TDDCollection(aSender); { sender is our dataset }
  Count:= ptruint(Data); { data contains the number of records in dataset }
  case Operation of
    ooAddItem   : ;
    ooChange    : ;
    ooCustom    : begin TfrmDataAware(fActiveObject).ShowDataRead(Ds,Count); end;
    ooDeleteItem: ;
    ooFree      : begin ShowMessage('Daily Diary data backend is shutting down. Bye'); end;
  end;
  Ds:= nil;
end;

{ TfrmDataAware }

procedure TfrmDataAware.pnlTopClick(Sender: TObject);
begin

end;

procedure TfrmDataAware.trvNavSelectionChanged(Sender: TObject);
begin
  { load the text from the dataset into our memo }
  case trvNav.Selected.Level of
    0: begin
         trvNav.Selected.Expand(false);
         memText.Lines.Text:= 'Root, carries a reference to our dataset';
       end;
    1: begin
         trvNav.Selected.Expand(false);
         memText.Text:= 'Year: '+trvNav.Selected.Text;
       end;
    2: begin
         trvNav.Selected.Expand(false);
         memText.Text:= 'Week: '+trvNav.Selected.Text;
       end;
    3: begin
         TDDCollectionItem(trvNav.Selected.Data).Text.Position:= 0; { seek to beginning of stream }
         memText.Lines.LoadFromStream(TDDCollectionItem(trvNav.Selected.Data).Text);
       end;
  end;                     {
  if trvNav.Selected.Level = 3 then begin
    TDDCollectionItem(trvNav.Selected.Data).Text.Position:= 0; { seek to beginning of stream }
    memText.Lines.LoadFromStream(TDDCollectionItem(trvNav.Selected.Data).Text);
  end else memText.Clear; }
end;

procedure TfrmDataAware.ConcatenateStreams(aStream1, aStream2: TStream);
begin
  aStream2.Position:= 0;
  aStream1.CopyFrom(aStream2, aStream2.Size);
  aStream1.Position:= 0;
  aStream2.Position:= 0; 
(* The TStream chain has got a bug, so the above is a workaround!!! 2022-08-18 /bc
const CrLf = #13#10'-----'#13#10;
var
  Buffer: TBytes;
  Res: int64;
begin
  SetLength(Buffer,aStream2.Size);
  aStream2.Position:= 0;
  Res:= aStream2.Read(Buffer,aStream2.Size);
  aStream1.Seek(0,soEnd);
  aStream1.Write(CrLf,9);
  aStream1.Write(Buffer,Res);
  aStream1.Position:= 0;
  aStream2.Position:= 0;
  SetLength(Buffer,0);
*)
end;

procedure TfrmDataAware.PutFormInEditMode(anEditMode: boolean);
begin
  case anEditMode of
    true : begin
//             fFormModes+= [fmEdit,fmInsert];  //bm
             fFormModes:= {fFormModes +} [fmEdit,fmInsert]; { does this exclude fmBrowse from set? }
           end;
    false: begin

           end;
  end; { case }
end;

function TfrmDataAware.SerializeSet(aSet: TFormModes): string;
const
  Modes: array [TFormMode] of String[10] = ('fmInsert','fmEdit','fmBrowse','fmDelete','fmInactive');
var
  Fm: TFormMode;
begin
  Result:= '';
  for Fm:= fmInsert to fmInactive do if Fm in aSet then begin
    if (Result <> '') then Result+= ', ';
    Result+= Modes[Fm]; { shorthand for "result:= result + modes[fm];" }
  end;
end;

procedure TfrmDataAware.FindAndAddYearNode(anItem: TDDCollectionItem);
var
  YearNode, WeekNode, DateNode: TTreeNode;
begin
  { find out if we've already added a node with this year, all yearnodes are level 1 }
  YearNode:= GetNodeByTextAtLevel(trvNav,anItem.Date.YearAsString,true,1);
  if YearNode <> nil then begin
    { find out if we've already added a node with this week, all weeknodes are level 2 }
    WeekNode:= GetNodeByTextAtLevel(trvNav,anItem.Date.WeekNumberAsString,true,2);
    if WeekNode <> nil then begin
      if WeekNode.Parent = YearNode then begin
        { ok, we've got the right weeknode, now find out if we've already added a node with this date,
          all datenodes are level 3 }
        DateNode:= GetNodeByTextAtLevel(trvNav,anItem.Date.AsString,true,3);
        if DateNode <> nil then begin
          if DateNode.Parent = WeekNode then begin
            { hmmm, existing datenode, must concatenate the 2 streams... }
//            ConcatenateStreams(TDDCollectionItem(DateNode.Data).Text,anItem.Text);
            bc_utilities.ConcatenateStreams(TDDCollectionItem(DateNode.Data).Text,anItem.Text,true);
            YearNode.Collapse(true);
          end;
        end else begin
          { add our new datenode }
          DateNode:= AddChildNodeWithData(trvNav,WeekNode,anItem.Date.AsString,pointer(anItem));  // 1.st date
          YearNode.Collapse(true);
        end;
      end;
    end else begin
      { add our new weeknode and datenode }
      WeekNode:= AddChildNodeWithData(trvNav,YearNode,anItem.Date.WeekNumberAsString,nil);  // n.th week
      DateNode:= AddChildNodeWithData(trvNav,WeekNode,anItem.Date.AsString,pointer(anItem));  // n.th date
      YearNode.Collapse(true);
    end;
  end else begin { root assigned, yearnode does not exist = nil }
    if trvNav.Items.Count = 1 then begin
      fLevel1:= AddChildNodeWithData(trvNav,fRootNode,anItem.Date.YearAsString,nil);  // 1.st year
      WeekNode:= AddChildNodeWithData(trvNav,fLevel1,anItem.Date.WeekNumberAsString,nil);  // 1.st week
      DateNode:= AddChildNodeWithData(trvNav,WeekNode,anItem.Date.AsString,pointer(anItem));  // 1.st date
      fLevel1.Collapse(true);
    end else begin
      YearNode:= AddChildNodeWithData(trvNav,fRootNode,anItem.Date.YearAsString,nil);  // n.th year
      WeekNode:= AddChildNodeWithData(trvNav,YearNode,anItem.Date.WeekNumberAsString,nil);  // n.th week
      DateNode:= AddChildNodeWithData(trvNav,WeekNode,anItem.Date.AsString,pointer(anItem));  // n.th date
      YearNode.Collapse(true);
    end;
  end;
end;

procedure TfrmDataAware.ShowDataRead(aDataset: TDDCollection; aCount: ptruint);
var
  Ci: TCollectionItem;
  Item: TDDCollectionItem;
begin
  fFormModes:= [fmBrowse];
  stbStatus.SimpleText:= SerializeSet(fFormModes);
  { add a root node with data to the tree, data is a pointer to our dataset }
  trvNav.BeginUpdate; { speeds things up considerably }
  if trvNav.Items.Count = 0 then fRootNode:= AddRootNode(trvNav,'Dates',pointer(aDataset))
  else fRootNode:= trvNav.Items[0];
  { now run through our dataset and populate our treeview }
  for Ci in aDataset do begin
    Item:= TDDCollectionItem(Ci);
    FindAndAddYearNode(Item);
    stbStatus.SimpleText:= format('-> Year=%d, Week=%d, Date=%s <-',
                                 [Item.Date.Year,Item.Date.ISOWeekNumber,Item.Date.AsString]);
  end;
  fRootNode.Selected:= true;
  fRootNode.Collapse(true);
  fRootNode.Expand(false);
  trvNav.EndUpdate;
  fFormModes+= [fmInactive,fmBrowse];
  stbStatus.SimpleText:= SerializeSet(fFormModes);
end;

procedure TfrmDataAware.FormCreate(Sender: TObject);
begin
  fDt:= TIsoDateTime.Create(Now);
  fBom:= CreateBom;
  fObserver:= TDDObserver.Create(Self);
  fBom.Observed.FPOAttachObserver(fObserver);
  Caption:= fDt.AsISOString;
  Include(fFormModes,fmInactive); //bm
end;

procedure TfrmDataAware.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDataAware.btnAddClick(Sender: TObject);
var
  Item: TDDCollectionItem;
begin
  { TODO -o'/bc' -c'a.s.a.p' : implement the add method }
  fNewItem:= fBom.AddNew;
  PutFormInEditMode(true);    //bm
end;

procedure TfrmDataAware.btnDeleteClick(Sender: TObject);
var Item: TDDCollectionItem;
begin
  if trvNav.Selected.Level <> 3 then exit; { user can only manipulate level 3 nodes! }
  fFormModes:= [fmDelete];
  stbStatus.SimpleText:= SerializeSet(fFormModes); Application.ProcessMessages;  //bm
  Item:= TDDCollectionItem(trvNav.Selected.Data);
  if messagedlg('Delete diary entry '+trvNav.Selected.Text+' ?',
                mtConfirmation,
                [mbNo,mbYes],
                0) = mrYes then begin
    Item.Modified:= mDelete;
    fbom.AppendToDelta(Item);
  end;
  fFormModes:= [fmInactive,fmBrowse];
  stbStatus.SimpleText:= SerializeSet(fFormModes); Application.ProcessMessages;  //bm
end;

procedure TfrmDataAware.btnReadDataClick(Sender: TObject);

begin
  fBom.ReadDataWithBlob(false); // read ascending dates
  btnReadData.Enabled:= false; // only run once on app-startup
  fFormModes+= [fmBrowse];
  stbStatus.SimpleText:= SerializeSet(fFormModes); Application.ProcessMessages;  //bm
end;

procedure TfrmDataAware.btnUpdateClick(Sender: TObject);
begin
  fFormModes:= [fmEdit];
  stbStatus.SimpleText:= SerializeSet(fFormModes); Application.ProcessMessages;  //bm
  { #todo -o/bc -ca.s.a.p : implement the update method... }
end;

procedure TfrmDataAware.FormDestroy(Sender: TObject);
begin
  Exclude(fFormModes,fmBrowse); //bm
  fBom.Observed.FPODetachObserver(fObserver);
  fBom.Clear;
  fBom:= nil; { memory gets released / freed on program end, in bom_dd.pas }
  fObserver.Free;
  fDt:= nil;
end;

end.

