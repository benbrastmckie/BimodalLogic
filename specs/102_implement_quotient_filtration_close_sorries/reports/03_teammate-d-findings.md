# Teammate D Findings: Strategic Horizons for Until/Since Sorry Closure (Round 3)

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Role**: Teammate D (Horizons)
- **Date**: 2026-04-11

## Key Findings

### 1. The Fundamental Insight the User is Pointing At

The user's comment -- "bx_le is a preorder (not total), and non-G formulas cannot propagate through it is close to the heart of matters, well worth deep thought and reflection" -- is directing attention to the ARCHITECTURAL mismatch between what bx_le IS (a preorder defined by G-formula inclusion) and what the Until truth lemma NEEDS (a total order where arbitrary formulas are determined at intermediate points).

After deep reflection, I believe the user is seeing something the prior research has missed: **this is not a bug to be worked around -- it is a signal that the canonical model needs to be understood differently.**

### 2. A Derived Unfolding Theorem: The Missing Piece?

I identified a derivable theorem from the existing BX axioms that has not appeared in any prior research:

**Theorem (Until Unfolding)**: `(phi U psi) -> psi OR (phi AND F(phi U psi))`

**Derivation from BX1-BX12**:

1. BX9: `(phi U psi) -> phi OR psi`. So if psi holds, done. If psi does not hold, phi holds.
2. BX1 (contrapositive): `not phi -> not G(phi)`. Applied to `not(phi U psi)`: if `G(not(phi U psi))` held, then `not(phi U psi)` holds (BX1), contradicting `phi U psi`. So `not G(not(phi U psi))` = `F(phi U psi)` holds.
3. Combining: from `phi U psi`, either psi holds, or `phi AND F(phi U psi)` holds.

**Significance**: This is the reflexive-semantics analogue of the classical unfolding `phi U psi <-> psi OR (phi AND X(phi U psi))`, but using F instead of X. Under reflexive semantics, X is degenerate (X(alpha) = alpha), so the classical unfolding collapses. The F-based unfolding does NOT collapse -- it provides genuinely new information: phi U psi persists into the future.

**Confidence**: HIGH (100%). This is a straightforward derivation from BX1 + BX9.

### 3. Why the Unfolding Alone Does Not Close the Gap

The unfolding gives `phi U psi -> F(phi U psi)`. So there exists v >= w (in the bx_le sense, via bx_forward_witness on F(phi U psi)) with phi U psi in v. At v, either psi holds (and we have our witness) or phi AND F(phi U psi) again. This looks like it should terminate, but:

- **No decreasing measure**: The defect count at v is NOT necessarily smaller than at w. The same Until formula `phi U psi` is the defect at both w and v. Unlike the Hintikka chain construction (where each step can discharge a DIFFERENT defect), this unfolding just reproduces the SAME defect.

- **The guard problem persists**: Even if we could find a chain w = v0, v1, ..., vk with bx_le vi v(i+1) and phi U psi at each vi (until psi at vk), we would need phi at ALL intermediate BXPoints u with bx_le w u and bx_lt u vk -- not just at the chain members vi.

**Confidence**: HIGH. The gap is real and structural.

### 4. The Two-Phase Completeness Idea

The user asked about a "two-phase completeness proof": Phase 1 for G/H/box (already done), Phase 2 extending to Until/Since with a separate model having total temporal ordering.

This is actually the most promising creative direction. Here is why:

**What Phase 1 gives us**: The truth lemma for atom, bot, imp, box, G, H is FULLY proved. The canonical model (BXPoints with bx_le ordering) is correct for these connectives. The bx_le preorder is sufficient because G/H only quantify over ALL points in one direction -- they do not need a total order.

**What Phase 2 needs**: For Until/Since, we need a total order on the points. But we do NOT need to modify the existing Phase 1 proof. We need to show that the Phase 1 canonical model can be EMBEDDED INTO a model with a total temporal ordering that agrees with bx_le on G/H semantics.

**Szpilrajn's theorem** (every partial order has a linear extension) is NOT sufficient because: (a) bx_le is a preorder, not a partial order (not antisymmetric), and (b) a random linear extension does not preserve formula membership at intermediate points.

However, **a SELECTIVE linear extension** might work: use BX7 and BX11 to constrain the linear extension. BX7 says Until-witnesses are linearly ordered. BX11 says F-witnesses are linearly ordered. These axioms give us enough ordering constraints that the "permitted" linear extensions form a non-empty set, and by Zorn's lemma, a maximal one exists.

**The question**: Does a BX7/BX11-compatible linear extension of bx_le preserve the truth of Until/Since formulas? This is the key research question that no prior analysis has addressed.

**Confidence**: MEDIUM (40%). The idea is mathematically coherent but unverified. The main risk is that BX7/BX11 constrain witnesses but not the INTERVALS between witnesses.

### 5. Reframing the Problem: What Does bx_le Actually Mean?

The user's insight suggests we should think more carefully about what bx_le IS, not just what it fails to be.

`bx_le w v` = `g_content(w) subset v.formulas` = `for all phi, G(phi) in w -> phi in v`.

This means: **v is a possible "next state" of w in the sense that every invariant (G-formula) that holds at w still holds at v.** This is a SAFETY property: bx_le preserves invariants.

Until is a LIVENESS property: `phi U psi` says "eventually psi, with phi holding along the way." The fundamental tension is: **bx_le captures safety (invariant preservation) but not liveness (eventual satisfaction with guards).**

In the temporal logic literature, this safety/liveness distinction is resolved by either:
(a) Working in a model where the ordering IS defined by both safety and liveness constraints (Burgess's chain construction), or
(b) Working in a finite quotient where both are decidable (filtration/quasimodel).

The codebase's bx_le captures only the safety side. This is why the Until truth lemma is blocked.

**Confidence**: HIGH. This is a clean reframing of the known blocker.

### 6. The Minimal Path: Strengthen the Backward Witness Construction

Rather than changing bx_le globally, the minimal intervention might be to strengthen the BACKWARD direction. Currently, `bx_backward_witness` constructs v with h_content(w) subset v and any additional seed formula. What if we construct a specialized backward witness that is tailored for Until?

Given: phi U psi in w, psi not in w. We want v with bx_le w v, psi in v, phi at all intermediate u.

**Enriched forward witness**: Construct v by extending the seed:

```
S = {psi} union g_content(w) union {all G(chi) such that chi U theta in w and theta not in w}
```

The idea: the seed includes not just g_content(w) (ensuring bx_le w v) and psi (the witness), but also ALL G-formulas of active Until defects. This ensures that at v, all active Until formulas from w are "visible" via their G-content.

**Consistency check**: Is S consistent?

- g_content(w) is consistent (standard lemma).
- Adding psi: consistent because F(psi) in w means G(not psi) not in w, so g_content(w) does not derive not psi.
- Adding G(chi) for chi U theta defects: need G(chi) to be consistent with g_content(w) union {psi}. From BX5: chi U theta -> (chi AND chi U theta) U theta. By BX9 on chi U theta (with theta not in w): chi in w. By BX4: G(P(chi)) in w. But G(P(chi)) is not G(chi). The step from chi in w to G(chi) consistent with g_content(w) requires chi to be derivable from g_content(w) -- which is only true if G(chi) in w.

This approach fails because G(chi) is NOT in w in general just because chi in w.

**Confidence**: LOW (20%). The enrichment idea is natural but the consistency step fails.

### 7. The Nuclear Creative Option: Bypass Frame.lean Entirely

The most radical creative option: **Do not prove the Frame.lean sorries at all. Instead, restructure Completeness.lean to NOT go through the Frame.lean truth lemma for Until/Since.**

The current flow is:
```
bx_completeness -> truth lemma -> until_iff_mcs -> bx_until_eventuality_resolution (sorry)
```

Alternative flow:
```
bx_completeness -> finite model completeness -> ...
```

This would mean: given a consistent formula phi, build a FINITE model directly (not via the canonical model) and show phi is satisfiable. The finite model would be a Hintikka structure built from the quasimodel infrastructure. The ordering is position in the defect-discharge chain (total by construction). The truth lemma is trivially correct because the model IS built to make phi true.

**Key advantage**: The finite model does not use bx_le at all. The G/H truth conditions in the finite model are handled by chain-transitivity, not by g_content inclusion. Until/Since are handled by the chain's linear ordering.

**Key disadvantage**: This requires building a separate `TaskModel` embedding for the finite model, which is exactly the Completeness.lean:154 sorry. However, a finite chain IS a much simpler TaskModel than the full canonical model: choose D = Fin n (for some n), each history visits chain members in order.

**This would close BOTH the Until/Since sorries AND the TaskModel embedding sorry (Completeness.lean:154) simultaneously.** It would bypass Frame.lean entirely (those sorries would become dead code -- never called by the proven completeness theorem).

**Confidence**: MEDIUM-HIGH (60%). The approach is mathematically sound (finite model construction for temporal logic is standard -- see Goldblatt 1992 Ch. 5, Reynolds 2003). The risk is implementation complexity in Lean 4 (building the TaskModel, defining histories over Fin n, etc.).

**Estimated effort**: 25-35 hours for the finite model + TaskModel embedding + completeness proof. This is comparable to the current plan's Phase 4-alt (16h) + Phase 5 (4-8h) + task 93's TaskModel sorry (unknown, probably 10-15h). So the total cost is SIMILAR, but this approach closes MORE sorries (6 vs 4 Frame + 1 Completeness) and has HIGHER confidence.

### 8. Strategic Assessment Against ROAD_MAP

The ROAD_MAP priority order is:
1. Task 94: Archive legacy code (drops ~210 sorries, mechanical)
2. Tasks 90/92/102: Close Until/Since sorries (4 Frame + 6 Realization)
3. Task 93: Box modal-equiv + TaskModel embedding (2 sorries)
4. Task 95: Axiom audit

**Strategic observation**: The box modal-equivalence sorry (Frame.lean:440) has actually already been proved in the code I read! Lines 444-498 of Frame.lean contain the full S5 argument using modal_5_collapse, and it compiles (the sorry at line 440 mentioned in the ROAD_MAP appears to be stale -- the code I see has the proof inline). Let me verify this is correct...

Actually, re-reading more carefully: the ROAD_MAP says sorry at line 440, but the current Frame.lean I read has the full proof at lines 444-498 with the S5 negative introspection argument. The sorry count in the ROAD_MAP may be stale.

If the box sorry is already closed, then the remaining active-path sorries are: 4 Frame.lean Until/Since + 1 Completeness.lean TaskModel = 5. The finite model approach (Finding 7) would close all 5 simultaneously plus the 6 Realization.lean sorries = 11 total, reducing the active-path sorry count to 0.

**Confidence on stale count**: MEDIUM (50%). I need to verify whether the code I read is the current state or whether there's a sorry I missed.

### 9. Practical Recommendation: A 3-Track Investigation

Given the analysis above, I recommend a parallel 3-track investigation with clear time-boxes and decision gates:

**Track A: BX7 Direct Proof (4h time-box)** [Already in plan, Phase 3]

Continue the BX7 investigation as currently planned. If BX7 closes the forward direction, the backward direction may follow. Cheapest option if it works.

Decision gate: After 4h, either have a proof sketch or abandon.

**Track B: Derived Unfolding + Defect Induction (3h time-box)** [NEW]

Investigate whether the derived unfolding `phi U psi -> psi OR (phi AND F(phi U psi))` combined with a MULTI-DEFECT decreasing measure can close the forward direction. The key insight: use BX5 to enrich the Until formula as `(phi AND phi U psi) U psi`, then BX7 to compare this with other Until defects. Each unfolding step may discharge a DIFFERENT defect, giving a decreasing measure across the FULL defect set.

Decision gate: After 3h, either have a decreasing measure or abandon.

**Track C: Finite Model Bypass (8h proof-of-concept)** [NEW]

Build a minimal finite model construction that bypasses Frame.lean:
1. Define `FiniteChainModel` as a list of Hintikka points (or MCSs) with position ordering
2. Prove Until truth lemma in this model (trivial: chain is linear)
3. Show this model can be embedded as a TaskModel over Fin n
4. Wire into Completeness.lean

Decision gate: After 8h, have either a working TaskModel embedding or a clear blocker.

**Recommended order**: A first (cheapest), then B (novel), then C (most reliable).

## Confidence Summary

| Finding | Confidence | Impact |
|---------|------------|--------|
| 1. User's insight about architectural mismatch | HIGH (90%) | Strategic framing |
| 2. Derived unfolding theorem | HIGH (100%) | Derivable, but insufficient alone |
| 3. Unfolding alone does not close gap | HIGH (95%) | Confirms need for additional technique |
| 4. Two-phase completeness idea | MEDIUM (40%) | Promising but unverified |
| 5. Safety vs liveness reframing | HIGH (90%) | Conceptual clarity |
| 6. Enriched forward witness | LOW (20%) | Consistency step likely fails |
| 7. Finite model bypass | MEDIUM-HIGH (60%) | Most reliable path; closes most sorries |
| 8. Box sorry may already be closed | MEDIUM (50%) | Needs verification; affects strategic priority |
| 9. 3-track investigation | HIGH (85%) | Practical and risk-hedged |

## Cross-References

- Previous round: `specs/102_.../reports/02_teammate-d-findings.md`
- Team synthesis: `specs/102_.../reports/02_team-research.md`
- Task 98 v5 plan: `specs/098_.../plans/05_quasimodel-pivot-plan.md`
- Frame.lean sorries: lines 607-648
- Completeness.lean sorry: line 154
- Quasimodel infrastructure: `Quasimodel/Construction.lean`, `Quasimodel/HintikkaPoint.lean`
- BX axioms: `ProofSystem/Axioms.lean:154-273`
