# Teammate C Findings: NF-to-FOMLO Bridge and Sorry Wiring

**Artifact**: 13, Teammate: C  
**Session**: sess_1781193902_83bc5c (continuation)  
**Date**: 2026-06-12

---

## Executive Summary

This report documents the complete NF-to-FOMLO infrastructure, the precise type
signatures of the three active sorry sites, and a wiring plan that could close
them. The key finding is that `p2_from_p1_succ` (FoToVecEA.lean, sorry-free)
gives P2(k) from P1(k+1), but this does NOT break the circularity in the current
master_induction — it merely shifts it up by one level. The three sorry sites all
stem from the same root: proving P1(k+1) requires P2(k), and getting P2(k) via
p2_from_p1_succ requires P1(k+1). Two viable paths exist: Path A (composition
theorem) and Path B (Prop 4.3 / structural induction on MonadicFormula).

---

## 1. NF-to-FOMLO Infrastructure Audit

### 1.1 What exists and is sorry-free

**`NormalForm.lean:705`** — `nf_to_formula`:
```
nf_to_formula : NormalForm sig k n → MonadicFormula sig n
```
Converts any NF to a MonadicFormula by: at depth 0, conjoin all atom conditions;
at depth k+1, conjoin atom conditions with ∃/¬∃ quantifier conditions. **Sorry-free.**

**`NormalForm.lean:719`** — `nf_to_formula_correct`:
```
theorem nf_to_formula_correct (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (nf : NormalForm sig k n) :
    eval M env (nf_to_formula nf) ↔ nf_eval_nf M k n env nf
```
This is the key NF-to-FOMLO bridge: nf_eval_nf has a MonadicFormula counterpart
that is correct on ALL structures (not just Prior). **Sorry-free.**

**`NormalForm.lean:433`** — `doets_lemma_1_1`:
```
theorem doets_lemma_1_1 (k n : Nat) (phi : MonadicFormula sig n)
    (h_depth : phi.quantifier_depth ≤ k)
    (M N : OrderedMonadicStructure sig) (env_M env_N)
    (h_same_nf : ∀ nf, nf_eval_nf M k n env_M nf ↔ nf_eval_nf N k n env_N nf) :
    eval M env_M phi ↔ eval N env_N phi
```
NF determines monadic formula truth. **Sorry-free.**

**`FoToVecEA.lean:85`** — `nf_exist_iff_char_quant`:
```
theorem nf_exist_iff_char_quant (M : OrderedMonadicStructure sig) (k : Nat)
    (t : M.carrier) (sub_nf : NormalForm sig k 2) :
    (∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf) ↔
    (nf_characteristic M (k + 1) 1 (fun _ => t)).2 sub_nf = true
```
The existence of a depth-k 2-var NF witness is equivalent to the depth-(k+1)
characteristic NF of t recording that sub_nf is realized. **Sorry-free.**
This is the semantic bridge — it does NOT require any formula construction.

**`FoToVecEA.lean:156`** — `p2_from_p1_succ`:
```
noncomputable def p2_from_p1_succ (k : Nat)
    (char_kp1 : NormalForm sig (k+1) 1 → Formula)
    (char_kp1_correct : ∀ nf_1 M h_UZ h_SZ t, temporal_truth M atomMap t (char_kp1 nf_1) ↔
        nf_eval_nf M (k+1) 1 (fun _ => t) nf_1)
    (parent_atoms : AtomKind sig 1 → Bool) (sub_nf : NormalForm sig k 2) :
    ∃ A, ∀ M h_UZ h_SZ t,
      (∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
      (temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf)
```
Formula: disjunction of `char_{k+1}(nf_1)` over all nf_1 with `nf_1.2(sub_nf) = true`
and atoms compatible with parent_atoms. **Sorry-free.**

### 1.2 What the Separation module provides

`Separation.nf_depth0_char_formula` (imported in KampPrior.lean and NfCharFormula.lean):
correct depth-0 NF characterization as a conjunction of atom literals. **Sorry-free.**

---

## 2. Sorry Site Inventory: Exact Type Signatures

### Sorry 1: NegationClosure.lean:1371 (`nf_exist_formula_nested_backward`)

**Goal at the sorry**:
```
h_formula : temporal_truth M atomMap t (nf_exist_formula_nested k char_kp1 parent_atoms sub_nf)
⊢ ∃ x, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x fun _ ↦ t) sub_nf
```

**Context**: `sub_nf : NormalForm sig (k+1) 2`, `char_kp1` correct for all Prior structures.
The formula `nf_exist_formula_nested` encodes: a witness x with depth-(k+1) 1-var NF
matching sub_nf atoms, plus interval Since/Until chains for the positive entries of
sub_nf.2. The backward direction must extract x and prove the full 2-var NF of (x,t)
matches sub_nf — requiring recovery of the quantifier part sub_nf.2.

**Why it is hard**: The quantifier part sub_nf.2(ssn) asserts `∃ y, nf_eval_nf M k 3 (y,x,t) ssn`.
For POSITIVE ssn (sub_nf.2(ssn) = true), the interval chains in the formula yield
witnesses y. For NEGATIVE ssn (sub_nf.2(ssn) = false), the formula provides NO direct
evidence — we need to show NO such y exists, which requires knowing the full 2-var NF
of (x,t), which is what we're trying to prove. Circular.

**Estimated lines to close**: 150-300 lines (composition theorem approach), or bypassed
entirely if the master_induction is restructured (Path B).

### Sorry 2: NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`)

**Type signature**:
```
theorem nf_2var_exist_formula_prior (atomMap : Formula → sig.preds)
    (h_surj : ...)
    (k : Nat)
    (char_k : NormalForm sig k 1 → Formula)
    (char_k_correct : ∀ nf_k M h_UZ h_SZ t,
        temporal_truth M atomMap t (char_k nf_k) ↔ nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool) (sub_nf : NormalForm sig k 2) :
    ∃ (A : Formula),
      ∀ M h_UZ h_SZ t,
        (∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf)
```

**Relationship to p2_from_p1_succ**: This is exactly P2(k), but with `char_k` as
hypothesis (not char_{k+1}). It cannot be filled directly by `p2_from_p1_succ`
because that requires `char_{k+1}`, not `char_k`.

**However**: `nf_2var_exist_formula_prior_fill` in NegationClosure.lean:1475 provides
exactly the same type by extracting `.2` from the master_induction. The master_induction
is sorry-free at k=0 but sorry-propagating at k≥1 (via the nested_backward sorry).

**Estimated lines to close**: 5 lines (redirect to a sorry-free master_induction, if one
is built) or 0 lines (this sorry becomes dead code once KampPrior.lean:149 is filled).

### Sorry 3: KampPrior.lean:149 (`nf_characterizable_temporal_prior` succ case)

**Goal at the sorry**:
```
sig : MonadicSignature
atomMap : Formula → sig.preds
h_surj : ∀ p, ∃ a, atomMap (.atom a) = p
k : Nat
nf : NormalForm sig (k + 1) 1
ih : (nf' : NormalForm sig k 1) → { A : Formula // ∀ M h_UZ h_SZ t,
      temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _ => t) nf' }
⊢ { A : Formula // ∀ M h_UZ h_SZ t,
      temporal_truth M atomMap t A ↔ nf_eval_nf M (k + 1) 1 (fun _ => t) nf }
```

**What is needed**: Given P1(k) (via ih), produce P1(k+1). This requires P2(k) (to
build the exist_f formulas from the ih). P2(k) = nf_2var_exist_formula_prior with
`char_k` from ih. But `nf_2var_exist_formula_prior` is sorry'd.

**Relationship to nf_char_kp1_from_2var**: The function `nf_char_kp1_from_2var`
(NegationClosure.lean:204) takes `char_k_correct` and `p2_k` as hypotheses and returns
P1(k+1). So the succ case of KampPrior.lean can be filled as:
```lean
| succ k ih =>
    let char_k := fun nf_k => (ih nf_k).val
    have char_k_correct := fun nf_k => (ih nf_k).property
    have p2_k : P2(k) := ... -- THIS IS THE GAP
    exact ⟨Classical.choose (nf_char_kp1_from_2var ... char_k char_k_correct p2_k nf),
           Classical.choose_spec (...)⟩
```
The `p2_k` gap is exactly `nf_2var_exist_formula_prior` applied to `char_k`/`char_k_correct`.

**Estimated lines to close**: 15-20 lines (if p2_k is provided), or restructure needed.

---

## 3. The Circularity: Why p2_from_p1_succ Does Not Directly Help

The circularity chain at the sorry sites:

```
P1(k+1) needs P2(k)                                    [nf_char_kp1_from_2var]
P2(k) via p2_from_p1_succ needs P1(k+1)               [FoToVecEA.lean:156]
```

The master_induction in NegationClosure.lean avoids this by proving P1(k+1) and P2(k+1)
simultaneously by induction on k. Specifically:
- P1(0): sorry-free (nf_depth0_char_formula)
- P2(0): sorry-free (backward_depth0)
- P1(k+1) from P1(k) + P2(k): sorry-free (nf_char_kp1_from_2var)
- P2(k+1) from P1(k+1): **this is the sorry** at line 1371

The sorry at line 1371 is the only blocker. It propagates upward:
- NegationClosure.lean:1371 → nf_2var_exist_formula_prior_fill is sorry-containing
- → nf_2var_exist_formula_prior (NfCharFormula.lean:572) remains sorry'd
- → nf_characterizable_temporal_prior (KampPrior.lean:149) succ case remains sorry'd

All three sorries have the same mathematical root: proving the backward direction of
the 2-var NF existence formula at depth k+1.

---

## 4. Wiring Plan: Three Sorry Sites

### Option A: Fix nf_exist_formula_nested_backward (NegationClosure.lean:1371)

This is the surgical fix. Once this sorry is closed, the entire chain resolves:

**Step 1** (0 lines): NegationClosure.lean:1371 is closed with the composition theorem.
  The composition theorem (Feferman-Vaught) gives: if pairwise depth-k 2-var NFs of
  (y,x) and (y,t) for all y match, then the depth-k 3-var NF of (y,x,t) matches.

**Step 2** (0 lines): `nf_2var_exist_formula_prior_fill` at NegationClosure.lean:1475 becomes
  sorry-free automatically (it's just `(master_induction ...).2 parent_atoms sub_nf`).

**Step 3** (~5 lines): Fill NfCharFormula.lean:572 by redirecting to `nf_2var_exist_formula_prior_fill`:
```lean
theorem nf_2var_exist_formula_prior ... := by
  exact nf_2var_exist_formula_prior_fill atomMap h_surj k parent_atoms sub_nf
```
**Type check**: The type of `nf_2var_exist_formula_prior_fill` (NegationClosure.lean:1481)
matches `nf_2var_exist_formula_prior` EXCEPT: `nf_2var_exist_formula_prior` takes `char_k`
and `char_k_correct` as hypotheses, while `nf_2var_exist_formula_prior_fill` does not (it
builds `char_k` internally from the master_induction). **Type mismatch**: the `char_k` and
`char_k_correct` parameters in `nf_2var_exist_formula_prior` are IGNORED by the fill function.
This is semantically fine (the fill is more general), but the signature differs.

**Resolution**: Either (a) change `nf_2var_exist_formula_prior` to drop the `char_k`
parameters (since fill doesn't need them), or (b) prove `nf_2var_exist_formula_prior`
by applying `nf_2var_exist_formula_prior_fill` and ignoring `char_k`. Option (b) is
cleaner: the `char_k_correct` hypothesis is used only to restrict to Prior structures,
which fill already handles. **Estimated: 5-8 lines.**

**Step 4** (~20 lines): Fill KampPrior.lean:149 succ case:
```lean
| succ k ih =>
    let char_k := fun nf_k => (ih nf_k).val
    have char_k_correct : ∀ nf_k M h_UZ h_SZ t,
        temporal_truth M atomMap t (char_k nf_k) ↔ nf_eval_nf M k 1 (fun _ => t) nf_k :=
      fun nf_k => (ih nf_k).property
    -- P2(k) from the filled nf_2var_exist_formula_prior
    have p2_k := fun pa sub_nf =>
      nf_2var_exist_formula_prior atomMap h_surj k char_k char_k_correct pa sub_nf
    exact ⟨Classical.choose (nf_char_kp1_from_2var atomMap h_surj k char_k char_k_correct p2_k nf),
           Classical.choose_spec (nf_char_kp1_from_2var atomMap h_surj k char_k char_k_correct p2_k nf)⟩
```
**Type check**: `nf_char_kp1_from_2var` returns `∃ A, ∀ M h_UZ h_SZ t, ...` and the target
is `{ A // ∀ M h_UZ h_SZ t, ... }`. Both use `Classical.choose`/`Classical.choose_spec`
to convert from the existential to the subtype. **Types match.**

### Option B: Replace master_induction with p2_from_p1_succ-based approach (Path B)

This is the structural induction on MonadicFormula approach from the handoff (Path B).

The key insight: `nf_to_formula` converts any NF to a MonadicFormula. On Prior structures,
every MonadicFormula has a temporal equivalent by structural induction. So:

```
∀ k, ∀ nf : NormalForm sig k 1,
  ∃ A : Formula, ∀ M h_UZ h_SZ t,
    temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _ => t) nf
```

follows from:
1. nf_to_formula converts nf to MonadicFormula phi (correct on all structures)
2. Prop 4.3 converts phi to VVecEA2 formula psi (correct on Prior structures)
3. VVecEA2.translateLeft_correct converts psi to temporal formula A

Prop 4.3 reduces each MonadicFormula to VVecEA via:
- Lemma 3.2.2: ∀ n > 2 free variables, EA formula decomposes into conjunction of 2-free-variable formulas
- Prop 4.2 (VecEAClosure.lean, sorry-free): on Prior structures, VecEA formulas are closed under negation
- Prop 3.5 (VecEATranslation.lean, sorry-free): VecEA formulas translate to temporal formulas

**Status of Prop 4.3 infrastructure**: VecEAClosure.lean and VecEATranslation.lean are
sorry-free per the grep audit. VecEAFormula.lean defines the types. The missing piece is
Lemma 3.2.2 (n > 2 variable decomposition) and a driver that connects nf_to_formula → Prop 4.3.

**Estimated effort for Path B**: 300-500 lines for Lemma 3.2.2 + Prop 4.3 driver.

---

## 5. Type Compatibility Analysis

### Can nf_2var_exist_formula_prior be filled without modifying master_induction?

YES. `nf_2var_exist_formula_prior_fill` provides the same mathematical content. The
signature difference is:
- `nf_2var_exist_formula_prior` takes `char_k : NormalForm sig k 1 → Formula` and `char_k_correct`
- `nf_2var_exist_formula_prior_fill` takes none (builds internally)

Fill proof:
```lean
theorem nf_2var_exist_formula_prior atomMap h_surj k char_k char_k_correct parent_atoms sub_nf :=
  nf_2var_exist_formula_prior_fill atomMap h_surj k parent_atoms sub_nf
```
The `char_k` and `char_k_correct` parameters are simply unused. This is valid in Lean 4.
The result type matches exactly. **No master_induction restructuring needed.**

### Can KampPrior.lean:149 be filled without restructuring master_induction?

YES, once `nf_2var_exist_formula_prior` is filled. The succ case (shown in Option A Step 4)
uses `nf_char_kp1_from_2var` which is already sorry-free.

### Does NegationClosure.lean:1371 need to be filled, or can it be bypassed?

**It depends on the path**:
- Under Option A: this sorry MUST be closed (it's the root blocker).
- Under Option B (Prop 4.3): this sorry CAN be bypassed. KampPrior.lean:149 can be filled
  using P1(k) from Prop 4.3 without ever calling master_induction or nf_exist_formula_nested.
  The sorry at NegationClosure.lean:1371 remains but becomes a dead branch (master_induction
  is not called in the main proof path).

### Does nf_exist_formula_nested_backward need the master_induction's P2(k)?

Yes. The function `nf_exist_formula_nested_backward` takes `p2_k` as an explicit parameter.
In the current master_induction, `p2_k` is the induction hypothesis at depth k (the P2
component). The sorry at line 1371 is inside the definition of P2(k+1), which uses P2(k)
to handle quantifier interactions. But closing the sorry at 1371 requires the COMPOSITION
THEOREM (Feferman-Vaught), not just P2(k).

---

## 6. Summary: What Types Match, What Doesn't

| Sorry site | Type needed | Available | Matches? |
|------------|-------------|-----------|----------|
| NegationClosure.lean:1371 | ∃ x, nf_eval_nf M (k+1) 2 (x,t) sub_nf | From composition theorem | Not yet proved |
| NfCharFormula.lean:572 | ∃ A, ... P2(k) with char_k param | nf_2var_exist_formula_prior_fill (drops char_k) | Yes (char_k unused) |
| KampPrior.lean:149 | { A // P1(k+1) } | nf_char_kp1_from_2var after P2(k) filled | Yes once P2(k) filled |

---

## 7. Recommended Wiring Plan

**Phase 1** (prerequisite): Close NegationClosure.lean:1371 via composition theorem
(Path A, ~150-300 lines) OR bypass it via Prop 4.3 (Path B, ~300-500 lines).

**Phase 2** (5-8 lines): Fill NfCharFormula.lean:572:
```lean
-- NfCharFormula.lean:572
  exact nf_2var_exist_formula_prior_fill atomMap h_surj k parent_atoms sub_nf
```
File: `/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean`, line 572.

**Phase 3** (15-20 lines): Fill KampPrior.lean:149 succ case using nf_char_kp1_from_2var:
```lean
-- KampPrior.lean after line 148
  | succ k ih =>
    let char_k := fun nf_k => (ih nf_k).val
    have char_k_correct := fun nf_k => (ih nf_k).property
    have p2_k := fun pa snf =>
      nf_2var_exist_formula_prior atomMap h_surj k char_k char_k_correct pa snf
    let result := nf_char_kp1_from_2var atomMap h_surj k char_k char_k_correct p2_k nf
    exact ⟨Classical.choose result, Classical.choose_spec result⟩
```
File: `/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`, line 149.

**Total non-prerequisite wiring**: ~25-28 lines across 2 files.

**The sole blocker**: Closing NegationClosure.lean:1371 (via composition theorem or Prop 4.3).
The handoff recommends Path B (Prop 4.3) as the revised recommendation, which bypasses
the difficult backward direction entirely. Under Path B, NegationClosure.lean:1371 remains
a sorry in a dead code branch, and neither NfCharFormula.lean:572 nor KampPrior.lean:149
depend on it.

---

## 8. Path B Detail: Can We Wire Without Modifying master_induction?

Under Path B, the plan is:

1. Prove `kamp_p1_from_prop43 : ∀ k nf, ∃ A, ∀ M h_UZ h_SZ t, ...` using Prop 4.3.
   This is the same type as the existential form of `nf_characterizable_temporal_prior`.

2. Fill KampPrior.lean:149 directly using kamp_p1_from_prop43:
   ```lean
   | succ k ih =>
       exact ⟨Classical.choose (kamp_p1_from_prop43 (k+1) nf),
              Classical.choose_spec (kamp_p1_from_prop43 (k+1) nf)⟩
   ```
   The IH `ih` is unused in this branch (Prop 4.3 proves all depths simultaneously).

3. Fill NfCharFormula.lean:572 (same as above, independent of master_induction).

Under Path B, `master_induction` and `nf_exist_formula_nested_backward` are NOT called
anywhere in the proof of `kamp_prior_expressive_completeness`. They remain as dead code
with their sorry, but the main theorem is sorry-free.

This is the cleanest architectural option: no modification to master_induction required.
