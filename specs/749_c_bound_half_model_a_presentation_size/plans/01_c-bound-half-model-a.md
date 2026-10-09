# Implementation Plan: Task #749

- **Task**: 749 - (C)'s bound half on model A: presentation size
- **Status**: [NOT STARTED]
- **Effort**: 14.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/749_c_bound_half_model_a_presentation_size/reports/01_c-bound-half-model-a.md
- **Artifacts**: plans/01_c-bound-half-model-a.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land (C)'s bound half on fixture model A as a COUNT: exhibit the presentation size `L` of
`Probe745.hitPresented_modelA` as `Nat.card (KType (clSig Fp) k)`, replacing the
`Set.Finite.bddAbove` witness. Three mathematical layers, in dependency order: (i) pigeonhole
eventual periodicity of the `k`-type of a constant block `ℓ^m`, with the threshold bounded by the
type count (`Compose.lean`); (ii) a transport layer (`Transport.lean`, new): the keystone "a
segment whose `k`-type is that of a nonempty constant block is itself a nonempty constant block"
and the cut surgery "deleting `p` positions from a long constant run lying inside one segment of
a `SegmentFactorization` preserves the family triple"; (iii) on model A, every factorization of a
`jump` trace holds the whole constant run inside its middle segment, so the surgery applies with
no re-cutting, every realized offset reduces below `m₀ + p ≤ Nat.card`, and `L` is explicit. The
closing phases update pins, the C14 baseline pair, `docs/theorem-index.md`, and every sentence in
the tree that still says the bound is unexhibited.

Every count in this record is described as a count and nothing else (Non-negotiable (1) below);
`k` stays free; no `Decidable (PlusValidZTime φ)`, no complexity bound, no `sorry`, no axiom.

### Research Integration

The report (`reports/01_c-bound-half-model-a.md`) settles four things this plan builds on, each
re-derived at plan-authoring time against the tree (import lines, declaration anchors, pin
section, heredoc anchors, probe line ranges):

- **F1 — landing site.** `listSeg` lives in `Decidability/RaySummary/Compose.lean`, which imports
  `SeamMulti → Seam → WeakCanonical.KTypeSummary` (the root that imports `Saturation.lean`).
  Phase 1 therefore lands in `Compose.lean` (namespace `FormalSystem.Metalogic.WeakCanonical`,
  which is `Compose.lean:77`'s own), never in `Saturation.lean`. `Compose.lean:271-275`'s
  docstring contains no "idempotence" wording; the only two sites are `RaySummary/README.md:291`
  and the probe's `:97`.
- **F2 — the binder.** `[Fintype sig.preds] [DecidableEq sig.preds]` together yield
  `Fintype (KType sig k)` by instance search, so the strengthened theorem can use
  `Fintype.exists_ne_map_eq_of_card_lt` directly and the binder is genuinely consumed: no
  `unusedArguments` finding, no `scripts/nolints.json` entry (`LEAN_STYLE_GUIDE.md:832` forbids
  one), no `set_option`. The recorded signature is kept verbatim.
- **F5/F6 — phase 2's decomposition.** Keystone (compiled in scratch, ~58 lines, via
  `k_equiv_monotone` + `k_equiv_preserves_sentence` with two depth-1 sentences) + general shrink
  surgery + model-A containment. The dispatch's case split (run met by several short segments)
  does not arise on model A at `k ≥ 1`: the keystone forces every negative segment to be a
  nonempty pure-`ℓ₀` block and every positive one a nonempty pure-`ℓ₁` block, so `t ∈ [W 0, W 1)`
  and the whole run `[t+1, t+1+n)` sits in the middle segment.
- **F7/F8 — phase 3's `L` and the stale-prose inventory.** `L := Nat.card (KType (clSig Fp) k)`
  (any `L ≥ m₀ + p - 1` works); the list of every sentence that becomes false is carried into
  Phases 7 and 8 as a checklist. `file_scope` in `specs/state.json` already carries the report's
  proposed additions (`Trace.lean`, `Transport.lean`, `RaySummary.lean`,
  `check-evidence-probes.sh`, `w-soundness-shape-refuted.lean`), verified by `jq` at planning.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided to this dispatch; `specs/ROADMAP.md:84-85` carries an entry for
this record (already saying "pigeonhole plus `kTypeOf_listSeg_append_congr`"). This plan does
not edit `ROADMAP.md`.

## Goals & Non-Goals

**Goals**:
- `kTypeOf_listSeg_replicate_eventually_periodic_bounded` (strengthened, `m₀ + p ≤ Nat.card (KType sig k)`) and `kTypeOf_listSeg_replicate_eventually_periodic` (verbatim `README.md:285-290`) in `Compose.lean`, pinned at `[propext, Classical.choice, Quot.sound]`, in the C14 baseline pair, with one `theorem-index.md` row cross-referencing `anchorCells_ncard_le`.
- `Transport.lean` (new, registered in `RaySummary.lean`): keystone `segZ_const_of_kTypeOf_eq_replicate`, deletion colouring `deleteRun`, its `labels`/`kTypeOf` lemmas, and the shrink surgery `inFamily_of_shrink_run` with its `familyTriples` corollary — all general over `sig`, every `k`-dependent statement carrying `(hk : 1 ≤ k)` where the keystone is used.
- In the probe: `run_subset_middle`, `deleteRun_clTrace_jump`, `familyTriples_jump_shrink`; `hitCl_eq_truncated` and `hitPresented_modelA` restated with the explicit `L = Nat.card (KType (clSig Fp) k)` and no `∃ L`; the "does NOT say" block and header rewritten in the same change.
- Every "no computable bound / never exhibited / non-constructive / finite-semigroup idempotence" sentence in the tree revised (inventory in Phases 2, 7, 8); the count disclaimer from `AnchorLayer.lean:317-320` quoted verbatim at every count site.
- Sorry-free, axiom-free, `k` free, gates green: `lake build`, `bash scripts/check-module-invariants.sh`, `bash scripts/check-evidence-probes.sh`, `bash scripts/readme-lint.sh`, `bash .claude/scripts/verify-deploy.sh`.

**Non-Goals**:
- The general every-model bound (the (W) run-layer record's completeness half).
- The unconditioned general transport lemma `InFamily c ↔ InFamily c'` for a maximal run met by several segments (honest general threshold `3·(m₀ + p)`, report F6); only the shrink direction under an explicit single-segment containment hypothesis is landed. The `→`-lengthen direction is not landed and no prose claims `↔`.
- Any `Decidable (PlusValidZTime φ)`, any complexity bound (upper or lower), any choice of `k`, any claim derived from the size of `NormalForm (clSig φ) k 0`.
- Editing `specs/ROADMAP.md`, `specs/archive/**`, or `scripts/nolints.json`.
- A computable (`#eval`-able) `L`: `Nat.card` is a well-formed `ℕ` term in a `Prop`; the probe's `#guard`s keep their `L = 2` literals.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Surgery's `cover`/`mono` arithmetic over `Monotone W` with empty segments allowed (Phase 5) | H | M | Three-range case split on `t < s` / `t ≥ s` with `F.cover t` or `F.cover (t + p)`; instantiate `F.mono` at the two relevant pairs and close by `omega`; `exists_zFactorization`'s own `cover` proof (`Family.lean:104`) is the in-tree template |
| `labels` equalities under translation / for the modified segment (Phase 4) | H | M | `labels_concat` (`HitOf.lean:396`) is the exact pattern: `List.ext_getElem` + `labels_getElem` + `decide_eq_true_iff`; `Classical.decPred` supplies the `DecidablePred` instance for `Prop`-valued colourings |
| The `strict_pos`/`strict_neg` cases `z₀ ∈ {1, -2}` need `p < j` strictly | M | H | Carry `hpj : p < j` as an explicit hypothesis of the surgery; in Phase 7 the reduction step only fires for `n > Nat.card ≥ m₀ + p`, where `n - p ≥ 1` |
| C14 baseline pair drifts (`C14BASE` vs `C14LEAN` order) | M | L | Append identical lists to both heredocs in one edit (Phases 2 and 8); run `bash scripts/check-module-invariants.sh` without `--no-build` |
| Stale "unexhibited"/"no computable bound" prose survives outside the probe | M | M | Phase 8 carries the full F8 inventory as a checklist and ends with the grep sweep in its verification |
| Probe grows past ~1700 lines | L | M | `lake env lean` applies no `longFile` limit; general lemmas live in `Transport.lean`, only model-A facts in the probe |
| `Nat.card` vs `Fintype.card` instance mismatch for `KType (clSig Fp) k` | L | L | `Fintype (clSig Fp).preds` / `DecidableEq` instances at `Closure.lean:83-88` give `Fintype (KType (clSig Fp) k)`; `Nat.card_eq_fintype_card` bridges |
| A full `lake build` after `Compose.lean` changes rebuilds every downstream module | M | H | Run builds detached and guarded per `.claude/rules/lean4.md`; build per-module during phases, the whole library once in Phase 8 |
| Removing `set_option linter.unusedVariables false in` at the probe's `hitCl_eq_truncated` (Phase 7) | L | L | `hk` becomes genuinely used (the keystone needs it); delete the suppression and its reason paragraph together |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 3, 5 |
| 6 | 7 | 6 |
| 7 | 8 | 2, 7 |

Phases within the same wave can execute in parallel. Phases 2 and 3 both edit
`RaySummary/README.md` (different rows of the file table); if run in parallel, serialize the
README edits.

### Phase 1: Pigeonhole periodicity in `Compose.lean` [NOT STARTED]

**Goal**: Land the strengthened periodicity theorem and the recorded corollary, binder consumed,
no linter finding.

**Tasks**:
- [ ] Open a new section `/-! ## Eventual periodicity of constant blocks -/` after `kTypeOf_listSeg_append_congr` (before `end FormalSystem.Metalogic.WeakCanonical` at the file's foot).
- [ ] Land a private helper `periodic_of_collision [Fintype sig.preds] (k) (ℓ) {i j : ℕ} (hij : i < j) (h : kTypeOf sig k (listSeg (List.replicate i ℓ)) = kTypeOf sig k (listSeg (List.replicate j ℓ))) : ∀ m, i ≤ m → kTypeOf sig k (listSeg (List.replicate (m + (j - i)) ℓ)) = kTypeOf sig k (listSeg (List.replicate m ℓ))`: write `m = i + (m - i)` and `m + (j - i) = j + (m - i)` (`omega`), rewrite both sides with `List.replicate_add`, apply `kTypeOf_listSeg_append_congr` once with the first argument varying (`h.symm`) and the second `rfl`.
- [ ] Land `theorem kTypeOf_listSeg_replicate_eventually_periodic_bounded (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) (ℓ : sig.preds → Bool) : ∃ m₀ p, 0 < p ∧ m₀ + p ≤ Nat.card (KType sig k) ∧ ∀ m, m₀ ≤ m → kTypeOf sig k (listSeg (List.replicate (m + p) ℓ)) = kTypeOf sig k (listSeg (List.replicate m ℓ))`. Proof: `Fintype.exists_ne_map_eq_of_card_lt (fun i : Fin (Fintype.card (KType sig k) + 1) => kTypeOf sig k (listSeg (List.replicate i.1 ℓ)))` with the side condition `by rw [Fintype.card_fin]; omega`; wlog `i < j` (`lt_or_gt_of_ne`, symmetric case swaps); witnesses `⟨i.1, j.1 - i.1, by omega, by rw [Nat.card_eq_fintype_card]; omega, periodic_of_collision …⟩`. The `Fintype (KType sig k)` instance is found from the two binders (`normalFormFintype`); do NOT use `Fintype.ofFinite` or `classical`.
- [ ] Land `theorem kTypeOf_listSeg_replicate_eventually_periodic` with the statement verbatim from `RaySummary/README.md:285-290` (same binders, same shape), proof `obtain ⟨m₀, p, hp, -, h⟩ := kTypeOf_listSeg_replicate_eventually_periodic_bounded sig k ℓ; exact ⟨m₀, p, hp, h⟩`.
- [ ] Docstrings on both theorems: route is pigeonhole plus `kTypeOf_listSeg_append_congr` (no semigroup, no idempotent); `Nat.card (KType sig k)` is a COUNT of depth-`k` types and nothing else — quote `AnchorLayer.lean:317-320` verbatim (text in Non-negotiable (1) below) and say in the same words that this count times nothing and bounds no procedure.
- [ ] Add the two theorems to the module docstring's "Main definitions and results" list (`Compose.lean:59-66`).
- [ ] Scratch check (scratchpad file, never landed): `#print axioms` for both theorems reads exactly `[propext, Classical.choice, Quot.sound]`; no `sorryAx`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The report's scratch compile (`replicate_periodic_v2.lean`, 1878 ms, binder consumed) is a CARRIED figure from `reports/01` F2 and is not re-run at planning time; the implementer confirms it by the module build and the `#print axioms` scratch above, and confirms the `Fintype (KType sig k)` instance resolves with `example (k : ℕ) : Fintype (KType sig k) := inferInstance` under the two binders before relying on it.

**Tier Justification**: The edit adds declarations to one module and changes no existing signature, so `lake build FormalSystem.Metalogic.Decidability.RaySummary.Compose` (detached and guarded per `.claude/rules/lean4.md`) plus the `#print axioms` scratch is the complete covering check; the C16 env-linter pass over the new binder runs in Phase 2's gate.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` - new section with the private helper and two theorems; module docstring bullet

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.RaySummary.Compose` exits 0 with no warnings on the new declarations.
- Scratch `#print axioms` for both new theorems: `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- `grep -n "sorry\|set_option linter" FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` shows no new hit (the pre-existing declaration-scoped `unusedFintypeInType` line at `:270` is the only `set_option`).

---

### Phase 2: Pins, C14 baseline pair, index row, idempotence wording [NOT STARTED]

**Goal**: Pin Phase 1's theorems, record them in the ledger with the count disclaimer, and retire
the "finite-semigroup idempotence" attribution at its two sites.

**Tasks**:
- [ ] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: in the (C) section (currently `:378-413`), after the `hitPresented_of_presented` pin, add two `/-- info: '…' depends on axioms: [propext, Classical.choice, Quot.sound] -/ #guard_msgs in #print axioms FormalSystem.Metalogic.WeakCanonical.kTypeOf_listSeg_replicate_eventually_periodic_bounded` (and `…_eventually_periodic`) pins. Copy the info string's line-wrapping from the OBSERVED Lean output (the file's existing pins show both one-line and wrapped forms). The section header prose (`:378-395`, "still no bound") is rewritten in Phase 8, not here.
- [ ] `scripts/check-module-invariants.sh`: append both declarations to the `C14BASE` heredoc (after the `anchorCells_ncard_le` line, currently `:2318`) and in the SAME order to the `C14LEAN` heredoc (after `:2540`), per the comment at `:2009-2011`.
- [ ] `docs/theorem-index.md`: add one row in the Decidability band directly after the `anchorCells_ncard_le` row (currently `:206`): Paper label `—`; Statement: the eventual periodicity of `m ↦ kTypeOf sig k (listSeg (List.replicate m ℓ))` with `m₀ + p ≤ Nat.card (KType sig k)`, by pigeonhole plus `kTypeOf_listSeg_append_congr`, then the verbatim `AnchorLayer.lean:317-320` quotation and, in the same words, that `Nat.card (KType sig k)` counts depth-`k` types, times nothing, bounds no procedure, and is not a complexity bound of any kind; cross-reference the `anchorCells_ncard_le` row by name; Lean name fully qualified `FormalSystem.Metalogic.WeakCanonical.kTypeOf_listSeg_replicate_eventually_periodic_bounded` (name the corollary in the Statement cell); File `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` (no line numbers); Frame class `—`; Axioms `pcq pinned:C14`.
- [ ] `docs/theorem-index.md`, `anchorCells_ncard_le` row: replace its closing parenthetical "(obligation (iii), `kTypeOf_listSeg_replicate_eventually_periodic`, unproved)" with a pointer to the new row (the obligation is discharged; the run layer's other obligations are untouched — do not overclaim).
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md:291` and `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean:97`: replace "finite-semigroup idempotence" with "pigeonhole plus `kTypeOf_listSeg_append_congr`" (the surrounding "stated and not proved" paragraphs are rewritten in Phases 7 and 8; here only the attribution changes, so the two later rewrites start from a true sentence).
- [ ] `RaySummary/README.md:34`: update `Compose.lean`'s line-count cell to the new `wc -l` value.
- [ ] Confirm `grep -rn idempoten FormalSystem docs scripts Tests specs/evidence` returns no hit attributing this theorem to idempotence.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: Line anchors `:378-413`, `:2318`, `:2540`, `:206`, `:291`, `:97`, `:34` were re-derived by `grep`/`sed` at planning time against the current tree and shift once Phase 1 lands; the implementer re-locates each by its declaration name or row key (`anchorCells_ncard_le`, `hitPresented_of_presented`, `C14BASE`/`C14LEAN`) rather than by line.

**Tier Justification**: The pins and the C14 heredocs are the enumerated direct dependents of Phase 1's two new symbols, so `lake build BimodalTest.Metalogic.KTypeSummaryAxiomTest` plus `bash scripts/check-module-invariants.sh` (full run, exercising C14's baseline pair and C16's env-linter batch over the consumed binder) is the covering check; the index and README edits have no compile surface and are covered by the `grep` above.

**Files to modify**:
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - two pins in the (C) section
- `scripts/check-module-invariants.sh` - two lines appended to each of `C14BASE` and `C14LEAN`
- `docs/theorem-index.md` - one new row; one parenthetical in the `anchorCells_ncard_le` row
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - `:291` attribution; `:34` line count
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` - `:97` attribution

**Verification**:
- `lake build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0 (both `#guard_msgs` pass).
- `bash scripts/check-module-invariants.sh` exits 0, C14 and C16 reporting PASS.
- `grep -rn idempoten FormalSystem docs scripts Tests specs/evidence` yields no attribution of the periodicity theorem to idempotence.

---

### Phase 3: `Transport.lean` and the keystone [NOT STARTED]

**Goal**: Create the transport module and land the keystone: a segment whose `k`-type equals that
of a nonempty constant block is nonempty and constant, at `k ≥ 1`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/RaySummary/Transport.lean` with the repository header (copyright block, module docstring with "Main definitions and results" and "References" per `docs/development/LEAN_STYLE_GUIDE.md`), imports `FormalSystem.Metalogic.Decidability.RaySummary.Compose` and `FormalSystem.Metalogic.WeakCanonical.Transfer` (cycle-free: `Transfer.lean:7-14` imports nothing under `Decidability/`), `namespace FormalSystem.Metalogic.WeakCanonical` (matching `Compose.lean:77`).
- [ ] Land the two depth-1 sentence helpers and their `eval` lemmas (private where not reused): `exTop : MonadicSentence sig := .ex (.not (.lt 0 0))` with `eval M Fin.elim0 exTop ↔ Nonempty M.carrier`; `allAtom (P : sig.preds) (b : Bool) := .all (bif b then .atom P 0 else .not (.atom P 0))` with `eval M Fin.elim0 (allAtom P b) ↔ ∀ x, (M.pred P x ↔ b = true)` (closed by `cases b <;> simp [allAtom, eval]`); `quantifierDepth` of each `≤ 1` by `simp [quantifierDepth]`.
- [ ] Land `theorem segZ_const_of_kTypeOf_eq_replicate [Finite sig.preds] {k : ℕ} (hk : 1 ≤ k) (c : sig.preds → ℤ → Prop) [∀ p, DecidablePred (c p)] (a b : ℤ) (ℓ : sig.preds → Bool) {j : ℕ} (hj : 0 < j) (h : kTypeOf sig k (segZ sig c a b) = kTypeOf sig k (listSeg (List.replicate j ℓ))) : a < b ∧ ∀ s, a ≤ s → s < b → ∀ P, (c P s ↔ ℓ P = true)`. Proof per report F5: `k_equiv_monotone sig hk h` to depth 1, `k_equiv_preserves_sentence` with `exTop` (nonemptiness) and `allAtom P (ℓ P)` for each `P` (constancy); the `(List.replicate j ℓ).get x P` goal closes by `obtain ⟨i, hi⟩ := x; simp` (`List.get_replicate` does not exist at this Mathlib pin). Match the binder convention of `kTypeOf_segZ_eq_listSeg` (`Compose.lean:168`) for the `DecidablePred` instance.
- [ ] Register the module: add `import FormalSystem.Metalogic.Decidability.RaySummary.Transport` to `FormalSystem/Metalogic/Decidability/RaySummary.lean` (after `Compose`).
- [ ] Add a `Transport.lean` row to the file table in `RaySummary/README.md` (the table at `:34` lists every file; `scripts/readme-lint.sh` counts files).
- [ ] Scratch `#print axioms` for the keystone: `[propext, Classical.choice, Quot.sound]`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: "~58 lines including four helpers, ~2 s" is CARRIED from `reports/01` F5's scratch `constant_block_probe.lean` (scratchpad, not retained); the implementer re-establishes it by compiling the landed file and does not cite the figure.

**Tier Justification**: A new module plus its one enumerated direct dependent (the aggregator `RaySummary.lean`) and a README row: `lake build FormalSystem.Metalogic.Decidability.RaySummary` (which builds `Transport` and the root) plus `bash scripts/readme-lint.sh` is the covering check; no existing symbol changes, so nothing beyond that one-hop set can break.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Transport.lean` - new file: header, sentence helpers, keystone
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import line
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - file-table row for `Transport.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.RaySummary` exits 0.
- Scratch `#print axioms …segZ_const_of_kTypeOf_eq_replicate` reads `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/readme-lint.sh` exits 0.

---

### Phase 4: The deletion colouring and its type-preservation lemmas [NOT STARTED]

**Goal**: Define `deleteRun` and prove that every segment's `k`-type survives the deletion:
untouched below `s`, translated above `s`, and — for the segment holding the run — by
periodicity through `kTypeOf_listSeg_append_congr`.

**Tasks**:
- [ ] In `Transport.lean`, define `deleteRun (c : sig.preds → ℤ → Prop) (s : ℤ) (p : ℕ) : sig.preds → ℤ → Prop := fun P u => if u < s then c P u else c P (u + p)` with a docstring (deletes the positions `[s, s + p)`). Provide its `DecidablePred` instance from `c`'s, or use `Classical.decPred` uniformly in every statement below — pick one and state it in the docstring.
- [ ] `labels_deleteRun_below (hb : b ≤ s) : labels (deleteRun c s p) a b = labels c a b` and `labels_deleteRun_above (ha : s ≤ a) : labels (deleteRun c s p) a b = labels c (a + p) (b + p)` by `List.ext_getElem` + `labels_length` + `labels_getElem` (pattern: `labels_concat`, `HitOf.lean:396`).
- [ ] Hence `kTypeOf_segZ_deleteRun_below`/`_above` via `kTypeOf_segZ_eq_listSeg` on both sides.
- [ ] The modified segment: `kTypeOf_segZ_deleteRun_of_const_run (ha : a ≤ s) (hb : s + j ≤ b) (hconst : ∀ u, s ≤ u → u < s + j → ∀ P, (c P u ↔ ℓ P = true)) (hpj : p ≤ j) (hper : ∀ m, m₀ ≤ m → kTypeOf sig k (listSeg (List.replicate (m + p) ℓ)) = kTypeOf sig k (listSeg (List.replicate m ℓ))) (hm : m₀ + p ≤ j) : kTypeOf sig k (segZ sig (deleteRun c s p) a (b - p)) = kTypeOf sig k (segZ sig c a b)`. Route: `kTypeOf_segZ_eq_listSeg` twice; show `labels c a b = labels c a s ++ List.replicate j ℓ ++ labels c (s + j) b` and `labels (deleteRun c s p) a (b - p) = labels c a s ++ List.replicate (j - p) ℓ ++ labels c (s + j) b` (each by `List.ext_getElem`, with `labels_getElem` and `hconst`); then `kTypeOf_listSeg_append_congr` twice with `rfl` on the outer pieces and `hper (j - p) (by omega)` (rewritten as `kTypeOf (ℓ^j) = kTypeOf (ℓ^(j-p))` via `j = (j - p) + p`) in the middle.
- [ ] Periodicity is an explicit HYPOTHESIS (`hper`) of every lemma in this phase and the next; Phase 1's theorem is plugged in only at the probe. State this in the module docstring: the surgery is independent of how `m₀`, `p` arise.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: Report F6 estimates the two `labels` equalities as the dominant cost of the surgery (~200-300 lines for Phases 4+5 together); this is a CARRIED estimate from `reports/01` Recommendation 2 and is confirmed only by landing the lemmas. If the three-piece `labels` decomposition resists `List.ext_getElem`, decompose in two steps (`labels c a b = labels c a s ++ labels c s b`, a `labels_concat`-shaped lemma, then split the right piece again).

**Tier Justification**: Every edit is inside `Transport.lean` and adds declarations only, so `lake build FormalSystem.Metalogic.Decidability.RaySummary.Transport` is the complete covering check; no other module imports `Transport` yet except the aggregator, which re-exports without elaborating anything.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Transport.lean` - `deleteRun`, `labels_deleteRun_*`, `kTypeOf_segZ_deleteRun_*`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.RaySummary.Transport` exits 0.
- Scratch `#print axioms` on `kTypeOf_segZ_deleteRun_of_const_run`: `[propext, Classical.choice, Quot.sound]`.

---

### Phase 5: The cut surgery `inFamily_of_shrink_run` [NOT STARTED]

**Goal**: From a `SegmentFactorization` of `c` whose segment `z₀` contains a constant run
`[s, s + j)` of letter `ℓ` with `m₀ + p ≤ j`, build one for `deleteRun c s p` with the same
triple; conclude `InFamily` and `familyTriples` transport in the shrink direction.

**Tasks**:
- [ ] State `theorem inFamily_of_shrink_run [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) (c) (F : SegmentFactorization sig k c) (z₀ s : ℤ) (ℓ) (j p m₀ : ℕ) (hp : 0 < p) (hpj : p < j) (hm : m₀ + p ≤ j) (hsub : F.W z₀ ≤ s ∧ s + j ≤ F.W (z₀ + 1)) (hconst : ∀ u, s ≤ u → u < s + j → ∀ P, (c P u ↔ ℓ P = true)) (hper : …as in Phase 4…) : InFamily sig k F.τneg F.τzero F.τpos (deleteRun c s p)`.
- [ ] Construct `F' : SegmentFactorization sig k (deleteRun c s p)` with `W' z := if z ≤ z₀ then F.W z else F.W z - p`, `τneg/τzero/τpos` copied.
  - `mono`: the only cross case `z ≤ z₀ < z'` needs `F.W z ≤ F.W z₀ ≤ s ≤ s + j - p ≤ F.W (z₀ + 1) - p ≤ F.W z' - p` (uses `p ≤ j`).
  - `cover`: for `t < s` use `F.cover t` (its index is `≤ z₀`, else `F.W z ≥ F.W (z₀ + 1) ≥ s + j > t`); for `t ≥ s` use `F.cover (t + p)` (its index is `≥ z₀`; the index `z₀` itself gives `W' z₀ = F.W z₀ ≤ s ≤ t < F.W (z₀ + 1) - p`).
  - `strict_pos` (`W' 1 < W' 2`): cases `z₀ ≥ 2` (unchanged), `z₀ ≤ 0` (both translated), `z₀ = 1` (`F.W 2 ≥ s + j > s + p ≥ F.W 1 + p`, using `hpj`). `strict_neg` symmetrically with `z₀ = -2`.
  - `pos_type`/`neg_type`/`zero_type`: case `z + 1 ≤ z₀` → `kTypeOf_segZ_deleteRun_below` and `F`'s field; `z ≥ z₀ + 1` → `_above` (the segment starts at `F.W z - p ≥ s`); `z = z₀` → `kTypeOf_segZ_deleteRun_of_const_run`.
- [ ] Corollary `familyTriples_subset_deleteRun` (`Trace.lean:203`'s `familyTriples`): under `(hcont : ∀ F : SegmentFactorization sig k c, ∃ z₀, F.W z₀ ≤ s ∧ s + j ≤ F.W (z₀ + 1))` and the other hypotheses, `familyTriples sig k c ⊆ familyTriples sig k (deleteRun c s p)` — unfold `InFamily`, obtain `F`, apply the surgery. If `familyTriples` is not importable from `Transport.lean` without a cycle (`Trace.lean` is below `Compose` in the import order — confirm with `grep -n "^import" Trace.lean`), state the corollary at the `InFamily` level only and move the `familyTriples` wrapper to Phase 6 in the probe.
- [ ] Docstrings: the "re-cut" case (run met by several short segments) is NOT handled here; the single-segment containment is a hypothesis, discharged on model A in the probe; the honest general threshold for an unconditioned statement is `3·(m₀ + p)` and is not claimed.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: The `mono`/`cover` case analysis above is a planning-time hand derivation (not compiled); if a case fails to close by `omega` after instantiating `F.mono` at the two relevant index pairs, the implementer records which case and closes it by an explicit `Monotone` chain rather than widening the hypotheses. If the general statement resists outright, the dispatch's fallback applies: specialize `c` to model A's `clTrace MA Fp t (jump w)` in the probe with `W'` written against the concrete letters (same proof, fewer binders) and record the specialization in the docstring; the general theorem is then a non-goal, not a `sorry`.

**Tier Justification**: Edits are confined to `Transport.lean` (new declarations only), so `lake build FormalSystem.Metalogic.Decidability.RaySummary.Transport` is the covering check; the aggregator re-export is the only dependent and elaborates nothing.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Transport.lean` - `inFamily_of_shrink_run`, `familyTriples_subset_deleteRun`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.RaySummary.Transport` exits 0.
- Scratch `#print axioms …inFamily_of_shrink_run`: `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- `grep -n "sorry" FormalSystem/Metalogic/Decidability/RaySummary/Transport.lean` is empty.

---

### Phase 6: Model-A containment and the jump-shrink corollary (probe) [NOT STARTED]

**Goal**: On model A at `k ≥ 1`, every factorization of `jump (t + n)`'s closure trace holds the
whole run `[t + 1, t + 1 + n)` inside its middle segment, and deleting `p` of it yields
`jump (t + n - p)`'s trace; hence `familyTriples` shrink along offsets.

**Tasks**:
- [ ] In `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` (namespace `Probe745`), after `clTrace_jump_apply` (`:488`) and before `hitCl_covered` (`:566`), name the three letters as `(clSig Fp).preds → Bool` functions: `ℓ₀` (`⊤`, `Fp` only), `ℓnow` (`now`, `⊤`, `Fp`), `ℓ₁` (`⊤`, `Fp`, `p`); prove `ℓ₀ ≠ ℓnow`, `ℓ₁ ≠ ℓnow`, `ℓ₀ ≠ ℓ₁` by `decide`/`simp` on the distinguishing predicate.
- [ ] `clTrace_jump_letter`: `clTrace MA Fp t (jump (t + n))` reads `ℓ₀` at `z < t`, `ℓnow` at `z = t`, `ℓ₀` on `t < z ≤ t + n`, `ℓ₁` at `z > t + n` (pointwise `↔` forms, from `clTrace_jump_apply`).
- [ ] `exists_nonempty_seg_below`: for any `F : SegmentFactorization` and any `u`, there is `z` with `z + 1 ≤ (index of u)`, `F.W z ≤ F.W z' - 1 < F.W (z + 1)`, i.e. a nonempty segment entirely below `u` (apply `F.cover` at `F.W z' - 1` where `z'` covers `u`; `z < z'` by monotonicity). Symmetric `exists_nonempty_seg_above` (apply `F.cover` at `F.W (z' + 1)`).
- [ ] `neg_segments_const` (`hk : 1 ≤ k`): every negative segment of `F` is nonempty and constantly `ℓ₀`. Case `F.W 0 ≤ t`: segment `-2` is nonempty (`strict_neg`) and entirely `< t`, hence pure `ℓ₀`; keystone on `F.neg_type` at `-2` gives `τneg = kTypeOf (ℓ₀^len)` with `len > 0`, so every negative segment is a nonempty `ℓ₀`-block (`segZ_const_of_kTypeOf_eq_replicate` with `F.neg_type z`). Case `F.W 0 > t`: `t` lies in some negative segment `z_t`; `exists_nonempty_seg_below` at `F.W z_t` gives a nonempty negative segment entirely `< t`, pure `ℓ₀`, so by the keystone segment `z_t` is constantly `ℓ₀` — but it contains `t` carrying `ℓnow ≠ ℓ₀`; contradiction, so this case is empty.
- [ ] `pos_segments_const` symmetrically with `ℓ₁` above `t + n` (case `F.W 1 > t + n` uses `strict_pos`; case `F.W 1 ≤ t + n` puts `t + n` in a positive segment and `exists_nonempty_seg_above` supplies a pure-`ℓ₁` segment; `t + n` carries `ℓ₀` or `ℓnow`, never `ℓ₁`).
- [ ] `run_subset_middle (hk : 1 ≤ k) (F : SegmentFactorization (clSig Fp) k (clTrace MA Fp t (jump (t + n)))) : F.W 0 ≤ t + 1 ∧ t + 1 + n ≤ F.W 1`: `F.W 0 ≤ t` (else `t` is in a negative segment, impossible by `neg_segments_const`) and `t + n < F.W 1` (else in a positive one).
- [ ] `deleteRun_clTrace_jump : deleteRun (clTrace MA Fp t (jump (t + (n + p)))) (t + 1) p = clTrace MA Fp t (jump (t + n))` by `funext` + `propext` on `clTrace_jump_letter`, cases `u < t + 1` / `t + 1 ≤ u < t + 1 + n` / `u ≥ t + 1 + n`.
- [ ] `familyTriples_jump_shrink (hk : 1 ≤ k) (m₀ p : ℕ) (hp : 0 < p) (hper : …) (n : ℕ) (hn : m₀ ≤ n) (h1 : 1 ≤ n) : familyTriples (clSig Fp) k (clTrace MA Fp t (jump (t + (n + p)))) ⊆ familyTriples (clSig Fp) k (clTrace MA Fp t (jump (t + n)))`: rewrite the target by `deleteRun_clTrace_jump`, apply Phase 5's corollary with `s := t + 1`, `j := n + p`, containment from `run_subset_middle` (so `z₀ = 0`), `hpj : p < n + p` from `h1`, `hm : m₀ + p ≤ n + p` from `hn`.
- [ ] Add the new declarations to the probe's `#print axioms` foot (`:1332-1346`) and check `bash scripts/check-evidence-probes.sh` compiles the probe.

**Timing**: 2 hours

**Depends on**: 3, 5

**Verification Tier**: local

**Scope Hypothesis**: "~100-150 lines" for containment is CARRIED from `reports/01` Recommendation 2c; the two-case argument above is a planning-time derivation, compiled only when landed. The probe imports `FormalSystem` (`:132`), so `Transport.lean`'s declarations are visible once `RaySummary.lean` registers the module and `FormalSystem.lean` reaches `RaySummary` — confirm the latter with `grep -n RaySummary FormalSystem.lean` before relying on it.

**Tier Justification**: The probe is outside the Lake build graph and is compiled only by `bash scripts/check-evidence-probes.sh` (`lake env lean` on the file), so that script's exit status — the repository's sanctioned entry point — is the complete covering check for an edit confined to this one file.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` - letters, `clTrace_jump_letter`, segment lemmas, `run_subset_middle`, `deleteRun_clTrace_jump`, `familyTriples_jump_shrink`, `#print axioms` lines

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 and reports the probe compiled.
- The probe's `#print axioms` output for `run_subset_middle` and `familyTriples_jump_shrink` reads `[propext, Classical.choice, Quot.sound]`.

---

### Phase 7: Exhibit `L` — restate `hitCl_eq_truncated` and `hitPresented_modelA` [NOT STARTED]

**Goal**: Replace the `Set.Finite.bddAbove` witness by `L := Nat.card (KType (clSig Fp) k)`,
drop the `∃ L` from both theorems, and rewrite the probe's own prose in the same change.

**Tasks**:
- [ ] Introduce `abbrev presentationSize (k : ℕ) : ℕ := Nat.card (KType (clSig Fp) k)` in the probe with a docstring that quotes `AnchorLayer.lean:317-320` verbatim and says, in the same words, that this is a COUNT of depth-`k` types over the closure alphabet of `Fp`, times nothing, bounds no procedure, and is not a complexity bound of any kind.
- [ ] Restate `theorem hitCl_eq_truncated (t : ℤ) (k : ℕ) (hk : 1 ≤ k) : HitCl MA stayA t Fp k = familyTriples (clSig Fp) k (clTrace MA Fp t stayA) ∪ ⋃ w ∈ Set.Icc t (t + (presentationSize k : ℤ)), familyTriples (clSig Fp) k (clTrace MA Fp t (jump w))` (no `∃`). Proof: `obtain ⟨m₀, p, hp, hle, hper⟩ := kTypeOf_listSeg_replicate_eventually_periodic_bounded (clSig Fp) k ℓ₀`; `⊆`: for `x ∈ HitCl`, `hitCl_covered` gives `n`; prove by strong induction on `n` that `x ∈ familyTriples (stayA) ∨ ∃ n' ≤ presentationSize k, x ∈ familyTriples (jump (t + n'))` — if `n ≤ presentationSize k` done; else `n > m₀ + p`, write `n = (n - p) + p` with `m₀ ≤ n - p` and `1 ≤ n - p`, apply `familyTriples_jump_shrink` and recurse at `n - p`. `⊇`: the existing proof (`:606-611`) verbatim. Delete the `set_option linter.unusedVariables false in` and the docstring paragraph explaining it: `hk` is now consumed.
- [ ] Restate `theorem hitPresented_modelA (t : ℤ) (k : ℕ) (hk : 1 ≤ k) : HitPresented MA stayA t Fp (labOf (presentationSize k)) (stepOf (presentationSize k)) k` with the body of the current proof minus the `obtain`/`refine ⟨L, _⟩` steps.
- [ ] `card_QA`'s docstring (`:657-658`): `Fintype.card (QA (presentationSize k)) = presentationSize k + 6` is a count of states of one presentation on one fixture; add that one-line corollary `card_QA_exhibited` if it reads better in the ledger. `jump_window_card`'s docstring (`:1245-1249`) likewise.
- [ ] Rewrite the probe's prose, every site in the same change: header `:1-19` (the headline paragraph: `L` IS exhibited, as a count); `:40-42` ("What is NOT established": now the general every-model statement and any complexity bound, not the fixture bound); `:70-106` ("Bound verdict: BLOCKED" becomes "Bound verdict: EXHIBITED on this fixture, as a count", obligation discharged by `kTypeOf_listSeg_replicate_eventually_periodic_bounded`; the "honest note on machine-checked" paragraph is rewritten to say what IS now machine-checked — the explicit `L` in the statement); `:109-` (axiom record: `Classical.choice` no longer enters through `bddAbove`; re-observe the foot); `:528-541` ("Where the non-constructivity enters" becomes "Where the bound comes from"); `:583-590`; `:1073`; `:1248`; `:1274-1281`; the "What `hitPresented_modelA` does NOT say" block `:1303-1312` (first bullet replaced: `L` is exhibited as `presentationSize k`, a count; no complexity bound; `k` free; nothing about general regular ℤ-models or `PlusValidZTime`; the second bullet, "deliberately NOT `Presented`", stays).
- [ ] Keep every `#guard` and `#eval` (`:650`, `:663`, `:1258`, `:1330`) untouched; never `#eval` `presentationSize`.
- [ ] Update the `#print axioms` foot for the restated theorems; re-observe and record the axiom foot in the header's axiom paragraph as OBSERVED, not predicted.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: The prose line ranges above are re-derived at planning time and will have shifted after Phase 6's insertions; the implementer re-locates each by its quoted phrase (`grep -n "never exhibited\|unexhibited\|non-constructiv\|Bound verdict\|no computable bound\|NOT exhibited" hit-presented-model-a.lean`) and confirms that grep is empty of false statements at the end of the phase.

**Tier Justification**: The edit is confined to the probe, compiled only by `bash scripts/check-evidence-probes.sh` (`lake env lean`), so that script's exit status is the complete covering check; no library module changes in this phase.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` - `presentationSize`, restated `hitCl_eq_truncated` and `hitPresented_modelA`, docstrings, header and "does NOT say" prose, `#print axioms` foot

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0.
- `grep -n "∃ L" specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` returns no hit in a theorem statement (prose may mention the former shape only as history that the file explicitly marks as superseded).
- `grep -n "set_option linter.unusedVariables" specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` returns no hit at `hitCl_eq_truncated`.
- The observed `#print axioms` foot for `hitCl_eq_truncated` and `hitPresented_modelA` is recorded in the header.

---

### Phase 8: Ledger for the transport theorems, stale-prose sweep, full gate [NOT STARTED]

**Goal**: Pin and index the transport headline theorems, retire every remaining "no computable
bound / never exhibited / non-constructive" sentence outside the probe, and run the complete gate
set.

**Tasks**:
- [ ] Pins: add `#guard_msgs in #print axioms` at `[propext, Classical.choice, Quot.sound]` for `FormalSystem.Metalogic.WeakCanonical.segZ_const_of_kTypeOf_eq_replicate` and `…inFamily_of_shrink_run` to `KTypeSummaryAxiomTest.lean`'s (C) section; append both to `C14BASE` and `C14LEAN` in the same order.
- [ ] `docs/theorem-index.md`: one row for `inFamily_of_shrink_run` (File `FormalSystem/Metalogic/Decidability/RaySummary/Transport.lean`, Frame `—`, `pcq pinned:C14`), stating the single-segment containment hypothesis explicitly and that the unconditioned general statement is not claimed. Revise the `hitPresented_of_presented` row (`:201`): "discharged **non-constructively** … never exhibited … **No computable bound** is delivered" becomes: discharged with the presentation size EXHIBITED as `Nat.card (KType (clSig Fp) k)` — a count of depth-`k` types on one fixture, with the `AnchorLayer.lean:317-320` disclaimer in the same words — so (C) is settled on the fixture in both halves; the general every-model statement remains the (W) run-layer record's; nothing about `PlusValidZTime`, no complexity bound.
- [ ] `KTypeSummaryAxiomTest.lean:378-395` section header: retitle from "satisfiable, and still no bound" and rewrite the last paragraph ("What is **not** pinned here … no presentation size is ever exhibited") to the exhibited count, naming the probe theorem and the Phase 1 row.
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean:330-338` (`HitPresented` docstring): replace "**non-constructively** … `∃ L` with no bound on `L`. **No computable bound is delivered**" with the exhibited count and the disclaimer; keep "nothing about general regular ℤ-models".
- [ ] `RaySummary/README.md`: the (C) row (`:154`) — "non-constructive … no computable bound and no general regular ℤ-model statement follows" becomes: bound half settled ON THE FIXTURE as a count (`presentationSize k = Nat.card (KType (clSig Fp) k)`), general statement still the (W) record's; `:252`; the section "The bound: blocked, with the obligation named" (`:270-300`) — retitle to "The bound: exhibited on the fixture, as a count", replace the "stated and not proved" obligation block by the landed theorems (Phase 1's two, keystone, surgery) with the disclaimer, keep the "honest scope note" rewritten to what is now machine-checked; `:455`; the `Transport.lean` and `Compose.lean` rows in the file table (line counts).
- [ ] `scripts/check-evidence-probes.sh` wired-probe table (`:436-440`, `:475-479`): "satisfiable, non-constructively; general (C) with a computable bound still open" becomes "satisfiable with the size exhibited as a count; general (C) still open"; "NON-CONSTRUCTIVE and delivers NO bound: the `L` is a `Set.Finite.bddAbove` witness" rewritten accordingly.
- [ ] `scripts/check-module-invariants.sh:2074-2078` C14 comment: "non-constructively and with NO computable bound" rewritten.
- [ ] `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean:67`: "holds on model A non-constructively" becomes "holds on model A with its presentation size exhibited as a count".
- [ ] Sweep: `grep -rn -i "no computable bound\|never exhibited\|unexhibited\|non-constructiv\|still no bound\|finite-semigroup\|bddAbove" FormalSystem docs scripts Tests specs/evidence README.md` — every remaining hit is read and either corrected or confirmed to describe something other than this record's bound (record the confirmation list in the implementation summary). Also `grep -rn -i "2EXPTIME\|running time\|complexity bound" ` over the files touched by this task: every hit must be a denial, never a claim.
- [ ] Full gate set: `lake build` (whole library and tests, detached and guarded per `.claude/rules/lean4.md`); `bash scripts/check-module-invariants.sh` (full, not `--no-build`; C14, C16, C27, C29, C30 PASS); `bash scripts/check-evidence-probes.sh`; `bash scripts/readme-lint.sh`; `bash .claude/scripts/verify-deploy.sh` — each checked by exit status.

**Timing**: 2 hours

**Depends on**: 2, 7

**Verification Tier**: full

**Scope Hypothesis**: The stale-prose inventory (eleven sites) is CARRIED from `reports/01` F8 and re-derived at planning time by `sed`; it is complete for the grep terms used, and the sweep in this phase is what confirms completeness rather than the list itself.

**Files to modify**:
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - two pins; (C) section header prose
- `scripts/check-module-invariants.sh` - two lines in each C14 heredoc; the C14 comment
- `docs/theorem-index.md` - one new row; the `hitPresented_of_presented` row
- `FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean` - `HitPresented` docstring
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - (C) row, `:252`, the bound section, `:455`, file-table line counts
- `scripts/check-evidence-probes.sh` - wired-probe table prose
- `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean` - one sentence

**Verification**:
- `lake build` exits 0 with no new warnings.
- `bash scripts/check-module-invariants.sh` exits 0 (C14 baseline pair, C16 env linters, C27, C29, C30 all PASS).
- `bash scripts/check-evidence-probes.sh` exits 0 (every wired probe, including the two edited ones, compiles).
- `bash scripts/readme-lint.sh` exits 0.
- `bash .claude/scripts/verify-deploy.sh` exits 0 with no FINDING attributable to this run.
- The two grep sweeps above are clean in the sense stated (no false "unexhibited" claim; no complexity claim).
- `grep -rn "sorry" FormalSystem/Metalogic/Decidability/RaySummary/Transport.lean FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` is empty; no new `axiom` declaration anywhere in the diff.

## Non-Negotiables (carried from the task description, checked at every phase)

1. `Nat.card (KType …)` is a COUNT and nothing else. Wherever this record's count appears (Phase 1 docstrings, the index rows, `presentationSize`'s docstring, the README bound section), quote verbatim from `AnchorLayer.lean:317-320`: "The one bound (W) can state honestly: a cardinality bound on the SET OF CELLS of a model, syntactic in `|cl φ|` — a cell is a set of subsets of `cl φ`, so there are at most `2 ^ (2 ^ |cl φ|)` of them. It is not a complexity bound of any kind: it counts cells, it does not time anything, and it must not be described as a bound on any procedure's running time." Derive nothing from the size of `NormalForm (clSig φ) k 0`.
2. The alphabet constraint (`clSig φ := subformulas φ ⊕ Unit`, `Closure.lean:80-81`) is met and not re-litigated.
3. `k` stays free: every new `k`-dependent statement carries `(hk : 1 ≤ k)` exactly as `hitCl_eq_truncated` does; no `k` is chosen.
4. `Decidable (PlusValidZTime φ)` appears in no statement.
5. No complexity bound, upper or lower, is asserted or implied; the CTL⋆ 2EXPTIME ceiling is never an upper-bound source.
6. Sorry-free; a route that does not close is `[BLOCKED]` with the obstruction named (the surgery's fallback is the model-A specialization in Phase 5's Scope Hypothesis, not a `sorry`).

## Decisions

- **Landing site**: Phase 1 in `Compose.lean` (import cycle forbids `Saturation.lean`); namespace as the dispatch names it. `Saturation.lean` remains in `file_scope` but is not edited.
- **Binder**: `[DecidableEq sig.preds]` kept in the signature and consumed by the proof; no linter finding, no `nolints.json` entry, no `set_option`. The dispatch's expectation of an `unusedArguments` warning is thereby moot, not contradicted.
- **Phase 2's statement**: shrink direction only, under an explicit single-segment containment hypothesis, at threshold `m₀ + p`; general over `sig`. The lengthen direction and the unconditioned statement (threshold `3·(m₀ + p)`) are non-goals and no prose claims `↔`.
- **New module** `Transport.lean` rather than growing `Compose.lean`: the keystone needs `Transfer.lean`, which `Compose.lean` does not import; keeping `Compose.lean`'s import closure unchanged avoids rebuilding its dependents for an import it does not use.
- **`L`**: `Nat.card (KType (clSig Fp) k)`, through a probe-local `abbrev presentationSize`; never `#eval`-ed.

## Testing & Validation

- [ ] Every new library theorem compiles with axioms exactly `[propext, Classical.choice, Quot.sound]` and is pinned in `KTypeSummaryAxiomTest.lean` and the C14 baseline pair.
- [ ] `bash scripts/check-module-invariants.sh` PASS (C14, C16, C27, C29, C30).
- [ ] `bash scripts/check-evidence-probes.sh` PASS on every wired probe.
- [ ] `bash scripts/readme-lint.sh` PASS (new file row present).
- [ ] `bash .claude/scripts/verify-deploy.sh` PASS.
- [ ] Stale-prose sweep and no-complexity-claim sweep (Phase 8) clean.
- [ ] No `sorry`, no new `axiom`, no `Decidable (PlusValidZTime φ)`, no chosen `k`.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` (two theorems + helper)
- `FormalSystem/Metalogic/Decidability/RaySummary/Transport.lean` (new)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` (registration)
- `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` (containment, shrink, explicit `L`)
- Pins, C14 baseline pair, `docs/theorem-index.md` rows, README/docstring/script prose revisions
- `specs/749_c_bound_half_model_a_presentation_size/summaries/01_c-bound-half-model-a-summary.md`

## Rollback/Contingency

Each phase is committed only when green (per-substep commit mandate), so a failing later phase
leaves the tree at the last green commit. If Phase 5's general surgery does not close, apply the
dispatch's fallback (model-A specialization in the probe, Phase 5's Scope Hypothesis); if that
does not close either, mark Phase 5 `[BLOCKED]` naming the obstruction, leave Phases 1-4 landed
(they are independently valuable and pinned), and do not touch Phases 6-8's prose — the tree then
still says the bound is unexhibited, which remains true. Never a `sorry`, never a new axiom. For
an intentional rollback of uncommitted work, `bash .claude/scripts/git-snapshot.sh 749` first
(see `.claude/rules/git-workflow.md`); for an ordinary defensive checkpoint before Phase 5 or 7,
`bash .claude/scripts/git-snapshot.sh --no-revert 749`.
