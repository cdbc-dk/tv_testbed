







(*
          if DateNode.Parent = WeekNode then stbStatus.SimpleText:= 'found '+DateNode.Text+' in '+WeekNode.Text;
          { hmmm, existing datenode, must concatenate the 2 streams... } //bm
          ConcatenateStreams(TDDCollectionItem(DateNode.Data).Text,anItem.Text);
          YearNode.Collapse(true);
*)

{$ifdef debug}
  memText.Append('Visiting existing: '+DateNode.Text);
{$endif}

{$ifdef debug}
  memText.Append('Visiting existing: '+WeekNode.Text);
{$endif}

{$ifdef debug}
  memText.Append('Visiting existing: '+YearNode.Text);
{$endif}

    { load the text from the dataset into our memo }
    Item.Text.Position:= 0; { seek to beginning of stream }
    memText.Lines.LoadFromStream(Item.Text);




 
