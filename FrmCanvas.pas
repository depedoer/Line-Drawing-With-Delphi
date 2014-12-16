unit FrmCanvas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type TRoom = record
  x, y : integer;
  name : string;
  selected : boolean;
end;

type
  TForm1 = class(TForm)
    Map: TImage;
    btnDrawBuilding: TButton;
    btnSnapping: TButton;
    btnUndo: TButton;
    btnDrawLines: TButton;
    lblSelectedRoom: TLabel;
    lblDrawLines: TLabel;
    lblSnapping: TLabel;

    procedure MapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MapMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnSnappingClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    function  roundLocation (input : integer) : integer;
    procedure drawPreLines();
    function getCurrentlySelectedRoom : TRoom;
    function getCurrentlySelectedRoomInt : Integer;
    procedure btnDrawBuildingClick(Sender: TObject);
    procedure btnDrawLinesClick(Sender: TObject);
  private

  public
    Drawing: Boolean;
    { Public declarations }
  end;



type TPointArray = array [1..1000, 1..4] of Integer;
type TRoomArray = array [1..100] of TRoom;

var
  Form1: TForm1;
  RoomLocations : TRoomArray;
  StartX, StartY : Integer;
  SPoint, EPoint: TPoint;
  Angle: Integer;
  ArrayPoints: TPointArray;
  Counter, roomCounter : Integer;
  SnappingEnabled, addingRoom, drawingEnabled : Boolean;
  lastMove : array [1..10] of Byte;


implementation

{$R *.dfm}
//returns the selected TRoom object
function TForm1.getCurrentlySelectedRoom : TRoom;
var i : integer;
  room : TRoom;
  varFound : boolean;
begin
  varFound := false;
  i := 1;           //loops through searching for the room
  if (getCurrentlySelectedRoomInt <> 0) then
  begin
    getCurrentlySelectedRoom := room;
  end else begin
    getCurrentlySelectedRoom := roomLocations[getCurrentlySelectedRoomInt];
  end;

end;

//returns the integer location of the currently selected room
function TForm1.getCurrentlySelectedRoomInt : Integer;
var i : integer;
  room : TRoom;
  varFound : boolean;
begin
  varFound := false;
  i := 0;           //loops through searching for the room
  while (varFound = false) AND (i < roomCounter) do
  begin
    inc(i);
    if (roomLocations[i].selected = true) then
    begin
      varFound := true;
    end;
  end;

  if (varFound = false) then
  begin
    getCurrentlySelectedRoomInt := 0; //returns 0 if no room found
  end else begin
  getCurrentlySelectedRoomInt := i; //else returns the room location
  end;

end;

//used to round a value to the nearest 10
function TForm1.roundLocation (input : integer) : integer;
var low : integer;
begin
  low := input mod 10;   //finds the remainder after dividing by 10
  if (low < 5) then
    roundLocation := input - low   //lower the value
  else
    roundLocation := input + 10 - low;  //raise the value
end;

//wipes the canvas and redraws all previously drawn objects
procedure TForm1.drawPreLines;
var i : integer;
begin
  map.canvas.brush.color:=clwhite;   //wipe the canvas
  map.canvas.rectangle(clientrect);
  map.canvas.brush.color:=clblack;   //set the brush to black
  cursor := crNone;
  cursor := crdefault;
  for i := 1 to counter do   //draw all lines held in the array
  begin
    map.Canvas.MoveTo(ArrayPoints[i, 1],  ArrayPoints[i, 2]);
    map.Canvas.LineTo(ArrayPoints[i, 3],  ArrayPoints[i, 4]);
  end;

  for i := 1 to roomCounter do  //draw all rooms held in the array
  begin
    if (roomLocations[i].selected = False) then   //if the room isn't selected, make it blue
      map.canvas.brush.color:=clblue
    else
      map.canvas.brush.color:=clred;  //if the room is selected make it red

    map.Canvas.Rectangle(roomLocations[i].x, roomLocations[i].y, roomLocations[i].x + 10, roomLocations[i].y + 10);  //draw the rectangle on the screen
  end;
end;


//triggered by snapping button, controls wether snapping is enabled
procedure TForm1.btnSnappingClick(Sender: TObject);
begin
  if snappingEnabled = true then //if snapping is enabled
  begin
    lblSnapping.Caption := '';
    snappingEnabled := false ;   //de-enable snapping
  end
  else begin
    snappingEnabled := true;   //otherwise enable snapping
    lblSnapping.Caption := 'Snap to Grid Enabled';
  end;
end;

//used to undo the last move, can undo up to 10 previous moves
procedure TForm1.btnUndoClick(Sender: TObject);
var
  i: Integer;
begin
  if lastMove[1] = 1 then  //if the last move was a draw line (value 1)
  begin
    dec(counter); //decrement the counter
    drawPreLines(); //draw the lines currently held in the array on the screen
    for i := 1 to 9 do  //bump all the items down the que
    begin
      lastMove[i] := lastMove[i+1];
    end;
    lastMove[10] := 0;   //fill the 10th position with 0 (null)
  end else if lastMove[1] = 2 then   //if the last move was a draw room (value 2)
  begin
    dec(roomCounter);         //decrement the counter
    drawPreLines(); //redraw the current objects on the canvas
    for i := 1 to 9 do  //bump all the items down the que
    begin
      lastMove[i] := lastMove[i+1];
    end;
    lastMove[10] := 0;   //fill the 10th position with 0 (null)
  end;


end;

//used to control wether lines should be drawn on the canvas
procedure TForm1.btnDrawLinesClick(Sender: TObject);
begin
  if (drawingEnabled = false) then   //if drawing is false
  begin
    drawingEnabled := true;      //enable drawing
    lblDrawLines.Caption := 'Drawing Lines';
  end
  else begin
    lblDrawLines.Caption :=''; //otherwise de-enable drawing
    drawingEnabled := false;
  end;
end;

//controls wether a room should be added
procedure TForm1.btnDrawBuildingClick(Sender: TObject);
begin
  addingRoom := true; //sets addingRoom Boolean to true
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
application.Terminate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
SnappingEnabled := False;
Counter := 0;
roomCounter := 0;
addingRoom := false;
drawingEnabled := false;

 with Map, canvas do
  begin
    brush.color:=clwhite;
    canvas.rectangle(clientrect);
  end;
end;

procedure TForm1.MapMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i, q: Integer;
begin
  if (addingRoom = true) then  //if we are adding a room
  begin
    inc(roomCounter);
    roomLocations[roomCounter].x := X;    //add the room
    roomLocations[roomCounter].y := Y;
    addingRoom := false;
    drawPreLines();   //redraw the canvas

    for i := 10 downto 2 do  //shift all the values along
    begin
      lastMove[i] := lastMove[i-1];
    end;
    lastMove[1] := 2; //2 is the code used to signify that the last move was adding a room
    repeat  //get the name of the room
      roomLocations[roomCounter].name := InputBox('Adding A Room', 'Please enter the name of the room:', 'Room ' + IntToStr(RoomCounter));
    until roomLocations[roomCounter].name <> '';

  end else if (drawingEnabled = true) then //if we're drawing lines
  begin
    for i := 10 downto 2 do  //shift all the values along
    begin
      lastMove[i] := lastMove[i-1];
    end;
    lastMove[1] := 1; //1 is the code used to signify that the last move was adding a line
    drawing := true;     //set drawing to true (not quiet sure why we have an if after this...)
    if Drawing = True then
      begin
        with Map.Canvas do
          begin
          if (snappingEnabled = false) then  //if snapping isnt enabled
          begin
            ArrayPoints[Counter + 1, 1] := x;  //save the starting points directly
            ArrayPoints[Counter + 1, 2] := y;
          end else begin
            ArrayPoints[Counter + 1, 1] := roundLocation(x);   //or round the starting points first
            ArrayPoints[Counter + 1, 2] := roundLocation(y);
          end;
          end;
      end;
  end else begin    //otherwise we're not drawing lines or adding a room, so we must be selecting
    roomLocations[getCurrentlySelectedRoomInt].selected := false; //clears the previously selected room
    lblSelectedRoom.Caption := '';  //clears the caption
    for i := 1 to roomCounter do
    begin      //if the mouse is over a room
      if (x >= roomLocations[i].x) AND (x <= roomLocations[i].x + 10) AND (y >= roomLocations[i].y) AND (y <= roomLocations[i].y + 10)  then
      begin

        roomLocations[i].selected := true;  //set it to true
        lblSelectedRoom.Caption := roomLocations[i].name + ' selected';
      end;
      drawPreLines();   //redraw the canvas
    end;
  end;
end;

//if the mouse is moving
procedure TForm1.MapMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var i : Integer;

begin
    if drawing = true then  //if we're drawing, we can draw the other line
    begin
      drawPreLines();  //draws the lines already held in the array on the canvas

      //draws a temporary line
      map.Canvas.MoveTo(ArrayPoints[counter + 1, 1],  ArrayPoints[counter + 1, 2]);
      if (snappingEnabled = false) then
      begin
        map.Canvas.LineTo(x, y);  //finished the temporary line in mouse location
      end else begin
        map.Canvas.LineTo(roundLocation(x), roundLocation(y));   //rounds mouse location befire finishing temporary line
      end;
    end;
  end;

//when we release the mouse
procedure TForm1.MapMouseUp(Sender: TObject; Button: TMouseButton;
                            Shift: TShiftState; X, Y: Integer);

begin
if Drawing then
  with Map do
    begin
        drawing := false;  //set drawing to false
        if snappingEnabled = false then
        begin
          arrayPoints[counter+1, 3] := x;  //save the finished values to the array
          arrayPoints[counter+1, 4] := y;
        end else begin
          arrayPoints[counter+1, 3] := roundLocation(x);
          arrayPoints[counter+1, 4] := roundLocation(y);
        end;
        inc(counter);
    end;
drawing := false;
end;

end.
