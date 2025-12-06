let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

  explodate = d1Max: d2Max:
    lib.lists.range 0 d1Max
    |> builtins.map (d1: lib.lists.range 0 d2Max |> builtins.map (d2: [d1 d2]));

  transpose = nestedList: let
    d1 = builtins.length nestedList;
    d2 = builtins.length (builtins.elemAt nestedList 0);
  in
    explodate (d2 - 1) (d1 - 1)
    |> builtins.map (coords:
      coords
      |> builtins.map (
        coord: let
          d1Inner = builtins.elemAt coord 0;
          d2Inner = builtins.elemAt coord 1;
        in
          builtins.elemAt (builtins.elemAt nestedList d2Inner) d1Inner
      ));

  parseNumberLine = line:
    line
    |> builtins.split " "
    |> builtins.filter (elem: elem != [] && elem != "")
    |> builtins.map builtins.fromJSON;

  parseOperators = line:
    line
    |> builtins.split " "
    |> builtins.filter (elem: elem != [] && elem != "");

  str2op = opStr: a: b:
    if opStr == "*"
    then a * b
    else a + b;

  opStr2NeutralElement = opStr:
    if opStr == "*"
    then 1
    else 0;

  calc = operatorStr: numberLine:
    numberLine
    |> builtins.foldl' (str2op operatorStr) (opStr2NeutralElement operatorStr);

  solver1 = file: let
    lines =
      file
      |> builtins.readFile
      |> builtins.split "\n"
      |> builtins.filter (elem: elem != [] && elem != "");
    numberLines =
      lines
      |> lib.lists.init
      |> builtins.map parseNumberLine
      |> transpose;
    operators =
      lines
      |> lib.lists.last
      |> parseOperators;
    calcResults =
      lib.lists.zipListsWith calc operators numberLines
      |> builtins.foldl' (a: b: a + b) 0;
  in
    calcResults;

  transposeStr = strList: let
    nestedCharList =
      strList
      |> builtins.map lib.strings.stringToCharacters;
  in
    transpose nestedCharList
    |> builtins.map (builtins.filter (char: char != " "))
    |> builtins.map lib.strings.concatStrings;

  parseNumberLineTrans = strListTrans:
    strListTrans
    |> builtins.map (elem:
      if elem == ""
      then "|"
      else elem)
    |> lib.strings.intersperse "o"
    |> lib.strings.concatStrings
    |> lib.strings.splitString "|"
    |> builtins.map (lib.strings.removeSuffix "o")
    |> builtins.map (lib.strings.removePrefix "o")
    |> builtins.map (lib.strings.splitString "o")
    |> builtins.map (builtins.map builtins.fromJSON);

  solver2 = file: let
    lines =
      file
      |> builtins.readFile
      |> builtins.split "\n"
      |> builtins.filter (elem: elem != [] && elem != "");
    numberLines =
      lines
      |> lib.lists.init
      |> transposeStr
      |> parseNumberLineTrans;
    operators =
      lines
      |> lib.lists.last
      |> parseOperators;
    calcResults =
      lib.lists.zipListsWith calc operators numberLines
      |> builtins.foldl' (a: b: a + b) 0;
  in
    calcResults;
in {
  check1 = solver1 ./inputs/check.txt;
  part1 = solver1 ./inputs/part1.txt;
  check2 = solver2 ./inputs/check.txt;
  part2 = solver2 ./inputs/part1.txt;
}
