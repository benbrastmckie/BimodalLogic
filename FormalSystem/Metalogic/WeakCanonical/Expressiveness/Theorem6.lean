/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis

/-!
# Theorem 6: Forward-to-Backward Game Transfer

The GHR93 Theorem 6 forward-to-backward transfer chain
(`ghr93_forward_to_backward_core`, `ghr93_forward_to_backward`,
`ghr93_forward_to_backward_rank_varying`) was archived to
`Boneyard/SorriedDeclExcisions/Ghr93ForwardToBackwardChain.lean`, together with
the case-analysis declarations it rested on (`gap_cut_exists_gt`,
`ghr93_cases_III_IV`, `ghr93_cases_II_III_IV`, `ghr93_inductive_step`): the
whole chain was a dead closure carrying sorried gap-detection cases, with zero
external call sites.

This module is intentionally declaration-free. It is kept (with its import) so
that existing imports of `Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6`
continue to compile unchanged. The live discrete-path analogue is
`ghr93_inductive_step_discrete` in `Metalogic/WeakCanonical/Transfer.lean`.
-/
