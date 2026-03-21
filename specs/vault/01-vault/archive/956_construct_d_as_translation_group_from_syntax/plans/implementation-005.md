# Implementation Plan: K-Relational Pipeline from Syntax to Representation Theorem

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [NOT STARTED]
- **Effort**: 18-22 hours
- **Dependencies**: None
- **Research Inputs**: research-023.md (complete K-Relational pipeline), research-021.md (Holder/freeness analysis), research-022.md (homogeneous automorphisms), research-020.md (D from syntax)
- **Artifacts**: plans/implementation-005.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-004.md (blocked at Phase 8a due to countability failure)

## Overview

This plan implements the **K-Relational strategy** from research-023, which bypasses the TranslationGroup obstacles (Holder's theorem, freeness, homogeneity) by using Cantor's order-theoretic characterization to DISCOVER Q from the syntax rather than importing it. The key insight: Q is not chosen a priori but EMERGES as the unique countable dense linear order without endpoints that characterizes the canonical MCS timeline.

The pipeline has **10 stages** with ONE hard blocker (density proof under DN). All other stages either leverage existing sorry-free infrastructure or apply Mathlib lemmas directly.

### Research Integration

- **research-023**: Complete 10-stage pipeline from syntax to representation theorem
- **research-021**: Confirms TranslationGroup approach is blocked by 5 hard steps
- **research-022**: Shows restricting to homogeneous automorphisms reduces to K-Relational
- **research-018**: Proves BidirectionalQuotient is UNCOUNTABLE (requires restricted fragment)

### Critical Path

```
[1] Lindenbaum -> [2] BidirectionalFragment -> [3] LinearOrder -> [4] DenselyOrdered (BLOCKER)
                                                                         |
[5] NoEndpoints ----------------------------------------------------------+
                                                                         |
[6] Countable (restricted fragment) <------------------------------------+
                                                                         |
[7] Cantor isomorphism (T ~ Q) <-----------------------------------------+
                                                                         |
[8] TaskFrame construction (D=Q, non-trivial task_rel) <-----------------+
                                                                         |
[9] Truth lemma <--------------------------------------------------------+
                                                                         |
[10] Representation theorem + Completeness <-----------------------------+
```

## Goals & Non-Goals

**Goals**:
- Construct D = Q from pure syntax via Cantor characterization
- Build non-trivial task_rel: `task_rel d w u := e(u) - e(w) = d`
- Prove representation theorem for TM + DN with genuinely non-trivial TaskFrame
- Achieve zero new sorries (resolve 4 density sorries or mark [BLOCKED])

**Non-Goals**:
- TranslationGroup approach (abandoned due to 5 hard blockers)
- Formal displacements (reduces to same mathematics)
- Discrete completeness for TM + DP/DF (separate task)
- Changing the irreflexive semantics (already completed in prior plan)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Density proof intractable | HIGH | MEDIUM | Mark [BLOCKED] with single documented sorry; all other infrastructure complete |
| Countable restricted fragment harder than expected | MEDIUM | LOW | Mathematical argument clear; standard inductive construction |
| NoEndpoints proof requires additional lemmas | LOW | LOW | temp_a gives G(bot)->bot; consistency gives contradiction |
| Truth lemma adaptation complex | MEDIUM | LOW | Follows existing Representation.lean template |

## Sorry Characterization

### Pre-existing Sorries
- `DenseQuotient.lean` lines 347, 349, 351, 698 (4 sorries from Lindenbaum collapse)

### Expected Resolution
- Phase 4: Either resolve all 4 sorries via MCS-level density OR mark [BLOCKED]
- No new sorries introduced in any phase
- If density blocked: single documented blocker, all other phases complete

### New Sorries
- None. NEVER introduce new sorries. If density proof cannot be completed:
  - Mark Phase 4 [BLOCKED] with `requires_user_review: true`
  - Document the mathematical obstacle
  - User decides: alternative approach, accept single sorry, or research more

### Remaining Debt
After this implementation:
- If density resolved: 0 sorries in K-Relational pipeline
- If density blocked: 1 documented sorry (DenselyOrdered), all else complete

## Implementation Phases

### Phase 1: Verify Existing Infrastructure [COMPLETED]

- **Dependencies:** None
- **Goal:** Confirm Stages 1-3 are complete and sorry-free

**Tasks:**
- [ ] Verify `set_lindenbaum` in `Core/MaximalConsistent.lean` is sorry-free
- [ ] Verify `BidirectionalFragment` and `BidirectionalReachable` are sorry-free (888 lines)
- [ ] Verify `LinearOrder` on `BidirectionalQuotient` is sorry-free
- [ ] Run `grep -rn "\bsorry\b"` on relevant files to confirm

**Timing:** 30 minutes

**Files to check:**
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean`
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean`

**Verification:**
- All three stages confirmed sorry-free
- `lake build` passes for these files

---

### Phase 2: Define Restricted Countable Fragment [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Define countable sub-fragment via specific Lindenbaum witnesses

**Mathematical Design:**
Since BidirectionalQuotient is uncountable (research-018), define a restricted fragment:
```lean
-- WitnessReachable: reachability via specific canonical witnesses only
inductive WitnessReachable (M0 : Set Formula) (h0 : SetMaximalConsistent M0) :
    (M : Set Formula) -> SetMaximalConsistent M -> Prop where
  | refl : WitnessReachable M0 h0 M0 h0
  | forward_step {M1 M2} {h1 h2} :
      WitnessReachable M0 h0 M1 h1 ->
      (phi : Formula) -> Formula.some_future phi in M1 ->
      M2 = canonical_forward_F_witness M1 h1 phi ->
      WitnessReachable M0 h0 M2 h2
  | backward_step {M1 M2} {h1 h2} :
      WitnessReachable M0 h0 M1 h1 ->
      (phi : Formula) -> Formula.some_past phi in M1 ->
      M2 = canonical_backward_P_witness M1 h1 phi ->
      WitnessReachable M0 h0 M2 h2
```

**Countability Argument:**
- Each step is indexed by `Formula` (countable)
- Paths are finite lists of `(Formula + Formula)` (F-step or P-step)
- Surjection from `List (Formula + Formula)` to fragment
- `List` preserves countability

**Tasks:**
- [ ] Define `WitnessReachable` inductive type in new file
- [ ] Define `RestrictedFragment` as `{M // WitnessReachable M0 h0 M.fst M.snd}`
- [ ] Prove `Countable RestrictedFragment` via path encoding
- [ ] Prove `RestrictedFragment` is closed under CanonicalR (inherits from BidirectionalFragment)

**Timing:** 2 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/RestrictedFragment.lean` (~150 lines)

**Verification:**
- `lake build` passes
- `Countable RestrictedFragment` instance available
- `grep -n "\bsorry\b" RestrictedFragment.lean` returns empty

---

### Phase 3: Prove Totality on Restricted Fragment [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Prove LinearOrder on RestrictedFragment (not just Preorder)

**Mathematical Argument:**
- `temp_linearity` axiom ensures totality: for any M1, M2 forward-reachable from M, either CanonicalR M M1 implies CanonicalR M M1 to M2 or vice versa
- The existing proof `canonical_forward_reachable_linear` works because CanonicalR is defined by GContent inclusion
- The specific witnesses satisfy CanonicalR, so totality transfers

**Tasks:**
- [ ] Prove `restricted_totally_ordered`: any two elements of RestrictedFragment are comparable
- [ ] Define `RestrictedQuotient` as Antisymmetrization of RestrictedFragment
- [ ] Prove `LinearOrder RestrictedQuotient` (follows from totality + antisymmetrization)

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RestrictedFragment.lean` (extend)

**Verification:**
- `lake build` passes
- `LinearOrder RestrictedQuotient` instance available

---

### Phase 4: Prove DenselyOrdered on Restricted Fragment [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove density using DN axiom; this is the SINGLE HARD BLOCKER

**Strategy Options:**

**Option A: MCS-level density (preferred)**
Work at the MCS level BEFORE quotient. The advantage: every new MCS is genuinely new (no quotient collapse). Given `a < b` in the restricted fragment:
1. Extract `chi in b \ a` (GContent difference)
2. `F(chi) in a` by canonical_F_of_mem_successor
3. Apply DN: `FF(chi) in a`
4. `F(chi AND F(chi)) in a` (derivable)
5. Construct intermediate `c` = canonical_forward_F_witness for `chi AND F(chi)`
6. Show `c` is in RestrictedFragment (forward step from `a`)
7. Show `a < c < b` at MCS level

**Option B: Double-seed approach (fallback)**
From research-017: use combined formula to distinguish from both endpoints.

**Option C: Mark [BLOCKED]**
If both options fail after reasonable effort (>4 hours), mark phase [BLOCKED]:
- Document the mathematical obstacle
- All other phases still complete
- Task becomes `[PARTIAL]` with single documented blocker

**Tasks:**
- [ ] Attempt Option A: MCS-level density proof
- [ ] If stuck (>2h), attempt Option B: double-seed approach
- [ ] If both fail (>4h total), mark [BLOCKED] with detailed documentation
- [ ] Document either success (0 sorries) or blocker (1 sorry, requires_user_review: true)

**Timing:** 4-6 hours (key phase)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RestrictedFragment.lean` (extend)

**Verification:**
- Either: `DenselyOrdered RestrictedQuotient` instance + `grep -n "\bsorry\b"` empty
- Or: Phase marked [BLOCKED] with `review_reason: "Lindenbaum collapse prevents density proof"`

---

### Phase 5: Prove No Endpoints [BLOCKED]

- **Dependencies:** Phase 3 (can run in parallel with Phase 4)
- **Goal:** Prove `NoMinOrder` and `NoMaxOrder` for RestrictedQuotient

**Mathematical Argument:**
From research-023 Section Stage 5:
1. `temp_a: G(phi) -> phi` is an axiom of TM
2. If `G(bot) in M` for any MCS M, then `bot in M` by temp_a
3. This contradicts MCS consistency
4. Therefore `G(bot) NOT in M`, so `NOT G(bot) in M`, i.e., `F(top) in M`
5. By forward_F, every MCS has a strict CanonicalR-successor
6. Similarly `H(bot) -> bot` (temp_a_past) gives P(top) in M, so strict predecessor exists

**Tasks:**
- [ ] Prove `no_max_order_restricted : NoMaxOrder RestrictedQuotient`
  - Key lemma: `F(top) in M` for every M in fragment
  - Uses `temp_a` and MCS consistency
- [ ] Prove `no_min_order_restricted : NoMinOrder RestrictedQuotient`
  - Key lemma: `P(top) in M` for every M in fragment
  - Uses `temp_a_past` and MCS consistency

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RestrictedFragment.lean` (extend)

**Verification:**
- `NoMinOrder RestrictedQuotient` and `NoMaxOrder RestrictedQuotient` instances
- `grep -n "\bsorry\b"` returns empty for new lemmas

---

### Phase 6: Apply Cantor's Theorem [NOT STARTED]

- **Dependencies:** Phase 4 (DenselyOrdered), Phase 5 (NoEndpoints)
- **Goal:** Obtain order isomorphism T ~ Q

**Mathematical Mechanism:**
Apply `Order.iso_of_countable_dense` from Mathlib:
```lean
theorem Order.iso_of_countable_dense (alpha beta : Type)
  [LinearOrder alpha] [LinearOrder beta] [Countable alpha] [DenselyOrdered alpha]
  [NoMinOrder alpha] [NoMaxOrder alpha] [Nonempty alpha]
  [Countable beta] [DenselyOrdered beta] [NoMinOrder beta] [NoMaxOrder beta]
  [Nonempty beta] : Nonempty (OrderIso alpha beta)
```

Instantiate with alpha = RestrictedQuotient, beta = Q. All instances for Q exist in Mathlib.

**Tasks:**
- [ ] Prove `Nonempty RestrictedQuotient` (root is in fragment)
- [ ] Apply `Order.iso_of_countable_dense` to get `Nonempty (RestrictedQuotient ≃o Rat)`
- [ ] Extract witness: `noncomputable def cantor_iso : RestrictedQuotient ≃o Rat := ...`

**Timing:** 30 minutes (ONE LINE application if instances are available)

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/CantorIsomorphism.lean` (~50 lines)

**Verification:**
- `lake build` passes
- `cantor_iso` exists with type `RestrictedQuotient ≃o Rat`

---

### Phase 7: Build TaskFrame with Non-Trivial task_rel [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Construct TaskFrame with D = Q and `task_rel d w u := e(u) - e(w) = d`

**Non-Trivial task_rel Definition:**
```lean
-- Given e : T ≃o Q (Cantor isomorphism)
def canonical_task_rel (e : T ≃o Rat) (w : T) (d : Rat) (u : T) : Prop :=
  e u - e w = d
```

**Properties to Prove:**
1. **Nullity**: `task_rel w 0 w` iff `e(w) - e(w) = 0`. Trivially true.
2. **Compositionality**: If `task_rel w d1 u` and `task_rel u d2 v`:
   - `e(u) - e(w) = d1` and `e(v) - e(u) = d2`
   - So `e(v) - e(w) = d1 + d2`
   - Hence `task_rel w (d1 + d2) v`. True.

**D Structure from Mathlib:**
- `Rat.addCommGroup : AddCommGroup Rat`
- `Rat.linearOrder : LinearOrder Rat`
- `Rat.instLinearOrderedAddCommGroup : LinearOrderedAddCommGroup Rat`
- `Rat.instIsOrderedAddMonoid : IsOrderedAddMonoid Rat` (from LinearOrderedAddCommGroup)

**Tasks:**
- [ ] Define `CanonicalTaskFrame : TaskFrame Rat` with:
  - `WorldState := RestrictedQuotient`
  - `task_rel := canonical_task_rel cantor_iso`
- [ ] Prove `nullity : forall w, task_rel w 0 w`
- [ ] Prove `compositionality : forall w u v d1 d2, task_rel w d1 u -> task_rel u d2 v -> task_rel w (d1 + d2) v`

**Timing:** 1.5 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrame.lean` (~100 lines)

**Verification:**
- `lake build` passes
- `CanonicalTaskFrame` exists with type `TaskFrame Rat`
- `grep -n "\bsorry\b"` returns empty

---

### Phase 8: Build Canonical Model and Valuation [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Construct TaskModel and valuation from MCS membership

**Design:**
```lean
def canonical_valuation (p : PropVar) (w : RestrictedQuotient) : Bool :=
  Formula.atom p in (representative w).world

def CanonicalModel : TaskModel CanonicalTaskFrame where
  val := canonical_valuation
```

World histories are built from FMCS families (existing infrastructure), with Cantor isomorphism providing rational time indexing.

**Tasks:**
- [ ] Define `representative : RestrictedQuotient -> RestrictedFragment` (quotient representative)
- [ ] Define `canonical_valuation : PropVar -> RestrictedQuotient -> Bool`
- [ ] Define `CanonicalModel : TaskModel CanonicalTaskFrame`
- [ ] Define `CanonicalHistory : WorldHistory CanonicalTaskFrame` using FMCS family
- [ ] Prove `CanonicalHistory` respects_task (follows from position-based task_rel)

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrame.lean` (extend)

**Verification:**
- `lake build` passes
- `CanonicalModel` and `CanonicalHistory` exist
- `respects_task` verified

---

### Phase 9: Prove Truth Lemma [NOT STARTED]

- **Dependencies:** Phase 8
- **Goal:** Prove phi in M iff truth_at canonical_model phi

**Structure (follows existing Representation.lean template):**
- **Atom case**: By valuation definition
- **Bot case**: By MCS consistency
- **Imp case**: By MCS implication property
- **Box case**: By modal_forward/modal_backward (existing infrastructure)
- **G/H cases**: By forward_G/backward_H of FMCS chain
  - Key: FMCS chain uses `<=` for propagation, semantic eval uses `<`
  - forward_G at t propagates to all s >= t, which includes s > t
- **F/P cases**: By canonical_F_of_mem_successor / canonical_P_of_mem_predecessor

**Tasks:**
- [ ] Prove `truth_lemma : forall phi M, phi in M.world <-> truth_at CanonicalModel CanonicalOmega CanonicalHistory 0 phi`
- [ ] Induction on phi with cases: atom, bot, imp, box, G, H (F, P derived)

**Timing:** 3-4 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/KRelationalTruthLemma.lean` (~250 lines)

**Verification:**
- `lake build` passes
- `truth_lemma` has correct type
- `grep -n "\bsorry\b"` returns empty

---

### Phase 10: Prove Representation Theorem and Completeness [NOT STARTED]

- **Dependencies:** Phase 9
- **Goal:** Prove completeness for TM + DN with non-trivial TaskFrame

**Structure:**
1. Consistent phi -> MCS M0 containing phi (set_lindenbaum)
2. Build RestrictedFragment from M0
3. Apply Cantor isomorphism
4. Build CanonicalTaskFrame with D = Q (discovered, not imported)
5. Truth lemma gives: phi in M0 iff truth_at canonical_model
6. Package as representation theorem:
   ```lean
   theorem k_relational_representation :
     ContextConsistent [phi] -> satisfiable Rat [phi]
   ```

**Completeness:**
```lean
theorem k_relational_completeness :
  valid_TM_DN phi -> TM_DN_provable phi
```

**Tasks:**
- [ ] Define `satisfiable_k_relational` using CanonicalTaskFrame
- [ ] Prove `k_relational_representation : ContextConsistent [phi] -> satisfiable Rat [phi]`
- [ ] Prove `k_relational_completeness : valid_TM_DN phi -> TM_DN_provable phi`
- [ ] Document that task_rel is NON-TRIVIAL (position-based displacement)

**Timing:** 2 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/KRelationalCompleteness.lean` (~100 lines)

**Verification:**
- `lake build` passes
- `k_relational_representation` and `k_relational_completeness` have correct types
- `grep -n "\bsorry\b"` returns empty

---

### Phase 11: Final Verification and Summary [NOT STARTED]

- **Dependencies:** Phase 10
- **Goal:** Full verification, sorry audit, documentation

**Tasks:**
- [ ] Run full `lake build`
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/`
- [ ] Verify either: all zero sorries, OR single documented blocker (Phase 4)
- [ ] Create implementation summary documenting:
  - Non-trivial task_rel achieved
  - D = Q discovered from syntax (not imported)
  - Pipeline stages complete
- [ ] If Phase 4 blocked: document as `[PARTIAL]` with clear resume point

**Timing:** 1 hour

**Files to create:**
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

**Verification:**
- `lake build` passes
- Summary complete with sorry audit
- Status: `[COMPLETED]` if zero sorries, `[PARTIAL]` if density blocked

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Mathematical Validation
- [ ] Countable RestrictedFragment proven (Phase 2)
- [ ] LinearOrder on RestrictedQuotient proven (Phase 3)
- [ ] Either DenselyOrdered proven OR Phase 4 [BLOCKED] (Phase 4)
- [ ] NoMinOrder and NoMaxOrder proven (Phase 5)
- [ ] Cantor isomorphism applied (Phase 6)
- [ ] TaskFrame with non-trivial task_rel constructed (Phase 7)
- [ ] Truth lemma proven (Phase 9)
- [ ] Completeness theorem proven (Phase 10)

## Artifacts & Outputs

**New Files (~795 lines total):**
- `Theories/Bimodal/Metalogic/Bundle/RestrictedFragment.lean` (~200 lines)
- `Theories/Bimodal/Metalogic/Bundle/CantorIsomorphism.lean` (~50 lines)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrame.lean` (~150 lines)
- `Theories/Bimodal/Metalogic/Bundle/KRelationalTruthLemma.lean` (~250 lines)
- `Theories/Bimodal/Metalogic/KRelationalCompleteness.lean` (~100 lines)

**Summary:**
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

1. **Phase 4 (density) blocked**: Mark [BLOCKED], continue with Phases 5-11 as much as possible. The infrastructure is valuable even with one sorry.

2. **Countable fragment harder than expected**: Fall back to WitnessReachable definition; mathematical argument is clear from research-023.

3. **Truth lemma complex**: Follow existing Representation.lean template closely; same structure with adapted types.

4. **Any phase fails unexpectedly**: Each phase independently committed; use `git revert` to recover.

## Comparison with Prior Plans

| Aspect | implementation-004 | implementation-005 |
|--------|--------------------|--------------------|
| Strategy | Hybrid B+C (double-seed + Countable BQ) | K-Relational (Cantor + restricted fragment) |
| D construction | TranslationGroup automorphisms | Q discovered via Cantor |
| Countability | BidirectionalQuotient (proven false) | RestrictedFragment (countable by design) |
| task_rel | Not addressed | Non-trivial: `e(u) - e(w) = d` |
| Hard blockers | 5 (Holder, freeness, homogeneity, density, countability) | 1 (density only) |
| Mathlib leverage | Limited | Full Q infrastructure |
| Estimated lines | ~800 | ~795 |
| Risk | HIGH (multiple blockers) | MEDIUM (single blocker) |

## Philosophical Note

The K-Relational strategy preserves the "from syntax" requirement:
1. The canonical model (RestrictedFragment, CanonicalR) is built entirely from MCSes and syntactic conditions
2. Q appears not as an import but as a CHARACTERIZATION of the syntactic structure (Cantor's theorem)
3. The group structure on D is INHERITED from Q via the order isomorphism, not assumed
4. The non-trivial task_rel captures genuine temporal displacement from the syntax

Q is "discovered" as the unique (up to isomorphism) countable dense linear order without endpoints. If the canonical timeline satisfies these properties, then Q is its canonical description.
