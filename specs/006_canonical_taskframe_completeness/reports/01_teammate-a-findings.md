# Task 1006 Research: Canonical TaskFrame Completeness
## Teammate A Findings — Primary Implementation Approach

---

## Key Findings

### 1. The Current Architecture (FlagBFMCS + satisfies_at)

The existing completeness infrastructure is split across:

- **`FlagBFMCS.lean`** — defines `FlagBFMCS` structure with flags (maximal chains in CanonicalMCS), modal saturation, and an eval position
- **`FlagBFMCSTruthLemma.lean`** — defines `satisfies_at` (an ad-hoc satisfaction relation) and proves `satisfies_at_iff_mem` (the truth lemma)
- **`FlagBFMCSCompleteness.lean`** — proves `FlagBFMCS_completeness` in terms of `satisfies_at`, with a `sorry`-dependent `algebraic_base_completeness_flagbfmcs` in `FlagBFMCSValidityBridge.lean` for the connection to `valid`

The critical gap: `satisfies_at` is a **bespoke recursive relation** that mirrors `truth_at` but is disconnected from it. Task 1006 replaces this with a direct construction of a canonical `TaskFrame`/`TaskModel`/`WorldHistory` and proves the truth lemma in terms of `truth_at`.

### 2. The Official Semantic Layer (truth_at, TaskFrame, WorldHistory)

**`truth_at` signature** (`Semantics/Truth.lean`, line 115):
```
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F)) (τ : WorldHistory F) (t : D) : Formula → Prop
```

Key facts:
- `D` must carry `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`
- `Box φ` at `(M, Omega, τ, t)` quantifies over ALL `σ ∈ Omega` (not just the current `τ`): `∀ σ ∈ Omega, truth_at M Omega σ t φ`
- `all_future φ` quantifies over ALL strictly future times in D (not just domain): `∀ s : D, t < s → truth_at M Omega τ s φ`
- Atoms at times outside domain are false: `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p`

**`valid`** (`Semantics/Validity.lean`, line 72) quantifies over all `D : Type` with `AddCommGroup`, all `TaskFrame D`, all models, all shift-closed Omega, all histories in Omega, and all times.

### 3. What ChainFMCS / FlagBFMCS Worlds Are

A **position** in FlagBFMCS is `(F : Flag CanonicalMCS, x : ChainFMCSDomain F)` where:
- `F` is a maximal chain in `CanonicalMCS` (linearly ordered set of MCSes)
- `x.val : CanonicalMCS` is a particular MCS in the chain
- `(chainFMCS F).mcs x = x.val.world` is the underlying `Set Formula`

**ChainFMCSDomain F** is `{ M : CanonicalMCS // M ∈ F }` with the suborder inherited from `CanonicalMCS`. This already forms a linearly ordered set — it IS the duration domain we need.

### 4. The Gap Between satisfies_at and truth_at

The gap is entirely about **universe/type structure**:

| Concern | `satisfies_at` | `truth_at` |
|---------|---------------|-----------|
| Duration domain D | No D; temporal comparison is `x.val < x'.val` on CanonicalMCS | Requires explicit `D` with `AddCommGroup` etc. |
| World type W | Implicit: `Set Formula` (the MCS) | Explicit `F.WorldState` |
| History | Not used; just indexes over Flags | Explicit `WorldHistory F` |
| Box semantics | Quantifies over `(F', x')` pairs with BoxContent inclusion | Quantifies over `σ ∈ Omega` |
| Temporal semantics | Cross-Flag: `x.val < x'.val` across different Flags | `∀ s : D, t < s` over ALL times in D |
| Omega | Implicit (all Flags in B.flags) | Explicit `Set (WorldHistory F)` |

The current `satisfies_at` is essentially a correct but **informal analogue** of `truth_at` that avoids the type-theoretic machinery.

### 5. The Existing Parametric Precedent

The algebraic approach in `ParametricCanonical.lean` + `ParametricHistory.lean` + `ParametricTruthLemma.lean` ALREADY solves the analogous problem for BFMCS. The pattern is:

1. `ParametricCanonicalWorldState` = `{ M : Set Formula // SetMaximalConsistent M }` — wraps MCS as world state
2. `parametric_canonical_task_rel M d N`: uses CanonicalR for `d > 0`, identity for `d = 0`, converse for `d < 0`
3. `parametric_to_history fam`: converts any `FMCS D` to a `WorldHistory (ParametricCanonicalTaskFrame D)` with `domain = fun _ => True` (full domain)
4. `ParametricCanonicalTaskModel D`: `valuation M p = (atom p ∈ M.val)`
5. `parametric_canonical_truth_lemma`: `φ ∈ fam.mcs t ↔ truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B) (parametric_to_history fam) t φ`

The key insight: `FMCS D` is parametric in D. A `chainFMCS F` is an `FMCS (ChainFMCSDomain F)` — but `ChainFMCSDomain F` needs to be given `AddCommGroup` etc. for the parametric machinery to apply.

### 6. The Core Problem: ChainFMCSDomain Needs Group Structure

`ChainFMCSDomain F = { M : CanonicalMCS // M ∈ F }` is a **linearly ordered type** (inheriting the order on `CanonicalMCS`), but it does NOT have an `AddCommGroup` structure — it is not a group, and there is no natural "zero element" or "subtraction."

This is the fundamental obstacle. The parametric approach requires `D : Type*` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

**Two resolution strategies**:

**Strategy A — Use Int as D, map each Flag into Int**:
- Pick D = Int
- For each Flag F, pick a bijection `embed : ChainFMCSDomain F ≃o ℤ` (order isomorphism to an interval in ℤ)
- Construct `FMCS Int` for each Flag using this bijection
- Apply the parametric machinery

Obstacle: Flags may have uncountable length (CanonicalMCS is constructed via Zorn) and may not be isomorphic to ℤ.

**Strategy B — Use a bespoke D from the Flag structure (task description's approach)**:
The task says "duration domain D parametrically from Flag chain positions." This suggests using `ChainFMCSDomain F` itself as D, but we need group structure. One approach: use `ℤ` and view positions as integers via a chosen embedding.

**Strategy C — Build canonical TaskFrame directly, avoid FMCS parametrization**:
This is the most direct approach and avoids the D-parametrization issue entirely. We build a `TaskFrame` where:
- `D = ℤ` (or `ℚ`, but ℤ suffices for base TM)
- `WorldState = CanonicalMCS` (or `{ M : Set Formula // SetMaximalConsistent M }`)
- `task_rel w d u = if d > 0 then CanonicalR w.val u.val else ...` (same as `parametric_canonical_task_rel`)
- For each Flag F, the history `τ_F : WorldHistory CanonicalTaskFrame` maps each integer time point to a corresponding MCS in F
- Omega = set of all such histories `{τ_F | F ∈ B.flags}`

This is EXACTLY the approach already implemented for BFMCS in `SeparatedTaskFrame.lean` / `SeparatedHistory.lean` / `ParametricRepresentation.lean`. The question is: can FlagBFMCS be mapped into this existing machinery?

---

## Recommended Approach

### Direct Approach: FlagBFMCS → BFMCS Int → Parametric Truth Lemma

The cleanest path is:

**Step 1: Define a temporal indexing for each Flag.**

Each `Flag CanonicalMCS` is a linearly ordered set. Pick `D = ℤ`. For each Flag F, we need an order-embedding (not necessarily surjective) `iota_F : ChainFMCSDomain F → ℤ`. This always exists for countable linear orders, and the Flags arising from CanonicalMCS via Zorn are linearly ordered but may be uncountable.

**Alternative for Step 1**: Use `D = CanonicalMCS` as the duration domain. But CanonicalMCS is not a group.

**Best Alternative for Step 1**: Use the fact that for the truth lemma, we only need ONE canonical model to be a countermodel. We can pick a **specific** D and construct the history over that D. Since base TM completeness works for ANY D, we can pick `D = ℤ` and observe that:

A Flag F is a maximal chain in CanonicalMCS. CanonicalMCS has a linear order from the Zorn/Lindenbaum construction. The chain F, viewed as a linearly ordered set, embeds into ℤ if it is countable, into ℚ if it is densely ordered, etc.

**Simplest viable approach**: Use the existing `BFMCS ℤ`/`parametric_canonical_truth_lemma` infrastructure.

The `allFlagsBFMCS` construction already has all the information. We need to:
1. For each `F ∈ B.flags`, construct an `FMCS ℤ` corresponding to `chainFMCS F`
2. Bundle these into a `BFMCS ℤ`
3. Apply `parametric_canonical_truth_lemma`

The obstruction: there is no canonical `ℤ`-indexing of a Flag without additional structure (countability/density assumptions).

### Recommended Direct Canonical TaskFrame Construction (Task Description's Intent)

Based on the task description ("duration domain D parametrically from Flag chain positions"), the intended approach avoids ℤ-indexing entirely:

**Key insight**: `truth_at` quantifies over ALL `s : D` (including times outside the Flag). For a canonical model, we want:
- A history `τ_F` where `τ_F.domain t = True` for all t (full domain), OR
- A history where `τ_F.domain t = (some canonical index of t is in F)`

Since `valid` quantifies over `D : Type` with just `AddCommGroup` (not requiring countability), we can pick D to be the linearly ordered type of Flag positions WITH an added group structure.

**Concrete construction**:

Let `D = ℤ` for simplicity (base TM). Pick a canonical enumeration of each Flag's positions. For `allFlagsBFMCS`, since `allFlags_temporally_complete` holds, every CanonicalMCS is in some Flag. This means:

1. Each Flag F is a linearly ordered chain of CanonicalMCS elements
2. Pick `chronological_index : ChainFMCSDomain F → ℤ` as any order-embedding (requires some choice)
3. Define `τ_F : WorldHistory (ParametricCanonicalTaskFrame ℤ)` by:
   - `domain t = ∃ x : ChainFMCSDomain F, chronological_index x = t`
   - `states t ht = ⟨(classical choice of x with index t).val.world, ...⟩`
4. Omega = `{τ_F | F ∈ B.flags}`

But this requires Omega to be shift-closed (ShiftClosed Omega), which would require every shift of τ_F to remain in Omega. This is the hard constraint — shifts of a flag history are NOT generally flag histories.

**Resolution**: Use `ShiftClosedParametricCanonicalOmega` (from `ParametricHistory.lean`) which takes the shift-closure of the initial Omega. This is already done in the existing parametric construction!

### Actual Recommended Approach: Extend Existing Parametric Infrastructure

The **correct approach** is to:

1. **Observe** that `FlagBFMCS.satisfies_at B F hF x φ ↔ φ ∈ (chainFMCS F).mcs x` (already proved as `satisfies_at_iff_mem`)

2. **Map** the FlagBFMCS to a `BFMCS D` for some D (e.g., D = ℤ) where:
   - Each Flag F maps to an `FMCS ℤ` (requires temporal indexing)
   - Modal coherence (`modal_forward`/`modal_backward`) must be verified

3. **Apply** `parametric_canonical_truth_lemma` to get `truth_at` directly

4. **Instantiate** `valid` with D = ℤ (or D = ℚ)

The key challenge is step 2 (temporal indexing of Flags into ℤ). The existing `StagedConstruction/TimelineQuotAlgebra.lean` and `TimelineQuotCanonical.lean` modules already solve this for specific staged constructions using `TimelineQuot`. The question is whether we can leverage this for FlagBFMCS.

**Alternative simpler approach** (avoids Int-indexing):

Build the canonical TaskFrame with `D = ChainFMCSDomain F` for a FIXED Flag F. This works for proving satisfiability of a SPECIFIC formula (the negation of an unprovable formula), since we only need ONE countermodel:

- `D` = `ChainFMCSDomain F` for the eval_flag F
- WorldState = CanonicalMCS
- task_rel w d u = `d > 0 → CanonicalR w.val u.val` etc.
- The history τ_F maps d to the world at position d

But `ChainFMCSDomain F` is not an `AddCommGroup`.

**Most practical approach for implementation**: Use D = ℤ and the following observation: for the completeness theorem, we only need to show that if `¬Provable φ`, then `¬valid φ`. The countermodel is constructed as follows:

From `allFlagsBFMCS M0`:
1. Take the existing `satisfies_at_iff_mem` (proved sorry-free)
2. Use `FlagBFMCS_completeness` (proved sorry-free) to get `satisfies_at` for `φ.neg`
3. Bridge to `truth_at` using: `satisfies_at B ... φ ↔ φ ∈ (chainFMCS F).mcs x` and a separate lemma `φ ∈ (chainFMCS F).mcs x ↔ truth_at (CanonicalTaskModel Int) (CanonicalOmega B) (flagHistory B F) 0 φ`

The last lemma is exactly what the parametric truth lemma provides, IF we can construct `flagHistory B F : WorldHistory (ParametricCanonicalTaskFrame Int)` and `CanonicalOmega B` appropriately.

---

## Evidence and Examples (with File Paths and Line Numbers)

### satisfies_at definition
`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean`, lines 135–146:
```lean
def satisfies_at (B : FlagBFMCS) (F : Flag CanonicalMCS) (hF : F ∈ B.flags)
    (x : ChainFMCSDomain F) : Formula → Prop
  | .atom p => Formula.atom p ∈ (chainFMCS F).mcs x
  | .bot => False
  | .imp ψ χ => satisfies_at B F hF x ψ → satisfies_at B F hF x χ
  | .box φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      MCSBoxContent x.val.world ⊆ MCSBoxContent x'.val.world →
      satisfies_at B F' hF' x' φ
  | .all_future φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      x.val < x'.val → satisfies_at B F' hF' x' φ
  | .all_past φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
      x'.val < x.val → satisfies_at B F' hF' x' φ
```

Key observation: `satisfies_at` for `all_future` compares `x.val < x'.val` using CanonicalMCS ordering, NOT `D`-ordering. It also ranges over DIFFERENT Flags `F'` — this is cross-Flag.

### truth_at definition
`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`, lines 115–122:
```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F)) (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M Omega τ t φ → truth_at M Omega τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
  | Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
```

### satisfies_at_iff_mem (truth lemma, sorry-free)
`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean`, lines 558–580:
The main truth lemma `satisfies_at_iff_mem` is fully proved (no sorry).

### validity bridge gap (sorry)
`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean`:
The file documents the gap. `algebraic_base_completeness_flagbfmcs` uses a `sorry` for the bridge from `satisfies_at` to `truth_at`/`valid`.

### Existing parametric truth lemma (already works for BFMCS)
`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`, lines 174–184:
```lean
theorem parametric_canonical_truth_lemma
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi ∈ fam.mcs t ↔
      truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
        (parametric_to_history fam) t phi
```

This is EXACTLY the form we need for FlagBFMCS, replacing `BFMCS D` with the FlagBFMCS structure.

### parametric_to_history (converts FMCS → WorldHistory)
`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean`, lines 62–80:
```lean
def parametric_to_history (fam : FMCS D) : WorldHistory (ParametricCanonicalTaskFrame D) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => True.intro
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩
  respects_task := ...
```

Domain is full (all times mapped), states map time `t` to the MCS at `t`.

### chainFMCS structure
`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`:
`chainFMCS F : FMCS (ChainFMCSDomain F)` — an FMCS over `ChainFMCSDomain F`. This is NOT an `FMCS Int`.

---

## Concrete Implementation Steps

### Step 1: Build canonical TaskFrame from FlagBFMCS

Given `B : FlagBFMCS`:

```lean
-- World state = CanonicalMCS (or ParametricCanonicalWorldState)
-- D = chosen ordered abelian group (suggest: D = ℤ for base TM)

noncomputable def canonicalTaskFrame_from_FlagBFMCS : TaskFrame ℤ where
  WorldState := ParametricCanonicalWorldState  -- { M : Set Formula // SetMaximalConsistent M }
  task_rel := parametric_canonical_task_rel    -- already defined
  ...
```

This is just `ParametricCanonicalTaskFrame ℤ`, which already exists.

### Step 2: Build WorldHistory for each Flag

For each `F ∈ B.flags`, we need a `WorldHistory (ParametricCanonicalTaskFrame ℤ)`:

```lean
noncomputable def flagHistory (F : Flag CanonicalMCS) (basePoint : ChainFMCSDomain F) (baseTime : ℤ) :
    WorldHistory (ParametricCanonicalTaskFrame ℤ) where
  domain := fun (t : ℤ) => ∃ x : ChainFMCSDomain F, ...
  states := fun t ht => ⟨(x corresponding to t).val.world, ...⟩
  ...
```

**Problem**: We need to assign a unique ℤ-index to each position in F. Flags may have arbitrary cardinality.

### Step 3: Build Omega from FlagBFMCS

```lean
def FlagBFMCS.Omega (B : FlagBFMCS) : Set (WorldHistory (ParametricCanonicalTaskFrame ℤ)) :=
  { τ | ∃ F ∈ B.flags, τ = flagHistory F ... }
```

Then take shift-closure.

### Step 4: Prove box case

The `satisfies_at` box condition:
```
MCSBoxContent x.val.world ⊆ MCSBoxContent x'.val.world
```
corresponds in `truth_at` to:
```
∀ σ ∈ Omega, truth_at M Omega σ t φ
```
The connection: `σ ∈ Omega` means `σ = flagHistory F' ...` for some F' and time t in F'. The BoxContent condition encodes S5 accessibility across Flags.

This is the hardest correspondence to establish and is why a direct approach (building BFMCS Int from FlagBFMCS) is better than trying to inline the bridge.

### Step 5: Alternative — Use existing ParametricRepresentation directly

`ParametricRepresentation.lean` already provides:
```lean
theorem parametric_algebraic_representation_conditional (phi : Formula) ...
```

This already proves `¬Provable φ → ¬valid φ` assuming a BFMCS construction exists. The key is to PLUG IN FlagBFMCS as the BFMCS construction.

The existing `temporal_coherent_family_exists_CanonicalMCS` (in `CanonicalConstruction.lean`) provides the BFMCS for CanonicalMCS. The FlagBFMCS approach is an ALTERNATIVE ROUTE to the same destination.

**Most practical path**: Show that `allFlagsBFMCS M0` can be converted to a `BFMCS ℤ` satisfying `temporally_coherent`. This conversion is the crux of the work.

---

## Confidence Level

**High confidence** on:
- The `satisfies_at` structure and its complete isomorphism with `truth_at` (modulo type differences)
- The existing `satisfies_at_iff_mem` proof being sorry-free
- The parametric truth lemma being the right target
- `ParametricCanonicalTaskFrame ℤ` being the right canonical TaskFrame

**Medium confidence** on:
- Whether Flags can always be embedded into ℤ without countability/density assumptions on CanonicalMCS
- Whether `ShiftClosedOmega` can be constructed from FlagBFMCS histories without breaking the truth lemma's box case

**Key uncertainty**: The box semantics in `satisfies_at` uses `MCSBoxContent x.val.world ⊆ MCSBoxContent x'.val.world` (BoxContent-to-BoxContent), while in `truth_at` it uses `∀ σ ∈ Omega`. These are COMPATIBLE if Omega is chosen as `{τ_F | F ∈ B.flags}` plus shift-closure, but establishing this precisely requires understanding the relationship between BoxContent-based accessibility and history-based accessibility in the parametric model.

The existing `parametric_canonical_truth_lemma` handles box via BFMCS `modal_forward`/`modal_backward` conditions. FlagBFMCS's `modally_saturated` condition must be shown equivalent to these BFMCS conditions under the embedding. This is the main proof obligation.

---

## Summary

The task asks to bypass `satisfies_at` entirely and build a canonical `TaskFrame` directly from FlagBFMCS, then prove truth_at directly. The recommended approach:

1. Use `D = ℤ` (already satisfies `AddCommGroup Int`, `LinearOrder Int`, `IsOrderedAddMonoid Int`)
2. Use `WorldState = ParametricCanonicalWorldState` (already defined)
3. Use `task_rel = parametric_canonical_task_rel` (already defined)
4. For each Flag F in B.flags, build a WorldHistory by embedding F's positions into ℤ (needs temporal indexing)
5. Set `Omega = ShiftClosedParametricCanonicalOmega` (or its analogue for FlagBFMCS)
6. Prove `φ ∈ (chainFMCS F).mcs x ↔ truth_at CanonicalModel Omega (τ_F) (index x) φ` by adapting `parametric_canonical_truth_lemma`

The parametric canonical infrastructure (`ParametricCanonical.lean`, `ParametricHistory.lean`, `ParametricTruthLemma.lean`) is the right foundation. The gap to fill is the temporal indexing (Step 4) and the box case correspondence (Step 6 box subcase).
