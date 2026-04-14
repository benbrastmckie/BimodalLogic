# Teammate A Findings: Quasimodel FMCS Adapter Analysis

## Key Findings

1. **`hintikka_step_g_prop` covers SubformulaClosure-parameterized G-formulas only** — it proves `G(χ) ∈ h₁.formulas → χ ∈ h₂.formulas` for ANY `χ` (not scoped to `SubformulaClosure`), but the Hintikka points are parameterized by `Sigma`, and `h₁.formulas ⊆ Sigma`. So in practice it covers all G-formulas that fit in Sigma.

2. **`Construction.lean` produces `HintikkaRawChain Sigma` with `ChainWitnessed` property** — the main export is `hintikka_chain_exists`, an existence theorem returning `∃ c : HintikkaRawChain Sigma, c.head = h0 ∧ ψ ∈ c.last.formulas ∧ ChainWitnessed c`.

3. **The quasimodel chain infrastructure is complete but disconnected from `int_chain`** — all the Hintikka-level machinery (oracle, chain existence, BXPoint witnessing) is in place. What is missing is a bridge from `HintikkaRawChain` to a monotone sequence `Int → Set Formula` that can serve as an `FMCS Int`.

4. **Both Until (forward) and Since (backward) defect infrastructure exists** — `sinceDefectSet`, `since_defect_count`, `hintikka_step_target_decrease_since`, and `SinceHintikkaStepOracle` are all mirrored for the Since direction.

5. **`deferralClosure` is currently `baseDeferralClosure`** — it does NOT include `(⊤ U ψ)` or `(⊤ S ψ)` terms. Adding Until/Since deferral requires switching to `extendedDeferralClosure`, which adds `untilDeferralSet` and `sinceDeferralSet`.

6. **The sorries at lines 518, 525 (`forward_F`, `backward_P`) and 649, 655 (`restricted_buc`, `restricted_fuc`) are architecturally separate** — the tc sorries need a functioning `int_chain` with F-persistence. The buc/fuc sorries need the Until/Since interval guard, which requires a different proof structure entirely.

---

## Detailed Analysis

### Q1: Exact type signature of `hintikka_step_g_prop`

**Location**: `Quasimodel/Realization.lean:419–424`

```lean
theorem hintikka_step_g_prop
    {Sigma : Finset Formula} {h₁ h₂ : HintikkaPoint Sigma}
    (h_step : hintikka_step h₁ h₂) {χ : Formula}
    (h_Gχ : Formula.all_future χ ∈ h₁.formulas) :
    χ ∈ h₂.formulas :=
  h_step.1 χ h_Gχ
```

This is the first clause of `hintikka_step`, projected as a lemma. **It covers all formulas in `h₁.formulas` that have the form `G(χ)`**. Since `h₁.formulas ⊆ Sigma`, it effectively covers `G(χ)` when `G(χ) ∈ Sigma`. It does NOT guarantee `G(χ) ∈ h₂.formulas` — only `χ ∈ h₂.formulas`. This is the core G-propagation but **not G-persistence**, which is the critical distinction noted in Realization.lean's Phase 5 obstacle analysis (lines 377–400).

**The obstacle in Realization.lean lines 377–400 is decisive**: G-formulas do not persist through `hintikka_step` because `¬G(χ) ∈ w_{i+1}` is consistent with `χ ∈ h_{i+1}`. So `g_content(v_i) ⊆ w_{i+1}` fails for G-formulas where `G(χ) ∉ Sigma`.

### Q2: What does `Construction.lean` output?

**Primary export** (`Construction.lean:594–659`):

```lean
theorem hintikka_chain_exists
    {Sigma : Finset Formula} {φ ψ : Formula}
    (oracle : HintikkaStepOracle (Sigma := Sigma) φ ψ)
    (h0 : HintikkaPoint Sigma) (w0 : BXPoint)
    (h0_sub : ∀ f ∈ h0.formulas, f ∈ w0.formulas)
    (h_target : Formula.untl φ ψ ∈ h0.formulas) :
    ∃ c : HintikkaRawChain Sigma,
      c.head = h0 ∧ ψ ∈ c.last.formulas ∧ ChainWitnessed c
```

This is an **existence theorem** over `HintikkaRawChain Sigma`, which is:

```lean
structure HintikkaRawChain (Sigma : Finset Formula) where
  points : List (HintikkaPoint Sigma)
  nonempty : points ≠ []
  is_chain : points.IsChain hintikka_step
```

with `ChainWitnessed c = ∀ h ∈ c.points, ∃ w : BXPoint, ∀ f ∈ h.formulas, f ∈ w.formulas`.

**The chain is finite** (a `List`). It proves that given an Until-defect at `h0`, there is a finite chain of Hintikka points ending at a point where `ψ` holds.

### Q3: Interface for a QuasimodelChain-to-FMCS adapter

To use `hintikka_chain_exists` to close `bx_fmcs_forward_F`, the adapter would need to:

**Input**:
- `w : BXPoint` with `F(ψ) ∈ w.formulas`
- The chain `int_chain M₀ h₀ t` which is `w.formulas` at time `t`

**Required proofs to build `v : BXPoint` with `t < v_time` and `ψ ∈ v.formulas`**:

1. From `F(ψ) ∈ w.formulas`, derive `(⊤ U ψ) ∈ w.formulas` via `F_imp_top_until_mcs` (proven at `CanonicalChain.lean:65–72`)
2. Construct `Sigma := enrichedClosure (⊤ U ψ)` (or some appropriate finite closure containing `(⊤ U ψ)`)
3. Construct `h0 := sigma_signature w Sigma h_neg_closed` — project `w.formulas` to Sigma
4. Verify `(⊤ U ψ) ∈ h0.formulas` — follows from `(⊤ U ψ) ∈ Sigma` and `(⊤ U ψ) ∈ w.formulas`
5. Supply a `HintikkaStepOracle` — **this is the critical missing piece**; the oracle must construct `hintikka_step h wh'.point` for each defective `h`, extracting a successor BXPoint from `bx_until_eventuality_resolution` or `bx_forward_witness`
6. Call `hintikka_chain_exists` to get `c : HintikkaRawChain Sigma` with `ψ ∈ c.last.formulas`
7. Extract `c.last`'s BXPoint witness `v` from `ChainWitnessed c`
8. Show `bx_le w v` (from the chain structure and `sigma_le`/`bx_le`)
9. Convert `bx_le w v` + integer chain positions to `t < v_time`

**Critical gap**: Steps 5 and 8–9. The oracle requires constructing a `hintikka_step h wh'.point` from the BX axioms, which requires showing `bx_le w_backing successor`. Step 8–9 require bridging from the abstract `bx_le` ordering on BXPoints to the integer positions in `int_chain`.

### Q4: Backward (Since) defect infrastructure

**YES — full symmetric infrastructure exists**:

- `sinceDefectSet` (`Construction.lean:301–306`)
- `since_defect_count` (`Construction.lean:310`)
- `mem_sinceDefectSet_iff` (`Construction.lean:314–331`)
- `hintikka_step_target_decrease_since` (`Construction.lean:335–356`)
- `SinceDefect` (`Construction.lean:62–63`)

There is also explicit mention of a `SinceHintikkaStepOracle` (referred to in comments at `Construction.lean:692+`). However, I did not find `hintikka_chain_exists_since` as a proven theorem — the Since dual of `hintikka_chain_exists` may not yet be proven. The underlying MCS lemmas for Since (`since_defect_step_phi`, `since_defect_step_P_psi`, etc.) are proven in `DefectChain.lean:107–136`.

### Q5: `deferralClosure` definition and impact of adding `(⊤ U ψ)` targets

**Current definition** (`Syntax/SubformulaClosure.lean:809–810`):

```lean
def deferralClosure (phi : Formula) : Finset Formula :=
  baseDeferralClosure phi
```

where `baseDeferralClosure = closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas`.

This does **NOT** contain Until/Since formulas of the form `(⊤ U ψ)` unless they are subformulas of `phi`. There is an `extendedDeferralClosure` that adds `untilDeferralSet phi` and `sinceDeferralSet phi` (`SubformulaClosure.lean:812–814`).

**What adding `(⊤ U ψ)` for F(ψ)-targets would require**:
- Switch the restricted coherence predicates to use `extendedDeferralClosure` instead of `deferralClosure`
- Or add `(⊤ U ψ)` to `deferralClosure` when `F(ψ) ∈ deferralClosure`
- The `restricted_temporally_coherent` predicate at `TemporalCoherence.lean:295–300` only requires `φ ∈ deferralClosure root` for F(φ)/P(φ); the `(⊤ U ψ)` issue is for the oracle that serves `hintikka_chain_exists`

**Impact assessment**: The sorry-closing approach via quasimodel does not actually require changing `deferralClosure`. The `bx_fmcs_forward_F` sorry needs a proof that `F(ψ) ∈ int_chain M₀ h₀ t → ∃ s > t, ψ ∈ int_chain M₀ h₀ s`. The quasimodel machinery operates entirely at the `BXPoint`/`HintikkaPoint` level and produces a BXPoint `v` with `bx_le w v` and `ψ ∈ v.formulas`. The gap is converting `bx_le w v` to an integer witness `s > t`.

### Q6: How `DefectChain.lean` works and whether it helps

**`DefectChain.lean`** defines:
- `is_until_defect`, `sigma_defect_count` — counts unsatisfied Until-formulas in Sigma at a given BXPoint
- `defect_step_phi` — from `φ U ψ ∈ w` and `ψ ∉ w`: `φ ∈ w`
- `defect_step_F_psi` — from `φ U ψ ∈ w`: `F(ψ) ∈ w` (BX10)
- `defect_step_connect` — from `φ U ψ ∈ w`: `G(P(φ U ψ)) ∈ w` (BX4)
- Symmetric `since_defect_count` and Since variants

**This is the MCS-level defect infrastructure.** It does not directly close the sorries but provides the MCS lemmas that would be consumed by a quasimodel oracle.

**For the sorry sites specifically**:
- `DefectChain.lean` could NOT be used directly for `bx_fmcs_forward_F` because that sorry requires a specific integer `s > t`. `DefectChain.lean` lemmas work in the abstract BXPoint setting.
- The defect chain machinery would be consumed by the `HintikkaStepOracle` implementation that bridges to `bx_until_eventuality_resolution` (already proven in `Frame.lean`).

---

## Recommended Approach

The cleanest path to closing the four sorries is a **two-phase strategy** based on what is already proven:

### Phase A: Close `bx_fmcs_forward_F` and `bx_fmcs_backward_P` (lines 518, 525)

**Key insight**: `bx_until_eventuality_resolution` is already proven (`CanonicalChain.lean:142–147`, delegates to `Frame.lean`). It states:
```lean
∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧ φ ∈ w.formulas
```

The blocking issue is converting `bx_le w v` to an integer `s > t`.

**Recommended approach**: Use `F_imp_top_until_mcs` (line 65 of `CanonicalChain.lean`) + `bx_until_eventuality_resolution` directly, bypassing the quasimodel entirely:

1. From `F(ψ) ∈ int_chain M₀ h₀ t`, get `(⊤ U ψ) ∈ int_chain M₀ h₀ t` via `F_imp_top_until_mcs`
2. Apply `bx_until_eventuality_resolution` to get `v : BXPoint` with `bx_le w v` and `ψ ∈ v.formulas`
3. **The gap**: Show that `v` appears as `int_chain M₀ h₀ s` for some `s > t`

This gap is the reason the sorry is blocked. The `int_chain` is not constructed to include all reachable `BXPoint`s — it only includes the specific points built by `fwd_succ`/`bwd_pred` via the schedule. A `BXPoint v` obtained from `bx_until_eventuality_resolution` is not guaranteed to equal any `int_chain M₀ h₀ s`.

**Real fix required**: The `int_chain` construction must be revised so that F(ψ)-witnessing BXPoints appear as chain members. This means either:
- (a) Building a new chain that explicitly includes eventuality witnesses (replacing the schedule-based approach)
- (b) Proving that `fwd_succ_resolves` eventually resolves every F-formula (requires the schedule surjectivity + F-carry propagation, but the counterexample in CanonicalModel.lean:500–507 shows this fails for the enriched seed)

**The quasimodel approach** would replace the `int_chain` construction entirely with a chain built from `HintikkaRawChain` + realization.

### Phase B: Close `bx_bfmcs_restricted_buc` and `bx_bfmcs_restricted_fuc` (lines 649, 655)

These require proving the Until/Since interval guard conditions:

**`restricted_buc`** (line 649): Given `φ U ψ ∈ subformulaClosure root`, `r ≤ t`, `ψ ∈ chain(r)`, and `∀ u ∈ (t, r], φ ∈ chain(u)` — prove `φ U ψ ∈ chain(t)`.

This follows from BX11 (Until induction): `ψ → φ U ψ` and `(φ ∧ F(φ U ψ)) → φ U ψ`. The proof would proceed backward from `r` to `t` using `psi_imp_until_mcs` at `r` and then inducting. **This is likely provable from existing BX axiom lemmas without any new construction.**

**`restricted_fuc`** (line 655): Given `φ U ψ ∈ subformulaClosure root` and `φ U ψ ∈ chain(t)` — prove `∃ s ≥ t, ψ ∈ chain(s) ∧ ∀ r ∈ [t, s), φ ∈ chain(r)`.

This is the harder direction. It requires extracting a specific integer witness `s`. The `bx_until_eventuality_resolution` gives a BXPoint witness but not an integer index — the same obstacle as `forward_F`.

### Minimum Viable Fix

For the 4 sorries, the dependency order is:
1. `bx_fmcs_forward_F` (line 518) — blocks `bx_bfmcs_restricted_tc` which blocks `bx_countermodel`
2. `bx_fmcs_backward_P` (line 525) — same dependency path
3. `bx_bfmcs_restricted_buc` (line 649) — also blocks `bx_countermodel`
4. `bx_bfmcs_restricted_fuc` (line 655) — also blocks `bx_countermodel`

**`restricted_buc` may be closeable independently** using BX axiom lemmas (BX11/BX8 induction backward from the witness). The formula `φ U ψ ∈ fam.mcs t` follows from `ψ ∈ fam.mcs r` (r ≥ t, `psi_imp_until_mcs`) and the guard `φ ∈ fam.mcs u` for all intermediate `u`. This is a pure axiom application, no chain construction needed.

Specifically at `CanonicalModel.lean:649`, inside the proof body after `intro t φ ψ _h_sub ⟨r, h_le, h_psi, h_guard⟩`:
- The hypothesis `h_le : t ≤ r` means we have an integer interval `[t, r]`
- At `r`: `ψ ∈ chain(r)` → `φ U ψ ∈ chain(r)` (BX8)
- Backward induction from `r` to `t+1`: at each step `u`, if `φ U ψ ∈ chain(u+1)` and `φ ∈ chain(u)`, then `φ U ψ ∈ chain(u)` via the Until induction axiom (BX11)
- Key lemma needed: `h_content(chain(u+1)) ⊆ chain(u)` (proven: `int_chain_h_content`)

This approach for `restricted_buc` would use `int_chain_h_content` and BX11. **File location for BX11**: search `Axiom.until_intro` or `Axiom.step_intro_until` in the axiom definitions.

---

## Confidence Level

**Medium** for the overall architectural picture.

**High** for the specific findings:
- `hintikka_step_g_prop` signature is exact and confirmed
- `Construction.lean` output type is confirmed (`hintikka_chain_exists`)
- The quasimodel infrastructure is functionally complete but disconnected from `int_chain`
- Both Until and Since defect discharge machinery exist symmetrically
- `deferralClosure` does not include Until/Since formulas by default

**Low** for the actionable implementation path:
- The core obstacle (BXPoint witnesses not being integer-indexed chain members) remains unresolved
- `restricted_buc` may be independently closeable but requires finding the BX11 axiom name
- The quasimodel-to-FMCS adapter would require significant new construction: a new `FMCS` definition backed by the quasimodel chain, not the current schedule-based `int_chain`
