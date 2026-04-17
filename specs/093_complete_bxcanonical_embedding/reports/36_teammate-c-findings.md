# Teammate C: Critic - Mathematical Soundness Audit

## BX12 Reduction Audit

### Verdict: SOUND (as an axiom step) but INSUFFICIENT for the full sorry closure

**What BX12 actually gives**: `F_until_equiv` at the axiom level is:
```
F(φ) → (⊤ U φ)
```
where `⊤ = ⊥ → ⊥`. At the MCS level, `F_imp_top_until_mcs` (CanonicalChain.lean:65-72)
proves: if `F(ψ) ∈ w.formulas` then `(⊤ U ψ) ∈ w.formulas`.

**The claim**: Use BX12 to reduce F-coherence (`forward_F`) to Until-coherence
(`forward_until_since_coherent`). If we prove Until coherence for the quasimodel
chain, then BX12 says F(ψ) implies (⊤ U ψ), and Until coherence for (⊤ U ψ)
gives a witness.

**Critical check: Is `⊤ U ψ` in `subformulaClosure(root)`?**

Examining `restricted_forward_until_since_coherent` in TemporalCoherence.lean (lines 535-544):
```lean
def BFMCS.restricted_forward_until_since_coherent (B : BFMCS D) (root : Formula) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.untl φ ψ ∈ Bimodal.Syntax.subformulaClosure root →
      Formula.untl φ ψ ∈ fam.mcs t → ...)
```

**FLAW IDENTIFIED**: `restricted_forward_until_since_coherent` quantifies over
`Formula.untl φ ψ ∈ subformulaClosure root`. The formula `(⊤ U ψ)` where
`⊤ = ⊥ → ⊥` is almost certainly NOT in `subformulaClosure(root)` unless `root`
already mentions `⊤ U ψ` explicitly. The subformula closure of `root` only contains
subformulas of `root` and their negations — not arbitrary syntactic variants like
`(⊥ → ⊥) U ψ`.

**Consequence**: Even if Until coherence is proved for all formulas in
`subformulaClosure(root)`, the BX12 bridge `F(ψ) → (⊤ U ψ)` produces a formula
`(⊤ U ψ)` that lies OUTSIDE the scope of `restricted_forward_until_since_coherent`.

**What `dd_bfmcs_restricted_fuc` actually needs to prove**
(RootScopedChain.lean:1524-1527):
```lean
theorem dd_bfmcs_restricted_fuc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (root : Formula) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_forward_until_since_coherent root := by
  sorry
```

For the BX12 bridge to work here, we would need either:
1. A version of restricted coherence covering `extendedDeferralClosure(root)` (which
   might include `⊤ U ψ` via `untilDeferralSet`), or
2. The `restricted_temporally_coherent` path instead (proving `forward_F` directly),
   or
3. Showing that `⊤ U ψ ∈ subformulaClosure(root)` whenever `F(ψ)` is relevant.

**Checking extendedDeferralClosure**: `extendedDeferralClosure = baseDeferralClosure ∪ untilDeferralSet ∪ sinceDeferralSet`. If `untilDeferralSet` includes `(⊤ U ψ)` formulas, the BX12 bridge might work via `restricted_temporally_coherent` (which uses `deferralClosure`, not `subformulaClosure`). However, `restricted_forward_until_since_coherent` specifically uses `subformulaClosure`, NOT `deferralClosure`. This is a structural mismatch.

**Bottom line on BX12**: The axiom itself is sound, and the MCS-level lemma
`F_imp_top_until_mcs` is proved. However, the proposed reduction from `forward_F` to
Until coherence via BX12 is blocked because `(⊤ U ψ)` falls outside the scope of
`restricted_forward_until_since_coherent`. The BX12 bridge addresses the wrong sorry
site — `dd_bfmcs_restricted_fuc` needs Until coherence for subformulas of `root`,
while BX12 produces Until formulas with `⊤` guard that are not subformulas of `root`.

---

## Quasimodel Bridge Feasibility Audit

### Verdict: BLOCKED by multiple unresolved gaps

### Gap 1: Finite chain vs. Int-indexed chain

The quasimodel in `Construction.lean` produces FINITE sequences of `HintikkaPoint`s
(`List (HintikkaPoint Sigma)`). The sorry sites are in `dd_bfmcs` which uses
`dd_fmcs : FMCS Int` — an **Int-indexed** family of MCS. Bridging these requires
extending a finite chain to an infinite Int-indexed structure.

The natural extension choices are:
- **Repetition at ends**: Repeat the first/last Hintikka point. But this must satisfy
  G-propagation: `G(χ) ∈ h → χ ∈ h_next`. In the repeated-last case, `h_last → h_last`
  is fine since `G(χ) ∈ h_last → χ ∈ h_last` (reflexivity via BX1). But this gives a
  CONSTANT chain past the endpoint, and `forward_F` would then require `ψ ∈ h_last`
  for all `F(ψ) ∈ h_last`, which is BX1 (reflexivity of G gives `G(¬ψ) → ¬ψ`).
  This doesn't generally work.
- **Omega repetition**: Cycle through the finite chain infinitely. The `hintikka_step`
  requires both G-propagation AND H-backward propagation between consecutive steps.
  At the wrap-around point `h_last → h_0`, H-backward (`H(χ) ∈ h_0 → χ ∈ h_last`)
  is not guaranteed since the finite chain has no memory of the start.

**This gap has no obvious fix**. The finite quasimodel and the Int-indexed FMCS are
fundamentally different structures, and no extension produces a valid `TemporalCoherentFamily`.

### Gap 2: HintikkaPoint to MCS Lindenbaum lift

`HintikkaPoint Sigma` is a finite signature-based structure (a `Finset Formula`), not
a full MCS (a `Set Formula`). The sorry sites require `SetMaximalConsistent` sets.
Lifting a HintikkaPoint to an MCS requires Lindenbaum extension, which is non-constructive.

**Critical question**: Does the Lindenbaum lift preserve the `hintikka_step` properties?

- `hintikka_step h1 h2` requires G-propagation: `G(χ) ∈ h1 → χ ∈ h2`.
- After Lindenbaum extension to MCS `M1, M2`, we need: `G(χ) ∈ M1 → χ ∈ M2`,
  i.e., `g_content(M1) ⊆ M2`, i.e., `bx_le M1 M2`.
- This holds only if `g_content(M1) ⊆ M2`, which requires that the Lindenbaum
  extension of `h2` (seed) contains `g_content(M1)`.
- BUT `g_content(M1)` depends on the FULL Lindenbaum extension M1, which includes
  formulas not in `h1`. The HintikkaPoint only knows about `g_content(h1.formulas)`,
  which is smaller than `g_content(M1)`.

**This creates a circularity**: proving `bx_le M1 M2` requires knowing `M1` first,
but `M2`'s seed must be chosen using `M1`. The construction would need to be a
simultaneous Lindenbaum extension, which is not how the existing infrastructure works.

### Gap 3: G-persistence obstruction for the extended Int-chain

The `hintikka_step` only gives: `G(χ) ∈ h1 → χ ∈ h2` (one step forward).
It does NOT give: `G(χ) ∈ h2`. So G-formulas are NOT persistent across the
HintikkaPoint chain. This is essential for the MCS-level `g_content` propagation
needed to construct `FMCS Int`.

Specifically: after Lindenbaum extension, G-formulas in `M1` persist to `M2` only
if `g_content(M1) ⊆ M2`. But `g_content` includes `G(G(χ))` etc. The Hintikka step
only transfers one "layer" of G.

### Gap 4: HintikkaStepOracle construction

Construction.lean acknowledges (lines 88-107) that the quasimodel construction relies
on existing BXPoint infrastructure rather than directly constructing a `HintikkaStepOracle`.
The HintikkaPoint chain is described as existing "at the MCS level" and "projected down."
This means the quasimodel bridge would need to work in the OPPOSITE direction: lift
up from HintikkaPoints to MCS, rather than project down.

No code in Realization.lean or Construction.lean actually constructs a
`QuasimodelChain` as a concrete Lean object. The functions `until_eventuality_resolution`
and `since_eventuality_resolution` in Realization.lean simply delegate to
`Frame.lean`'s `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution`.

**This means the quasimodel infrastructure is NOT actually sorry-free** — it relies
on the Frame.lean eventuality resolution functions, which were themselves noted as
having "chain-based completeness" as the resolution path.

### Gap 5: Backward direction (Since/P-coherence)

The quasimodel in Construction.lean handles the FORWARD direction (Until). The
sorry sites include `dd_fmcs_backward_P` (line 1463) and `dd_bfmcs_restricted_buc`
(line 1519-1522), which require backward P-coherence (Since/P operators). The
quasimodel `SinceDefect` type is defined but the backward construction is not
explicitly present in the accessible Construction.lean code. A backward quasimodel
would require analogous infrastructure.

---

## Hidden Circularity Check

### Circularity 1: G-content and Lindenbaum seeding

As noted above: constructing the seed for `M_{i+1}` from the Lindenbaum lift of `h_{i+1}`
requires `g_content(M_i)`, but `M_i` is itself a Lindenbaum extension. This is
circular unless both extensions are constructed simultaneously with compatible seeds.

### Circularity 2: restricted_temporally_coherent and forward_F dependency

`dd_bfmcs_restricted_tc` (line 1516) has signature:
```lean
theorem dd_bfmcs_restricted_tc ... (h_sub : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ sigma_list) :
    (dd_bfmcs ...).restricted_temporally_coherent root
```

`restricted_temporally_coherent` requires `forward_F` for all `φ ∈ deferralClosure(root)`.
The sorry site `rr_fwd_chain_forward_F` (line 1386) is exactly `forward_F`. So proving
`dd_bfmcs_restricted_tc` requires proving `forward_F`, which is the depth-0 base case sorry.

There is NO circularity in the logical dependency graph — `restricted_temporally_coherent`
→ `forward_F` is a valid dependency direction. But it means all three restricted
coherence theorems ultimately reduce to solving the `forward_F` depth-0 base case.

### Circularity 3: Would Until coherence from quasimodel give temporal coherence?

Suppose we proved `restricted_forward_until_since_coherent`. Would this give `forward_F`
via BX12?

The proposed reduction: `F(ψ) → (⊤ U ψ)` (BX12), then Until coherence for `(⊤ U ψ)`
gives witness `s ≥ t` with `ψ ∈ fam.mcs s`.

But `restricted_forward_until_since_coherent` requires `(⊤ U ψ) ∈ subformulaClosure(root)`.
This is NOT satisfied unless root mentions `⊤ U ψ`. So the reduction is circular in
the sense that it requires a stronger form of Until coherence than what is provided.

---

## Sorry Site Compatibility Check

The three sorry sites at lines 1516-1527:

### Sorry 1: `dd_bfmcs_restricted_tc` (temporal coherence)
- Requires: `forward_F` and `backward_P` for all `φ ∈ deferralClosure(root)`
- `forward_F` = the depth-0 base case sorry (line 1413)
- `backward_P` = `dd_fmcs_backward_P` sorry (line 1464)
- **Both are blocked** by the BX11 perpetual deferral obstruction

### Sorry 2: `dd_bfmcs_restricted_buc` (backward Until/Since coherence)
- Requires: Given witness `(ψ at s, φ on guard)`, derive `φ U ψ ∈ fam.mcs t`
- `UntilSinceCoherence.lean` shows this reduces to a "step transfer" property
- Step transfer: `(φ U ψ) ∈ fam.mcs(r+1) ∧ φ ∈ fam.mcs(r) → (φ U ψ) ∈ fam.mcs(r)`
- For `dd_fmcs`, the chain uses `fwd_succ` (or its enriched variant). Does `fwd_succ`
  provide the step transfer?
- `fwd_succ` uses `g_content` propagation. `(φ U ψ) ∈ fam.mcs(r+1)` does NOT imply
  `G(φ U ψ) ∈ fam.mcs(r)` in general, so backward induction via `g_content` fails.
- **STATUS**: This sorry appears to be ALSO blocked unless the chain construction is
  specifically designed to support step transfer.

### Sorry 3: `dd_bfmcs_restricted_fuc` (forward Until/Since coherence)
- Requires: `(φ U ψ) ∈ fam.mcs t → ∃ s ≥ t, ψ ∈ fam.mcs s ∧ ∀ r ∈ [t,s), φ ∈ fam.mcs r`
- This is essentially the `forward_F`-for-Until version
- TemporalCoherence.lean (lines 487-494) states: "forward Until/Since (conjuncts 1 and 3)
  is blocked by a fundamental incompatibility between Lindenbaum extension freedom and
  Until formula persistence"
- **STATUS**: BLOCKED by the same fundamental obstruction as forward_F

### Two additional sorry sites (depth-0 forward_F and backward_P, lines 1413 and 1463-1464):

- `rr_fwd_chain_forward_F` depth-0 base case (line 1413): The irreducible BX11 perpetual
  deferral obstruction. The enriched chain preserves F(ψ) but cannot force ψ ∈ chain(s).
- `dd_fmcs_backward_P` (line 1463): symmetric obstruction for P-direction.
- `defect_fwd_chain_forward_F` (line 2196): `defect_fwd_chain` has an additional sorry.
- `defect_bwd_chain_backward_P` (line 2288): parallel backward sorry.

**Total: 8 sorry sites, all fundamentally blocked by the same core obstacle: the
Lindenbaum extension freedom allows choosing against any specific formula.**

---

## Unidentified Obstacles

### Obstacle 1: The `defect_fwd_chain` vs `rr_fwd_chain` duality

There are TWO different forward chains in the file:
1. `rr_fwd_chain` (round-robin): cycles through all sigma formulas
2. `defect_fwd_chain` (defect-driven): schedules based on a fixed defect list

Both have their own `forward_F` sorry. The plan in the file header (lines 7-37) says
the key insight is F-preservation via enriched step. But as noted in lines 1280-1284:
"All 30 sections confirm that the round-robin chain with enriched_fwd_step CANNOT prove
forward_F." The `defect_fwd_chain` is a separate attempt but shares the same obstruction.

### Obstacle 2: The dd_countermodel construction already invokes the sorry sites

`dd_countermodel` (line 1531-1557) calls `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`,
and `dd_bfmcs_restricted_fuc` directly. This is the top-level theorem. The sorry sites
are IN the proof path to the main theorem — they are not auxiliary lemmas. Any solution
must satisfy ALL three simultaneously.

### Obstacle 3: sigma_list closure requirement vs. `⊤`

`rr_fwd_chain_forward_F` requires:
```lean
(h_closed : ∀ χ : Formula, Formula.some_future χ ∈ sigma_list → χ ∈ sigma_list)
```
This is satisfied by `extendedDeferralClosure`. But `(⊤ U ψ)` in sigma_list would
require `⊤ = ⊥ → ⊥ ∈ sigma_list` (as a subformula of `⊤ U ψ`). Since `⊤` is not
generally in `deferralClosure(root)` for arbitrary roots, the BX12 approach would
require extending sigma_list to include these `⊤ U ψ` formulas explicitly.

### Obstacle 4: `dd_bfmcs_restricted_tc` has an extra hypothesis not matched by chain

```lean
theorem dd_bfmcs_restricted_tc ...
    (h_sub : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ sigma_list) :
```
This requires that `sigma_list` contains `deferralClosure(root)`. In `dd_countermodel`,
`sigma_list = (extendedDeferralClosure φ).toList`. Since `deferralClosure ⊆ extendedDeferralClosure`
(SubformulaClosure.lean:826-830), this hypothesis IS satisfied.

However, for forward_F to help, we need `ψ ∈ sigma_list` (i.e., `ψ ∈ extendedDeferralClosure`).
F-obligations for formulas OUTSIDE sigma_list are unconstrained. This is coherent with
the restriction to `deferralClosure(root)` — but it means the quasimodel bridge must
handle ALL formulas in `deferralClosure(root)`, including those with no obvious
Until-formula connection.

---

## Counterexamples

### Counterexample 1: BX12 bridge scope failure

Let `root = p` (an atom). Then:
- `subformulaClosure(p) = {p, ¬p}`
- `deferralClosure(p) ⊇ {p, ¬p}` plus deferral formulas

Now suppose `F(p) ∈ fam.mcs t`. BX12 gives `(⊤ U p) ∈ fam.mcs t`.
`restricted_forward_until_since_coherent` would need `(⊤ U p) ∈ subformulaClosure(p)`.
But `subformulaClosure(p) = {p, ¬p}` and `(⊤ U p) ∉ {p, ¬p}`. So BX12 does NOT
let us apply `restricted_forward_until_since_coherent` to get the witness.

This confirms: the BX12 reduction CANNOT work through `restricted_forward_until_since_coherent`.

### Counterexample 2: enriched_fwd_step perpetual deferral

Consider `sigma_list = [ψ₁, ψ₂]` and `F(ψ₁), F(ψ₂) ∈ M₀`.

At each enriched step, BX11 gives three cases. The Lindenbaum extension can always
choose to put `G(¬ψ₁)` in the extension (killing `F(ψ₁)`) while resolving `ψ₂`.
This is the perpetual deferral: ψ₁ is never resolved because the Lindenbaum extension
ALWAYS has the freedom to choose `G(¬ψ₁)` as long as `F(ψ₁)` remains. This is
consistent when the MCS "happens to" be on a branch of the non-standard model where
ψ₁ never occurs.

The enriched step guarantees that AT EACH STEP, some formula is resolved (the
`enriched_fwd_fold_with_witness` theorem). But "some formula" can be the same formula
every time. The round-robin scheduling does NOT force a particular formula to be
resolved at its scheduled step — it schedules WHEN to try, but the Lindenbaum
extension can always defer.

### Counterexample 3: Backward Until step transfer failure

Suppose chain uses `fwd_succ` with seed `g_content(M)`. Given `(φ U ψ) ∈ chain(r+1)`,
we need `(φ U ψ) ∈ chain(r)`. This requires `G(φ U ψ) ∈ chain(r)` (so that
`g_content(chain(r))` passes it forward). But `G(φ U ψ) ∈ chain(r)` is NOT
equivalent to `(φ U ψ) ∈ chain(r+1)` in general — it's a strictly stronger claim.
The chain construction does not preserve G-formulas for arbitrary Until formulas.

---

## Overall Assessment

The "quasimodel bridge" approach (~800-1200 LOC) has **at least five independent
blocking issues**:

1. **BX12 scope mismatch**: `(⊤ U ψ)` is not in `subformulaClosure(root)`, so
   `restricted_forward_until_since_coherent` cannot be applied via BX12.

2. **Finite-to-infinite extension failure**: The quasimodel produces a finite chain;
   extending to `Int` with valid `hintikka_step` propagation has no obvious solution.

3. **HintikkaPoint-to-MCS Lindenbaum gap**: The seed for M_{i+1}'s Lindenbaum
   extension depends on `g_content(M_i)`, which depends on M_i already being
   Lindenbaum-extended — a circularity.

4. **G-persistence loss**: `hintikka_step` propagates G-formulas one step but does
   not guarantee they persist in the lifted MCS chain.

5. **Quasimodel infrastructure is not actually sorry-free**: Realization.lean's
   functions delegate to Frame.lean eventuality resolution, which has its own
   chain-based completeness dependency.

**Additionally**, even if the quasimodel bridge were complete, it would address:
- Forward Until/Since (via quasimodel witnessing): POSSIBLY addressable
- Forward F via BX12: BLOCKED by scope mismatch
- Backward P/Since: NOT addressed by forward quasimodel
- Backward Until step transfer: NOT addressed by quasimodel

The sorry sites split into two independent axes:
- `dd_bfmcs_restricted_tc` requires `forward_F` AND `backward_P` (both blocked)
- `dd_bfmcs_restricted_fuc` requires forward Until witnessing (blocked by Lindenbaum freedom)
- `dd_bfmcs_restricted_buc` requires step transfer (not provided by any current construction)

**The core mathematical problem is the same in all cases**: the Lindenbaum extension
for each chain step has freedom to contradict any specific formula, and no
finite/counting argument prevents perpetual deferral because the chain is infinite
and the extension makes a binary choice at each step.

---

## Confidence Level

**HIGH** — findings are based on:
1. Direct reading of all relevant Lean files (no inference beyond what is written)
2. Type signatures of all three sorry sites verified
3. `restricted_forward_until_since_coherent` definition checked against
   `subformulaClosure` (not `deferralClosure`)
4. Quasimodel Construction.lean structure confirmed: no `QuasimodelChain` term
   is actually constructed; functions delegate to Frame.lean
5. The BX12 counterexample (root = atom p) is elementary and decisive
6. The finite-to-infinite extension problem is a type-level incompatibility,
   not a proof technique issue

**The quasimodel bridge approach should be classified as BLOCKED unless a solution
to all five identified gaps is presented simultaneously.**
