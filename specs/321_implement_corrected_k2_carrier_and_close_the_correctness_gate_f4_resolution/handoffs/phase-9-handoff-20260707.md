# Phase 9 Handoff — Carrier-Side Per-σ `hgate` Derivation (O4, MAKE-OR-BREAK)

- **Session**: sess_1783487859_3f6358
- **Date**: 2026-07-07
- **Status**: Phase 9 COMPLETED — **O4 VERDICT: FAIL** (honest, evidenced; a documented FAIL
  is the phase's sanctioned outcome). Commits: 7488001ec (derivable core), e79da7f94
  (crux capture + record).

## Immediate Next Action (Phase 10 = DECISION GATE)

Render the FULL/N1/N2 verdict from the plan's routing table with the Phase 8 PASS + Phase 9
FAIL inputs. The plan's own table prescribes: **FAIL on O4 → N2** (single-positive-sub
fragment, ~200-350 lines): amend the plan to promote Appendix N2's phase sequence
(N2-A/N2-B/N2-C) as replacement content for Phases 11-12, re-run `generate-todo.sh` after
the state edit, and proceed. Write the dated verdict record under the Phase 10 heading
citing commits 2c55cf3f1/8c22e01c5 (Phase 8), 7488001ec/e79da7f94 (Phase 9), and the
captured failing goal (below / `SharedWitness.lean` O4 CRUX RECORD).

## What Phase 10 needs — the FAIL evidence, in one place

**Captured crux goal** (`lean_goal`-verbatim; hypothesis set was the FULL superset — the
realized joint disjunct `h` itself + `hL`/`hR` arrangement memberships + gate `hg` + every
Phase-8-extractable fact `hepL`/`hepR`/`hptW`/`hptX1`/`hbundleL` — so the failure is not
attributable to a dropped input). With σ, τ distinct left-interior positives
(`hστ : σ ≠ τ`), `hτbit : kvE2_sepBits τ kvE_sub2_zXU χ = true`, τ's χ-slot interleaved
below σ's fresh slot (its witness `v` has `x < v < x1` and
`hχv : nf_eval_nf M 0 1 (fun _ => v) χ`):

    ⊢ σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true

**Five failed closers** (full diagnostics in the O4 CRUX RECORD, `SharedWitness.lean` end):
1. `exact hτbit` → type mismatch (τ's bit ≠ σ's bit — no cross-σ channel).
2. `simp_all [kvE2_sepBits, kvE2_sepGate, kvE2_sepInnerConsistentL]` → gate fully unfolded;
   all four clauses conclude `= false`; goal unsolved (polarity exhaustion, machine-visible).
3. `exact hg.2.2.2 σ hσ hσzone kvE_sub2_zXU χ (by simp …)` → sub-goal false (`kvE_sub2_zXU`
   IS consistent zone #3) and wrong conclusion polarity.
4. `exact kvE2_sepSegForm_excludes … v …` → residual goals unprovable: `v` is a bracket
   POINT (segments realized only on OPEN intervals) and the channel consumes bit-FALSE.
5. `aesop` → exhaustive search failure.

**Channel exhaustion**: the carrier's only model-fact→fold-bit channels are (a) segment
contrapositive (open intervals only), (b) `kvE2_sepLit` biconditional literals (six
at/exterior zones only — never `zXU`/`zUW`/`zWT`), (c) σ's OWN slot enumeration. τ's slot
point in σ's open region has none. The plan's FAIL criterion verbatim: "a per-σ zone bit
required by `hgate` underdetermined by the refined-conjunction segments + E[Σ]-atom
literals".

**No additive repair** (probed at bit level; record has details): conjunctive cross-σ gate
clause is not honest-derivable (breaks `kvE2_sepGate_holds_of_honest` + non-vacuity,
FM-vac); disjunctive clause is arrangement-blind; the faithful repair is bit-compatibility
FILTERING of `kvE2_sepArrL/R` — a Phase-7 carrier re-definition (kills the canonical-list
non-vacuity proof), outside additive scope, owned by the decision gate. Second independent
obstruction to the ∀-anchor form: conjunct `a < w` unprovable (right-region segments
exclude only depth-0 `charBase` 1-types, never the `charK` E[Σ]-atom; a right-interior τ
with equal `nfk_projFresh` even realizes it above `w`).

**Why N2 dissolves the crux** (supports the plan's FAIL→N2 routing): with ONE interior
positive there are no cross-σ slots — every left-list witness is σ's own bit-true 1-type
(bit true by `kvE2_sepS` construction) or the literal-covered self-zones — exactly the
configuration `kvE_subBracket2V_sound_of_outer` (`SubBracket2V.lean:1216`) +
`kvE_sub2V_bounded_anchor_of_outer` (`:1182`) already serve.

## Landed API (Phase 9, all public, sorry-free, axiom-clean)

| Object | Role |
|--------|------|
| `kvE2_sep_zone4_consistent` | PUBLIC N-point analog of the private `kvE_sub2V_zone_consistent` template: any zone realized over `[x1,w,x,t]` with `x<x1<w<t` is in `kvE2_sepInnerConsistentL` (nine zones). Discharges the inconsistent-zone cases of `hgate`-forward. |
| `kvE2_sepHgate_offFiber` | `hgate` off-fiber conjunct (`SubBracket2V.lean:1872`) read off gate clause (iii) — model-independent, per positive σ. |
| `kvE2_sepHgate_innerNine` | Gate clause (iv) surfaced: inner nine-zone falsity for left-interior positives. |
| `kvE2_sepSegForm_excludes` | The segment channel: realized `kvE2_sepSegForm` + bit-false → ¬`charBase χ` at the point (Cor 5.4). The `hgate`-forward contrapositive restricted to segment-covered points. |
| O4 CRUX RECORD (doc block, file end) | The inert FAIL record: captured goal, five failed closers, channel exhaustion, no-additive-repair analysis, N2 consequence. |

These remain LIVE inputs to N2 (per-σ gate work against σ's own segments).

## Current State

- `SharedWitness.lean`: 1,614 lines (+~220 Phase 9, append-only). `git diff` for Phase 9
  touches ONLY this file + the plan. Full `lake build` green (1720 jobs).
- Sorry census: 0 in SharedWitness.lean (script-verified). Litmus grep: 0 live hits (all
  matches are doc-comment quotations of the rule). No vacuous defs introduced (the single
  repo hit is pre-existing `Examples/TemporalStructures.lean:269`, untouched). Axiom
  baseline unchanged (2 pre-existing Boneyard comment-line matches only).
- Axiom check: `kvE2_sep_zone4_consistent` and `kvE2_sepSegForm_excludes` exactly
  `[propext, Classical.choice, Quot.sound]`; the two gate wrappers `[propext, Quot.sound]`.
- Note: a concurrent session committed task-332 work (c4acffff1) between the two Phase 9
  commits; staging here was targeted and unaffected.

## Key Decisions (this phase)

1. **Probe with a full hypothesis superset**: the crux was stated with the realized
   disjunct `h` itself PLUS all extracted facts, so the FAIL cannot be attributed to a
   dropped input (adversarial-robustness of the record).
2. **Instance-form relaxation also probed**: the crux was taken at the extracted anchor
   (where conjuncts 1-2 hold from extraction) — it dies on the same forward-zone residue;
   the ∀-anchor form (`:1868` spec) additionally dies on `a < w`. FAIL either way.
3. **No gate extension attempted as a patch**: the sanctioned additive gate extension was
   analyzed (conjunctive/disjunctive forms) and shown either unsound-for-honesty or
   insufficient — recorded, not coded, per the one-dispatch cap and FM-vac.
4. **Probe removed before commit**: only the inert record + sorry-free positive lemmas are
   committed (crux house style, mirroring `NavigatedSpine.lean:395-449`).

## Sorry Inventory

Empty. No sorries introduced (probe deleted before commit); none inherited (Phase 8
inventory was empty). Pre-existing task-external sorries unchanged (`Kamp/Boneyard/*` (2),
`Kamp/EANegation.lean:1090/:1249` DO-NOT-EDIT F-record, `Kamp/KampPrior.lean:351/:354`
strategic hook — all off the task live path).
