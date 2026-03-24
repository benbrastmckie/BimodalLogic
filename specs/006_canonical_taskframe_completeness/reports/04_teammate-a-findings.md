# Research Report: Order-Preserving Embedding for CanonicalMCS to Int

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-19
**Focus**: Primary approach — constructing an order-preserving embedding from ChainFMCSDomain to Int

---

## Key Findings

### Finding 1: CanonicalR is a Preorder on a DAG, NOT a Total Order

`CanonicalR M M'` is defined as `g_content M ⊆ M'` (file:
`Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`, line 63). The Preorder on
`CanonicalMCS` is:

```lean
le a b := a = b ∨ CanonicalR a.world b.world
```

(file: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`, line 96)

This Preorder is **NOT total** in general — there exist MCS pairs M, M' where neither
`g_content M ⊆ M'` nor `g_content M' ⊆ M` holds. The codebase explicitly documents
this: `"Note: this Preorder is NOT total in general."` (line 94 in `CanonicalFMCS.lean`).

### Finding 2: Flags ARE Totally Ordered (Linearly)

A `Flag CanonicalMCS` is a maximal chain in the CanonicalMCS preorder. Within a Flag F,
any two elements are comparable:

```lean
theorem chainFMCS_pairwise_comparable (flag : Flag CanonicalMCS)
    (a b : ChainFMCSDomain flag) : a ≤ b ∨ b ≤ a
```

(file: `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`, line 550)

So `ChainFMCSDomain F` is a **totally ordered** countable set (a subtype of countable
`CanonicalMCS`). This is the critical observation for embedding.

### Finding 3: The FMCSTransfer Infrastructure Already Solves the Per-Flag Embedding Problem

The file `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` defines exactly the
embedding/retraction structure needed:

```lean
structure FMCSTransfer (D : Type*) [Preorder D] where
  embed : CanonicalMCS →o D
  retract : D → CanonicalMCS
  retract_left_inverse : ∀ w : CanonicalMCS, retract (embed w) = w
  embed_retract_eq : ∀ d : D, embed (retract d) = d
  retract_lt : ∀ d₁ d₂ : D, d₁ < d₂ → retract d₁ < retract d₂
  embed_lt : ∀ w₁ w₂ : CanonicalMCS, w₁ < w₂ → embed w₁ < embed w₂
```

(lines 80–93)

This is a **strict order-preserving bijection** between CanonicalMCS and D. If we can
provide `embed_lt` (strict order-preservation), then `transferred_forward_G` and
`transferred_backward_H` are proven:

```lean
theorem transferred_forward_G (T : FMCSTransfer D) (d₁ d₂ : D) (phi : Formula)
    (h_lt : d₁ < d₂) (h_G : Formula.all_future phi ∈ transferredMCS T d₁) :
    phi ∈ transferredMCS T d₂
```

(lines 168–173)

The proof goes: `d₁ < d₂` in D → `retract d₁ < retract d₂` in CanonicalMCS (by
`retract_lt`) → apply `canonicalMCS_forward_G`. This is **already implemented and
sorry-free**.

### Finding 4: The Global `enum_mcs` Fails Because It Maps All CanonicalMCS, Not One Flag

The existing `enum_mcs : CanonicalMCS -> ℤ` (file:
`Theories/Bimodal/Metalogic/Bundle/FlagBFMCSIntBundle.lean`, line 70) uses
`Encodable.encode`, which assigns integers based on encoding order — completely unrelated
to the CanonicalR partial order. The code explicitly documents the failure at lines
163–186.

**Why it fails**: For `forward_G`, we need: `s < t` (integers) implies G(φ) at
`mcs_at_time s` propagates to `mcs_at_time t`. But the integer ordering has no
relationship to `CanonicalR` between the corresponding MCS — the encoding is entirely
order-unrelated.

### Finding 5: A Per-Flag Order-Preserving Embedding Into Int IS Constructible

For a single Flag F, `ChainFMCSDomain F` is a countable, totally ordered set. The
question is whether a countable total order embeds order-preservingly into Int.

**Mathematical answer**: Not every countable total order embeds into Int. Specifically:
- Dense countable total orders (like Q) do not embed into Int (Int has no density)
- However, Int itself is a discrete total order

Within a Flag, the order is induced by CanonicalR (a strict order). The critical
question is: are Flags **discrete** (every element has a successor/predecessor) or
**dense**?

**Key observation from the axioms**: The temporal logic includes a **density axiom**
`DN: GGφ → Gφ` (documented in `CanonicalTimeline.lean`, line 166, and the density
lemma `density_of_canonicalR` at line 174, though it has a `sorry` due to task 991
complications). If density holds in the canonical model, then Flags may be densely
ordered, making Int (discrete) an unsuitable target.

However, the current codebase is working under **irreflexive semantics** (Task 991),
and the density axiom situation is complex. Looking at the existing structures:

- `ChainFMCS` works over `ChainFMCSDomain` with the CanonicalMCS preorder
- The preorder `a < b` is equivalent to `CanonicalR a.world b.world`
- CanonicalR is defined purely by set inclusion (`g_content M ⊆ M'`)

**Can two MCS be "between" a third in CanonicalR?** Yes, potentially. The CanonicalR
relation permits dense orderings (there can be intermediate MCS between any two
CanonicalR-related MCS). This means Flags might be **densely ordered**, NOT discrete.

### Finding 6: The FMCSTransfer Requires Surjectivity — This Is the Core Obstruction

The `FMCSTransfer` structure requires `embed_retract_eq : ∀ d : D, embed (retract d) = d`,
meaning the embedding must be **surjective** onto D. For D = Int, this means the Flag
must have the same cardinality as Int.

- A Flag is a maximal chain of MCS — countably infinite (since MCS are countable)
- Int is countably infinite
- Countable → there exists a bijection to Int or N

But we need a **order-preserving** bijection. For a countable total order to be
order-isomorphic to Int (as a totally ordered set), it must:
1. Be totally ordered ✓ (Flags are chains)
2. Have no minimum element ✓ (NoMinOrder from seriality)
3. Have no maximum element ✓ (NoMaxOrder from seriality)
4. Be **discrete** (every element has an immediate successor/predecessor)

Property (4) is the crucial unknown. If Flags are dense (no immediate successors), they
are NOT isomorphic to Int; they would be isomorphic to Q (or a suborder of Q).

### Finding 7: The Correct Target Domain Depends on Flag Density

The existing codebase has two completeness pathways:

1. **Discrete completeness** (`D = Int`): Requires SuccOrder, PredOrder — Flags must
   be discrete
2. **Dense completeness** (`D = Rat`): Requires DenselyOrdered — Flags can be dense

The `ParametricCanonicalTaskFrame` is polymorphic in D:
```lean
abbrev DenseCanonicalTaskFrame : TaskFrame Rat := ParametricCanonicalTaskFrame Rat
abbrev DiscreteCanonicalTaskFrame : TaskFrame Int := ParametricCanonicalTaskFrame Int
```

(file: `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` and
`DiscreteInstantiation.lean`)

The question of whether Flags embed into Int vs Rat is equivalent to the question of
whether the canonical CanonicalMCS preorder is discrete or dense within chains.

---

## Recommended Approach

### Primary Recommendation: Use Rat (Dense) Not Int (Discrete) for the Embedding

**Rationale**: The Cantor theorem approach (already in the codebase) provides a
ready-made order-preserving embedding for countable dense linear orders into Q.

The `CanonicalTimeline` module (`Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean`)
develops the timeline infrastructure and mentions `Cantor's theorem` for countable dense
linear orders (`Order.iso_of_countable_dense`). The `CantorApplication.lean` file applies
this to get `TimelineQuot ≃o Q`.

**Proposed construction for the Flag embedding**:

Given a Flag F (a maximal chain in CanonicalMCS), we want an order-preserving injection
`embed_F : ChainFMCSDomain F ↪o Rat`.

This exists by the following argument:
1. `ChainFMCSDomain F` is a countable total order (no min, no max by seriality axioms)
2. Under density axioms, it is densely ordered
3. By Cantor's theorem, any countable dense linear order without endpoints is
   order-isomorphic to Q
4. Therefore `ChainFMCSDomain F ≃o Q` exists (as an order isomorphism, not just embedding)

This would give the order-preserving embedding into Rat (= Q). The `FMCSTransfer` with
`D = Rat` would then be satisfiable.

**For `D = Int` (discrete)**: If the canonical model under current axioms is NOT
guaranteed to produce discrete Flags, embedding into Int is mathematically incorrect.
The correct approach for integer-indexed completeness is to use a different construction
(like the existing dovetailing chain), not to embed Flags into Int.

### Alternative Recommendation: Bypass Int Entirely

The `FlagBFMCSValidityBridge.lean` file already proves `FlagBFMCS_completeness` (lines
92–121) using `satisfies_at` — a sorry-free completeness proof. The remaining gap
(line 241, sorry) is the **validity bridge** connecting `satisfies_at` to `truth_at`.

**The validity bridge can be resolved without constructing BFMCS Int**:

The validity bridge requires showing the FlagBFMCS model is a valid Kripke model in the
`valid` sense (quantifying over `TaskFrame D`). Rather than constructing `BFMCS Int`,
we can:

1. Define `FlagBFMCS.toTaskFrame : FlagBFMCS → TaskFrame (ChainFMCSDomain eval_flag)`
   — use the Flag itself as the domain type (no embedding needed)
2. Prove `satisfies_at` corresponds to `truth_at` in this task frame
3. Show the resulting task frame is accessible from the `valid` quantifier

This avoids the embedding problem entirely by using the natural domain of the Flag.

### If Int Is Required: Use Saturated Chains + Discrete Density Argument

If `D = Int` is specifically required (e.g., for the algebraic base completeness with
`AddCommGroup Int`), the resolution requires:

1. **Show Flags are discrete**: Prove that in the canonical model (under current axioms
   without the full density axiom), there ARE no intermediate MCS between CanonicalR-
   related pairs within a maximal chain. This would require analyzing what
   `g_content M ⊆ M'` and the absence of intermediate MCS means.

2. **Use saturated chain construction**: The `SaturatedChain.lean` file
   (`Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean`) defines saturated chains
   with F/P witnesses. A saturated chain that is also **ω-ordered** (isomorphic to ℤ as
   a sequence) could be directly embedded into Int via index counting.

3. **Enumerate via construction not Encodable**: Instead of using `Encodable.encode`
   (order-unrelated), build the Int indexing **during** the chain construction, assigning
   index 0 to root_mcs, index 1 to the next F-step, index -1 to the next P-step, etc.
   This is the dovetailing approach already attempted in tasks 1004 and 989.

---

## Evidence/Examples

### The FMCSTransfer Pattern Already Works for Order-Preserving Embeddings

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`

Lines 162–173:
```lean
theorem transferred_forward_G (T : FMCSTransfer D) (d₁ d₂ : D) (phi : Formula)
    (h_lt : d₁ < d₂) (h_G : Formula.all_future phi ∈ transferredMCS T d₁) :
    phi ∈ transferredMCS T d₂ := by
  unfold transferredMCS at *
  have h_retract_lt : T.retract d₁ < T.retract d₂ := T.retract_lt d₁ d₂ h_lt
  exact canonicalMCS_forward_G (T.retract d₁) (T.retract d₂) phi h_retract_lt h_G
```

This is the key insight: if `retract` is strictly order-preserving and `embed` is a left
inverse, then `forward_G` and `backward_H` transfer automatically. The entire
`transferredFMCS` construction is sorry-free given an `FMCSTransfer` instance.

### The Existing Countability Proof Uses Non-Order-Preserving Encoding

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FlagBFMCSIntBundle.lean`

Lines 70–82:
```lean
noncomputable def enum_mcs (M : CanonicalMCS) : ℤ :=
  (Encodable.encode M : ℤ)

theorem enum_mcs_injective : Function.Injective enum_mcs
```

The `Encodable.encode` approach gives injectivity but NOT order-preservation. This is
explicitly confirmed blocked at lines 163–186.

### ChainFMCSDomain Is a Totally Ordered Subtype of CanonicalMCS

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`

Lines 542–552:
```lean
abbrev ChainFMCSDomain (flag : Flag CanonicalMCS) :=
  { w : CanonicalMCS // w ∈ flag }

theorem chainFMCS_pairwise_comparable (flag : Flag CanonicalMCS)
    (a b : ChainFMCSDomain flag) : a ≤ b ∨ b ≤ a := by
  exact flag.Chain'.total a.property b.property
```

### Density Is Proven for CanonicalTimeline (With Sorry for Task 991 Complications)

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean`

Lines 174–183 (the density lemma has a `sorry` but describes the intended approach):
```lean
theorem density_of_canonicalR (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧
      Formula.some_future φ ∈ W := by
  -- ...
  sorry
```

This suggests the intended behavior is density, which would imply Rat (not Int) as
the correct target.

---

## Mathematical Summary: Can We Embed Into Int?

The answer is **conditional**:

- **If CanonicalR within Flags is discrete** (every element has an immediate
  successor/predecessor): YES, ChainFMCSDomain F embeds order-isomorphically into Int
  (as both are countable discrete total orders without endpoints).

- **If CanonicalR within Flags is dense** (between any two related MCS, another exists):
  NO, ChainFMCSDomain F does not embed order-preservingly into Int (Int is not dense).
  The correct target is Rat.

- **The current axiom set** (with density axiom GGφ → Gφ) suggests the canonical model
  is intended to be dense, meaning **Rat is the correct target**, not Int.

### The Core Issue With the Plan-02 Approach

The streamlined plan (v2) using global `enum_mcs : CanonicalMCS -> Int` is fundamentally
broken because:

1. It maps **all** CanonicalMCS to Int, but only elements within a single Flag need to
   be ordered relative to each other
2. The ordering constraint is only needed **within each Flag**, not globally
3. Even within a Flag, Int may be the wrong target if the order is dense

The plan should be revised to either:
- Use `Rat` as the target for the per-Flag embedding (matching density)
- Use `ChainFMCSDomain F` directly as the domain (bypassing Int entirely)

---

## Confidence Level

**High** for the following findings:
- CanonicalR is NOT a total order on all CanonicalMCS (code clearly states this)
- Flags (maximal chains) ARE totally ordered (proven in ChainFMCS.lean)
- FMCSTransfer pattern works when embed is order-preserving (sorry-free proofs exist)
- The global `enum_mcs` (Encodable.encode) is NOT order-preserving (explicitly documented)
- `FMCS D` with `D = ChainFMCSDomain F` works without any embedding (chainFMCS is sorry-free)

**Medium** for the following:
- Whether Flags are dense or discrete (depends on resolving the Task 991 density sorry)
- Whether Rat vs Int is the correct target (follows from density question)

**Low** for:
- Whether there exists a purely algebraic proof that ChainFMCSDomain F ≃o ℤ (not
  investigated in detail; requires density analysis)

---

## Recommended Next Steps for Phase 2 Unblocking

1. **Immediate path** (no new research needed): Use `ChainFMCSDomain F` directly as
   the FMCS domain for each Flag. The `chainFMCS F : FMCS (ChainFMCSDomain F)` is
   **already sorry-free** and fully functional. The BFMCS can use a Sigma type
   `Σ (F : Flag), ChainFMCSDomain F` as its domain. The `valid` bridge would need
   to work with this domain type.

2. **Medium-term path** (if Int is required): Resolve the density question for
   CanonicalMCS Flags. If discrete, construct an order-isomorphism to Int using
   the dovetailing/successor construction (Tasks 1004, 989). If dense, switch target
   to Rat.

3. **Do NOT use**: The global `enum_mcs` approach for `forward_G`/`backward_H` transfer.
   It is mathematically incorrect for any order-sensitive property.
