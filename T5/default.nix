let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

  parseIngredients = ingredientsStr:
    ingredientsStr
    |> builtins.split "\n"
    |> builtins.filter (elem: elem != [] && elem != "")
    |> builtins.map builtins.fromJSON;

  parseRanges = rangesStr:
    rangesStr
    |> builtins.split "\n"
    |> builtins.filter (elem: elem != [] && elem != "")
    |> builtins.map (builtins.split "-")
    |> builtins.map (builtins.filter (elem: elem != [] && elem != ""))
    |> builtins.map (builtins.map builtins.fromJSON);

  checkIngredientOnSingleRange = range: ingredient: let
    min = builtins.elemAt range 0;
    max = builtins.elemAt range 1;
  in
    min <= ingredient && ingredient <= max;

  checkIngredientOnRanges = ranges: ingredient:
    ranges
    |> builtins.any (range: checkIngredientOnSingleRange range ingredient);

  countFreshIngredients = ranges: ingredients:
    ingredients
    |> builtins.filter (checkIngredientOnRanges ranges)
    |> builtins.length;

  solver1 = file: let
    splittedContent =
      file
      |> builtins.readFile
      |> builtins.split "\n\n"
      |> builtins.filter (elem: elem != [] && elem != "");
    ranges = builtins.elemAt splittedContent 0 |> parseRanges;
    ingredients = builtins.elemAt splittedContent 1 |> parseIngredients;
  in
    countFreshIngredients ranges ingredients;

  mergeRanges = ranges: let
    mergeRangesInner = acc: currentRange: let
      lastRange = lib.lists.last acc;
      lastRangeMax = builtins.elemAt lastRange 1;
      currentRangeMin = builtins.elemAt currentRange 0;
      newAcc =
        if lastRangeMax + 1 >= currentRangeMin
        then let
          currentRangeMax = builtins.elemAt currentRange 1;
          bothMax =
            if currentRangeMax > lastRangeMax
            then currentRangeMax
            else lastRangeMax;
          mergedRange = [(builtins.elemAt lastRange 0) bothMax];
          accWithMerged = builtins.concatLists [(lib.lists.init acc) [mergedRange]];
        in
          accWithMerged
        else builtins.concatLists [acc [currentRange]];
    in
      if acc == []
      then [currentRange]
      else newAcc;
  in
    ranges
    |> lib.lists.sortOn (range: builtins.elemAt range 0)
    |> builtins.foldl' mergeRangesInner [];

  countFreshIngredients2 = range: let
    min = builtins.elemAt range 0;
    max = builtins.elemAt range 1;
  in
    max - min + 1;

  solver2 = file: let
    splittedContent =
      file
      |> builtins.readFile
      |> builtins.split "\n\n"
      |> builtins.filter (elem: elem != [] && elem != "");
    ranges =
      builtins.elemAt splittedContent 0
      |> parseRanges
      |> mergeRanges
      |> builtins.map countFreshIngredients2
      |> builtins.foldl' (a: b: a + b) 0;
  in
    ranges;
in {
  check1 = solver1 ./inputs/check.txt;
  part1 = solver1 ./inputs/part1.txt;
  check2 = solver2 ./inputs/check.txt;
  part2 = solver2 ./inputs/part1.txt;
}
