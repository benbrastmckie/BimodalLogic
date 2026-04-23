# Teammate D (Horizons): Solution Proposal from Literature Synthesis

**Task**: 107 - Chain design diagnostics for representation theorem
**Round**: 5 (Literature study)
**Focus**: Bridge literature proofs to the project's 5 sorry sites

---

## 1. Literature Technique Selection

### Recommended: Burgess Chronicle Construction (1982), adapted for reflexive BX

**Why Burgess over Verbrugge**: The project's logic TM is a Since/Until tense logic
over general linear orders, which is precisely the setting of Burgess 1982. Verbrugge's
step-by-step method (dJVV 2004) targets G/H logics without Until/Since as primitive
connectives, then adds Until/Since via density or discreteness axioms. Since TM has
Until/Since as primitives with 7 dedicated axioms (BX5-BX12), Burgess's chronicle
construction -- which was PURPOSE-BUILT for Since/Until completeness -- is the
mathematically correct match.

**Key structural alignment**: Burgess builds "chronicles" (f, g) where f maps
rationals to MCSs and g maps pairs to DCSs (deductively closed sets) representing
"what holds throughout the interval." The g function corresponds exactly to the
project's `g_content` (the G-content of an MCS). The chronicle conditions C0-C5
capture precisely the properties the project needs: C5a is forward_F resolution,
C4a is backward Until/Since guard satisfaction.

**Why not a hybrid**: The Verbrugge method is fundamentally different -- it builds
finite stretches and extends cyclically, which works for discrete structures (Z, Z*n)
but does not directly address Until/Since eventuality discharge on general linear
orders. Since TM targets general linear orders (Int as the concrete instantiation),
Burgess's method is both more general and more directly applicable.

### Critical difference from the current approach

The current `RootScopedChain.lean` attempts to build an **infinite chain** and then
prove F-resolution as a PROPERTY of that chain. This fails because:

1. `set_lindenbaum` (via `Classical.choose`) makes successor MCSs opaque
2. F-obligations cannot be forced through `g_content` (`F(phi) -> G(F(phi))` is not derivable)

Burgess's approach is fundamentally different: he builds chronicles **incrementally**,
one point at a time, fixing one counterexample at each step. The chronicle is the
LIMIT of an omega-sequence of finite extensions, each of which addresses one specific
deficiency (a counterexample to C4a or C5a). This avoids the F-propagation problem
entirely because each extension is PURPOSE-BUILT to resolve a specific obligation.

---

## 2. Concrete Algorithm

### Phase 0: Initial Chronicle

Given a consistent formula phi_0, extend to MCS A_0. Set:
- dom(f_0) = {0}
- f_0(0) = A_0
- g_0 = empty function

This satisfies C0-C3 vacuously. (f_0, g_0) is in F (the set of valid chronicles).

### Phase 1: Iterative Extension (The Core)

Enumerate all potential counterexamples to C4a, C4b, C5a, C5b. At each stage n+1,
fix one counterexample from (f_n, g_n):

**Case C5a** (F-resolution, corresponds to sorry #1): "U(xi, eta) in f(x) but no
y > x with xi in f(y) and eta in g(x,y)."

- Apply Lemma 2.10 (counterexample elimination for C5a)
- Add ONE new point y beyond x (or between x and its successor)
- Set f'(y) = C (an MCS containing xi, constructed via Lemma 2.4)
- Set g'(x,y) = B (a DCS containing eta, maximal w.r.t. r(f(x), -, C))
- Let C3 determine g' for other pairs

**Case C4a** (Until guard satisfaction, corresponds to sorries #4-5):
"neg U(gamma, delta) in f(x) and gamma in f(y) but no z between x and y with
neg delta in f(z)."

- Apply Lemma 2.9 (counterexample elimination for C4a)
- Add ONE new point z between x and y
- Set f'(z) = D (an MCS containing neg delta, constructed via Lemma 2.6)
- Set g'(x,z) and g'(z,y) from Lemma 2.6
- Let C3 determine the rest

**Cases C4b, C5b**: Mirror images for the backward direction (P-resolution,
Since guard). Corresponds to sorries #2-3.

### Phase 2: Taking the Limit

Let X = union of all dom(f_n), f = union of all f_n, g = union of all g_n.
Then (f, g) satisfies C0-C5 (including C4, C5 in both directions).

### Phase 3: Truth Lemma (Claim 2.11)

Define valuation V by: x in V(alpha) iff alpha in f(x).
Prove by formula induction that (+) holds for all alpha:
- For U(beta, gamma): C5a provides the forward witness; C4a provides the
  backward guard satisfaction
- For S: symmetric via C4b, C5b

### How this maps to the 5 sorry sites

| Sorry | Chronicle property | Burgess lemma |
|-------|-------------------|---------------|
| #1 (fwd_chain_forward_F) | C5a: F(phi) resolution | Lemma 2.10 + limit |
| #2 (restricted_tc, bwd chain F-case) | C5a for backward region | Lemma 2.10 (mirror) |
| #3 (restricted_tc, backward P-resolution) | C5b: P(phi) resolution | Lemma 2.10 mirror |
| #4 (restricted_buc) | C4a/C4b: Until/Since guard | Lemma 2.9 + Lemma 2.6 |
| #5 (restricted_fuc) | C5a/C5b: Until/Since forward | Lemma 2.10 + 2.4 |

---

## 3. Infrastructure Mapping: Reuse vs Build

### What CAN be reused (directly)

1. **`ParametricRepresentation.lean`** (sorry-free): The parametric representation
   theorem accepts ANY BFMCS with temporal coherence. If we build a Burgess-style
   chronicle that satisfies `restricted_temporally_coherent`, `restricted_backward_until_since_coherent`,
   and `restricted_forward_until_since_coherent`, the existing sorry-free framework
   produces the completeness theorem. This is the entire upper layer -- ~500 lines
   of sorry-free infrastructure.

2. **`RestrictedParametricTruthLemma.lean`** (sorry-free): Only requires restricted
   coherence, not full coherence. Fully compatible with Burgess chronicles.

3. **`Completeness.lean`** (sorry-free): Calls `dd_countermodel`, which calls
   `fully_restricted_parametric_representation_from_neg_membership`. This can be
   rewired to call a Burgess-style countermodel construction.

4. **`backward_until_from_step` / `backward_since_from_step`** (UntilSinceCoherence.lean,
   sorry-free): Provides backward Until/Since given a step transfer property. Under
   the Burgess construction, step transfer is built into the chronicle (C3: g(x,z) =
   g(x,y) intersection f(y) intersection g(y,z)).

5. **`Frame.lean`** (sorry-free, 673 lines): All BXPoint/MCS infrastructure, including
   `bx_forward_witness`, `bx_backward_witness`, `g_content_closed_derivation`,
   `g_content_set_consistent`. These are the fundamental Lindenbaum lemmas used
   inside each chronicle extension step.

6. **`Quasimodel/Construction.lean`**: `hintikka_step_for_sigma_sig` (sorry-free),
   `defect_count`, `UntilDefect` definitions. These are useful for the BOUNDED
   Until/Since discharge within finite subchronicle segments but are not strictly
   necessary for the Burgess approach.

7. **`Filtration/DefectChain.lean`**: `sigma_defect_count` provides well-founded
   recursion on Until-defects within a sigma-closure. Useful for bounding finite
   chronicle segments.

### What CAN be reused (with adaptation)

1. **`preserving_fwd_step`** (RootScopedChain.lean): The BX11 enriched fold step
   that resolves at least one defect while preserving all F-obligations. Under the
   Burgess approach, this is NOT used for building the main chain but could be
   repurposed for constructing the intermediate DCS B in Lemma 2.4 (the interval
   content between chronicle points).

2. **`enriched_resolving_seed_consistent`** (RootScopedChain.lean): Proves that
   `{psi, alpha} union g_content(M)` is consistent when `F(psi /\ alpha) in M`.
   This is exactly the seed consistency needed for Burgess Lemma 2.4 (constructing
   chronicle successor points).

3. **`defect_resolving_seed` / `defect_fwd_step`** (RootScopedChain.lean):
   General-purpose seed construction for Lindenbaum extension with target resolution.
   Directly applicable to Burgess's point insertion.

4. **`sigma_signature` / `HintikkaPoint`** (Quasimodel/HintikkaPoint.lean):
   Finite-state abstraction of MCSs. Under the Burgess approach, sigma-signatures
   can be used to BOUND the number of chronicle extension steps needed (since
   only finitely many defect types exist within a sigma-closure).

### What MUST be built new

1. **Chronicle structure**: A new type `Chronicle` representing Burgess's (f, g)
   pair satisfying C0-C3. This replaces `dd_chain` / `dd_bfmcs`. Estimated ~150 lines.

   ```
   structure Chronicle where
     points : Finset Rat  -- dom(f), finite at each stage
     f : Rat -> Set Formula  -- MCS assignment
     g : Rat -> Rat -> Set Formula  -- interval DCS
     h_f_mcs : forall x in points, SetMaximalConsistent (f x)
     h_g_dcs : forall x y, x < y -> x in points -> y in points ->
       DeductivelyClosedSet (g x y)
     h_C2 : forall x y, x < y -> x in points -> y in points ->
       r_relation (f x) (g x y) (f y)
     h_C2' : forall x y, immediately_succeeds x y ->
       R_maximal (f x) (g x y) (f y)
     h_C3 : forall x y z, x < y -> y < z ->
       g x z = g x y ∩ f y ∩ g y z
   ```

2. **The r-relation and R-maximality**: Burgess's r(A, beta, C) and R(A, B, C)
   predicates. These encode the interval consistency condition. Estimated ~100 lines.

   ```
   -- r(A, beta, C): for all gamma in C, U(gamma, beta) in A
   def r_formula (A C : Set Formula) (beta : Formula) : Prop :=
     forall gamma in C, Formula.untl gamma beta in A

   -- R(A, B, C): B is maximal w.r.t. r(A, -, C)
   def R_maximal (A B C : Set Formula) : Prop :=
     r_set A B C /\ forall B', B ⊂ B' -> not (r_set A B' C)
   ```

3. **Lemma 2.4** (chronicle point constructor): Given U(gamma, delta) in A,
   construct B, C with beta in B, gamma in C, R(A, B, C). This is the key
   constructor for C5a resolution. Estimated ~200 lines.

   Core argument:
   - Construct C_0 = {gamma} union {S(alpha, beta) : alpha in A}
   - Prove C_0 is consistent using A3a (BX5/BX6 equivalents) + 2.2
   - Lindenbaum extend to C
   - Maximize B w.r.t. r(A, -, C)

4. **Lemmas 2.5-2.8** (chronicle extension lemmas): These handle inserting new
   points into existing chronicles while maintaining C0-C3. Estimated ~400 lines total.

   - 2.5 (composition): R(A,B,C) + r(A,B',D) + r(D,B'',C) + B subset B' cap D cap B''
     implies B = B' cap D cap B''
   - 2.6 (delta-insertion): Given R(A,B,C) and delta not in B, insert a point with
     neg delta between A and C
   - 2.7 (Until-insertion): Given R(A,B,C) and U(xi,eta) in A and eta not in B,
     insert a point with xi between A and C
   - 2.8 (Until-variant): Alternative condition for insertion

5. **Lemmas 2.9-2.10** (counterexample elimination): The main extension lemmas
   that fix C4a and C5a violations. Estimated ~300 lines.

   These use induction on the number of chronicle points between x and y,
   calling 2.4/2.6/2.7/2.8 at the base case.

6. **Limit construction**: Taking the omega-union of chronicles. Estimated ~100 lines.
   Mostly just showing that the union of an increasing chain of chronicles satisfies
   C0-C5.

7. **BFMCS wrapper**: Converting a Burgess chronicle into the project's BFMCS
   interface (the three restricted coherence properties). Estimated ~150 lines.

   The key insight: a chronicle (f, g) over rationals can be mapped to an FMCS over
   Int by choosing a countable subset of the rationals and ordering them as integers.
   Alternatively, the chronicle can be built over Int directly (Burgess uses rationals
   for density, but for Int-indexed FMCS, we just need a total order with no gaps).

### Critical architectural decision: Rat vs Int indexing

Burgess uses rationals because he needs to insert new points between existing ones
(midpoint construction). The project uses Int for FMCS indexing. Two options:

**Option A: Build over Rat, convert to Int at the end.**
The chronicle is built over Rat (natural for midpoint insertion). At the limit,
the countable dense linear order is isomorphic to Q. Then either:
- Use D = Rat for the BFMCS (requires adjusting ParametricRepresentation to Rat)
- Map to Int by choosing an enumeration

**Option B: Build directly over Int with careful bookkeeping.**
At each extension stage, we insert a new point. We can always choose the new
point to be an integer not yet used (instead of a rational midpoint). The
"between x and y" insertion just becomes "right after x" with all subsequent
points shifted. This is more cumbersome but avoids the Rat-to-Int conversion.

**Recommendation: Option A** (Rat indexing). The parametric representation theorem
is already parameterized by D. Instantiate D = Rat. The chronicle construction
over Rat is mathematically natural and avoids index arithmetic complications.
The existing `ParametricRepresentation.lean` already supports arbitrary D.

---

## 4. Implementation Phases

### Phase 1: Foundation (20-30 hours)

**Goal**: Define the chronicle structure, r-relation, R-maximality, and prove
Lemmas 2.2-2.3.

1. Define `r_formula`, `r_set`, `R_maximal` predicates
2. Prove Lemma 2.2 (consistency criterion): U(gamma, delta) in MCS A implies
   gamma is consistent. Uses BX10 (`until_F`) + TG.
3. Prove Lemma 2.3 (r-equivalence): r(A, beta, C) via either the Until or Since
   characterization. Uses BX5 (self_accum_until) + BX4 (connect_future).
4. Define `Chronicle` structure satisfying C0-C3
5. Define `chronicle_extends` and prove basic extension properties

**Reuse**: `g_content_closed_derivation`, `forward_temporal_witness_seed_consistent`,
`set_lindenbaum`, `SetMaximalConsistent` infrastructure from Frame.lean.

### Phase 2: Point Constructor (25-35 hours)

**Goal**: Prove Lemma 2.4 (point construction from U(gamma, delta)) and
Lemmas 2.5-2.6 (composition and delta-insertion).

1. Prove Lemma 2.4: Given U(gamma, delta) in A, construct B, C with
   R(A, B, C) and gamma in C, delta in B.
   - Construct C_0 seed and prove consistency
   - Lindenbaum extend to C
   - Maximize B via Zorn-like argument or explicit construction
2. Prove Lemma 2.5 (composition/intersection identity)
3. Prove Lemma 2.6 (delta-insertion): Given R(A,B,C) and delta not in B,
   insert a point with neg(delta). Uses A4a (BX5 analog), A5a (BX7 analog).

**Reuse**: `enriched_resolving_seed_consistent`, `set_lindenbaum`,
`SetMaximalConsistent.negation_complete`.

### Phase 3: Until-Specific Insertion (20-30 hours)

**Goal**: Prove Lemmas 2.7-2.8 (Until-specific point insertion).

1. Prove Lemma 2.7: Given R(A,B,C) and U(xi,eta) in A and eta not in B,
   insert a point with eta in B' and xi in D.
   Uses A5a (BX7), A7a (BX11/linear_until), A3a (BX5).
2. Prove Lemma 2.8 (variant for neg(xi or (eta and U(xi,eta))) in C).

**Reuse**: `bx11_earlier`, `linear_until` axiom infrastructure.

### Phase 4: Counterexample Elimination (15-25 hours)

**Goal**: Prove Lemmas 2.9-2.10 (fixing C4a and C5a violations).

1. Prove Lemma 2.9 (C4a fix): By induction on the number of points between
   x and y. Base case uses Lemma 2.6; inductive case reduces.
2. Prove Lemma 2.10 (C5a fix): By induction on the number of points after x.
   Base case uses Lemma 2.4; inductive case uses 2.7 or 2.8.

### Phase 5: Limit and BFMCS Construction (15-20 hours)

**Goal**: Build the omega-limit chronicle and wire it into the BFMCS interface.

1. Define the enumeration of counterexamples (countable, each occurring
   infinitely often in the enumeration)
2. Define (f_n, g_n) sequence and prove each extends the previous
3. Take the limit (f, g) and prove C0-C5
4. Convert chronicle to BFMCS:
   - Each family is a time-shifted version of the chronicle
   - Modal saturation via bx_modal_witness (already sorry-free)
   - restricted_temporally_coherent follows from C5a/C5b
   - restricted_backward_until_since_coherent follows from C4a/C4b + C3
   - restricted_forward_until_since_coherent follows from C5a/C5b + C3
5. Wire into `dd_countermodel` or its replacement

### Phase 6: Integration and Cleanup (10-15 hours)

**Goal**: Replace the 5 sorry sites and verify compilation.

1. Replace `dd_bfmcs` with Burgess chronicle-based construction
2. Prove `dd_bfmcs_restricted_tc` from chronicle C5a/C5b
3. Prove `dd_bfmcs_restricted_buc` from chronicle C4a/C4b
4. Prove `dd_bfmcs_restricted_fuc` from chronicle C5a/C5b
5. `lake build` to verify zero sorries on active path
6. Run `#print axioms bx_completeness` to verify clean axiom set

**Total estimated effort: 105-155 hours** (roughly 13-19 working days).

---

## 5. Risk Assessment

### LOW risk

1. **Lemma 2.2 (consistency criterion)**: Direct application of BX10 + TG.
   Already have `until_F_in_mcs` and similar infrastructure. Confidence: 95%.

2. **Lemma 2.3 (r-equivalence)**: Uses BX5/BX4, which are already formalized
   as `self_accum_until` and `connect_future`. Confidence: 90%.

3. **Limit construction**: Standard omega-union argument. No deep mathematical
   content. Confidence: 95%.

4. **BFMCS wrapper**: The interface requirements are well-understood. The
   parametric framework accepts any D. Confidence: 90%.

### MEDIUM risk

5. **Lemma 2.4 (point construction)**: Requires constructing a consistent
   seed C_0 and proving consistency. The Lindenbaum extension part is routine,
   but the consistency argument uses BX5 (self_accum_until) in a way that may
   need careful term-level encoding. Confidence: 75%.

6. **Lemma 2.6 (delta-insertion)**: The consistency proof for D_0 is the most
   complex part of Burgess's paper. It requires BX5, BX7 (linear_until),
   and BX4 (connect_future) in combination. The argument is intricate but
   self-contained. Confidence: 70%.

7. **Lemmas 2.7-2.8 (Until-specific insertion)**: Uses BX11 (linear_until)
   in a 3-way case analysis. The project already has `temp_linearity_mcs`
   and `bx11_earlier` infrastructure. The main risk is ensuring the
   reflexive BX semantics (with BX8/BX9) don't introduce edge cases
   not present in Burgess's original strict-semantics proof. Confidence: 65%.

8. **Reflexive vs strict semantics adaptation**: Burgess's proof uses strict
   Until semantics (witness s strictly after t, guard on open interval (t,s)).
   TM uses reflexive Until (witness s >= t, guard on half-open [t,s)). This
   changes:
   - F(phi) = U(phi, T) becomes phi OR F_strict(phi) under reflexive semantics
   - BX8 (psi -> phi U psi) is only sound under reflexive semantics
   - The r-relation definition needs adjustment for reflexive Until
   
   The adaptation should be straightforward because reflexive Until is STRONGER
   (more formulas are Until-valid), but care is needed. Confidence: 70%.

### HIGH risk

9. **BX axiom correspondence**: Burgess uses axioms A1a-A7a which do NOT
   exactly match BX1-BX12. The correspondence is:
   - A1a ~ BX2 (left_mono_until)
   - A2a ~ BX3 (right_mono_until)
   - A3a ~ BX4+BX5 (connect_future + self_accum_until)
   - A4a: Needs derivation from BX axioms
   - A5a ~ BX7 (self_accum_until ... wait, BX7 is linear_until)
   - A6a ~ BX6 (absorb_until)
   - A7a ~ BX11 (temp_linearity / linear_until)
   
   The exact derivations need verification. Some of Burgess's axioms may
   require multi-step derivations from the BX axioms. If any Burgess axiom
   is NOT derivable from BX1-BX12, the approach fails. Confidence: 60%.

   **Specific concern: A3a and A4a.**
   
   A3a: `p /\ U(q, r) -> U(q /\ S(p, r), r)`. This uses the Since
   connective inside the Until. BX has separate Until/Since axioms
   but A3a connects them. This must be derivable from BX4 (connect_future)
   + BX5 (self_accum_until) + BX3 (right_mono_until).
   
   A4a: `U(p, q) /\ ~U(p, r) -> U(q /\ ~r, q)`. This is a disjunction
   axiom for Until. It must be derivable from BX7 (linear_until) or
   BX11 (temp_linearity). If BX does not have this exactly, it may need
   a separate derivation.

10. **The backward direction (P/Since)**: Burgess's proof handles the backward
    direction via "mirror images" of all lemmas. The project's backward chain
    (`bwd_chain_of_sigma`) lacks the preserving step infrastructure that the
    forward chain has. Building `preserving_bwd_step` and its properties is
    additional work (~10-15 hours) but follows the same pattern. Confidence: 75%.

### Remaining unknowns

1. **Does BX derive all of Burgess's axioms A1a-A7a?** This is the single
   most critical verification needed before committing to implementation.
   If any axiom is not derivable, we need to find an alternative proof path
   or add the axiom to TM.

2. **Does the reflexive adaptation of the r-relation preserve Lemma 2.3?**
   The equivalence between the Until and Since characterizations of r may
   be sensitive to the reflexive/strict distinction.

3. **Is the Rat-indexed chronicle compatible with Int-indexed BFMCS?**
   The parametric framework accepts any D, so Rat should work. But the
   shift-closed omega needs careful handling.

---

## 6. Confidence Level per Component

| Component | Confidence | Risk Level | Notes |
|-----------|-----------|------------|-------|
| Chronicle structure (C0-C3) | 90% | Low | Standard definition |
| r-relation / R-maximality | 85% | Low | Direct from Burgess |
| Lemma 2.2 (consistency criterion) | 95% | Low | Already have infrastructure |
| Lemma 2.3 (r-equivalence) | 85% | Low-Med | BX4+BX5 needed |
| Lemma 2.4 (point constructor) | 75% | Medium | Core consistency argument |
| Lemma 2.5 (composition) | 80% | Medium | Uses BX6 (absorb_until) |
| Lemma 2.6 (delta-insertion) | 70% | Medium | Complex consistency proof |
| Lemma 2.7 (Until-insertion) | 65% | Medium-High | BX11 3-way case analysis |
| Lemma 2.8 (Until-variant) | 65% | Medium-High | Variant of 2.7 |
| Lemma 2.9 (C4a fix) | 75% | Medium | Induction on point count |
| Lemma 2.10 (C5a fix) | 75% | Medium | Induction, calls 2.4/2.7/2.8 |
| Limit construction | 95% | Low | Standard omega-union |
| BFMCS wrapper | 85% | Low | Interface already defined |
| BX axiom correspondence | 60% | High | A3a, A4a need verification |
| Reflexive adaptation | 70% | Medium | Edge cases possible |
| Backward (P/Since) direction | 75% | Medium | Mirror of forward |

**Overall confidence**: 65-70%. The main risk is the BX axiom correspondence
(item 9 above). If all Burgess axioms are derivable from BX, confidence rises
to 80-85%.

---

## 7. Recommended First Steps

Before committing to full implementation:

1. **Axiom derivation check (4-6 hours)**: Verify that Burgess axioms A1a-A7a
   (and their mirror images) are derivable from BX1-BX12. This is a GATE
   condition. Use `lean_run_code` to verify each derivation compiles.

2. **r-relation prototype (4-6 hours)**: Define the r-relation for reflexive
   BX and verify Lemma 2.3 compiles. This tests the reflexive adaptation.

3. **Lemma 2.4 prototype (8-12 hours)**: Implement the core point constructor.
   This is the mathematical heart of the approach. If it works, the rest is
   engineering.

If all three prototypes succeed, proceed with full implementation (Phases 1-6).
If the axiom derivation check fails for any axiom, assess whether the missing
axiom can be derived via an alternative route or whether a different proof
technique is needed.

---

## 8. Alternative if Burgess Fails

If the BX axiom correspondence fails (some Burgess axiom is not derivable from
BX1-BX12), the fallback is:

**Modified Verbrugge approach for Until/Since**: Build the chronicle using the
existing quasimodel infrastructure (`hintikka_step_for_sigma_sig`, `defect_count`,
`sigma_signature`) to handle Until/Since discharge within bounded segments, then
assemble segments into a full chronicle. This is more complex but uses infrastructure
that is already sorry-free.

The quasimodel approach handles F-resolution via finite defect-discharge chains
(bounded by |Sigma|), which avoids the infinite-chain F-propagation problem.
The remaining challenge is wiring the quasimodel BXPoint chains into the Int-indexed
FMCS/BFMCS format (dead end #25 from ROADMAP), but this is an engineering problem,
not a mathematical one.
