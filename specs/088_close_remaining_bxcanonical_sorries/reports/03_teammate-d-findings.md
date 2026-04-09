# Teammate D Findings (Round 3): Strategic Horizons

**Task**: 88 -- Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Role**: Teammate D (Strategic Horizons)
**Focus**: Big-picture value assessment, publication story, priority of the 6 sorries

---

## Key Findings

### 1. What the Project Can Claim TODAY (Without Closing Any More Sorries)

The project already has a publication-quality story. The `Metalogic.lean` module documents
three sorry-free, axiom-free results:

| Result | Theorem | Status |
|--------|---------|--------|
| **Soundness** | `soundness` in `Soundness.lean` | SORRY-FREE, AXIOM-FREE |
| **Base Completeness** | `base_truth_lemma` infrastructure | SORRY-FREE, AXIOM-FREE |
| **Decidability** | `validity_decidable` + `fmp_completeness` | SORRY-FREE, AXIOM-FREE |

The decidability result (`validity_decidable`) is especially strong: it uses `fmp_contrapositive`
and `mcs_finite_model_property` to establish that:
- Validity is decidable (classical `em`)
- Any unprovable formula has a **finite countermodel** bounded by `2^|closure(φ)|`

The **Finite Model Property** is sorry-free. The `FMP.lean` and `Correctness.lean` modules
have zero sorries in the `Decidability/` subtree. This is not a trivial result — it establishes
the fundamental algorithmic character of TM logic.

**Fragment completeness** (`usf_completeness` in `CanonicalEmbedding.lean`) covers the
Until/Since-free fragment `{atom, bot, imp, box, G, H}`, with one remaining sorry for the
imp Case B (partial, but the theorem exists and is stated cleanly).

Additionally, the **D-parametric algebraic representation theorem** in
`ParametricRepresentation.lean` is sorry-free. This is the abstract framework from which
concrete completeness instantiations are derived.

### 2. What Closing the 6 Sorries Would Give

The 6 sorries sit at the top of a dependency chain:

```
Frame.lean (4 sorries: eventuality resolution)
    -> TruthLemma.lean (Until/Since truth bridge)
        -> CanonicalEmbedding.lean (1 sorry: imp Case B)
            -> Completeness.lean (1 sorry: bx_completeness)
```

Closing all 6 yields `bx_completeness`:

```lean
theorem bx_completeness (φ : Formula) : valid φ → Nonempty (DerivationTree [] φ)
```

This is the full **representation theorem** for TM bimodal logic: every valid formula (true
in all task frames) is derivable in the BX proof system. Together with sorry-free soundness,
this completes the `valid ↔ provable` circle.

This is qualitatively different from what the project has today:
- **FMP** gives: unprovable → finite countermodel (finitary failure)
- **Soundness** gives: provable → valid (proof-to-model direction only)
- **bx_completeness** gives: valid → provable (the hard direction; completes the circle)

### 3. Novelty in the Formalization Community

Lean/Mathlib search (via `lean_leanfinder`) finds only **first-order logic completeness**
results in Mathlib (Lindenbaum, DLO completeness). No bimodal, temporal, or tense logic
completeness theorems exist in Mathlib or in the broader Lean 4 ecosystem to the best of
available knowledge.

**The project would be a first**: formal verification in Lean 4 of completeness for a
bimodal logic combining S5 modal semantics with linear temporal operators (Until/Since).
The Burgess-Xu axiom system (BX) is standard in the literature; formalizing its completeness
in Lean 4 has not been done.

For comparison, the state of the art in proof assistant formalizations of modal/temporal logic:
- **Coq**: Several modal logic completeness proofs exist (e.g., Vestergaard, Simpson for
  intuitionistic modal logic). K, S4, S5 completeness proofs exist.
- **Isabelle**: CTL/LTL model checking verification, but not pure-logic completeness in
  the Hilbert-system sense.
- **Lean 4**: No temporal logic completeness theorems in Mathlib or widely-known projects.

A sorry-free `bx_completeness` would be a legitimate "first" claim.

### 4. Comparison: Soundness Only vs. Completeness

**Soundness alone** (what the project has) is the easier direction: show that the proof
system is consistent with the semantics. Every logician expects soundness to hold; it is a
sanity check.

**Completeness** (what `bx_completeness` gives) is the harder and more interesting direction:
the axiom system is *strong enough* to prove everything true. This requires that:
1. The BX axiom list is complete (not missing any axioms) -- task 88's Phase 1 already
   addressed this by restoring `temp_linearity` (BX11) and `F_until_equiv` (BX12).
2. The canonical model construction works for Until/Since formulas -- this is precisely what
   the 4 Frame.lean sorries block.

A proof assistant formalization of completeness is more valued than soundness alone because:
- It validates the axiom set (the restored BX11/BX12 were necessary additions)
- It constitutes a checkable certificate that the logic is "right"
- Completeness for Until/Since is technically harder than for pure modal logic (requires
  eventuality resolution, the main obstacle in Frame.lean)

### 5. Strategic Assessment of the 6 Sorries

**Priority ordering** (highest leverage first):

| Priority | Sorry | What Closing It Gives |
|----------|-------|----------------------|
| 1 | Frame.lean:653 (forward Until) | Unlocks all other sorries |
| 2 | Frame.lean:690 (forward Since) | Mirror of (1); closes the Since case |
| 3 | Frame.lean:675 (backward Until) | Likely simpler (contradiction + BX8) |
| 4 | Frame.lean:704 (backward Since) | Mirror of (3) |
| 5 | CanonicalEmbedding.lean:418 | Unlocks Completeness.lean |
| 6 | Completeness.lean:160 | The capstone; closes bx_completeness |

The 4 Frame.lean sorries are the critical bottleneck. The remaining 2 are downstream.

**Is closing ALL 6 necessary for a meaningful result?**

No, but partial closure has diminishing returns:
- Closing 0-3 sorries: No new theorem-level claim (infrastructure improvement only)
- Closing 4/4 Frame.lean sorries: Unlocks the **full truth lemma** (sorry-free). This is
  independently valuable and could be published as a separate lemma.
- Closing 5/6 (including CanonicalEmbedding): Gives sorry-free `usf_completeness` for the
  full Until/Since-free fragment (G/H/box/atom). This is a publishable fragment result.
- Closing 6/6: Gives sorry-free `bx_completeness`. Full representation theorem.

**Fragment completeness as a publishable result**: The Until/Since-free fragment covers
S5 modal logic + G/H tense operators. This is the bimodal logic studied in philosophy of
time and agency (Priorean tense logic). A sorry-free completeness for this fragment would
be a publishable "first" even without Until/Since.

### 6. Does FMP Serve as an Alternative Representation Theorem?

The FMP (`fmp_contrapositive`) already serves as a *weak* representation theorem:
unprovable → countermodel exists. But it is not the same as the representation theorem
in the standard sense because:
- FMP gives: ¬provable φ → ∃ finite model where φ fails
- Representation theorem gives: valid φ → provable φ (universally, not finitely)

The FMP does NOT imply full completeness unless combined with a semantic argument that
finite validity implies full validity. For TM logic, this combination is valid (the FMP
says finite models are sufficient), but the Lean formalization has not wired this together
into `bx_completeness`.

The path: `FMP.fmp_contrapositive` + `valid → valid_on_finite_models` → `bx_completeness`.
This is **Alternative B** from Round 2: a 2-hour research spike to check if
`valid_on_finite_models` is already in scope. If yes, this bypasses the Frame.lean sorries.
This should be investigated before committing to the Frame.lean proof engineering.

### 7. Decidability as the Main Result

The project already has `validity_decidable` and `fmp_completeness`. For a
"computation-focused" publication story, these are sufficient:

**Current claim (sorry-free)**:
- TM bimodal logic is decidable
- Any unprovable formula has a finite countermodel of size ≤ 2^|closure(φ)|
- Soundness: every proof corresponds to a valid formula

**Enhanced claim (after closing 6 sorries)**:
- All of the above, plus: every valid formula has a proof (completeness closes the circle)

The decidability result is already strong for a "first formalization in Lean 4" story.
The completeness theorem makes it publication-quality for a logic venue.

### 8. What the Round 2 Team Got Right and What's Still Open

Round 2 correctly identified that:
- `bx_le_total` (global) is false; interval linearity is the correct formulation
- Phase 1 (axiom restoration) was independently valuable and is now complete
- Quick wins in ConservativeExtension are available (mechanical, ~1-2 hours)

What is still underassessed:
- **The FMP bridge** (Alternative B from Round 2): This needs a 2-hour spike BEFORE
  committing to Phase 2 formalization. If `valid_on_finite_models` is derivable from
  the existing `FMP.lean` infrastructure, the Frame.lean sorries can be bypassed.
- **The publication threshold**: Closing 5/6 sorries (leaving Completeness.lean for later)
  already gives a publishable fragment completeness claim.

---

## Strategic Assessment

### What the Project Would Lose by Stopping Now (0 more sorries closed)

The FMP + soundness + decidability story is publication-ready for a *system description*
paper at a proof assistant venue (ITP, IJCAR). The missing piece is the completeness direction.

Without `bx_completeness`, the project cannot claim "the first verified proof of TM logic
completeness." This is the strongest academic claim available, and it requires closing all 6.

### What Closing the Frame.lean Sorries (4 of 6) Would Give

This is the highest-value subset to close. The 4 Frame.lean sorries unlock:
1. Sorry-free truth lemma for Until/Since
2. The ability to construct valid chain-based countermodels
3. Downstream unblocking of CanonicalEmbedding and Completeness

Closing just the 4 Frame.lean sorries without closing CanonicalEmbedding would give
infrastructure value but not a clean theorem statement.

### Recommended Strategic Priority

**Immediate (highest leverage, ~2 hours)**:
Investigate the FMP bridge: Can `valid → valid_on_finite_models → provable` be closed
using the existing `fmp_contrapositive` + `FilteredWorld` infrastructure? This would
bypass all 6 BXCanonical sorries entirely.

**Short-term (if FMP bridge fails)**:
Close the 4 Frame.lean sorries via interval linearity (Round 2 plan, reformulated Phase 2).
This is the highest-leverage subset — it unblocks the truth lemma and enables the
CanonicalEmbedding and Completeness proofs.

**Medium-term**:
Close CanonicalEmbedding (5/6) to reach sorry-free fragment completeness.
This is a publishable "first formalization of S5+G/H completeness in Lean 4" claim.

**Long-term**:
Close Completeness.lean (6/6) to reach full `bx_completeness`.
This is the publication-quality "first formal verification of TM bimodal logic completeness."

---

## Recommended Priority (for this round of implementation)

1. **FMP bridge spike** (2 hours, 55% confidence of bypassing BXCanonical entirely)
2. **Frame.lean interval linearity** (4-8 hours, 65% confidence)
3. **Frame.lean backward Until/Since** (2-4 hours, 70% confidence after interval linearity)
4. **CanonicalEmbedding** (4-8 hours, 60% confidence after Frame.lean)
5. **Completeness** (2-4 hours, 80% confidence after CanonicalEmbedding)

Quick wins (do in parallel regardless):
- ConservativeExtension mechanical fixes (~1-2 hours, 90% confidence)

---

## Confidence Level

| Claim | Confidence | Basis |
|-------|-----------|-------|
| Project can publish on decidability + FMP today | HIGH (90%) | All relevant theorems are sorry-free |
| Sorry-free bx_completeness would be a "first" in Lean 4 | HIGH (85%) | No temporal logic completeness in Mathlib; search confirms |
| Fragment completeness (5/6 sorries) is a publishable milestone | HIGH (80%) | USF fragment = S5 + G/H; already studied in literature |
| FMP bridge can bypass Frame.lean sorries | MEDIUM (55%) | Requires `valid → finite valid` connection not yet verified |
| Closing all 6 sorries in this task completes the circle | HIGH (85%) | Dependency chain is clear; sorries are structural not conceptual |
| bx_le_total globally is provable | VERY LOW (5%) | Confirmed false by prior counterexample |
