let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

  max = list:
    list
    |> builtins.foldl' (a: b:
      if a > b
      then a
      else b)
    0;

  pow = x: e:
    if e == 0
    then 1
    else x * (pow x (e - 1));

  parseArea = str:
    str
    |> builtins.split "\n"
    |> builtins.filter (elem: elem != [] && elem != "")
    |> builtins.map lib.strings.stringToCharacters;

  getElemArea = area: coord: let
    d1 = builtins.elemAt coord 0;
    d2 = builtins.elemAt coord 1;
  in
    builtins.elemAt (builtins.elemAt area d1) d2;

  explodate = d1Max: d2Max:
    lib.lists.range 0 d1Max
    |> builtins.concatMap (d1: lib.lists.range 0 d2Max |> builtins.map (d2: [d1 d2]));

  isCoordValid = d1Max: d2Max: coord: let
    d1 = builtins.elemAt coord 0;
    d2 = builtins.elemAt coord 1;
    d1Valid = 0 <= d1 && d1 <= d1Max;
    d2Valid = 0 <= d2 && d2 <= d2Max;
  in
    d1Valid && d2Valid;

  getAdjacents = area: d1Max: d2Max: coord: let
    d1 = builtins.elemAt coord 0;
    d2 = builtins.elemAt coord 1;
    adjacents =
      [
        [(d1 - 1) (d2 - 1)]
        [d1 (d2 - 1)]
        [(d1 + 1) (d2 - 1)]
        [(d1 - 1) d2]
        [(d1 + 1) d2]
        [(d1 - 1) (d2 + 1)]
        [d1 (d2 + 1)]
        [(d1 + 1) (d2 + 1)]
      ]
      |> builtins.filter (isCoordValid d1Max d2Max)
      |> builtins.map (getElemArea area);
  in
    adjacents;

  countRolls = places:
    places
    |> builtins.filter (elem: elem == "@")
    |> builtins.length;

  isRollPresent = area: coord:
    "@" == getElemArea area coord;

  isCoordReachable = area: d1Max: d2Max: coord: let
    adjs = getAdjacents area d1Max d2Max coord;
    rollCount = countRolls adjs;
  in
    rollCount < 4;

  solver1 = file: let
    area =
      file
      |> builtins.readFile
      |> parseArea;
    d1Max = (builtins.length area) - 1;
    d2Max = (builtins.elemAt area 0 |> builtins.length) - 1;
    areaCoordsAdj =
      explodate d1Max d2Max
      |> builtins.filter (isRollPresent area)
      |> builtins.filter (isCoordReachable area d1Max d2Max)
      |> builtins.length;
  in
    areaCoordsAdj;

  explodate2d = d1Max: d2Max:
    lib.lists.range 0 d1Max
    |> builtins.map (d1: lib.lists.range 0 d2Max |> builtins.map (d2: [d1 d2]));

  replaceSingleField = oldArea: removableCoords: coord:
    if builtins.elem coord removableCoords
    then "."
    else getElemArea oldArea coord;

  removeRolls = oldArea: removableCoords: d1Max: d2Max:
    explodate2d d1Max d2Max
    |> builtins.map (builtins.map (replaceSingleField oldArea removableCoords));

  reduceArea = oldArea: d1Max: d2Max: let
    removableCoords =
      explodate d1Max d2Max
      |> builtins.filter (isRollPresent oldArea)
      |> builtins.filter (isCoordReachable oldArea d1Max d2Max);
    newArea = removeRolls oldArea removableCoords d1Max d2Max;
  in
    if newArea == oldArea
    then newArea
    else (reduceArea newArea d1Max d2Max);

  countRollsInArea = area:
    area
    |> builtins.concatMap (elem: elem)
    |> builtins.filter (field: field == "@")
    |> builtins.length;

  solver2 = file: let
    area =
      file
      |> builtins.readFile
      |> parseArea;
    d1Max = (builtins.length area) - 1;
    d2Max = (builtins.elemAt area 0 |> builtins.length) - 1;
    reducedArea = reduceArea area d1Max d2Max;
    overallCount = countRollsInArea area;
    unremovableCount = countRollsInArea reducedArea;
  in
    overallCount - unremovableCount;
in {
  check1 = solver1 ./inputs/check.txt;
  part1 = solver1 ./inputs/part1.txt;
  check2 = solver2 ./inputs/check.txt;
  part2 = solver2 ./inputs/part1.txt;
}
