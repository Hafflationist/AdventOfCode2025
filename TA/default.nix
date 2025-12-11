let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

  pow = x: e:
    if e == 0
    then 1
    else x * (pow x (e - 1));

  isOdd = n: (n / 2) * 2 != n;
  hasDigit = n: digit: isOdd (n / (pow 2 digit));

  powerset = list: let
    listLength = builtins.length list;
    createSublist = n:
      lib.lists.range 0 (listLength - 1)
      |> builtins.filter (hasDigit n)
      |> builtins.map (idx: builtins.elemAt list idx);
  in
    lib.lists.range 1 ((pow 2 (listLength + 2)) - 1)
    |> builtins.map createSublist;

  parseTargetLampState = str:
    str
    |> lib.strings.removeSuffix "]"
    |> lib.strings.removePrefix "["
    |> lib.strings.stringToCharacters
    |> lib.lists.imap0 (idx: char: {
      idx = idx;
      char = char;
    })
    |> builtins.filter (elem: elem.char == "#")
    |> builtins.map (elem: elem.idx)
    |> lib.lists.sort (a: b: a < b);

  parseButton = str:
    str
    |> lib.strings.removeSuffix ")"
    |> lib.strings.removePrefix "("
    |> lib.strings.splitString ","
    |> builtins.map builtins.fromJSON
    |> lib.lists.sort (a: b: a < b);

  parseJoltageRequirements = str:
    str
    |> lib.strings.removeSuffix "}"
    |> lib.strings.removePrefix "{"
    |> lib.strings.splitString ","
    |> builtins.map builtins.fromJSON;

  parseMachine = line: let
    parts = line |> lib.strings.splitString " ";
  in {
    initState = [];
    targetLampState =
      parts
      |> lib.lists.head
      |> parseTargetLampState;
    buttons =
      parts
      |> lib.lists.tail
      |> lib.lists.init
      |> builtins.map parseButton;
    joltage =
      parts
      |> lib.lists.last
      |> parseJoltageRequirements;
  };

  parseMachines = file: let
  in
    file
    |> builtins.readFile
    |> lib.strings.splitString "\n"
    |> builtins.filter (line: line != "")
    |> builtins.map parseMachine;

  toggleButton = lampState: button: let
    intersection = lib.lists.intersectLists lampState button;
    union = builtins.concatLists [lampState button];
  in
    lib.lists.subtractLists intersection union |> lib.lists.unique;

  toggleButtonList = lampState: buttonList: builtins.foldl' toggleButton lampState buttonList;

  initMachine = machine:
    machine.buttons
    |> powerset
    |> builtins.map (buttonList: let
      endState = toggleButtonList machine.initState buttonList |> lib.lists.sort (a: b: a < b);
    in {
      buttonList = buttonList;
      buttonListLength = builtins.length buttonList;
      endState = endState;
    })
    |> builtins.filter (r: r.endState == machine.targetLampState)
    |> lib.lists.sort (a: b: a.buttonListLength < b.buttonListLength)
    |> builtins.map (r: r.buttonListLength)
    |> lib.lists.head;

  solver1 = checkForGreenTiles: file: let
    machines = parseMachines file;
  in
    machines
    |> builtins.map initMachine
    |> builtins.foldl' (acc: elem: acc + elem) 0;
in {
  check1 = solver1 false ./inputs/check.txt;
  part1 = solver1 false ./inputs/part1.txt;
  # check2 = solver1 true ./inputs/check.txt;
  # part2 = solver1 true ./inputs/part1.txt;
}
