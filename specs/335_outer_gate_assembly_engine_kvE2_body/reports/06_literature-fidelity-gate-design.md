# Report 06 — Literature-Fidelity Gate Design (kvE2_sepGate clause iv/v asymmetry)

- **Task**: 335 (outer_gate_assembly_engine_kvE2_body)
- **Session**: sess_1783723095_edd5a7_335 (blocker-research fork 3 — literature fidelity)
- **Date**: 2026-07-10
- **Type**: lean4 hard-mode research (H2/H3/H4/H5). RESEARCH ONLY — no .lean edits, no state changes.
- **Reference grounding tier**: **Tier 1 (literature-backed)** — Rabinovich 2014, *A Proof of
  Kamp's Theorem*, ground truth. Citations by **PDF page only** (per dispatch citation rule).
- **Ground-truth source**: `~/Projects/Literature/sources/rabinovich_2014/` (PDF pp.5–9 read
  directly this session).

## Executive verdict

**R1-faithful.** The zXW3-only inner-consistency clause (iv) is an **artifact** of the LEFT
construction landing first, not a faithful transcription of any left/right asymmetry in
Rabinovich. The paper's normal form is a single increasing anchor chain with a uniform
point-type/segment-type consistency requirement (Prop 3.5, p.5; Lemma 5.1 (5.1), p.7), and its
E[Σ] fold is an explicit **mirror pair** (Cor 5.4(1)/(2), p.9, "(2) is the mirror image of (1)").
Faithfulness therefore *requires* the mirror clause (v). R1 (add clause (v) = the zWT3 mirror of
clause (iv)) matches the paper exactly and simultaneously dissolves the task-344 `hInnerR`
blocker: with clause (v) in the gate, `hInnerR` becomes a **gate consequence**, not a free
(circular, LEFT-unsatisfiable) hypothesis.

**LEFT-unsatisfiability: CONFIRMED.** `hInnerR` as landed in `kvE2_outer_fold_frag`
(SharedWitness.lean:12520) and `kvE2_sepBody_kit_sound_frag` (:12476) is stated over **all**
sole-positive owners — guarded only by `kvE2_sepPos qnf = [σ0]`, **not** by `σ0` being
RIGHT-interior. For a LEFT sole-positive owner it forces `σ0.2` false on zones that a LEFT pin
genuinely realizes, so it is unsatisfiable for honest LEFT qnf and cannot be discharged publicly
by task 335. 344's fold needs repair regardless; R1 is that repair.

## Findings — 5-column lemma/source mapping (Tier 1)

| Source (Rabinovich 2014) | Prop/Location (PDF page) | Lean identifier | Type signature (verified) | Status |
|---|---|---|---|---|
| →∃∀ normal form: chain `z0=x0<x1<…<xn=z1`, point-types `α_j` at anchors, segment-types `β_j` on open `(x_{j-1},x_j)` | Prop 3.5 formula, **p.5**; Lemma 5.1 (5.1), **p.7** | `NormalForm sig k n`; `kvE2_sepInnerConsistentL/R` enumerate the 9 realizable trichotomy cells of a 4-anchor set | `def kvE2_sepInnerConsistentL (zs : ZoneSpec 4) : Prop` (SW:1220); `…R` (SW:11295) | LANDED |
| Uniform order-consistency of a point type (a zone must correspond to a genuine position in the linear anchor order) | Prop 3.5 chain constraint, **p.5** | `kvE2_sep_zone4_consistent` (L) / `kvE2_sep_zone4_consistentR` (R) | `(hz : zoneHolds M [x1,w,x,t] zs u) → kvE2_sepInnerConsistent{L,R} zs` (SW:6558 / SW:11309) | LANDED (both geometries) |
| **Mirror pair** of the E[Σ] navigated fold: 5.4(1) over `(z0,z)`, 5.4(2) over `(z,z1)` — same treatment reflected | Cor 5.4(1)/(2), **p.9** ("(2) is the mirror image of (1)") | gate clause (iv) [L] + proposed clause (v) [R] | `kvE2_sepGate` (SW:1238), clause iv at SW:1244–1246 | (iv) LANDED; **(v) MISSING — the defect** |
| Quantifier-free / monadic point & segment types (no richer static atoms) | Lemma 5.1 "α_i, β_i quantifier free", **p.7** | static `ZoneSpec`/`σ.2` bit vocabulary | — | Consistent with R1 (adds no content) |
| Honest realization ⇒ gate holds (well-formedness of a realizable qnf) | Prop 4.2 closure geometry, **p.6**; Cor 5.4, **p.9** | `kvE2_sepGate_holds_of_honest` | `(h : nf_eval_nf …) → kvE2_sepGate qnf` (SW:2666) | LANDED (sole gate constructor) |

### The geometric core (why iv/v is a symmetry, not an asymmetry)

Decoding `ZoneSpec 4` over env `[x1, w, x, t]` (pair `(before?, after?)`, `(F,F)`=at,
`(T,T)` forbidden), both `kvE2_sepInnerConsistentL` (SW:1220–1229) and
`kvE2_sepInnerConsistentR` (SW:11295–11304) are **the same object**: the 9 trichotomy cells
(4 points + 5 open gaps) of the ordered 4-anchor set. They differ **only** in where the pin
`x1` sits:

- **L** (`x < x1 < w < t`, owner class `kvE2_sep_zXW3`): cells `<x, =x, (x,x1), =x1, (x1,w), =w, (w,t), =t, >t`.
- **R** (`x < w < x1 < t`, owner class `kvE2_sep_zWT3`): cells `<x, =x, (x,w), =w, (w,x1), =x1, (x1,t), =t, >t`.

Patterns 1–3 and 7–9 coincide; the middle 3 (patterns 4/5/6 — the cells around the pin) swap.
This is exactly the merge-order asymmetry of *where the fresh witness falls*, i.e. Rabinovich's
chain position of `x1` — **not** a difference in the consistency *notion*. The notion ("the point
type is order-consistent with the anchor chain") is uniform across the paper. The
formalization hard-codes the enumeration for LEFT geometry in clause (iv) and omits the RIGHT
enumeration; that omission is the artifact.

## Per-question verdict table

| # | Question | Verdict | Evidence |
|---|----------|---------|----------|
| Q1 | Is the point-type consistency constraint symmetric across anchor geometry, or a genuine L/R asymmetry? Is clause (iv)'s zXW3-only form faithful or an artifact? | **SYMMETRIC; clause (iv) zXW3-only is an ARTIFACT** | Normal form is one increasing chain, uniform α/β consistency (Prop 3.5, p.5; Lemma 5.1, p.7). Fold is an explicit mirror pair (Cor 5.4(1)/(2), p.9). No paper object privileges LEFT. The L/R zone sets are the same 9 trichotomy cells, differing only by pin position. |
| Q2 | Faithful gate shape: (a) symmetric clauses both owners (=R1 clause v); (b) single geometry-neutral clause; (c) other? | **(a) = R1 is faithful & minimal; (b) is an extensionally-EQUIVALENT cleaner refactor; NOT (c)** | The gate already factors owners by `nf0_zoneSpec σ.1 ∈ {zXW3, zWT3}`. A geometry-neutral predicate would dispatch on that same test, unfolding to `(iv) ∧ (v)`. So (a) and (b) coincide extensionally; (a) has the smaller blast radius given `kvE2_sepInnerConsistentR`/`kvE2_sep_zone4_consistentR` are already landed. |
| Q3 | Is `hInnerR` (as landed in `kvE2_outer_fold_frag`, SW:12520) satisfiable for a LEFT sole-positive owner? | **UNSATISFIABLE for honest LEFT owners — CONFIRMED** | `hInnerR` is guarded only by `kvE2_sepPos qnf = [σ0]`, not by RIGHT-interior. It forces `σ0.2` false on all `¬consistentR` zones, which for a LEFT owner include the realizable middle cells `=x1 (zAtX1L)`, `(x1,w) (zUW)`, `=w (zAtWL)`. A non-vacuous LEFT qnf marks its own pin self-zone true → contradicts `hInnerR`. So 335 cannot discharge it; the fold is unconsumable for LEFT qnf as landed. |
| Q4 | Does R1 contradict the 330 faithfulness audit / F-invariants? | **NO** | 330's REDESIGN verdict is about carrier *arity* (navigated vs constant-arity static characteristic, Prop 3.5/Cor 5.4). Clause (v) adds no atoms, no joint content, no arity — it is a well-formedness restriction within the existing static bit vocabulary and the already-sanctioned single-positive fragment. 330 repeatedly treats "mirror" as a legitimate structural pattern. |

## Faithful gate shape — exact clause text

Add clause (v) to `kvE2_sepGate` (SharedWitness.lean:1238), the exact mirror of clause (iv):

```lean
def kvE2_sepGate {sig : MonadicSignature} (qnf : NormalForm sig 2 3) : Prop :=
  (∀ σ : NormalForm sig 1 4, nf0_dropFresh σ.1 ≠ qnf.1 → qnf.2 σ = false) ∧          -- (i)
  (∀ σ : NormalForm sig 1 4, ¬ kvE2_sepOuterConsistent (nf0_zoneSpec σ.1) →
    qnf.2 σ = false) ∧                                                                -- (ii)
  (∀ σ : NormalForm sig 1 4, qnf.2 σ = true →
    ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧               -- (iii)
  (∀ σ : NormalForm sig 1 4, qnf.2 σ = true → nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →     -- (iv) LEFT
    ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), ¬ kvE2_sepInnerConsistentL zs →
      σ.2 (nf0_assemble zs χ σ.1) = false) ∧
  (∀ σ : NormalForm sig 1 4, qnf.2 σ = true → nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →     -- (v) RIGHT  ★NEW
    ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), ¬ kvE2_sepInnerConsistentR zs →
      σ.2 (nf0_assemble zs χ σ.1) = false)
```

**Discharge of clause (v) in `kvE2_sepGate_holds_of_honest` (SW:2666)** is the byte-mirror of
clause (iv)'s discharge (SW:2706–2726): extract `x1` with `x < w < x1 < t` from the RIGHT-owner
`hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3`, read the RIGHT order bits, then close a marked bit's
`¬consistentR` case by contradiction using the landed `kvE2_sep_zone4_consistentR` (SW:11309) —
exactly as (iv) uses `kvE_subBracket2V_gate_holds_of_honest`/the L classifier. A RIGHT-geometry
per-σ honest bundle (`kvE2_sepHonestBundleR`, the mirror of `kvE2_sepHonestBundleL` at SW:2739)
may be the cleanest closer; implementer's choice — both are landed-lemma-backed.

## R1-as-proposed: matches, no adjustment needed

The dispatch's R1 ("add clause (v) = the zWT3 mirror of clause (iv), provable by the landed
`kvE2_sep_zone4_consistentR`") is **exactly** the faithful shape. One refinement to record (not
an adjustment to R1's statement): clause (v) makes `hInnerR` **derivable from the gate**, so the
344 fold chain should have `hInnerR` **removed** (not merely guarded), deriving it internally
from `hg : kvE2_sepGate qnf`. The `_fragR` producer already does `by_cases hg` (SW:11558), so the
RIGHT branch gains clause (v) with no new hypothesis.

## Impact list — which landed 344 lemmas change and how

| Lemma (SharedWitness.lean) | Change under R1 | Nature |
|---|---|---|
| `kvE2_sepGate` (SW:1238) | +1 conjunct (clause v) | Definition edit — the pivot |
| `kvE2_sepGate_holds_of_honest` (SW:2666) | +1 `refine` goal, closed by RIGHT mirror of SW:2706–2726 via `kvE2_sep_zone4_consistentR` | Sole constructor gains obligation (contained) |
| `kvE2_sepGateAtPin_fragR` (SW:11525) | **drop** `hInnerR` param (SW:11544); derive it from `hg` (clause v) inside the existing `by_cases hg` | Signature simplification |
| `kvE2_sepBody_kit_sound_frag` (SW:12459) | **drop** `hInnerR` param (SW:12476); RIGHT branch (SW:12494–12495) no longer threads it | Signature simplification |
| `kvE2_outer_fold_frag` (SW:12502) | **drop** `hInnerR` param (SW:12520); it becomes a gate consequence | Signature simplification — unblocks 335 |
| All gate CONSUMERS (`hg : kvE2_sepGate qnf` at SW:5901,6362,6669,6680,8435,9647,10402,11558) | clause (v) available as extra hypothesis; **no obligation** | Additive/inert |
| Decision sites (SW:2332 `dite`, SW:2361 `¬gate`) | branch on slightly-stronger predicate; vacuous/false branches unaffected | Inert |
| No non-`SharedWitness.lean` consumer of the `_frag` chain exists yet | 335 is the pending first consumer; it benefits (no `hInnerR` to discharge) | — |

**Net**: R1 is additive to the gate DEFINITION (one mirror conjunct), one contained new
obligation in the single honest constructor, and a *simplification* (hypothesis removal) of the
three landed 344 `_frag` lemmas. It is NOT a churn of existing proofs — consumers are inert.

## Recommended execution shape (spawn task)

**Spawn a SharedWitness-territory task** (additive/edit to the gate def + one constructor +
three `_frag` signatures). Title: *"Symmetrize kvE2_sepGate with RIGHT inner-consistency clause
(v); dissolve hInnerR in the 344 _frag fold"*. 335 keeps OuterGate.lean; 341's GATE-phase re-diff
absorbs the SharedWitness change.

- **Phase 1** — Add clause (v) to `kvE2_sepGate` (SW:1238); discharge it in
  `kvE2_sepGate_holds_of_honest` (SW:2666) via the RIGHT mirror of SW:2706–2726 +
  `kvE2_sep_zone4_consistentR`. Add `kvE2_sepHonestBundleR` if the closer needs it. `lake build`
  the module; axiom-clean {propext, Classical.choice, Quot.sound}. (~150–300 lines.)
- **Phase 2** — Remove `hInnerR` from `kvE2_sepGateAtPin_fragR` (SW:11525), deriving the
  bit→consistentR direction from `hg` (clause v) at the existing `by_cases hg` (SW:11558). Rebuild.
  (~100–200 lines.)
- **Phase 3** — Thread the removal through `kvE2_sepBody_kit_sound_frag` (SW:12459) and
  `kvE2_outer_fold_frag` (SW:12502): drop the `hInnerR` params (SW:12476, :12520) and the
  RIGHT-branch pass-through (SW:12495). Rebuild; confirm `kvE2_outer_fold_frag` now takes only
  `hfrag`/`hcorrK`/`hexcl`. (~80–150 lines.)
- **Phase 4** — Handoff to 335: `kvE2_outer_fold_frag` is consumable with `hcorrK`
  (ExistProviders.correct, already 335's step) and `hexcl` (335's Phase-C GO/NO-GO probe,
  unchanged). No `hInnerR` obligation remains.
- Constraints: no sorries on live paths; H7 territory SharedWitness.lean; 341 unaffected
  (its GATE-phase re-diff already re-scans SharedWitness before code moves).

## Adversarial Self-Verification (H4)

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| L and R inner-consistency sets are the 9 trichotomy cells, differing only in pin position | SW:1220–1229 vs 11295–11304 decoded against env `[x1,w,x,t]` under each order | Direct read of both defs + `ZoneSpec` decode | High |
| Clause (iv) is zXW3-only; no zWT3 mirror exists | SW:1244–1246 is the last conjunct of `kvE2_sepGate` (SW:1238); no clause keys on zWT3 | `grep` all `kvE2_sepGate` refs + full def read | High |
| Paper's normal form is a single uniform increasing chain (no L/R distinction in consistency) | Prop 3.5 formula, p.5; Lemma 5.1 (5.1), p.7 | PDF pp.5,7 read directly | High |
| Paper's E[Σ] fold is an explicit mirror pair | Cor 5.4(1)/(2), p.9: "(2) is the mirror image of (1) and is proved similarly" | PDF p.9 read directly | High |
| `hInnerR` guarded only by single-positive, not RIGHT-interior | SW:12520 (and :12476): `∀ σ0, kvE2_sepPos qnf = [σ0] → …¬consistentR…` | Direct read of both `_frag` signatures | High |
| `hInnerR` unsatisfiable for honest LEFT owner | Forces `σ0.2` false on consistentL\consistentR = {=x1, (x1,w), =w}; honest LEFT qnf marks its own pin self-zone true | Set-difference of the two 9-elt enumerations + fold-body branch read (SW:12490–12495) | High |
| Blast radius contained: sole gate constructor is `kvE2_sepGate_holds_of_honest` | Only `: kvE2_sepGate qnf := by` producer is SW:2672; all others are `hg :` consumers | `grep` for constructor pattern across file | High |
| Clause (v) discharges by the mirror of (iv), via landed `kvE2_sep_zone4_consistentR` | (iv) discharge at SW:2706–2726 uses L extraction + per-σ gate lemma; R analog is `kvE2_sep_zone4_consistentR` (SW:11309) | Read of (iv) discharge + R classifier signature | Medium (exact closer is implementer's choice; classifier is landed) |
| R1 does not contradict 330 audit | 330 REDESIGN is about carrier arity (navigated characteristic), not gate well-formedness clauses | Read 330 audit verdict + F-invariant grep | High |

**Contradiction log**: none. The one Medium-confidence item (exact honest closer for clause v)
is a proof-engineering choice, not a fidelity risk — the RIGHT classifier it relies on
(`kvE2_sep_zone4_consistentR`) is already landed and machine-checked.

**Recommendations modified after verification**: initial instinct was that clause (v) might be a
larger blast radius (touching many gate consumers). Verification showed consumers are inert
(they receive the clause as an extra hypothesis); only the single honest constructor gains an
obligation, and the three `_frag` lemmas are *simplified* (hypothesis removal). R1 is lower-risk
than first assumed.

## Zero-debt note

No sorry-deferral or axiom introduction is recommended. All discharge channels are landed public
lemmas (`kvE2_sep_zone4_consistentR`, the `_holds_of_honest` mirror, existing `by_cases hg`
sites). If the RIGHT honest closer proves harder than the L mirror suggests, the correct action
is a dedicated GO/NO-GO probe on the clause-(v) discharge in Phase 1 — not a placeholder.
