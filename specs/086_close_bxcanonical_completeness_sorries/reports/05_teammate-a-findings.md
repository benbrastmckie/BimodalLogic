# Research Report: Teammate A — Deep Dive Through All Past Attempts

**Task**: 86 — Close BXCanonical completeness sorries
**Date**: 2026-04-09
**Mode**: Team Research (Teammate A — past attempts analysis)
**Session**: Research round 5

---

## Key Findings

### 1. Pattern Analysis: What Keeps Failing and Why

After reading through 39+ research rounds from task 83, plus task 84, 85, and 86 reports, a clear pattern emerges: **every approach hits the same 2-3 mathematical walls, in different disguises**. These are not separate problems — they are the same problem reformulated each time.

#### Wall 1: Forward F / Backward G Circularity (tasks 83, 84, 85, 86)

The most persistent blocker across all attempts:

- To prove `forward_F(psi)`: assume psi never appears in the chain, need `G(neg psi) in chain(t)` to derive contradiction with `F(psi)`.
- To get `G(neg psi) in chain(t)`: use `temporal_backward_G_with_fwd_F`, which requires `forward_F(neg neg psi)`.
- `sizeof(neg neg psi) > sizeof(psi)` — the formula grows. No well-founded measure descends.
- **Report 28**: documented this circularity exhaustively; proved formula size doesn't help; DovetailedChain architecture cannot avoid it.
- **Report 24**: showed quasimodel + pigeonhole approach reaches same wall at the cycle contradiction step.
- **Task 85 report 01**: Confirmed unbreakable for Architecture A (deterministic chain), and also confirmed that Architecture B (SuccChainFMCS) avoids it for `forward_F` itself, but hits it at `forward_Until_coherence`.
- **Task 86 handoff 01**: Confirmed this is the blocker for the `usf_completeness` G-contrapositive step.

#### Wall 2: Until Does Not Propagate Through g_content (the G-content Mismatch)

The second persistent blocker:

- `phi U psi in w` does NOT imply `G(phi U psi) in w` (semantically invalid: Until is existential, G is universal).
- The bx_le ordering is defined via g_content: `bx_le w v` means `g_content(w) ⊆ v.formulas`.
- So `phi U psi` does NOT propagate to bx_le-successors.
- The guard condition for `bx_until_eventuality_resolution` requires `phi in u` for ALL intermediate BXPoints u. But "intermediate" is defined via bx_le, and `phi U psi` doesn't flow forward.
- **Report 39 (task 83)**: All 3 teammates independently confirmed Path B (BXCanonical port) is impossible because of this universal quantifier over ALL BXPoints.
- **Task 85 report 01**: Confirmed bx_le ordering is not total (two BXPoints above w can be incomparable), which is exactly why the guard is unverifiable.
- **Task 86 report 01 (team research)**: All 3 teammates confirmed g_content/Until mismatch as root cause of all 4 Frame.lean sorries.

#### Wall 3: x_content Triviality Under Reflexive Semantics (discovered task 85)

A more recently discovered wall that invalidated many older approaches:

- Under BX reflexive Until (BX8: `psi -> phi U psi`): `X(alpha) = bot U alpha <-> alpha` in any MCS.
- Therefore `x_content(M) = M`, making deterministic chains constant.
- ALL x_content-based chain constructions (DeterministicChain.lean, DeterministicFMCS.lean in Boneyard) are degenerate — the chain never moves.
- **Task 85 report 01**: Discovered independently by Teammates B and C; confirmed by UntilSinceCoherence.lean docstring.
- Eliminates: deterministic chain approach, forward_F via finite deferral, all Boneyard chain files.

#### Wall 4: Burgess-Xu Axiom 4 Is Semantically Invalid (discovered task 85)

- The standard approach for guard verification in canonical completeness proofs uses Burgess-Xu axiom 4: `alpha AND chi U psi -> chi U (psi AND chi S alpha)`.
- This enriches the Until witness to carry a Since condition that encodes the guard.
- **Task 83 report 35**: Recommended deriving this from BX5+BX6+BX7 (Option A).
- **Task 85 report 01**: Proved this is impossible — the axiom is semantically invalid under the half-open guard `[t, s)` convention. At the witness point `s`, the Since formula `chi S alpha` requires `chi(s)`, but the Until guard only covers `[t, s)` (excluding s). Confirmed by Soundness.lean:397-401 comment.
- **Impact**: Closes off the entire "derive/add Burgess-Xu 4" strategy permanently.

---

### 2. What Has Been Tried (Exhaustive Inventory)

#### A. Chain-Based Approaches (all abandoned)

| Approach | Task | Outcome |
|----------|------|---------|
| UltrafilterChain / SuccChainFMCS | 83 | Sorries at `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P`; F-obligations cannot be forced via Lindenbaum extensions |
| DovetailedChain (Boneyard) | 83 | 6 sorries; `forward_dovetailed_until_persists` is genuinely unprovable; x_content / g_content mismatch |
| DeterministicFMCS (Boneyard) | 83 | `deterministic_forward_F` circular; x_content triviality makes chain constant under reflexive semantics |
| FiniteDeferral approach | 83 | Pigeonhole gives cycle but cycle contradiction step requires backward_G which requires forward_F (circular) |
| Enriched seed (targeted_g_content_seed_consistent) | 83/39 | Seed consistency provable but Until persistence breaks through Lindenbaum detours (X-vs-G mismatch) |
| Dovetailed fair scheduling (Nat.unpair) | 83 | Scheduling gap: G(neg phi) can enter chain before phi's turn; insufficient to guarantee forward_F |

#### B. BXCanonical Approaches (active architecture)

| Approach | Task | Outcome |
|----------|------|---------|
| bx_until_eventuality_resolution via Zorn (maximal persistence) | 83 | Failed 3 times; guard at intermediate BXPoints unverifiable because phi U psi doesn't propagate through g_content |
| bx_le redefinition via Until witness ordering | 86 round 1 | Forced by G truth lemma: bx_le must equal g_content inclusion; redefinition breaks 300+ lines of proved infrastructure |
| FMP bridge | 86 round 1 | fmp_completeness operates at MCS-membership level, not semantic level; bridging to `valid phi -> provable phi` requires same Until/Since work plus more |
| BX7 linearity -> bx_le totality | 85-86 | Unexplored at end of task 85, became focus of task 86; report 37 (task 83) proved bx_le is NOT linear (two BXPoints above w can be incomparable under bx_le) |
| Fragment completeness {bot, imp, box, G, H} | 86 | Viable for the USF fragment; Phase 1 (box preservation) completed sorry-free; remaining blocker is Phase 2 (dovetail chain construction) |

#### C. Semantic Redesign Approaches (abandoned)

| Approach | Task | Outcome |
|----------|------|---------|
| Reflexive semantics switch (Plan v26) | 83 | Resolves seed consistency but NOT Until persistence; breaks F_until_equiv (unsound under mixed strict/reflexive) |
| Strict Until -> reflexive Until conversion | 32 | Creates different problems in guard semantics (half-open vs closed interval) |
| Derive/add Burgess-Xu axiom 4 | 83/35 | Semantically invalid in this system; permanently closed |

#### D. What IS Sorry-Free (Genuine Progress Made)

- All BX axioms: sound, proved.
- G/H/Box truth lemma (TruthLemma.lean): `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs` — all sorry-free.
- Fragment completeness for `{bot, imp, box, G, H}` when nested in G/H — Phase 1 complete.
- `box_preserved_along_bx_le`, `bx_modal_equiv_of_bx_le`, `modal_omega_eq_of_bx_le` — NEW, sorry-free (task 86 Phase 1).
- `bx_G_forward`, `bx_backward_witness`, `bx_forward_witness` — sorry-free.
- `temporal_backward_G_with_fwd_F` (conditioned on forward_F) — sorry-free.
- FMP infrastructure: `TruthPreservation.lean` fully sorry-free after fixing temp_4 one-liner (task 85 fixed by Phase 3).
- Soundness theorem — sorry-free.
- BX decidability — sorry-free.

---

### 3. Current Sorry State (Task 86)

**BXCanonical module** (17 sorry lines total, 6 functional sorry sites):

| File | Line | Description | Blocking what |
|------|------|-------------|--------------|
| `Frame.lean:418` | 418 | Modal equivalence backward (□χ ∈ M → □χ ∈ w) | bx_modal_witness; isolated |
| `Frame.lean:646` | 646 | bx_until_eventuality_resolution | Forward Until truth lemma |
| `Frame.lean:668` | 668 | bx_until_backward | Backward Until truth lemma |
| `Frame.lean:683` | 683 | bx_since_eventuality_resolution | Forward Since truth lemma |
| `Frame.lean:697` | 697 | bx_since_backward | Backward Since truth lemma |
| `CanonicalEmbedding.lean:418` | 418 | usf_completeness imp Case B | USF fragment completeness |
| `Completeness.lean:153` | 153 | bx_completeness | Full BX completeness |

**Current active plan** (04_implementation-plan.md): Close `CanonicalEmbedding.lean:418` via dovetailed chain truth lemma. Phase 1 is COMPLETED. Phase 2 (dovetail chain construction) is BLOCKED by forward_F property.

---

### 4. The Current Blocker in Precise Terms (Per Handoff 01)

The current sorry at `CanonicalEmbedding.lean:418` (usf_completeness imp Case B) requires a **backward truth bridge**: given `chi not-in w`, construct a model where `chi` is false. For chi containing G/H, this requires:

- The history visits specific G-backward / H-backward witnesses.
- The dovetail chain construction provides this.
- But the dovetail chain must satisfy **G-contrapositive**: `(forall r >= s, alpha in chain(r)) -> G(alpha) in chain(s)`.
- G-contrapositive requires `forward_F` on the chain: given `G(alpha) not-in chain(s)`, get a future step where `neg alpha` appears.
- The dovetail chain is built by placing explicit G-backward witnesses at scheduled steps. If `G(alpha) not-in chain(s)`, then by `bx_G_backward` there exists a BXPoint above `chain(s)` with `neg alpha`. But the dovetail chain uses this witness at a specific scheduled step, and after that step, new G-formulas may enter (via the next scheduled witness), potentially later killing the `neg alpha` fact.
- This is **the same G-completeness failure** documented in handoff 01 for the dovetail scheduling approach.

The proposed Path 1 (Combined F-Seed Extension) addresses this by putting ALL pending F-obligations in the Lindenbaum seed at each step (not just one). But this requires:

```lean
theorem combined_F_seed_consistent (w : BXPoint)
    (L : List Formula) (hL : forall psi in L, Formula.some_future psi in w.formulas) :
    SetConsistent (L.toFinset union g_content w.formulas)
```

This is the **compactness argument** from Goldblatt 1992/Burgess 1984.

---

### 5. Recommended Approach: Combined F-Seed with Dovetail Scheduling

Based on the full history of attempts, the most viable path is:

#### Why Combined F-Seed Avoids Prior Failures

1. **Does NOT use x_content**: Not affected by x_content triviality. Uses g_content-based seeds.
2. **Does NOT use Burgess-Xu 4**: Not needed. Seeds directly include witnesses.
3. **Does NOT have the single-target scheduling gap**: By including ALL active F-formulas in each seed, no F-obligation can be killed by a later witness (because all witnesses are in the seed simultaneously).
4. **Does NOT require backward_G**: Forward_F is established by construction — if `F(phi) in chain(t)`, then by design `phi in chain(t+1)` (because phi was in the seed at step t).

#### The Key Lemma Required

```
combined_F_seed_consistent: ∀ w : BXPoint, ∀ L : List Formula,
  (∀ psi ∈ L, F(psi) ∈ w.formulas) →
  SetConsistent (L.toFinset ∪ g_content(w.formulas))
```

**Proof sketch** (standard from Goldblatt 1992, §6.5):
- Suppose inconsistent: some finite subset derives `bot`.
- That finite subset is `S ⊆ L ∪ g_content(w)`.
- Let `S_L = S ∩ L` (finitely many), `S_g = S ∩ g_content(w)`.
- From S_g: there exist G(alpha_i) ∈ w such that `g_content` of w contains `S_g`.
- The derivation gives: `S_g ⊢ neg(psi_1) ∨ ... ∨ neg(psi_k)` (disjunction of negations of the L-members).
- By G-distribution and Lindenbaum: `G(neg psi_1) ∨ ... ∨ G(neg psi_k) ∈ w` (from the derivation applied universally).
- But each `F(psi_i) ∈ w` means `G(neg psi_i) ∉ w` (by MCS).
- MCS negation completeness + consistency: `G(neg psi_1) ∨ ... ∨ G(neg psi_k) ∉ w`. Contradiction.

This argument uses: G-distribution, MCS propositional closure, temporal duality.

#### Difficulty Assessment

**Medium**. The combined seed consistency lemma is a standard argument but requires:
1. G-distribution over conjunction (already provable from BX1 + temporal K).
2. Temporal duality: `F(phi) in w <-> G(neg phi) not-in w` (should follow from MCS + definitional expansion).
3. Finite subset extraction from the Lindenbaum argument.

None of these appear to have hidden blockers from prior research.

#### What Needs to be Built

1. `combined_F_seed_consistent` — the core lemma (~50-100 LOC).
2. A modified dovetail chain that at each step extends using the combined seed for ALL current F-obligations, not one at a time.
3. Proof that this chain satisfies `forward_F` (by construction: every F(psi) in chain(t) has psi in chain(t+1)).
4. G-contrapositive: with forward_F, the `temporal_backward_G_with_fwd_F` lemma already exists and is sorry-free.
5. The rest of the truth lemma (G, H, box cases) follows from existing infrastructure.

---

### 6. Alternative Paths Ranked by Viability

| Path | Confidence | Why |
|------|-----------|-----|
| Combined F-Seed Extension (Path 1 from handoff) | Medium-High (65%) | Standard technique, no known prior blocker, avoids all 4 walls |
| Fragment completeness without Until/Since | High (85%) for fragment, Low (10%) for full | Already proved G/H/Box truth lemma; dovetail chain remains the blocker |
| Decidability route (soundness + decidability = completeness) | Low-Medium (40%) | DecisionProcedure.lean sorry status unknown; completeness form may not match |
| Derive Until-induction from BX5+BX6+BX7 | Low (25%) | No derivation found in 39+ research rounds; BX7 is formula-level, not ordering |
| Zorn's Lemma chain (Path 4 from handoff) | Low (20%) | Requires maximal chain to have forward_F by maximality, but Zorn gives maximal CHAIN (sequence), not maximal element; needs careful formulation |
| Fix SuccChainFMCS sorries | Very Low (5%) | 10+ sorries; hidden false lemma (`constrained_successor_seed_restricted_consistent`); 43 failed rounds |

---

### 7. What NOT to Do (High Confidence)

Based on the full history:

1. **Do NOT pursue BXCanonical Frame.lean sorries directly** (bx_until_eventuality_resolution, etc.). The universal quantifier over ALL BXPoints cannot be satisfied by any finite chain. This has been proved 3+ times.

2. **Do NOT try enriched single-step seed chains** without the combined-all-F-seeds variant. The scheduling gap always allows G(neg psi) to enter between when psi is "scheduled" and when it is checked.

3. **Do NOT try to derive/add Burgess-Xu axiom 4**. Semantically invalid in this system (half-open guard).

4. **Do NOT revive DeterministicChain or DovetailedChain from Boneyard**. x_content triviality makes deterministic chain constant; DovetailedChain has known architectural failure with Until persistence.

5. **Do NOT try well-founded induction on formula complexity for forward_F**. The dependency chain grows from psi to neg neg psi (+4 in size). No measure descends.

6. **Do NOT try to redefine bx_le**. It is forced by the G truth lemma to be g_content inclusion. Any alternative definition must be provably equivalent, providing zero benefit.

---

### 8. Evidence Summary

All findings are cross-referenced from actual reports:

| Claim | Source |
|-------|--------|
| forward_F / backward_G circularity is genuine | Task 83 report 28, §2.3; task 85 report 01, Finding 2 |
| x_content = M under reflexive semantics | Task 85 report 01, Finding 4; UntilSinceCoherence.lean:33-34 |
| Burgess-Xu axiom 4 semantically invalid | Task 85 report 01, Finding 5; Soundness.lean:397-401 |
| g_content / Until mismatch is root cause of Frame.lean sorries | Task 83 report 39 §2; task 86 report 01 §4 |
| bx_le is NOT total (two points above w can be incomparable) | Task 83 report 37 (referenced in report 39); task 85 report 01, §3a |
| FMP operates at MCS-membership, not semantic model level | Task 86 report 01, Finding 2 |
| Phase 1 (box preservation) is completed sorry-free | Task 86 handoff 01, Completed Work |
| Combined F-seed technique from standard literature | Goldblatt 1992 §6.5; Burgess 1984; Task 86 handoff 01 Path 1 |

---

## Confidence Level

**High** for the diagnosis (what keeps failing and why).

**Medium-High** for the recommended approach (combined F-seed extension). The key lemma (`combined_F_seed_consistent`) has a clear proof sketch from the literature. No prior attempt has tried it. The main uncertainty is whether there are hidden Lean formalization obstacles in the consistency proof.

**Low** for the Frame.lean sorries (bx_until_eventuality_resolution etc.). These appear to require bx_le linearity/totality on intervals, which bx_le provably lacks. No path to these sorries has been identified.

---

## Summary for Team Synthesis

The project has been going in circles on:
1. Chain-based forward_F (circular dependency, architectural impossibility, x_content triviality)
2. BXCanonical guard verification (g_content mismatch, bx_le non-totality)
3. Semantic redesigns (Burgess-Xu 4 invalid, reflexive/strict tension)

**The one approach NOT yet tried** is the combined F-seed extension: at each chain step, include ALL pending F-obligations (not just one) in the Lindenbaum seed. This is the standard technique in Goldblatt 1992. It makes forward_F trivially true by construction and avoids the G-completeness failure.

**The current blocker** (task 86 phase 2, dovetail chain G-contrapositive) IS addressable via combined F-seed, but requires proving `combined_F_seed_consistent` first (~50-100 LOC, medium difficulty).

**The Frame.lean sorries** (bx_until_eventuality_resolution etc.) appear genuinely blocked by bx_le non-totality. They should not be the focus of implementation effort. The target sorry is `CanonicalEmbedding.lean:418` only.
