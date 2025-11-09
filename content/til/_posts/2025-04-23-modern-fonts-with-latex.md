---
layout: post
title: "TIL: Modern Fonts with LaTeX"
date: "2025-04-23 00:00:00 +0900"
blog: til
tags: programming latex
render_with_liquid: false
---

I recently learned that you can use modern fonts in LaTeX documents by using the
[`fontspec`] package. This allows you to take advantage of modern system fonts
like TrueType fonts when using [XeLaTeX] or [LuaLaTeX].

You can use the [Noto Sans] variable font in your LaTeX document by including
the following lines in your preamble. In my case I bundle the fonts in my
repository so I include a path to them in the `Path` option.

```latex
\usepackage{fontspec}

\setmainfont[
    Path                = path/to/fonts/,
    Extension           = .ttf,
    BoldFont            = {NotoSans-VariableFont_wdth,wght},
    ItalicFont          = {NotoSans-Italic-VariableFont_wdth,wght},
    BoldItalicFont      = {NotoSans-Italic-VariableFont_wdth,wght},
    BoldFeatures={RawFeature={+axis={wght=bold}}},
    BoldItalicFeatures={RawFeature={+axis={wght=bold}}},
]{NotoSans-VariableFont_wdth,wght}
```

[Noto Sans]: https://fonts.google.com/noto/specimen/Noto+Sans
[`fontspec`]: https://ctan.org/pkg/fontspec
[XeLaTeX]: https://www.tug.org/xetex/
[LuaLaTeX]: https://www.luatex.org/
