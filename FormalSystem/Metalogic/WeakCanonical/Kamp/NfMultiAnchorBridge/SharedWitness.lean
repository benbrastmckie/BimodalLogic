/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Slots
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.OrderGate
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Carrier
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Completeness
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.EngineInputs
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Soundness
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.DisjunctionSpikes
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Assembly
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.KitFold
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.FragmentFoldRight

/-! # Shared-Interior-Witness Joint Carrier (O1 + O1b + O2)

The ONE unbuilt object named by the SubBracket2V API banner (`SubBracket2V.lean:25-27`):
the shared-interior-witness conjunction `∃ w, ⋀_σ (per-σ realization at that same w)`,
built as a concrete, model-independent joint carrier `kvE2_sepBody` (Candidate A staged via
Candidate C, per the v7 faithful-separate-bracket design route and its consolidated
faithful-route analysis §2.2).

Every disjunct is a single FLAT bracket (Rabinovich 2014, "A Proof of Kamp's Theorem";
cited by PDF page):

- ONE shared `ptW` slot + per positive interior σ one `charK (nfk_projFresh σ)` E[Σ]-atom
  slot plus σ's per-region interior-positive `charBase χ` slots — quantifier-free /
  E[Σ]-atom point types ONLY (**Lemma 5.1**, PDF p.3: "alpha_j, beta_j are quantifier-free
  formulas over Sigma"); no chain predicate in any point-type position (FM-merge), no
  bracket-in-bracket (no-nesting, `NavigatedSpine.lean:43-48`).
- Disjuncts enumerate the JOINT interleavings of every positive interior σ's slot sequence
  between the fixed endpoints `x`, the shared `w` slot, and `t` (**Lemma 3.2(1)**, PDF p.3:
  "Conjunction of exists-forall formulas is equivalent to a disjunction of exists-forall
  formulas") — realized as permutations of the tagged slot union filtered by the per-σ
  region order (`XU* < x1 < UW*` resp. `WX1* < x1 < X1T*`).
- Refined segment types = conjunction of EVERY interior σ's exclusion content on that
  refined sub-interval (**Cor 5.4**, PDF p.5), keyed per arrangement by the position of
  each σ's fresh-witness slot.
- `epL`/`epR`/`ptW` carry (i) `qnf.1`'s endpoint 1-types, (ii) each interior σ's
  exterior/boundary `charBase` literals (per-σ `epL`/`epR` content, `SubBracket2V.lean:183-192`),
  and (iii) the σ-LEVEL navigation literals for the five non-interior outer placements —
  `Since`/`Until` `charK`-atom literals at the fixed endpoints (**Prop 3.5**, PDF p.3: the
  reconstruction rides the temporal evaluation point; LITMUS: no `x1 < e_i` literal).
- Gate-failure branch `{ disjuncts := [] }` under the depth-2 gate: outer off-fiber falsity,
  outer seven-zone consistency (the joint witness self-zone `zAtW3` included — nine-zone
  lesson one level up, `SubBracket2V.lean:160-166`), inner off-fiber for every positive σ,
  and the inner NINE-zone consistency (verbatim `SubBracket2V.lean:1400-1408` pattern set,
  including both witness self-zones `zAtX1`/`zAtW`) for left-interior positives.

**Recorded scope decision (Phase 7).** Positive subs are classified by their OUTER zone
`nf0_zoneSpec σ.1` (x1 relative to `[w,x,t]`; the enumeration device of the quarantined
`kvE2_body` reused as a *pattern*, never imported). The two interior classes (`zXW3`,
`zWT3`) receive slot groups; the five non-interior classes ride the σ-level endpoint
literals that the landed joint dischargers (`NavigatedSpine.lean:257-383`) serve. The inner
nine-zone gate clause is stated for the LEFT-interior class (the class the landed per-σ kit
`kvE_subBracket2V_correctness_pair` serves); extending it to the mirrored right-interior
class is deferred to the phase that consumes it (Phases 8-10 arbitration).

DO-NOT-EDIT discipline: this module is purely additive; it consumes only public
`SubBracket2V`/`NavigatedSpine`/sibling-Kamp assets and rebuilds nothing landed.

## Module map

This file is a re-export **hub**: it holds no declarations of its own. The 462 declarations
of the joint carrier live in `SharedWitness/`, cut into a strict backward-import tower so
that each module imports only earlier ones (acyclic by construction):

| Module | Contents |
|---|---|
| `Slots` | Zone constants (Def 3.1, PDF pp.2-3), tagged joint slots, `kvE2_sepPos`/`kvE2_sepPosI` |
| `OrderGate` | Bit-compatibility, endpoint/witness literals, gate `kvE2_sepGate`, `kvE2_ordRank` |
| `Carrier` | The joint carrier `kvE2_sepBody` (O1) and its gate discharge |
| `Completeness` | Lemma 3.2(1) ⇐: the honest arrangement selects its disjunct (PDF p.3) |
| `EngineInputs` | Honest bundles, anchor family, engine preconditions (internal only) |
| `Soundness` | O3 joint soundness extraction; segment-form exclusions (Cor 5.4, PDF p.5) |
| `DisjunctionSpikes` | Per-order-type validity; `kvE2_sepProjFresh_eval` |
| `Assembly` | O4 assembly: `kvE2_sepBody_extract`, `kvE2_sepBody_holds_of_honest` |
| `KitFold` | Per-σ kit application; `kvE2_sepFragment_frag`/`_realizable`, `kvE2_outer_fold` |
| `FragmentFoldRight` | R2 right fragment gate; `kvE2_outer_fold_frag` (Prop 4.3, PDF p.6) |

Importing this module re-exports the whole tower, so every existing import site
(`NfMultiAnchorBridge.lean`, `OuterGate.lean`, `ExteriorZoneTriage.lean`,
`ExteriorNegation.lean`, and their transitive consumers) is preserved unchanged. -/
