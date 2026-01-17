let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

  parseAdj = line: let
    words = line |> lib.strings.splitString " ";
  in {
    source =
      words
      |> lib.strings.head
      |> lib.strings.removeSuffix ":";
    targets =
      words
      |> lib.strings.tail;
  };

  parseGraph = file: let
  in
    file
    |> builtins.readFile
    |> lib.strings.splitString "\n"
    |> builtins.filter (line: line != "")
    |> builtins.map parseAdj;

  stepForwardSinglePath = adjs: path: let
    createPathFromNewNode = newNode: let
    in {
      lastNode = newNode;
      visitedFft = path.visitedFft || (newNode == "fft");
      visitedDac = path.visitedDac || (newNode == "dac");
    };
  in
    adjs
    |> builtins.filter (adj: adj.source == path.lastNode)
    |> builtins.concatMap (adj: adj.targets |> builtins.map createPathFromNewNode);

  stepForwardGenerateNewPaths = adjs: openPaths: let
    newPaths = openPaths |> builtins.concatMap (path: stepForwardSinglePath adjs path);

    newPaths' =
      if (builtins.length openPaths) == 0
      then []
      else
        builtins.concatLists [
          (openPaths |> lib.lists.head |> (stepForwardSinglePath adjs))
          (lib.lists.tail openPaths)
        ];
  in
    newPaths';

  stepForward = adjs: finalNodes: pathsPair: let
    openPaths = pathsPair.openPaths;

    newPaths = stepForwardGenerateNewPaths adjs openPaths;

    newFinalPathsCands = newPaths |> builtins.filter (path: builtins.elem path.lastNode finalNodes);
    newOpenPaths = newPaths |> builtins.filter (path: !(builtins.elem path.lastNode finalNodes));

    newVisitedFft = newFinalPathsCands |> builtins.filter (path: path.visitedFft) |> builtins.length;
    newVisitedDac = newFinalPathsCands |> builtins.filter (path: path.visitedDac) |> builtins.length;
    newVisitedBoth = newFinalPathsCands |> builtins.filter (path: path.visitedDac && path.visitedFft) |> builtins.length;
  in {
    finalPaths = {
      count = pathsPair.finalPaths.count + (builtins.length newFinalPathsCands);
      visitedFft = pathsPair.finalPaths.visitedFft + newVisitedFft;
      visitedDac = pathsPair.finalPaths.visitedDac + newVisitedDac;
      visitedBoth = pathsPair.finalPaths.visitedBoth + newVisitedBoth;
    };
    openPaths = newOpenPaths;
  };

  stepThrough = initNode: adjs: finalNodes: let
    initPath = {
      openPaths = [
        {
          lastNode = initNode;
          visitedFft = false;
          visitedDac = false;
        }
      ];
      finalPaths = {
        count = 0;
        visitedFft = 0;
        visitedDac = 0;
        visitedBoth = 0;
      };
    };
    chunkSize = 1000;

    chunks =
      lib.lists.range 0 chunkSize
      |> builtins.map (elem: lib.lists.range 0 chunkSize);
  in
    lib.lists.foldl
    (acc: chunk: lib.lists.foldl (paths: ignoreMe: stepForward adjs finalNodes paths) acc chunk)
    initPath
    chunks;

  solver1 = file: let
    adjs = parseGraph file;
    pathsPair = stepThrough "you" adjs ["out"];
  in
    # pathsPair;
    {
      finalCount = pathsPair.finalPaths.count;
      openCount = builtins.length pathsPair.openPaths;
    };

  # stepThrough2 = initNode: adjs: finalNodes: let
  #   initPathsPairPlus = {
  #     openPaths = [
  #       {
  #         lastNode = initNode;
  #         visitedFft = false;
  #         visitedDac = false;
  #       }
  #     ];
  #     finalPaths = [];
  #     finalPathsWithPerNode =
  #       finalNodes
  #       |> builtins.map (fn: {
  #         node = fn;
  #         count = 0;
  #       });
  #     finalPathsCount = 0;
  #   };
  #   stepForward2 = adjs: pathsPairPlus: let
  #     calculatedPathsPair = stepForward adjs finalNodes pathsPairPlus;
  #     newFinalPathsWithPerNode =
  #       finalNodes
  #       |> builtins.map (fn: {
  #         node = fn;
  #         count =
  #           (
  #             calculatedPathsPair.finalPaths
  #             |> builtins.filter (path: path.lastNode == fn)
  #             |> builtins.length
  #           )
  #           + (pathsPairPlus.finalPathsWithPerNode
  #             |> lib.lists.findFirst (c2n: c2n.node == fn) null).count;
  #       });
  #   in {
  #     openPaths = calculatedPathsPair.openPaths;
  #     finalPaths = [];
  #     finalPathsWithPerNode = newFinalPathsWithPerNode;
  #   };
  # in
  #   lib.lists.range 0 15
  #   |> builtins.foldl' (paths: ignoreMe: stepForward2 adjs paths) initPathsPairPlus;

  # Neuer Ansatz gegen RAM-Problem: Anfang der Liste löschen, weil man ihn praktisch nicht braucht!
  solver2 = file: let
    adjs = parseGraph file;
    result1 = stepThrough "svr" adjs ["out"];
    # result1 = stepThrough "svr" adjs ["fft" "dac"];
    # result2 = stepThrough "fft" adjs ["out" "dac"];
    # result3 = stepThrough "dac" adjs ["out" "fft"];
  in {
    # hugo1 = result1;
    finalPaths1 = result1.finalPaths;
    # finalPaths2 = result2.finalPaths;
    # finalPaths3 = result3.finalPaths;
    openPaths = builtins.length result1.openPaths;
    # hugo2 = result2.finalPaths |> builtins.length;
    # hugo3 = result3.finalPaths |> builtins.length;
  };
in {
  # check1 = solver1 ./inputs/check.txt;
  # part1 = solver1 ./inputs/part1.txt;
  # check2 = solver2 ./inputs/check2.txt;
  part2 = solver2 ./inputs/part1.txt;
}
