# Research Report: Task #563

**Task**: 563 - formalize_interval_site_and_behavior_presheaf
**Started**: 2026-10-03T06:10:58Z
**Completed**: 2026-10-03T06:52:00Z
**Effort**: ~45 min (research only)
**Dependencies**: None
**Sources/Inputs**:
- Codebase (`FormalSystem/Semantics/`, `scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`, `scripts/check-paper-definitions.sh`, `docs/reference/paper-definitions-of-record.md`, `docs/development/REFERENCE_NORMAL_FORM.md`, `docs/reference/docstring-standard.md`, `references.bib`)
- `specs/archive/553_decide_convex_history_layer_collapse/probes/04_presheaf-skeleton.lean` (the named probe; **archived**, path in the dispatch is stale)
- `specs/archive/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` §5.1
- Literature source: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, `def:interval-site` and `def:behavior-presheaf` (both inside the commented-out `app:Structure` block)
- lean-lsp readiness: declared `reachable`; evidence below is **compiled-probe** evidence (`lake env lean`), the strongest tier available, so no claim here rests on a `lean_local_search` empty result.

**Artifacts**:
- `specs/563_formalize_interval_site_and_behavior_presheaf/reports/01_interval-site-behavior-presheaf.md` (this report)
- `specs/563_formalize_interval_site_and_behavior_presheaf/probes/01_port-probe.lean` (port of the task-553 probe, compiles, exit 0)
- `specs/563_formalize_interval_site_and_behavior_presheaf/probes/02_site-probe.lean` (interval site `Int(D)`, compiles, exit 0)
- `specs/563_formalize_interval_site_and_behavior_presheaf/probes/03_siting-rehearsal.lean` (**the lift-ready artifact**: both modules in their final namespaces with the layering guard, 226 lines, 0 sorry, compiles warning-free, exit 0)

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The dispatch's central premise is false as written, and the correction is cheap.** The named
  probe does **not** compile against the live tree: it is written against a `ConvexHistory`
  *structure* that commit `0688a7a3c` deleted ("Re-base history layer on PartialHistory, delete
  ConvexHistory"), and it calls `ShiftSet.wh_ext`, which commit `60d65a1d3` removed. The probe is
  also not at the path the dispatch names — task 553 has been archived to `specs/archive/`.
- **All four deliverables nevertheless port, sorry-free, and are now verified.** The port is
  mechanical and *shrinks* the proof: with `Beh F l` a subtype of `PartialHistory F`, the probe's
  `convex` field and its three convexity proofs disappear, and convexity becomes a derived
  one-liner (`Beh.isConvex`). Three further deltas: `PartialHistory.states_eq_of_time_eq` replaces
  the `ConvexHistory` namesake, a locally-stated `partialHistory_ext` replaces the deleted
  `ShiftSet.wh_ext` (Lean generates no `PartialHistory.ext` — the dependent `states` field blocks
  it), and `[F.IsRegular]` is now required wherever a frame axiom is consumed.
- **The siting constraint is satisfied strictly, not just adequately.** The cluster needs only
  `FormalSystem.Init` + `FormalSystem.Semantics.PartialHistory` — no `ShiftSet`, no `Truth`, no
  Mathlib import beyond what `PartialHistory` already pulls. `assert_not_exists
  FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree` was verified to **pass**
  in the new closure, so the layering can be locked positively rather than merely not broken.
- **Two findings the plan must act on before writing a docstring.** (1) `def:interval-site`,
  `def:behavior-presheaf` and `app:presheaf-dictionary` are all **unresolvable** against the live
  paper — `app:Structure` is commented out in full — so check **C15** will go red the moment a
  docstring cites them unless `KNOWN-ANCHORS` rows marked `DANGLING` are added **first**. (2)
  `schultz2020` and `johnstone1999` are absent from the root `references.bib`, so check **C31**
  will go red the moment a `## References` block cites them.
- **Recommended addition beyond the four deliverables (same files, ~15 lines, already proved):**
  state the presheaf action *indexed by a site morphism* (`restrictTr`, `restrictTr_id`,
  `restrictTr_comp`) and the Germs clause as an `Equiv` (`germEquiv : Beh F 0 ≃ F.WorldState`).
  This is what makes "`Beh(F)` is a presheaf on `Int(D)`" a statement in the library rather than
  two unconnected clusters, and it is the surface tasks 564–567, 617 and 618 will consume.
- **Baseline recorded**: `lake build FormalSystem` exit 0, 2807 jobs, run today through
  `lake-build-guard.sh`.

## Context & Scope

Researched: how to site the behavior presheaf `Beh(F)` and the interval site `Int(D)` in the
library, at the four deliverables the dispatch names, under the repository's live gate surface.

Constraints honoured:
- No `sorry`, no new axiom, no deferral. The zero-debt policy is satisfiable here: every
  deliverable is now compiled sorry-free (probe 03).
- `glue_seam` is **excluded**: task 564 owns `Presheaf/Sheaf.lean` and that clause. It was carried
  through the port anyway (probe 01) because 564's description relies on it existing, and it needs
  the same four deltas; that is reported for 564's benefit, not implemented here.
- `BD+`, the factorization category and `lem:interval-twisted-arrow` are **excluded** (task 616,
  `Presheaf/Duration.lean`), per the dispatch's 2026-10-02 scope correction.
- Declared `file_scope`: `FormalSystem/Semantics/Presheaf.lean`, `Presheaf/Site.lean`,
  `Presheaf/Behavior.lean`, `Presheaf/README.md`. Everything recommended below fits inside it
  except the three gate-prerequisite edits called out explicitly in **Risks & Mitigations**.

## Literature Proof Structure

**Source**: `def:interval-site` and `def:behavior-presheaf`, `app:Structure` ("Topological and
Categorical Structure"), `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`.
**Strategy**: definitional transcription — both anchors are `Ddef` environments, so there is no
proof to follow; the proof content lives in `app:presheaf-dictionary`, which this task does not own.

**STATE OF THE SOURCE — stronger than the dispatch says.** The dispatch warns that `app:Structure`
carries a `% TODO: review in full` marker. That marker is **no longer in the paper**. What is there
instead is more consequential: `app:Structure` is **commented out in its entirety**, under an
explicit editorial record reading

> `% SECTION CUT: "Topological and Categorical Structure" (app:Structure) in full.`
> `%        Everything sheaf- and category-theoretic goes: def:interval-site, def:behavior-presheaf,`
> `%        def:twisted-arrow, lem:interval-twisted-arrow, app:presheaf-dictionary, def:conduche,`
> `%        def:path-category, cor:path-fibration.`

and the surviving in-block marker is a bare `% CHECK` directly under the `\label{app:Structure}`.
The paper body's own conclusion paragraph that previewed this material is likewise commented out
(`% Convex histories in a task frame $\F$ are recast in …`). The honest module-docstring flag is
therefore **"cut from the paper, unreviewed, tracked here against the record"** — not "carries a
TODO". The two live, uncommented sentences nearest this material are in the paper body: the
`app:gluing` theorem is restored and uncommented, and the body now asserts that
"`\ref{app:gluing}` is not yet among" the formalized results — which is exactly the gap task 564
closes.

### Step Map (definitional, in the paper's order)

`def:interval-site`, seven items:
1. *Duration Monoid* `BD⁺` — **task 616**, excluded here.
2. *Interval* `[p, q] := {z ∈ D : p ≤ z ≤ q}` — `Presheaf.Interval`.
3. *Interval Category* `Int(D)`: objects the durations `ℓ ∈ D⁺`; morphisms `Tr p : ℓ' → ℓ` the
   translations by `p ∈ D⁺` with `p + ℓ' ≤ ℓ`; composition `Tr p ∘ Tr p' := Tr (p + p')`;
   identities `Tr 0` — `Presheaf.Obj`, `Presheaf.Tr`, `Tr.id`, `Tr.comp`, `Tr.id_comp`,
   `Tr.comp_id`, `Tr.comp_assoc`, `Tr.ext`.
4. *Presheaf*: a functor `Int(D)ᵒᵖ → Set`; `X(0)`'s elements are *germs*; `Lres` and `Rres` are
   restriction along `Tr 0` and `Tr (ℓ - ℓ')` — `Presheaf.lres`, `Presheaf.rres`.
5. *Johnstone Coverage*: for `ℓ ∈ D⁺` and `p ∈ [0, ℓ]`, the pair `Tr 0 : p → ℓ` and
   `Tr p : ℓ - p → ℓ` — `Presheaf.coverLeft` / `coverRight` (probe 02).
6. *Sheaf*: the two-section gluing statement — **task 564**, excluded here; `Int(D)`'s side of it
   (that the only equal-composite pair into `ℓ` is the germ restrictions) is the content of
   probe 02's `cover_germ_composites`, which is the *statement's* site-side justification and is
   cheap to carry.
7. (no seventh item; the enumeration is six plus the *Duration Monoid*.)

`def:behavior-presheaf`, four items:
1. *Behavior Presheaf* `Beh(F)(ℓ)` = the convex histories with domain `[0, ℓ]`, restriction along
   `Tr p` sending `τ` to `z ↦ τ(p + z)` — `Presheaf.Beh`, `Beh.restrict`, `Beh.restrictTr`.
2. *Reflection* `τ^r(z) := τ(ℓ - z)` — **task 617**, excluded.
3. *Converse Frame* `F⁻` — **task 617**, excluded (the convention already exists as
   `FrameOver.reflection`).
4. *Reflection Automorphism* — **task 617**, excluded.

### Dependencies

- Item 3 of `def:interval-site` depends on item 2 only notionally (the interval is the *meaning*
  of a translation, not an input to it); the Lean `Tr` structure needs neither.
- Items 4 and 5 depend on item 3.
- `def:behavior-presheaf` item 1 depends on `def:interval-site` items 3 and 4 for its *indexing*,
  and on `PartialHistory` for its *sections*. This is the one genuine cross-file dependency:
  `Behavior.lean` must import `Site.lean`.

### Potential Formalization Challenges

- **`Int(D)` as a Lean category: a decision the plan must make and task 616 asked to own.** Task
  616's description says the `Mathlib.CategoryTheory`-vs-concrete decision "should be made once,
  here, and written into the module docstring with its reasoning — not made implicitly by whichever
  task gets there first." But 616 *depends on* 563 for `Int(D)`, so 563 reaches the decision first
  by construction. See **Decisions** below for the resolution; the live tree imports **zero**
  CategoryTheory (`grep -rl CategoryTheory FormalSystem/` returns nothing; the one archived user is
  `Boneyard/RetiredTactics/AesopRuleSet.lean`).
- **`Int(D)` is a thin category up to the shift datum.** `Tr.le_of_hom` shows a morphism
  `ℓ' → ℓ` exists only when `ℓ' ≤ ℓ`, but `Tr` is *not* a `Prop`: distinct shifts give distinct
  morphisms (`Tr.ext` says the shift is the whole datum). Encoding `Int(D)` as a preorder would
  lose exactly the information the presheaf action reads.
- **No `PartialHistory.ext`.** Confirmed by `#check @PartialHistory.ext` → unknown constant. The
  `states` field is dependent on `domain`, so Lean's `@[ext]` derivation does not fire; the
  `@[ext]` at `PartialHistory.lean:461` is `WorldHistory.ext`, a `Subtype.ext` wrapper and not
  usable here.
- **Not a challenge, worth recording**: the domain-side goals all discharge by `Iff.rfl`/`rfl`
  because `Beh`'s membership condition is stated as an `Iff` with the *definitional* interval
  predicate. Changing `Beh`'s field to `τ.val.domain = Interval 0 l` (an equality rather than a
  pointwise `Iff`) would break those `rfl`s. Keep the `Iff` form and expose the equality as the
  derived `Beh.domain_eq_interval`.

## Findings

### Codebase Patterns

**The port deltas, each verified by compilation**

| Probe 04 (task 553) | Live tree | Why |
|---|---|---|
| `ConvexHistory F` (5 fields incl. `convex`) | `PartialHistory F` (4 fields) | `0688a7a3c` "Re-base history layer on PartialHistory, delete ConvexHistory". `PartialHistory.lean`'s own docstring now records "There is deliberately no `ConvexHistory` structure." |
| three `convex := by …` field proofs | **deleted**; `Beh.isConvex` derives convexity in 3 lines | an interval domain is convex, so the field was redundant for this subfamily |
| `ShiftSet.wh_ext` | `Presheaf.partialHistory_ext`, stated locally | `60d65a1d3` "retarget semantics over WorldHistory" removed it; its own docstring had already recorded that consolidating it into `PartialHistory.lean` was "a clean follow-up" |
| `ConvexHistory.states_eq_of_time_eq` | `PartialHistory.states_eq_of_time_eq` (`PartialHistory.lean:268`) | same lemma, rehomed |
| `F.nullity_identity` with no instance | `F.nullity_identity` needs `[F.IsRegular]` (`TaskFrame.lean:2665`) | the four frame axioms moved from `FrameOver` fields into the `IsRegular` class |
| `F.comp` with no instance | `F.comp` needs `[F.IsRegular]` (`TaskFrame.lean:2669`) | same |
| `import FormalSystem.Semantics.ShiftSet` + `Mathlib.Algebra.Order.Group.Int` | `import FormalSystem.Init` + `FormalSystem.Semantics.PartialHistory` | `ShiftSet` was imported only for `wh_ext`; the Mathlib Int import was verified unnecessary (recompiled with it stripped, exit 0) |

**The §5.1 dictionary of the task-553 report is itself stale.** Three of the paths it cites no
longer exist: `Semantics/StarPasting.lean` → `FormalSystem/PlusLanguage/PlusPasting.lean`,
`Semantics/StarDeterminism.lean` → `FormalSystem/StarLanguage/StarDeterminism.lean`,
`Semantics/ConvexHistory.lean` → deleted (its `timeShift` is now `PartialHistory.timeShift`, and
`ts_zero`/`ts_add` are in `Semantics/ShiftSet.lean:324,329`). Consequence for *this* task: the
dictionary's claim that `ts_zero`/`ts_add` "are literally `Tr 0 = id` and `Tr p ∘ Tr p' = Tr (p+p')`,
proved" is **true only for `WorldHistory`** (total histories) on the live tree. `restrict_id` /
`restrict_comp` at `Beh` are therefore genuinely new content, not a restatement — the dictionary
over-credited the tree on this row.

**Layering, confirmed positively.** `PartialHistory.lean` imports only
`FormalSystem.Semantics.TaskFrame`; `ShiftSet.lean` imports `Truth`, `TruthTransport` and
`Extension.Extension`. Building the cluster on `PartialHistory` rather than `ShiftSet` is what puts
it *below* `Truth.lean`, and `assert_not_exists FormalSystem.ProofSystem.Axiom
FormalSystem.ProofSystem.DerivationTree` was verified to pass at the end of probe 03. Note the
`assert_not_exists` in `Truth.lean:156` was never actually at risk — nothing imports the new
cluster into `Truth.lean` — so adding the assertion to the new modules is a *lock*, not a repair.
Precedent for the idiom: `TaskFrame.lean:270`, `FrameProperty.lean:107`, `TruthTransport.lean:44`.

**Namespace.** Use `FormalSystem.Semantics.Presheaf`, on the `Semantics/Ultraproduct/` precedent
(`namespace FormalSystem.Semantics.Ultraproduct`) rather than the flat
`namespace FormalSystem.Semantics` that `Extension/` and `Frames/` use. The nested form is the
right one here because `Interval`, `Tr`, `Obj`, `restrict` and `germ` are generic names, and
`restrict` in particular would shadow-collide with `PartialHistory.restrict` at the flat level.
Verified: probe 03 compiles in the nested namespace with no collision.

**Gate surface the implementation must satisfy** (all from `scripts/check-module-invariants.sh`
unless noted):

| Check | Obligation for this task |
|---|---|
| C8 | `FormalSystem/Semantics/Presheaf.lean` must exist beside `Presheaf/`, and `Presheaf/Presheaf.lean` must not. Already in `file_scope`. |
| C15 (first assertion) | every `def:`/`app:` anchor cited must have a MANIFEST or KNOWN-ANCHORS row in `docs/reference/paper-definitions-of-record.md`. **Three anchors are unrecorded or unresolvable — see Risks.** |
| C15 (second assertion) | only applies to `docs/theorem-index.md` rows. **Recommendation: add no rows.** That ledger carries C2/C14-axiom-pinned flagship results; a row would pull these declarations into an axiom baseline for no gain. |
| C24 | every module transitively imports `FormalSystem.Init`. Satisfied by `import FormalSystem.Init` in each new `.lean`, which probe 03 already does. (The dispatch paraphrases C24 as "every module stays in the root closure"; the actual assertion is the `Init` import. The root-closure property is C33's.) |
| C31 | every `[key]` in a `## References` block resolves in root `references.bib`. **`schultz2020`/`johnstone1999` are missing — see Risks.** |
| C33 | root `FormalSystem.lean` must be byte-for-byte `lake exe mk_all --lib FormalSystem`. **Regenerate it after adding files.** |
| C34a/C34b | both enforced. C34b fires on a `[F.IsRegular]`-binder declaration whose own `/--` block names a constraint (`Compositionality`/`Seriality`/`Limit`/`Saturation`, or `Serial`/`Compositional`/`Saturated`) *and* a negation or consumption word. See **Risks** for the safe pattern. |
| C26 | no non-trailing underscore in a `def`/`abbrev` **name**. Structure *fields* are read from source as fields, not `def`s, so `shift_nonneg`/`shift_add_le` are fine (precedent: `PartialHistory.nonempty_domain`, `respects_task`). All probe-03 `def` names are camelCase. |
| C9 | zero task-number citations under `FormalSystem/`. The module docstrings must cite tasks by nothing — name the paper anchors and the record file instead. |
| `scripts/readme-lint.sh` check 1 (**gated**) | every directory containing `.lean` files has a `README.md`. `Presheaf/README.md` is therefore **mandatory**, not optional. Check 3 (gated) additionally requires every relative link in it to resolve. |

**Docstring tier.** `docs/reference/docstring-standard.md`: `Site.lean` and `Behavior.lean` are
definition-bearing with a recorded design decision, i.e. **Tier 3** — Title + scope paragraph,
`## Main Definitions`, `## Main Results`, `## Implementation Notes`, `## References`, in that
order. `Presheaf.lean` is a re-export aggregator, **Tier 1**.

### External Resources

- `def:interval-site` and `def:behavior-presheaf`: quoted in full above; both inside the cut
  `app:Structure` block of `possible_worlds.tex`.
- `[P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020]`
  — Applied Categorical Structures 28 (2020), 1–57, doi `10.1007/s10485-019-09565-x`. The paper
  cites Defs. 3.1.1–3.1.2, Notation 3.1.7 and Defs. 3.2.1–3.2.2 for the interval site, and
  Def. 3.2.1 §3.2 for the behavior presheaf.
- `[P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999]` — Theory and
  Applications of Categories 5 (1999), no. 1, 1–11. Cited for the Johnstone coverage (and, in
  `app:Structure`, Prop. 3.6).
- Both bibliographic records were read from the paper's own `possible_worlds.bib`, which is how
  they can be added to the repository `references.bib` without inventing an entry — the
  REFERENCE_NORMAL_FORM prohibition on invented entries is thereby respected.

### Recommendations

**A sorry-free path exists and is already compiled.** Lift probe 03 into two modules. The split:

`FormalSystem/Semantics/Presheaf/Site.lean` — imports `FormalSystem.Init`,
`FormalSystem.Semantics.TemporalOrder`. Stated over `{D : TemporalOrder}`, no task frame:
`Interval`, `Obj`, `Tr` (+ `Tr.ext`), `Tr.id`, `Tr.comp`, `Tr.comp_shift`, `Tr.id_shift`,
`Tr.id_comp`, `Tr.comp_id`, `Tr.comp_assoc`, `Tr.le_of_hom`, `lres`, `rres`, and (cheap, and the
site-side content of `def:interval-site`'s *Sheaf* item) `coverLeft`, `coverRight`,
`cover_germ_composites`.

`FormalSystem/Semantics/Presheaf/Behavior.lean` — imports `FormalSystem.Init`,
`FormalSystem.Semantics.PartialHistory`, `FormalSystem.Semantics.Presheaf.Site`:
`partialHistory_ext`, `Beh`, `Beh.mem_dom`, `Beh.isConvex`, `Beh.domain_eq_interval`,
`Beh.restrict`, `Beh.restrict_domain`, `Beh.restrict_states`, `Beh.ext`, `Beh.restrict_id`,
`Beh.restrict_comp`, `Beh.restrictTr`, `Beh.restrictTr_id`, `Beh.restrictTr_comp`, `Beh.germ`,
`Beh.ofGerm`, `Beh.germ_ofGerm`, `Beh.ofGerm_germ`, `Beh.germEquiv`. End both files with
`assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`.

`FormalSystem/Semantics/Presheaf.lean` — Tier-1 aggregator importing the two.

**The one addition worth arguing for.** The dispatch's four deliverables, taken literally, give
`restrict` indexed by *raw data* (`p`, `l'`, and three order proofs). `restrictTr`, indexed by a
morphism `f : Tr l' l` of the site, is what makes `Beh(F)` a presheaf *on `Int(D)`* rather than a
family with two coincidence lemmas, and `restrictTr_id` / `restrictTr_comp` are then one-line
corollaries of `restrict_id` / `restrict_comp` (verified, probe 03 lines 168–182). It costs ~15
lines inside `file_scope` and it is the API every downstream task in the cluster (564, 565, 566,
567, 617, 618) actually needs. Same argument for `germEquiv : Beh F 0 ≃ F.WorldState`: the
dispatch asks for "the Germs clause `Beh(F)(0) iso W`", and `germ_ofGerm` + `ofGerm_germ` are its
two halves, not the isomorphism itself.

**Phasing.** The natural decomposition, each phase one agent run and ending green:
1. Gate prerequisites (no Lean): the two `references.bib` entries, the three KNOWN-ANCHORS rows.
   Must land **before** any docstring cites them, or C15/C31 go red mid-task.
2. `Site.lean` + `Presheaf.lean` + regenerate root + `Presheaf/README.md`.
3. `Behavior.lean` + aggregator import + regenerate root; README update.
4. Full gate pass (`lake build FormalSystem`, `check-module-invariants.sh`, `readme-lint.sh`).

**Hand-offs to record for the cluster** (not work for this task):
- Task 564's description says the Sheaf assembly uses `ShiftSet.wh_ext`. It no longer exists; 564
  should use `Presheaf.partialHistory_ext`. 564 also cites
  `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean`; the live path is
  `FormalSystem/PlusLanguage/PlusPasting.lean`, and `paste_rel_le_lt` there now carries
  `[F.IsRegular]`.
- Task 567 cites `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean`; the live
  determinism module is `FormalSystem/StarLanguage/StarDeterminism.lean`.
- Task 566 cites `FrameOver.mem_HF_iff_adjacent` in `Semantics/IntTransfer.lean`; the §5.1
  dictionary places it in `Semantics/IntNormalForm.lean`. Worth resolving at 566's plan time.
- Task 616's own named input,
  `/home/benjamin/Philosophy/Papers/PossibleWorlds/specs/111_verify_interval_twisted_arrow_lemma/reports/01_verify-twisted-arrow-lemma.md`,
  **does not exist on disk**. 616 should not be dispatched on the assumption that it does.

## Decisions

1. **`Beh F l` is a subtype of `PartialHistory F`, and convexity is derived, not carried.**
   `{ τ : PartialHistory F // ∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l) }`. This is forced by the tree
   (no `ConvexHistory` exists) and is also the better definition: `PartialHistory.lean`'s
   docstring records that convexity is deliberately a predicate, and `Beh.isConvex` recovers it.
   The membership condition stays a pointwise `Iff` so that the domain-side goals remain `rfl`.
2. **`Int(D)` is stated as concrete Lean structures, with no `Mathlib.CategoryTheory` dependency.**
   Reasoning to put in `Site.lean`'s docstring: the live tree imports no category theory at all,
   `def:interval-site`'s content is three composition laws plus a coverage, the concrete route
   keeps the import surface flat and keeps `Site.lean` buildable from `TemporalOrder` alone, and
   nothing this task or tasks 564–567/617 deliver needs categorical vocabulary. This decision is
   **reversible without changing any definition**: `Tr.id`/`Tr.comp`/`Tr.id_comp`/`Tr.comp_id`/
   `Tr.comp_assoc` are exactly a `Category` instance's fields, so task 616 or 618 can add
   `instance : Category (Obj D)` later if `fact:conduche-equivalence` needs it. Task 616 asked to
   own this decision; it cannot, since it depends on `Int(D)`. The plan should say so in the
   docstring and 616's plan should reconcile rather than re-litigate.
3. **Namespace `FormalSystem.Semantics.Presheaf`** (nested), on the `Ultraproduct/` precedent, to
   keep `Interval`/`Tr`/`restrict`/`germ` out of the `Semantics` namespace.
4. **`partialHistory_ext` lives in the Presheaf cluster, not in `PartialHistory.lean`.** Two
   independent reasons: `PartialHistory.lean` is outside this task's `file_scope`, and task 565
   carries a hard constraint to leave `PartialHistory` untouched. Record the consolidation as a
   deliberate deferral in the docstring (the deleted `wh_ext` already called it a clean follow-up).
5. **No `docs/theorem-index.md` rows.** That ledger is the C2/C14-pinned flagship set; adding
   presheaf rows would require axiom pinning for no benefit and widens C15's second assertion.
6. **Do not implement `glue_seam`** even though it is verified to port (probe 01). Task 564 owns
   `Presheaf/Sheaf.lean` and would contend for it.
7. **Flag the paper's state honestly in the module docstring**: `app:Structure` is cut in full and
   carries a bare `% CHECK`, the anchors resolve against
   `docs/reference/paper-definitions-of-record.md` and not against a live `\label{}`, and the
   material is unreviewed by the author. This replaces the dispatch's weaker "carries a
   `% TODO: review in full` marker" wording, which no longer matches the source.

## Risks & Mitigations

| Risk | Evidence | Mitigation |
|---|---|---|
| **C15 goes red the moment a docstring cites the anchors.** `def:interval-site` and `def:behavior-presheaf` are "deliberately NOT pinned" per `paper-definitions-of-record.md` (the twelve-anchor block at line ~630), and `app:presheaf-dictionary` has **no row at all** — neither MANIFEST nor KNOWN-ANCHORS. All three are also **unresolvable**: `check-paper-definitions.sh --resolve 'def:interval-site\|env\|-\|-'` returns "could not resolve", because every resolver filters LaTeX comment lines and the whole appendix is commented out. | Add three `KNOWN-ANCHORS` rows with status **`DANGLING`** (the record's own definition of that status explicitly covers "it was commented out"), each noting that `app:Structure` was cut in full, and cite them at every site with that fact stated — the record requires "every in-tree citation of one of these must say so at the citation site". Do this in phase 1, before any docstring. **Do not attempt to pin them**: `--resolve` cannot produce text for a commented-out anchor. |
| **C31 goes red the moment a `## References` block cites the sources.** `grep Schultz\|Johnstone references.bib` returns nothing. | Add `@article{schultz2020,…}` and `@article{johnstone1999,…}` to the root `references.bib`, transcribed from the paper's `possible_worlds.bib` (details in **External Resources**; no entry is invented). Lowercase keys match the tree's convention and REFERENCE_NORMAL_FORM's documented key shape. |
| **C34a trap.** A `Constraints consumed:` line that omits a constraint must be *discharged* by one of three narrow routes. `ofGerm` honestly consumes only `Seriality` + `Limit`, `glue_seam` only `Compositionality` — exactly the omitting shape C34a gates. | Simplest safe route: **write no `Constraints consumed:` marker**, and keep constraint discussion in the `/-!` **module** docstring, which C34b does not read (its span regex terminates at `^\s*/-!`). Then ensure no declaration's own `/--` block pairs a constraint name with a negation/consumption word. If the plan wants the marker, the only honest discharge is route 2 (a binder-free twin at an explicit `TaskFrame.Compositional`/nullity hypothesis with a byte-identical signature line) — ~10 extra lines, and defensible, but not required by anything. |
| **C33 fails if the root aggregator is not regenerated.** Three new `.lean` files. | Run `lake exe mk_all --lib FormalSystem` (or reproduce its output) after each phase that adds a file, and re-run `check-module-invariants.sh --no-build` to confirm C33. |
| **`readme-lint.sh` check 1 is gated.** Every `.lean`-bearing directory needs a `README.md`; all five existing `Semantics/` subdirectories have one. | `Presheaf/README.md` is in `file_scope`; treat it as a deliverable, not a nicety. Keep every relative link in it resolving (check 3 is also gated). |
| **Shared-touch collision on `FormalSystem/Semantics.lean`.** Convention is that `Semantics.lean` imports and documents each submodule, but it is **not** in this task's `file_scope`, and task 616's description warns explicitly that the cluster aggregator is a shared touch that the collision gate cannot see. | Nothing *gates* the `Semantics.lean` import (C8 needs only the sibling file; C24 is the `Init` import; the generated root already reaches the modules). **Recommendation: leave `Semantics.lean` alone in this task** and record the one-line import plus its Submodules bullet as an explicit follow-up, so the front's aggregator contention stays in one place. If the plan does take it, declare the `file_scope` widening up front. |
| **Stale inputs in the dispatch itself.** The probe path (`specs/553_…` → `specs/archive/553_…`), the probe's compile claim, the `% TODO: review in full` marker, and the C24 paraphrase are all out of date. | All four are corrected in this report. The implementation plan should cite **probe 03 in this task's own directory** as the source of record, not the archived task-553 probe. |
| **Foreign uncommitted modifications observed** (territory contract requires reporting). `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md` are modified in the working tree, outside this task's `file_scope` and outside sibling task 718's declared scope (`specs/718_…/`). | `git diff` shows they are benign "Last verified" date stamps advanced to 2026-10-02, plus a note that `check-paper-definitions.sh` reports drift on `def:BX` (`SU` renamed `US` upstream). Not a conflict with this task; **not reverted, not staged, left exactly as found**. Useful side-effect: that stamp independently records `lake build` clean and sorry-free and C1–C37 all-green as of today. |
| **Deployed `.claude/` tree is stale** for `core filetypes formal lean literature memory typst` (per the dispatch's deploy-freshness block). | Every command and convention relied on above was verified against the repository's own `scripts/` and `docs/` — not against a deployed extension file — except `long-builds.md`, which was read from the deployed copy only to obtain the `lake-build-guard.sh` invocation shape, and which worked (exit 0). |

## Tactic Survey Results

No tactic search was needed: every obligation discharged structurally on the first attempt, from
the ported proof terms. Recorded for completeness, as measured during the three probe compiles:

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `Beh`'s domain-side obligations (`restrict`, `ofGerm`, `restrict_domain`) | `Iff.rfl` / `rfl` | success | definitional, because `Beh`'s condition is a pointwise `Iff` against the same predicate |
| `restrict`'s `respects_task` | `rwa [add_sub_add_left_eq_sub]` | success | `PartialHistory.respects_task` at `p + s`, `p + t` |
| `Beh.isConvex` | `intro` + `le_trans` chain | success | `τ.property` in both directions |
| `restrict_id` / `restrict_comp` states-side | `rw [restrict_states …]` + `PartialHistory.states_eq_of_time_eq` | success | the dependent-transport lemma is required; `rw` on the time equality alone does not typecheck through the domain proof |
| `ofGerm`'s `respects_task` | `simpa [sub_self] using (F.nullity_identity w w).mpr rfl` | success | needs `[F.IsRegular]` |
| `glue_seam` | `rw [hsum]` + `(F.comp …).mpr` | success | needs `[F.IsRegular]`; `sub_add_sub_cancel` for the duration split |
| `Tr.comp`'s order obligation | `calc` with `add_le_add (le_refl _) _` | success | `add_le_add_left` does **not** fit — it rewrites on the right, and the goal needs the left slot fixed (observed as a type mismatch, probe 02 first run) |
| `Tr.id_comp` / `comp_id` / `comp_assoc` | `ext; simp` / `ext; simp [add_assoc]` | success | with `@[simp] comp_shift` and `@[simp] id_shift` |

## Context Extension Recommendations

- **Topic**: probe staleness across an archived task boundary.
  **Gap**: a task description that says "already proved, sorry-free, against the live tree" ages
  silently. Here the referenced probe had been invalidated by two intervening refactors
  (`ConvexHistory` deletion, `wh_ext` removal) and *moved* to `specs/archive/`, and the dispatch
  still asserted the compile claim as present tense.
  **Recommendation**: add to `context/project/lean4/patterns/` a short rule — *before planning
  from a cited probe, recompile it; a probe's compile claim is dated evidence, not a standing
  fact* — with the `lake env lean <probe>` one-liner and the instruction to re-point the plan at a
  freshly compiled probe in the current task's own directory.
- **Topic**: paper anchors inside commented-out LaTeX.
  **Gap**: `paper-definitions-of-record.md` already has the right status vocabulary (`DANGLING`
  covers "it was commented out"), but three rows in the live KNOWN-ANCHORS table —
  `def:task-topology`, `app:topology-t1`, `app:topology-r0` — read `LIVE-UNPINNED` while the
  paper's own SECTION CUT record says "the topology stays commented there". Those three rows look
  stale in the same way the anchors this task needs do. Out of scope here, worth a task.
  **Recommendation**: a `check-paper-definitions.sh` sub-mode that audits KNOWN-ANCHORS
  `LIVE-UNPINNED` rows for actual live resolvability, so a commented-out anchor cannot sit in the
  record as live.

## Appendix

### Commands of record

```bash
# the three probes, all exit 0, all sorry-free
lake env lean specs/563_formalize_interval_site_and_behavior_presheaf/probes/01_port-probe.lean
lake env lean specs/563_formalize_interval_site_and_behavior_presheaf/probes/02_site-probe.lean
lake env lean specs/563_formalize_interval_site_and_behavior_presheaf/probes/03_siting-rehearsal.lean

# baseline build, exit 0, 2807 jobs
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem

# the two anchors are unresolvable against the live paper
bash scripts/check-paper-definitions.sh --resolve 'def:interval-site|env|-|-'
bash scripts/check-paper-definitions.sh --resolve 'def:behavior-presheaf|env|-|-'

# no PartialHistory.ext is generated
echo 'import FormalSystem.Semantics.PartialHistory
open FormalSystem.Semantics
#check @PartialHistory.ext' > /tmp/x.lean && lake env lean /tmp/x.lean   # unknown constant

# the two deletions, by commit
git log --oneline -S "structure ConvexHistory" -- FormalSystem/   # 0688a7a3c, b9fd6f15c
git log --oneline -S "wh_ext" -- FormalSystem/                    # 60d65a1d3 and earlier
```

### Searches used

Codebase: `ConvexHistory`, `wh_ext`, `partialHistory_ext`, `assert_not_exists`,
`nullity_identity`, `class IsRegular`, `CategoryTheory`, `PositiveCone`, `ts_zero`/`ts_add`,
`paste_rel_le_lt`, `C8`/`C15`/`C24`/`C26`/`C31`/`C33`/`C34` in
`scripts/check-module-invariants.sh`, `Schultz`/`Johnstone` in `references.bib`.
Paper: `def:interval-site`, `def:behavior-presheaf`, `app:Structure`, `app:presheaf-dictionary`,
`lem:interval-twisted-arrow`, `app:gluing`, `TODO` in `possible_worlds.tex`; `Schultz2020`,
`Johnstone1999` in `possible_worlds.bib`.
No rate-limited Mathlib search tool was needed — every lemma used is either already in the tree
or a standard ordered-group lemma reached by name (`add_sub_add_left_eq_sub`, `sub_add_sub_cancel`,
`sub_add_cancel`, `add_sub_cancel`, `le_add_of_nonneg_left`, `sub_nonneg`).

### References

* JPL paper `def:interval-site` — the interval site `Int(D)`, its translations and the Johnstone
  coverage. **DANGLING**: `app:Structure` is commented out in full; resolves against
  `docs/reference/paper-definitions-of-record.md`, not a live `\label{}`.
* JPL paper `def:behavior-presheaf` — `Beh(F)(ℓ)` and its restriction along `Tr p`. **DANGLING**,
  same reason.
* JPL paper `app:presheaf-dictionary` — the seven clauses; this task delivers none of them, and
  the anchor has no row in the record yet. **DANGLING**, same reason.
* `[P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020]`,
  Defs. 3.1.1–3.1.2, Notation 3.1.7, Defs. 3.2.1–3.2.2 and §3.2 Def. 3.2.1
* `[P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999]`, §2 and Prop. 3.6
* `FormalSystem/Semantics/PartialHistory.lean` — the one history structure; `IsConvex` as a
  predicate, `states_eq_of_time_eq`, and the recorded decision against a `ConvexHistory` structure
* `FormalSystem/Semantics/TaskFrame.lean` — `TemporalOrder`-indexed frames, the `IsRegular`
  constraint bundle, `nullity_identity`, `comp`
* `FormalSystem/Semantics/TemporalOrder.lean` — `TemporalOrder`, its `CoeSort`, `PositiveCone`
* `docs/reference/paper-definitions-of-record.md` — the anchor record and the `DANGLING` status
* `docs/development/REFERENCE_NORMAL_FORM.md` — the `## References` normal form and the
  constraint-consumption line
* `docs/reference/docstring-standard.md` — the four docstring tiers and the section ordering
