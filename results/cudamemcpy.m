thisDirectory = If[TrueQ[StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName]],
  DirectoryName[$InputFileName],
  Directory[]
];

$rawDataFiles = <|
  "Whatever_pageable" ->FileNameJoin[{thisDirectory, "raw_data", "whatever", "cudamemcpy.json"}],
  "Whatever_pinned" ->FileNameJoin[{thisDirectory, "raw_data", "whatever", "cudamemcpy_pinned.json"}],
  "Minsky_pageable" -> FileNameJoin[{thisDirectory, "raw_data", "minsky", "cudamemcpy.json"}],
  "Minsky_pinned" -> FileNameJoin[{thisDirectory, "raw_data", "minsky", "cudamemcpy_pinned.json"}],
  "Minsky_pageable_TEST" -> FileNameJoin[{thisDirectory, "raw_data", "minsky", "test.smt0.cudamem.json"}],
  "Minsky_pinned_TEST" -> FileNameJoin[{thisDirectory, "raw_data", "minsky", "test.smt0.cudapinned.json"}]
|>;

data = KeyValueMap[
    Function[{key, val},
      Module[{info = Import[val, "RAWJSON"]},
        info["benchmarks"] = Append[#, "machine" -> key]& /@ info["benchmarks"];
        info = Append[info, "machine" -> key];
        info
      ]
    ],
    $rawDataFiles
];

groupedData = GroupBy[
  Flatten[Lookup[data, "benchmarks"]],
  Lookup[{"bytes"}]
];

makeChart[data_] :=
  BarChart[Association[
    SortBy[KeyValueMap[
      Function[{key, val},
       key -> AssociationThread[
         Lookup[val, "machine"] ->
          Lookup[val, "bytes_per_second"]/1024^3]], data], First]],
  BarSpacing -> {Automatic, 2},
  Frame -> True,
  FrameLabel -> {Row[{Spacer[600], "Bytes"}], "GigaBytes/Sec (Log scale)"},
  ChartLabels -> {Placed[First /@ Keys[data], Below, Rotate[#, 90 Degree] &], None}, ChartLegends -> Automatic,
  RotateLabel -> True,
  ImageSize -> 640,
  LegendAppearance -> "Column",
  ChartLegends -> Placed[Automatic, Right],
  BarSpacing -> {Automatic, 1},
  PlotTheme -> "FullAxesGrid",
  ScalingFunctions -> "Log",
  GridLines -> {None, Automatic},
  ChartStyle -> "Rainbow"
];

Export[FileNameJoin[{thisDirectory, "cudaMemcpy_plot.png"}], makeChart[groupedData], ImageSize->2400, ImageSize->2400, ImageResolution->400, RasterSize -> 400]
