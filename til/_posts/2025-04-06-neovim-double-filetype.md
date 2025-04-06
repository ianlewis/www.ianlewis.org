---
layout: post
title: "TIL: Neovim Double Filetype"
date: "2025-04-06 00:00:00 +0900"
blog: til
# tags: <tags>
render_with_liquid: false
---

Sometimes you want to identify certain types not just by their base format but by a higher level format. For example, GitHub Actions are YAML, but they are a special kind of YAML and if you know that you can do added checks on it etc.

Neovim (and maybe Vim as well?) has the ability to mark files with multiple file types at once by joining them with a dot. This is most useful for adding a kind of filetype annotation. For example, I can create the type `yaml.ghaction` which will denote that the file is YAML so it gets the normal YAML syntax highlighting, but I can also match on the full file type to enable other checks like running `actionlint` on the file. The following adds the `yaml.ghaction` filetype when matching against yaml files in a `.github/workflows` directory.

```lua
vim.filetype.add({
    pattern = {
        -- Add a special file type extension to indicate a GitHub Actions
        -- workflow. This is used to run GitHub Actions linters.
        [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
    },
})
```

And here I set up `efm-langserver` to run `actionlint` as a linter for the `yaml.ghaction` filetype but not for the `yaml` filetype.

```lua
local prettier = require("efmls-configs.formatters.prettier")
local actionlint = require("efmls-configs.linters.actionlint")
local yamllint = require("efmls-configs.linters.yamllint")

lspconfig.efm.setup({
    init_options = { documentFormatting = true },
    settings = {
        rootMarkers = { ".git/" },
        languages = {
            yaml = { prettier, yamllint },
            ["yaml.ghaction"] = { prettier, actionlint, yamllint },
        },
    },
})
```
