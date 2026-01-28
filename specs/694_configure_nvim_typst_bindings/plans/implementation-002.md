# Implementation Plan: Task #694 (Revised)

- **Task**: 694 - configure_nvim_typst_bindings
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Normal
- **Dependencies**: None
- **Research Inputs**: reports/research-001.md, reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false
- **Revision**: v2 - Changed keybinding prefix from `<leader>t` to `<leader>l` (shared with LaTeX, filetype-isolated)

## Overview

Configure Neovim for Typst editing with a UX that mirrors the existing LaTeX setup. The modern 2026 approach uses tinymist LSP + treesitter (no typst.vim plugin required) + typst-preview.nvim for live preview.

**KEY REVISION**: Keybindings will use the **same** `<leader>l` prefix as LaTeX. Since both are loaded via ftplugin (filetype-specific), they never conflict - LaTeX bindings only load in `.tex` files, Typst bindings only load in `.typ` files. This provides a consistent "document editing" UX where `<leader>l` always means "language/document actions" regardless of whether you're in LaTeX or Typst. The existing `<leader>t` mappings are preserved unchanged.

### Research Integration

- **research-001.md**: Analyzed existing LaTeX configuration including VimTeX, texlab LSP, snippets, nvim-surround bindings, and `<leader>l` keybindings structure
- **research-002.md**: CORRECTION - Modern Typst setup requires only tinymist + treesitter + typst-preview.nvim. typst.vim is NOT recommended for treesitter-enabled Neovim

## Goals & Non-Goals

**Goals**:
- Use `<leader>l` keybindings for Typst (same as LaTeX, filetype-isolated via ftplugin)
- Enable tinymist LSP for completions, diagnostics, formatting, go-to-definition
- Enable live preview via typst-preview.nvim with cross-jump features
- Create Typst snippets in SnipMate format matching LuaSnip setup
- Configure nvim-surround bindings for Typst-specific delimiters
- Add Typst parser to nvim-treesitter

**Non-Goals**:
- Installing typst.vim (conflicts with treesitter, provides redundant functionality)
- Using SeniorMars/typst.nvim (not production-ready)
- Modifying existing `<leader>t` mappings (preserved as-is)
- Modifying LaTeX configuration (purely additive changes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| tinymist not in nixpkgs | Medium | Low | typst-preview.nvim auto-downloads tinymist; fallback to Mason |
| Treesitter parser issues | Low | Low | Parser is well-maintained with 2 active maintainers |
| typst-preview.nvim API changes | Low | Low | Version pinning to 1.* ensures stability |
| Filetype detection issues | Low | Low | Typst filetype detection is built into Neovim 0.10+ |

## Implementation Phases

### Phase 1: NixOS Package Configuration [NOT STARTED]

**Goal**: Add tinymist to system packages for NixOS-managed binary

**Tasks**:
- [ ] Edit `~/.dotfiles/configuration.nix` to add `tinymist` to `environment.systemPackages`
- [ ] Run `sudo nixos-rebuild switch` to apply changes
- [ ] Verify tinymist installation with `which tinymist` and `tinymist --version`

**Timing**: 20 minutes

**Files to modify**:
- `~/.dotfiles/configuration.nix` - Add tinymist package

**Verification**:
- `which tinymist` returns path
- `tinymist --version` shows version info

---

### Phase 2: Treesitter Configuration [NOT STARTED]

**Goal**: Add Typst parser to nvim-treesitter for syntax highlighting

**Tasks**:
- [ ] Locate treesitter configuration file (`~/.config/nvim/lua/neotex/plugins/editor/treesitter.lua`)
- [ ] Add `"typst"` to `ensure_installed` list
- [ ] Verify parser installation with `:TSInstall typst` command

**Timing**: 15 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/plugins/editor/treesitter.lua` - Add "typst" to parsers

**Verification**:
- `:TSInstallInfo` shows typst as installed
- Opening a `.typ` file shows syntax highlighting

---

### Phase 3: LSP Configuration [NOT STARTED]

**Goal**: Configure tinymist LSP with native Neovim 0.11+ API

**Tasks**:
- [ ] Add tinymist configuration to `~/.config/nvim/lua/neotex/plugins/lsp/lspconfig.lua`
- [ ] Configure settings: formatterMode (typstyle), exportPdf (onSave)
- [ ] Add tinymist to `vim.lsp.enable()` call
- [ ] Optionally update `~/.config/nvim/lua/neotex/plugins/editor/formatting.lua` for typst formatting

**Timing**: 25 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/plugins/lsp/lspconfig.lua` - Add tinymist config
- `~/.config/nvim/lua/neotex/plugins/editor/formatting.lua` - Add typst formatter (optional)

**Verification**:
- Open `.typ` file, verify `:LspInfo` shows tinymist attached
- Completions work when typing
- Diagnostics appear for errors

---

### Phase 4: typst-preview.nvim Plugin [NOT STARTED]

**Goal**: Add live preview plugin with cross-jump capabilities

**Tasks**:
- [ ] Create `~/.config/nvim/lua/neotex/plugins/text/typst-preview.lua`
- [ ] Configure plugin to use system tinymist via `dependencies_bin`
- [ ] Use version pinning (`1.*`) for stability

**Timing**: 20 minutes

**Files to modify**:
- `~/.config/nvim/lua/neotex/plugins/text/typst-preview.lua` - New file

**Verification**:
- `:TypstPreview` opens browser preview
- Changes in editor reflect in preview
- `:TypstPreviewToggle` toggles preview

---

### Phase 5: Filetype Configuration and Keybindings [NOT STARTED]

**Goal**: Create ftplugin with `<leader>l` keybindings (matching LaTeX prefix) and nvim-surround configuration

**IMPORTANT**: Using `<leader>l` (same as LaTeX) because:
1. Ftplugin files are filetype-specific - `after/ftplugin/typst.lua` only loads for `.typ` files
2. Provides consistent UX: `<leader>l` = "language/document actions" in both LaTeX and Typst
3. Preserves `<leader>t` mappings which are already in use

**Tasks**:
- [ ] Create `~/.config/nvim/after/ftplugin/typst.lua`
- [ ] Add nvim-surround buffer setup with Typst-specific surrounds:
  - `b` for bold (`*...*`)
  - `i` for italic (`_..._`)
  - `$` for math (`$...$`)
  - `c` for code (`` `...` ``)
  - `e` for functions/environments (`#fn[...]`)
- [ ] Add which-key bindings under `<leader>l` (parallel to LaTeX):
  - `<leader>lc` - compile (typst compile)
  - `<leader>le` - errors (diagnostics float)
  - `<leader>lf` - format (via tinymist/typstyle)
  - `<leader>ll` - view PDF / preview toggle (like VimTeX's `\ll`)
  - `<leader>lp` - preview toggle (typst-preview)
  - `<leader>lP` - pin main file (multi-file projects)
  - `<leader>lv` - view PDF in Sioyek
  - `<leader>ls` - sync/jump to source (from preview)
- [ ] Enable treesitter for syntax highlighting
- [ ] Register which-key group name: `{ "<leader>l", group = "Typst" }` (ftplugin-scoped)

**Timing**: 45 minutes

**Files to modify**:
- `~/.config/nvim/after/ftplugin/typst.lua` - New file

**Verification**:
- Opening `.typ` file shows `<leader>l` bindings in which-key with "Typst" group
- Opening `.tex` file still shows `<leader>l` bindings with "LaTeX" group (unchanged)
- Surround operations work (`ysiw*` for bold)
- `<leader>lp` toggles preview
- `<leader>t` mappings are NOT affected

---

### Phase 6: Snippets Creation [NOT STARTED]

**Goal**: Create SnipMate-format snippets for common Typst patterns

**Tasks**:
- [ ] Create `~/.config/nvim/snippets/typst.snippets`
- [ ] Add heading snippets: `h1`, `h2`, `h3`
- [ ] Add formatting snippets: `bf`, `it`, `code`
- [ ] Add math snippets: `dm` (display math), `im` (inline math)
- [ ] Add environment snippets: `fig`, `eq`, `enum`, `item`
- [ ] Add reference snippets: `ref`, `cite`
- [ ] Add theorem-like environment snippets (paralleling LaTeX theorems)

**Timing**: 35 minutes

**Files to modify**:
- `~/.config/nvim/snippets/typst.snippets` - New file

**Verification**:
- In `.typ` file, typing `h1<Tab>` expands to heading
- Snippet placeholders work correctly
- `:LuaSnipListAvailable` shows typst snippets

---

## Testing & Validation

- [ ] Open `.typ` file and verify syntax highlighting (treesitter)
- [ ] Verify LSP features: completions, diagnostics, hover, go-to-definition
- [ ] Test `<leader>lf` formatting with typstyle
- [ ] Test `<leader>lp` preview toggle
- [ ] Test `<leader>lP` pin main file in multi-file project
- [ ] Test `<leader>lc` compile command
- [ ] Test surround operations: add/change/delete bold, italic, math
- [ ] Test snippets: headings, math, figures, lists
- [ ] **CRITICAL**: Verify `<leader>l` shows "Typst" in `.typ` files
- [ ] **CRITICAL**: Verify `<leader>l` shows "LaTeX" in `.tex` files (unchanged)
- [ ] **CRITICAL**: Verify `<leader>t` mappings are unchanged

## Artifacts & Outputs

- `~/.dotfiles/configuration.nix` (modified) - tinymist package
- `~/.config/nvim/lua/neotex/plugins/editor/treesitter.lua` (modified) - typst parser
- `~/.config/nvim/lua/neotex/plugins/lsp/lspconfig.lua` (modified) - tinymist LSP
- `~/.config/nvim/lua/neotex/plugins/text/typst-preview.lua` (new) - preview plugin
- `~/.config/nvim/after/ftplugin/typst.lua` (new) - keybindings and surround with `<leader>l`
- `~/.config/nvim/snippets/typst.snippets` (new) - Typst snippets

## Rollback/Contingency

If implementation causes issues:

1. **NixOS**: Remove `tinymist` from configuration.nix, rebuild
2. **Treesitter**: Remove "typst" from ensure_installed, run `:TSUninstall typst`
3. **LSP**: Remove tinymist config block, remove from `vim.lsp.enable()` call
4. **Plugin**: Delete `typst-preview.lua`, remove with `:Lazy clean`
5. **Ftplugin**: Delete `after/ftplugin/typst.lua`
6. **Snippets**: Delete `snippets/typst.snippets`

All changes are additive; no existing functionality is modified except adding items to lists.

## Revision Notes (v1 → v2)

**Changed**: Keybinding prefix from `<leader>t` to `<leader>l`

**Rationale**:
- User has existing `<leader>t` mappings they don't want to change
- `<leader>l` is used for LaTeX, and using the same prefix for Typst provides UX consistency
- Ftplugin mechanism ensures no conflicts - bindings only load in their respective filetypes
- This mirrors the "language-agnostic document editing" paradigm where `<leader>l` = "this language's actions"
