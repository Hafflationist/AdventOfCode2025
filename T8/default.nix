let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;

  distance = b1: b2: let
    dx = b1.x - b2.x;
    dy = b1.y - b2.y;
    dz = b1.z - b2.z;
  in
    dx * dx + dy * dy + dz * dz;

  contains = cluster: box: 0 < (cluster |> builtins.filter (elem: elem == box) |> builtins.length);

  box2Hash = box: box.x + box.y * 100000 + box.z * 10000000000;

  allDistances = boxes:
    (lib.lists.crossLists (b1: b2: {
        box1 = b1;
        box2 = b2;
        distance = distance b1 b2;
      })
      [
        boxes
        boxes
      ])
    |> builtins.filter (dis: (box2Hash dis.box1) < (box2Hash dis.box2))
    |> lib.lists.sort (a: b: a.distance < b.distance);

  createClusterFromBoxes = boxes: builtins.map (box: [box]) boxes;

  mergeCluster = clusters: dis: let
    cluster1 = lib.lists.findFirst (elem: contains elem dis.box1) null clusters;
    cluster2 = lib.lists.findFirst (elem: contains elem dis.box2) null clusters;
    untouchedClusters = builtins.filter (elem: elem != cluster1 && elem != cluster2) clusters;
    newCluster = builtins.concatLists [cluster1 cluster2] |> lib.lists.unique;
    resultClusters = builtins.concatLists [untouchedClusters [newCluster]];
    resultClustersEventuallyWithShell =
      if (builtins.length resultClusters) == 1
      then [{a = dis.box1.x * dis.box2.x;}]
      else resultClusters;
  in
    if (builtins.length clusters) == 1
    then clusters
    else resultClustersEventuallyWithShell;

  parseContent = file: let
    parseLine = line: let
      xyz =
        line
        |> lib.strings.splitString ","
        |> builtins.map builtins.fromJSON;
    in {
      x = builtins.elemAt xyz 0;
      y = builtins.elemAt xyz 1;
      z = builtins.elemAt xyz 2;
    };
  in
    file
    |> builtins.readFile
    |> lib.strings.splitString "\n"
    |> builtins.filter (line: line != "")
    |> builtins.map parseLine;

  clusterize = connections: boxes: let
    distances = allDistances boxes |> lib.lists.take connections;
    clusters = createClusterFromBoxes boxes;
  in
    distances
    |> builtins.foldl' mergeCluster clusters;

  solver1 = connections: file: let
    boxes = parseContent file;
    mergedClusters =
      boxes
      |> clusterize connections
      |> lib.lists.sort (a: b: (builtins.length a) > (builtins.length b))
      |> builtins.filter (elem: 1 < (builtins.length elem))
      |> builtins.map builtins.length
      # |> builtins.foldl' (a: b: a + b) 0;
      |> lib.lists.take 3
      |> builtins.foldl' (a: b: a * b) 1;
  in
    mergedClusters;

  solver2 = file: let
    boxes = parseContent file;
    mergedClusters = clusterize 10000000000 boxes;
  in
    mergedClusters;
in {
  check1 = solver1 10 ./inputs/check.txt;
  part1 = solver1 1000 ./inputs/part1.txt;
  check2 = solver2 ./inputs/check.txt;
  part2 = solver2 ./inputs/part1.txt;
}
