let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

  parseContent = file: let
    lines =
      file
      |> builtins.readFile
      |> lib.strings.splitString "\n"
      |> builtins.map lib.strings.stringToCharacters
      |> builtins.filter (elem: elem != [] && elem != "");
    startBeam =
      lines
      |> lib.lists.head
      |> lib.lists.findFirstIndex (e: e == "S") null;
  in {
    splitterLines = lib.lists.tail lines;
    startBeam = startBeam;
  };

  mergeBeams = beams: let
    idx2Count = idx:
      beams
      |> builtins.filter (beam: beam.idx == idx)
      |> builtins.map (beam: beam.count)
      |> builtins.foldl' (acc: elem: acc + elem) 0;
  in
    # beams;
    beams
    |> builtins.map (beam: beam.idx)
    |> lib.lists.unique
    |> builtins.map (idx: {
      idx = idx;
      count = idx2Count idx;
    });

  tachyonStep = acc: currentSplittingLine: let
    beamPartition = builtins.partition (beam: (builtins.elemAt currentSplittingLine beam.idx) == ".") acc.beams;
    beamsStoic = beamPartition.right;
    beamsSplitted =
      beamPartition.wrong
      |> builtins.concatMap (beam: [
        {
          idx = beam.idx - 1;
          count = beam.count;
        }
        {
          idx = beam.idx + 1;
          count = beam.count;
        }
      ]);
    newBeams =
      builtins.concatLists [beamsStoic beamsSplitted]
      |> lib.lists.sort (beam1: beam2: beam1.idx < beam2.idx)
      |> mergeBeams;
    newSplitCount = acc.splitCount + (builtins.length beamPartition.wrong);
  in {
    splitCount = newSplitCount;
    beams = newBeams;
  };

  solver1 = file: let
    content = parseContent file;
    splittingLines =
      content.splitterLines
      |> builtins.foldl' tachyonStep {
        splitCount = 0;
        beams = [
          {
            idx = content.startBeam;
            count = 1;
          }
        ];
      };
  in {
    beams = splittingLines.splitCount;
  };

  solver2 = file: let
    content = parseContent file;
    splittingLines =
      content.splitterLines
      |> builtins.foldl' tachyonStep {
        splitCount = 1;
        beams = [
          {
            idx = content.startBeam;
            count = 1;
          }
        ];
      };
    worldCount =
      splittingLines.beams
      |> builtins.map (beam: beam.count)
      |> builtins.foldl' (acc: elem: acc + elem) 0;
  in {
    # splittinLines = splittingLines;
    worldCount = worldCount;
  };
in {
  check1 = solver1 ./inputs/check.txt;
  part1 = solver1 ./inputs/part1.txt;
  check2 = solver2 ./inputs/check.txt;
  part2 = solver2 ./inputs/part1.txt;
}
