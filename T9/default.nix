let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

  parseTiles = file: let
    parseTile = line: let
      xy =
        line
        |> lib.strings.splitString ","
        |> builtins.map builtins.fromJSON;
    in {
      x = builtins.elemAt xy 0;
      y = builtins.elemAt xy 1;
    };
  in
    file
    |> builtins.readFile
    |> lib.strings.splitString "\n"
    |> builtins.filter (line: line != "")
    |> builtins.map parseTile;

  abs = a:
    if a < 0
    then -a
    else a;

  area = tile1: tile2: ((abs (tile1.x - tile2.x)) + 1) * ((abs (tile1.y - tile2.y)) + 1);

  inLine = a: b: c: a < b && b < c || c < b && b < a;

  isInRectanlge = tile1: tile2: tileInter:
    (inLine tile1.x tileInter.x tile2.x)
    && (inLine tile1.y tileInter.y tile2.y);

  largestAreaFromTile = checkForGreenTiles: tilesDensified: tiles: tile1: let
    tile2WithoutInterference =
      tiles
      |> builtins.filter (
        tile2:
          if checkForGreenTiles
          then
            0
            == (
              tilesDensified
              |> builtins.filter (isInRectanlge tile1 tile2)
              |> builtins.length
            )
          else true
      );
    tile2Candidates =
      tile2WithoutInterference
      |> builtins.map (t2: {
        t1 = tile1;
        t2 = t2;
        area = area tile1 t2;
      });
    tile2 =
      tile2Candidates
      |> lib.lists.sort (tile21: tile22: tile21.area > tile22.area)
      |> lib.lists.head;
  in
    tile2;

  densify = tiles: let
    fillGap = tile1: tile2: let
    in [
      {
        x = (tile1.x + tile2.x) / 2;
        y = (tile1.y + tile2.y) / 2;
      }
    ];
    densifyStep = denseTiles: currentTile: let
      lastDenseTile = lib.lists.last denseTiles;
      newDenseTiles = builtins.concatLists [
        denseTiles
        (fillGap lastDenseTile currentTile)
        [currentTile]
      ];
    in
      if 0 == (builtins.length denseTiles)
      then [currentTile]
      else newDenseTiles;
    lastTile = lib.lists.last tiles;
  in
    tiles
    |> builtins.foldl' densifyStep [lastTile]
    |> lib.lists.tail;

  largestArea = checkForGreenTiles: tiles: let
    tilesDensified = densify tiles;
  in
    tiles
    |> builtins.map (largestAreaFromTile checkForGreenTiles tilesDensified tiles)
    |> lib.lists.sort (a: b: a.area > b.area)
    |> lib.lists.head;

  solver1 = checkForGreenTiles: file: let
    tiles = parseTiles file;
  in
    largestArea checkForGreenTiles tiles;
in {
  check1 = solver1 false ./inputs/check.txt;
  part1 = solver1 false ./inputs/part1.txt;
  check2 = solver1 true ./inputs/check.txt;
  part2 = solver1 true ./inputs/part1.txt;
}
