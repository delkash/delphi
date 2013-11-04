unit UTabSheetWithCloseButton;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, UxTheme, Themes, Math, XPMan, UFrmArquivo, UFrmAjuda,
  UFrmEditar, UFrmLocalizar;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Editar1: TMenuItem;
    Localizar1: TMenuItem;
    Ajuda1: TMenuItem;
    PageControlCloseButton: TPageControl;
    StatusBar1: TStatusBar;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure PageControlCloseButtonDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure PageControlCloseButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PageControlCloseButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PageControlCloseButtonMouseLeave(Sender: TObject);
    procedure PageControlCloseButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Arquivo1Click(Sender: TObject);
    procedure Editar1Click(Sender: TObject);
    procedure Localizar1Click(Sender: TObject);
    procedure Ajuda1Click(Sender: TObject);
  private
    FCloseButtonsRect: array of TRect;
    FCloseButtonMouseDownIndex: Integer;
    FCloseButtonShowPushed: Boolean;
    procedure CriarAba(clsForm: TFormClass; Index: Integer);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ http://stackoverflow.com/questions/2201850/how-to-implement-a-close-button-for-a-ttabsheet-of-a-tpagecontrol }
procedure TForm1.Ajuda1Click(Sender: TObject);
begin
  CriarAba(TFrmAjuda, 0);
end;

procedure TForm1.Arquivo1Click(Sender: TObject);
begin
  CriarAba(TFrmArquivo, 0);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  PageControlCloseButton.TabWidth := 150;
  PageControlCloseButton.TabHeight := 20;
  PageControlCloseButton.OwnerDraw := True;

  // should be done on every change of the page count
  SetLength(FCloseButtonsRect, PageControlCloseButton.PageCount);
  FCloseButtonMouseDownIndex := -1;

  for I := 0 to Length(FCloseButtonsRect) - 1 do
  begin
    FCloseButtonsRect[I] := Rect(0, 0, 0, 0);
  end;
end;

procedure TForm1.Localizar1Click(Sender: TObject);
begin
  CriarAba(TFrmLocalizar, 0);
end;

procedure TForm1.PageControlCloseButtonDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  CloseBtnSize: Integer;
  PageControl: TPageControl;
  TabCaption: TPoint;
  CloseBtnRect: TRect;
  CloseBtnDrawState: Cardinal;
  CloseBtnDrawDetails: TThemedElementDetails;
begin
  PageControl := TPageControl(Control);

  if InRange(TabIndex, 0, Length(FCloseButtonsRect) - 1) then
  begin
    CloseBtnSize := 14;
    TabCaption.Y := Rect.Top + 3;

    if Active then
    begin
      CloseBtnRect.Top := Rect.Top + 4;
      CloseBtnRect.Right := Rect.Right - 5;
      TabCaption.X := Rect.Left + 6;
    end
    else
    begin
      CloseBtnRect.Top := Rect.Top + 3;
      CloseBtnRect.Right := Rect.Right - 5;
      TabCaption.X := Rect.Left + 3;
    end;

    CloseBtnRect.Bottom := CloseBtnRect.Top + CloseBtnSize;
    CloseBtnRect.Left := CloseBtnRect.Right - CloseBtnSize;
    FCloseButtonsRect[TabIndex] := CloseBtnRect;

    PageControl.Canvas.FillRect(Rect);
    PageControl.Canvas.TextOut(TabCaption.X, TabCaption.Y, PageControl.Pages[TabIndex].Caption);

    if not(UseThemes) then
    begin
      if (FCloseButtonMouseDownIndex = TabIndex) and FCloseButtonShowPushed then
        CloseBtnDrawState := DFCS_CAPTIONCLOSE + DFCS_PUSHED
      else
        CloseBtnDrawState := DFCS_CAPTIONCLOSE;

      Windows.DrawFrameControl(PageControl.Canvas.Handle, FCloseButtonsRect[TabIndex], DFC_CAPTION, CloseBtnDrawState);
    end
    else
    begin
      Dec(FCloseButtonsRect[TabIndex].Left);

      if (FCloseButtonMouseDownIndex = TabIndex) and FCloseButtonShowPushed then
        CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonPushed)
      else
        CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonNormal);

      ThemeServices.DrawElement(PageControl.Canvas.Handle, CloseBtnDrawDetails, FCloseButtonsRect[TabIndex]);
    end;
  end;
end;

procedure TForm1.PageControlCloseButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  PageControl: TPageControl;
begin
  PageControl := TPageControl(Sender);

  if (Button = mbLeft) then
  begin
    for I := 0 to Length(FCloseButtonsRect) - 1 do
    begin
      if (PtInRect(FCloseButtonsRect[I], Point(X, Y))) then
      begin
        FCloseButtonMouseDownIndex := I;
        FCloseButtonShowPushed := True;
        PageControl.Repaint;
      end;
    end;
  end;
end;

procedure TForm1.PageControlCloseButtonMouseLeave(Sender: TObject);
var
  PageControl: TPageControl;
begin
  PageControl := TPageControl(Sender);
  FCloseButtonShowPushed := False;
  PageControl.Repaint;
end;

procedure TForm1.PageControlCloseButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  PageControl: TPageControl;
  Inside: Boolean;
begin
  PageControl := TPageControl(Sender);

  if (ssLeft in Shift) and (FCloseButtonMouseDownIndex >= 0) then
  begin
    Inside := PtInRect(FCloseButtonsRect[FCloseButtonMouseDownIndex], Point(X, Y));

    if FCloseButtonShowPushed <> Inside then
    begin
      FCloseButtonShowPushed := Inside;
      PageControl.Repaint;
    end;
  end;
end;

procedure TForm1.PageControlCloseButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  PageControl: TPageControl;
begin
  PageControl := TPageControl(Sender);

  if (Button = mbLeft) and (FCloseButtonMouseDownIndex >= 0) then
  begin
    if (PtInRect(FCloseButtonsRect[FCloseButtonMouseDownIndex], Point(X, Y))) then
    begin
      // ShowMessage('Button ' + IntToStr(FCloseButtonMouseDownIndex + 1) + ' pressed!');
      PageControl.Pages[PageControl.ActivePageIndex].Free;

      FCloseButtonMouseDownIndex := -1;
      PageControl.Repaint;
    end;
  end;
end;

procedure TForm1.CriarAba(clsForm: TFormClass; Index: Integer);
var
  { http: // www.lucianopimenta.com/post.aspx?id=171 }
  TabSheet: TTabSheet;
  Form: TForm;
  PageControl: TPageControl;
begin
  PageControl := PageControlCloseButton;
  Form := clsForm.Create(TabSheet);
  TabSheet := TTabSheet.Create(Self);

  TabSheet.PageControl := PageControl;
  TabSheet.Caption := Form.Caption;
  TabSheet.ImageIndex := Index;

  //Form.Align := alClient;
  Form.Position := poMainFormCenter;
  Form.BorderStyle := bsNone;
  Form.Parent := TabSheet;
  Form.Show;

  PageControl.ActivePage := TabSheet;
end;

procedure TForm1.Editar1Click(Sender: TObject);
begin
  CriarAba(TFrmEditar, 0);
end;

end.