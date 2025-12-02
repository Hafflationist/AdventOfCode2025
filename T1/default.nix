let
  mod = a: b: let
    newA = a + 10 * b;
  in
    newA - (b * (newA / b));
  abs = a:
    if a > 0
    then a
    else -a;

  rotation2number = rotation: let
    direction =
      rotation
      |> builtins.toString
      |> builtins.substring 0 1;
    distance =
      rotation
      |> builtins.substring 1 (-1)
      |> builtins.fromJSON;
    number =
      if direction == "R"
      then distance
      else -distance;
  in
    number;

  parseRotations = content:
    content
    |> builtins.split "\n"
    |> builtins.filter (str: builtins.isString str)
    |> builtins.filter (str: (builtins.stringLength str) > 0)
    |> builtins.map rotation2number;

  solver1 = file: let
    fileContent = builtins.readFile file;
    parsedRotations = parseRotations fileContent;
    accumulated =
      parsedRotations
      |> builtins.foldl' (
        acc: elem: let
          head = builtins.elemAt acc 0;
          newHead = mod (head + elem) 100;
        in
          builtins.concatLists [[newHead] acc]
      ) [50]
      |> builtins.filter (value: value == 0)
      |> builtins.length;
  in
    accumulated;

  solver2 = file: let
    fileContent = builtins.readFile file;
    parsedRotations = parseRotations fileContent;
    countZeroPasses = state: direction: newState: let
      freeZeroPasses = abs (direction / 100);
      cleanDirection =
        if direction > 0
        then direction - (freeZeroPasses * 100)
        else direction + (freeZeroPasses * 100);
      newStateWithoutModulo = state + cleanDirection;
      zeroPass =
        if newStateWithoutModulo >= 100 || (newStateWithoutModulo <= 0 && state > 0) || newState == 0
        then 1
        else 0;
    in
      freeZeroPasses + zeroPass;
    # zeroPass;
    # freeZeroPasses;
    steps =
      parsedRotations
      |> builtins.foldl' (
        acc: elem: let
          head = builtins.elemAt acc 0;
          newHead = mod (head + elem) 100;
        in
          builtins.concatLists [[newHead] acc]
      ) [50];
    accumulated =
      parsedRotations
      |> builtins.foldl' (
        acc: elem: let
          newCounter = zeroPasses + acc.counter;
          newState = mod (acc.state + elem) 100;
          zeroPasses = countZeroPasses acc.state elem newState;
          newHistElem = {
            a_oldState = acc.state;
            b_newState = newState;
            dir = elem;
            zeroPass = zeroPasses;
          };
        in {
          counter = newCounter;
          state = newState;
          # hist = builtins.concatLists [acc.hist [newState]];
          hist = [];
        }
      ) {
        counter = 0;
        state = 50;
        hist = [];
      };
  in
    accumulated;
in {
  check1 = solver1 ./inputs/check.txt;
  part1 = solver1 ./inputs/part1.txt;
  check2 = solver2 ./inputs/check.txt;
  part2 = solver2 ./inputs/part2.txt;
}
