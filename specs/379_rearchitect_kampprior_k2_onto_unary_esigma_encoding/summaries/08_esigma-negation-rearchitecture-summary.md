# Phase 0 Summary — ζ/ε spine-rewire seam de-risking spike (viability gate)

- **Task**: 379 — rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Phase**: 0 of 8 (Wave 1). Single-phase dispatch.
- **Verdict**: **GO** (both seams viable, sorry-free).

## What was delivered

A scratch/off-path Lean probe at `reports/08_zeta-epsilon-seam-probe.lean` (NOT under `Theories/`;
compiled with `lake env lean`, EXIT 0). Five theorems, all sorry-free — each `#print axioms` lists
only `[propext, Classical.choice, Quot.sound]` (no `sorryAx`):

| Theorem | Seam | Content |
|---|---|---|
| `hcapture_dischargeable_minimal` | (b) | For any injective naming `Aσ` of sub-normal-forms by formulas, the canonical anchored-existential `sat` discharges `esigma_descent`'s `hcapture` premise, minimal case `k=0, n=1, anchor=0`. |
| `esigma_descent_composes_minimal` | (b) | The discharged `hcapture` feeds the LANDED `esigma_descent` verbatim, yielding the arity-preserving depth-1 descent (folded existential read off a fresh unary atom; no arity-`(n+1)` joint environment). |
| `seam_a_characteristic_records` | (a) | The MonadicFormula's semantic content lands in a `NormalForm` object — the characteristic NF of `(M,env)` is always satisfied. |
| `seam_a_bridge_atom` | (a) | Single-atom `MonadicFormula` truth transports across any two structures agreeing on the depth-0 characteristic `NormalForm` (via `doets_lemma_1_1`). |
| `seam_a_bridge_lt` | (a) | Same bridge on a `.lt` order literal — not atom-specific. |

## Findings (recorded for Phases 1 and 7)

- **Seam (b) — `hcapture` discharge: DISCHARGEABLE.** The Def 4.1 (Rabinovich PDF p.5) / p.6-collapse
  mechanism — the fresh unary E[Σ] atom's truth set is exactly the anchored existential — discharges
  sorry-free and drives the real `esigma_descent`. No new mathematics; no arity growth.
- **Seam (a) — object-language bridge: VIABLE, SEMANTIC direction only.** There is **no** syntactic
  `NormalForm → MonadicFormula` translation in the codebase and none is needed. The viable bridge is
  `MonadicFormula → characteristic NormalForm → truth-determined`, via `nf_characteristic` /
  `nf_characteristic_satisfies` + `doets_lemma_1_1` (depth-bounded EF-invariance) — exactly the
  interface `kamp_prior_expressive_completeness` / `nf_characterizable_temporal_prior` already
  consume. Phases 1/7 must wire the rewire through this semantic bridge.

## Verification

- `lake env lean reports/08_zeta-epsilon-seam-probe.lean` → EXIT 0.
- All five theorems sorry-free (axiom sets checked).
- No `Theories/` edits — the live `lake build` and `#print axioms completeness_discrete` are
  untouched (the pre-existing `KampPrior.lean` `nf_nvar_exist_all_depths | _k+2` sorry and the two
  off-path `EANegation.lean` sorries are unchanged; none were introduced or modified here).
- No `sorry`, vacuous definition, or new axiom introduced.
- Faithfulness: Rabinovich cited by PDF page only (Def 3.1 p.4, Lemma 3.2 p.4, Def 4.1 p.5 + p.6
  collapse, Prop 4.3 / Thm 4.4 p.6); the corrupt `.md` was not used.

## Next action

Wave 2 is authorized: Phase 1 (ε) and Phase 2 (α) in parallel, both off the live import path. The
large `conjInterleave` combinatorial build is now de-risked to proceed — the ζ/ε crux interface is
not a wall.
