import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Lemma32Reduction
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierKv

/-!
# Reduction-navigated arity-3 endpoint primitive `endChar` (task 349, v4)

This module builds the recursive navigated arity-3 endpoint primitive `endChar` and its
correctness theorem `endChar_correct` by **consuming** task 351's `nfEval_le2_reduction`
(the Rabinovich Lemma 3.2(2) ≤2/≤3-free-variable reduction) so the recursion NEVER climbs
past anchor arity 3. It is additive: it edits NEITHER `Base.lean` NOR `Lemma32Reduction.lean`
(nor any frozen provider file), depending on their green declarations by import only.

## Phase 1 (this file, initial scaffold): reduction entry at arity 3

Phase 1 establishes the arity-3 specialization of the imported reduction and pins the
ACHIEVABLE correctness target. Later phases add the depth-0 navigated base
(`endCharNav0_correct`, Phase 2), the load-bearing inner-realizability navigator
(`navPieceForm`/`_correct`, Phase 3), the recursion `endChar` and `endChar_correct`
(Phase 4), and the consumer gate (Phase 5).

## The ACHIEVABLE `endChar_correct` target (conditional / navigable — pinned here)

The v3 UNCONDITIONAL world-local shape

```
(endChar k qnf).eval_at M atomMap y ↔ nf_eval_nf M k 3 (zoneEnv3 y x t) qnf   -- for ARBITRARY x t
```

is **UNPROVABLE**. The refutation is machine-checked and green in `Base.lean`:
`endChar0_correct`'s own docstring counterexample (Base.lean:1036-1047) and
`endCharN0_correct_infeasible` (Base.lean:1779) exhibit a concrete `Bool` model in which a
single-world `TemporalPred`, read only at the navigated witness `y`, cannot certify the
predicate/order layer at the free anchors `x`, `t` (world-locality of `TemporalPred.eval_at`).
Re-freezing this unconditional shape is therefore FORBIDDEN (plan v4 Postmortem Constraint 1).

The ACHIEVABLE target — the one the green arity-3 machinery already realizes — is the
**conditional / navigable** form, where the two enclosing anchors `{x, t}` are reached/pinned
by navigation (exactly as the green `endChar0_correct` carries its anchor residual `h_res`, and
`nf_char3_endpoint_tl_correct` carries `h_atom`):

```
-- target shape (frozen for Phases 2-4):
(endChar k qnf).eval_at M atomMap y ↔ nf_eval_nf M k 3 (zoneEnv3 y x t) qnf
   -- UNDER the enclosing-anchor coupling for {x, t}, discharged by navigation (arity ceiling 3)
```

The anchor coupling is discharged by the task-351 reduction + arity-3 navigation, NEVER by a
free-standing `NavResidual`. Cross-references:
* atom-hook coupling shape: `nf_char3_endpoint_tl_correct`'s `h_atom` (Base.lean:885).
* base-case anchor residual: `endChar0_correct`'s `h_res` (Base.lean:1056).
* forbidden unconditional form: `endCharN0_correct_infeasible` (Base.lean:1779),
  counterexample narrative at Base.lean:1036-1047.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-- **Arity-3 specialization of the task-351 reduction** (Rabinovich Lemma 3.2(2), md:119).
For every depth `k`, environment `env : Fin 3 → M.carrier`, and normal form
`qnf : NormalForm sig k 3`, the arity-3 evaluation `nf_eval_nf M k 3 env qnf` is equivalent to
the reduced conjunction `nfEvalRHS M k 3 env qnf` of ≤2-anchor `nf_eval_nf` atom facts plus the
depth-recursive quant-layer realizability clauses.

This is a plain instantiation of the imported, `∀ (k n env qnf)`-quantified
`nfEval_le2_reduction` (Lemma32Reduction.lean:535) at `n = 3` — it re-derives NOTHING; it only
fixes the arity ceiling at 3 for the navigated recursion. Every emitted `nf_eval_nf` conjunct on
the RHS has anchor arity 2 (see `nfEval3_reduction_zero_shape` / `nfEval3_reduction_succ_shape`
below), so navigation over this reduction never climbs past anchor arity 3 (the SETTLED ≤3
ceiling; the single realizability witness `w` is threaded OUTSIDE the reduced inner form —
order-theoretic merge, no per-pair distribution). -/
theorem nfEval3_reduction {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (k : Nat) (env : Fin 3 → M.carrier) (qnf : NormalForm sig k 3) :
    nf_eval_nf M k 3 env qnf ↔ nfEvalRHS M k 3 env qnf :=
  nfEval_le2_reduction M k 3 env qnf

/-- **Arity confirmation, depth 0.** At `k = 0`, the reduced RHS of `nfEval3_reduction` is
exactly a conjunction (over anchor pairs `i j : Fin 3`) of arity-**2** `nf_eval_nf` atom facts
`nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf i j)` — no arity climb past 2 among the
emitted `nf_eval_nf` facts. Direct from the imported `nfEvalRHS_zero`. -/
theorem nfEval3_reduction_zero_shape {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (env : Fin 3 → M.carrier) (qnf : NormalForm sig 0 3) :
    nfEvalRHS M 0 3 env qnf
      = ∀ (i j : Fin 3), nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf i j) :=
  nfEvalRHS_zero M env qnf

/-- **Arity confirmation, depth `k+1`.** At `k+1`, the reduced RHS of `nfEval3_reduction`
splits into (a) arity-**2** `nf_eval_nf` atom facts over anchor pairs, and (b) the
depth-recursive realizability clauses `∃ w, nfEvalRHS M k 4 (Fin.cons w env) sub ↔ …` in which
the witness `w` stays OUTSIDE the reduced inner form (order-theoretic `∃w ∀ij` merge — never a
per-pair `∀ij ∃w` distribution). No emitted `nf_eval_nf` atom fact climbs past anchor arity 2.
Direct from the imported `nfEvalRHS_succ`. -/
theorem nfEval3_reduction_succ_shape {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    {k : Nat} (env : Fin 3 → M.carrier) (qnf : NormalForm sig (k + 1) 3) :
    nfEvalRHS M (k + 1) 3 env qnf
      = ((∀ (i j : Fin 3),
            nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf.1 i j)) ∧
          (∀ sub : NormalForm sig k 4,
            (∃ w : M.carrier, nfEvalRHS M k 4 (Fin.cons w env) sub) ↔ (qnf.2 sub = true))) :=
  nfEvalRHS_succ M env qnf

/-! ## Phase 2 (task 349): depth-0 navigated base `endCharNav0_correct` (arity-3, conditional)

The `k = 0` base of the recursion, in the **reduction-consuming, conditional/navigable** shape
(NEVER the refuted unconditional world-local form — `endCharN0_correct_infeasible`, Base.lean:1779).
It connects the green base `endChar0_correct` (Base.lean:1056, which carries the enclosing-anchor
residual `h_res`) to the reduced `nfEvalRHS M 0 3` shape by composing with the arity-3 reduction
`nfEval3_reduction` at `k = 0`. This is the exact form Phase 4's `k`-induction base consumes.

Under the enclosing-anchor coupling `h_res` (the `{x, t}` predicate/order residual, pinned by the
bracket witnesses — G4, anchors `{x, t} ⊆ {x, t}`, ≤2, `y` a bracket witness never a third free
anchor), the navigated base's `.eval_at y` is equivalent to the `≤2`-anchor reduced RHS. Every
emitted `nf_eval_nf` atom fact on that RHS has anchor arity exactly 2
(`nfEval3_reduction_zero_shape`), so the base never climbs past anchor arity 3. -/
theorem endCharNav0_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 0 3) (y x t : M.carrier)
    (h_res : ∀ atom : AtomKind sig 3, (∀ p : sig.preds, atom ≠ AtomKind.pred p 0) →
      (atom_eval M (zoneEnv3 y x t) atom ↔ (qnf atom = true))) :
    (endChar0 atomMap h_surj qnf).eval_at M atomMap y ↔
      nfEvalRHS M 0 3 (zoneEnv3 y x t) qnf :=
  (endChar0_correct M atomMap h_surj qnf y x t h_res).trans
    (nfEval3_reduction M 0 (zoneEnv3 y x t) qnf)

/-- **Arity-2 manifest form of `endCharNav0_correct`.** Rewriting the reduced RHS through the
depth-0 shape `nfEval3_reduction_zero_shape` exposes the base as a conjunction, over anchor pairs
`(i, j) : Fin 3`, of honest **arity-2** `nf_eval_nf` atom facts on the anchor+witness environment
`envPair M (zoneEnv3 y x t) i j`. Confirms every atom piece is arity ≤2 (no arity climb) while
still carrying the enclosing-anchor coupling `h_res`. -/
theorem endCharNav0_correct_pairwise {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 0 3) (y x t : M.carrier)
    (h_res : ∀ atom : AtomKind sig 3, (∀ p : sig.preds, atom ≠ AtomKind.pred p 0) →
      (atom_eval M (zoneEnv3 y x t) atom ↔ (qnf atom = true))) :
    (endChar0 atomMap h_surj qnf).eval_at M atomMap y ↔
      ∀ (i j : Fin 3),
        nf_eval_nf M 0 2 (envPair M (zoneEnv3 y x t) i j) (nfRestrict0 qnf i j) := by
  rw [endCharNav0_correct M atomMap h_surj qnf y x t h_res,
      nfEval3_reduction_zero_shape M (zoneEnv3 y x t) qnf]

/-! ## Phase 3 (task 349): arity-3 inner-realizability navigator `navPieceForm` / `_correct`
(the load-bearing core)

`navPieceForm` is the closed-`Formula` converter that discharges the depth-`(k+1)`
inner-realizability obligation `h_inner` of `nf_char3_endpoint_tl_correct` (Base.lean:885): for
each arity-4 `sub`, its `temporal_truth` at the navigated point `y` characterizes the coupled
inner existential `∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub`.

### Design (SETTLED — plan v4 Phase 3)

The arity-4 inner `nf_eval_nf` is reduced to arity-`≤3` pieces by task 351's
`nfEval_le2_reduction` (`nfEval3_reduction`, the Rabinovich Lemma 3.2(2) reduction) **under a
single shared witness** — the witness `w` stays OUTSIDE the reduced inner form (order-theoretic
`∃w ∀ij` merge, never a per-pair `∀ij ∃w` distribution). Each resulting arity-3 realizability
piece is NAVIGATED over its enclosing anchor pair by the green two-anchor navigation form
`nf_zone_flatten_navigable` (Base.lean:667) via the arity-3 bridges `nfEval_pair_arity3_flatten`
(Lemma32Reduction.lean:318) and `nfEval_pair_arity3_interior` (:344), with BOTH endpoint hooks
`pastEnd`/`futureEnd` instantiated to the parametric depth-`(k-1)` arity-3 IH `rec`. Navigation
NEVER climbs past anchor arity 3.

`navPieceForm rec sub` is assembled as the disjunction of the two navigated `bracketBuild*`
chains (`bracketBuildLeft` walking into the past exterior, `bracketBuildRight` into the future
exterior) whose interior is the genuine non-trivial β-segment `seg rec q3` (G3 — never
`TemporalPred.top`) and whose exterior endpoints are `rec q3`, where `q3 := nfk_take (3 ≤ 4) sub`
is the arity-3 prefix restriction of the arity-4 `sub` (CarrierKv.lean:70). Every deeper witness
is a bracket witness, never a free anchor; the free-anchor set stays `{x, t}` (G2/G4), arity
capped at 3.

### Route audit
- **G1** — no arity-1 collapse: `q3` is arity 3, every navigated `nf_eval_nf` residual is arity 3.
- **G2/G4** — `w` and every bracket witness ride `Until`/`Since` brackets, never a third free
  anchor; anchors `{x, t} ⊆ {x, t}`, `≤ 2`.
- **G3** — the interior slot is the non-trivial `seg rec q3`, never `TemporalPred.top`.
- **G5** — the correctness is assembled by manual `exists_congr`/`or_congr`/`and_congr_right`
  bridges over the reduction and the two navigated-reach pillars; no `simp`/`omega`/`aesop`
  shortcut of a Rabinovich chain step.
- **FORBIDDEN** — no `nf_char3_deeper_split` (would grow the anchor set to 4); no per-pair
  `∀ij ∃w` distribution; no arity-collapsing quant `nfRestrict`; no free-standing `NavResidual`. -/

/-- **Arity-3 inner-realizability navigator** (task 349 Phase 3, load-bearing core). The closed
`Formula` whose `temporal_truth` at a navigated point captures the arity-4 inner realizability
`∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub`, by NAVIGATING the arity-3 pieces of the
task-351 reduction over the enclosing anchor pair. Parametric in the depth-`(k-1)` arity-3 IH hook
`rec : NormalForm sig k 3 → TemporalPred` (used for BOTH exterior endpoints). Assembled as the
disjunction of the past-exterior `bracketBuildLeft` and future-exterior `bracketBuildRight`
navigated chains, each carrying the non-trivial β-segment `seg rec q3` as its interior (G3) and
`rec q3` as its exterior endpoint, where `q3 = nfk_take (3 ≤ 4) sub` is the arity-3 prefix
restriction of `sub`. Arity capped at 3 (G1/G4); witnesses are bracket witnesses (G2). -/
noncomputable def navPieceForm {sig : MonadicSignature} {k : Nat}
    (rec : NormalForm sig k 3 → TemporalPred)
    (sub : NormalForm sig k 4) : Formula :=
  let q3 : NormalForm sig k 3 := nfk_take (by omega : 3 ≤ 4) sub
  Formula.or
    (bracketBuildLeft (seg rec q3) (rec q3))
    (bracketBuildRight (seg rec q3) (rec q3))

/-- **Phase 3 reduction step (SETTLED "witness-stays-OUTSIDE" merge, GREEN).** The arity-4 inner
realizability obligation of `nf_char3_endpoint_tl_correct`'s `h_inner` — `∃ w, nf_eval_nf M k 4
(Fin.cons w (zoneEnv3 y x t)) sub` — is reduced, **under the single shared witness `w`** (via
`exists_congr`, so `w` stays OUTSIDE the reduced inner form — the order-theoretic `∃w ∀ij` merge,
never a per-pair `∀ij ∃w` distribution), to `∃ w, nfEvalRHS M k 4 (Fin.cons w (zoneEnv3 y x t)) sub`
by consuming task 351's `nfEval_le2_reduction` (Rabinovich Lemma 3.2(2), Lemma32Reduction.lean:535)
at arity 4. This is the FIRST, load-bearing step of `navPieceForm_correct`: the reduced RHS
`nfEvalRHS M k 4 [w, y, x, t] sub` is a conjunction of anchor-arity-2 `nf_eval_nf` atom facts over
pairs `(i, j) : Fin 4` plus (at `k+1`) the depth-recursive quant clauses (`nfEval3_reduction_zero_shape`
/ `nfEval3_reduction_succ_shape` one arity up), so navigation over it never climbs past anchor
arity 3. sorry-free. -/
theorem navPiece_reduce {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig)
    (y x t : M.carrier) (sub : NormalForm sig k 4) :
    (∃ w : M.carrier, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) ↔
      (∃ w : M.carrier, nfEvalRHS M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) :=
  exists_congr (fun w => nfEval_le2_reduction M k 4 (Fin.cons w (zoneEnv3 y x t)) sub)

/-! ### Phase 3b (correctness `navPieceForm_correct`) — DEFERRED, contingency-triggered

The correctness biconditional `temporal_truth M atomMap y (navPieceForm rec sub) ↔
∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub` is NOT landed in this dispatch. The
`lean_goal`-verified reduced target (via `navPiece_reduce`) is

```
⊢ (∃ w, nfEvalRHS M k 4 (Fin.cons w (zoneEnv3 y x t)) sub)  ↔  temporal_truth M atomMap y (navPieceForm rec sub)
```

whose LHS atom layer ranges over ALL pairs `(i, j) : Fin 4` — i.e. the FOUR anchors `{w, y, x, t}`
of the env `Fin.cons w (zoneEnv3 y x t)` — plus, at `k+1`, an arity-5 quant layer. Navigating this
full Fin-4 pairwise/quant structure into a single closed `Formula` read at `y` requires an
**arity-4-enclosing-pair navigation bridge** (a disjunction over the possible enclosing pairs
threading the single witness `w` through the linear order), which is NOT among the green consumed
assets (`nfEval_pair_arity3_flatten`/`_interior` navigate a FIXED arity-3 pair only, and the
single-pair arity-4→3 bi-implication is machine-checked a NON-THEOREM — Lemma32Reduction.lean:290-306).
Per the plan v4 Phase-3 Contingency Trigger, this is recorded for a dedicated follow-up (`/spawn 349`
for the missing arity-4-enclosing-pair navigation bridge) rather than closed by a collapse, a
single-anchor reshape, a per-pair `∀ij ∃w` distribution, or a mis-stated/vacuous theorem. The
`navPieceForm` def (above) and `navPiece_reduce` (the SETTLED witness-outside reduction step) are the
landed, green, sorry-free 3a deliverables; the def structure is expected to be enriched alongside the
new bridge. -/

/-! ## Phase 1 (task 349, v5): residual-conditioned spec freeze + `endChar` skeleton + base case

**Faithful v5 architecture (report 05 §3).** This section supersedes the v4 Phase-3 interface (the
refuted inner-`Formula` `nf_char3_endpoint_tl` / `navPieceForm_correct` converter — a machine-checked
NON-THEOREM by parameter independence, report 04 — DELETED from the critical path). The v5 recursion
reduces the arity-4 inner existential to a ≤2-anchor conjunction FIRST (consuming the green
`navPiece_reduce` / `nfEval_le2_reduction`), characterizes each conjunct with the Prop-valued,
x,t-EXPLICIT `nf_zone_flatten_navigable_correct` (Base.lean:687), rides the bounded interior on the
non-trivial `seg` (G3), and collapses to a closed `Formula` ONLY at the base `endChar0` (Step D).

### FROZEN spec — `endChar_correct` (report 05 §3.2; residual-conditioned, x,t-EXPLICIT)

Stated at EVERY depth `k` carrying the anchor-residual `h_res` (generalizing the green base
`endChar0_correct`, Base.lean:1056). Pinned here; CLOSED in Phase 4 by induction on `k` (base =
`endChar_correct_zero` below; step = the Phase-3 `endCharStep` k+1 discharge):

```
theorem endChar_correct {sig} (M) (atomMap)
    (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p) :
    ∀ (k : Nat) (qnf : NormalForm sig k 3) (w x t : M.carrier)
      (h_res : ∀ atom : AtomKind sig 3, (∀ p, atom ≠ AtomKind.pred p 0) →
        (atom_eval M (zoneEnv3 w x t) atom ↔ (qnf atom = true))),
    (endChar atomMap h_surj k qnf).eval_at M atomMap w ↔
      nf_eval_nf M k 3 (zoneEnv3 w x t) qnf
```

**FORBIDDEN — the unconditional world-local form** (`endCharN0_correct_infeasible`, Base.lean:1779):
`(endChar k qnf).eval_at M atomMap y ↔ nf_eval_nf M k 3 (zoneEnv3 y x t) qnf` for ARBITRARY,
x,t-IMPLICIT anchors is a machine-checked NON-THEOREM (counterexample narrative Base.lean:1036-1047):
a closed navigated-`w` `TemporalPred`, read only at `w`, cannot certify the predicate/order layer at
the free anchors. The discriminator (report 05 §5.2) is the pair: (i) `h_res` — supplying the
anchor predicate/order residual the world-local read cannot see — and (ii) `x, t` appearing
EXPLICITLY as parameters so `h_res` pins `{x, t}` (≤2 anchors, G2/G4; `w` a bracket witness, never a
third free anchor). Re-freezing the unconditional/x,t-implicit shape is FORBIDDEN.

### Skeleton (report 05 §3.3)

```
endChar 0     qnf = endChar0 atomMap h_surj qnf                     -- closed-Formula collapse only at base
endChar (k+1) qnf = endCharStep atomMap h_surj (endChar k) qnf      -- Phase-2/3 navigated builder (hole)
```
-/

/-- **`endCharStep` — recursion step builder (Phase-1 SCAFFOLD; real body lands in Phase 3).** The
depth-`(k+1)` navigated endpoint builder consuming the depth-`k` interior/exterior hook
`rec : EndCharCarrier sig k`. Its FINAL body (Phase 3, report 05 §3.4 Steps B–D) reduces the arity-4
inner existential to ≤2-anchor conjuncts (`navPiece_reduce`), characterizes each via the x,t-EXPLICIT
`nf_zone_flatten_navigable_correct`, rides the interior on `seg` (G3), and collapses to a closed
`Formula` only at the base. This Phase-1 body is a genuine `TemporalPred`-valued SCAFFOLD — the
position-0 atom layer `endChar0 … qnf.1` — installed ONLY so the `endChar` recursion and the
`endChar_correct` STATEMENT elaborate. It is NOT the final navigated builder and carries NO proof
obligation (no `endChar_correct` step case is claimed here — that is the Phase-3 feasibility gate).
Replaced fix-forward in Phase 3 (`_rec` → `rec`). -/
noncomputable def endCharStep {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat} (_rec : EndCharCarrier sig k) : EndCharCarrier sig (k + 1) :=
  fun qnf => endChar0 atomMap h_surj qnf.1

/-- **The recursive navigated arity-3 endpoint primitive `endChar` (skeleton, report 05 §3.3).** Base
`endChar 0 = endChar0` (the closed-`Formula` Prop-3.5 collapse, ≤1 free); step
`endChar (k+1) = endCharStep (endChar k)` (the Phase-2/3 navigated builder). Arity fixed at 3 (G1: no
arity-1 collapse; closed-`Formula` read occurs only at the base). The step body is the Phase-1
scaffold until Phase 3 installs the real navigated builder; the recursion structure is frozen here so
Phases 2–4 dispatch against a stable definition. -/
noncomputable def endChar {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) → EndCharCarrier sig k
  | 0 => endChar0 atomMap h_surj
  | (k + 1) => endCharStep atomMap h_surj (endChar atomMap h_surj k)

/-- **Base case (`k = 0`) of the frozen `endChar_correct` (report 05 §3.2), sorry-free.** Under the
anchor-residual `h_res`, the navigated base `endChar … 0 qnf` (which unfolds definitionally to
`endChar0 … qnf` by the `Nat`-recursion zero branch) read at `w` is equivalent to the FULL depth-0
arity-3 atom layer `nf_eval_nf M 0 3 (zoneEnv3 w x t) qnf`. This is DEFINITIONALLY the green
`endChar0_correct` (Base.lean:1056). It is the base building block Phase 4 feeds to the induction on
`k`; `x, t` are EXPLICIT and `h_res` pins the `{x, t}` residual (≤2 anchors, G2/G4; `w` a bracket
witness), NEVER the refuted unconditional world-local form. -/
theorem endChar_correct_zero {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 0 3) (w x t : M.carrier)
    (h_res : ∀ atom : AtomKind sig 3, (∀ p : sig.preds, atom ≠ AtomKind.pred p 0) →
      (atom_eval M (zoneEnv3 w x t) atom ↔ (qnf atom = true))) :
    (endChar atomMap h_surj 0 qnf).eval_at M atomMap w ↔
      nf_eval_nf M 0 3 (zoneEnv3 w x t) qnf :=
  endChar0_correct M atomMap h_surj qnf w x t h_res

end Bimodal.Metalogic.WeakCanonical.Kamp
