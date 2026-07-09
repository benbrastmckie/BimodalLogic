# Task 342 Phase 5 Handoff (sess_1783617988_38e7cf)

## Immediate Next Action

Phase 6 (opens Part II — tie-admitting validity): replace `kvE2_sepDisjValid` conjunct (iii)
(global `Nodup` over flattened index tuples, SW:1534) with (iii') anchor-distinct + (iv)
tie-class validity reads; add `kvE2_sepClosedLeafAt`, the anchor-payload projection, and the
`kvE2_sepTieGroupedL/R` grouping functions. See "Phase 6 Recipe" below.

## Current State

- Phase 5 [COMPLETED] (plan heading updated). Part I is fully landed.
- Full `lake build` green (1720 jobs). Commit `25aa1c0e2`
  (`task 342 phase 5: delete hLR binders …`). Diff: 72 insertions, 64 deletions across
  `SharedWitness.lean` (code+docs), `OuterGate.lean` (prose only), plan file (status marker).
- **hLR DELETED** from all four completeness theorems — `kvE2_sepBody_complete` (SW:2632),
  `kvE2_sepCoincidentOrder_mem_arr'` (SW:2680), `kvE2_sepHonestOrder_mem_arr'` (SW:3291),
  `kvE2_sepBody_complete_holds` (SW:4467) — all now UNCONDITIONAL over the honest evaluation
  `h`. The one forwarding use (old SW:4477) removed. Zero proof-body repairs were needed
  (Phase 4 had made `hLR` syntactically unused); this was a pure statement rewrite as planned.
- **`kvE2_sepDisjunct_extract` restated** (SW:~4886): `hmemL`/`hmemR` now quantify over
  `kvE2_sepPosI qnf`. Proof repaired with one `have hσI := (kvE2_sepPosI_mem qnf σ).mpr
  ⟨hσpos, Or.inl/inr hzone⟩` per bundle branch (conclusions stay zone-guarded over
  `kvE2_sepPos`, unchanged). The `kvE2_sepBody_extract` call site SIMPLIFIED: the lambdas now
  pass `hσ` straight to `kvE2_sepSlotsL/ROf_mem` (the `kvE2_sepMem_posI_of_slotL/R` upgrade is
  no longer needed there).
- **Guard verbatim**: `kvE2_sepHonest_hLR_absurd` (SW:4834) — zero diff hunks in its region
  (old 4816–4867); statement, docstring, proof untouched. `lean_verify`:
  `{propext, Classical.choice, Quot.sound}`.
- **Exit-gate audit** (`grep -n hLR`): SharedWitness 9 lines = 6 inside the guard + its
  docstring (4819/4825/4828/4834/4838/4863) + 2 historical-reference lines in
  `kvE2_sepBody_complete`'s new docstring (2630–2631) + 1 guard-name reference in
  `complete_holds`'s docstring (4464). OuterGate: 2 prose lines (32–33) referencing the guard
  by name. No `hLR`-shaped binder exists anywhere outside the guard.
- Axioms (`lean_verify`, prefix `Bimodal.Metalogic.WeakCanonical.Kamp.`): all four rebuilt
  theorems + `kvE2_sepDisjunct_extract` + the guard = exactly
  `{propext, Classical.choice, Quot.sound}`.
- `grep -rc kvE2_sepPosI_eq_pos Theories/` = 0 (vacuity bridge still dead). Sorry count in
  landed declarations: 0 (all grep hits are prose or quarantined Boneyard). `sorry_inventory`:
  empty. No new axioms; no vacuous defs.
- Non-vacuity: the four theorems' hypothesis sets are now jointly satisfiable (the guard's
  `False` derivation consumed `hLR`; with it gone, `h` alone is the realizable honest-bundle
  setting). Proof bodies are constructive (no `absurd`/`False.elim` route).

## Phase 6 Recipe (Part II opener — tie-admitting validity)

**The live `kvE2_sepDisjValid` conjunct structure** (SW:1530–1534), verbatim:

```lean
noncomputable def kvE2_sepDisjValid {sig : MonadicSignature}
    (_qnf : NormalForm sig 2 3) (wo : KvE2SepWeakOrder sig) : Bool :=
  wo.all (fun p => kvE2_sepDisjValidOwner p.1 p.2.1)          -- (i)  zone-bit placement read
    && wo.all (fun p => kvE2_sepConsistentBlock p.1 p.2.2)    -- (ii) per-owner linear extension
    && decide (wo.flatMap (fun p => p.2.2)).Nodup             -- (iii) GLOBAL Nodup — REPLACE
```

`wo : KvE2SepWeakOrder sig` entries are `p = (σ, (tag, idxTuple))` with `p.1 : NormalForm sig
1 4`, `p.2.1 : KvE2SepSpikeOrderType`, `p.2.2 : List ℕ` (the owner's per-slot global-index
tuple `(i₀,i₁,i₂)`). NOTE: the (iii) `Nodup` is over the flattened FULL tuples, not just the
anchor bases `i₀` (the SW:1521 docstring's "anchor-base indices" phrasing understates the code
— read the code). `kvE2_sepDisjValidOwner` (SW:1506): `.strictBefore` → OPEN `zXU` bit,
`.strictAfter` → OPEN `zUW` bit, `.coincident` → `kvE2_sepClosedLeafStub σ` (SW:1496:
left-interior → CLOSED `zAtX1L` at `nf0_projFresh σ.1`, else CLOSED `zAtX1R`). F5: the
tie-class read path must use ONLY these CLOSED keys — grep any new code for `kvE_sub2_` keys.

**Steps** (plan Phase 6 tasks, SW anchors current as of commit 25aa1c0e2):
1. `kvE2_sepClosedLeafAt (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : Bool` — foreign-
   type generalization of `kvE2_sepClosedLeafStub` (left-interior: `kvE2_sepBits σ
   kvE2_sep_zAtX1L χ`, else `zAtX1R`). Lemma: `kvE2_sepClosedLeafStub σ =
   kvE2_sepClosedLeafAt σ (nf0_projFresh σ.1)` (should be `rfl`-adjacent by `if` congruence).
2. Anchor-payload projection: extract each owner's ANCHOR-slot payload index from
   `(σ, tag, t)` — the anchor is at structural position `(kvE2_sepS σ kvE_sub2_zXU).length`
   (left) resp. `(kvE2_sepS σ kvE2_sep_zWX1).length` (right) in `kvE2_sepSlotBlock σ`;
   `lean_local_search` for an existing 340 block-position lemma before writing one.
3. Replace (iii) with (iii') anchor-distinct `Nodup` + (iv) tie-class validity (each duplicated
   payload value's class: ≤1 anchor slot; anchor-of-`σa` + base slots of types `χᵢ` forces
   `kvE2_sepClosedLeafAt σa χᵢ = true`; base-base classes impose no read). Keep (i)/(ii)
   verbatim; keep everything `Bool`/`decide`-able.
4. `kvE2_sepTieGroupedL/R` grouping (`List.splitBy` or house pattern) + round-trip lemmas
   (`flatten` = the sorted list; classes nonempty; Nodup ⇒ all singletons).
5. Repair conjunct-(iii) branches of the three membership theorems via ONE shared
   `kvE2_sepDisjValid_tie_of_nodup`-style lemma: current payloads are globally Nodup (banked:
   `kvE2_sepAllSlots_map_slotIndexOf_nodup` for coincident, `kvE2_ordRank_injective` route for
   honest), which implies (iii') and vacuates (iv).

**Preserved-green watchlist** for Phase 6: the three membership theorems' conjuncts (i)/(ii)
must compile verbatim; only the (iii) branch (the `decide_eq_true_eq` + flatMap-rewrite blocks
at SW:~2668/~2710/~3320s) changes. Do not touch the guard, `kvE2_sepDisjunct_extract`,
`kvE2_sepBracketN_construct`, or any banked `kvE2_sepHonest*` lemma.

## Key Decisions / Gotchas

- OuterGate.lean received prose-only edits (header item 4 parenthetical + the full R-A scope
  bullet, lines ~21–34): the `hL` description was replaced with the interior-restricted-carrier
  description. No code in that file changed (it contains only the live def + `rfl` bridge).
- The guard's own docstring still says the completeness theorems are "conditional on `h ∧
  hLR`" — intentionally left verbatim per the plan's prefer-zero-changes rule; it is now a
  historical record of WHY the hypothesis was removed.
- The 340-plan file `specs/340_*/plans/03_*.md` and `working-progress-1783582863.patch` remain
  dirty from an unrelated session — do NOT stage them.
- FORBIDDEN (unchanged): any PosI/Pos equality lemma; any hLR-shaped hypothesis;
  `kvE2_sepPosI` as an append of two zone filters; citing "per the proof of Lemma 3.2(1)"
  (the closure is stated without printed proof — "It is clear that", Def 3.1 p.4 forces
  tie-collapse; k=m split p.7 and Def 7.5 p.13 are corroboration only).

## Sorry Inventory

(empty)
