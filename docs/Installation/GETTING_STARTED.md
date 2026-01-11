# Getting Started with ProofChecker

[Back to Installation](README.md) | [Basic Installation](BASIC_INSTALLATION.md) | [Using Git](USING_GIT.md)

---

This guide walks you through terminal basics, editor setup, and your first steps with ProofChecker.

## Table of Contents

1. [Using the Terminal](#using-the-terminal)
2. [Setting Up Your Editor](#setting-up-your-editor)
   - [VS Code (Recommended for Beginners)](#vs-code-recommended-for-beginners)
   - [NeoVim (For Advanced Users)](#neovim-for-advanced-users)
3. [Your First Proof](#your-first-proof)
4. [Understanding Project Structure](#understanding-project-structure)
5. [Running Examples](#running-examples)
6. [Next Steps](#next-steps)

---

## Using the Terminal

> Skip this section if you're already comfortable using the terminal/command line.

ProofChecker is built with Lean 4, which uses command-line tools. The terminal lets you navigate directories, run builds, and execute tests.

### What is the Terminal?

The terminal is a text-based interface for controlling your computer. Instead of clicking icons and menus, you type commands to:
- Navigate between folders (directories)
- Run build commands like `lake build`
- Execute tests with `lake test`
- Use Git for version control

### Opening the Terminal

**macOS:**
1. Press `Cmd + Space` to open Spotlight
2. Type "Terminal" and press Enter
3. Or: Navigate to Applications > Utilities > Terminal

**Windows:**
- **PowerShell** (recommended): Press `Windows + X`, then select "PowerShell"
- **Command Prompt**: Press `Windows + R`, type `cmd`, press Enter
- **Windows Terminal** (modern): Search for "Terminal" in the Start menu

**Linux:**
- Press `Ctrl + Alt + T` (works on most distributions)
- Or search for "Terminal" in your application menu

### Basic Terminal Commands

Here are the essential commands you'll need:

**Navigating Directories:**
```bash
pwd               # Print working directory - shows where you are
ls                # List files in current directory (dir on Windows)
cd folder_name    # Change directory - move into a folder
cd ..             # Go up one directory level
cd ~              # Go to your home directory
```

**Common Usage:**
```bash
# See where you are
pwd

# List what's here
ls

# Move into the ProofChecker directory
cd ~/Documents/Projects/ProofChecker

# List project contents
ls
```

**Creating Directories:**
```bash
mkdir my_folder        # Create a new folder
mkdir -p path/to/dir   # Create nested folders
```

### Understanding Paths

A path tells your computer where to find a file or folder:

**Absolute path** - Full address from the root:
```bash
/home/user/Documents/Projects/ProofChecker     # Linux/macOS
C:\Users\User\Documents\Projects\ProofChecker  # Windows
```

**Relative path** - Location relative to where you are now:
```bash
Bimodal/Theorems/Perpetuity.lean    # File inside current directory
../my_project                        # Folder in parent directory
./examples                           # Folder in current directory
```

**Home directory shortcut:**
```bash
~/Documents            # Your home directory + Documents
```

### Tips for Beginners

- **Tab completion**: Start typing a folder name and press Tab - the terminal will complete it
- **Command history**: Use Up/Down arrow keys to cycle through previous commands
- **Copy/Paste**: Usually `Ctrl+Shift+C` / `Ctrl+Shift+V` in Linux/Windows terminals, `Cmd+C` / `Cmd+V` on macOS
- **Clear screen**: Type `clear` (or `cls` on Windows) to clean up your terminal
- **Get help**: Most commands support `--help` flag, e.g., `lake --help`

---

## Setting Up Your Editor

A properly configured text editor is essential for Lean 4 development. It provides:

- **Syntax highlighting** for Lean code
- **Type information** on hover
- **Goal state display** during proof development
- **Error diagnostics** inline
- **Auto-completion** for tactics and lemmas

We recommend two options: **VS Code** for beginners and **NeoVim** for advanced users.

### VS Code (Recommended for Beginners)

VS Code with the lean4 extension provides an excellent Lean development experience with minimal setup.

#### Step 1: Install VS Code

**macOS:**
- Download from [code.visualstudio.com](https://code.visualstudio.com/)
- Or: `brew install --cask visual-studio-code`

**Windows:**
- Download from [code.visualstudio.com](https://code.visualstudio.com/)
- Or: `winget install Microsoft.VisualStudioCode`

**Linux:**
- Download .deb or .rpm from [code.visualstudio.com](https://code.visualstudio.com/)
- Or use your package manager

#### Step 2: Install the lean4 Extension

1. Open VS Code
2. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on macOS) to open Extensions
3. Search for "lean4"
4. Click **Install** on "lean4" by leanprover

#### Step 3: Open ProofChecker

1. In VS Code, go to File > Open Folder
2. Navigate to your ProofChecker directory
3. Click Open

VS Code will automatically detect the Lean project and start the language server.

#### Step 4: Wait for Lake Build

The first time you open the project, Lake will build and download dependencies. You'll see progress in the bottom status bar. This may take several minutes on first open.

#### Step 5: Verify It Works

1. Open any `.lean` file (e.g., `Bimodal/Syntax/Formula.lean`)
2. You should see:
   - Syntax highlighting (colors for keywords, types, etc.)
   - The **Lean Infoview** panel on the right showing goal states
   - Hover over any term to see its type

#### VS Code Tips

- **Ctrl+Shift+Enter** - Check the current file
- **Ctrl+.** - Quick fixes and suggestions
- **Hover** - See type information
- **Infoview panel** - Shows goal state during proofs
- **Problems panel** - Shows all errors and warnings

---

### NeoVim (For Advanced Users)

NeoVim provides a powerful, keyboard-driven Lean development environment. This setup is ideal if you prefer modal editing and terminal-based workflows.

#### Pre-configured Configuration

A complete NeoVim configuration with Lean 4 support is available at:

**[https://github.com/benbrastmckie/.config](https://github.com/benbrastmckie/.config)**

This configuration includes:
- **lean.nvim** plugin for Lean 4 LSP integration
- Goal state display in floating windows
- Keybindings for proof navigation
- Syntax highlighting and diagnostics
- Integration with telescope for file/symbol search

#### Installation

Follow the README at the repository above for complete installation instructions. The general process:

1. Install NeoVim (v0.9+)
2. Clone the config repository
3. Run NeoVim to trigger plugin installation
4. Configure your terminal font for symbols

#### Requirements

- **NeoVim 0.9+** - Required for modern LSP features
- **Terminal comfort** - NeoVim uses vim keybindings
- **Nerd Font** - For icons and symbols (e.g., JetBrainsMono Nerd Font)

#### Quick Reference

If using the benbrastmckie config:

| Action | Keybinding |
|--------|------------|
| Open file explorer | `<leader>e` |
| Go to definition | `gd` |
| Show hover info | `K` |
| Show diagnostics | `<leader>d` |
| Next diagnostic | `]d` |
| Previous diagnostic | `[d` |

See the config repository for the complete keybinding reference.

---

## Your First Proof

Let's explore a simple proof to understand how Lean 4 works with ProofChecker.

### Step 1: Open a Proof File

In your editor, open:
```
Bimodal/Theorems/Perpetuity.lean
```

This file contains proofs of the Perpetuity Principles connecting modal and temporal operators.

### Step 2: Understand the Structure

A typical proof looks like:

```lean
/-- P1: Necessary truths are perpetual (Box phi implies Triangle phi) -/
theorem perpetuity_1 (phi : Formula) : ⊢ φ.box.imp (△φ) := by
  -- Proof tactics go here
  apply derivation_tactic
  ...
```

Key elements:
- **Docstring** (`/-- ... -/`) - Describes what the theorem states
- **Theorem declaration** - `theorem name : type := by`
- **Proof body** - Tactics that construct the proof

### Step 3: See the Goal State

Position your cursor inside a proof (after `by`) and look at:
- **VS Code**: The Infoview panel on the right
- **NeoVim**: Use `K` or your configured keybinding

You'll see the current goal state showing what needs to be proved.

### Step 4: Try Modifying

Try adding `sorry` somewhere in a proof:
```lean
theorem my_theorem : ⊢ some_formula := by
  sorry
```

You'll see a warning that the proof is incomplete. This is how Lean tracks what still needs to be proved.

---

## Understanding Project Structure

ProofChecker is organized into several directories:

```
ProofChecker/
├── Bimodal/                 # Main TM logic implementation
│   ├── Syntax/              # Formula definitions
│   ├── Semantics/           # Task frames and models
│   ├── ProofSystem/         # Axioms and derivation trees
│   ├── Metalogic/           # Soundness and completeness
│   └── Theorems/            # Proven theorems (perpetuity, etc.)
│
├── BimodalTest/             # Tests for Bimodal library
│   ├── Syntax/              # Syntax tests
│   ├── Semantics/           # Semantics tests
│   └── ProofSystem/         # Proof system tests
│
├── Logos/                   # Future extensions (Layers 1-3)
│   └── LaTeX/               # LaTeX documentation
│
├── docs/           # User and developer guides
│   ├── Installation/        # This directory
│   ├── UserGuide/           # Tutorials and examples
│   └── Development/         # Contributor guides
│
└── lakefile.lean            # Build configuration
```

### Key Files

| File | Purpose |
|------|---------|
| `Bimodal/Syntax/Formula.lean` | Formula type definition |
| `Bimodal/ProofSystem/Axiom.lean` | TM logic axioms |
| `Bimodal/ProofSystem/Derivation.lean` | Derivation tree structure |
| `Bimodal/Metalogic/Soundness.lean` | Soundness theorem |
| `lakefile.lean` | Project configuration |

---

## Running Examples

### Build the Project

```bash
cd ~/Documents/Projects/ProofChecker
lake build
```

This compiles all Lean files and checks all proofs.

### Run Tests

```bash
lake test
```

This runs the test suite in BimodalTest/.

### Build Specific Library

```bash
# Build only Bimodal library
lake build Bimodal

# Build only tests
lake build BimodalTest
```

### Check for Errors

If a file has errors, you'll see them in:
- Your editor's diagnostics
- The terminal output from `lake build`

---

## Next Steps

Now that you have your environment set up:

- **[Using Git](USING_GIT.md)** - Learn Git/GitHub for version control and collaboration
- **[Tutorial](../UserGuide/TUTORIAL.md)** - Deep dive into writing proofs
- **[Architecture](../UserGuide/ARCHITECTURE.md)** - Understand TM logic specification
- **[Contributing](../Development/CONTRIBUTING.md)** - How to contribute to ProofChecker

### External Resources

- **[Lean 4 Documentation](https://lean-lang.org/documentation/)** - Official Lean reference
- **[Mathlib4 Documentation](https://leanprover-community.github.io/mathlib4_docs/)** - Mathematical library reference
- **[Lean Zulip Chat](https://leanprover.zulipchat.com/)** - Community support

---

[Back to Installation](README.md) | [Basic Installation](BASIC_INSTALLATION.md) | [Using Git](USING_GIT.md)
