# JuDoc

| Status | Coverage |
| :----: | :----: |
| [![Build Status](https://travis-ci.org/tlienart/JuDoc.jl.svg?branch=master)](https://travis-ci.org/tlienart/JuDoc.jl) | [![codecov.io](http://codecov.io/github/tlienart/JuDoc.jl/coverage.svg?branch=master)](http://codecov.io/github/tlienart/JuDoc.jl?branch=master) |

1. [What's this about](#about)
    1. [Short example](#short-ex1)
1. [Installation](#installation)
    1. [The engine](#the-engine)
    1. [Rendering](#rendering)
    1. [Minifying](#minifying)
1. [Getting started](#getting-started)
    1. [Folder structure](#folder-structure)
1. [Shortcuts](#shortcuts)

## What's this about? <a id="about"></a>

JuDoc is a simple static site generator (SSG) oriented towards technical blogging (code, maths, ...) and written in Julia.
I use it to generate [my website](https://tlienart.github.io).

It's basically the same as most SSG using Markdown as base syntax with extensions allowing LaTeX-like commands.
Not just for maths (which is rendered using KaTeX) but also to define macros using `\newcommand{...}[...]{...}` as in LaTeX.

### Short example <a id="short-ex1"></a>

To give an idea of the syntax, the source below renders to [this page](https://tlienart.github.io/pub/misc/judoc-example1.html) (open it in a new window to compare).
If you like what you see, read on.

<!-- =========== EXAMPLE =========== -->
```markdown
@def isdemo = true      <!-- these are page variables that are used to -->
@def hascode = true     <!-- determine how the html should be rendered,  -->
@def title = "Example"  <!-- e.g. what css sheets to include -->

\newcommand{\R}{\mathbb R}                <!-- just like in LaTeX; you can -->
\newcommand{\E}{\mathbb E}                <!-- use this for maths but also -->
\newcommand{\scal}[1]{\langle #1 \rangle} <!-- for things that are repeated -->

# JuDoc Example

You can define commands in a same way as in LaTeX, and use them in the same
way: $\E[\scal{f, g}] \in \R$.
Math is displayed with [KaTeX](https://katex.org) which is much faster than MathJax.

$$ \hat f(\xi) = \int_\R \exp(-2i\pi \xi t) \,\mathrm{d}t. \label{fourier} $$

The syntax is basically an extended form of GitHub Flavored Markdown
([GFM](https://guides.github.com/features/mastering-markdown/))
allowing for some **LaTeX** as well as **div blocks**:

@@colbox-yellow
Something inside a div with div name "colbox-yellow"
@@

You can add figures, tables, links and code just as you would in GFM.
For syntax highlighting, [highlight.js](https://highlightjs.org) is used by default.

## Why?

Extending Markdown allows to define LaTeX-style commands for things that may
appear many times in the current page (or in all your pages), for example let's
say you want to define an environment for systematically inserting images from
a specific folder within a specific div.
You could do this with:

\newcommand{\smimg}[1]{@@img-small ![](/assets/misc/smimg/!#1) @@}

\smimg{marine-iguanas-wikicommons.jpg}

It also allows things like referencing (which is not natively supported by
KaTeX for instance):

$$ \exp(i\pi) + 1 = 0 \label{a nice equation} $$

can then be referenced as such: \eqref{a nice equation} unrelated to
\eqref{fourier} which is convenient for maths notes.
```
<!-- =========== end EXAMPLE =========== -->

## Installation

In short:

* `add https://github.com/tlienart/JuDoc.jl` in Julia ≥ 0.7
* `npm install -g browser-sync`
* `pip install css-html-js-minify`

details below.

### The engine

To install JuDoc, you need [Julia](https://julialang.org/) (0.7 or above) and JuDoc (which is currently unregistered):

```
] # enter package mode
(v 1.0) > add https://github.com/tlienart/JuDoc.jl
```

### Rendering

To render your site locally, `JuDoc.serve()` uses [`browser-sync`](https://browsersync.io/) which allows you to directly see the modifications you make in your browser.
It is not necessary to install it i.e.: you could just run JuDoc, push the pages on GitHub and see how they get rendered there but it's easier to see how your website renders locally with any modifications you make being applied live.
To install [`browser-sync`](https://browsersync.io/) just run

```
npm install -g browser-sync
```

(which requires you to have [`npm`](https://www.npmjs.com/get-npm) but it's unlikely you don't.)

### Minifying

The files generated by JuDoc are pretty simple and thus pretty light already but they can still be compressed a bit more.
For this we use the simple [`css-html-js-minify`](https://github.com/juancarlospaco/css-html-js-minify) which can be installed via `pip`:

```
pip install css-html-js-minify
```

Again, it's not a required dependency, it is however encoded in `JuDoc.publish()` so if you use that, JuDoc will assume that you have it.

**Remark** there are more sophisticated minifiers out there however the script above is simple and has the added advantage that it doesn't clash with KaTeX which [`html-minifier`](https://github.com/kangax/html-minifier) does in my experience.

## Getting started

### Folder structure

The starting point should be a folder with the following structure (the folders/files marked with a star *must* be
there)

```
site
+-- assets
+-- libs (*)
|   +-- katex
|   +-- prism
+-- src (*)
|   +-- _css (*)
|   +-- _html_parts (*)
|   +-- pages (*)
|   |   +-- folder1 ...
|   |   +-- folder2 ...
|	|	+-- ...
|   +-- config.md
|   +-- index.md
```

The folders can be described as follows:

* `assets`: essentially contains files like images.
* `libs`: contains files necessary to run libraries such as [KaTeX](https://katex.org) and [highlight.js](https://highlightjs.org/).
* `src`: this is the folder where you work
    * `src/_css`: is where you should modify your CSS files
    * `src/_html_parts`: is where basic html building blocks are defined (head, foot etc) which are used in assembling the final pages
    * `src/pages/*`: is where you should put your notes in `.md` files
    * `src/config.md`: is a global configuration file where you can store variables such as the author name or latex commands you want to be able to use throughout
    * `src/index.md`: is the file corresponding to the landing page

Note that `src/pages/*` can contain plain html files which will be available to your website untouched, in a similar way, you can write the landing page directly in html and just have `src/index.html` instead of `src/index.md` if you prefer.

After running JuDoc, a few extra folders will appear (marked with a dagger)

```
site
+-- assets
+-- css (†)
+-- libs
+-- pub (†)
|   +-- folder1 ...
|   +-- folder2 ...
+-- src
+-- index.html (†)
```

* `css/`: contains the css that your website will use, it's effectively copied (and possibly minified) from `src/_css/*`
* `pub/*`: contains all the (possibly minified) html pages that have been generated from your `.md` notes
* `index.html`: is the generated landing page from `index.md`


## Shortcuts

It quickly becomes convenient to define the following two shortcuts and save them in your bash profile:

1. a shortcut for running the engine and live serving on port 8000 via browser-sync: `alias jd="using JuDoc; JuDoc.serve()"`
2. a shortcut for minifying the generated pages and push everything to GitHub: `alias jdp="using JuDoc; JuDoc.publish()"`

The `serve` and `publish` commands have a few simple arguments, have a look in [judoc.jl](https://github.com/tlienart/JuDoc.jl/blob/master/src/manager/judoc.jl) for more informations.
