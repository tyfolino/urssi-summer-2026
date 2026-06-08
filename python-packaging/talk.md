class: middle, center, title-slide
count: false

# Structuring & Distributing Python Packages:<br> Turning analyses into scientific tools

.large.blue[Ty Janoski]<br>
.large[(Rutgers University)]
<br>
[tyler.janoski@rutgers.edu](mailto:tyler.janoski@rutgers.edu)
<br>

[URSSI Summer School on Research Software Development](https://github.com/si2-urssi/summerschool-June2026)

June 8th, 2026

---
# About Me

.kol-1-2[
.large[
* Climate scientist: my work focuses on the threat of compound flooding on the NJ powergrid
* Author of [ClimKern](https://github.com/tyfolino/climkern), a Python package for
  computing radiative feedbacks with climate-model kernels
* Started as analysis scripts in 2022; now a published, citable tool used by other groups thanks to a previous iteration of this school
* I care about **reusable** open science so we can build on each other's work
]
]
.kol-1-2[
.large[
**How this talk works:**

We'll learn the mechanics on a tiny *generic* package you can copy to your own work and use ClimKern as an example.
]
]

.footnote[
Adapted, with thanks, from [Matthew Feickert](https://www.matthewfeickert.com/)'s 2024
URSSI talk and [Kyle Niemeyer](https://kyleniemeyer.github.io/research-software-dev-modules/module-packaging/)'s packaging module.
]

---
# The typical workflow

.large[
1. Work on an idea for a paper with collaborators
2. Do exploratory analysis in scripts and the Jupyter ecosystem
3. As the research progresses, you write more complicated functions and workflows
4. Code begins to **sprawl** across multiple directories
5. Software dependencies become more complicated
6. The code "works on my machine" — but what about your collaborators?
]

.center.large.bold[This is painful and not reusable.]

---
# Reusable science, step by step

.large[
In this first scenario you'll probably see a lot of `sys.path` manipulation and a
catch-all `utils.py`:
]

```python
# analysis.py
import sys
from pathlib import Path

# Make ./code/stats.py visible to Python
sys.path.insert(1, str(Path(__file__).parent / "code"))
from stats import mean   # our own helper function
```

* This is *already better* than one giant file
* But now things are tied to a relative path on *your* computer, and break the moment you
  move or rename anything

.large[We can do much better — by making our code a **package**.]

---
# First, some vocabulary

.large[
* A **module** is a single `.py` file with definitions (functions, classes, ...)
* A **package** is a directory of modules, marked by an `__init__.py`
* A **distribution** is the bundled-up package you hand to `pip` (`pip install ...`)
]

```console
mypackage/             # the project folder
└── src/
    └── mypackage/     # the package (importable)
        ├── __init__.py   # makes it a package; defines the public API
        ├── stats.py      # a module
        └── helpers.py    # another module
```

.footnote[
"Package" gets used for both *the importable folder* and *the thing on PyPI*. Usually clear
from context.
]

---
# Before packaging: work in a virtual environment

.large[
Kyle covered this in **Managing environments** this morning — so just the one rule that
matters once we start packaging:
]

.center.large.bold[Always install your package into an *active* environment — one per project.]

.large[
That isolates each project's dependencies (and your in-development package itself) from
every other project and from system Python — no clashes, no "works on my machine."
]

.footnote[
`venv`, `conda` / `mamba`, or `uv` all give you this — whatever Kyle set you up with works
the same way here.
]

---
# Next steps: packaging your code

.large[
The goal: .bold[your code becomes installable] — then `import mypackage` works anywhere your
environment is active, no `sys.path` hacks.
]

.large[
You pick a **build backend** to do it, but can almost always default to the simplest:
]

<p style="text-align:center;">
   <a href="https://github.com/scientific-python/cookie">
      <img src="figures/cookie-backend-options.png" width=27%>
   </a>
</p>

* **pure Python**: [`hatchling`](https://hatch.pypa.io/) or [`setuptools`](https://setuptools.pypa.io/) (the classic)
* **compiled extensions** (C/C++/Fortran): [`scikit-build-core`](https://scikit-build-core.readthedocs.io/) + [`pybind11`](https://github.com/pybind/pybind11)

.footnote[
We'll use `hatchling` below — the simplest modern default. (ClimKern uses `setuptools`; both are valid.)
]

---
# First: what does "building" even mean?

.large[
**Building** = turning your human-readable source code into a tidy, installable bundle.
]

.center[![build pipeline: your code to pip install](figures/build-pipeline.svg)]

.large[
* a **wheel** (`.whl`) — a ready-to-install zip; `pip` just unzips it into place
* an **sdist** (`.tar.gz`) — your source files; `pip` builds it on the user's machine
]

.footnote[
You rarely build by hand for local work — `pip install .` does it for you. You build
explicitly when you're ready to publish.
]

---
# A clean project layout

.huge[
A modern package needs just **one** config file: [`pyproject.toml`](https://packaging.python.org/en/latest/guides/writing-pyproject-toml/).
]

```console
mypackage/
├── pyproject.toml   # the one config file (packaging + tools)
├── README.md        # what it is, how to use it
├── LICENSE          # so others can legally reuse it
└── src/
    └── mypackage/
        ├── __init__.py   # makes it a package
        └── stats.py      # your actual code
```

.footnote[
This is a **`src/` layout** — the package lives under `src/`. Copy this skeleton for your
own project and you're 90% of the way there.
]

---
# Flat vs. `src/` layout

.kol-1-2[
**Flat layout**
```console
mypackage/
├── pyproject.toml
└── mypackage/
    ├── __init__.py
    └── stats.py
```
Package sits next to the config.
]
.kol-1-2[
**`src/` layout**
```console
mypackage/
├── pyproject.toml
└── src/
    └── mypackage/
        ├── __init__.py
        └── stats.py
```
Package tucked under `src/`.
]

.large[
Both are valid! `src/` is a little safer: your tests import the **installed** package, not
whatever happens to be in the current folder — so you catch "forgot to include a file" bugs.
]

---
# Importing within your package

.large[
Inside a package, modules refer to each other with imports — two flavors:
]

```python
# src/mypackage/solvers/linear.py   — inside the "solvers" subpackage
from mypackage.stats import mean    # absolute: full path from the top
from ..stats import mean            # relative: ".." is the parent package
from .util import scale             # relative: "." is this subpackage
```

.large[
`__init__.py` decides the **public API** — what `import mypackage` actually exposes:
]

```python
# src/mypackage/__init__.py
from .stats import mean, median     # now usable as mypackage.mean
```

.footnote[
Prefer *absolute* imports for clarity; *relative* imports keep a package self-contained when
it's renamed. Pick one style and stay consistent.
]

---
# `pyproject.toml`: what is `.toml`?

.large[
> "TOML aims to be a .bold[minimal configuration file format] that's easy to read due to
> obvious semantics. TOML is designed to map unambiguously to a hash table." — https://toml.io/

A plain text format of `key = value` settings grouped under `[section]` headers — easy for
**humans** to read and **machines** to parse.
]

---
# `pyproject.toml`: how it gets built

.large[Two lines tell tools *how* to build your package:]

```toml
[build-system]
requires = ["hatchling"]              # the build backend to install
build-backend = "hatchling.build"     # ...and how to call it
```

.large[
* a **build backend** (here, `hatchling`) is the tool that *does* the building
* a **build frontend** (like `pip` or `build`) is the tool *you run*, which calls the backend
]

.footnote[
You almost never interact with the backend directly — `pip` and `build` talk to it for you.
Swap `hatchling` for `setuptools` and everything else below is identical.

.blue[In the wild:] ClimKern recently retired its old `setup.py` shim and now builds from
`pyproject.toml` alone (with `setuptools`).
]

---
# Project metadata: who & what

.large[Now the `[project]` table. Start with the **basics** — who made it and what it is:]

```toml
[project]
name = "mypackage"
version = "0.1.0"
description = "A tiny example package."
readme = "README.md"
license = "MIT"
authors = [
    {name = "Your Name", email = "you@example.com"},
]
```

.footnote[
`license = "MIT"` is an [SPDX identifier](https://spdx.org/licenses/) — a standard short
code for a license (the modern way, since PEP 639).

.blue[In the wild:] ClimKern doesn't hard-code its `version` at all — `setuptools-scm` reads
it straight from the latest `git` tag.
]

---
# Project metadata: what it needs to run

.large[Next, the package's **runtime needs**:]

```toml
requires-python = ">=3.9"

dependencies = [        # installed automatically with your package
    "numpy",
    "pandas>=2.0",
]
```

--

.large[**Optional** dependencies ("extras") users opt into:]

```toml
[project.optional-dependencies]
test = ["pytest"]       #  ->  pip install "mypackage[test]"
```

.footnote[
Pin loosely (`>=`) for a *library* so it plays nicely with others' projects.

.blue[Also worth adding:] `keywords`, `classifiers`, and `[project.urls]` — they fill out
your PyPI page (ClimKern's latest release added exactly this block).
]

---
# `pyproject.toml`: configuring your tools

.large[The same file configures your **dev tools** — no more one `.cfg` per tool:]

```toml
[tool.ruff]            # linter (catches bugs / style issues)
line-length = 88

[tool.pytest.ini_options]   # test runner
testpaths = ["tests"]
```

.footnote[
One file for packaging *and* your linter, formatter, test runner, type checker... it's the
center of a modern Python project.
]

---
# Installing your code

.large[With `pyproject.toml` in place, install your package into your environment:]

```console
$ cd mypackage
$ python -m pip install .
Successfully built mypackage
Successfully installed mypackage-0.1.0
```

.large[
Now `import mypackage` works anywhere your environment is active — no `sys.path`,
no relative paths.
]

---
# Packaging doesn't slow you down: editable installs

.huge[
Use an [editable install](https://pip.pypa.io/en/latest/topics/local-project-installs/#editable-installs) while developing:
]

```console
$ python -m pip install --editable .
```

.large[
This links your source folder into the environment, so **edits take effect immediately** —
no reinstall needed (unless you change `pyproject.toml`).

Develop your code and use it at the same time.
]

---
# Your first package: the whole recipe

.large[
**1.** Put your code under `src/mypackage/` with an `__init__.py`

**2.** Add a minimal `pyproject.toml`:
]

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "mypackage"
version = "0.1.0"
```

.large[
**3.** `python -m pip install --editable .` — now `import mypackage` works anywhere
]

.center.large.bold[That's a real, installable package. Everything else builds on this.]

---
# As it grows: subpackages & data files

.kol-1-2[
.large[
A package can nest **subpackages** (each with its own `__init__.py`) and ship non-code files
right alongside the modules.
]
]
.kol-1-2[
```console
src/mypackage/
├── __init__.py
├── stats.py
├── solvers/          # a subpackage
│   ├── __init__.py
│   ├── linear.py
│   └── util.py
└── data/
    └── coeffs.csv    # bundled data
```
]

.large[
Small reference data can travel *inside* the wheel. Large data (gigabytes) is better
downloaded on demand.
]

.footnote[
.blue[In the wild:] ClimKern's kernels are multi-GB, so it *downloads* them from Zenodo
(`python -m climkern download`) instead of bundling them in the package.
]

---
# Make a module runnable: the `main()` idiom

.large[
Put your logic in functions, then guard the entry point so the file can be *imported* and
run directly:
]

```python
# src/mypackage/cli.py
def main():
    ...                        # do the work

if __name__ == "__main__":     # true only when executed, not imported
    main()
```

* `import mypackage.cli` → defines `main()`, runs nothing
* `python -m mypackage.cli` → `__name__ == "__main__"`, so `main()` fires

.footnote[
This is the hook that `[project.scripts]` (next) and ClimKern's `python -m climkern` both
rely on.
]

---
# Console commands with `[project.scripts]`

.large[
Want your package to provide a **terminal command**? Point an entry point at a function:
]

```toml
[project.scripts]
mypackage = "mypackage.cli:main"   # runs mypackage.cli.main()
```

```console
$ mypackage --help        # now available on your PATH
```

.footnote[
.blue[In the wild:] ClimKern ships a `__main__.py` so users run
`python -m climkern download` to fetch its (multi-GB) data files from Zenodo.
]

---
# When `pip` isn't enough: the `conda` family

.large[
Some scientific packages depend on compiled, non-Python libraries (Fortran/C++ wrappers,
GPU stacks) that *aren't on PyPI* — so `pip install` alone can't get you there.
]

.large[
The `conda` family ([`conda`](https://docs.conda.io/), [`mamba`](https://mamba.readthedocs.io/),
[`pixi`](https://prefix.dev/docs/pixi/)) installs **prebuilt binaries** — Python *and* compiled
libraries (compilers, Fortran, even the full CUDA stack). Grab those first, then `pip`:
]

```console
$ conda create -n myenv python=3.11 <compiled-dep> -c conda-forge
$ conda activate myenv
$ pip install mypackage
```

.footnote[
The trade-off vs. `pip`: no matching prebuilt binary means no automatic build-from-source fallback.

.blue[In the wild:] ClimKern's regridder, [ESMPy](https://earthsystemmodeling.org/esmpy/),
is a compiled Fortran/C++ library installed exactly this way.
]

---
# Publishing your package to conda-forge

.large[
To let users `conda install` your package, submit a **recipe** to
[`conda-forge/staged-recipes`](https://github.com/conda-forge/staged-recipes):
]

* Write a small `meta.yaml` (name, version, source URL + hash, dependencies) — tools like
  [`grayskull`](https://github.com/conda/grayskull) generate it from your PyPI release
* Open a PR; once reviewed and merged, conda-forge auto-builds binaries for every platform
* You get a **feedstock** repo that re-builds automatically each time you publish a new version

.footnote[
Publish to PyPI *first* — most recipes just point at your PyPI sdist, and conda-forge keeps
itself in sync from there.
]

---
# Going further: distributing via Git

.large[
If your code is in a public Git repo, you've already done a version of distribution!
]

```console
# Works for pure-Python packages
$ python -m pip install "git+https://github.com/you/mypackage.git"

# General pattern (a specific branch, even)
$ python -m pip install "mypackage @ git+https://example.com/repo.git@branch"
```

.large[Great for trying a branch or an unreleased fix — but for users we want something tidier.]

---
# Building distributions: sdist & wheel

.large[
When you're ready to publish, **build** the two distribution files:
]

```console
$ python -m pip install --upgrade build
$ python -m build
Successfully built mypackage-0.1.0.tar.gz and mypackage-0.1.0-py3-none-any.whl
$ ls dist
mypackage-0.1.0-py3-none-any.whl   mypackage-0.1.0.tar.gz
```

* the **`.whl`** is the wheel (ready to install)
* the **`.tar.gz`** is the sdist (source)

---
# Uploading to a package index (PyPI)

.large[
Upload the files in `./dist/` to the [Python Package Index (PyPI)](https://pypi.org/) —
`pip`'s default index — and now *anyone* can `pip install mypackage`.
]

<p style="text-align:center;">
   <a href="https://pypi.org/project/climkern/">
      <img src="figures/pypi-page.png" width=42%>
   </a>
</p>

.footnote[
Historically you'd run `twine upload`. In 2026 there's a better way — see "What's new".
]

---
# Reproducibility: lock files

.large[
A library should support a range of dependency versions (reusable). But an
*analysis* you want to reproduce exactly needs a **lock file**: a hash-level record of every
dependency, pinned.
]

* For `pip`: [`pip-tools`](https://pip-tools.readthedocs.io/), [`uv`](https://docs.astral.sh/uv/)
* For the `conda` family: [`conda-lock`](https://conda.github.io/conda-lock/), [`pixi`](https://prefix.dev/docs/pixi/)

.large[Keep the lock file in version control alongside the analysis.]

---
# Make your software citable
.center.large[Kyle's Day 3 *Open science & software citation* goes deep — here's the packaging hook.]

.kol-1-2[
.large[
**[Zenodo](https://zenodo.org/)** archives each GitHub release and mints a **DOI**:

Tag a release → Zenodo mints a DOI → put it in your README and papers.

ClimKern: [10.5281/zenodo.10291284](https://doi.org/10.5281/zenodo.10291284)
]
]
.kol-1-2[
.large[
A [`CITATION.cff`](https://citation-file-format.github.io/) file tells GitHub *how* to cite
your software (adds a "Cite this repository" button):
]
```yaml
cff-version: 1.2.0
title: "ClimKern"
doi: "10.5281/zenodo.10291284"
authors:
  - family-names: "Janoski"
    given-names: "Tyler P."
contributors:        # credit your PR authors!
  - family-names: "Linke"
    given-names: "Olivia"
```
]

.footnote[
The **contributors** block matters — when someone lands a PR, add them here so they get
credit beyond the commit log.
]

---
# Essential files beyond the code

.large[
A package is more than `.py` files. Reviewers and users look for:
]

* **README** — what it is, how to install, a usage example
* **LICENSE** — without one, others legally can't reuse it
* **[CHANGELOG](https://keepachangelog.com/)** — human-readable version history, newest first ([semantic versioning](https://semver.org/): `MAJOR.MINOR.PATCH`)
* **CONTRIBUTING** — how to set up a dev environment and submit changes
* **CODE_OF_CONDUCT** — expectations for the community
* **CITATION.cff** — how to cite the software

.footnote[
You don't need all of these on day one — but a README and a LICENSE are the bare minimum to
share your work.
]

---
# What's new in 2026
.center[(the field has moved since the 2024 talks)]

.large[
[`uv`](https://docs.astral.sh/uv/) (from Astral, the `ruff` folks) is a fast Rust-based tool
covering the whole lifecycle — an option, not a requirement:
]

```console
$ uv venv                     # create a virtual environment
$ uv add numpy                # add a dependency to pyproject.toml + lock
$ uv run pytest               # run in the project env, auto-synced
$ uv build && uv publish      # build sdist + wheel, then upload to PyPI
$ uvx ruff check .            # run a tool without installing it (like pipx)
```

.large[
**Publishing is safer, too:** 2FA is now mandatory on PyPI, and
[**Trusted Publishing**](https://docs.pypi.org/trusted-publishers/) lets GitHub Actions upload
via OpenID Connect — no API tokens to manage or leak (goodbye, `twine upload`).
]

---
# Don't start from scratch

.large[
Use a template to set up your repo with best practices baked in:
]

* [`scientific-python/cookie`](https://github.com/scientific-python/cookie) — templates for
  11+ build backends, plus CI, linting, and docs scaffolding
* [`copier`](https://copier.readthedocs.io/) — like cookiecutter, but lets you **re-apply**
  template updates to an existing project later

```console
$ uvx copier copy gh:scientific-python/cookie my-new-package
```

---
# Recommendation: follow community guides

.large[
Packaging best practices keep changing (for the better). Instead of maintaining your own
lore, **follow and engage** with the teams building the tools.
]

<p style="text-align:center;">
   <a href="https://learn.scientific-python.org/development/">
      <img src="figures/scientific-python-development-guide.png" width=55%>
   </a>
</p>
.caption[[Scientific Python Library Development Guide](https://learn.scientific-python.org/development/)]

---
# Summary

.large[
* A **package** makes your code installable, importable, and shareable — no more `sys.path`
* `pyproject.toml` is the one file at the center of it all: build backend, metadata, tools
* **Build** → wheel/sdist → **PyPI** → anyone can `pip install` it
* Real packages (like ClimKern) add tests, a license, a DOI, and citation info on top
* In 2026: `uv`, SPDX licenses, standardized lock files, and Trusted Publishing make it smoother than ever
]

.center.large.bold[Copy the `mypackage` skeleton and you've already started.]

---
# References

.large[
1. [Matthew Feickert's 2024 URSSI packaging talk](https://github.com/matthewfeickert-talks/talk-urssi-summer-school-2024)
2. [Kyle Niemeyer's packaging module](https://kyleniemeyer.github.io/research-software-dev-modules/module-packaging/)
3. [PyPA Packaging Python Projects Tutorial](https://packaging.python.org/en/latest/tutorials/packaging-projects/)
4. [Scientific Python Library Development Guide](https://learn.scientific-python.org/development/)
5. [`uv` documentation](https://docs.astral.sh/uv/)
6. [ClimKern](https://github.com/tyfolino/climkern) (the real-world example)
]

---
class: middle, center
count: false

# The end.

Copy the skeleton · `pip install mypackage` · build · publish
