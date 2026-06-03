# URSSI Summer School 2026 — Ty Janoski's talks

Slides for the talks I'm giving at the
[URSSI Research Software Development Summer School](https://github.com/si2-urssi/summerschool-June2026)
(8–10 June 2026, Boston, MA).

All three are [Remark.js](https://remarkjs.com/) decks — plain Markdown rendered in the
browser, no build step. Each talk lives in its own self-contained directory.

## Talks

| Talk | Slides | Source |
|:--|:--|:--|
| Structuring & Distributing Python Packages | [python-packaging/](./python-packaging/) | [`talk.md`](./python-packaging/talk.md) |
| Collaboration with Git & GitHub | [git-collaboration/](./git-collaboration/) | [`talk.md`](./git-collaboration/talk.md) |
| Peer Code Review | [peer-review/](./peer-review/) | [`talk.md`](./peer-review/talk.md) |

Once published, the slides are served at:

- `https://tyfolino.github.io/<repo>/python-packaging/`
- `https://tyfolino.github.io/<repo>/git-collaboration/`
- `https://tyfolino.github.io/<repo>/peer-review/`

## Editing

Edit the `talk.md` in a talk's directory. In Remark.js:

- `---` starts a new slide
- `--` reveals content incrementally within a slide

## Previewing locally

Remark loads `talk.md` over HTTP, so serve the directory rather than opening the file
directly:

```console
$ python3 -m http.server
# then open http://localhost:8000/python-packaging/
```

## Credits

- The packaging talk is adapted from [Matthew Feickert](https://www.matthewfeickert.com/)'s
  2024 URSSI talk and [Kyle Niemeyer](https://kyleniemeyer.github.io/research-software-dev-modules/module-packaging/)'s
  packaging module.
- The git and peer-review talks are adapted from [Madicken Munk](https://munkm.github.io/)'s
  2024 URSSI lessons.

Examples throughout use my own package,
[ClimKern](https://github.com/tyfolino/climkern).
