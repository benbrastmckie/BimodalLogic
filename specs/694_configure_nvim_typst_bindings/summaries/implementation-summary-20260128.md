# Implementation Summary: Task #694

**Completed**: 2026-01-28
**Duration**: ~25 minutes

## Changes Made

Configured Neovim for Typst editing with a UX that mirrors the existing LaTeX setup. The implementation uses tinymist LSP + treesitter + typst-preview.nvim, with `<leader>l` keybindings that are filetype-isolated (same prefix as LaTeX, but only active in `.typ` files).

## Files Modified

- `~/.config/nvim/lua/neotex/plugins/editor/treesitter.lua` - Added "typst" to the parsers list for syntax highlighting
- `~/.config/nvim/lua/neotex/plugins/lsp/lspconfig.lua` - Added tinymist LSP configuration with typstyle formatting and PDF export on save

## Files Created

- `~/.config/nvim/lua/neotex/plugins/text/typst-preview.lua` - typst-preview.nvim plugin configuration for live preview with cross-jump support
- `~/.config/nvim/after/ftplugin/typst.lua` - Filetype plugin with:
  - `<leader>l` keybindings (parallel to LaTeX): compile, preview, format, view PDF, diagnostics
  - nvim-surround buffer setup for Typst-specific surrounds (bold, italic, math, code, functions)
  - Spelling and formatting options
- `~/.config/nvim/snippets/typst.snippets` - SnipMate-format snippets (~60 snippets) including:
  - Headings (h1-h4)
  - Formatting (bold, italic, code, etc.)
  - Math (display, inline, fractions, sums, integrals)
  - Lists (enumerated, bullet, term)
  - Figures and images
  - Theorem-like environments (theorem, lemma, proposition, definition, proof)
  - Tables, code blocks, references
  - Document templates (article, note)

## Verification

- Phase 1: tinymist already installed via NixOS (`/run/current-system/sw/bin/tinymist`)
- Phase 2: Treesitter parser added to auto-install list
- Phase 3: LSP configured with Neovim 0.11+ native API
- Phase 4: typst-preview.nvim plugin created with system tinymist
- Phase 5: ftplugin with keybindings and nvim-surround setup
- Phase 6: Comprehensive snippets file created

## Keybinding Summary

| Binding | Action |
|---------|--------|
| `<leader>lc` | Compile document |
| `<leader>le` | Show diagnostics |
| `<leader>lf` | Format document |
| `<leader>ll` | Toggle live preview |
| `<leader>lp` | Start preview |
| `<leader>lP` | Toggle cursor follow |
| `<leader>ls` | Sync cursor to preview |
| `<leader>lv` | View PDF in Sioyek |
| `<leader>lw` | Watch mode (continuous compile) |
| `<leader>lx` | Stop preview |

## nvim-surround Keybindings

| Key | Surround Type |
|-----|---------------|
| `b` | Bold (`*...*`) |
| `i` | Italic (`_..._`) |
| `$` | Inline math (`$...$`) |
| `c` | Code (`` `...` ``) |
| `e` | Function (`#fn[...]`) |
| `m` | Display math (`$ ... $`) |
| `r` | Raw block (```...```) |

## Notes

- The `<leader>l` prefix is shared with LaTeX intentionally for consistent "document editing" UX
- Filetype isolation via ftplugin ensures no conflicts between LaTeX and Typst bindings
- Restart Neovim and run `:Lazy sync` to install typst-preview.nvim
- Run `:TSInstall typst` if the parser doesn't auto-install
