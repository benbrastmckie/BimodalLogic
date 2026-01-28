# Research Report: Task #694

**Task**: 694 - configure_nvim_typst_bindings
**Started**: 2026-01-28T00:30:00Z
**Completed**: 2026-01-28T01:00:00Z
**Effort**: medium
**Priority**: normal
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, Typst documentation, Neovim plugin ecosystem
**Artifacts**: specs/694_configure_nvim_typst_bindings/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- User's LaTeX setup uses VimTeX with Sioyek viewer, LuaSnip with SnipMate-format snippets, nvim-surround with filetype-specific bindings, and texlab LSP
- Typst equivalent requires: tinymist LSP, typst-preview.nvim for live preview, typst.vim for syntax, and typst treesitter parser
- tinymist is NOT currently installed via NixOS - must be added to configuration.nix
- Key binding structure can mirror LaTeX: `<leader>t` for Typst commands (analogous to `<leader>l` for LaTeX)

## Context & Scope

### Research Objective
Analyze the existing LaTeX configuration in ~/.config/nvim to understand the complete workflow (keybindings, plugins, LSP, snippets, surround operations) and identify analogous configurations for Typst .typ files.

### Constraints
- NixOS-based system with packages managed via ~/.dotfiles/
- Mason.nvim used sparingly (only pyright installed via ensure_installed)
- LuaSnip uses SnipMate format from ~/.config/nvim/snippets/
- Lazy.nvim plugin manager
- Neovim 0.11+ (uses native vim.lsp.config API)

## Findings

### Current LaTeX Configuration

#### 1. VimTeX Plugin (`lua/neotex/plugins/text/vimtex.lua`)
```lua
-- Key settings:
vim.g.vimtex_view_method = 'sioyek'           -- PDF viewer
vim.g.vimtex_compiler_method = 'latexmk'       -- Compiler
vim.g.vimtex_compiler_latexmk = {
  build_dir = 'build',
  options = { '-xelatex', '-interaction=nonstopmode', '-synctex=1' },
}
vim.g.vimtex_mappings_enabled = false          -- Custom mappings in ftplugin
```

#### 2. LaTeX Keybindings (`after/ftplugin/tex.lua`)
```lua
-- which-key registered bindings under <leader>l:
<leader>la  -- annotate (PDF annotations extraction)
<leader>lb  -- bib export
<leader>lc  -- compile (VimtexCompile)
<leader>ld  -- draft mode
<leader>le  -- errors (VimtexErrors)
<leader>lf  -- final build
<leader>lg  -- glossary template
<leader>lh  -- format (latexindent)
<leader>li  -- index (VimtexTocOpen)
<leader>lk  -- kill aux (VimtexClean)
<leader>lm  -- menu (vimtex-context-menu)
<leader>lv  -- view (VimtexView)
<leader>lw  -- word count
<leader>lx  -- clear cache
<leader>ls  -- subfile toggle
```

#### 3. LaTeX LSP (`lua/neotex/plugins/lsp/lspconfig.lua`)
```lua
vim.lsp.config("texlab", {
  cmd = { "texlab" },
  filetypes = { "tex", "plaintex", "bib" },
  root_markers = { ".latexmkrc", ".texlabroot", "Tectonic.toml", ".git" },
  settings = {
    texlab = {
      build = { onSave = true },
      chktex = { onEdit = false, onOpenAndSave = false },
      diagnosticsDelay = 300,
    },
  },
})
```

#### 4. LaTeX Snippets (`snippets/tex.snippets`)
- 443 lines of SnipMate-format snippets
- Environment snippets: `begin`, `align`, `enum`, `item`
- Theorem environments: `Tthm`, `Mthm`, `Cthm`, `lemma`, `prop`
- Formatting: `it`, `bf`, `sc`, `tt`
- Math: `mf` (mathfrak), `mc` (mathcal), `ms` (mathscr)
- References: `aref`, `bref`, `eref`, `lab`, `fn`
- Structures: `sec`, `sub`, `ssub`, `hilbert`

#### 5. LaTeX Surround (`after/ftplugin/tex.lua`)
```lua
require("nvim-surround").buffer_setup({
  surrounds = {
    ["e"] = { add = function() ... end },  -- LaTeX environments
    ["Q"] = { add = { "``", "''" } },       -- LaTeX double quotes
    ["q"] = { add = { "`", "'" } },         -- LaTeX single quotes
    ["b"] = { add = { "\\textbf{", "}" } }, -- Bold
    ["i"] = { add = { "\\textit{", "}" } }, -- Italic
    ["t"] = { add = { "\\texttt{", "}" } }, -- Teletype
    ["$"] = { add = { "$", "$" } },         -- Math mode
  },
})
```

#### 6. LaTeX Completion (`lua/neotex/plugins/lsp/blink-cmp.lua`)
- Uses cmp-vimtex for citation/reference completion
- Special source ordering for tex: `lsp`, `snippets`, `omni`, `path`, `buffer`
- Context-aware disabling of sources in \cite{} and \ref{} contexts

#### 7. Treesitter Configuration
- LaTeX/TeX explicitly DISABLED in treesitter (uses VimTeX syntax instead)
- Typst parser NOT in the parsers list (needs to be added)

### Typst Ecosystem Research

#### 1. tinymist Language Server
- **Current status**: NOT installed (verified via `which tinymist`)
- **Installation options**:
  - NixOS: Add to configuration.nix (recommended for this setup)
  - Mason.nvim: `ensure_installed = { "tinymist" }`
  - Cargo: `cargo install tinymist-cli`

- **Key features**:
  - Code completion, diagnostics, go-to-definition, hover
  - Formatting (bundled typstyle or typstfmt)
  - exportPdf on type/save
  - Multi-file project support with main file pinning

#### 2. typst-preview.nvim
- **Purpose**: Live web preview (similar to VimTeX + Sioyek workflow)
- **Plugin**: `chomosuke/typst-preview.nvim`
- **Requirement**: tinymist binary
- **Keybinding suggestion**: `<leader>tp` to toggle preview

#### 3. typst.vim
- **Purpose**: Syntax highlighting and concealment
- **Plugin**: `kaarmu/typst.vim`
- **Note**: Offers treesitter-based highlighting for Neovim

#### 4. tree-sitter-typst
- **Parser**: `uben0/tree-sitter-typst` (bundled with nvim-treesitter)
- **Action needed**: Add `"typst"` to parsers list in treesitter.lua

#### 5. Typst Snippets
- Community-created snippets with context awareness (math/text mode)
- SnipMate format compatible with existing LuaSnip setup
- Key difference from LaTeX: Typst syntax is simpler, fewer snippets needed

### System Package Status

| Tool | Status | Installation Method |
|------|--------|---------------------|
| typst | Installed | NixOS (configuration.nix line 364) |
| tinymist | NOT installed | Add to configuration.nix |
| typstyle | NOT installed | Bundled with tinymist |

## Recommendations

### Phase 1: System Packages (NixOS)

Add to `~/.dotfiles/configuration.nix`:
```nix
# In environment.systemPackages:
tinymist             # Typst language server with bundled formatter
```

### Phase 2: Neovim Plugin Configuration

#### 2.1 Add typst.vim plugin (`lua/neotex/plugins/text/typst.lua`)
```lua
return {
  "kaarmu/typst.vim",
  ft = { "typst" },
  init = function()
    vim.g.typst_pdf_viewer = "sioyek"
    vim.g.typst_conceal_math = 1
    vim.g.typst_auto_open_quickfix = 0
  end,
}
```

#### 2.2 Add typst-preview.nvim (`lua/neotex/plugins/text/typst-preview.lua`)
```lua
return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = {
    dependencies_bin = {
      ["tinymist"] = "tinymist",
    },
  },
}
```

#### 2.3 Update treesitter.lua
Add `"typst"` to the parsers list.

#### 2.4 Update lspconfig.lua
```lua
vim.lsp.config("tinymist", {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { "typst.toml", ".git" },
  settings = {
    formatterMode = "typstyle",
    exportPdf = "onSave",
  },
})
vim.lsp.enable({ "lua_ls", "pyright", "texlab", "tinymist" })
```

#### 2.5 Update formatting.lua
```lua
-- Add to formatters_by_ft:
typst = { "typstyle" },
```

### Phase 3: Filetype Configuration

Create `after/ftplugin/typst.lua`:
```lua
-- Typst-specific surround operations
require("nvim-surround").buffer_setup({
  surrounds = {
    ["b"] = { add = { "*", "*" } },           -- Bold
    ["i"] = { add = { "_", "_" } },           -- Italic
    ["$"] = { add = { "$", "$" } },           -- Math mode
    ["c"] = { add = { "`", "`" } },           -- Code
    ["e"] = {                                  -- Environment/function
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
    { "<leader>tv", function()
      local pdf = vim.fn.expand("%:r") .. ".pdf"
      vim.system({ "sioyek", pdf })
    end, desc = "view PDF", buffer = 0 },
    { "<leader>tw", "<cmd>TypstWatch<CR>", desc = "watch mode", buffer = 0 },
  })
end

-- Enable treesitter for Typst (unlike LaTeX which uses VimTeX syntax)
vim.opt_local.syntax = "off"
pcall(vim.treesitter.start)
```

### Phase 4: Snippets

Create `snippets/typst.snippets`:
```snippets
# Headings
snippet h1 "Heading 1" b
	= ${1:Title}
	${0}

snippet h2 "Heading 2" b
	== ${1:Title}
	${0}

snippet h3 "Heading 3" b
	=== ${1:Title}
	${0}

# Formatting
snippet bf "Bold" wi
	*${1}*${0}

snippet it "Italic" wi
	_${1}_${0}

snippet code "Inline code" wi
	\`${1}\`${0}

# Math
snippet dm "Display math" b
	$ ${1} $
	${0}

snippet im "Inline math" wi
	$${1}$${0}

# Environments
snippet fig "Figure" b
	#figure(
		image("${1:path}"),
		caption: [${2:caption}],
	) <${3:label}>
	${0}

snippet eq "Equation" b
	$ ${1} $ <${2:label}>
	${0}

# Lists
snippet enum "Numbered list" b
	+ ${1:item}
	${0}

snippet item "Bullet list" b
	- ${1:item}
	${0}

# References
snippet ref "Reference" wi
	@${1:label}${0}

snippet cite "Citation" wi
	@${1:key}${0}
```

## Decisions

1. **Keybinding prefix**: Use `<leader>t` for Typst (parallel to `<leader>l` for LaTeX)
2. **Viewer**: Use Sioyek for PDF viewing (same as LaTeX setup)
3. **Preview**: Use typst-preview.nvim for live web preview (Typst's main advantage)
4. **Treesitter**: Enable for Typst (unlike LaTeX which uses VimTeX syntax)
5. **Package management**: Install tinymist via NixOS (consistent with other tools)
6. **Formatter**: Use typstyle (bundled with tinymist, recommended default)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| tinymist not in nixpkgs | Check nixpkgs for package; fallback to Mason or Cargo installation |
| Treesitter parser issues | Parser is well-maintained in nvim-treesitter; fallback to typst.vim syntax |
| typst-preview.nvim compatibility | Use version pinning (`1.*`); plugin actively maintained |
| Snippet overlap with LaTeX | Typst snippets in separate file; context-aware via filetype |

## Appendix

### Search Queries Used
1. `tinymist typst language server neovim 2025 2026`
2. `typst neovim plugin treesitter 2025`
3. `typst snippets luasnip neovim snipmate 2025`

### Key Documentation References
- [Tinymist Neovim Documentation](https://myriad-dreamin.github.io/tinymist/frontend/neovim.html)
- [LazyVim Typst Extra](https://www.lazyvim.org/extras/lang/typst)
- [typst.vim GitHub](https://github.com/kaarmu/typst.vim)
- [Typst Forum: Giles Castel-like Snippets](https://forum.typst.app/t/giles-castel-like-snippets-for-typst-in-neovim/3961)

### Files Analyzed
- `~/.config/nvim/lua/neotex/plugins/text/vimtex.lua`
- `~/.config/nvim/after/ftplugin/tex.lua`
- `~/.config/nvim/lua/neotex/plugins/lsp/lspconfig.lua`
- `~/.config/nvim/lua/neotex/plugins/lsp/blink-cmp.lua`
- `~/.config/nvim/lua/neotex/plugins/editor/treesitter.lua`
- `~/.config/nvim/lua/neotex/plugins/editor/formatting.lua`
- `~/.config/nvim/lua/neotex/plugins/tools/surround.lua`
- `~/.config/nvim/lua/neotex/plugins/tools/luasnip.lua`
- `~/.config/nvim/snippets/tex.snippets`
- `~/.dotfiles/configuration.nix`
