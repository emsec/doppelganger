# Navigation
1. [Introduction](#introduction)
2. [Usage](#usage)
3. [Academic Context](#academic-context)

# Welcome to Doppelganger! <a name="introduction"></a>

Doppelganger is the first generic design-level obfuscation technique that is based on low-level camouflaging.
It obstructs encoding logic of digital designs, e.g., state transition logic of FSMs, resulting in two different design functionalities:
an apparent one that is recovered during reverse engineering and the actual one that is executed during operation.
Notably, both functionalities are under the designer's control.

This repository contains our code and results used for the experiments of our paper "Doppelganger Obfuscation --- Exploring the Defensive and Offensive Aspects of Hardware Camouflaging".

# Usage <a name="usage"></a>
Requirements:
 - `python3`
 - `graphviz` (optional, used for generating state transition graphs)

The file `doppelganger.py` contains the main obfuscation code, which is used by `obfuscate_fsm_states.py` and `obfuscate_bus_controller.py`.
Simply calling `python3 obfuscate_fsm_states.py` and `python3 obfuscate_bus_controller.py` will create the obfuscations used in our case studies.
You can comment in/out the various configurations in both files to generate the various settings presented in our paper.

# Academic Context <a name="academic-context"></a>

If you use Doppelganger in an academic context, please cite our paper using the reference below:
```latex
@article{DBLP:journals/tches/HoffmannP21,
  author    = {Max Hoffmann and
               Christof Paar},
  title     = {Doppelganger Obfuscation - Exploring theDefensive and Offensive Aspects
               of Hardware Camouflaging},
  journal   = {{IACR} Trans. Cryptogr. Hardw. Embed. Syst.},
  volume    = {2021},
  number    = {1},
  pages     = {82--108},
  year      = {2021},
  url       = {https://doi.org/10.46586/tches.v2021.i1.82-108},
  doi       = {10.46586/tches.v2021.i1.82-108},
  timestamp = {Fri, 29 Jan 2021 16:46:53 +0100},
  biburl    = {https://dblp.org/rec/journals/tches/HoffmannP21.bib},
  bibsource = {dblp computer science bibliography, https://dblp.org}
}
```
