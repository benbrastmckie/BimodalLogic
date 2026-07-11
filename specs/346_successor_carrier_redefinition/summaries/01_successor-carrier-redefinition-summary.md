# Implementation Summary: Successor Carrier Redefinition (task 346)

- **Task**: 346 - successor_carrier_redefinition
- **Type**: lean4 (hard mode)
- **Plan**: `specs/346_successor_carrier_redefinition/plans/01_successor-carrier-redefinition.md`
- **Session**: sess_1783782450_230288
- **Status**: implemented (all 6 phases COMPLETED)
- **Completion date**: 2026-07-11

## Executive Summary

Report 01 (H4-verified) re-framed the task: the literal "bit-compatibility carrier redefinition"
was already landed by tasks 333/334, so the genuine open work was a **fragment-predicate repair +
non-vacuous restatement + exterior-completeness re-scope**. Task 346 delivered exactly that:

1. Swapped the fragment carrier list from the global positive index `kvE2_sepPos` (proven
   *unrealizable* — every realized qnf carries >=3 boundary positives, report 07 Refutation 1) to
   the interior-restricted index `kvE2_sepPosI`, byte-identically at both predicate sites.
2. Proved the new interior-singleton predicate is **realizable** with a concrete witness
   (`kvE2_sepFragment_realizable`), making the RE-SCOPE verdict a machine-checked fact.
3. Repaired the fold (`kvE2_outer_fold_frag`) and its kit consumer for the un-vacuated boundary
   case via an honest **hypothesis-split** interface (`hreal` / `hexcl` / `hexclExt`) — no sorry,
   no vacuous placeholder.
4. Re-stated the soundness half `bracketEndChar_kvE2_sound_two_prior_frag` non-vacuously and
   removed both VACUITY NOTEs.
5. **Full-project `lake build` GREEN** (1720 jobs); all touched theorems axiom-clean; zero sorries
   on any task-346 live path.

The full-exterior completeness residue is **quarantined** as the named hypothesis `hexclExt`
(strictly-exterior exclusion) and deferred to a documented Prop-4.3 successor task — not hidden
behind a sorry.

## Phases Executed

| Phase | Name | Status | Key deliverable |
|-------|------|--------|-----------------|
| 1 | Byte-identical fragment-predicate swap + build triage | COMPLETED | Swap applied at both sites; break surface localized to 3 fold-family sites (all below the 341 GATE banner) |
| 2 | Interior-singleton realizability witness | COMPLETED | `kvE2_sepFragment_realizable` (SW ~:10265) — concrete satisfier, 4 positives collapse to interior singleton `[σ0]` |
| 3 | hexcl boundary-restriction (R1) | COMPLETED | `hexcl` split into cone `hexcl` + exterior `hexclExt`; forward branch re-threaded via `by_cases hcone` |
| 4 | Fold backward-branch repair for boundary positives | COMPLETED | `exfalso` retired; boundary positives realized via named `hreal` channel; kit_sound + fold signatures updated |
| 5 | Non-vacuous restatement + VACUITY-NOTE removal | COMPLETED | `bracketEndChar_kvE2_sound_two_prior_frag` re-stated against the fold interface; both VACUITY NOTEs replaced with NON-VACUITY notes |
| 6 | Handoff — inventory, consumer notes, successor spec | COMPLETED | Full build green; sorry inventory empty; consumer + successor documentation (this summary) |

## Theorems / Definitions Landed

| Decl | File | Change | Axioms |
|------|------|--------|--------|
| `kvE2_sepFragment` (def) | OuterGate:200 | Carrier list `kvE2_sepPos` -> `kvE2_sepPosI` (byte-identical to `_frag`) | (predicate; consumed clean) |
| `kvE2_sepFragment_frag` (def) | SharedWitness:10219 | Identical swap (rfl defeq bridge preserved) | (predicate; consumed clean) |
| `kvE2_sepFragment_realizable` (thm) | SharedWitness ~:10265 | NEW — realizability witness | {propext, Classical.choice, Quot.sound} |
| `kvE2_outer_fold_frag` (thm) | SharedWitness:12627 | Signature: dropped `hfrag`/`hcorrK`, added `hreal`/`hexclExt` (kept cone `hexcl`); backward branch realizes boundary positives via `hreal` | {propext, Classical.choice, Quot.sound} |
| `kvE2_sepBody_kit_sound_frag` (thm) | SharedWitness:12487 | Signature: dropped 6 order bits + `hfrag` + `hcorrK`, added `hreal`; dispatch via `kvE2_sepBody_extract` + `hreal` | {propext, Classical.choice, Quot.sound} |
| `bracketEndChar_kvE2_sound_two_prior_frag` (thm) | OuterGate:245 | Re-stated: single all-carrier `hexcl` -> `hreal` + cone `hexcl` + `hexclExt`; `h_UZ`/`h_SZ`/`hcorrK` dropped; `hfrag` retained as non-vacuity anchor | {propext, Classical.choice, Quot.sound} |

## Final Verification Results (Phase 6)

- **Full-project `lake build`**: GREEN — `Build completed successfully (1720 jobs)`, exit 0.
- **Axiom audit** (authoritative `lake env lean` `#print axioms` against the warm build cache) on
  the four key theorems: all `{propext, Classical.choice, Quot.sound}` — NO `sorryAx`.
- **Sorry inventory (live paths)**: EMPTY. All `sorry` substrings in the two modified files
  (OuterGate:251; SharedWitness:68/2996/5431/6929/6948/12579) are prose/docstring occurrences
  (design notes asserting "no sorry"), not tactic terms. Grep + `#print axioms` cross-confirm.
- **Vacuous definitions**: none introduced.
- **New axioms**: none introduced.
- **Pre-existing unrelated `sorryAx`** (NOT a 346 regression, documented for honesty): the whole-
  project build surfaces `sorryAx` on `Bimodal.Metalogic.BXCanonical.completeness` /
  `completeness_discrete` (`BXCanonical/Completeness.lean:342-372`). That file is in a different
  module tree, was NOT touched by any task-346 commit (last touched by tasks 302/301/281/155), and
  is out of task-346 scope. It is the task-155 Stavi EF-game residue, unrelated to the Kamp
  NfMultiAnchorBridge work here.

## No Full-Build Breakage from This Task's Interface Changes

The delegation flagged a risk that downstream consumers referencing the OLD signatures (arity,
`hfrag`/`hcorrK`) might turn the full build RED. Verified NOT the case:

- `bracketEndChar_kvE2_sound_two_prior_frag` has **zero external consumers** in `Theories/`
  (grep: no references outside `OuterGate.lean`).
- `kvE2_outer_fold_frag` is referenced only inside `OuterGate.lean` (all references are the single
  internal caller at :290 plus doc prose).
- `kvE2_sepBody_kit_sound_frag` is called only by the fold; its sole external mention is doc prose
  (OuterGate:214).

The interface changes are therefore self-contained within `NfMultiAnchorBridge`, and the
downstream consumers named below (task 309 / 335 / `KampPrior.lean:351`) do not yet wire this gate
into a compiled path (they carry strategic sorries / are not-yet-assembled), so no fix-forward was
required and no consumer file went RED.

## Deviations from Plan (all accepted, machine-justified)

1. **Phase 3 — hexcl SPLIT, not single-binder restriction.** The plan's "restrict the `hexcl`
   binder to the cone" with a "trivial cone-membership fill" was unachievable: `nf_eval_nf`
   (`NormalForm.lean:206`) quantifies the fresh-variable existential over ALL of `M.carrier`, so
   the forward branch genuinely needs to exclude strictly-exterior witnesses too. Realized instead
   as a split: `hexcl` (cone `x <= x1 <= t`, Phase-4-dischargeable) + `hexclExt` (strictly-exterior
   residue, deferred). `hexcl AND hexclExt` = the old full `hexcl`; no logical strength dropped.
2. **Phase 4 — `hreal` realization channel, not in-carrier endpoint-literal realization.** In-carrier
   realization of a boundary σ's FULL arity-4 zone content requires the task-335 provider to witness
   each true bit (design note SW:10027-10032); the endpoint literals carry only σ's charK-atom
   content. Realized via a named `hreal` hypothesis (the completeness dual of `hexcl`),
   provider-discharged downstream — structurally identical to the Phase-3 split. Also **expanded**
   from the plan's single backward-branch surface to include `kvE2_sepBody_kit_sound_frag`'s two
   fragL/fragR call sites (Phase-1 triage finding: kit_sound also breaks under the swap because it
   feeds `hpos` to the global-singleton producers).
3. **Phase 2 — placement below the 341 GATE banner, stated over `kvE2_sepFragment_frag`.** The plan's
   "~SW:245" slot sits ABOVE the frozen SW:10210 banner (orchestrator constraint forbids edits
   there), and `OuterGate.kvE2_sepFragment` is not visible in `SharedWitness` (import cycle). Witness
   appended below the banner over the byte-identical `_frag` predicate; Phase 5 consumes it via the
   rfl defeq bridge. The witness is combinatorial (pure `qnf`-domain), so no `OrderedMonadicStructure`
   was needed.

## Preserved Assets — Verified, Not Rewritten

All confirmed green under the full build; none re-proved:

- Symmetric-gate clause (v) (Rabinovich Cor 5.4; task 345) — inert under the swap (keys on zone).
- Pin-anchored gate producers `kvE2_sepGateAtPin_fragL`/`_fragR` (tasks 344/345) — green, unchanged
  (they demand the global singleton; genuinely inapplicable in the new regime but not edited).
- Unconditional completeness half `bracketEndChar_kvE2_complete_two_prior` (OuterGate:139) and
  provider bridge `bracketEndChar_kvE2_hck` (OuterGate:115; 335 Phase B) — untouched.
- Interior index + membership lemmas `kvE2_sepPosI`/`_mem`/`_zone`/`_subset` (task 342) — reused as
  the new carrier; not modified.
- Bit-compatibility carrier `kvE2_sepCompat` (tasks 333/334) — frozen, not re-plumbed.
- No decl above the SW:10210 341 GATE banner was edited.

## Consumer Impact Notes

The soundness-half interface changed. Any task consuming it must supply the new hypothesis triple
and carry the exterior residue as the successor obligation.

**Old interface (pre-346)** — `bracketEndChar_kvE2_sound_two_prior_frag` took a single all-carrier
exclusion `hexcl : ∀ w …, ∀ σ, qnf.2 σ = false → ∀ x1, ¬ nf_eval_nf …`, plus provider priors
`h_UZ`/`h_SZ` and the `hcorrK` correctness bridge, and destructured `hfrag`.

**New interface (post-346)** — the caller must supply:
- `hreal` — per-positive realization: `∀ w, x < w → w < t → (kvE2_sepPtW …).eval_at M atomMap w →
  ∀ σ ∈ kvE2_sepPos qnf, ∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`.
  This is the completeness dual of `hexcl`; provider correctness now lives here (subsumes the
  dropped `hcorrK`/`h_UZ`/`h_SZ`).
- `hexcl` — cone-restricted exclusion, binder guarded `x ≤ x1 → x1 ≤ t` (dischargeable by the
  landed endpoint/witness biconditional literals).
- `hexclExt` — strictly-exterior residue, binder guarded `¬ (x ≤ x1 ∧ x1 ≤ t)`. **This is the
  deferred Prop-4.3 obligation the successor task carries.**
- `hfrag : kvE2_sepFragment qnf` — retained purely as the non-vacuity anchor (proof-unused; benign
  `unusedVariables` warning at OuterGate:267). It is satisfiable by `kvE2_sepFragment_realizable`.

Per-consumer:

- **Task 309, Phases 13.4/14** (final soundness assembly): must consume the **interior+boundary
  gate**, NOT a full-exterior hexcl-free gate. It supplies cone `hexcl` + `hreal` and threads
  `hexclExt` outward as the exterior obligation. Any plan step expecting the old single all-carrier
  `hexcl` (or the `hcorrK`/`h_UZ`/`h_SZ` provider priors) must be updated to the new triple.
- **`KampPrior.lean:351` strategic sorry**: this is the downstream site that will eventually
  discharge the gate. Under the new interface it now expects the interior+boundary gate; when it is
  wired, it must supply `hreal` (from the task-335 provider) + cone `hexcl` and leave `hexclExt` as
  the named exterior residue. It must NOT assume the gate already covers strictly-exterior witnesses.
- **Task 335, Phase D** (interior+boundary-scoped correct gate assembly): `hreal` is the exact
  hook where task 335 discharges the boundary+interior realization obligation — its shape is
  provider-friendly (quantifies the pivot `w`, guards on `kvE2_sepPtW.eval_at w`, asks for
  `∃ x1, nf_eval_nf [x1,w,x,t] σ` per positive σ; the `ExistProviders.correct` step-(c)
  instantiation). Phase D assembles the interior+boundary gate; the strictly-exterior completeness
  is explicitly out of Phase D scope and belongs to the Prop-4.3 successor.

## Deferred Successor Task Specification (do NOT create here; document only)

The following is written so `/task` or `/spawn` can create it verbatim. **This dispatch does NOT
add the entry to state.json** — creation is the orchestrator's / user's call.

---

**Title**: `prop43_exterior_completeness`

**Type**: lean4

**Dependencies**: 346 (landed — provides the `hexclExt` isolation point), 335 (provider), 309
(consumer assembly). Grounding literature: 330 report 01, 335 report 07.

**Description**:

Discharge the strictly-exterior completeness obligation isolated by task 346 as the named
hypothesis `hexclExt` in `kvE2_outer_fold_frag` (SharedWitness:12627) and
`bracketEndChar_kvE2_sound_two_prior_frag` (OuterGate:245). Task 346 delivered an
interior+boundary-complete CONDITIONAL gate; the residue is the exclusion of strictly-exterior
witnesses `x1` with `¬ (x ≤ x1 ∧ x1 ≤ t)`:

```
hexclExt : ∀ w, x < w → w < t → (kvE2_sepPtW …).eval_at M atomMap w →
           ∀ σ, qnf.2 σ = false → ∀ x1, ¬ (x ≤ x1 ∧ x1 ≤ t) → ¬ nf_eval_nf M 1 4 [x1,w,x,t] σ
```

**Obligation carried**: full-exterior completeness — proving no strictly-exterior point realizes a
qnf-false sub. This is the outer-forward exterior direction machine-confirmed NOT dischargeable on
any currently-unblocked in-tree route (335 report 07 **Refutation 2**: category mismatch at the
inner-bits layer + `bracketEndChar_kv_factors` arity-1 inseparability).

**Entry problem**: the navigated Prop-4.3 re-flatten route
(`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean`) is independently BLOCKED on the
uniform-negation connective cases (`:120-159`). That blocker is the successor's first target: either
complete the uniform-negation re-flatten there, or establish a new route to the exterior exclusion.

**Grounding**:
- 330 report 01 (Prop 4.3 audit — the exterior-completeness requirement).
- 335 report 07, Refutation 2 (why the direct route is inseparable) and point 1 (Prop 4.3
  dependency).
- `Prop43.lean:120-159` (the blocked navigated route, entry problem).

**Definition of done**: `hexclExt` is discharged for the intended model class, the fold and
soundness-half theorems are called with the residue closed (interior+boundary+exterior = full
completeness), and the `KampPrior.lean:351` strategic sorry is retired. Axiom-clean
{propext, Classical.choice, Quot.sound}, no sorry on any live path.

**Scope note**: this is a distinct major effort (a genuine mathematical gap, not a wiring task) and
was deliberately out of task-346 scope — task 346's RE-SCOPE verdict (settled, not to be re-opened
without a machine counterexample) is precisely that the exterior direction is not achievable in the
346 timeframe.

---

## Artifacts

- Plan: `specs/346_successor_carrier_redefinition/plans/01_successor-carrier-redefinition.md`
- Progress records: `specs/346_successor_carrier_redefinition/progress/phase{1..5}-*.md`
- This summary: `specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md`
- Modified source (all commits landed):
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean`,
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
- Phase commits: 44fd89221, eeb904088, 13605f51c, 809addd44, 070002293, bebc49179
