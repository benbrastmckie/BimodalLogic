# Research Findings: ParametricTruthLemma F-Case Analysis

**Analyst**: math-research-agent (teammate-a)
**Task**: 81 - F/P Witness Representation Theorem
**Date**: 2026-03-31

---

## The Answer

**The F-case (all_future / G forward direction) does NOT require `forward_F`.**

The G/H *forward* cases only use `fam.forward_G` and `fam.backward_H` — properties that live at
the FMCS level, available unconditionally without any temporal coherence assumption.

**`forward_F` (family-level existential coherence) is required only in the G/H *backward* direction.**

---

## Proof Structure

### G Forward Case (lines 316–319, `ParametricTruthLemma.lean`)

```lean
· -- Forward: G psi in MCS -> forall s ≥ t, truth tau s psi
  intro h_G s hts
  have h_psi_mcs : psi ∈ fam.mcs s := fam.forward_G t s psi hts h_G
  exact (ih fam hfam s).mp h_psi_mcs
```

This uses only `fam.forward_G` (an FMCS field, always available). No coherence hypothesis
(`h_tc`) is used.

### G Backward Case (lines 321–332)

```lean
· -- Backward: forall s ≥ t, truth tau s psi -> G psi in MCS
  intro h_all
  obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam   -- <-- h_tc USED HERE
  let tcf : TemporalCoherentFamily D := {
    toFMCS := fam
    forward_F := h_forward_F
    backward_P := h_backward_P
  }
  have h_all_mcs : ∀ s : D, t ≤ s → psi ∈ fam.mcs s := ...
  exact temporal_backward_G tcf t psi h_all_mcs
```

`h_tc` is destructured to extract `forward_F` (existential: F(phi) at t → ∃ s ≥ t with phi
in fam.mcs s) and `backward_P`. These are combined into a `TemporalCoherentFamily`, which is
passed to `temporal_backward_G`. The proof of `temporal_backward_G` (TemporalCoherence.lean
lines 165–178) proceeds by contraposition:

1. Assume G(phi) ∉ fam.mcs t
2. MCS maximality: neg(G(phi)) ∈ fam.mcs t
3. `neg_all_future_to_some_future_neg`: F(neg phi) ∈ fam.mcs t
4. **`forward_F`**: ∃ s ≥ t, neg(phi) ∈ fam.mcs s  ← critical step
5. By induction hypothesis: phi ∈ fam.mcs s (from h_all)
6. Contradiction in consistent MCS

**Step 4 is where `forward_F` is essential.** The witness `s` must be in the SAME family
`fam`, because the semantic hypothesis (`truth at all s ≥ t`) is evaluated along
`parametric_to_history fam`. A witness in a different family would live on a different
history and not generate the needed contradiction.

### H Case (lines 333–353)

Exactly symmetric: `fam.backward_H` in the forward direction; `backward_P` (via `h_tc`)
in the backward direction.

---

## Key Dependencies

| Case | Direction | Coherence Property Used | Source |
|------|-----------|------------------------|--------|
| G (all_future) | Forward | `fam.forward_G` | FMCS field — always available |
| G (all_future) | Backward | `forward_F` (via `h_tc`) | TemporalCoherentFamily — requires `h_tc` |
| H (all_past) | Forward | `fam.backward_H` | FMCS field — always available |
| H (all_past) | Backward | `backward_P` (via `h_tc`) | TemporalCoherentFamily — requires `h_tc` |
| Box | Both | `B.modal_forward`, `B.modal_backward` | BFMCS fields |
| F (some_future) | N/A | **Not a case** | F = neg(G(neg·)), handled structurally |
| P (some_past) | N/A | **Not a case** | P = neg(H(neg·)), handled structurally |

**Critical observation**: The formula `some_future` (F/P operators) does **not appear as a
case** in the truth lemma's induction. The truth lemma is defined by structural induction on
the Formula type. F and P are **not primitive constructors** in this formalization — they are
defined as abbreviations:
- `F(phi) = neg(G(neg(phi)))`
- `P(phi) = neg(H(neg(phi)))`

This means the truth lemma handles F/P *indirectly* through the neg and G/H cases.

---

## `forward_F` vs `forward_G`: Precise Distinction

| Property | Type | What it says | Where it lives |
|----------|------|-------------|----------------|
| `fam.forward_G` | `∀ t t' φ, t ≤ t' → G(φ) ∈ fam.mcs t → φ ∈ fam.mcs t'` | Universal: G distributes to future times | FMCS structure field |
| `forward_F` | `∀ t φ, F(φ) ∈ fam.mcs t → ∃ s, t ≤ s ∧ φ ∈ fam.mcs s` | Existential: F witnesses exist in same family | TemporalCoherentFamily / `h_tc` condition |

**`forward_F` is strictly stronger**: it requires actual witnesses to *exist* within the
family at some future time. This is non-trivial in incomplete constructions and is exactly
the problematic property for the F/P witness problem.

---

## Evaluation Context

- Truth is evaluated at `(fam, t)` for a SINGLE family: `parametric_to_history fam`
- The `fam` is fixed throughout the lemma; all IH applications use the same `fam`
- Exception: the **box case** quantifies over all `fam' ∈ B.families` (modal accessibility)
- For temporal operators: witnesses must come from the SAME `fam`, not different families

This confirms the module documentation at lines 48–50:

> "The witness must be in the SAME family `fam`, because the semantic hypothesis (truth at
> all s ≥ t) is evaluated along the history `to_history(fam)`. A witness in a DIFFERENT
> family would be evaluated along a different history and would not produce the needed
> contradiction."

---

## Implications for the F/P Witness Problem

### Is the problem already solved?

**No.** The F/P witness problem is genuinely hard. Here is why:

1. `temporal_backward_G` (needed for the G backward case) requires `forward_F`.
2. `forward_F` must be proven for whatever concrete family construction is used.
3. Providing `forward_F` for an arbitrary MCS embedded in a temporal family is exactly the
   content of the F/P witness problem: given `F(phi) ∈ fam.mcs t`, you must produce `s ≥ t`
   with `phi ∈ fam.mcs s`.

### What the G *forward* case shows

The G forward direction is already fully implemented and requires no `forward_F`. So the
forward direction of the truth lemma is essentially **free** given only FMCS structure.

### The bottleneck

The backward direction of the truth lemma requires `B.temporally_coherent` — which packages
`forward_F` and `backward_P` for every family in the bundle. Any completeness proof that uses
`parametric_canonical_truth_lemma` must first provide a `h_tc : B.temporally_coherent`. This
is where the F/P witness problem lives.

### The `temporal_coherent_family_exists_CanonicalMCS` placeholder

From ParametricRepresentation.lean (lines 65–68), the representation theorem table references
`temporal_coherent_family_exists_CanonicalMCS` as the BFMCS construction for D=Int. This is
the function that must provide `forward_F`/`backward_P` witnesses, and it is likely the locus
of any sorry or open obligation.

---

## Confidence Level

**High.** The analysis is based on:
- Complete read of `ParametricTruthLemma.lean` (506 lines)
- Complete read of `TemporalCoherence.lean` (223 lines)
- Complete read of `FMCSDef.lean` (129 lines)
- Complete read of `ParametricRepresentation.lean` (300 lines)

The proof structure is fully explicit in the Lean code with detailed comments. The module
docstring (lines 33–50 of ParametricTruthLemma.lean) explicitly confirms this analysis.

---

## Summary

| Question | Answer |
|----------|--------|
| Does F-case proof use `forward_F`? | **No** — F is not a primitive constructor; handled via neg+G |
| Does G-case forward use `forward_F`? | **No** — uses only `fam.forward_G` (FMCS field) |
| Does G-case backward use `forward_F`? | **Yes** — essential for contraposition argument |
| Where does `h_tc` (temporal coherence) enter? | Only in G/H backward cases, via `temporal_backward_G`/`H` |
| Is F/P witness problem already solved? | **No** — `forward_F` must still be provided by BFMCS construction |
| Does same-family requirement hold? | **Yes** — witnesses must come from same `fam`, not other families |
