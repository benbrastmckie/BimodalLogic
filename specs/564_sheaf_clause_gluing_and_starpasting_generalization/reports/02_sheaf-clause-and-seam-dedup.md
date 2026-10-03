# Research Report: Task #564

**Task**: 564 - Sheaf clause gluing and `paste` generalization
**Started**: 2026-10-03T18:10:38Z
**Completed**: 2026-10-03T19:05:00Z
**Effort**: ~1 hour (three compiled probes, no library edits)
**Dependencies**: 563 — **discharged**: `[COMPLETED]`, `FormalSystem/Semantics/Presheaf/{Site,Behavior}.lean` are on the tree
**Sources/Inputs**:
  - `FormalSystem/Semantics/Presheaf/Site.lean`, `FormalSystem/Semantics/Presheaf/Behavior.lean`, `FormalSystem/Semantics/Presheaf.lean`, `FormalSystem/Semantics/Presheaf/README.md`
  - `FormalSystem/Semantics/PartialHistory.lean`, `FormalSystem/Semantics/TaskFrame.lean`
  - `FormalSystem/PlusLanguage/PlusPasting.lean`
  - `specs/563_formalize_interval_site_and_behavior_presheaf/probes/01_port-probe.lean` (the live `glue_seam` port), `specs/563_.../reports/01_interval-site-behavior-presheaf.md`
  - `specs/564_.../reports/01_finite-vs-directed-gluing-findings.md`
  - `specs/718_omega_sequence_decidability_full_lplus/reports/01_gluing-route-seed.md` §§2.1, 6, 7 (read-only context; nothing re-derived)
  - `docs/development/REFERENCE_NORMAL_FORM.md` §§2–3, `docs/reference/paper-definitions-of-record.md`, `scripts/check-module-invariants.sh` (C20/C31/C33/C34/INV headers)
  - lean-lsp MCP: **not used**; all evidence is compiled (`lake env lean`) rather than LSP-queried. Evidence tier: **compiled probe**, the strongest tier available here.
**Artifacts**:
  - this report
  - `specs/564_.../probes/01_seam-lemma-and-glue.lean` (227 lines, sorry-free)
  - `specs/564_.../probes/02_site-and-compatible-family.lean` (69 lines, sorry-free)
  - `specs/564_.../probes/03_pasteat-off-totality.lean` (112 lines, sorry-free)
**Standards**: report-format.md, subagent-return.md, REFERENCE_NORMAL_FORM.md

## Executive Summary

- **The whole deliverable is already compiled.** Probe 01 proves, sorry-free against the live
  tree, the glued section, both restriction identities, uniqueness, and the `∃!` packaging of the
  *Sheaf* clause. Nothing in it is a sketch; the plan's job is siting and documentation, not
  discovery — the same posture task 563 took toward its own port probe.
- **State the clause in CUT form, not sum form.** Sections over `p` and `l - p` gluing to one over
  `l` (cut point `p ≤ l`) is the shape the coverage already has. Probe 02 shows
  `restrictTr (coverLeft …)` and `restrictTr (coverRight …)` are **definitionally** (`rfl`) the
  raw-data restrictions the clause is stated with, so the site-level statement costs nothing. The
  `l₁ + l₂` form needs a dependent transport along `l₁ + l₂ - l₁ = l₂` and buys nothing.
- **The de-duplication is one lemma, `rel_across_seam`, stated at `PartialHistory` with two
  independent seam coordinates.** Probe 01 derives *both* call sites from it with their signatures
  byte-unchanged: `PlusLanguage.paste_rel_le_lt` (total histories, seam at `t` on both sides) and
  the interval-site step (seam at `l₁` on the left, `0` on the right). The two coordinates are what
  absorb the interval site's shift; a one-coordinate lemma does not cover both.
- **"Sheaf is choice-free" is true but not for free, and it needs the right wording.** A naive
  transcription makes the clause depend on `Classical.choice` — through `TaskFrame.reflection`,
  whose zero case splits on `eq_or_ne d 0`. Routing the mixed-orientation case through the
  **off-zero** reflection law instead (`TaskFrame.reflect_reflection_of_ne`, which needs no
  constraint at all, and whose hypothesis `t - s ≠ 0` is available because the case is strict)
  brings `glue`, `rel_across_seam`, both restriction identities, uniqueness and `sheaf_clause` all
  to `[propext, Quot.sound]`. Verified by `#print axioms` in probe 01.
- **The literal reading of "generalize `paste` off its totality hypothesis" is also achievable,
  and verified.** Probe 03 compiles `pasteAt` on two *arbitrary* partial histories (choice-free),
  plus `isTotal_pasteAt` and `paste_eq_pasteAt`, which recover the existing `paste` as a corollary
  **without touching its definition or signature** — so the six pasting validities and the planned
  incompleteness result are untouched, as report 01's recommendation 2 requires.
- **Scope must widen; the plan cannot be executed inside the declared `file_scope`.** The declared
  scope is `FormalSystem/Semantics/Presheaf/Sheaf.lean` alone. The deliverable additionally
  requires `FormalSystem/PlusLanguage/PlusPasting.lean` (the de-duplication is not optional),
  `FormalSystem/Semantics/PartialHistory.lean` (the shared lemma's home), and four wiring files
  the gates make mandatory — see Findings §6.

## Context & Scope

Task 564 owns the *Sheaf* clause of the paper's presheaf dictionary and the de-duplication of the
seam-composition argument against `PlusLanguage/PlusPasting.lean`. Task 563 landed the site and
the presheaf; this round establishes exactly what remains, in compiled form, and enumerates the
wiring and gate obligations that adding one module to the `Presheaf/` cluster carries.

Three constraints framed the work. The zero-debt gate (green `lake build FormalSystem`, no new
`sorry`, at the end of every phase) means nothing may be deferred behind a placeholder — so every
claim below is a compiled one. The `--lit`-adjacent instruction to record which dictionary clauses
are choice-free means the choice-freedom claim had to be *measured*, not asserted. And the
aggregator-contention note means the shared touches had to be enumerated rather than discovered
mid-implementation.

**Baseline**: `lake build FormalSystem` is green on the current tree — 2810 jobs, exit 0, run
through `lake-build-guard.sh` at the start of this round. The library carries no `sorry`.

### Three stale references in the task description, corrected

1. **The probe path is archived.** `specs/553_decide_convex_history_layer_collapse/probes/04_presheaf-skeleton.lean`
   is now `specs/archive/553_.../probes/04_presheaf-skeleton.lean`, and `specs/archive/` is
   gitignored. Use **`specs/563_formalize_interval_site_and_behavior_presheaf/probes/01_port-probe.lean`**
   instead: it is task 563's port of that probe to the current tree (`ConvexHistory` is gone), it
   carries `glue_seam` at line 136, and its `Beh`/`restrict`/`mem_dom` block is line-for-line the
   landed `Presheaf/Behavior.lean`. This report's probe 01 supersedes even that.
2. **`ShiftSet.wh_ext` no longer exists.** The extensionality lemma the description says to apply
   is now `FormalSystem.Semantics.Presheaf.partialHistory_ext`
   (`Presheaf/Behavior.lean`), with `Beh.ext` as the subtype wrapper. Probe 01 uses
   `Beh.ext (partialHistory_ext …)` throughout.
3. **The namespace note is now stale in its turn.** The DEPENDENCY NOTE says `paste_rel_le_lt`
   lives in `FormalSystem.Semantics`; the later POST-RELOCATION NOTE corrects this to
   `FormalSystem.PlusLanguage` at `FormalSystem/PlusLanguage/PlusPasting.lean`. The later note is
   the accurate one — verified on the tree.

## Findings

### 1. Codebase patterns: what the landed cluster gives the clause

- **`Beh F l`** (`Presheaf/Behavior.lean`) is `{τ : PartialHistory F // ∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l)}`.
  The pointwise `Iff` is load-bearing, as that module's own Implementation Notes say: it is what
  makes a constructed section's `property` field discharge by `fun _ => Iff.rfl`. Probe 01's
  `glue` exploits this — its domain is written as the literal `fun z => 0 ≤ z ∧ z ≤ l` and its
  property field is `fun _ => Iff.rfl`. **Do not** build the glued section by composing
  `PartialHistory`-level pastes and then proving the domain *equal* to `Interval 0 l`; that
  discards the `Iff.rfl` discharge and buys nothing.
- **`PartialHistory.respects_task` is unconditional** — all pairs `(s, t)`, no `s ≤ t` guard. This
  is why the glued section's obligation has **four** cases rather than two, and why the
  mixed-orientation case (reading `τ₂` before `τ₁`, at a negative duration) is unavoidable. It is
  also why `reflection` enters at all, which is where the choice question lives (§4).
- **`PartialHistory.states_eq_of_time_eq`** is the only tool needed to move a state across
  `0 + r = r`, `p + 0 = p` and `p + r - p = r`. Every restriction identity in probe 01 is
  `Beh.restrict_states` followed by one `states_eq_of_time_eq` and one `dif_pos`/`dif_neg`.
- **`TaskFrame.forward_of_comp`** (`TaskFrame.lean:905`) is the composition half of
  *Compositionality* over a bare relation, at an **explicit** `Compositional R` hypothesis. It is
  what lets the seam lemma be stated with no bundling binder (§4).

### 2. The shared argument: `rel_across_seam`

Verified in probe 01, lines 24–36:

```lean
theorem rel_across_seam {F : TaskFrame} (hcomp : TaskFrame.Compositional F.TaskRel)
    {σ τ : PartialHistory F}
    {m m' : F.Duration} (hσm : σ.domain m) (hτm' : τ.domain m')
    (hmatch : σ.states m hσm = τ.states m' hτm')
    {s s' d : F.Duration} (hs : σ.domain s) (hs' : τ.domain s')
    (hsm : s ≤ m) (hm's' : m' ≤ s')
    (hd : d = (m - s) + (s' - m')) :
    F.TaskRel (σ.states s hs) d (τ.states s' hs')
```

Three design points, each load-bearing:

- **Two seam coordinates (`m` in `σ`, `m'` in `τ`), not one.** The total-history instance has
  `m = m' = t`; the interval-site instance has `m = l₁` (the right endpoint of `τ₁`) and `m' = 0`
  (the left endpoint of `τ₂`). A single-coordinate lemma covers only the first, and forcing the
  second through it would require `PartialHistory.timeShift`-ing `τ₂` into place — strictly more
  work than carrying a second coordinate.
- **The duration is an explicit parameter `d` with a splitting hypothesis**, not the literal
  `(m - s) + (s' - m')`. Each call site then supplies its own arithmetic identity in the `hd`
  slot, so the lemma's conclusion matches the goal without a post-hoc rewrite. The two identities
  are one line each: `sub_add_sub_cancel s' t s` for `paste`, and `sub_zero` plus
  `sub_add_sub_cancel t l₁ s` for the site.
- **No bundling binder.** `TaskFrame.Compositional F.TaskRel` is explicit, which is what makes
  the choice-freedom claim checkable and satisfies C34a (§6).

Both consumers are derived in probe 01 with **unchanged signatures**:

| Consumer | Probe 01 | Signature |
|---|---|---|
| `PlusLanguage.paste_rel_le_lt` | `paste_rel_le_lt'`, lines 40–46 | byte-identical to the live one, including `[F.IsRegular]`; passes `F.comp` |
| the interval-site step (`glue_seam`) | `glue_seam'`, lines 50–59 | byte-identical to 563's probe `glue_seam` |

The live `paste_rel_le_lt` body is 8 lines; as a delegation it is 4, and the argument then exists
once in the tree. **This is the de-duplication the task exists to produce.**

### 3. The Sheaf clause, in cut form

All of the following are compiled, sorry-free, in probe 01.

```lean
def glue (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration}
    (hp : 0 ≤ p) (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p … = τ₂.val.states 0 …) : Beh F l
```

- `domain := fun z => 0 ≤ z ∧ z ≤ l`, `property := fun _ => Iff.rfl`.
- `states` is a **dependent** `if hzp : z ≤ p` — `dite`, not `ite`, because each branch needs the
  domain witness. The reading equations `glue_states_le` / `glue_states_not_le` are then literally
  `dif_pos hzp` / `dif_neg hzp`, and every later proof goes through them rather than unfolding
  `glue`.
- The decidability of `z ≤ p` comes from the `LinearOrder` field of the temporal order, **not**
  from `Classical.propDecidable`: a bare `if z ≤ p` over an abstract `F.Duration` measures
  `[propext]` alone (probe measurement, §4).
- `respects_task` is a four-way `by_cases`: `τ₁`'s own law, the forward cross case
  (`rel_across_seam`), the mixed-orientation case (off-zero reflection, then `rel_across_seam`
  with the roles exchanged), and `τ₂`'s own law at `(s - p, t - p)` via
  `sub_sub_sub_cancel_right`. This mirrors `PlusPasting.paste_rel`'s own four-way split exactly,
  which is the structural evidence that the two really are one argument.

```lean
theorem restrict_glue_left  … : Beh.restrict 0 p le_rfl hp … (glue …) = τ₁
theorem restrict_glue_right … : Beh.restrict p (l - p) hp … (glue …) = τ₂
theorem glue_unique         … (υ : Beh F l) (hL : …= τ₁) (hR : …= τ₂) : υ = glue …
theorem sheaf_clause        … : ∃! υ : Beh F l, (restrict 0 p … υ = τ₁) ∧ (restrict p (l-p) … υ = τ₂)
```

Two mechanics worth carrying into the plan:

- **The right identity is where `hmatch` is consumed.** Restricting at offset `p` reads
  `glue.states (p + r)` for `r ∈ [0, l - p]`. The `dite` test `p + r ≤ p` is *true* at `r = 0`, so
  that one point lands in the `τ₁` branch and is reconciled to `τ₂.states 0` by `hmatch`. The
  `r = 0` step needs `r ≤ 0` from `p + r ≤ p`; take it choice-free as `sub_nonpos.mpr` plus
  `add_sub_cancel_left`, **not** `le_of_add_le_add_left`, which measures `Classical.choice` (§4).
- **Uniqueness needs a way to read states out of an equality of sections.** `Beh` equality is
  subtype equality over a structure with a *dependent* `states` field, so `congrArg` is awkward;
  the three-line `states_eq_of_eq` (`subst h; rfl`, resting on definitional proof irrelevance) is
  what probe 01 uses, and it is reusable.

### 4. The choice question, measured

`#print axioms`, run in probe 01 against the live tree:

| Declaration | Axioms |
|---|---|
| `taskRel_reflection_of_ne` | `[propext]` |
| `rel_across_seam` | `[propext, Quot.sound]` |
| `paste_rel_le_lt'` | `[propext, Quot.sound]` |
| `glue_seam'` | `[propext, Quot.sound]` |
| `glue` | `[propext, Quot.sound]` |
| `restrict_glue_left`, `restrict_glue_right`, `glue_unique` | `[propext, Quot.sound]` |
| `sheaf_clause` | `[propext, Quot.sound]` |
| `Beh.germEquiv` (landed, the *Germs* clause) | `[propext, Quot.sound]` |
| `PlusLanguage.paste` (landed) | `[propext, Classical.choice, Quot.sound]` |

**The single source of `Classical.choice` on this front is `TaskFrame.reflection`**, which
measures `[propext, Classical.choice, Quot.sound]`. Its proof (`reflection_of_limit`,
`TaskFrame.lean:1375`) opens with `rcases eq_or_ne d 0`, and `eq_or_ne` is classical excluded
middle. The off-zero half, `TaskFrame.reflect_reflection_of_ne`, is `[propext]` — the module's own
docstring already says so in words ("off zero the law is definitional content of
`TaskFrame.reflect` … and costs nothing at all"). The mixed-orientation case of both `glue` and
`paste_rel` is **strict** (`t ≤ p < s`), so `t - s ≠ 0` is in hand and the off-zero law suffices.

Two consequences:

- A four-line wrapper
  ```lean
  theorem TaskFrame.reflection_of_ne (F : TaskFrame) {w u : F.WorldState} {d : F.Duration}
      (hd : d ≠ 0) : F.TaskRel w d u ↔ F.TaskRel u (-d) w := TaskFrame.reflect_reflection_of_ne hd
  ```
  is needed because `rw` cannot see through `F.TaskRel` to the underlying `TaskFrame.reflect`
  pattern (probe-measured: the bare `rw [TaskFrame.reflect_reflection_of_ne …]` fails with
  "did not find an occurrence of the pattern"; applied as a term via a wrapper it succeeds). The
  wrapper carries **no** constraint binder at all.
- Routing `paste_rel`'s own mixed case through it makes **`paste` choice-free too** — a free
  side-benefit of the de-duplication, and the only thing standing between `paste_eq_pasteAt`
  (probe 03) and a clean axiom list.

**The docstring claim needs two sentences, not one.** The dispatch's "Sheaf is [choice-free]" is
sound in *both* available senses once the above lands, but they are different claims and the
module should distinguish them, because report 01 and the paper's own footnote are about the
first and `#print axioms` is about the second:

1. *Saturation-independence* — the binary seam gluing uses **Compositionality only**. The honest
   witness is the signature: state the clause at an explicit
   `(hcomp : TaskFrame.Compositional F.TaskRel)`, not at `[F.IsRegular]`, which bundles
   *Saturation* and so would make the claim unreadable from the binder. Directed gluing is the
   contrasting case and rests on *Saturation* through the Extension Theorem
   (`FormalSystem/Semantics/Extension.lean`, `app:gluing`'s footnote).
2. *Axiom-freedom* — `[propext, Quot.sound]`, no `Classical.choice`, as measured above.

### 5. The site-level clause, and the coverage's compatible-family condition

Probe 02 establishes two things the cut form makes cheap:

- `Beh.restrictTr (coverLeft l p hp hpl) υ = Beh.restrict 0 p le_rfl hp … υ` and
  `Beh.restrictTr (coverRight l p hp hpl) υ = Beh.restrict p (l.val - p) hp … υ` are both **`rfl`**.
  So a site-indexed `∃!` statement follows from the raw-data one definitionally — no transport,
  no cast. This is the whole reason to prefer the cut form: it is the shape `coverLeft`/
  `coverRight` already have (`Tr ⟨p, hp⟩ l` and `Tr ⟨l - p, _⟩ l`), whereas the `l₁ + l₂` form
  would need `Beh F (l₁ + l₂ - l₁) ≃ Beh F l₂` transported along `add_sub_cancel_left`.
- The coverage's **compatible-family condition** over the germ that `cover_germ_composites`
  identifies —
  `Beh.restrictTr (rres hp) τ₁ = Beh.restrictTr (lres _) τ₂` as elements of `Beh F 0` — is
  **equivalent** to the raw `hmatch` (`compat_iff_match`, probe 02). So the clause can be stated
  in the vocabulary of the site's own coverage and then reduced to the raw hypothesis the proof
  consumes. That closes the loop `Site.lean`'s `cover_germ_composites` docstring opens ("a
  compatible family is a pair of sections agreeing on a single germ"): it is now a theorem, not a
  remark.

A `Beh F l₂` → `Beh F (l₁ + l₂ - l₁)` transport, if a sum-form corollary is wanted anyway, is a
three-line `Beh.cast` along a duration equality (`⟨τ.val, by subst h; exact τ.property⟩`). Treat
it as optional.

### 6. Scope, wiring, and the gates that make each touch mandatory

The declared `file_scope` is `FormalSystem/Semantics/Presheaf/Sheaf.lean` alone. That is not
sufficient for this deliverable. The full set, with the reason each is unavoidable:

| Path | Why | Gate |
|---|---|---|
| `FormalSystem/Semantics/Presheaf/Sheaf.lean` | the clause (new, owned) | — |
| `FormalSystem/Semantics/PartialHistory.lean` | home of `rel_across_seam` (see below) | — |
| `FormalSystem/Semantics/TaskFrame.lean` | home of the `reflection_of_ne` wrapper (§4) | — |
| `FormalSystem/PlusLanguage/PlusPasting.lean` | `paste_rel_le_lt` → delegation; `paste_rel`'s mixed case → off-zero reflection; `pasteAt` + bridge | — |
| `FormalSystem.lean` | **regenerate**: `lake exe mk_all --lib FormalSystem` | **C33** (byte-exact) |
| `FormalSystem/Semantics/Presheaf.lean` | one `import` line + a `## Modules` bullet | **C24/C6** (root closure) |
| `FormalSystem/Semantics/Presheaf/README.md` | generated inventory row + hand-written Key Definitions/Results | **INV** (stale block fails) |
| `FormalSystem/README.md`, `README.md` | generated inventory/metrics blocks | **INV** |

Regeneration commands, not hand edits: `lake exe mk_all --lib FormalSystem` for `FormalSystem.lean`,
and `bash scripts/check-module-invariants.sh --emit-inventory` for every `<!-- BEGIN GENERATED:
inventory … -->` block (`scripts/readme-inventory.sh` is a deprecated shim that only prints this
advice).

**Where `rel_across_seam` should live: `FormalSystem/Semantics/PartialHistory.lean`.** It is a
statement about two partial histories and the task relation, and `PartialHistory.lean` already
houses `WorldHistory`, `respects_task_le` and `states_eq_of_time_eq`; it sits below both consumers
(`Presheaf/Behavior.lean` imports it directly; `PlusPasting` reaches it through
`PlusValidity → PlusTruth → Semantics.Truth`). The alternative — put it in `Sheaf.lean` and have
`PlusPasting` import `FormalSystem.Semantics.Presheaf.Sheaf` — is legal layering (Sheaf is lower)
but makes the core pasting validities depend on the peripheral presheaf-dictionary cluster, which
inverts the architecture `Site.lean`'s Implementation Notes are at pains to keep clean. Note also
that `Presheaf/Behavior.lean`'s own Implementation Notes already name `PartialHistory.lean` as the
natural home for history-level lemmas (the recorded `partialHistory_ext` consolidation); this
lemma goes where that note points. **Do not** also move `partialHistory_ext` down in this task —
that is 563's recorded follow-up and would churn `Behavior.lean` for no gain here.

**Aggregator contention is real and the description's instruction holds.** Do not widen
`file_scope` to include `FormalSystem/Semantics/Presheaf.lean`; make the one-line edit, re-read
the file immediately beforehand (task 727 has undeclared scope this cycle), and re-run
`lake build` after it. Concurrent siblings this cycle: 710 (plan; its scope includes
`docs/theorem-index.md` and `scripts/check-evidence-probes.sh`) and 727 (research, undeclared).
**Therefore do not touch `docs/theorem-index.md`** — 710 owns it, and nothing requires a row for
these declarations (C15 checks existing rows are anchored, not that every declaration has one).

**Citation and marker obligations** (`REFERENCE_NORMAL_FORM.md` §§2–3):

- `app:gluing` carries a **`LIVE-UNPINNED`** row in `docs/reference/paper-definitions-of-record.md`
  (line 2104), explicitly "Not pinned: no docstring quotes its text". Cite it as a pointer
  (`* JPL paper \`app:gluing\` — …`) and **do not** quote its text verbatim, which would make the
  row's own description false. `app:presheaf-dictionary` and `app:Structure` carry `DANGLING`
  rows; cite them exactly as `Site.lean`/`Behavior.lean` already do, recording the cut.
- Bibliographic keys `schultz2020` and `johnstone1999` resolve in the root `references.bib`
  (lines 830, 841) and are the right ones to reuse; C31 gates any key that does not resolve.
- **C34a's "fix pattern of record" is exactly the design recommended here** — and the standard
  names it in those words: "prove the claim at the explicit hypotheses the proof consumes, keep
  the binder-carrying original as a one-line corollary whose signature line is byte-identical so
  no call site moves" (18 live declarations already do this). So: mark the binder-free
  declarations `Constraints consumed: Compositionality` (and `None` for the reflection wrapper),
  and if an `[F.IsRegular]` corollary is added, give it the identical marker list and a
  byte-identical signature line. **C34b** only fires on bracketed-binder declarations, so the
  binder-free statements are out of its scope; its span regex terminates at `^\s*/-!`, so the
  module docstring's own constraint discussion is safe either way.

### 7. `paste` generalized off totality — verified, and droppable last

Probe 03 compiles, sorry-free:

- `pasteAt (hcomp) (σ τ : PartialHistory F) (t) (hσt hτt hmatch) : PartialHistory F`, with
  `domain := fun z => (z ≤ t ∧ σ.domain z) ∨ (¬ z ≤ t ∧ τ.domain z)`. Axioms:
  `[propext, Quot.sound]`. The `states` field splits on the decidable `z ≤ t` and then resolves
  the disjunction inside each branch (`hz.resolve_right (fun h => h.1 hzt) |>.2`), which is what
  keeps a `Prop`-valued `Or` from being eliminated into a `Type`.
- `isTotal_pasteAt` — at two total histories it is total.
- `paste_eq_pasteAt : paste ρ σ t hsame = ⟨pasteAt …, isTotal_pasteAt …⟩`, via
  `WorldHistory.ext_state` and the two reading lemmas. **`paste`'s definition and signature are
  untouched**, so `paste_agreeFrom`, `paste_agreeUpTo` and the six validities
  (`paste_valid`, `paste_valid'`, `future_dstab_valid`, `stab_allFuture_valid`,
  `untl_dstab_valid`, `snce_dstab_valid`) and their `*_plusValid` packagings do not move. This is
  report 01's recommendation 2, satisfied by construction rather than by care.

`paste_eq_pasteAt` currently measures `Classical.choice` **only** because it mentions the existing
`paste`; once `paste_rel`'s mixed case routes through the off-zero reflection, it clears.

## Decisions

1. **Cut form `(l, p)` over sum form `(l₁, l₂)`** for the primary clause, on the probe-02
   evidence that it lifts to the site by `rfl`. A sum-form corollary via `Beh.cast` is optional
   and should not get a phase of its own.
2. **`rel_across_seam` lands in `FormalSystem/Semantics/PartialHistory.lean`**, with two seam
   coordinates and an explicit duration-splitting hypothesis, at an explicit
   `TaskFrame.Compositional F.TaskRel`.
3. **No bundling binder on any new gluing declaration.** `[F.IsRegular]` appears only on
   signature-preserving corollaries (`paste_rel_le_lt`, and any `IsRegular` convenience wrapper),
   per C34a route 2.
4. **The de-duplication is interpreted as: the argument exists once, `paste` is touched, and
   `pasteAt` exists as the literal off-totality generalization.** Both readings of the
   description's wording are therefore satisfied, and neither requires redefining `paste`. This
   was the one genuine interpretive fork in the dispatch; it is resolved here rather than
   escalated, because probe 03 shows the stronger reading costs ~40 lines and carries no risk to
   `paste`'s consumers. If the planner must cut scope, cut §7 (`pasteAt` and the bridge) and keep
   §2 (`rel_across_seam` and the two delegations) — §2 alone discharges the stated harm
   ("should not be written twice"), §7 alone does not.
5. **Do not touch `docs/theorem-index.md`** this cycle (task 710 owns it), and **do not** widen
   `file_scope` to the `Presheaf.lean` aggregator (per the description's own instruction).
6. **No `user_decision` is set.** Every fork above was resolvable from the artifacts plus a
   compiled probe; none turns on a preference the artifacts cannot infer or on an external cost.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| The docstring overclaims "choice-free" while `glue` still routes through `TaskFrame.reflection` | Make the off-zero reflection wrapper and its two call sites part of the **same** phase as `glue`, not a follow-on; re-measure with `#print axioms` before writing the docstring sentence. The honest fallback wording, if the wrapper is dropped, is the *Saturation*-independence claim alone (§4, sense 1) — it is still true and still worth recording. |
| The docstring overclaims by citing probe results as library facts | Cite only `app:gluing`'s footnote and `Semantics/Extension.lean` for the directed case, exactly as report 01's risk note already directs. The `#print axioms` rows are about declarations that will be *in* the library, so those are quotable. |
| Aggregator edit clobbered by a concurrent sibling | Re-read `FormalSystem/Semantics/Presheaf.lean` immediately before editing, stage only this task's hunks (never a directory or glob `git add`), re-run `lake build` after. 727's scope is undeclared this cycle. |
| `FormalSystem.lean` hand-edited and C33 fails byte-comparison | Always regenerate with `lake exe mk_all --lib FormalSystem`; never add the import by hand. |
| A README inventory block left stale, failing INV | Run `bash scripts/check-module-invariants.sh --emit-inventory` after adding the module, and commit the rewritten blocks in `Presheaf/README.md`, `FormalSystem/README.md` and `README.md`. |
| A `Constraints consumed:` marker written over a bundling binder, failing C34a | Keep the binder-free form primary. If a marker is written on an `[F.IsRegular]` corollary, it must delegate to a binder-free twin with the *identical* list and a byte-identical signature line. The safest route remains the one 563's report identified: write no marker at all and keep constraint discussion in the `/-!` module block. |
| A quoted `app:gluing` text turning the `LIVE-UNPINNED` record row false | Cite as a pointer only; do not quote. |
| Phase overruns the one-agent-run budget | The natural split is four phases, each independently green: (A) `reflection_of_ne` + `rel_across_seam` + `PlusPasting` delegation; (B) `Sheaf.lean` with `glue`, the reading lemmas, both restriction identities, uniqueness, `∃!`; (C) the site-level corollary + `compat_iff_match` + docstring/References/README/aggregator/`FormalSystem.lean` wiring; (D) `pasteAt` + `isTotal_pasteAt` + `paste_eq_pasteAt`. Probes 01–03 are the transcription source for A/B/D and C respectively, so each phase is transcription plus siting, not discovery. |
| `lake build` cost at each phase end | The baseline build is fully cached (2810 jobs, ~8s). Editing `PartialHistory.lean` or `TaskFrame.lean` invalidates a large transitive closure, so phase A's build is the expensive one — run it detached through `lake-build-guard.sh build --timeout 1800 -- build FormalSystem`, never in the foreground. |

## Tactic Survey Results

Measured by compiling candidate proofs (`lake env lean`) rather than by `lean_multi_attempt`:
the obligations here are structural rather than closable by a search tactic, so the useful
question was which *lemma* discharges each step, not which automation does.

| Goal | Tactic / lemma | Result | Notes |
|---|---|---|---|
| seam composition at a duration split | `TaskFrame.forward_of_comp hcomp` + `sub_add_sub_cancel` | success | choice-free; the one shared step |
| mixed-orientation task relation (negative duration) | `TaskFrame.reflect_reflection_of_ne` via a wrapper, then `neg_sub` | success | `[propext]`; `rw` needs the wrapper, the bare lemma's pattern does not match `F.TaskRel` |
| same, via the general law | `F.reflection` | success | pulls in `Classical.choice` — reject |
| `τ₂`'s own law at shifted times | `sub_sub_sub_cancel_right` | success | `(t - p) - (s - p) = t - s` |
| reading the glued states | `dif_pos` / `dif_neg` | success | reading equations are the `dite` lemmas verbatim |
| section equality | `Beh.ext (partialHistory_ext …)` | success | `ShiftSet.wh_ext` no longer exists |
| moving a state across a time identity | `PartialHistory.states_eq_of_time_eq` | success | used at `0 + r = r`, `p + 0 = p`, `p + r - p = r` |
| reading states out of a section equality | `by subst h; rfl` | success | definitional proof irrelevance |
| `r ≤ 0` from `p + r ≤ p` | `sub_nonpos.mpr` + `add_sub_cancel_left` | success | choice-free |
| same | `le_of_add_le_add_left` | success | pulls in `Classical.choice` — reject |
| `p + r - p = r` | `ring` | **unavailable** | `ring` is not in this import closure; use `add_sub_cancel_left` |
| `r ≤ 0` arithmetic | `linarith` | **unavailable** | not in this import closure; `TaskFrame.lean`'s own notes record the same constraint |
| site/raw restriction agreement | `rfl` | success | both `coverLeft` and `coverRight` |
| germ compatibility ↔ raw `hmatch` | `simp only [Beh.restrictTr, rres, lres]` then `Beh.restrict_states` | success | `restrictTr` must be unfolded first or `rw` cannot see the pattern |

`simp`, `omega`, `decide`, `aesop` and `norm_num` were not applicable to any obligation above:
every one is an equality of dependent structures or a frame-relation composition, not an
arithmetic or decidable goal.

## Context Extension Recommendations

- **Topic**: `Classical.choice` leakage through `TaskFrame.reflection`.
  **Gap**: nothing in `.claude/context/project/lean4/` records that the general reflection law is
  classical while its off-zero half is not, nor that `eq_or_ne` is the leak. Any future "this
  result is choice-free" claim in this repository will hit the same wall.
  **Recommendation**: a short note under `context/project/lean4/patterns/` — "measuring axiom
  dependence in this tree" — pairing the `#print axioms` recipe with the two measured traps found
  here (`TaskFrame.reflection`'s `eq_or_ne`, and `le_of_add_le_add_left`), and the standing
  observation that `[propext, Classical.choice, Quot.sound]` is the repository's *normal* baseline
  so a choice-freedom claim must be measured rather than assumed.
- **Topic**: the shared-touch checklist for adding one module to a `Semantics/` cluster.
  **Gap**: §6's table was reconstructed by reading `check-module-invariants.sh` headers and
  `REFERENCE_NORMAL_FORM.md`. It is the same eight-path set every module-adding task on this front
  will need, and 563 rediscovered it independently.
  **Recommendation**: a `context/project/lean4/operations/` note listing the four wiring files,
  their gates (C33, C24/C6, INV), and the two regeneration commands.
- **Topic**: `ring`/`linarith` unavailability in the `Semantics/` import closure.
  **Gap**: `TaskFrame.lean` records it in one declaration's docstring ("`linarith` is not
  available in this module's import closure … do not 'simplify' this to `linarith` at review
  time"); it is not recorded anywhere an agent would look before writing a proof.
  **Recommendation**: one line in the Lean rules or the mcp-tools guide.

## Appendix

### Probes, and what each one holds

| Probe | Lines | Content | Axioms |
|---|---|---|---|
| `probes/01_seam-lemma-and-glue.lean` | 227 | `taskRel_reflection_of_ne`; `rel_across_seam`; `paste_rel_le_lt'` and `glue_seam'` as its two consumers at unchanged signatures; `glue`; `glue_states_le/_not_le`; `restrict_glue_left/_right`; `states_eq_of_eq`; `glue_unique`; `sheaf_clause` (`∃!`); eleven `#print axioms` rows | all new declarations `[propext, Quot.sound]` or `[propext]` |
| `probes/02_site-and-compatible-family.lean` | 69 | `restrictTr (coverLeft …) = restrict 0 p …` and `restrictTr (coverRight …) = restrict p (l-p) …`, both `rfl`; `compat_iff_match` | — |
| `probes/03_pasteat-off-totality.lean` | 112 | `pasteAt` (arbitrary partial histories); `pasteAt_states_le/_not_le`; `isTotal_pasteAt`; `paste_eq_pasteAt` | `pasteAt` `[propext, Quot.sound]`; the bridge inherits `Classical.choice` from the existing `paste` |

All three compile with `lake env lean <path>`, exit 0, no `sorry`. They live under `specs/564_…/probes/`,
which `/todo` will archive with the task; nothing outside this report cites their paths, and the
clause itself lands in the library, so no `specs/evidence/` registration is needed.

### Reproduction commands

```bash
lake env lean specs/564_sheaf_clause_gluing_and_starpasting_generalization/probes/01_seam-lemma-and-glue.lean
lake env lean specs/564_sheaf_clause_gluing_and_starpasting_generalization/probes/02_site-and-compatible-family.lean
lake env lean specs/564_sheaf_clause_gluing_and_starpasting_generalization/probes/03_pasteat-off-totality.lean
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem   # detached
```

### References consulted

- `FormalSystem/Semantics/Presheaf/Site.lean` — `Obj`, `Tr`, `lres`, `rres`, `coverLeft`,
  `coverRight`, `cover_germ_composites`
- `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, `mem_dom`, `restrict`,
  `restrict_states`, `restrictTr`, `partialHistory_ext`, `germEquiv`
- `FormalSystem/Semantics/PartialHistory.lean:136` — `PartialHistory`; `:225` `IsTotal`;
  `:268` `states_eq_of_time_eq`; `:423` `WorldHistory`; `:489` `WorldHistory.ofTotal`
- `FormalSystem/Semantics/TaskFrame.lean:357` — `reflect_reflection_of_ne`; `:805` `Compositional`;
  `:905` `forward_of_comp`; `:1375` `reflection_of_limit`; `:2727` `TaskFrame.forward_comp`
- `FormalSystem/PlusLanguage/PlusPasting.lean:85` — `paste_rel_le_lt`; `:99` `paste_rel`;
  `:111` `paste`
- `docs/development/REFERENCE_NORMAL_FORM.md` §2 (the three `## References` forms), §3 (the
  constraint-consumption line and C34's three discharges)
- `docs/reference/paper-definitions-of-record.md:2104` (`app:gluing`, `LIVE-UNPINNED`),
  `:2120` (`app:presheaf-dictionary`, `DANGLING`), `:2132` (`def:interval-site`, `DANGLING`)
- `scripts/check-module-invariants.sh` headers for C20, C24, C31, C33, C34a/b, and the
  `--emit-inventory` contract
- `specs/718_omega_sequence_decidability_full_lplus/reports/01_gluing-route-seed.md` §§2.1, 6, 7
