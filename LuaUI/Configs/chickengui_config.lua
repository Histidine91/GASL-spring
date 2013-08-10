local configs = {}

configs.roostName = 'starbase'

configs.difficulties = {
    [0] = 0,
    [1] = 'Very Easy',
    [2] = 'Easy',
    [3] = 'Normal',
    [4] = 'Hard',
    [5] = 'Suicidal',
    [6] = 'Pods - Easy',
    [7] = 'Pods - Normal',
    [8] = 'Pods - Hard',
}

--ARGB
configs.colorSet = {
  dagger        = "\255\184\100\255",
  sword = "\255\100\100\170",
  mace       = "\255\255\100\100",
  claymore       = "\255\100\100\255",
  longbow       = "\255\255\120\80",
  dronelauncherm = "\255\100\170\170",
  --wraith   = "\255\150\001\150",
  comet       = "\255\255\255\100",
  --warhammer       = "\255\100\255\255",
  starslayer       = "\255\100\192\255",
  supportcarrier = "\255\100\100\120",
  meteor	= "\255\255\100\180",
  shuriken	= "\255\200\200\200",
  --carrier	= "\255\32\64\255",
}

return configs