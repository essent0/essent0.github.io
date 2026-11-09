# Adding notes

On a fresh Ubuntu install, these packages are enough to build the native gems and preview the site:

```bash
sudo apt install \
  build-essential \
  ca-certificates \
  libffi-dev \
  libssl-dev \
  libyaml-dev \
  pkg-config \
  ruby \
  ruby-bundler \
  ruby-dev \
  zlib1g-dev
```

Then, from this repository:

```bash
./bin/serve
```

Open http://127.0.0.1:4000/. The first run installs the gems. Stop the server with Ctrl-C.

## Top-level category

In `_config.yml`, add the topic, its collection, and a `note` layout default. The collection name is the folder name without the leading underscore.

```yaml
topics:
  - name: Physics
    slug: physics
    collection: physics
    description: Mechanics and other notes.

collections:
  physics:
    output: true
    permalink: /physics/:path/

defaults:
  - scope:
      path: ""
      type: physics
    values:
      layout: note
```

Create the folder `_physics/`. The site URL is `/physics/`.

## Subcategory

Add a folder inside the category. `index.md` is optional. When present, its title, description, and body are the subcategory page, and `order` controls where it sorts. Without it, the folder name is titleized (`graph-theory` becomes Graph Theory).

```text
_physics/mechanics/index.md
```

```yaml
---
title: Mechanics
description: Newtonian mechanics.
order: 1
---

Notes on motion.
```

## Document

Any other Markdown file in that folder is a note. It needs front matter. `order` is optional; otherwise notes sort by filename. Use `$...$` for inline math and `$$` for display math.

```text
_physics/mechanics/newton.md
```

```yaml
---
title: Newton's Laws
order: 1
---

The second law is $F = ma$.
```

## MathJax

Notes are rendered with [MathJax](https://docs.mathjax.org/en/v3.2-latest/) 3.2.2, using its TeX input (`tex-chtml`). Write LaTeX, not AsciiMath. The command list is the [TeX/LaTeX macro reference](https://docs.mathjax.org/en/v3.2-latest/input/tex/macros.html). Extra packages are listed under [TeX extensions](https://docs.mathjax.org/en/v3.2-latest/input/tex/extensions.html).

Inline math uses single dollar signs, with no space just inside them. Display math uses `$$` on their own lines. A real dollar sign is `\$`. Math inside a backtick code span or a fenced code block is left alone.

```markdown
The norm is $\|x\| = \sqrt{x_1^2 + x_2^2}$.

$$
\begin{align*}
e^{i\theta} &= \cos\theta + i\sin\theta.
\end{align*}
$$
```

Core TeX and [AMS](https://docs.mathjax.org/en/v3.2-latest/input/tex/extensions/ams.html) (`ams`) are already loaded, including `\mathbb`, `\operatorname`, matrices, and `align`. Numbered environments such as `equation` and `align` get equation numbers. Use the starred form, `align*`, to leave them unnumbered.

`\newcommand` is available. Other common packages load the first time you use one of their commands, including `\boldsymbol`, `\cancel`, `\color`, `\bra` and `\ket`, and `\ce` for mhchem. Load anything else by name:

```latex
\require{physics}
```
