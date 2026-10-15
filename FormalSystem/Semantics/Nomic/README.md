# Nomic — nomic frames, law-histories, and the nomic hierarchy

The frame-level half of the paper's nomic appendix. A **nomic frame** (`def:nomic-frame`) keeps
one carrier `W` and replaces the single task relation by a relativized family `⇒ʷ`, one task
relation per world state, each satisfying `def:frame`; the `w`-th member `F^w = (W, D, ⇒ʷ)` is an
ordinary task frame, its possible worlds are the **law-histories** `H_F^w`, and `H_F` is their
union over `w`.

The nomic *operator* and its logic are not here — see "Siting, and its cost" below.

## Modules

| File | Description |
|------|-------------|
| `Frame.lean` | `def:nomic-frame`: the structure, the derived family `NomicFrame.at` (declared dotted outside the namespace, since `at` is a reserved token), the regularity class `NomicFrame.IsRegular` and the `instAtIsRegular` instance that feeds it back to `FrameOver.IsRegular`, the relativized `TaskRel`, `lawHist`/`HF` with the `WorldHistory` bridge `mem_lawHist_iff`, `def:nomic-properties`' three properties (*Lawful*, *Static*, *Uniform*), the two implications from *Uniform*, and `lem:nomic-occurrence` |
| `Recovery.lean` | The two-point partial history `{⟨0,p⟩,⟨d,q⟩}` as a **general lemma over `TaskFrame`** (`PartialHistory.exists_worldHistory_two_point`), `lem:nomic-recovery` — `H_F^w = H_F^u` iff `⇒ʷ = ⇒ᵘ` — over the one-directional helper the biconditional applies twice, and `static_iff_taskRel_eq`, the primitive-level form of *Static* |
| `ZTime.lean` | `def:nomic-witnesses`: the ℤ-time presentation `ofStepFamily`, whose `w`-th member is `FrameOver.ofStep (R w)` **by `rfl`**, the two `lawHist`-over-ℤ membership bridges, law-history monotonicity in the one-step relation, and the two step-path invariants (two-sided and forward-only) |
| `Witnesses.lean` | `prop:nomic-hierarchy`: three finite ℤ-time witnesses — *Static* not *Lawful*, *Lawful* not *Static*, *Static* and *Lawful* not *Uniform* — with their per-witness independence theorems, and the bundled `nomic_hierarchy` |

## Paper anchors ported

| Anchor | Where |
|--------|-------|
| `def:nomic-frame` | `NomicFrame`, `NomicFrame.at`, `NomicFrame.IsRegular`, `lawHist`, `HF` (`Frame.lean`) |
| `def:nomic-properties` | `Lawful`, `Static`, `Uniform`, `static_of_uniform`, `lawful_of_uniform` (`Frame.lean`) |
| `lem:nomic-occurrence` | `NomicFrame.occurrence` (`Frame.lean`) |
| `lem:nomic-recovery` | `lawHist_eq_iff_taskRel_eq`, over `taskRel_imp_of_lawHist_eq` (`Recovery.lean`) |
| `def:nomic-witnesses` | `ofStepFamily`, `ofStepFamily_at`, `ofStepFamily_isRegular` (`ZTime.lean`) |
| `prop:nomic-hierarchy` | `nomic_hierarchy` and the `NomicHierarchy` witnesses (`Witnesses.lean`) |

`thm:nomic-primitive` is **cut material**, not a live anchor: clause (1) is `static_iff_taskRel_eq`
and is cited by file and header (`appendix_cut_material.tex`, "Primitive-level characterization of
the nomic frames"). Clauses (2)-(4) are not ported; (2) needs a three-point partial history whose
well-definedness argument has no precedent in this tree, and the cut note itself records (3) and
(4) as having no consumer.

## Siting, and its cost

This cluster sits under `Semantics/`, not under `OpenLanguage/`. A nomic frame mentions no object
language, no formula and no model, and every tool it consumes (`FrameOver`, `PartialHistory`,
`Extension`, `IntNormalForm`) lives under `Semantics/`. `OpenLanguage/` imports `Semantics/`,
never the reverse, so the nomic operator can live in `OpenLanguage/` and import these frames;
siting the frames under `OpenLanguage/` would invert that dependency and put `def:nomic-frame` in
a directory whose other modules are all about formulas.

**The cost, stated plainly**: the operator will then live in a different directory from its
frames, so it carries one extra import and the two halves of the nomic appendix are not
co-located. The alternative buys that co-location at the price of the dependency inversion and of
making the frames unreachable for a purely semantic consumer that does not want `OpenLanguage`'s
imports. The import direction is the deciding argument.

## Choice dependence, measured rather than assumed

Every axiom set below was read off with `#print axioms`, not inferred from the proof text.

| Declaration | Axioms |
|-------------|--------|
| `mem_lawHist_iff`, `static_of_uniform`, `lawful_of_uniform` | `[propext]` |
| `stepPath_invariant` | `[propext, Quot.sound]` |
| `occurrence`, `exists_worldHistory_two_point`, `lawHist_eq_iff_taskRel_eq`, `static_iff_taskRel_eq` | `[propext, Classical.choice, Quot.sound]` |
| `stepPath_forward_invariant`, the three `ofStepFamily` lemmas, `nomic_hierarchy` and every witness theorem | `[propext, Classical.choice, Quot.sound]` |

Two distinct sources of choice, worth separating. The recovery results and
`lem:nomic-occurrence` are theorems of **ZFC** through `thm:extension`'s Zorn appeal. The ℤ-time
witnesses are choice-bearing for an unrelated reason: each member frame's *Saturation* comes from
`TaskFrame.saturation_of_finite`, and `stepPath_forward_invariant` additionally inherits choice
from Mathlib's `Int.leInduction`, which — unlike `Int.induction_on` — is choice-dependent on this
pin. `rmk:choice` lists the paper's choice-free results and no nomic result is among them;
nothing in this directory advertises one as choice-free.

## Known gaps

- The two-point history belongs beside `PartialHistory.point`/`occurrence` in
  `Semantics/Extension/Extension.lean` and is declared in `namespace PartialHistory` so that
  promoting it there is a pure file move. `Semantics/DeterministicBridge.lean` carries the same
  construction inline and can be rewritten as one call to it. Neither move is done here.
- The paper's `% PORT:` markers under `lem:nomic-occurrence` and `lem:nomic-recovery` are not
  cleared: `possible_worlds.tex` is read-only input from another repository. The declarations are
  named so that a later `\leanproof{\texttt{NomicFrame.…}}` needs no rename.

## Dependencies

- **Imports from**: `FormalSystem.Semantics.Extension` (hence `TaskFrame`, `PartialHistory`) and
  `FormalSystem.Semantics.IntNormalForm`
- **Imported by**: `FormalSystem.Semantics.Nomic` (the sibling aggregator), hence
  `FormalSystem.Semantics`

## Related Documentation

- [Semantics README](../README.md)
- [FormalSystem README](../../README.md)

---

**Last verified**: 2026-10-14
