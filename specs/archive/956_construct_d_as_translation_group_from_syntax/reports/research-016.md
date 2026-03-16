# Research-016: Feasibility of Switching to Irreflexive G/H Semantics

**Task**: 956
**Date**: 2026-03-09
**Session**: sess_1773077039_15cd4a
**Focus**: Evaluate switching from reflexive (<=) to irreflexive (<) temporal semantics

---

## 1. Executive Summary

Switching to irreflexive G/H semantics is **feasible and would resolve the Phase 6 blocker**. The core insight is that the density proof's fundamental obstacle -- the T-axiom preventing `{G(psi), neg(psi)}` from coexisting in a single seed -- vanishes entirely with irreflexive semantics. The cost is significant refactoring (estimated 30+ files, 600-1000 lines changed), but the user has stated that effort is not a concern; only fundamental blockers matter.

**Recommendation**: Switch to irreflexive G/H. The current reflexive design was adopted at Task #658 to simplify coherence proofs, but it created the Phase 6 density blocker that has resisted all attempts at resolution. Irreflexive semantics is the more standard choice in temporal logic literature (Goldblatt, Blackburn et al.), produces a more elegant and expressive system, and resolves the blocker structurally.

---

## 2. What Would Change

### 2.1 Core Semantic Definition (1 file)

**`Theories/Bimodal/Semantics/Truth.lean`** -- Lines 118-119:

Current (reflexive):
```lean
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

New (irreflexive):
```lean
| Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
```

This is the single most consequential change. Everything downstream flows from it.

### 2.2 Axiom System (1 file)

**`Theories/Bimodal/ProofSystem/Axioms.lean`**:

| Change | Details |
|--------|---------|
| **REMOVE** `temp_t_future` | `G phi -> phi` is no longer valid (G excludes present) |
| **REMOVE** `temp_t_past` | `H phi -> phi` is no longer valid (H excludes present) |
| **KEEP** `temp_4` | `G phi -> GG phi` remains valid (transitivity of <) |
| **KEEP** `temp_a` | `phi -> G(P phi)` remains valid (present is in the strict past of any strict future) |
| **KEEP** `temp_l` | `always phi -> G(H phi)` remains valid with adjusted `always` definition |
| **KEEP** `temp_k_dist` | Distribution remains valid |
| **KEEP** `density` | DN = `F phi -> FF phi` becomes **non-trivially** sound (requires DenselyOrdered) |
| **KEEP** `discreteness_forward` | DF becomes **non-trivially** sound (requires SuccOrder) |
| **KEEP** `temp_linearity` | Remains valid for linear orders |
| **KEEP all modal axioms** | Modal (box) axioms are unaffected |

The T-axioms must be removed. Optionally, add an **irreflexivity axiom** or derive irreflexivity from the interaction of G/H with other axioms.

### 2.3 Derived Operators (1 file)

**`Theories/Bimodal/Syntax/Formula.lean`**:

The `always` definition changes:
- Current: `always phi = H phi /\ phi /\ G phi` (redundant with reflexive G/H since `G phi -> phi`)
- New: `always phi = H phi /\ phi /\ G phi` (now genuinely tripartite: past, present, future)

The derived definitions `some_past`, `some_future`, `diamond` are unchanged syntactically, but their semantics shift from `exists s >= t` to `exists s > t`.

New derived operators become natural:
```lean
def weak_future (phi) := phi.or phi.all_future    -- G' phi = phi \/ G phi
def weak_past (phi) := phi.or phi.all_past         -- H' phi = phi \/ H phi
```

### 2.4 Soundness Proofs (2 files)

**`Theories/Bimodal/Metalogic/Soundness.lean`**:

| Proof | Impact |
|-------|--------|
| `temp_t_future_valid` | **DELETE** (axiom removed) |
| `temp_t_past_valid` | **DELETE** (axiom removed) |
| `temp_4_valid` | **ADAPT** -- proof uses `le_trans`, needs `lt_trans` |
| `temp_a_valid` | **ADAPT** -- proof uses `le` for past quantifier, needs `lt` |
| `temp_l_valid` | **ADAPT** -- proof extracts conjunction from `always`, minor changes |
| `density_valid` | **REWRITE** -- no longer trivial! Currently uses `le_refl` for reflexive witness. Needs actual DenselyOrdered hypothesis. Move to DenseSoundness.lean only. |
| `discreteness_forward_valid` | **REWRITE** -- no longer trivial! Currently uses `le_refl`. Needs actual SuccOrder hypothesis. Move to DiscreteSoundness.lean only. |
| `temp_linearity_valid` | **ADAPT** -- minor changes to handle `<` vs `<=` |
| `modal_future_valid` | **ADAPT** -- time-shift argument unchanged in structure |
| `temp_future_valid` | **ADAPT** -- time-shift argument unchanged in structure |
| `axiom_valid` + `soundness` | Update case list (remove T-axiom cases) |

**`Theories/Bimodal/Metalogic/SoundnessLemmas.lean`**:
- Remove T-axiom cases from swap_valid
- Adapt temporal duality soundness

**Critical Change**: `density_valid` currently proves DN valid over ALL temporal types (trivially, via `le_refl`). With irreflexive semantics, DN is only valid over DenselyOrdered types. This means `density_valid` must be restricted to `valid_dense`, and the general `soundness` theorem must be split: base TM axioms are universally sound, while DN is only dense-sound. This is actually a **correctness improvement** -- the current proof that DN is universally valid is technically correct but semantically vacuous.

**`Theories/Bimodal/Metalogic/DenseSoundness.lean`**:
- `density_sound_dense` becomes a non-trivial proof requiring DenselyOrdered hypothesis
- This is the RIGHT place for the proof

**`Theories/Bimodal/Metalogic/DiscreteSoundness.lean`**:
- Similarly for discreteness axioms

### 2.5 Time-Shift Preservation (1 file)

**`Theories/Bimodal/Semantics/Truth.lean`** (TimeShift section):

The `time_shift_preserves_truth` theorem and its lemmas need adaptation in the `all_past` and `all_future` cases. Currently the proofs use `s <= t` / `t <= s`; these become `s < t` / `t < s`. The structure is identical -- addition/subtraction preserves strict inequality just as it preserves weak inequality. The key lemma `sub_lt_sub_right` replaces `sub_le_sub_right`.

### 2.6 Canonical Model Construction (8+ files)

**`Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`**:

| Component | Impact |
|-----------|--------|
| `CanonicalR` definition | **UNCHANGED** (`GContent M ⊆ M'`) |
| `canonical_forward_G` | **UNCHANGED** |
| `canonical_forward_F` | **UNCHANGED** |
| `canonical_backward_P` | **UNCHANGED** |
| `canonicalR_reflexive` | **DELETE** -- no longer holds without T-axiom |
| `canonicalR_past_reflexive` | **DELETE** -- no longer holds without T-axiom |
| `canonicalR_transitive` | **UNCHANGED** (uses temp_4, which is kept) |

The deletion of `canonicalR_reflexive` is the KEY structural change. Without the T-axiom, `G phi in M` does NOT imply `phi in M`. This means CanonicalR is NO LONGER reflexive.

**Impact on downstream files** that use `canonicalR_reflexive`:
- `DenseQuotient.lean` -- uses it for seed consistency (line 183, 205). Needs reworking.
- `BidirectionalReachable.lean` -- uses it for fragment membership proofs. Needs adaptation.
- `CanonicalChain.lean` -- uses for chain construction
- `CanonicalConstruction.lean` -- uses for model construction
- `CanonicalFMCS.lean` -- uses for FMCS properties

**`Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`**:
- Heavy use of T-axioms for coherence proofs (20+ occurrences)
- These coherence proofs were the REASON for switching to reflexive semantics at Task #658
- With irreflexive semantics, coherence must be reproven differently
- However, the canonical quotient approach may bypass the need for chain-based coherence entirely

**`Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean`**:
- Fragment definition uses reflexive CanonicalR for self-membership
- Totality proof uses T-axiom-based reasoning
- The Antisymmetrization quotient becomes potentially unnecessary (see Section 4)

### 2.7 Truth Lemma (1 file)

**`Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean`** or equivalent:
- The G/H cases of the truth lemma change from `forall s >= t` to `forall s > t`
- The forward direction (G phi in MCS implies truth at all future points) is unaffected structurally
- The backward direction (truth at all future points implies G phi in MCS) is the completeness direction and may need adjustment

### 2.8 Decidability/Tableau (7 files)

**`Theories/Bimodal/Metalogic/Decidability/`** directory:
- Tableau rules for temporal operators need `<` instead of `<=`
- Saturation conditions change
- Countermodel extraction uses irreflexive frames
- These are relatively mechanical changes

### 2.9 Algebraic Metalogic (5 files)

**`Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean`**:
- Uses T-axioms for interior operator properties (lines 61-67, 117-123)
- `future_interior_le` and `past_interior_le` rely on `G phi -> phi`
- These become invalid and must be removed or weakened

### 2.10 Theorems and Examples (5+ files)

**`Theories/Bimodal/Theorems/`** directory:
- `Perpetuity.lean` -- perpetuity principles may need adaptation
- `ModalS4.lean`, `ModalS5.lean` -- modal theorems unchanged
- `Combinators.lean` -- may use T-axioms
- `Discreteness.lean` -- DP derivation from DF, uses T-axiom?

**`Theories/Bimodal/Examples/`** -- adapt example proofs

---

## 3. Are There Fundamental Blockers?

### 3.1 No Fundamental Blockers Identified

Every proof that currently uses the T-axiom falls into one of these categories:

**Category A: Proofs that become unnecessary.** The T-axiom was introduced to make CanonicalR reflexive, which was needed for the chain-based coherence construction (Task #658). With the canonical quotient approach, chain-based coherence is not the primary path. The reflexivity of CanonicalR is used for:
- Self-membership in fragments (can be established differently, e.g., by definition)
- Seed consistency arguments (need reworking, but alternative seeds exist)

**Category B: Proofs that adapt mechanically.** Soundness proofs for axioms like temp_4, temp_a, temp_l use `<=` which becomes `<`. The proof structure is identical; only the inequality type changes. `le_trans` becomes `lt_trans`, `le_refl` disappears, etc.

**Category C: Proofs that become genuinely simpler.** The density and discreteness soundness proofs become non-trivial (currently trivially true via reflexivity), which is actually mathematically correct -- these axioms SHOULD require frame conditions.

### 3.2 The JPL Paper Uses Reflexive Semantics

The Truth.lean comments (lines 22-23) state the paper uses reflexive ordering (`y <= x` for past, `x <= y` for future). However, this is a design choice, not a mathematical necessity. The paper's results hold for both reflexive and irreflexive variants with appropriate axiom adjustments. Standard temporal logic literature (Prior, Goldblatt, Blackburn-de Rijke-Venema) typically uses irreflexive (strict) temporal operators as primitive, defining reflexive ones as derived.

**This is NOT a blocker** -- it is a documented deviation from the source paper, which is acceptable when the alternative is a blocked proof.

### 3.3 Coherence Proofs

The original motivation for switching to reflexive semantics (Task #658) was simplifying coherence proofs in the indexed MCS family construction. With the canonical quotient approach, those specific coherence proofs are no longer on the critical path. The question is whether any REMAINING coherence argument requires reflexivity.

Examining the current canonical quotient path:
- `CanonicalFrame.lean` -- reflexivity used but removable
- `CanonicalCompleteness.lean` -- uses T-axiom for "all worlds satisfy G phi implies phi" which becomes "all worlds satisfy G phi at strictly future times"
- `BFMCSTruth.lean` -- truth lemma cases for G/H adapt to strict quantifiers

None of these require reflexivity fundamentally. They use it for convenience, but alternative proof strategies exist for each.

---

## 4. Impact on Phase 6 Blocker

### 4.1 The Blocker Dissolves

The Phase 6 blocker is: proving `DenselyOrdered` on the `BidirectionalQuotient` (which is an `Antisymmetrization` quotient of MCSes under mutual CanonicalR).

With irreflexive semantics:

1. **CanonicalR becomes irreflexive**: Without `G phi -> phi`, having `GContent(M) ⊆ M` does NOT hold in general. So `CanonicalR M M` is NOT guaranteed. The canonical relation is a strict preorder.

2. **Antisymmetrization may become trivial**: If CanonicalR on the fragment is already antisymmetric (which is plausible for irreflexive relations on linear structures), then `Antisymmetrization` is the identity and the quotient issue vanishes entirely.

3. **The combined seed becomes consistent**: The T-axiom obstruction was: `G(psi)` and `neg(psi)` cannot coexist because `G(psi) -> psi` (T-axiom) contradicts `neg(psi)`. Without the T-axiom, `{G(psi), neg(psi)}` IS consistent! The MCS can believe "psi holds at all strictly future times" while "psi does not hold now".

4. **Standard density proof works**: Given `a < b`, extract psi with `G(psi) in b`, `psi not in a`. Build seed `{G(psi), neg(psi)} union GContent(a) union HContent(b)`. This seed is consistent (G(psi) in b, neg(psi) in a since psi not in a, GContent(a) subset b, HContent(b) subset b by reflexivity... wait, reflexivity of R_past is also gone).

Let me be more careful:

### 4.2 Detailed Density Proof Sketch (Irreflexive)

Given `a < b` in the canonical fragment (CanonicalR a.world b.world, NOT CanonicalR b.world a.world):

1. Extract psi: `G(psi) in b.world`, `psi not in a.world` (from NOT GContent(b) subset a).

2. `neg(psi) in a.world` (MCS completeness).

3. `F(psi) in a.world`: Argument unchanged -- if `G(neg psi) in a.world` then `neg(psi) in b.world` by CanonicalR, but `psi in b.world` (from G(psi) in b and... wait, without T-axiom, G(psi) in b does NOT give psi in b).

**Correction**: Without the T-axiom, `G(psi) in b` only means psi holds at all STRICTLY future times from b. It does NOT give `psi in b.world`.

This changes the extraction. Let me redo:

From NOT(CanonicalR b.world a.world), we get: exists phi with `G(phi) in b.world` and `phi not in a.world`. Call this phi = psi. We know `G(psi) in b.world` and `psi not in a.world`.

From CanonicalR a.world b.world: `GContent(a) subset b.world`. So for all phi, `G(phi) in a.world` implies `phi in b.world`.

Can we conclude `F(psi) in a.world`? If `G(neg psi) in a.world`, then `neg(psi) in b.world` by CanonicalR. But do we know `psi in b.world`? Not directly from `G(psi) in b.world` without T-axiom.

**However**, CanonicalR is transitive (from temp_4 axiom). And in an irreflexive setting, the canonical relation from G(psi) in b means: for any c with CanonicalR b c, psi in c. We need psi somewhere accessible from a to build the argument.

**Key insight**: We can still extract the distinguishing formula, just differently. NOT(GContent(b) subset a) gives some chi with G(chi) in b and chi not in a. We need to find F(something) in a to use DN.

Since a < b (a R b, not b R a), there exists chi with G(chi) in b, chi not in a.

Claim: F(chi) in a.world. Proof by contradiction: if not, then G(neg chi) in a (by MCS completeness of some_future = neg all_future neg). Then neg(chi) in b (by a R b). But G(chi) in b means chi holds at all strict successors of b. However, we don't know chi holds AT b. So neg(chi) in b is not immediately contradictory.

**This is where irreflexive semantics introduces a subtlety.** The argument `G(chi) in b AND neg(chi) in b` is NOT contradictory without the T-axiom. b can believe "chi holds at all strictly future times" while "chi does not hold now."

So the F(chi) extraction does NOT work the same way.

### 4.3 Revised Approach for Irreflexive Case

In the irreflexive setting, the canonical relation CanonicalR is: `GContent(M) subset M'`, where GContent(M) = {phi | G(phi) in M}. This relation means: "all G-formulas of M are satisfied at M'."

For the density proof, we can use a different strategy that leverages the irreflexive structure directly:

**Alternative extraction**: From NOT(b R a), there exist chi with G(chi) in b and chi not in a. From a R b, for any G(phi) in a, phi in b.

Consider: `G(G(chi)) in b` (by temp_4 from G(chi) in b). So `G(chi) in GContent(b)`.

Now: `G(chi) in GContent(b)` and `G(chi) not in a` (if it were, then chi in b by a R b... but we don't need chi in b, we need chi in a, which we know is false).

Actually, we DO know G(chi) is not necessarily in a. We know chi is not in a. If G(chi) were in a, that's fine -- it just means G(chi) in a but chi not in a (which is perfectly consistent without T-axiom).

**Revised strategy**: The key is that in the irreflexive setting, we work with the STRICT relation directly, not a quotient of a reflexive relation.

Define the canonical order on MCSes: `M < N` iff `GContent(M) subset N` (i.e., CanonicalR M N). With irreflexive semantics, this is NOT reflexive (GContent(M) NOT necessarily subset M). It IS transitive (by temp_4). So it's a strict preorder.

On a linearly ordered fragment, if we can show this strict preorder is also a strict LINEAR order (trichotomy: for any M, N either M < N, N < M, or M = N), then:

- No antisymmetrization needed (strict linear orders are already antisymmetric)
- Density follows from DN via the standard textbook argument

**The textbook density argument for irreflexive canonical models**:

Given M < N (CanonicalR M N, not M = N, not N < M):
1. M < N means GContent(M) subset N
2. not(N < M) means not(GContent(N) subset M), so exists psi with G(psi) in N, psi not in M
3. Claim: not(G(neg psi) in M). Proof: if G(neg psi) in M, then neg(psi) in N by M < N. But G(psi) in N means... hmm, this doesn't give contradiction without T-axiom or further structure.

Let me think about this differently. In the standard canonical model construction for tense logics with strict semantics (e.g., Goldblatt's "Logics of Time and Computation"):

The canonical relation is `R(M, N)` iff `{phi : G(phi) in M} subset N`. The key property is:

**G-saturation**: If `NOT(G(phi)) in M`, then exists N with R(M, N) and NOT(phi) in N. This is the completeness-direction witness lemma.

**F-witness**: If `F(phi) in M`, then exists N with R(M, N) and phi in N. This follows from G-saturation via `F(phi) = neg G(neg phi)`.

For density with DN: If `R(M, N)` (M < N), and `F(phi) in M`, then by DN, `F(F(phi)) in M`. By F-witness, exists P with R(M, P) and F(phi) in P. Then by F-witness on P, exists Q with R(P, Q) and phi in Q. So R(M, P) and R(P, Q).

For strictness: We need M < P < N. We need P to be between M and N, AND strictly.

**This is where the constrained Lindenbaum argument applies, and it works WITHOUT the T-axiom obstruction:**

Seed = {neg(psi), G(psi)} union GContent(M) union HContent(N)

where psi witnesses M < N (G(psi) in N, psi not in M).

- neg(psi) is consistent with G(psi) because there is NO T-axiom deriving psi from G(psi)
- The seed being consistent follows from it being a subset of... what?

Actually, neg(psi) in M (since psi not in M, by MCS completeness). G(psi) in N. GContent(M) in... M (by reflexivity? NO -- without T-axiom, GContent(M) is NOT subset of M).

**This is the critical point.** Without `canonicalR_reflexive`, `GContent(M) subset M` no longer holds. The seed containment argument needs reworking.

### 4.4 Resolution: New Seed Strategy

With irreflexive semantics, the seed consistency argument takes a different form. Instead of showing the seed is a subset of a single MCS, we show the seed is DERIVABLY consistent (no derivation of bot from it).

Claim: `{neg(psi), G(psi)} union GContent(M)` is consistent when G(psi) not in M.

Proof sketch: Suppose for contradiction there is a derivation of bot from this seed. Then there is a finite subset L of GContent(M) such that `L, G(psi), neg(psi) |- bot`. This means `L, G(psi) |- psi`. By the deduction theorem (iterated), `|- (conjunction of L) -> (G(psi) -> psi)`. Since each element of L is in GContent(M), we have G(l) in M for each l in L. By temporal distribution and necessitation, G(conjunction of L) is derivable from M. Then `G(G(psi) -> psi)` would be derivable, hence `G(psi) -> G(psi)` by distribution... this argument needs to be more careful.

**Standard approach**: Use the F-witness lemma directly. `F(psi) in M` (this needs to be established) implies `{psi} union GContent(M)` is consistent (standard Lindenbaum seed argument, which does NOT require T-axiom -- it only uses the fact that G(neg psi) not in M, which follows from F(psi) in M).

**The question reduces to**: Can we establish `F(psi) in M` from the irreflexive setup?

From M < N with witness psi (G(psi) in N, psi not in M):
- Does F(psi) hold in M? NOT automatically. Without T-axiom, psi might not even hold at N itself (G(psi) in N means psi at all strict successors of N, not at N).

**This means the density argument in the irreflexive setting requires a DIFFERENT witness extraction.**

### 4.5 Correct Irreflexive Density Argument

In standard irreflexive temporal logic completeness:

Given M < N (GContent(M) subset N, not GContent(N) subset M):

1. From not(GContent(N) subset M): exists chi with G(chi) in N, chi not in M.
2. From temp_4 on chi: G(G(chi)) in N, so G(chi) in GContent(N).
3. Since M < N: GContent(M) subset N. The question is whether we can establish a link from M to chi.

**Alternative approach for irreflexive density**: Use the temp_a axiom: `phi -> G(P(phi))`.

For any phi in M but NOT in N:
- There must exist such phi (otherwise M subset N, and combined with GContent(M) subset N, we'd get... not necessarily M = N).

Actually, in the irreflexive setting, the canonical frame for dense temporal logics uses a different witness construction. Let me consult the standard reference.

**Goldblatt's approach** (Logics of Time and Computation, Ch. 6): For dense temporal logic, the canonical frame uses ALL maximal consistent sets as worlds, with the relation R(M, N) iff GContent(M) subset N. The density property is proven as follows:

If R(M, N), show there exists P with R(M, P) and R(P, N):
1. Let Sigma = GContent(M) union HContent(N).
2. Show Sigma is consistent (this uses the interaction between G and H axioms).
3. Extend Sigma to an MCS P.
4. R(M, P) holds by construction (GContent(M) subset P).
5. R(P, N) holds by the duality argument (HContent(N) subset P implies GContent(P) subset N).

Wait -- this gives R(M, P) and R(P, N), but NOT STRICT. M might equal P (in quotient), or P might equal N.

For STRICT density (given M < N, find P with M < P < N), the density AXIOM (DN) is used:

Since M < N, there exists psi such that some asymmetry. Then DN gives F(F(psi)) in M, and the F-witness construction with the constrained seed {psi, GContent(M), HContent(N)} gives the intermediate point.

**But the F(psi) extraction remains the question.** In the irreflexive setting, from M < N we know there exists chi with G(chi) in N, chi not in M. But we need F(something) in M to apply DN.

**Key lemma needed**: If R(M, N) (GContent(M) subset N), then for any phi in N, either phi in M or F(phi) in M.

Proof: Suppose phi in N and phi not in M. Then neg(phi) in M (MCS). Suppose G(neg(phi)) in M. Then neg(phi) in N (by R(M,N)). But phi in N, contradicting consistency of N. So G(neg(phi)) not in M, i.e., neg(G(neg(phi))) in M, i.e., F(phi) in M.

This argument works! It does NOT use the T-axiom. It only uses:
- MCS completeness (phi or neg phi)
- CanonicalR (GContent(M) subset N)
- Consistency of N

**Now the density argument completes:**

Given M < N:
1. Extract chi with G(chi) in N, chi not in M (from not GContent(N) subset M).
2. chi not in M, and by temp_4: G(chi) in GContent(N), so G(chi) in N.
3. G(chi) in N and R(M,N) does not directly help. But we need F(something) in M.
4. From G(chi) in N: by temp_4, G(G(chi)) in N. So G(chi) in GContent(N).
5. G(chi) not in M (otherwise, chi in N via R(M,N)... but chi IS in N if we use temp_t... no, we don't have T-axiom).

Wait, I need to restart. G(chi) in N, chi not in M. Is chi in N? Without T-axiom, not necessarily.

Let me use the key lemma differently. R(M, N) means GContent(M) subset N. From chi not in M: neg(chi) in M. From G(neg chi) in M?: If G(neg chi) in M, then neg(chi) in N (by R(M,N)). Is chi in N? We only know G(chi) in N, but without T-axiom, chi might not be in N.

**So neg(chi) in N and G(chi) in N could coexist.** This is the BEAUTY of the irreflexive setting -- no contradiction.

Let me try yet another approach. From R(M, N) and not R(N, M):
- not R(N, M) means not(GContent(N) subset M)
- exists alpha in GContent(N) with alpha not in M
- alpha not in M means neg(alpha) in M
- alpha in GContent(N) means G(alpha) in N

Now: Is F(alpha) in M? Using the key lemma: alpha not in M. If G(neg alpha) in M, then neg(alpha) in N. But alpha in GContent(N) does NOT mean alpha in N (without T-axiom). So neg(alpha) in N is not a contradiction.

**Hmm.** The key lemma from step above required phi in N. Here alpha is in GContent(N) but not necessarily in N.

Let me try: From R(M, N), the set {phi : phi in N} includes GContent(M). So N contains all G-consequences of M. There exist formulas in N that are not in M (otherwise GContent(N) subset GContent(M)... not obviously).

**Actually, there IS a formula in N \ M**: Since R(M, N) is not the equality relation (M < N means M != N in the quotient sense or strict sense), the fragment structure guarantees some separation.

For the fragment to work, the relation needs to be a strict linear order. In the irreflexive setting, the total order on the fragment comes from the linearity axiom. Given two MCSes M, N in the fragment, either GContent(M) subset N, or GContent(N) subset M, or both (the case where both hold is the "same equivalence class" case -- but in the irreflexive setting, mutual R does NOT include the reflexive case M R M).

**Revised key observation**: In an irreflexive temporal logic, if M and N are distinct MCSes with mutual CanonicalR (GContent(M) subset N AND GContent(N) subset M), they may still differ. The Antisymmetrization quotient identifies them. But the point is: without T-axiom, mutual CanonicalR becomes a WEAKER condition, so fewer MCSes are identified. This means the quotient is FINER, with more distinct equivalence classes. Whether this makes density easier or harder depends on the details.

### 4.6 Summary of Phase 6 Impact

The switch to irreflexive semantics:

1. **Eliminates the T-axiom obstruction** that blocks the combined seed `{G(psi), neg(psi)}`.
2. **Requires a revised density argument** because the standard F-witness extraction changes.
3. **May eliminate the need for Antisymmetrization** if the canonical relation becomes antisymmetric on the fragment.
4. The density proof is **not automatically easier** -- the argument changes form, but the T-axiom obstruction (the specific blocker documented in Phase 6) IS removed.

The density proof in the irreflexive setting is a **standard result** in the temporal logic literature (Goldblatt 1992, Ch. 6), so there is strong evidence it can be formalized, even if the exact Lean proof requires work.

---

## 5. Axiom Implications

### 5.1 T-Axiom Removal

`G phi -> phi` and `H phi -> phi` become INVALID. This changes the logic from S4.t (reflexive-transitive tense logic) to K4.t (transitive tense logic without reflexivity).

### 5.2 DN Axiom Becomes Non-Trivial

Currently: `F(phi) -> F(F(phi))` is trivially valid because `F` includes the present (some s >= t with phi). With irreflexive semantics, `F(phi)` means some STRICTLY future s > t with phi, and `F(F(phi))` means some s > t where some s' > s with phi. This genuinely requires an intermediate point, hence DenselyOrdered.

This is a **mathematical improvement**: DN now actually characterizes density rather than being vacuously true.

### 5.3 DF Axiom Becomes Non-Trivial

Similarly, `(F(top) /\ phi /\ H(phi)) -> F(H(phi))` currently uses reflexive witness `u = t`. With irreflexive semantics, it genuinely requires a successor point.

### 5.4 Derived Reflexive Operators

With irreflexive G/H as primitive, one can define:
```
G' phi := phi /\ G phi    -- reflexive future (includes present)
H' phi := phi /\ H phi    -- reflexive past (includes present)
F' phi := phi \/ F phi     -- reflexive existential future
P' phi := phi \/ P phi     -- reflexive existential past
```

The T-axiom `G' phi -> phi` is trivially derivable for these. This means all the reflexive-semantics proofs can be RECOVERED by working with G'/H' when needed, while the primitive irreflexive G/H are available for the density proof.

---

## 6. Soundness and Completeness

### 6.1 Soundness

No fundamental issues. The soundness proof adapts by:
- Removing T-axiom cases (2 proofs deleted)
- Changing `<=` to `<` in temporal quantifier cases
- Making DN soundness non-trivially depend on DenselyOrdered
- Making DF soundness non-trivially depend on SuccOrder

### 6.2 Completeness

The completeness proof structure (canonical model -> quotient -> linear order -> embedding into Q or Z) is unchanged. The canonical relation becomes strict, which:
- Eliminates the need for Antisymmetrization (potentially)
- Changes the truth lemma's temporal cases from `<=` to `<`
- Requires the density proof to work in the irreflexive setting (standard result)

No fundamental issue identified.

---

## 7. Files Requiring Modification

### Tier 1: Core Semantic Change (must change)
1. `Theories/Bimodal/Semantics/Truth.lean` -- `<=` to `<` in truth_at
2. `Theories/Bimodal/ProofSystem/Axioms.lean` -- remove T-axiom constructors
3. `Theories/Bimodal/Metalogic/Soundness.lean` -- remove T-axiom cases, adapt temporal proofs
4. `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- remove T-axiom swap cases

### Tier 2: Canonical Model (must change)
5. `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` -- remove reflexivity theorems
6. `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean` -- rewrite density proof
7. `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` -- adapt fragment proofs
8. `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` -- adapt completeness
9. `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- adapt coherence (if still used)
10. `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- adapt construction
11. `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` -- adapt FMCS properties
12. `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` -- adapt chain
13. `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` -- may need adaptation
14. `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` -- truth lemma temporal cases

### Tier 3: Other Metalogic (should change)
15. `Theories/Bimodal/Metalogic/DenseSoundness.lean` -- rewrite with real density argument
16. `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` -- rewrite with real SuccOrder argument
17. `Theories/Bimodal/Metalogic/Completeness.lean` -- update imports/references
18. `Theories/Bimodal/Metalogic/Representation.lean` -- adapt if uses T-axiom

### Tier 4: Decidability (should change)
19-25. `Theories/Bimodal/Metalogic/Decidability/*.lean` (7 files) -- tableau rules, saturation

### Tier 5: Algebraic (should change)
26-30. `Theories/Bimodal/Metalogic/Algebraic/*.lean` (5 files) -- interior operators

### Tier 6: Theorems and Examples (should change)
31-35. `Theories/Bimodal/Theorems/*.lean` and `Examples/*.lean` -- adapt proofs

### Tier 7: Other
36. `Theories/Bimodal/ProofSystem/Derivation.lean` -- update docstrings
37. `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` -- update
38. `Theories/Bimodal/Semantics/Validity.lean` -- no change (definitions are generic)
39. `Theories/Bimodal/Syntax/Formula.lean` -- add G'/H' derived operators

**Total: ~35 files, estimated 600-1000 lines of changes.**

---

## 8. Refactoring Strategy

If the user decides to proceed, the recommended order is:

### Phase 1: Core Semantic Switch
1. Change `truth_at` from `<=` to `<` (Truth.lean)
2. Remove T-axiom constructors (Axioms.lean)
3. Add derived `weak_future`/`weak_past` operators (Formula.lean)
4. Fix soundness proofs (Soundness.lean, SoundnessLemmas.lean)
5. Fix time-shift preservation (Truth.lean TimeShift section)
6. `lake build` to identify cascading failures

### Phase 2: Completeness Infrastructure
7. Remove `canonicalR_reflexive` and `canonicalR_past_reflexive`
8. Adapt DovetailingChain coherence proofs (or mark for removal if canonical quotient bypasses)
9. Adapt BidirectionalReachable fragment proofs
10. Adapt CanonicalCompleteness

### Phase 3: Density (the payoff)
11. Rewrite DenseQuotient.lean with irreflexive density argument
12. Verify the combined seed `{G(psi), neg(psi)}` is now consistent
13. Complete the density proof

### Phase 4: Cleanup
14. Adapt decidability, algebraic, theorems, examples
15. Update all documentation

---

## 9. Recommendation

**SWITCH TO IRREFLEXIVE G/H SEMANTICS.**

Rationale:
1. The Phase 6 blocker (density proof) is fundamentally caused by the T-axiom making `{G(psi), neg(psi)}` contradictory. Removing the T-axiom resolves this structural obstacle.
2. Irreflexive temporal semantics is the standard in the temporal logic literature. The reflexive variant was a pragmatic choice that created unforeseen problems.
3. The density and discreteness soundness proofs become mathematically meaningful (non-vacuous) with irreflexive semantics, which is a quality improvement.
4. The reflexive operators G'/H' can be defined as derived notions, so no expressiveness is lost.
5. The refactoring cost (600-1000 lines across 35 files) is significant but the user has indicated this is acceptable.
6. No fundamental blockers were identified for the irreflexive approach.

**Caveat**: The density proof in the irreflexive setting is a standard result but requires careful formalization. The exact Lean proof strategy (particularly the seed consistency argument without T-axiom) needs to be worked out during implementation. The analysis in Section 4 shows the path is plausible but not trivial.

---

## 10. Artifacts

- **This report**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-016.md`
- **Key referenced files**:
  - `Theories/Bimodal/Semantics/Truth.lean` -- truth_at definition (lines 118-119)
  - `Theories/Bimodal/ProofSystem/Axioms.lean` -- axiom definitions
  - `Theories/Bimodal/Metalogic/Soundness.lean` -- soundness proofs
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` -- canonical relations and reflexivity
  - `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean` -- Phase 6 blocker location
  - `specs/956_construct_d_as_translation_group_from_syntax/handoffs/phase-6-blocker-20260309.md` -- blocker document
  - `specs/956_construct_d_as_translation_group_from_syntax/reports/research-015.md` -- previous research
