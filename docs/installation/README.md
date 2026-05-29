# Installation Documentation

[Back to Documentation](../README.md)

---

## Overview

This directory contains installation guides for ProofChecker, a Lean 4 formalization of bimodal logic combining S5 modal operators with linear temporal operators.

## Guides

| Guide | Description |
|-------|-------------|
| [BASIC_INSTALLATION.md](BASIC_INSTALLATION.md) | Manual installation (elan, Lean 4, Mathlib) |

## Quick Start

```bash
# Install elan (Lean version manager)
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh

# Clone repository
git clone https://github.com/benbrastmckie/BimodalLogic.git
cd BimodalLogic

# Build project (first build downloads Mathlib cache, ~30 minutes)
lake build
```

## Requirements

| Component | Version | Purpose |
|-----------|---------|---------|
| Lean 4 | v4.27.0-rc1 | Theorem prover |
| Lake | (included) | Build system |
| Mathlib | v4.27.0-rc1 | Mathematical library |

---

[Back to Documentation](../README.md)
