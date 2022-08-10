
{***************************************************************************
*        Unit name : tv_const.pp                                           *
*        Copyright : (C)cdbc.dk 2022                                       *
*        Programmer: Benny Christensen                                     *
*        Created   : 2022.08.10 /bc constants etc. for tv_testbed.lpr      *
*        Updated   : 2022.08.10 /bc added git cheat sheet for pushing.     *
*                                                                          *
*                    2022.08.10 /bc                                        *
*                                                                          *
*                                                                          *
*                                                                          *
*                                                                          *
*                                                                          *
*                                                                          *
*                                                                          *
****************************************************************************
*        Purpose:                                                          *
*        Helper functions / procedures to aid in manipulating and          *
*        working with TTreeview and TTreeNodes                             *
*                                                                          *
*        Git 'push changes to github.com':                                 *
*        1) {git add *}                                                    *
*        2) {git commit -m "descriptive message here"}                     *
*        3) {git push origin branchname}                                   *
*        4) {enter username: cdbc-dk, enter token} -> done.                *
*        5) {checkout -b new_branch_name}                                  *
*           //remember the new name for next push.                         *
*                                                                          *
*                                                                          *
*                                                                          *
*        TODO:                                                             *
****************************************************************************
*        License:                                                          *
*        "Beer License" - If you meet me one day, you'll buy me a beer :-) *
*        I'm NOT liable for anything! Use at your own risk!!!              *
***************************************************************************}

unit tv_const;
{$mode objfpc}{$H+}
{.$define debug}
interface

uses
  Classes, SysUtils;

//const

//type

//var

//function Example: TObject; { global singleton }   

implementation

(*
var 
  __Example: TObject;

function Example: TObject; { singleton }
begin
  if not assigned(__Example) then __Example:= TObject.Create;
  Result:= __Example;
end; { gets released on progam end }
*)

initialization
//  __Example:= nil;

finalization 
//  FreeAndNil(__Example);
  
end.

