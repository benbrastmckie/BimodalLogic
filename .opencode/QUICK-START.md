# .opencode System Quick Start

## 🚀 System Status: FULLY FUNCTIONAL

The .opencode/ system has been successfully overhauled and is now ready for LEAN 4 theorem proving workflows.

## ⚡ Key Improvement

**BEFORE**: Commands failed with "poetry: command not found"  
**AFTER**: All commands execute through robust bash infrastructure

## 🎯 How to Use

### Basic Commands
```bash
# Task management
/task --help                    # Show task options
/task "Create new task"           # Create a new task
/research TASK_NUMBER              # Research a task
/plan TASK_NUMBER                # Create implementation plan
/implement TASK_NUMBER           # Implement a task

# LEAN 4 specific commands
/lean-build --help               # Lake build system
/lean-test --help                # Run LEAN tests  
/lean-proof FILE.lean            # Interactive proof development
/theorem-research "query"          # Search mathematical theorems
/mathlib-search "topic"           # Search Mathlib documentation
```

### Examples

#### Create a LEAN 4 Task
```bash
/task "Prove continuity theorem in Logos layer" --priority high --language lean
```

#### Research with LEAN Tools
```bash
/research 456 "Focus on Mathlib's continuity module"
```

#### Build and Test LEAN 4 Project
```bash
/lean-build --target all          # Build entire project
/lean-test --package core          # Test core modules
```

#### Develop Interactive Proof
```bash
/lean-proof Theories/Logos/Layer1/Continuity.lean
```

## 📁 System Architecture

### Command Execution Flow
```
Command → execute-command.sh → Command Definition → Bash Execution
```

### Agent Delegation
```
Command → Skill → Agent → Return → Command completes
```

### Context Loading
```
Command Type → Context Files → Specialized Knowledge
```

## 🔧 Key Components

### Command Infrastructure
- **execute-command.sh**: Main router for all commands
- **command-execution.sh**: Core execution patterns
- **lean-command-execution.sh**: LEAN 4 specific functions

### LEAN 4 Integration
- **Lake Build System**: Automatic project building
- **Mathlib Search**: LeanSearch and Loogle integration
- **Proof Development**: Interactive LEAN 4 proof editing
- **Verification**: Automated proof checking

### Context Organization
- **LEAN 4 Standards**: Coding conventions and best practices
- **Theorem Library**: Existing proofs and definitions
- **Tool Integration**: Mathlib, LeanSearch, LSP guides

## 🎯 Success Indicators

### Command Execution
- ✅ No more "poetry: command not found" errors
- ✅ All commands route correctly to bash scripts
- ✅ Comprehensive error handling

### LEAN 4 Workflows  
- ✅ Lake build system integration
- ✅ Mathlib search functionality
- ✅ Interactive proof development
- ✅ Automated proof verification

### System Integration
- ✅ All components work together seamlessly
- ✅ Agent delegation chains functional
- ✅ Task state management synchronized

## 📚 Documentation

- **Full Guide**: `.opencode/README.md`
- **Architecture**: `.opencode/ARCHITECTURE.md`
- **Command Reference**: `.opencode/command/README.md`
- **Context Index**: `.opencode/context/index.md`

## 🚀 Ready for Production

The .opencode/ system is now production-ready for LEAN 4 theorem proving and formal verification workflows.

**First Commands to Try**:
1. `/task --help` - Explore task management
2. `/lean-build --help` - Test LEAN integration
3. `/research 673 --help` - Test research workflows

All commands now execute successfully through the new bash infrastructure, providing a robust foundation for LEAN 4 development and theorem proving.