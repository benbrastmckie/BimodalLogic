import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base
import FormalSystem.Boneyard.Kamp.KampWeakCanonical.NfMultiAnchorBridgeRetired.Lemma32Reduction
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierKv
import FormalSystem.Boneyard.Kamp.KampWeakCanonical.DocumentedSingles.NavigatedEndCharSinglePoint

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Reduction-navigated arity-3 endpoint reduction family (v6)

**v6 ARCHIVAL SWAP (plan `06_faithful-two-endpoint-carrier.md`, Phase 1).** The refuted single-point
`EndCharCarrier → TemporalPred` scaffold (`navPieceForm`, `endCharStep`, `endChar`,
`endChar_correct_zero`, and the `endChar_correct` / `endChar_correct_step` / `navPieceForm_correct`
non-theorem narrative) has been MOVED to `Kamp/Boneyard/NavigatedEndCharSinglePoint.lean` — proven
UNFAITHFUL (a machine-checked non-theorem, 4th strike) by reports 04 / 06 / 07. The faithful carrier
is the `x,t`-EXPLICIT two-endpoint `BracketEndCharCarrierV := NormalForm sig k 3 → VVecEA2`
(CarrierK1V.lean:365), green at k=0 and k=1, and is rebuilt in `CarrierK1V.lean` (Phases 2-6). The
Boneyard file is imported here only to keep the archived scaffold compiled (it does not rot);
nothing on the critical path depends on it.

## What this file now retains — the GREEN Step-A reduction family (code-independent of the archive)

The `nfEval_le2_reduction`-consuming arity-3/arity-4 reduction lemmas that the faithful
carrier's Step-A "reduce FIRST" step reuses, all sorry-free at axioms
`[propext, Classical.choice, Quot.sound]`:
`nfEval3_reduction` (+`_zero_shape`/`_succ_shape`), `endCharNav0_correct` (+`_pairwise`),
`navPiece_reduce`, `nfEval4_reduction` (+`_zero_shape`/`_succ_shape`), `endCharStep_reduceA`,
`endCharStep_quant_reduceA`. These reference NONE of the archived defs in code (docstring mentions of
the retired `endCharStep`/`navPieceForm` are historical only).

It remains additive: it edits NEITHER `Base.lean` NOR `Lemma32Reduction.lean` (nor any frozen
provider file), depending on their green declarations by import only.

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

The anchor coupling is discharged by `nfEval_le2_reduction` + arity-3 navigation, NEVER by a
free-standing `NavResidual`. Cross-references:
* atom-hook coupling shape: `nf_char3_endpoint_tl_correct`'s `h_atom` (Base.lean:885).
* base-case anchor residual: `endChar0_correct`'s `h_res` (Base.lean:1056).
* forbidden unconditional form: `endCharN0_correct_infeasible` (Base.lean:1779),
  counterexample narrative at Base.lean:1036-1047.
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation

/-- **Arity-3 specialization of `nfEval_le2_reduction`** (Rabinovich Lemma 3.2(2), md:119).
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
theorem nfEval3_reduction {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    (k : Nat) (env : Fin 3 → M.carrier) (qnf : NormalForm sig k 3) :
    nf_eval_nf M k 3 env qnf ↔ nfEvalRHS M k 3 env qnf :=
  nfEval_le2_reduction M k 3 env qnf

/-- **Arity confirmation, depth 0.** At `k = 0`, the reduced RHS of `nfEval3_reduction` is
exactly a conjunction (over anchor pairs `i j : Fin 3`) of arity-**2** `nf_eval_nf` atom facts
`nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf i j)` — no arity climb past 2 among the
emitted `nf_eval_nf` facts. Direct from the imported `nfEvalRHS_zero`. -/
theorem nfEval3_reduction_zero_shape {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
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
theorem nfEval3_reduction_succ_shape {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    {k : Nat} (env : Fin 3 → M.carrier) (qnf : NormalForm sig (k + 1) 3) :
    nfEvalRHS M (k + 1) 3 env qnf
      = ((∀ (i j : Fin 3),
            nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf.1 i j)) ∧
          (∀ sub : NormalForm sig k 4,
            (∃ w : M.carrier, nfEvalRHS M k 4 (Fin.cons w env) sub) ↔ (qnf.2 sub = true))) :=
  nfEvalRHS_succ M env qnf

/-! ## Phase 2: depth-0 navigated base `endCharNav0_correct` (arity-3, conditional)

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
theorem endCharNav0_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
theorem endCharNav0_correct_pairwise {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

/-- **Phase 3 reduction step (SETTLED "witness-stays-OUTSIDE" merge, GREEN).** The arity-4 inner
realizability obligation of `nf_char3_endpoint_tl_correct`'s `h_inner` — `∃ w, nf_eval_nf M k 4
(Fin.cons w (zoneEnv3 y x t)) sub` — is reduced, **under the single shared witness `w`** (via
`exists_congr`, so `w` stays OUTSIDE the reduced inner form — the order-theoretic `∃w ∀ij` merge,
never a per-pair `∀ij ∃w` distribution), to `∃ w, nfEvalRHS M k 4 (Fin.cons w (zoneEnv3 y x t)) sub`
by consuming `nfEval_le2_reduction` (Rabinovich Lemma 3.2(2), Lemma32Reduction.lean:535)
at arity 4. This is the FIRST, load-bearing step of `navPieceForm_correct`: the reduced RHS
`nfEvalRHS M k 4 [w, y, x, t] sub` is a conjunction of anchor-arity-2 `nf_eval_nf` atom facts over
pairs `(i, j) : Fin 4` plus (at `k+1`) the depth-recursive quant clauses (`nfEval3_reduction_zero_shape`
/ `nfEval3_reduction_succ_shape` one arity up), so navigation over it never climbs past anchor
arity 3. sorry-free. -/
theorem navPiece_reduce {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig)
    (y x t : M.carrier) (sub : NormalForm sig k 4) :
    (∃ w : M.carrier, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) ↔
      (∃ w : M.carrier, nfEvalRHS M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) :=
  exists_congr (fun w => nfEval_le2_reduction M k 4 (Fin.cons w (zoneEnv3 y x t)) sub)

/-! ## Phase 2 (v5): `endCharStep` Step A — arity-4 → `nfEvalRHS` reduction (reduce FIRST)

**Faithful v5 architecture, Step A (report 05 §3.4 Step A, §5.3).** The recursion step `endCharStep`
at depth `k+1` must characterize, for each arity-4 sub-form `sub`, the coupled inner realizability
existential `∃ v, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub` (the quant clause of
`nf_eval_nf M (k+1) 3 (zoneEnv3 w x t) qnf`, exposed by `nfEval_step_unfold_gen` at arity 3). Step A
REDUCES this arity-4 inner existential to the ≤2-anchor (≤ arity-3) conjunction `nfEvalRHS`
**BEFORE any `Formula` conversion**, by consuming `nfEval_le2_reduction` (Rabinovich
Lemma 3.2(2), Lemma32Reduction.lean:535) under a single shared witness `v` (via `exists_congr`, so
`v` stays OUTSIDE the reduced inner form — the order-theoretic `∃v ∀ij` merge, NEVER a per-pair
`∀ij ∃v` distribution). This is where v4 went wrong (it converted to `Formula` first); here the
arity reduction is first (report 05 §1.1, §3.4).

Every emitted `nf_eval_nf` conjunct of the reduced RHS has anchor arity **exactly 2**
(`nfEval4_reduction_zero_shape` / `nfEval4_reduction_succ_shape` below), so navigation over this
reduction (Phase 3) never climbs past anchor arity 3. The arity-4 domain of the recursive `∃ v`
binder over `Fin.cons v (zoneEnv3 w x t)` is NOT an emitted anchor arity — it is the env domain of
the recursion, and its only emitted `nf_eval_nf` facts are the depth-0 arity-2 atom pieces.

### Route audit (Phase 2)
- **G1** — no arity-1 collapse: the reduction targets arity-2 atom facts and the depth-recursive
  quant clauses; no arity-1 residual is produced.
- **G2/G4** — the witness `v` is existentially bound and stays OUTSIDE the reduced inner form (never
  a per-pair distribution); the free anchors stay `{x, t}` (`x, t` EXPLICIT); `v` is a bracket
  witness, never a third free anchor.
- **G5** — assembled by manual `exists_congr` (inside `navPiece_reduce`), `forall_congr'`, and
  `iff_congr` congruence bridges over the reduction; `Iff.rfl` / `rfl` on definitional shapes only;
  no `simp`/`omega`/`aesop` shortcut of a Rabinovich chain step.
- **FORBIDDEN (absent)** — no `Formula`-valued converter yet; no `navPieceForm_correct`; no
  arity-4 enclosing-pair collapse / single-point read (the machine-checked NON-THEOREM,
  Lemma32Reduction.lean:290-306); no arity-collapsing quant `nfRestrict` (the quant assignment
  `qnf.2` is preserved verbatim); no per-pair `∀ij ∃v` distribution; no `nf_char3_deeper_split`. -/

/-- **Arity-4 specialization of `nfEval_le2_reduction`** (Rabinovich Lemma 3.2(2), md:119). The
arity-4 companion of `nfEval3_reduction` (:75): for every depth `k`, environment `env : Fin 4 →
M.carrier`, and sub-form `sub : NormalForm sig k 4`, the arity-4 evaluation `nf_eval_nf M k 4 env
sub` is equivalent to the reduced conjunction `nfEvalRHS M k 4 env sub` of ≤2-anchor `nf_eval_nf`
atom facts plus the depth-recursive quant-layer realizability clauses. A plain instantiation of the
imported `nfEval_le2_reduction` (Lemma32Reduction.lean:535) at `n = 4` — it re-derives NOTHING; it
only fixes the arity at 4 (the env domain of the step's inner existential). Every emitted
`nf_eval_nf` conjunct has anchor arity 2 (`nfEval4_reduction_zero_shape` /
`nfEval4_reduction_succ_shape`), so navigation over it (Phase 3) never climbs past anchor arity 3. -/
theorem nfEval4_reduction {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    (k : Nat) (env : Fin 4 → M.carrier) (sub : NormalForm sig k 4) :
    nf_eval_nf M k 4 env sub ↔ nfEvalRHS M k 4 env sub :=
  nfEval_le2_reduction M k 4 env sub

/-- **Arity confirmation, depth 0 (arity 4).** At `k = 0`, the reduced RHS of `nfEval4_reduction` is
exactly a conjunction (over anchor pairs `i j : Fin 4`) of arity-**2** `nf_eval_nf` atom facts
`nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 sub i j)` — no arity climb past 2 among the
emitted `nf_eval_nf` facts. Direct from the imported `nfEvalRHS_zero`. Confirms the Step-A reduced
conjunction is ≤ arity-3 (in fact arity 2) at the base. -/
theorem nfEval4_reduction_zero_shape {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    (env : Fin 4 → M.carrier) (sub : NormalForm sig 0 4) :
    nfEvalRHS M 0 4 env sub
      = ∀ (i j : Fin 4), nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 sub i j) :=
  nfEvalRHS_zero M env sub

/-- **Arity confirmation, depth `k+1` (arity 4).** At `k+1`, the reduced RHS of `nfEval4_reduction`
splits into (a) arity-**2** `nf_eval_nf` atom facts over anchor pairs `i j : Fin 4`, and (b) the
depth-recursive realizability clauses `∀ s, (∃ w, nfEvalRHS M k 5 (Fin.cons w env) s) ↔ (sub.2 s =
true)` in which the witness `w` stays OUTSIDE the reduced inner form (order-theoretic `∃w ∀ij`
merge — never a per-pair `∀ij ∃w` distribution) and the quant assignment `sub.2` is preserved
verbatim (no arity-collapsing `nfRestrict`). No emitted `nf_eval_nf` atom fact climbs past anchor
arity 2. Direct from the imported `nfEvalRHS_succ`. -/
theorem nfEval4_reduction_succ_shape {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    {k : Nat} (env : Fin 4 → M.carrier) (sub : NormalForm sig (k + 1) 4) :
    nfEvalRHS M (k + 1) 4 env sub
      = ((∀ (i j : Fin 4),
            nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 sub.1 i j)) ∧
          (∀ s : NormalForm sig k 5,
            (∃ w : M.carrier, nfEvalRHS M k 5 (Fin.cons w env) s) ↔ (sub.2 s = true))) :=
  nfEvalRHS_succ M env sub

/-- **Step A — per-`sub` arity-4 → `nfEvalRHS` reduction (witness `v` OUTSIDE; the thin step-level
reduction lemma Phase 3 consumes).** For each arity-4 sub-form `sub`, the coupled inner
realizability existential `∃ v, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub` (the quant clause
of `nf_eval_nf M (k+1) 3 (zoneEnv3 w x t) qnf` at this `sub`, per `nfEval_step_unfold_gen`) is
reduced — **under the single shared witness `v`** — to `∃ v, nfEvalRHS M k 4 (Fin.cons v (zoneEnv3 w
x t)) sub`, whose emitted `nf_eval_nf` conjuncts are all anchor-arity 2 (≤ arity-3;
`nfEval4_reduction_zero_shape` / `nfEval4_reduction_succ_shape`). This is the SETTLED
"witness-stays-OUTSIDE" merge: it CONSUMES the preserved green `navPiece_reduce`
(NavigatedEndChar.lean:215 — `exists_congr (fun v => nfEval_le2_reduction …)`, so `v` stays OUTSIDE),
retained verbatim, renamed to the step context (`y := w`). This is Step A of the v5 REDUCE-FIRST
architecture: the arity reduction happens BEFORE any `Formula` conversion (Phase 3), the witness
`v` stays existential (G2/G4), the anchors stay `{x, t}` EXPLICIT, and there is NO per-pair `∀ij ∃v`
distribution and NO arity-collapsing `nfRestrict`. sorry-free. -/
theorem endCharStep_reduceA {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (sub : NormalForm sig k 4) :
    (∃ v : M.carrier, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub) ↔
      (∃ v : M.carrier, nfEvalRHS M k 4 (Fin.cons v (zoneEnv3 w x t)) sub) :=
  navPiece_reduce M w x t sub

/-- **Step A — whole quant-layer reduction (the form the Phase-3 `endCharStep` assembly threads).**
The depth-`(k+1)` quant layer of `nf_eval_nf M (k+1) 3 (zoneEnv3 w x t) qnf` — the family of
per-`sub` realizability clauses `∀ sub, (∃ v, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub) ↔
(qnf.2 sub = true)` (exposed by `nfEval_step_unfold_gen` at arity 3) — is reduced, clause-by-clause
under the shared witness `v` via `forall_congr'` + `iff_congr` over `endCharStep_reduceA`, to the
`nfEvalRHS`-reduced quant layer `∀ sub, (∃ v, nfEvalRHS M k 4 (Fin.cons v (zoneEnv3 w x t)) sub) ↔
(qnf.2 sub = true)`. The witness `v` stays OUTSIDE each clause (no per-pair `∀ij ∃v` distribution);
the quant assignment `qnf.2` is preserved verbatim (no arity-collapsing `nfRestrict`); every emitted
`nf_eval_nf` conjunct on the reduced side is anchor-arity 2 (≤ arity-3). This is the Step-A output
Phase 3 navigates (Step B, `nf_zone_flatten_navigable_correct`); no `Formula` conversion yet.
sorry-free. -/
theorem endCharStep_quant_reduceA {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (qnf : NormalForm sig (k + 1) 3) :
    (∀ sub : NormalForm sig k 4,
        (∃ v : M.carrier, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub) ↔
          (qnf.2 sub = true)) ↔
      (∀ sub : NormalForm sig k 4,
        (∃ v : M.carrier, nfEvalRHS M k 4 (Fin.cons v (zoneEnv3 w x t)) sub) ↔
          (qnf.2 sub = true)) :=
  forall_congr' (fun sub => iff_congr (endCharStep_reduceA M w x t sub) Iff.rfl)

end FormalSystem.Metalogic.WeakCanonical.Kamp
