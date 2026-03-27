# Teammate C: Root Cause Algebraic Analysis

**Task**: 58 - Wire completeness to FrameConditions
**Focus**: Algebraic root cause analysis of the completeness wiring obstruction
**Date**: 2026-03-27
**Agent**: Teammate C (Root Cause Algebraic Analysis)

---

## The Mathematical Problem (Precise Statement)

### The Three Target Sorries

In `Theories/Bimodal/FrameConditions/Completeness.lean`:

| Theorem | Line | Statement |
|---------|------|-----------|
| `dense_completeness_fc` | 115 | `DenseCompletenessStatement φ`: valid over all dense D → provable |
| `discrete_completeness_fc` | 158 | `DiscreteCompletenessStatement φ`: valid over all discrete D → provable |
| `bundle_validity_implies_provability` | 186 | `valid_over Int φ → Nonempty ([] ⊢ φ)` |

The first two delegate to `completeness_over_Int`, which itself delegates to `bundle_validity_implies_provability`. So all three reduce to:

**Core Sorry**: Prove that if `valid_over Int φ` holds (i.e., φ is true in ALL
`TaskFrame Int` models, at ALL times, in ALL shift-closed Omega, at ALL histories),
then `[] ⊢ φ`.

### What "valid_over Int" Requires

By definition (`FrameConditions/Validity.lean:53`):
```
valid_over Int φ ≡
  ∀ (F : TaskFrame Int) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : Int),
    truth_at M Omega τ t φ
```

This is a universal statement over all `TaskFrame Int` models. Completeness says
this implies `[] ⊢ φ`.

### The Algebraic Infrastructure That IS Sorry-Free

The following theorems have NO sorry (verified in prior research):

- `construct_bfmcs_bundle M0 h_mcs : BFMCS_Bundle` — builds a bundle from any MCS
- `boxClassFamilies_bundle_temporally_coherent` — bundle-level F/P coherence
- `mcs_neg_gives_countermodel` — if `φ.neg ∈ M`, then `φ ∉ eval_family.mcs 0`
- `bundle_completeness_contradiction` — if `{φ.neg}` is consistent, the bundle exists
- `not_provable_implies_neg_consistent` — `⊬ φ` implies `{φ.neg}` consistent
- `parametric_canonical_truth_lemma` — FULL bidirectional truth lemma for `BFMCS D`
- `parametric_shifted_truth_lemma` — truth lemma for `ShiftClosedParametricCanonicalOmega`

### The Precise Gap

The `parametric_shifted_truth_lemma` requires `B : BFMCS D` with `B.temporally_coherent`.
The `construct_bfmcs_bundle` produces `BFMCS_Bundle` (a DIFFERENT type) with
`BundleTemporallyCoherent`.

The two types are NOT the same:

```
BFMCS D (in Bundle/BFMCS.lean):
  temporally_coherent : ∀ fam ∈ families,
    (forward_F: ∃ s > t in fam.mcs s) ∧
    (backward_P: ∃ s < t in fam.mcs s)

BFMCS_Bundle (in Algebraic/UltrafilterChain.lean):
  BundleTemporallyCoherent: ∀ fam ∈ families,
    F(φ) ∈ fam.mcs t → ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s
```

**Key distinction**:
- `BFMCS.temporally_coherent` requires the witness s to be in the **same** family: `φ ∈ fam.mcs s`
- `BundleTemporallyCoherent` allows the witness to be in a **different** family: `φ ∈ fam'.mcs s`

The `parametric_shifted_truth_lemma` calls `temporal_backward_G`, which calls `fam.forward_F`
to get a witness s with `φ.neg ∈ fam.mcs s` (same family). Without same-family coherence,
the contradiction in step 5 fails because `φ ∈ fam.mcs s` (from hypothesis, same family)
and `φ.neg ∈ fam'.mcs s` (from forward_F, DIFFERENT family) don't inhabit the same MCS.

---

## Root Cause Analysis

### The Exact Structural Obstruction

The truth lemma's backward direction for `all_future (G)` reads:

```lean
-- Backward: ∀ s ≥ t, truth_at ... s ψ → G(ψ) ∈ fam.mcs t
intro h_all
-- by temporal_backward_G: uses fam.forward_F (same-family witness)
-- fam.forward_F: F(neg ψ) ∈ fam.mcs t → ∃ s > t, neg ψ ∈ fam.mcs s
```

This requires: "If `F(neg ψ) ∈ fam.mcs t`, then there exists `s > t` with `neg ψ ∈ fam.mcs s`."

The contradiction then exploits: `ψ ∈ fam.mcs s` (from `h_all s (le_of_lt hts)`)
and `neg ψ ∈ fam.mcs s` — both in the **same** MCS `fam.mcs s`.

With bundle-level coherence only, we get `neg ψ ∈ fam'.mcs s` for SOME family `fam'`.
There is no contradiction because `ψ ∈ fam.mcs s` and `neg ψ ∈ fam'.mcs s` live in
different families; an MCS is only required to be internally consistent.

### Why Family-Level Coherence Cannot Be Proven for SuccChainFMCS

The `SuccChainFMCS M0` is built by a successor chain where each step `succ_chain_fam M0 (n+1)`
is constructed to satisfy the **deferral relation** `Succ(u, v)`. The successor satisfies:

1. `forward_G`: `G(φ) ∈ u → φ ∈ v` (G-formulas persist forward)
2. `deferralDisjunctions`: for each `F(ψ) ∈ u`, either `ψ ∈ v` or `F(ψ) ∈ v`

The deferral disjunction at step n+1 does NOT guarantee `ψ ∈ chain(n+1)`. It defers.
An F-obligation deferred at step n reappears as `F(ψ) ∈ chain(n+1)` but may be deferred
again at step n+2, indefinitely.

**The core algebraic reason this fails**: The Lindenbaum extension for building the MCS
`chain(n+1)` from the seed `g_content(chain(n)) ∪ deferralDisjunctions ∪ p_step_blocking`
is completely free to include `G(neg ψ)` for any formula `ψ` where `F(ψ) ∈ chain(n)`.
Once `G(neg ψ) ∈ chain(n+1)`, we have `neg ψ ∈ chain(m)` for ALL `m > n`, permanently
killing the `F(ψ)` obligation from `chain(n)`.

### The G-Lift Barrier

Every attempt to prove same-family F-witness existence collapses to the following proof obligation:

**Wanted**: A seed containing `{ψ}` that is consistent with `G_theory(M) ∪ box_theory(M)`.

**Standard G-lift argument** (from `temporal_theory_witness_consistent`):
If `L ⊆ seed` and `L ⊢ ⊥`, then by deduction theorem `L_without_ψ ⊢ ψ.neg`.
G-lift: if all `x ∈ L_without_ψ` satisfy `G(x) ∈ M`, then `G(ψ.neg) ∈ M`.
But `F(ψ) = neg(G(neg ψ)) ∈ M` means `G(neg ψ) ∉ M`. Contradiction.

**Why this only works for a SINGLE ψ from a single F-obligation**: The G-lift requires
`G(x) ∈ M` for every `x ∈ L_without_ψ`. If `L_without_ψ` contains any element
`x` such that `G(x) ∉ M`, the G-lift fails. In particular:

- If `x ∈ G_theory(M)`, then `G(x) ∈ M` (by definition of `G_theory`).
- If `x = ψ` (the single witness formula), it has been removed by deduction theorem.
- If `x ∈ deferralDisjunctions` (formulas `ψ' ∨ F(ψ')` for `F(ψ') ∈ M`):
  then `G(ψ' ∨ F(ψ')) ∉ M` in general, because `G(ψ' ∨ F(ψ'))` is equivalent
  to `G(F(ψ'))` when `ψ'` is sometimes false — and `G(F(ψ'))` ("always eventually ψ'")
  is strictly stronger than `F(ψ')` ("eventually ψ'").
- If `x = F(ψ')` (preserving another F-obligation): then `G(F(ψ')) ∉ M` in general.

Every attempt to expand the seed beyond `{ψ} ∪ G_theory(M) ∪ box_theory(M)` adds
elements whose G-wraps are NOT in M, breaking the only available consistency proof.

---

## Algebraic Insight

### The Fundamental Algebraic Gap: F(ψ) and G(F(ψ)) are Independent

The core algebraic obstruction is the strict logical independence of `F(ψ)` and `G(F(ψ))`:

- `F(ψ)` = "at some future time, ψ" (existential, one-shot)
- `G(F(ψ))` = "at every future time, eventually ψ" (universal + existential, persistent)

In the Lindenbaum algebra, `F(ψ) ≤ G(F(ψ))` does NOT hold. An ultrafilter containing
`F(ψ)` need not contain `G(F(ψ))`. This is a PROVABLY valid model-theoretic fact:

Consider time = Int, with `ψ` true at time 1 only. Then:
- At time 0: `F(ψ)` holds (ψ is true at 1).
- At time 0: `G(F(ψ))` FAILS (at time 2, there is no future time where ψ holds).

This model proves that `F(ψ)` and `G(F(ψ))` are not equivalent and `F(ψ) ⊬ G(F(ψ))`.

**Algebraic consequence for the Lindenbaum algebra (LindenbaumAlg)**:
In the TenseS5Algebra `STSA`, the element `STSA.G (STSA.F a)` is NOT bounded below
by `STSA.F a` in general. There exists an ultrafilter containing `STSA.F a` but not
`STSA.G (STSA.F a)`. This is the algebraic witness that no proof of consistency
for seeds containing F-formulas alongside G-theory is possible via G-lifting.

### What the Bundle Approach Does Get Right

The `BFMCS_Bundle` construction with `boxClassFamilies` DOES achieve:
- Modal coherence (Box agreement across all families)
- Bundle-level temporal coherence (F-witness in SOME family)

These are the correct properties for the Jonsson-Tarski canonical extension approach.
The `boxClassFamilies_bundle_temporally_coherent` is fully sorry-free and correct.

However, the semantic framework (`valid_over`, `truth_at`) uses **single-timeline** semantics:
`G(φ)` is true at `(τ, t)` iff `φ` is true at `(τ, s)` for all `s ≥ t` **in the same
history τ**. The bundle structure places each `SuccChainFMCS` as a separate history.
Bundle-level temporal coherence says "a witness exists in SOME history" but the semantics
requires "G is false iff a negation-witness exists in THIS history."

This is the type mismatch at the heart of the sorry: the bundle gives existential
witnesses across histories; the semantics requires existential witnesses within a history.

---

## Principled Solution Direction

### What a Correct Solution Actually Requires

There are exactly two mathematically sound paths:

**Path 1: Build a SuccChainFMCS with same-family forward_F (the hard way)**

This requires proving: for any MCS `M` and any `F(ψ) ∈ M`, we can build an omega-chain
`chain : Int → MCS` starting from `M` such that for every `n` and every `F(ψ) ∈ chain(n)`,
there exists `m > n` with `ψ ∈ chain(m)`.

This is precisely the standard completeness proof for temporal logic (cf. Burgess 1979,
Goldblatt 1992). The standard proof uses a DOVETAILING / FAIR SCHEDULING strategy:

At step n, enumerate all pairs `(k, ψ)` with `F(ψ) ∈ chain(k)` that have not yet been
resolved, ordered by a priority queue (e.g., earliest unresolved obligation first). At step n,
build `chain(n+1)` to resolve the HIGHEST-PRIORITY obligation.

The mathematical claim: if `F(ψ) ∈ chain(k)` is NEVER resolved (ψ never appears),
then it must be that `G(neg ψ) ∈ chain(k+1)` for some specific step. But then
`F(ψ) ∈ chain(k)` and `G(neg ψ) ∈ chain(k+1)` together with the **priority guarantee**
that ALL obligations from `chain(k)` take priority over new ones... this requires showing
the priority queue forces resolution.

**Key obstacle**: The priority queue argument requires a compactness argument (each F-formula
has finitely many "depth levels") or a known termination argument. For the TM system
without bounded depth (no filtration), this terminates only if we can show the set of
unresolved obligations DECREASES. The depth-based argument fails because `temporal_theory_witness_exists`
can introduce NEW `F`-obligations while resolving old ones.

**Formalization insight**: The dovetailing approach IS formalizable if we can prove:
> If `F(ψ) ∈ chain(n)` and we build `chain(n+1)` via `temporal_theory_witness_exists` for `ψ`,
> then for every `F(χ) ∈ chain(n)` with `χ ≠ ψ`, either `F(χ) ∈ chain(n+1)` or `χ ∈ chain(n+1)`.

This is the "no F-obligation killing" lemma, and it is equivalent to asking whether the
`temporal_theory_witness_exists` construction for `ψ` can be arranged to preserve all other
F-obligations. The answer is YES if we build the seed as:
```
{ψ} ∪ G_theory(chain(n)) ∪ box_theory(chain(n))
```
and note that `temporal_theory_witness_consistent` is already proven. The question is only
whether `F(χ)` for `χ ≠ ψ` survives or is killed by Lindenbaum extension.

The HONEST answer: we cannot control Lindenbaum extension. Lindenbaum non-constructively
extends to a maximal set; a classical completeness argument cannot prevent arbitrary
G(neg χ) from appearing.

**This means Path 1 in its direct form is blocked for the same reason all 16+ previous
attempts failed**: there is no constructive proof of F-obligation preservation.

**Path 2: Change the semantic framework to match the algebraic construction (the right way)**

The algebraic construction produces a `BFMCS_Bundle` with bundle-level coherence.
The `valid_over Int φ` quantifies over ALL `TaskFrame Int` models.

The key algebraic insight: **we need to show that the bundle model IS a valid `TaskFrame Int`
model where `G` is evaluated with bundle-level semantics.**

But `truth_at` (in `Semantics/Truth.lean`) already defines `G(φ)` at `(M, Omega, τ, t)` as:
```
truth_at M Omega τ t (G φ) ≡ ∀ s ≥ t, truth_at M Omega τ s φ
```

This is SINGLE-HISTORY semantics (τ is fixed). The completeness proof via bundle
requires showing that `G(φ)` fails at some specific history when `φ` is not provable.

The PRINCIPLED solution is:

**Step 1**: Show that `SuccChainFMCS M0` (the eval_family) satisfies `forward_F` AT THE
BUNDLE LEVEL but by careful choice of which family satisfies the F-witness.

Actually, re-reading the code: `SuccChainFMCS M0` has `forward_G` and `backward_H` (the
non-existential directions) but LACKS `forward_F` and `backward_P` (the existential ones).

**Step 2**: Show that the `parametric_to_history (eval_family)` history in the bundle model
satisfies: if `G(φ)` is false (i.e., `F(neg φ) ∈ eval_family.mcs t`), then there exists
`s > t` in the SAME history where `neg φ` is true.

This IS provable IF we can show `forward_F` holds for `eval_family = SuccChainFMCS M0`.

And THIS is exactly what is currently unknown: does `SuccChainFMCS M0` satisfy `forward_F`?

**The Z-chain section of UltrafilterChain.lean** (`Z_chain_forward_F`, line ~2424) has a sorry:
```lean
theorem Z_chain_forward_F (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ omega_chain M0 h_mcs0 t) :
    ∃ s > t, phi ∈ omega_chain M0 h_mcs0 s := by
  sorry
```

The `omega_chain` construction (using `temporal_theory_witness_exists` at each step)
is designed to resolve F-obligations, but the current sorry reflects that the
DOVETAILING argument has not been formalized.

### The Principled Path Forward

The mathematically correct and feasible solution is:

**Phase A: Prove `Z_chain_forward_F` using the dovetailing argument**

The omega_chain at step n resolves F(φ) by using `temporal_theory_witness_exists` for
the formula with the SMALLEST index among unresolved obligations. Specifically:

- At step n = 0: resolve the F-obligation with smallest `φ` in some fixed enumeration
- At step n = k+1: resolve the NEXT obligation in the priority queue

The key lemma to prove:
```lean
-- For the dovetailing chain, every F-obligation eventually gets resolved
theorem dovetailed_chain_forward_F (M0 : Set Formula) ...
    (h_F : F(φ) ∈ chain(n)) :
    ∃ m > n, φ ∈ chain(m)
```

Proof by well-founded induction on the priority of φ in the enumeration. At step p
where φ is highest priority, `chain(p+1)` is built via `temporal_theory_witness_exists` for φ,
so φ ∈ chain(p+1) by `temporal_theory_witness_exists`.

**Obstacle**: We need to show that if F(φ) ∈ chain(n), then F(φ) either survives to chain(p)
or is resolved before p. Since the chain is built by `temporal_theory_witness_exists` for
OTHER formulas ψ at intermediate steps, we need: if ψ ≠ φ, then resolving F(ψ) at step k
does NOT kill F(φ) at step k.

This is NOT provable in general (it's exactly the F-obligation killing problem from above).

**The actual key insight that makes the dovetailing work** (often omitted in informal proofs):

When F(φ) ∈ chain(n) and we build chain(n+1) via `temporal_theory_witness_exists` for some
ψ ≠ φ:
- If F(φ) ∈ chain(n+1): defer to later step
- If G(neg φ) ∈ chain(n+1): then neg φ ∈ chain(m) for all m ≥ n+1

In the second case: F(φ) ∈ chain(n) and G(neg φ) ∈ chain(n+1). These are globally
consistent (in different MCSes), but the CHAIN must be a model of TM logic, which
requires at chain(n): `F(φ) → F(neg G(neg φ))` — which means `F(φ)` at chain(n) implies
`G(neg φ) ∉ chain(n+1)` only if the chain satisfies the TM temporal axioms.

But the chain is defined by MCS succession, and MCS succession does NOT globally enforce
TM-model consistency across time. Each step is independently consistent; the chain as a
whole need not satisfy `valid_over Int (F(φ) → ¬G(neg φ).all_past)`.

**Conclusion about Path 2**: The dovetailing approach IS correct mathematically
(it works in pen-and-paper proofs in Goldblatt 1992, Ch. 6), but formalizing it requires
either:
(a) A NON-CLASSICAL argument (one that controls Lindenbaum extension), OR
(b) A CONSTRUCTIVE Lindenbaum extension (where we explicitly choose which formulas to add)

Option (b) is viable: instead of using the abstract `set_lindenbaum` which applies Zorn's
lemma, build the MCS chain(n+1) CONSTRUCTIVELY by adding the seed
`{ψ} ∪ G_theory(chain(n)) ∪ box_theory(chain(n))`
and then extending by a WELL-ORDERED enumeration of all formulas, checking consistency
before adding each one. This gives a specific MCS that is the GREEDY EXTENSION of the seed.

For the constructive MCS, we can then REASON about what it contains: if F(φ) ∈ chain(n)
and we used `temporal_theory_witness_exists` to put ψ ∈ chain(n+1), then for any other
formula χ with F(χ) ∈ chain(n):
- The seed does NOT contain G(neg χ), so Lindenbaum will only add G(neg χ) if it is
  consistent with the seed and all prior additions.
- The greedy extension adds the FIRST formula in the enumeration consistent with the
  current partial MCS. G(neg χ) may or may not be added depending on enumeration order.

This means even constructive Lindenbaum cannot prevent F-obligation killing in general.

### The True Solution: Extending The Temporal Witness to Preserve F-Obligations

Reading the mathematical literature carefully (Burgess 1979, §3; Goldblatt 1992, Ch. 6):

The standard proof of completeness for temporal logic builds the canonical model differently.
Rather than using successor chains, it uses an ORDERED LINDENBAUM CONSTRUCTION where:

1. All formulas are enumerated: φ_0, φ_1, φ_2, ...
2. Each MCS in the chain is built by a SCHEDULED addition: at step n, we handle the EARLIEST
   unhandled F-obligation.
3. The key lemma: "If F(φ) ∈ MCS_k, then φ is satisfied in the canonical model at time k+f(φ),
   where f(φ) is the rank of φ in the enumeration."

The crucial insight from Burgess/Goldblatt: the canonical model is NOT built as a chain of
individual MCSes linked by successor. It is built as a SINGLE MCS indexed by time, where:
- The MCS at time 0 is the initial MCS
- The MCS at time n is constructed by the ENTIRE inductive process up to step n, which
  ensures ALL F-obligations from time 0 through time n-1 are resolved.

This is a well-founded recursion argument, NOT an induction on single steps.

**For Lean formalization**, the right approach is:

1. Build the dovetailing chain as a well-defined `Nat → Set Formula` (or `Int → Set Formula`)
   function, using `Nat.rec` with STATE tracking which F-obligation is "due" at each step.
2. The STATE at step n records: the list of unresolved F-obligations, ordered by due time.
3. At step n: extend the MCS to resolve the obligation with the smallest due time.

This is implementable in Lean but requires significant new infrastructure that is NOT
currently in the codebase.

**HOWEVER**: Reading `UltrafilterChain.lean` more carefully, the `omega_chain` construction
DOES attempt this (using `temporal_theory_witness_exists` at each step). The sorry in
`Z_chain_forward_F` is PRECISELY where the dovetailing argument must be formalized.
The existing infrastructure is correct; the gap is the FORMAL PROOF that the dovetailing
resolves all obligations.

---

## Summary Diagram: The Sorry Chain

```
bundle_validity_implies_provability [SORRY]
  |
  uses: not_provable_implies_neg_consistent [SORRY-FREE]
  uses: construct_bfmcs_bundle [SORRY-FREE: gives BFMCS_Bundle]
  uses: mcs_neg_gives_countermodel [SORRY-FREE: gives φ ∉ eval_family.mcs 0]
  |
  GAP: need eval_family.mcs 0 → semantic falsehood in valid_over Int model
  |
  need: parametric_shifted_truth_lemma [SORRY-FREE: but requires BFMCS.temporally_coherent]
  |
  GAP: BFMCS_Bundle.BundleTemporallyCoherent ≠ BFMCS.temporally_coherent
       (bundle-level ≠ family-level F-witnesses)
  |
  FUNDAMENTAL: SuccChainFMCS lacks forward_F [family-level]
  |
  FUNDAMENTAL: No known proof of same-family forward_F via Lindenbaum
  (G-lift fails for F-formulas; 16+ attempts blocked)
```

---

## Confidence Level

**High** — This analysis is grounded in:
1. Direct reading of all relevant Lean files (no speculation about code structure)
2. Mathematical understanding of why the G-lift argument is the ONLY available tool for
   temporal MCS consistency proofs, and why it is fundamentally insufficient for seeds
   containing F-formulas
3. The algebraic fact `F(ψ) ⊬ G(F(ψ))` is provably independent in the TM system
4. The dovetailing gap in `Z_chain_forward_F` is the CORRECT location of the sorry and
   the mathematically hardest step in the completeness proof

---

## Recommendations

### Immediate (Reduce 3 Sorries to 1)

Wire `dense_completeness_fc` and `discrete_completeness_fc` through `completeness_over_Int`:
- `completeness_over_Int` calls `bundle_validity_implies_provability` (1 sorry)
- `dense_completeness_fc` should instantiate with D = Rat (which embeds in dense orders)
  and reduce to `completeness_over_Int`
- `discrete_completeness_fc` should instantiate with D = Int (which is discrete) and
  reduce to `completeness_over_Int`
- This wiring requires showing Int is a valid instance for both frame classes

### Medium-Term (Eliminate the Last Sorry)

Prove `Z_chain_forward_F` in `UltrafilterChain.lean`. This is the dovetailing argument:

```lean
theorem Z_chain_forward_F (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ omega_chain M0 h_mcs0 t) :
    ∃ s > t, phi ∈ omega_chain M0 h_mcs0 s
```

The proof requires showing that the omega_chain construction ensures F-obligations are
eventually resolved. This is the genuine mathematical difficulty, corresponding to the
heart of Burgess (1979) / Goldblatt (1992) temporal completeness.

If `Z_chain_forward_F` is proven, then `OmegaFMCS` satisfies `forward_F` and can serve
as the eval_family with same-family temporal coherence, connecting to the existing
truth lemma machinery and eliminating the last sorry.

### Do Not Pursue

- Multi-BRS consistency for `constrained_successor_seed` (SuccChainFMCS approach) — blocked
- Bundle-level truth lemma — changes the semantics (non-standard)
- Weakened completeness statements — changes the mathematical content
- Any approach requiring `G(F(ψ)) ∈ M` from `F(ψ) ∈ M` — algebraically impossible
