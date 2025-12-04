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

  parseBatteryBank = lineStr:
    lineStr
    |> lib.strings.stringToCharacters
    |> builtins.map builtins.fromJSON;

  bankToJoltage = digitsLeft: bank: let
    firstDigit =
      bank
      |> lib.lists.dropEnd digitsLeft
      |> max;
    firstDigitPosition = bank |> lib.lists.findFirstIndex (elem: elem == firstDigit) null;
    bankLeft = bank |> lib.lists.drop (firstDigitPosition + 1);
    lowerJoltage = bankToJoltage (digitsLeft - 1) bankLeft;
    joltage = lowerJoltage + (pow 10 digitsLeft) * firstDigit;
  in
    if digitsLeft == 0
    then max bank
    else joltage;

  solver = digits: file: let
    fileContent =
      file
      |> builtins.readFile
      |> builtins.split "\n"
      |> builtins.filter (elem: elem != [] && elem != "")
      |> builtins.map parseBatteryBank
      |> builtins.map (bankToJoltage (digits - 1))
      |> builtins.foldl' (a: b: a + b) 0;
  in
    fileContent;
in {
  check1 = solver 2 ./inputs/check.txt;
  part1 = solver 2 ./inputs/part1.txt;
  check2 = solver 12 ./inputs/check.txt;
  part2 = solver 12 ./inputs/part1.txt;
}
