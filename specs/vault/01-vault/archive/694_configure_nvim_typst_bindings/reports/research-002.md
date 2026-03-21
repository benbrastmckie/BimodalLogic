# Research Report: Modern Typst Neovim Integration (2026)

**Task**: 694 - configure_nvim_typst_bindings
**Started**: 2026-01-28T02:00:00Z
**Completed**: 2026-01-28T02:45:00Z
**Effort**: medium
**Priority**: normal
**Dependencies**: None
**Sources/Inputs**: Web search, official documentation, GitHub repositories, Typst Forum, community blog posts
**Artifacts**: specs/694_configure_nvim_typst_bindings/reports/research-002.md
**Standards**: report-format.md

## Executive Summary

- **typst.vim is NOT recommended** for modern Neovim setups in 2026 - it's a VimScript plugin with treesitter compatibility issues and no tinymist awareness
- **Minimal modern setup**: tinymist LSP + nvim-treesitter (typst parser) + typst-preview.nvim - no additional syntax plugin needed
- **nvim-treesitter includes Typst parser** (uben0/tree-sitter-typst) as an officially supported parser with active maintenance
- **typst-preview.nvim is the official Neovim plugin for tinymist** - automatically downloads and manages tinymist binaries
- **Neovim 0.11+ native LSP API** (`vim.lsp.config`) is the recommended approach over nvim-lspconfig wrappers
- **SeniorMars/typst.nvim is NOT production-ready** - only 6 commits, development stalled

## Context & Scope

### Research Objective
Investigate the modern 2026 Neovim ecosystem for Typst to correct/update the recommendations from research-001.md, which recommended typst.vim (a VimScript plugin).

### Key Questions Addressed
1. Is typst.vim still the right choice for Neovim?
2. What Lua-native alternatives exist?
3. How does treesitter integration work for Typst?
4. What's the minimal recommended setup in 2026?

## Findings

### 1. typst.vim Status and Limitations

**Source**: [kaarmu/typst.vim GitHub](https://github.com/kaarmu/typst.vim)

typst.vim is actively maintained (172 commits, 28 contributors) but has significant limitations for modern Neovim:

| Aspect | Status |
|--------|--------|
| Language | VimScript (not Lua-native) |
| Treesitter | **Explicit incompatibility** - `typst#synstack()` does not work with treesitter enabled (issue #117) |
| LSP awareness | References deprecated typst-lsp, no mention of tinymist |
| Modern Neovim | Limited integration with nvim-treesitter ecosystem |

**Recommendation**: Do not use typst.vim in a modern Neovim setup that uses treesitter. It provides redundant functionality (syntax highlighting, `:make` compilation) that is better handled by tinymist LSP and treesitter.

### 2. Modern Alternative: tinymist + treesitter + typst-preview.nvim

**Sources**:
- [Tinymist Neovim Documentation](https://myriad-dreamin.github.io/tinymist/frontend/neovim.html)
- [typst-preview.nvim GitHub](https://github.com/chomosuke/typst-preview.nvim)
- [Note-taking with Typst and Neovim in 2026](https://www.dogeystamp.com/typst-notes2/)

The 2026 recommended stack:

| Component | Purpose | Plugin/Tool |
|-----------|---------|-------------|
| Syntax highlighting | Treesitter-based | nvim-treesitter (typst parser builtin) |
| LSP features | Completion, diagnostics, formatting, hover, go-to-definition | tinymist |
| Live preview | Web-based instant preview | chomosuke/typst-preview.nvim |
| Formatting | Integrated in LSP | typstyle (bundled with tinymist) |

**Key insight from typst-preview.nvim**: "This is the Neovim plugin for Myriad-Dreamin/tinymist." It automatically downloads and manages tinymist binaries, so you don't need to install tinymist separately unless you want to manage the binary yourself.

### 3. nvim-treesitter Typst Parser

**Source**: [nvim-treesitter parsers.lua](https://github.com/nvim-treesitter/nvim-treesitter/blob/master/lua/nvim-treesitter/parsers.lua)

The Typst parser is officially included in nvim-treesitter:

```lua
list.typst = {
  install_info = {
    url = "https://github.com/uben0/tree-sitter-typst",
    files = { "src/parser.c", "src/scanner.c" }
  },
  maintainers = { "@uben0", "@RaafatTurki" }
}
```

**Key points**:
- Parser is fully integrated without experimental flags (production-ready)
- Two active maintainers
- No external plugin needed for syntax highlighting

### 4. Neovim 0.11+ Native LSP Configuration

**Sources**:
- [Neovim 0.11 LSP Configuration](https://lugh.ch/switching-to-neovim-native-lsp.html)
- [Native LSP config in Neovim V0.11](https://0xunicorn.com/neovim-native-lsp-config/)

Neovim 0.11 introduced `vim.lsp.config()` and `vim.lsp.enable()` APIs, making nvim-lspconfig optional:

```lua
-- Native approach (recommended for Neovim 0.11+)
vim.lsp.config["tinymist"] = {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { "typst.toml", ".git" },
  settings = {
    formatterMode = "typstyle",
    exportPdf = "onSave",
  }
}
vim.lsp.enable("tinymist")
```

**tinymist commands require Neovim 0.11+**: The `client:exec_cmd()` API used for tinymist commands is only available in Neovim 0.11+.

### 5. SeniorMars/typst.nvim Assessment

**Source**: [SeniorMars/typst.nvim GitHub](https://github.com/SeniorMars/typst.nvim)

| Aspect | Status |
|--------|--------|
| Development | **Stalled** - only 6 commits total |
| Releases | None published |
| Features | Planned but not implemented |
| Production readiness | **Not suitable** |

The author noted: "The issue is Typst is a big language, that I needed a break from this project for a bit."

**Recommendation**: Do not use typst.nvim - it's experimental/incomplete.

### 6. LazyVim Typst Extra (Reference Implementation)

**Source**: [LazyVim Typst Extra](http://www.lazyvim.org/extras/lang/typst)

LazyVim's official Typst configuration provides a reference implementation:

```lua
-- Treesitter
opts = { ensure_installed = { "typst" } }

-- LSP (tinymist)
opts = {
  servers = {
    tinymist = {
      keys = {
        { "<leader>cP", -- Pin main file command
          function()
            local buf_name = vim.api.nvim_buf_get_name(0)
            LazyVim.lsp.execute({
              command = "tinymist.pinMain",
              arguments = { buf_name },
            })
          end,
          desc = "Pin main file",
        },
      },
      single_file_support = true,
      settings = { formatterMode = "typstyle" },
    },
  },
}

-- Preview
{ "chomosuke/typst-preview.nvim",
  cmd = { "TypstPreview", "TypstPreviewToggle", "TypstPreviewUpdate" },
  keys = {
    { "<leader>cp", "<cmd>TypstPreviewToggle<cr>", ft = "typst", desc = "Toggle Typst Preview" },
  },
}
```

**Note**: LazyVim does NOT include typst.vim - further evidence it's not needed.

### 7. typst-preview.nvim Configuration

**Source**: [typst-preview.nvim Documentation](https://github.com/chomosuke/typst-preview.nvim)

Minimal lazy.nvim configuration:

```lua
{
  'chomosuke/typst-preview.nvim',
  lazy = false,  -- or ft = 'typst'
  version = '1.*',
  opts = {},  -- implicitly calls setup()
}
```

**Key capabilities**:
- Low-latency incremental rendering
- Cross-jump between code and preview (click on preview to jump to code)
- Cursor following (preview scrolls with cursor)
- Automatic binary management (downloads tinymist if not provided)

**Recent release**: v1.4.1 (December 2025)

### 8. Preview Command via tinymist LSP

**Source**: [Note-taking with Typst and Neovim in 2026](https://www.dogeystamp.com/typst-notes2/)

Alternative to typst-preview.nvim - use tinymist's built-in preview:

```lua
vim.lsp.get_clients({ name = "tinymist" })[1]:exec_cmd({
  command = "tinymist.startDefaultPreview",
  title = "Preview"
})
```

This opens a browser-based preview without needing typst-preview.nvim, though it lacks the cross-jump features.

## Decisions

1. **Remove typst.vim from recommendations** - treesitter provides syntax highlighting, tinymist provides everything else
2. **Use nvim-treesitter with typst parser** - officially supported, no additional plugin needed
3. **Keep typst-preview.nvim** - but clarify it's for cross-jump features, not strictly required for preview
4. **Use native vim.lsp.config** - consistent with Neovim 0.11+ best practices already used in the user's config
5. **Do not recommend SeniorMars/typst.nvim** - not production-ready

## Recommendations

### Revised Minimal Setup (Correcting research-001.md)

#### Phase 1: System Packages (NixOS)
```nix
# tinymist is OPTIONAL if using typst-preview.nvim (auto-downloads)
# Add only if you want system-managed binary:
tinymist
```

#### Phase 2: Remove typst.vim, Use Treesitter Only

Replace the recommended `lua/neotex/plugins/text/typst.lua`:

```lua
-- Do NOT use kaarmu/typst.vim - treesitter handles syntax highlighting
-- This file can be deleted or left empty
return {}
```

Update treesitter.lua:
```lua
-- Add "typst" to ensure_installed
ensure_installed = { "lua", "vim", ..., "typst" }
```

#### Phase 3: Updated typst-preview.nvim Configuration

```lua
return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = {
    -- If tinymist is installed system-wide:
    dependencies_bin = {
      tinymist = "tinymist",  -- Use system tinymist
    },
    -- Otherwise, remove dependencies_bin to auto-download
  },
}
```

#### Phase 4: Updated LSP Configuration (Native API)

```lua
vim.lsp.config["tinymist"] = {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { "typst.toml", ".git" },
  settings = {
    formatterMode = "typstyle",
    exportPdf = "onSave",
  },
}
vim.lsp.enable({ "lua_ls", "pyright", "texlab", "tinymist" })
```

#### Phase 5: Filetype Configuration

Create/update `after/ftplugin/typst.lua`:

```lua
-- Enable treesitter (tinymist may enable semantic tokens, but treesitter is primary)
vim.opt_local.syntax = "off"
pcall(vim.treesitter.start)

-- Typst-specific surround operations (unchanged from research-001.md)
require("nvim-surround").buffer_setup({
  surrounds = {
    ["b"] = { add = { "*", "*" } },
    ["i"] = { add = { "_", "_" } },
    ["$"] = { add = { "$", "$" } },
    ["c"] = { add = { "`", "`" } },
    ["e"] = {
      add = function()
        local fn = vim.fn.input("Function: ")
        return { { "#" .. fn .. "[" }, { "]" } }
      end,
    },
  },
})

-- which-key bindings under <leader>t (Typst)
local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
  wk.add({
    { "<leader>t", group = "typst", icon = "", buffer = 0 },
    { "<leader>tc", "<cmd>!typst compile %<CR>", desc = "compile", buffer = 0 },
    { "<leader>te", vim.diagnostic.open_float, desc = "errors", buffer = 0 },
    { "<leader>tf", function() vim.lsp.buf.format() end, desc = "format", buffer = 0 },
    { "<leader>tp", "<cmd>TypstPreviewToggle<CR>", desc = "preview toggle", buffer = 0 },
    { "<leader>tP", function()
      -- Pin main file for multi-file projects
      local buf = vim.api.nvim_buf_get_name(0)
      local clients = vim.lsp.get_clients({ name = "tinymist" })
      if #clients > 0 then
        clients[1]:exec_cmd({
          command = "tinymist.pinMain",
          arguments = { buf },
        })
        vim.notify("Pinned: " .. vim.fn.fnamemodify(buf, ":t"), vim.log.levels.INFO)
      end
    end, desc = "pin main file", buffer = 0 },
    { "<leader>tv", function()
      local pdf = vim.fn.expand("%:r") .. ".pdf"
      vim.system({ "sioyek", pdf })
    end, desc = "view PDF", buffer = 0 },
  })
end
```

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| typst-preview.nvim auto-download blocked by firewall | Install tinymist via NixOS and use `dependencies_bin` |
| Treesitter parser outdated | Parser is actively maintained (2 maintainers); check `:TSUpdate typst` periodically |
| tinymist commands fail on Neovim < 0.11 | User's config already uses 0.11+ features (vim.lsp.config) |

## Appendix

### Comparison: research-001.md vs research-002.md

| Aspect | research-001.md | research-002.md (Corrected) |
|--------|----------------|----------------------------|
| Syntax plugin | typst.vim | None (treesitter only) |
| Treesitter | Mentioned but typst.vim primary | Primary syntax highlighting |
| typst-preview.nvim | Included | Included (unchanged) |
| tinymist | NixOS install required | Optional (auto-download) |
| typst.nvim | Not mentioned | Explicitly NOT recommended |

### Key Sources

- [Tinymist Neovim Documentation](https://myriad-dreamin.github.io/tinymist/frontend/neovim.html)
- [typst-preview.nvim GitHub](https://github.com/chomosuke/typst-preview.nvim)
- [LazyVim Typst Extra](http://www.lazyvim.org/extras/lang/typst)
- [Note-taking with Typst and Neovim in 2026](https://www.dogeystamp.com/typst-notes2/)
- [Typst Forum: Tinymist vs typst.vim vs typst-preview.nvim](https://forum.typst.app/t/tinymist-vs-typst-vim-vs-typst-preview-nvim/1775)
- [nvim-treesitter parsers.lua](https://github.com/nvim-treesitter/nvim-treesitter/blob/master/lua/nvim-treesitter/parsers.lua)
- [kaarmu/typst.vim GitHub](https://github.com/kaarmu/typst.vim)
- [SeniorMars/typst.nvim GitHub](https://github.com/SeniorMars/typst.nvim)
