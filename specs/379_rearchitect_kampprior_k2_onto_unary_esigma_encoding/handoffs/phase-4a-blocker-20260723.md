# Phase 4a Blocker Handoff — Phase-4 staging gap (design-level escalation, no code attempted)

- **Task**: 379 — rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Plan**: `plans/21_infinite-esigma-alphabet-optionA-v2.md` (Phase 4 / 4a now `[BLOCKED]`)
- **Session**: sess_1784829998_2462de
- **Date**: 2026-07-23
- **State at handoff**: green HEAD for Lean (no `.lean` edits made this run; working tree carries only
  the pre-existing non-Lean modifications `.claude-extensions.json`, `README.md`, `specs/events.jsonl`).
  Full `lake build` remains EXIT 0 at HEAD; `#print axioms completeness_discrete` byte-identical to
  baseline. The three permitted sorries are unchanged.

## TL;DR

Phase 4a was resumed per the flip-last sequencing. Before writing any code, static inspection of the
actual enumeration surface refuted the flip-last decision's central premise. The plan's Phase-4
decomposition (4a lands green off-path as a bounded sub-run, then 4b/4c) is **not realizable as
written**, because the per-formula re-representation of `UnaryType` is a single whole-surface change,
not a per-file-incremental one, and a foundational rendering-layer re-encode it needs is outside the
Phase-4 file scope. This is a **planning decision**, escalated per `plan-compliance.md` (`.lean` files:
raise a blocker, do not invent a substitute decomposition). No code was written.

## The two findings (static evidence only)

### Finding 1 — the per-formula `UnaryType` re-representation breaks the whole surface at once

- Current: `UnaryType sig F := NormalForm (sigE sig F) 0 1` — a TOTAL truth assignment to all E[Σ]
  unary atoms (`ExistsForallFormula.lean:57`). It is referenced as a bare, `M`-free type in ~19 files:
  - `ExistsForallFormula.pointType : Fin (n+1) → UnaryType sig F` (a stored field type);
  - `IntervalType sig F := Finset (UnaryType sig F)` (element type);
  - `unaryToFormula … (τ : UnaryType sig F)` (`Prop35ExistsForall.lean`);
  - `skelDisjunct (σ : Fin (m+1) → UnaryType sig F)` / `skelR := Finset.univ : Finset (Fin (m+1) →
    UnaryType sig F)` (`LiftPair.lean:87/101`).
- The Phase-1 gate representation is `UnaryTypeFin sig F M := {a // a ∈ M} → Bool`
  (`InfAlphabetProbe.lean:86`) — PARAMETERIZED by the mentioned-atom set
  `M : Finset (AtomKind (sigE sig F) 1)`.
- Promoting the gate rep into production is therefore one of:
  - **(a) arity change** — add an `M` parameter to `UnaryType`; every one of the ~19 consumers' bare
    `UnaryType sig F` references breaks simultaneously;
  - **(b) semantics change** — bundle `M` into the type (e.g. `Σ M, ({a // a ∈ M} → Bool)`); this keeps
    the arity but weakens satisfaction: `unaryHolds` goes from "agrees on ALL atoms" to "agrees on the
    bundled `M`", so every correctness lemma (`unaryHolds_iff`, `intervalHolds_ofComplete_iff`,
    `unaryToFormula_correct`, `translateProp35_correct`, `liftPair_forward/backward`) must be re-proven
    under the weaker relation.
- **Key point:** keeping `sigE` finite (the flip-last device) preserves the `Fintype`/`DecidableEq`
  INSTANCES on `UnaryType`, but it does NOT preserve the TYPE's arity/semantics. The break in (a)/(b) is
  independent of alphabet finiteness. So "3 + 4a together green" is unreachable for exactly the same
  reason the Phase-3 blockquote gave for the summand flip — the per-formula re-encode is inseparable
  from the same whole-surface break it was meant to stage around.

### Finding 2 — the atomic rendering layer is `Fintype (sig.preds)`-dependent and out of Phase-4 scope

- `translateProp35` (`Prop35Assembly.lean`) is already `Finset.univ`-free (it folds `disj` over an
  explicit `S.toList`, not `Finset.univ`). But it renders each type via
  `unaryToFormula` (`Prop35ExistsForall.lean:65`) → `nf_depth0_char_formula`
  (`Separation/KampTranslation.lean`), which builds the characteristic formula by folding over
  `(Fintype.elems (α := sig.preds)).val.toList` under an explicit `[Fintype sig.preds]` — i.e. it
  conjoins over ALL predicates.
- Under the infinite E[Σ] alphabet, `Fintype (sigE sig F).preds` does not exist, so a total `UnaryType`
  cannot be rendered to a `Formula` at all. `unaryToFormula`/`nf_depth0_char_formula` must be re-encoded
  onto per-formula-`M` rendering (mentioned atoms only), and `unaryToFormula_correct` /
  `translateProp35_correct` re-established under partial satisfaction.
- The Phase-1 gate did NOT exercise this: it proved only the "type = finite disjunction of atoms"
  equivalence (`typeEqFiniteDisjunction`) and its instantiation on a trivial `ξConcrete` — never the
  render step, never `translateProp35_correct`.
- `Separation/KampTranslation.lean` is in the foundational layer and is listed in NONE of Phase
  4a/4b/4c's "Files to modify".

## Alphabet-dependent enumeration inventory (for the re-plan)

Genuinely alphabet-dependent `Finset.univ` sites (typed at `UnaryType`/`AtomKind (sigE …)`; the many
`Finset.univ : Finset (Fin …)` index enumerations are harmless and unaffected):

| Site | Role | Phase |
|---|---|---|
| `IntervalType.lean:72` `intervalTop := Finset.univ : Finset (UnaryType sig F)` | ⊤ interval type | 4a |
| `LiftPair.lean:101` `skelR := Finset.univ : Finset (Fin (m+1) → UnaryType)` | tuple skeleton | 4b |
| `LiftPair.lean:246/596/869` `Finset.univ : Finset (Fin (K+1) → UnaryType)` .filter | tuple skeleton | 4b |
| `Prop43Translate.lean:344` `Finset.univ : Finset (Fin (m+1) → UnaryType)` .filter | δ translate | 4c |
| `ESigmaCapture.lean:92/95` `Finset.univ.filter (τ : UnaryType => …)` | capture (removed) | 5 |
| `ZetaUniformExtract.lean:66` `Finset.univ.filter (τ : UnaryType => …)` | capture (removed) | 5 |
| `nf_depth0_char_formula` (`Separation/KampTranslation.lean`) `Fintype.elems (sig.preds)` | rendering | UNSCOPED |

Plus the two implicit type-level dependencies that break at the flip regardless of `Finset.univ`:
`IntervalType := Finset (UnaryType)` (needs `DecidableEq (UnaryType)`) and `unaryToFormula`'s
whole-predicate fold.

## What the re-plan must decide (route: `/revise`, or `/research` first)

1. **Representation choice** for the per-formula `UnaryType`: `M`-parameter (arity change) vs `Σ M`-bundled
   (semantics change) vs a parallel-additive new type with a bridge. (The `Σ M`-bundled option notably
   keeps `IntervalType := Finset (UnaryType)` alive under the flip — `Finset (AtomKind (sigE) 1)` retains
   `DecidableEq` because `Formula`/`sig.preds` do — but still loses `Fintype (UnaryType)`, so `intervalTop`
   and the skeleton `Finset.univ` still need per-formula re-expression.)
2. **Bring the rendering layer into scope**: add `unaryToFormula`/`nf_depth0_char_formula`
   (`Separation/KampTranslation.lean`) as an explicit Phase-4 (or new foundational) file with a
   per-formula-`M` rendering re-encode and an `unaryToFormula_correct` re-proof.
3. **Staging that stays green**: the only genuinely green-incremental path is an ADDITIVE
   parallel-representation migration (introduce per-formula `UnaryType`/`IntervalType` + bridge, migrate
   the ~19 consumers one at a time behind the bridge — the "widen-last" pattern `IntervalType.lean`
   already used, scaled to the whole surface — then delete the total types LAST). Specify the bridge and
   the consumer migration order.
4. **Extend the gate before the full re-base**: a Phase-1-class gate on the RENDER step and
   `translateProp35_correct` under partial satisfaction (report 20 §3.3's flagged 4b risk, now shown to
   reach 4a's rendering path too).

## Discipline notes

- Per `plan-compliance.md`, choosing among the representation/staging options above is a substitution of
  a different decomposition than the plan specifies — a planning decision, not an implementation-time
  invention. Hence this escalation rather than a forced re-base.
- Prohibited (unchanged): no single atomic multi-file flip (crash-unsafe red window, explicitly rejected
  by the flip-last decision); no `sorry` / `def X := True` / full-alphabet `Finset.univ`; no weakening of
  any correctness statement to force a fit.
- The two closure-probe deletions and the flip-last sequencing decision from the prior run remain landed
  and correct; nothing here reverts them.
