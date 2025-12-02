let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

  parseSingleRange = rangeStr: let
    parts = rangeStr |> builtins.split "-" |> builtins.filter (elem: elem != []);
  in {
    begin = builtins.fromJSON (builtins.elemAt parts 0);
    end = builtins.fromJSON (builtins.elemAt parts 1);
  };

  explodeRange = range: let
    inherit (range) begin;
    inherit (range) end;
  in
    lib.lists.range begin end;

  parseRanges = content:
    content
    |> builtins.split ","
    |> builtins.filter (elem: elem != [])
    |> builtins.map parseSingleRange;

  checkNumber1 = number: let
    numberStr = builtins.toString number;
    numberStrLength = builtins.stringLength numberStr;
    firstHalf = builtins.substring 0 (numberStrLength / 2) numberStr;
    secondHalf = builtins.substring (numberStrLength / 2) (-1) numberStr;
  in
    if firstHalf == secondHalf
    then number
    else 0;

  solver1 = file: let
    fileContent = builtins.readFile file;
  in
    fileContent
    |> parseRanges
    |> builtins.concatMap explodeRange
    |> builtins.map checkNumber1
    |> builtins.foldl' (a: b: a + b) 0;

  getDivider = num:
    if num == 1
    then []
    else if num == 2
    then [1]
    else if num == 3
    then [1]
    else if num == 4
    then [1 2]
    else if num == 5
    then [1]
    else if num == 6
    then [1 2 3]
    else if num == 7
    then [1]
    else if num == 8
    then [1 2 4]
    else if num == 9
    then [1 3]
    else if num == 10
    then [1 2 5]
    else if num == 11
    then [1]
    else if num == 12
    then [1 2 3 4 6]
    else [0/0];

  splitStringEvenly = str: partitionLength: let
    strLength = builtins.stringLength str;
    partitionCount = strLength / partitionLength;
    cutPartition = nthPartition: let
      pos = nthPartition * partitionLength;
    in
      builtins.substring pos partitionLength str;
  in
    lib.lists.range 0 (partitionCount - 1)
    |> builtins.map cutPartition;

  checkNumber2 = number: let
    numberStr = builtins.toString number;
    numberStrLength = builtins.stringLength numberStr;
    goldenCutCount =
      numberStrLength
      |> getDivider
      |> builtins.map (splitStringEvenly numberStr)
      |> builtins.map lib.lists.unique
      |> builtins.filter (list: (builtins.length list) == 1)
      |> builtins.length;
  in
    if goldenCutCount > 0
    then number
    else 0;

  solver2 = file: let
    fileContent = builtins.readFile file;
  in
    fileContent
    |> parseRanges
    |> builtins.concatMap explodeRange
    |> builtins.map checkNumber2
    |> builtins.foldl' (a: b: a + b) 0;
in {
  check1 = solver1 ./inputs/check.txt;
  part1 = solver1 ./inputs/part1.txt;
  check2 = solver2 ./inputs/check.txt;
  part2 = solver2 ./inputs/part1.txt;
}
