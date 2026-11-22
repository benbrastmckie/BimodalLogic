/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Automation.ProofMode.RuleRegistry
import FormalSystem.Theorems.ProofMode.ModalBoolean

/-! # Preferred orientations for explicit modal and Boolean simplifier rules -/

register_lrewrite FormalSystem.Theorems.ProofMode.doubleNegationIff
register_lrewrite FormalSystem.Theorems.ProofMode.conjunctionSelfIff
register_lrewrite FormalSystem.Theorems.ModalS5.boxConjIff reverse
register_lrewrite FormalSystem.Theorems.ModalS5.diamondDisjIff reverse
register_lrewrite FormalSystem.Theorems.ModalS5.s5DiamondBox
register_lrewrite FormalSystem.PlusLanguage.ProofMode.doubleNegationIff
register_lrewrite FormalSystem.PlusLanguage.ProofMode.conjunctionSelfIff
register_lrewrite FormalSystem.PlusLanguage.ProofMode.boxConjIff reverse
register_lrewrite FormalSystem.PlusLanguage.ProofMode.diamondDisjIff reverse
register_lrewrite FormalSystem.PlusLanguage.ProofMode.s5DiamondBox
