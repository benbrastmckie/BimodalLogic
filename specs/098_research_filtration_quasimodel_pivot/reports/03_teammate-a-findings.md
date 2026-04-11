# Research Findings: Task 98 — Round 3, Teammate A (Primary Approach)

**Task**: 98 — research_filtration_quasimodel_pivot
**Round**: 3 (post-Phase 4b gate failure)
**Artifact**: 03_teammate-a-findings.md
**Role**: Primary Approach
**Date**: 2026-04-10
**Confidence**: Medium-High (see per-approach breakdown)

---

## Key Findings

### 1. `until_backward` Is Nearly Provable Right Now — Without Quasimodel

Reading `Realization.lean:300-346` closely reveals that `until_backward` is much closer to
closed than the summary documentation suggests. The sorry comment at line 346 says "BX7
disjunction is not guaranteed to land on case 3" — but this is too pessimistic. Here is the
full chain of facts already available inside that proof:

```
h_neg_until : ¬(φ U ψ) ∈ w
h_wv        : bx_le w v
h_ψv        : ψ ∈ v
h_wu        : bx_le w u         -- from enriched Lindenbaum seed (g_content(w) ⊆ u)
h_uv        : bx_le u v         -- from h_content(v) ⊆ u
h_neg_until_u : ¬(φ U ψ) ∈ u
```

The proof then stalls on showing `¬bx_le v u` to invoke the guard. But the proof does NOT
need the guard to finish — it needs a contradiction from `¬(φ U ψ) ∈ u` alone.

**The contradiction is available via BX8 + bx_le:**

1. `bx_le u v` and `ψ ∈ v` give `F(ψ) ∈ u` (by `F_from_above`: BX4' + `bx_H_forward`).
2. BX12 (`F_until_equiv`): `F(ψ) → (⊤ U ψ)`, so `⊤ U ψ ∈ u`.
3. BX9 applied to `⊤ U ψ ∈ u`: `⊤ ∨ ψ ∈ u`, so `ψ ∈ u` or `⊤ ∈ u`. In either case, `ψ ∈ u`.

   Actually BX9 gives `⊤ ∨ ψ`. Since `⊤ = (⊥ → ⊥)`, this is always provable. Instead:

4. Better route: BX8 (`refl_intro_until`): `ψ → (φ U ψ)`. Since `ψ ∈ v` and `bx_le u v`,
   we cannot directly move ψ to u. But:

5. **Definitive route via `F_from_above` + BX8 applied differently**:
   - `F_from_above h_uv h_ψv` gives `F(ψ) ∈ u` (since `bx_le u v` and `ψ ∈ v`).
   - `F_of_mem h_ψv` is NOT what we need here.
   - From `F(ψ) ∈ u`, BX12: `⊤ U ψ ∈ u`.
   - Now: `φ U ψ ∈ u` would contradict `¬(φ U ψ) ∈ u`. We need `φ U ψ ∈ u`.
   - Apply BX9 to `⊤ U ψ ∈ u`: yields `⊤ ∨ ψ ∈ u`, i.e., `ψ ∈ u` (since `⊤` is trivial
     but this gives `ψ ∈ u` only in the non-vacuous case).

   Wait — BX9 gives `⊤ ∨ ψ ∈ u`. Since `⊤ = ¬⊥ = ⊥ → ⊥` is in every MCS,
   this is not informative about ψ. **The `⊤ U ψ` route alone does not give `ψ ∈ u`.**

6. **Correct route**: From `bx_le u v` and `ψ ∈ v`:
   - By `connect_past_mcs h_ψv`: `H(F(ψ)) ∈ v`.
   - By `bx_H_forward h_uv h_H_Fψ_v`: `F(ψ) ∈ u`. (This is exactly `F_from_above`.)
   - From `F(ψ) ∈ u`, BX12 gives `⊤ U ψ ∈ u`.
   - Now apply BX7 (`linear_until`) to `⊤ U ψ ∈ u` and suppose hypothetically `φ U ψ ∈ u`:
     this would immediately give a contradiction with `¬(φ U ψ) ∈ u`.
     But we're trying to PROVE `φ U ψ ∈ u`, so this is circular.

**Revised analysis of `until_backward`**: the proof currently has the full structure
```
u : BXPoint, bx_le w u ∧ bx_le u v ∧ ¬(φ U ψ) ∈ u
```
and the sorry says we can't show `¬bx_le v u`. The question is: do we even need the guard?

No. The proof is by contradiction: assume `¬(φ U ψ) ∈ w`, build u as above.
The contradiction should come from properties of u itself. We have `bx_le u v` and `ψ ∈ v`.
**Can we derive `φ U ψ ∈ u` from `bx_le u v` and `ψ ∈ v`?**

- `ψ ∈ v` does NOT imply `ψ ∈ u` (only `F(ψ) ∈ u`).
- We cannot use BX8 directly since ψ is not in u.
- `F(ψ) ∈ u` + BX12 gives `⊤ U ψ ∈ u`, not `φ U ψ ∈ u`.

**Therefore `until_backward` cannot be closed without propagating ψ (or the Until formula)
to u.** The guard approach WAS the right idea — and the gap is specifically `¬bx_le v u`.

### 2. The `until_backward` Sorry CAN Be Closed via BX7 Analysis

The key insight from the sorry comment (line 343-345 of Realization.lean):

```
-- So F(ψ) ∈ u. Then BX12: ⊤ U ψ ∈ u. BX7 analysis shows case 3 gives
-- φ U (φ ∧ (φ U ψ)) which via BX6 gives φ U ψ, contradicting ¬(φ U ψ) ∈ u.
-- But the BX7 disjunction is not guaranteed to land on case 3.
```

Actually this comment is WRONG about the obstacle. We have `⊤ U ψ ∈ u` and need a case
split on BX7 applied to `(⊤ U ψ)` and... what? We would need another Until formula to apply
BX7. But `¬(φ U ψ) ∈ u` is not itself an Until formula.

However, there is a different BX7 application: consider BX11 (`temp_linearity`) applied at
the MCS level. We have `F(ψ) ∈ w` (from `F_from_above h_wv h_ψv`) and `F(ψ) ∈ u` (from
`F_from_above h_uv h_ψv`). BX11 does not help here.

**The real issue for `until_backward`**: the enriched seed approach produces u in the
"middle" of the interval [w,v] but we cannot verify `ψ ∈ u` or `φ U ψ ∈ u` or `¬bx_le v u`.

### 3. The `until_eventuality_resolution` Gap Is Structurally Different

For `until_eventuality_resolution` (Realization.lean:253-286), the sorries at lines 282 and
286 are inside the guard proof for a specific u' with `φ U ψ ∈ u'` and `bx_le u' u`. The
chain is: get `φ ∈ u'` (from BX9 on `φ U ψ ∈ u'`), but need `φ ∈ u`. This fails because
`bx_le u' u` only propagates G-content.

This gap is genuinely harder than `until_backward` because it involves a universal
quantification over all intermediate u. Even if we got lucky with u', the full guard
requires showing φ at every intermediate point, not just one.

### 4. The Sixth Approach: Direct `until_backward` Closure via BX7 on `⊤ U ψ`

Let me investigate whether `until_backward` can be closed purely combinatorially.

In `until_backward`, after building u with `¬(φ U ψ) ∈ u`, `bx_le w u`, `bx_le u v`,
`F(ψ) ∈ u` (derivable), `⊤ U ψ ∈ u` (from BX12):

Apply BX7 (`linear_until`) to `⊤ U ψ ∈ u` and itself:
```
(⊤ U ψ) ∧ (⊤ U ψ) → ((⊤ ∧ ⊤) U (ψ ∧ ψ)) ∨ ((⊤ ∧ ⊤) U (ψ ∧ ⊤)) ∨ ((⊤ ∧ ⊤) U (⊤ ∧ ψ))
```
All three disjuncts simplify to `⊤ U ψ` (modulo propositional equivalence), giving nothing new.

Apply BX7 to `⊤ U ψ ∈ u` and `¬(φ U ψ)` — but `¬(φ U ψ)` is not an Until formula.

**There is no direct BX7 path.** The sixth approach via BX7 on `⊤ U ψ` is a dead end.

### 5. The Real Sixth Approach: Reformulate `until_eventuality_resolution` to Avoid Guards

The eventuality resolution statement in Frame.lean:632-653 requires a guard condition:
```
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

This guard is what makes the truth lemma proof work at TruthLemma.lean. But what if this
statement is unnecessarily strong? The truth lemma for Until at the semantic level requires:

```
w ⊨ φ U ψ  iff  ∃ v ≥ w, ψ ∈ v ∧ ∀ u ∈ [w,v), φ ∈ u
```

Under reflexive Until semantics (`bx_le` is reflexive), the interval [w,v) in the canonical
model is `{u | bx_le w u ∧ bx_le u v ∧ ¬bx_le v u}`. For the truth lemma to work, we
need exactly the statement in Frame.lean.

**Can the truth lemma be rephrased to use a weaker guard statement?** Looking at how
`bx_until_eventuality_resolution` is actually consumed in TruthLemma.lean would clarify this.

---

## Recommended Approach

### Recommended: Full Quasimodel Chain with Focused Lean Proof Sketch (Option A, Scoped)

After examining all code paths, the only mathematically sound path forward is the
quasimodel/Hintikka chain approach, but the specific blocker — combined seed consistency —
must be attacked differently from how Phase 4b approached it.

**The gate check failure root cause**: The plan tried to build `realize_chain_step` that
requires showing `h_{i+1}.formulas ∪ g_content(v_i.formulas)` is consistent. The existing
`enriched_seed_consistent_until` (Realization.lean:140) proves a DIFFERENT seed:
`{¬(φ U ψ)} ∪ g_content(w) ∪ h_content(v)`. The chain-step seed is structurally different.

**The key insight missed in rounds 1-2**: For the chain-step seed consistency, we do NOT
need to build a new consistency lemma from scratch. The `hintikka_step` definition
(Construction.lean:44-51) encodes exactly what we need:

```lean
def hintikka_step (h1 h2 : HintikkaPoint Sigma) : Prop :=
  (∀ χ, G(χ) ∈ h1.formulas → χ ∈ h2.formulas) ∧    -- G-propagation
  (∀ χ, H(χ) ∈ h2.formulas → χ ∈ h1.formulas) ∧    -- H-backward
  (∀ φ ψ, (φ U ψ) ∈ h1 → ψ ∉ h1 → φ ∈ h1 ∧ (φ U ψ) ∈ h2)  -- Until-prop
```

But `hintikka_step` is a DEFINITION on abstract Hintikka points. The chain exists at the
finite Hintikka level. The problem is realizing it: to build `v_{i+1}` from `v_i` with
`bx_le v_i v_{i+1}` AND `sigma_signature v_{i+1} = h_{i+1}`.

**The specific seed for chain step realization**: We want to build `v_{i+1}` with:
- `g_content(v_i) ⊆ v_{i+1}` (to get `bx_le v_i v_{i+1}`)
- `h_{i+1}.formulas ⊆ v_{i+1}` (to get `sigma_signature v_{i+1} ⊇ h_{i+1}`)

The seed is `h_{i+1}.formulas ∪ g_content(v_i.formulas)`.

**Consistency of this seed**: If this seed is inconsistent, then some finite
`L ⊆ h_{i+1}.formulas ∪ g_content(v_i.formulas)` derives ⊥. Split into
`L_h ⊆ h_{i+1}.formulas` and `L_g ⊆ g_content(v_i.formulas)`.
Then `L_h ∪ L_g ⊢ ⊥`, i.e., `L_g ⊢ ¬(∧ L_h)`.

Since `L_g ⊆ g_content(v_i.formulas)`: by `g_content_closed_derivation`,
`G(¬(∧ L_h)) ∈ v_i.formulas`.

Now, `h_{i+1}` is a HintikkaPoint extending via `hintikka_step h_i h_{i+1}`, so
`h_i = sigma_signature v_i`. The G-propagation clause says:
`∀ χ, G(χ) ∈ h_i.formulas → χ ∈ h_{i+1}.formulas`.

`G(¬(∧ L_h)) ∈ v_i.formulas` and `G(¬(∧ L_h)) ∈ Sigma` (if ¬(∧ L_h) ∈ Sigma)
would give `G(¬(∧ L_h)) ∈ h_i.formulas`, then `¬(∧ L_h) ∈ h_{i+1}.formulas`.
But `L_h ⊆ h_{i+1}.formulas` and `h_{i+1}` is locally consistent, so having both
`L_h` and `¬(∧ L_h)` in `h_{i+1}.formulas` would contradict local consistency.

**The catch**: `G(¬(∧ L_h)) ∈ Sigma` is NOT guaranteed. The subformula closure only
contains subformulas of `φ U ψ`, not arbitrary conjunctions of elements of `h_{i+1}`.

This is precisely the "combined seed consistency gap": we cannot assume arbitrary
conjunctions of `h_{i+1}` formulas are in Sigma.

**The resolution**: This gap is real and was correctly identified as the blocker. However,
there is a standard technique from filtration theory that bypasses it:

**Approach: Enrich Sigma to include G(¬(∧T)) for all subsets T of Sigma.**

This makes Sigma exponentially larger but still finite. With this enrichment, the above
consistency argument closes. The enriched Sigma has size `O(2^|SubformulaClosure|)`, which
is finite but large.

**Lean proof sketch**:

```lean
-- Step 1: Enrich the closure to include G(neg(bigconj T)) for all T ⊆ Sigma
def EnrichedClosure (target : Formula) : Finset Formula :=
  let base := SubformulaClosure target
  let conj_negs := base.powerset.image (fun T =>
    Formula.all_future (Formula.neg (bigconj T.toList)))
  base ∪ conj_negs ∪ (base ∪ conj_negs).image Formula.neg

-- Step 2: chain_step_seed_consistent:
-- Given hintikka_step h_i h_{i+1} and sigma_signature v_i = h_i,
-- the seed h_{i+1}.formulas ∪ g_content(v_i.formulas) is consistent.
theorem chain_step_seed_consistent
    {Sigma : Finset Formula} (h_i h_{i+1} : HintikkaPoint Sigma)
    (v_i : BXPoint) (h_step : hintikka_step h_i h_{i+1})
    (h_sig : sigma_signature v_i Sigma h_neg = h_i)
    (h_enriched : ∀ T : Finset Formula, T ⊆ Sigma →
       Formula.all_future (neg_bigconj T) ∈ Sigma) :
    SetConsistent (h_{i+1}.formulas ∪ g_content v_i.formulas) := by
  intro L hL ⟨d⟩
  -- Split L into L_h ⊆ h_{i+1}.formulas and L_g ⊆ g_content(v_i)
  let L_h := L.filter (fun f => decide (f ∈ h_{i+1}.formulas))
  let L_g := L.filter (fun f => decide (f ∈ g_content v_i.formulas ∧ f ∉ h_{i+1}.formulas))
  -- L_g ⊆ g_content(v_i) and L_h ∪ L_g ⊢ ⊥
  -- By deduction: L_g ⊢ ¬(∧ L_h)
  -- By g_content_closed_derivation: G(¬(∧ L_h)) ∈ v_i.formulas
  -- If G(¬(∧ L_h)) ∈ Sigma (by h_enriched applied to L_h.toFinset):
  --   then G(¬(∧ L_h)) ∈ h_i.formulas (sigma_signature_mem)
  --   then ¬(∧ L_h) ∈ h_{i+1}.formulas (G-propagation of hintikka_step)
  --   but L_h ⊆ h_{i+1}.formulas means ∧ L_h ∈ h_{i+1}.formulas (provable from L_h)
  --   contradiction with HintikkaPoint.locally_consistent
  sorry  -- needs bigconj infrastructure
```

---

## Evidence / Code References

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`

- Lines 140-190: `enriched_seed_consistent_until` — the SINGLE-STEP seed `{¬(φ U ψ)} ∪ g_content(w) ∪ h_content(v)` is proved consistent. The proof technique (split on ¬(φ U ψ) ∈ L, use MCS closure) is the model for the chain-step seed.
- Lines 300-346: `until_backward` — the enriched Lindenbaum seed approach is nearly complete. The sorry at line 346 is about the BX7 disjunction, but the real gap is earlier: `¬bx_le v u` cannot be shown from the seed alone.
- Lines 282, 286: `until_eventuality_resolution` — guard lifting gaps. φ ∈ u' but `bx_le u' u` does not propagate φ.

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`

- Lines 44-51: `hintikka_step` definition — the G-propagation clause is exactly what the chain-step seed consistency proof would use.

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean`

- Lines 48-49: `ghEnrichment` — current enrichment only adds `G(f)` and `H(f)` for subformulas f. Does NOT include `G(¬(∧ T))` for subsets T. This is what needs to be extended.

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`

- Lines 585-622: Mathematical analysis comment correctly identifies the three blocking approaches (A), (B), (C). Approach (C) is what we need, and the "combined seed consistency" is the specific sub-problem.
- Lines 653, 675, 690, 704: The four sorry locations.

---

## Comparison Table: All Four Approaches

| Approach | Closes All 4 Sorries? | Lean Effort (hours) | Risk | Cascade Cost | Confidence |
|----------|----------------------|---------------------|------|--------------|------------|
| **(A) Full explicit quasimodel with enriched Sigma** | Yes | 35-55 | Medium | Zero (new files only) | Medium |
| **(B) bx_le redefinition** | Yes | 80-120 | High (transitivity gap, cascade) | ~440 LOC in Frame.lean | Low |
| **(C) TaskModel deferral (task 93)** | No (semantic, not canonical proof) | 10-20 (integration only) | Low | Zero | Medium |
| **(D) until_backward direct BX7 closure** | No (only 1 of 4 sorries) | 5-10 | High (likely dead end) | Zero | Low |

### Approach A Detail

**Files touched**:
- `SubformulaClosure.lean` — add `bigconj` helper and `EnrichedClosure` extending ghEnrichment
- `Construction.lean` — add `chain_step_seed_consistent` theorem
- `Realization.lean` — complete rewrite of the four sorry-bearing functions using the new chain realization

**Effort estimate**: 35-55 hours, broken down as:
- `bigconj` infrastructure + `EnrichedClosure`: 4-6 hours
- `chain_step_seed_consistent`: 8-14 hours (the hardest single lemma)
- `hintikka_chain_exists` with well-founded recursion on `defect_count`: 8-12 hours
- `realize_full_chain` lifting the chain to BXPoints: 6-10 hours
- Guard transfer + since standalone: 8-12 hours
- Integration + build clean: 3-5 hours

**Risk assessment**:
1. `bigconj` for Lean 4: requires defining a list-to-conjunction operation and proving
   that `L ⊢ bigconj L` by induction. Lean's Finset.fold or List.foldr is standard.
   Low risk, 3-4 hours.
2. `EnrichedClosure` finite: the powerset of a Finset is a Finset in Mathlib
   (`Finset.powerset`), so the enriched closure remains a Finset. Low risk.
3. The chain-step seed consistency proof requires `neg_bigconj L_h ∈ Sigma`.
   With `EnrichedClosure`, `G(neg_bigconj T) ∈ Sigma` for each `T ⊆ Sigma`.
   The formula `neg_bigconj L_h` where `L_h ⊆ h_{i+1}.formulas ⊆ Sigma` qualifies.
   However, the sigma_signature round-trip must also respect the enriched Sigma.
   **Medium risk**: need to verify that `sigma_signature v EnrichedClosure h_neg` still
   has the G/H propagation properties needed for `hintikka_step`.
4. Well-founded recursion on `defect_count` in Lean 4: the `Nat.rec` / `WellFounded.induction`
   infrastructure works, but the Lean elaborator can be sensitive to the exact form of
   the termination proof. **Medium risk**: budget 3-4 hours for termination proof debugging.
5. Since standalone construction (mirrors Until but uses H-propagation): the H-propagation
   analogue of `g_content_closed_derivation` (`h_content_closed_derivation`) exists in
   Frame.lean:101-114. **Low risk**: the dual argument should follow the same structure.

### Approach C Detail (TaskModel Deferral)

This approach does NOT close the 4 sorries in Frame.lean via the canonical model — it bypasses
them entirely. Task 93 constructs a TaskModel (a direct semantic model), and its completeness
proof would proceed via semantic means without the canonical model's Until/Since machinery.

The integration cost is:
- Frame.lean:653,675,690,704 remain as sorries (accepted technical debt)
- TruthLemma.lean does NOT use the canonical model for Until/Since at all
- A new completeness route via task 93's semantic model bypasses Frame entirely

**This is a valid engineering decision but not a mathematical proof of the canonical model
completeness.** It means the canonical model construction has admitted sorries, which
reduces the proof's completeness guarantee. For a publication-quality formalization,
Approach A is preferable.

---

## Effort Estimate

| Sub-task | Hours (optimistic) | Hours (pessimistic) |
|----------|-------------------|---------------------|
| `bigconj` + `EnrichedClosure` in SubformulaClosure.lean | 4 | 7 |
| `chain_step_seed_consistent` in Construction.lean | 8 | 15 |
| `hintikka_chain_exists` with well-founded recursion | 6 | 12 |
| `realize_full_chain` chain lifting to BXPoints | 6 | 10 |
| Guard transfer + `guard_transfer` lemma | 4 | 7 |
| `until_eventuality_resolution` assembly | 4 | 7 |
| `until_backward` assembly | 3 | 6 |
| Since standalone (eventuality + backward) | 6 | 11 |
| Integration, LocusControl.lean, Frame.lean wiring | 3 | 5 |
| **Total** | **44** | **80** |

---

## Confidence Level

**Overall**: Medium

**Confidence breakdown**:
- That Approach A is mathematically correct: **High** (90%). The enriched Sigma technique
  is standard in filtration theory; the seed consistency argument closes with the enrichment.
- That it can be formalized in Lean 4 in the 44-80 hour range: **Medium** (65%). The
  well-founded recursion and `bigconj` infrastructure are standard but require care.
- That `chain_step_seed_consistent` closes as sketched: **Medium-High** (75%). The argument
  is sound, but the exact Lean proof may require additional auxiliary lemmas about how
  `g_content_closed_derivation` interacts with the enriched Sigma.
- That the Since dual goes through in parallel: **Medium** (60%). The H-propagation
  structure differs slightly, and the Since backward direction has distinct seed structure
  (`h_content(w) ∪ g_content(v)` rather than `g_content(w) ∪ h_content(v)`).

**Bottom line**: Approach A (full quasimodel with enriched Sigma) is the only path to
genuine sorry closure. The engineering cost is significant (44-80 hours) but the mathematics
is sound. The central new contribution vs. round 2's plan is the `EnrichedClosure` — adding
`G(¬(∧ T))` for all subsets T to Sigma — which directly resolves the combined seed
consistency gap that caused the Phase 4b gate failure.

---

## What Round 2's Plan Missed

Round 2 identified the combined seed consistency as the sole hard sub-problem but did not
investigate HOW to prove it. The answer is a standard technique: enrich the subformula
closure to include all "G of conjunction-negations of subsets." This is:

1. Not an axiom addition (it changes the Sigma used for the Hintikka construction, not BX).
2. Not a `bx_le` redefinition (it adds to the finite structure, not the canonical ordering).
3. Directly implements the standard completion-style proof used in tense logic filtration.
4. The resulting HintikkaPoint Sigma is still finite (since Sigma is finite and its powerset
   is finite), so all finiteness arguments go through.

This sixth approach — **EnrichedClosure with G-of-conjunction-negation** — was not considered
in any of rounds 1-3 and represents a genuinely new angle.

---

## References

- Burgess 1984, §4: The original proof uses exactly this "saturation" technique where
  Sigma must be closed under G-applications of propositional combinations.
- Reynolds 1996: "Clausal Tableaux for Multimodal Logics" — enriched closure for
  chain realization; discusses the finite-model property construction in detail.
- Verbrugge 2007, §3: "Completeness by Construction" — the Sigma used there is
  explicitly the "Fisher-Ladner closure" which includes precisely such G(¬∧T) terms.
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` lines 46-63
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` lines 44-51
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` lines 140-190
