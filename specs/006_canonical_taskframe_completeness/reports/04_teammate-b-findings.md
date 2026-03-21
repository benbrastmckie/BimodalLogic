# Research Report: Task #1006 (Teammate B)

**Task**: Canonical TaskFrame Completeness - Alternative Approaches to Order-Preserving Embedding
**Date**: 2026-03-19
**Focus**: Alternative approaches and prior art for the Phase 2 blocker (non-order-preserving embedding)

---

## Key Findings

### Finding 1: The Blocker Is Real — `enum_mcs` Is Injective But Not Order-Preserving

The Phase 2 blocker is confirmed by studying how `ParametricHistory.lean` uses an `FMCS D`. The
`parametric_to_history` function converts an `FMCS D` to a `WorldHistory` by setting:

```lean
-- ParametricHistory.lean lines 62-90
states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩
respects_task := ...  -- uses fam.forward_G
```

The `respects_task` proof (line 81) calls `fam.forward_G s t phi h_lt h_G_phi` where `h_lt : s < t`
refers to **D-ordering** (not CanonicalR). So `forward_G` must hold for D-order, i.e., if `s < t`
in D, then `G(phi) ∈ mcs(s) → phi ∈ mcs(t)`.

For an `FMCS Int` built from FlagBFMCS via an enum `enum_mcs : CanonicalMCS → Int`, this means:
`n < m` in Int must imply `CanonicalR (mcs_at n) (mcs_at m)`.
But `enum_mcs` is an arbitrary enumeration — no order-preservation guarantee.
**This confirms the blocker is fundamental, not incidental.**

---

### Finding 2: The Parametric Infrastructure Does NOT Need D = Int

The key insight from studying `ParametricCanonical.lean` (lines 73, 199-206) is:

```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

def ParametricCanonicalTaskFrame (D : Type*) [...] : TaskFrame D where
  WorldState := ParametricCanonicalWorldState   -- ALL MCSes, not just chain elements
  task_rel := parametric_canonical_task_rel      -- uses CanonicalR, not D-order
```

The `WorldState` is ALL MCSes (`ParametricCanonicalWorldState = {M : Set Formula // SetMaximalConsistent M}`).
The task_rel uses `CanonicalR` (via sign-based case analysis on d). **D is only used for the
duration parameter; the worlds themselves are all MCSes.**

The critical implication: `D` need not "embed" CanonicalMCS at all. `D` is the time axis;
`WorldState` is the space of worlds. These are orthogonal.

---

### Finding 3: The FMCS Needed Is Not an Embedding — It's a Schedule

The `FMCS D` interface (FMCSDef.lean) requires:
- `mcs : D → Set Formula` — any function from times to MCSes
- `forward_G : ∀ t t' phi, t < t' → G(phi) ∈ mcs t → phi ∈ mcs t'` — order on D must match CanonicalR

So an `FMCS Int` is NOT an injection of CanonicalMCS into Int. It is a **schedule**: a function
`Int → CanonicalMCS` such that whenever `n < m` in Int, `CanonicalR (mcs n) (mcs m)`.

**The schedule does not need to enumerate all CanonicalMCS.** It only needs to:
1. Place the root MCS `M₀` at some time (e.g., `mcs 0 = M₀`)
2. Satisfy forward_G: `n < m → G(phi) ∈ mcs(n) → phi ∈ mcs(m)`
3. Satisfy backward_H: `m < n → H(phi) ∈ mcs(n) → phi ∈ mcs(m)`

This is exactly what `chainFMCS F` does! It schedules the Flag `F` (a chain in CanonicalMCS)
as a function `ChainFMCSDomain F → Set Formula`, where `w.val < w'.val` in CanonicalMCS
implies `CanonicalR w.val.world w'.val.world`, giving forward_G for free.

---

### Finding 4: The Core Approach — Use D = ChainFMCSDomain F With a Group Structure

`ChainFMCSDomain F` is defined as `{w : CanonicalMCS // w ∈ flag}` (ChainFMCS.lean line 542).
It inherits the CanonicalMCS `Preorder` (reflexive closure of CanonicalR). The total order on
a Flag comes from `chainFMCS_pairwise_comparable` (line 550-552).

**The problem**: `ChainFMCSDomain F` is a subtype of a preorder, not an `AddCommGroup`.

**Alternative 1 — Use CanonicalMCS directly as D (BLOCKED)**:
`CanonicalMCS` has a preorder, but `FMCS` and `ParametricCanonicalTaskFrame` require
`AddCommGroup`. There is no canonical group structure on `CanonicalMCS`.

**Alternative 2 — Use D = Int and build an order-preserving FMCS Int (MAIN APPROACH)**:
Build `mcs : Int → Set Formula` by placing Flag chain elements at integer positions:
- `mcs 0 = M₀.world` (root)
- `mcs 1 = next element in Flag above M₀`
- `mcs (-1) = next element in Flag below M₀`
- etc.

This gives `n < m` in Int iff `mcs n` and `mcs m` are adjacent in the Flag order,
so `CanonicalR (mcs n) (mcs m)` holds. This is **order-preserving by construction**.

The construction is possible without a countable embedding of ALL CanonicalMCS — only the
elements of one Flag F need to be scheduled, and a Flag is countable (formulas are countable,
each MCS is a set of formulas from a countable language, and Flags are chains in this order).

---

### Finding 5: The Dovetailing Gap Is the REAL Blocker — forward_F and backward_P

The plan's Phase 2 focuses on `forward_G`/`backward_H`, but the harder problem is
`forward_F`/`backward_P` required by `TemporalCoherentFamily` (TemporalCoherence.lean lines 149-153):

```lean
forward_F : ∀ t : D, ∀ φ, some_future φ ∈ mcs t → ∃ s : D, t < s ∧ φ ∈ mcs s
backward_P : ∀ t : D, ∀ φ, some_past φ ∈ mcs t → ∃ s : D, s < t ∧ φ ∈ mcs s
```

These are needed by `temporal_backward_G` (TemporalCoherence.lean line 166), which is called in
`parametric_canonical_truth_lemma` and `parametric_shifted_truth_lemma` for the G/H backward cases.

**IntBFMCS.lean** (lines 16-33) documents this as a **FUNDAMENTAL LIMITATION**: any linear chain
construction fails to prove `forward_F`/`backward_P` without dovetailing. The witness from
`canonical_forward_F` may not be in the chain.

**CanonicalFMCS.lean** (lines 23-40) provides the working alternative: use ALL CanonicalMCS as
domain. Then `forward_F`/`backward_P` are trivial because every CanonicalMCS is already a domain
element. But `CanonicalMCS` lacks `AddCommGroup` structure.

---

### Finding 6: FlagBFMCS Sidesteps the Group Problem Entirely

The existing `FlagBFMCS` approach (FlagBFMCSTruthLemma.lean) proves a complete truth lemma
`satisfies_at_iff_mem` WITHOUT requiring `AddCommGroup`. The temporal quantification in
`satisfies_at` (lines 143-146) uses `x.val < x'.val` (CanonicalMCS ordering), not D-ordering:

```lean
| .all_future φ => ∀ (F' : Flag CanonicalMCS) (hF' : F' ∈ B.flags) (x' : ChainFMCSDomain F'),
    x.val < x'.val → satisfies_at B F' hF' x' φ
```

And the truth lemma's G-backward case (`mem_of_satisfies_at_all_future`,
FlagBFMCSTruthLemma.lean lines 300-367) uses `temporal_complete` + `canonicalMCS_in_some_flag`
to find witnesses directly in CanonicalMCS. No `forward_F` proof needed.

**Critical Insight**: The FlagBFMCS truth lemma avoids the `forward_F`/`backward_P` problem
entirely by using cross-Flag quantification with `temporally_complete`. The parametric BFMCS
approach requires `forward_F`/`backward_P`, which is the hard part.

---

### Finding 7: The "Flip the Perspective" Alternative Is Viable

The research prompt asks: "What if we use Int but define the FMCS differently?"

**Concrete approach**: Define `mcs : Int → Set Formula` using the CANONICAL FMCS (all CanonicalMCS)
evaluated at different "times" identified with arbitrary integers. Since the parametric machinery
only needs `forward_G` and `backward_H` (not `forward_F`/`backward_P`) for `ParametricTruthLemma`
itself — `forward_F`/`backward_P` are only needed for the temporal backward lemmas called inside
the truth lemma.

But wait — looking at `parametric_shifted_truth_lemma` lines 421-460, the G-backward and H-backward
cases DO call `temporal_backward_G` and `temporal_backward_H`, which DO need `forward_F`/`backward_P`.
So you cannot avoid them.

**Alternative angle**: What if we bypass `BFMCS D` entirely and prove a version of the
truth lemma that ONLY needs `chainFMCS` structure (no `forward_F`/`backward_P`)?

Looking at the truth lemma proof structure in `parametric_canonical_truth_lemma`:
- The G-backward case (lines 286-293) creates a `TemporalCoherentFamily D` using `h_tc fam hfam`
- `h_tc` is `B.temporally_coherent`, which supplies `forward_F`/`backward_P`

**So temporal completeness is strictly necessary for the parametric truth lemma.**

---

### Finding 8: Three Viable Alternative Approaches

#### Approach A: Stay With FlagBFMCS (No Embedding Needed)

The `satisfies_at`-based truth lemma already works. The only problem is connecting it to `valid`
(which requires `TaskFrame D` with `D : AddCommGroup`).

**Key observation**: `valid phi` requires:
```lean
def valid (phi : Formula) : Prop :=
  ∀ D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
  ∀ (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F)) (ShiftClosed Omega),
  ∀ tau ∈ Omega, ∀ t, truth_at M Omega tau t phi
```

To prove `¬valid phi` (for completeness proof), we only need ONE counterexample — ONE specific
`D`, `F`, `M`, `Omega`, `tau`, `t` where `phi` fails. We can choose `D = Int`.

The question is: can we build an `FMCS Int` from a specific Flag F such that the truth lemma
connects MCS membership to `truth_at`?

**Yes, if we use the dovetailing chain from a specific Flag.** The dovetailing chain within ONE
Flag provides `forward_F`/`backward_P` witnesses IF we accept that witnesses may come from
a DIFFERENT Flag (which `allFlagsBFMCS` handles). But for `FMCS Int`, the witnesses must be
at Int positions in the SAME family.

#### Approach B: Use CanonicalMCS as D With Artificial Group Structure (BLOCKED)

Adding `AddCommGroup` to `CanonicalMCS` is mathematically incoherent — there's no natural group
operation on MCSes.

#### Approach C: Use a Two-Stage Construction

**Stage 1**: Use the FlagBFMCS truth lemma (`satisfies_at_iff_mem`) to show `phi` is false
at `(B.eval_flag, B.eval_element)`.

**Stage 2**: Construct a specific `BFMCS Int` from `allFlagsBFMCS` where:
- The `FMCS Int` for each Flag F maps integers to MCSes using the canonical ordering within F
- `forward_F`/`backward_P` are handled by the `temporally_complete` property of `allFlagsBFMCS`

This is essentially the plan's current approach, blocked only by Phase 2's `forward_F`/`backward_P`.

#### Approach D (RECOMMENDED): Use CanonicalFMCS Over All CanonicalMCS With a Fake D

**The key insight**: `ParametricCanonicalTaskFrame D` has `WorldState = ParametricCanonicalWorldState`
(ALL MCSes) and `task_rel` using `CanonicalR`. The parameter `D` is only used for the time type.

We can use `D = Int` and build an `FMCS Int` that maps integers to MCSes using a dovetailed
schedule of ALL CanonicalMCS (not just one Flag). Such a schedule:
1. Is countable (CanonicalMCS is countable since formulas form a countable language)
2. Covers every CanonicalMCS at some Int position
3. Provides `forward_F`/`backward_P` by the dovetailing coverage
4. Satisfies `forward_G`/`backward_H` via CanonicalR transitivity

**This is the dovetailing chain from IntBFMCS.lean** — but it requires resolving the
fundamental dovetailing gap documented there. The resolution is available: task 1004
proved `DovetailedCoverage` using `DovetailedBuild`.

---

## Recommended Approach

### Short-Term (Unblock Phase 2): Accept the Non-Order-Preserving Embedding

The plan's Phase 2 — building `FMCS Int` from Flag chains — is blocked because
`enum_mcs` is NOT order-preserving. The fix is:

**Do not embed ChainFMCSDomain F into Int via enum_mcs.** Instead:

1. Use a **single specific Flag** `F = B.eval_flag` from `allFlagsBFMCS`.
2. Since `F` is a chain in `CanonicalMCS`, and `CanonicalMCS` is countable, there exists
   an order-isomorphism `σ : ChainFMCSDomain F ↪o Int` (order-embedding into Int).
3. Define `mcs_int : Int → Set Formula` by:
   - `mcs_int n = (chainFMCS F).mcs (σ⁻¹ n)` for `n ∈ range(σ)`
   - `mcs_int n = M₀.world` for `n ∉ range(σ)` (constant extension)
4. The constant extension means `forward_G`/`backward_H` hold for ALL Int pairs,
   since `G(phi) ∈ M₀.world → phi ∈ M₀.world` (by T-axiom) for the constant part.
5. For `forward_F`/`backward_P`, the witnesses are in range(σ) (within the flag),
   since the Flag contains all Flag-reachable F/P witnesses.

**BUT**: Flag F may not contain ALL F/P witnesses. The dovetailing gap reappears.

### Long-Term (Correct) Approach: Use allFlagsBFMCS Temporal Completeness Directly

The FlagBFMCS truth lemma (`satisfies_at_iff_mem`) already proves what's needed.
The completeness theorem `FlagBFMCS_completeness` already works.

To connect to `valid`, we need a bridge theorem:

```lean
theorem flagbfmcs_implies_not_valid (B : FlagBFMCS) (h_complete : B.temporally_complete)
    (phi : Formula) (h_neg_mem : phi.neg ∈ B.root.world) :
    ¬valid phi
```

This does NOT require building a `BFMCS Int` at all. Instead:
1. `satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element phi.neg` (by truth lemma backward)
2. `¬ satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element phi` (by consistency)
3. Interpret `satisfies_at` as truth in a specific bimodal frame structure
4. Show this frame falsifies `phi`, hence `¬ valid phi`

**The gap**: `valid phi` is phrased in terms of `truth_at` in a `TaskFrame D` with `D : AddCommGroup`.
The FlagBFMCS `satisfies_at` does not directly produce a `TaskFrame D` countermodel.

**The actual recommended fix**: Prove that `satisfies_at` and `truth_at` agree for a
specifically constructed `TaskFrame (ChainFMCSDomain B.eval_flag)` where we add an
`AddCommGroup` instance artificially. Since `ChainFMCSDomain F` is a linear order of countable
type, it is isomorphic to `Int` as an ordered set (or a countable ordinal). Define
addition on `ChainFMCSDomain F` via this isomorphism.

**But this requires `ChainFMCSDomain F` to be infinite** (which it may not be in finite cases).

### Simplest Correct Path

The simplest path that avoids all these problems:

1. Keep the FlagBFMCS completeness theorem (`FlagBFMCS_completeness`) as the main result.
2. Prove `¬ valid phi` by constructing a Kripke countermodel directly from FlagBFMCS data,
   bypassing `truth_at` and `TaskFrame` entirely.
3. Show the bimodal Kripke semantics used by FlagBFMCS is equivalent to the `valid`-based
   semantics for the purposes of completeness.

OR more precisely:

**Do NOT need `forward_F`/`backward_P` if using allFlagsBFMCS**. The `parametric_shifted_truth_lemma`
DOES need `temporally_coherent` (which requires `forward_F`/`backward_P`). But if we can use the
FlagBFMCS truth lemma DIRECTLY (without going through `BFMCS Int`), we skip the problem entirely.

The question reduces to: **Does `valid phi` need to be the final statement, or can we prove
completeness using the FlagBFMCS `satisfies_at` definition and later bridge to `valid`?**

Looking at `FlagBFMCS_completeness` (FlagBFMCSCompleteness.lean lines 92-122), this is already
proven. The remaining work for task 1006 is exactly connecting `satisfies_at` to `valid`.

---

## Evidence/Examples

### File: `ParametricHistory.lean` — Key Evidence for Finding 1
- Lines 62-90: `parametric_to_history` — `forward_G` uses D-ordering directly
- The proof at line 81: `exact fam.forward_G s t phi h_lt h_G_phi` where `h_lt : s < t` is D-order

### File: `ParametricCanonical.lean` — Key Evidence for Finding 2
- Lines 63-64: `ParametricCanonicalWorldState := { M : Set Formula // SetMaximalConsistent M }`
- Lines 85-89: `parametric_canonical_task_rel` — uses `CanonicalR`, not D-order

### File: `TemporalCoherence.lean` — Key Evidence for Finding 5
- Lines 147-153: `TemporalCoherentFamily` requires `forward_F`/`backward_P`
- Lines 166-179: `temporal_backward_G` proof uses `forward_F`

### File: `IntBFMCS.lean` — Key Evidence for Finding 5
- Lines 16-33: FUNDAMENTAL LIMITATION documented — any linear chain fails `forward_F`/`backward_P`
- Lines 34-43: CanonicalFMCS is the working alternative

### File: `FlagBFMCSTruthLemma.lean` — Key Evidence for Finding 6
- Lines 57-79: `FlagBFMCS.temporally_complete` — alternative to `forward_F`/`backward_P`
- Lines 143-146: `satisfies_at` for G/H uses cross-Flag quantification with CanonicalMCS ordering

### File: `FlagBFMCSCompleteness.lean` — Key Evidence for Finding 8
- Lines 92-122: `FlagBFMCS_completeness_set` — complete truth lemma already proven
- Lines 51-58: `FlagBFMCS_satisfies_root` — root MCS formulas are satisfied

### File: `IntFMCSTransfer.lean` — Key Evidence for Finding 5
- Lines 102-134: `singleFamilyBFMCS_Int` — `modal_backward` is sorry'd with clear explanation
- Lines 179-194: `construct_bfmcs_from_mcs_Int` — currently has 3 sorries (F/P + modal_backward)

---

## Confidence Level: High

**Why high**: The analysis is grounded in the actual proof architecture. The blocker (non-order-
preserving `enum_mcs`) is real and confirmed by examining `parametric_to_history`. The
alternatives are clearly articulated: either fix the embedding (requires dovetailing from task 1004)
or bypass it entirely (using FlagBFMCS truth lemma directly + bridge to `valid`).

The recommended path is:

1. **Phase 2 fix**: Instead of embedding via `enum_mcs`, use a **Flag-order-preserving mapping**
   where integer `n` maps to the `n`-th element of the Flag chain (using `Nat.find` + countability).
   For elements outside the flag range, extend with the root MCS. This gives order-preservation
   for elements within the flag, and the constant extension trivially satisfies forward_G (T-axiom).

2. **Phase 2 forward_F fix**: Accept that `forward_F`/`backward_P` witnesses may not be in the
   same flag. Use the `allFlagsBFMCS` + `temporally_complete` approach: define the `BFMCS Int`
   with `families = { intFMCS_from_flag F | F : Flag CanonicalMCS }` and prove `temporally_coherent`
   using `allFlagsBFMCS_temporally_complete`. The `forward_F` witness for `intFMCS_from_flag F`
   at position `n` is found by: (a) convert `n` back to Flag element `w`, (b) apply
   `canonicalMCS_forward_F`, (c) get witness `s` in CanonicalMCS, (d) use `canonicalMCS_in_some_flag`
   to find a Flag `F'` containing `s`, (e) convert `s` to a position in `intFMCS_from_flag F'`.

   **This DOES work** because the BFMCS families include ALL flags, so the witness is in some family.

---

## Summary of Alternative Approaches

| Approach | Blocks On | Effort | Recommended? |
|----------|-----------|--------|--------------|
| Fix enum_mcs to be order-preserving | Must enumerate Flag chain in order | Low | YES (Phase 2) |
| Use CanonicalMCS as D | No AddCommGroup on CanonicalMCS | N/A | NO |
| FlagBFMCS → BFMCS Int via all flags | forward_F needs cross-flag witnesses | Medium | YES (correct) |
| Stay with FlagBFMCS satisfies_at + bridge | Bridge from satisfies_at to valid | Medium | YES (cleanest) |
| CanonicalFMCS over all MCS + arbitrary D | D-ordering vs CanonicalR mismatch | High | NO |

**Bottom line**: The order-preserving issue in Phase 2 is solvable by enumerating the Flag chain
in order (not all CanonicalMCS). The `forward_F`/`backward_P` issue is solvable by using
`families = all flags` in the BFMCS Int construction. Both fixes together unblock Phase 2.
