# Using Claude Code with ProofChecker

[Back to Installation](README.md) | [Basic Installation](BASIC_INSTALLATION.md) | [Getting Started](GETTING_STARTED.md)

---

## 1. Getting Started

### What is Claude Code?

Claude Code is Anthropic's official command-line interface for interacting with Claude AI in your terminal. With ProofChecker, it provides:

- **Automated Installation** - Let Claude handle Lean 4 and Mathlib installation
- **Proof Development** - Get intelligent help writing and debugging proofs
- **Project Navigation** - Explore the codebase with AI guidance
- **GitHub Integration** - Manage repositories, issues, and PRs

### Prerequisites

Before installing Claude Code, you'll need the following:

- **Anthropic subscription** - Claude Code requires an active Anthropic account with API access.
  - [Sign up for Anthropic](https://console.anthropic.com/) and set up billing

- **Internet connection** - Required for Claude AI communication and downloading Mathlib.

- **Terminal access** - Claude Code runs in a command-line interface (Terminal on macOS/Linux, PowerShell on Windows).
  - New to the terminal? See [Getting Started: Using the Terminal](GETTING_STARTED.md#using-the-terminal)

- **Text editor** - A properly configured editor with Lean 4 support is essential for proof development.
  - See [Getting Started: Setting Up Your Editor](GETTING_STARTED.md#setting-up-your-editor) for VS Code and NeoVim options

- **Git** - For version control and collaboration.
  - New to Git/GitHub? See [Using Git](USING_GIT.md)

---

## 2. Install Claude Code

### macOS

```bash
# Using Homebrew (recommended)
brew install anthropics/claude/claude-code

# Or using curl
curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code/main/install.sh | sh
```

### Windows

```powershell
# Using winget (Windows 11)
winget install Anthropic.ClaudeCode

# Or using PowerShell (as Administrator)
irm https://raw.githubusercontent.com/anthropics/claude-code/main/install.ps1 | iex
```

### Linux

```bash
# Debian/Ubuntu
curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code/main/install.sh | sh

# Arch Linux
yay -S claude-code

# NixOS
nix-env -iA nixpkgs.claude-code
```

### Verify and Authenticate

```bash
# Verify installation
claude --version

# Authenticate with Anthropic
claude auth login
# Follow the prompts to log in via browser

# Check authentication status
claude auth status
```

---

## 3. Install ProofChecker

Once Claude Code is set up, let it handle the installation:

### Step 1: Create a Workspace

```bash
mkdir -p ~/Documents/Projects
cd ~/Documents/Projects
claude
```

### Step 2: Request Installation

Paste this prompt into Claude Code:

```
Please follow the installation instructions at
https://github.com/benbrastmckie/ProofChecker/blob/master/Documentation/Installation/BASIC_INSTALLATION.md
to install ProofChecker and all dependencies. After installation, verify the build succeeds with `lake build`.
```

Claude will:
1. Install elan (Lean version manager)
2. Clone the ProofChecker repository
3. Run `lake build` to build the project and download Mathlib
4. Verify the build succeeds

**Note**: The first build downloads Mathlib cache, which takes approximately 30 minutes. Claude will wait for this to complete.

### Working with Projects

```bash
cd ~/Documents/Projects/ProofChecker
claude
```

Example prompts:
```
Help me understand the proof of modal_t in Bimodal/Metalogic/SoundnessLemmas.lean
```

```
I want to prove a new theorem about perpetuity. Guide me through the process.
```

```
Explain the structure of the Bimodal/ directory and how the modules relate.
```

For detailed usage, see [Getting Started](GETTING_STARTED.md).

---

## 4. Set Up the Agent System

The ProofChecker repository includes an optional `.claude/` agent system that provides enhanced workflow commands.

### What It Provides

- **Task Management**: `/task`, `/research`, `/plan`, `/implement` cycle
- **Specialized Skills**: Lean 4 development agents with MCP tool integration
- **Context Files**: Domain knowledge for modal/temporal logic and theorem proving
- **State Persistence**: Track progress across sessions

### Installation

The `.claude/` directory is already included in the ProofChecker repository. If you cloned the repo, you already have it.

To verify:
```bash
ls -la .claude/
# Should show CLAUDE.md, rules/, specs/, etc.
```

### After Installation

1. **Restart Claude Code** - Exit and restart for commands to be available
2. **Test the setup**:
   ```
   /task "Test task"
   ```
3. **Learn the commands** - See [.claude/CLAUDE.md](../../.claude/CLAUDE.md)

### Available Commands

| Command | Purpose |
|---------|---------|
| `/task` | Create and manage tasks |
| `/research` | Conduct research on a task |
| `/plan` | Create implementation plan |
| `/implement` | Execute implementation |
| `/todo` | Archive completed tasks |

---

## 5. Using gh CLI for GitHub

GitHub CLI (`gh`) integrates with Claude Code for repository management and issue tracking.

### Install GitHub CLI

Ask Claude Code to install it:

```
Please install the GitHub CLI (gh) for my system and help me authenticate.
```

Or install manually:

```bash
# macOS
brew install gh

# Windows
winget install GitHub.cli

# Linux (Debian/Ubuntu)
sudo apt install gh
```

Then authenticate:

```bash
gh auth login
# Follow prompts to authenticate
```

### Creating Issues

When you encounter problems, report them to the ProofChecker repository:

```bash
cd ~/Documents/Projects/ProofChecker
claude
```

```
Help me create a GitHub issue for the bug I just found.
Include the error message and steps to reproduce.
```

Claude will:
1. Gather relevant information (error messages, environment)
2. Format the issue with proper structure
3. Submit using `gh issue create`

**Manual issue creation:**

```bash
gh issue create --repo benbrastmckie/ProofChecker \
  --title "Brief description" \
  --body "Detailed description with steps to reproduce"
```

### Creating Pull Requests

After making changes:

```
I've added a new theorem. Help me create a pull request with proper documentation.
```

Claude will:
1. Create a feature branch
2. Commit your changes
3. Push to remote
4. Create PR using `gh pr create`

For comprehensive Git/GitHub workflows, see [Using Git](USING_GIT.md).

---

## 6. Tips and Troubleshooting

### Effective Prompts

**Be specific:**
```
Help me prove that necessity implies perpetuity (P1: box phi implies triangle phi)
using the existing axioms in Bimodal/Metalogic/SoundnessLemmas.lean
```

**Reference documentation:**
```
Following the instructions in Documentation/Installation/BASIC_INSTALLATION.md,
install ProofChecker and verify it works.
```

**Use lean-lsp tools:**
```
Use lean_goal to check the proof state at line 150 in Bimodal/Theorems/Perpetuity.lean
```

### Common Issues

**Claude Code won't start:**
```bash
which claude          # Check if in PATH
claude auth status    # Check authentication
```

**Authentication issues:**
```bash
claude auth logout
claude auth login
```

**Build fails or takes too long:**
- First build downloads Mathlib cache (~30 minutes)
- Ensure stable internet connection
- Check available disk space (needs ~5GB for Mathlib)

**Lean version mismatch:**
```bash
# Check installed version
lean --version
lake --version

# Update via elan if needed
elan update
```

**GitHub CLI issues:**
```bash
gh auth logout
gh auth login
gh repo view benbrastmckie/ProofChecker  # Test access
```

---

## 7. Next Steps

- **[Getting Started](GETTING_STARTED.md)** - Terminal basics and editor setup
- **[Using Git](USING_GIT.md)** - Git/GitHub workflows
- **[Basic Installation](BASIC_INSTALLATION.md)** - Manual installation
- **[Tutorial](../UserGuide/TUTORIAL.md)** - Learn to write proofs
- **[Contributing](../Development/CONTRIBUTING.md)** - Contribution guidelines
- **[Agent System Docs](../../.claude/CLAUDE.md)** - Full command reference

### Additional Resources

- **[Claude Code Docs](https://docs.claude.com/claude-code)** - Official documentation
- **[Lean 4 Documentation](https://lean-lang.org/documentation/)** - Lean language reference
- **[Mathlib4 Documentation](https://leanprover-community.github.io/mathlib4_docs/)** - Mathematical library reference
- **[GitHub CLI Manual](https://cli.github.com/manual/)** - Complete gh reference

---

[Back to Installation](README.md) | [Basic Installation](BASIC_INSTALLATION.md) | [Getting Started](GETTING_STARTED.md)
