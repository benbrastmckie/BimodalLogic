# Phase 9 Handoff: untl/snce Argument Convention Swap

## Session
- **Session ID**: sess_1778221275_3b41e2
- **Status**: Partial — core swap done, cascade incomplete

## What Was Done

### Core Changes (Complete)

1. **Truth.lean** — Swapped semantics:
   - `truth_at ... (untl φ ψ)` now has `φ` at witness (event), `ψ` at guard
   - `truth_at ... (snce φ ψ)` now has `φ` at witness (event), `ψ` at guard
   - All proof bodies in truth_double_shift_cancel and time_shift_preserves_truth updated

2. **Formula.lean** — Updated constructor docs and next/prev:
   - `next φ = Formula.untl φ Formula.bot` (was `untl bot φ`)
   - `prev φ = Formula.snce φ Formula.bot` (was `snce bot φ`)
   - Constructor docstrings updated to document Burgess convention

3. **Axioms.lean** — All 20 axiom constructors using untl/snce swapped

4. **Soundness.lean** — All soundness theorems for BX axioms updated (signatures + proofs)

5. **SoundnessLemmas.lean** — swap_temporal/truth bridge lemmas updated

6. **TemporalDerived.lean** — All derived theorem signatures updated

7. **TemporalCoherence.lean** — All coherence definitions updated:
   - `until_since_coherent`, `forward_until_since_coherent`, `backward_until_since_coherent`
   - Restricted versions also updated
   - Event now at witness position, guard at intermediates

8. **ParametricTruthLemma.lean** — IH applications swapped (ih_phi↔ih_psi)

9. **WitnessSeed.lean, CanonicalFrame.lean, SuccRelation.lean, Frame.lean** — Hypothesis types updated

### Remaining Work (5 files, ~58 errors)

All remaining errors are the same mechanical pattern: swapping which variable
is event vs guard in coherence-related proofs.

1. **RRelation.lean** (~27 errors) — The `burgessR` construction and its proofs.
   Pattern: wherever the code destructures coherence results as `⟨s, h_ts, h_psi_s, h_guard⟩`,
   the `h_psi_s` now corresponds to `φ` (event) and `h_guard` to `ψ` (guard).
   Fix: swap the variable names or swap which IH is applied.

2. **UntilSinceCoherence.lean** (~2 errors, lines 130, 164) — Backward coherence step proofs.
   Fix: swap `Formula.untl φ ψ` to `Formula.untl ψ φ` in step lemma signatures.

3. **BXCanonical/TruthLemma.lean** (~2 errors, lines 286, 311) — Same IH swap as ParametricTruthLemma.

4. **BXCanonical/Quasimodel/Construction.lean** (~4 errors) — Hintikka point coherence.

5. **RestrictedParametricTruthLemma.lean** — Same IH pattern as ParametricTruthLemma (may cascade after fixing ParametricTruthLemma).

### Mechanical Fix Pattern

For every error, the fix is one of:
- **Type signature**: `Formula.untl a b` → `Formula.untl b a` (and `snce` similarly)
- **IH swap**: `ih_phi` ↔ `ih_psi` in truth lemma proofs
- **Coherence destructuring**: Variable names like `h_psi_s`/`h_guard` now have swapped types

### Key Insight

After swapping BOTH the semantics AND all constructor calls, the mathematical
content is identical. The propositions `truth_at M Omega τ t (untl a b)` evaluate
to the same Prop before and after the swap (old: event=b at witness, guard=a;
new: event=a at witness, guard=b — but `a` and `b` are also swapped at call sites).

This means proof bodies that use `simp only [truth_at, ...]` to unfold everything
will generally still work. The failures are in proofs that directly reference
inductive hypotheses or destructured coherence results by name.

## Files Modified (Complete List)

- `Theories/Bimodal/Syntax/Formula.lean` — constructor docs, next/prev
- `Theories/Bimodal/Semantics/Truth.lean` — semantics definition + all proofs
- `Theories/Bimodal/ProofSystem/Axioms.lean` — all axiom formulas
- `Theories/Bimodal/Metalogic/Soundness.lean` — soundness theorem signatures + proofs
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` — swap bridges + soundness helpers
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — all derived theorem signatures
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — coherence definitions
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` — hypothesis types
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` — hypothesis types
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — signatures + proof bodies
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — backward reflexive
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — eventuality resolution
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` — IH swaps
