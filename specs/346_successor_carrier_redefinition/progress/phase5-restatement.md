# Phase 5 Record — non-vacuous restatement + VACUITY-NOTE removal

**Session**: sess_1783782450_230288
**Dispatch**: lean-implementation-hard-agent, Phase 5 ONLY
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean`
**Decl**: `bracketEndChar_kvE2_sound_two_prior_frag` (OuterGate:245) + the two VACUITY NOTEs
(def `kvE2_sepFragment` docstring; theorem docstring).

## What changed

### 1. Theorem signature re-stated against the Phase-4 fold interface

`kvE2_outer_fold_frag` (SW:12627) after Phases 3+4 takes, beyond the provider shape and 6 order
bits: `M x t h hreal hexcl hexclExt`. The soundness half now threads exactly these. Concretely:

- **REMOVED** the single all-carrier exclusion hypothesis
  `(hexcl : ∀ w …, ∀ σ, qnf.2 σ = false → ∀ x1, ¬ nf_eval_nf …)`.
- **ADDED** three hypotheses mirroring the fold (with `charK := fun χ => P.existF 0 χ`):
  - `hreal` — per-positive realization: `∀ w, x<w → w<t → (kvE2_sepPtW …).eval_at M atomMap w →
    ∀ σ ∈ kvE2_sepPos qnf, ∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`.
  - `hexcl` — cone-restricted exclusion, binder guarded `x ≤ x1 → x1 ≤ t`.
  - `hexclExt` — strictly-exterior residue, binder guarded `¬ (x ≤ x1 ∧ x1 ≤ t)` (the deferred
    Prop-4.3 obligation).
- **DROPPED** `h_UZ`/`h_SZ` (semantic priors) and the `hcorrK` bridge lambda
  `(fun σ a hσa => (bracketEndChar_kvE2_hck …).mp hσa)` — the fold no longer takes `hcorrK`;
  provider correctness now lives inside `hreal`.
- **RETAINED** `hfrag : kvE2_sepFragment qnf` as the fragment-scope / non-vacuity anchor. It is no
  longer destructured by the body, so it produces a benign `unusedVariables` linter warning at
  :267. Kept because non-vacuity is asserted precisely about this premise being satisfiable.

Body (shape unchanged, arg list updated):
```
intro h_holds
rw [bracketEndChar_kvE2_two_eq] at h_holds
exact kvE2_outer_fold_frag atomMap h_surj (fun χ => P.existF 0 χ) qnf
  h_xy h_yt h_xt h_yx h_ty h_tx M x t h_holds hreal hexcl hexclExt
```

### 2. Both VACUITY NOTEs replaced with NON-VACUITY notes

- **Def `kvE2_sepFragment`** (OuterGate:192): the old "UNREALIZABILITY FLAGGED" note replaced by
  "REPAIRED & REALIZABLE" — the Phase-1 swap to `kvE2_sepPosI` + the Phase-2 witness
  `kvE2_sepFragment_realizable` (SW:10265) make the predicate satisfiable.
- **Theorem** (OuterGate:240): the old "DO NOT CONSUME / vacuous AS STATED" note replaced by
  "VACUITY RESOLVED" — cites `kvE2_sepFragment_realizable` (∃ qnf with `kvE2_sepFragment_frag qnf`,
  byte-defeq to `kvE2_sepFragment` via the rfl bridge OuterGate:223-224), so the `hfrag` premise is
  satisfiable and the theorem is non-vacuous; scopes `hexcl` (dischargeable cone) vs `hexclExt`
  (named, deferred exterior residue → Prop-4.3 successor).

## Build / verification

- Scoped build `lake build …NfMultiAnchorBridge.OuterGate` (imports SharedWitness): **GREEN**,
  1014 jobs. Only pre-existing `unusedSimpArgs` warnings (inside SharedWitness fragL/fragR) plus
  the new benign `unusedVariables` warning on the retained `hfrag` (:267) and the pre-existing
  completeness-half order-bit warnings (:146-149). No errors.
- Axioms: `#print axioms bracketEndChar_kvE2_sound_two_prior_frag` via `lake env lean` against the
  build cache → `{propext, Classical.choice, Quot.sound}` — axiom-clean, **no `sorryAx`**.
- **Stale-tool caveat (recorded for the vault)**: a `lean_verify` MCP call on the freshly-edited
  theorem reported `sorryAx` while siblings in the same file verified clean. This was a stale LSP
  error-recovery artifact — the cache-backed `#print axioms` is authoritative and shows clean.
- No sorry / admit / vacuous placeholder on any live path (grep-confirmed; the only `sorry`
  substrings in the file are prose in the NON-VACUITY note).

## Preserved / not-regressed

- SharedWitness untouched this phase (all Phase-1..4 commits frozen and green).
- `kvE2_outer_fold_frag` (SW:12627), `bracketEndChar_kvE2` / `_two_eq` / `_hck`, the completeness
  half (:139), and `kvE2_sepFragment_realizable` all independently verify axiom-clean.

## Handoff to Phase 6

- **New consumer interface** for task 309 (Phases 13.4/14, `KampPrior.lean:351`) and task 335
  Phase D: they must supply the cone `hexcl` + `hreal`, and carry `hexclExt` as the successor
  obligation. They no longer supply `hfrag`-to-the-fold, `hcorrK`, or `h_UZ`/`h_SZ`.
- **Deferred successor**: `hexclExt` is the strictly-exterior completeness residue — recommend
  `/spawn` of `prop43_exterior_completeness` carrying the full-exterior obligation, the
  `Prop43.lean` uniform-negation blocker (:120-159) as entry problem, and 330 report 01 + 335
  report 07 as grounding.
- **Not run this dispatch**: full-project `lake build`. Phase 5 verified scoped only. External
  consumer files may be RED until they thread the new interface — that reconciliation is Phase 6 /
  consumer-task work, not a Phase-5 regression.
