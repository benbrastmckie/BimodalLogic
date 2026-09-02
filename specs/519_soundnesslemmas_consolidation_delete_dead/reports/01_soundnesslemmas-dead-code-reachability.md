# SoundnessLemmas Consolidation — Reachability Audit and Phase Map

**Task**: 519 (WAVE 1, deletion)
**Date**: 2026-09-02
**Baseline commit**: `f35c16401` (task 517: complete implementation)
**Scope declared**: `FormalSystem/Metalogic/SoundnessLemmas/`, `SoundnessLemmas.lean`,
`Soundness.lean`, `SoundnessLemmas/README.md`

---

## 0. Tree state and concurrency check

`git status` at the time of this audit shows **no foreign modification inside `FormalSystem/`**.
The only dirty paths are task bookkeeping (`specs/TODO.md`, `specs/state.json`,
`specs/events.jsonl`) plus an untracked `.tmp-lit-verify-112/`. No foreign commits landed on
`FormalSystem/Metalogic/SoundnessLemmas/` or `Soundness.lean` after the review date — the newest
commit touching them is `ba33a7be6` (task 508 phase 5), which predates the review.

**No `lake build` is running.** `ps` shows only a `lake serve` language server (PID 3027458) with
six `lean --worker` processes it spawned — that is the lean-lsp MCP backend, not a build. One of
those workers holds `DenseValidity.lean` open. This does not block the task, but an implementer
should expect the LSP's view of the file to go stale after large deletions and should restart it
(`lean_build`) rather than trusting hover/goal output mid-edit.

**Build artifacts are fresh**: `.olean` files for `Soundness`, `DenseValidity`,
`FrameClassVariants` and `Decidable` are all newer than their sources, so the tree is at a green
baseline and an incremental `lake build` after edits will be much cheaper than a cold one.

**`sorry` baseline**: zero structural `sorry` in the entire scope. The four `grep` hits in
`Soundness.lean` (`:113`, `:988`, `:1558`, `:1639`) are all prose sentences asserting
sorry-freeness. C3 stays green as long as nothing new is introduced.

---

## 1. Verification of the measured state

### 1.1 Confirmed as stated

| Claim in task description | Verified |
|---|---|
| `SoundnessLemmas/` totals 2,487 lines | **Yes** — 107 + 141 + 1296 + 591 + 352 = 2,487 |
| `axiom_locally_valid` at `:970`, private, zero references | **Yes** — `occ=1` (own `theorem` line only) |
| `swap_axiom_{t4,ta,tl}_valid` at `:98`, `:115`, `:143` | **Yes** — all three `occ=1` |
| Four `*_preserves_swap_valid` at `:228`–`:279` | **Yes** — all four `occ=1` |
| `axiom_density_valid` at `:960`, dead | **Yes** — `occ=1` |
| Three `*_preserves_*` at `:1268`–`:1297` | **Yes** — `mp_preserves_valid` `:1268`, `necessitation_preserves_local_valid` `:1277`, `temporal_necessitation_preserves_local_valid` `:1287`, all `occ=1` |
| Four live survivors at `:875`, `:907`, `:940`, `:950` | **Yes** — each has a live consumer at `FrameClassVariants.lean:310`/`312`/`314`/`316` |
| `axiom_swap_valid` at `DenseValidity.lean:297` | **Yes** — body spans `:297`–`:716` (420 lines including the closing arm) |
| `axiom_swap_valid_general` at `FrameClassVariants.lean:46` | **Yes** — body spans `:46`–`:398` (353 lines) |
| `Soundness.lean:1337,1341` reach into the Dense dispatcher for exactly two arms | **Yes** — `density` and `dense_indicator`, and those are its only two live consumers |
| `Core.lean:42`'s `IsValid D` | **Yes** |
| `.toFibre` + `(D := F.Duration)` shims at `Soundness.lean:913-935` and `:1326-1356` | **Yes** — five sites: `:917`, `:924`, `:932`, `:1333`, `:1337`, `:1341`, `:1345`, `:1348`, `:1351` |
| `exists_isGLB_of_lub` duplicated at `Soundness.lean:1000` / `Separability.lean:48` | **Yes**, both `private`, and the `Separability` copy carries the apologetic docstring |
| `Separability` omitted from the aggregator (A-10) | **Yes** — `SoundnessLemmas.lean` imports only CoValidity, Core, DenseValidity, FrameClassVariants |
| Supersession docstring at `DenseValidity.lean:215-217` | **Yes** |

### 1.2 Discrepancies — report these rather than the description's numbers

1. **`DenseValidity.lean` is 1,296 lines, not 1,297.** Cosmetic; the review's `615 of 1,297`
   figure is off by one line. My own measurement of the eight named dead ranges sums to **~636
   lines** (72 + 69 + 158 + 10 + 298 + 29), so the "615" figure is if anything an undercount.

2. **The `:717-874` block holds fourteen `axiom_*_valid` helpers, not eleven.** Full list:
   `axiom_prop_k_valid` `:717`, `axiom_prop_s_valid` `:725`, `axiom_modal_t_valid` `:733`,
   `axiom_modal_4_valid` `:741`, `axiom_modal_b_valid` `:749`, `axiom_modal_5_collapse_valid`
   `:758`, `axiom_ex_falso_valid` `:770`, `axiom_peirce_valid` `:779`,
   `axiom_modal_k_dist_valid` `:794`, `axiom_temp_k_dist_valid` `:802` (private),
   `axiom_temp_4_valid` `:810` (private), `axiom_temp_a_valid` `:818` (private),
   `axiom_temp_l_valid` `:831` (private), `axiom_modal_future_valid` `:855`. Plus the
   `and_of_not_imp_not` copy at `:826`. The four private ones are *already* `occ=1` — nothing
   consumes them, not even the dead dispatcher — so they are dead independently of
   `axiom_locally_valid`.

3. **`DenseValidity.lean:280` is named `and_extract`, not `and_of_not_imp_not`.** So the "defined
   five times" claim is right about the *statement* being copied five times, but there are only
   **four distinct names**: `and_of_not_imp_not` (`Soundness.lean:153`, `DenseValidity.lean:826`,
   `CoValidity.lean:61`), `and_extract` (`DenseValidity.lean:280`), and `and_of_not_imp_not'`
   (`Decidable.lean:2563`). `and_extract` is `occ=1` — dead — so it disappears with the
   `:228-296` range and never needed consolidation.

4. **The two dispatchers share 323 identical lines, not 321.** Measured with a
   `diff --unchanged-group-format` on `DenseValidity.lean:297-716` (420 lines) against
   `FrameClassVariants.lean:46-398` (353 lines). Two lines of drift since the review; the finding
   stands.

5. **`exists_isGLB_of_lub` has a *third* copy**, at
   `Decidability/Verified/Decidable.lean:2569` under the name `exists_isGLB_of_lub'`. The task
   description names only two. See §4.3 — this affects the "un-private and delete the copy"
   sub-task's reach.

### 1.3 Dead declarations the description does not name

These all satisfy the acceptance criterion "zero declarations in the directory with only their own
occurrence in the tree", so an implementer must handle them or the gate fails.

| Declaration | Site | Status |
|---|---|---|
| `valid_at_triple` | `Core.lean:56` | `occ=1` — **already dead today**. Named in review A-01 but omitted from the task description's "eight dead ranges". |
| `truth_at_swap_swap` | `Core.lean:67` | `occ=2`, and the second occurrence is the module docstring at `:15`. **Already dead today.** Also A-01. |
| `and_extract` | `DenseValidity.lean:280` | `occ=1` — already dead (see §1.2 item 3). |
| `swap_axiom_F_until_equiv_valid` | `DenseValidity.lean:170` | `occ=2`; its only consumer is `axiom_swap_valid:606`. **Becomes dead the moment `axiom_swap_valid` is deleted.** Not named anywhere in the task description. |
| `swap_axiom_P_since_equiv_valid` | `DenseValidity.lean:180` | Same — only consumer is `axiom_swap_valid:607`. **Becomes dead.** |

The last two matter for phase ordering: they are *live today* and *dead after Phase B*, so a
dead-code sweep run before the dispatcher deletion will not find them.

---

## 2. Reachability ledger

Method: for every declaration in `SoundnessLemmas/`, count `\bname\b` occurrences across
`FormalSystem/` and `Tests/` (`.lean` only, Boneyard included in the sweep by directory but no
hits). `occ=1` means the only occurrence is its own `theorem` line. Where `occ>1` I inspected each
site to distinguish a real use from a docstring mention, and then closed transitively.

### 2.1 `DenseValidity.lean` (1,296 lines) — final disposition

| Range | Contents | Disposition |
|---|---|---|
| `:1-49` | header, imports, namespace, `variable` | delete with the file |
| `:50-97` | `swap_axiom_mt_valid`, `swap_axiom_m4_valid`, `swap_axiom_mb_valid` | **LIVE** — consumed at `FrameClassVariants.lean:60,61,62`. **MOVE** |
| `:98-169` | `swap_axiom_t4_valid`, `swap_axiom_ta_valid`, `swap_axiom_tl_valid` | DEAD — delete |
| `:170-198` | `swap_axiom_F_until_equiv_valid`, `swap_axiom_P_since_equiv_valid` | live only via `axiom_swap_valid` → **DEAD after Phase B** — delete |
| `:199-214` | `swap_axiom_mf_valid` | **LIVE** — `FrameClassVariants.lean:319`. **MOVE** |
| `:215-296` | section docstring, four `*_preserves_swap_valid`, `and_extract` | DEAD — delete |
| `:297-716` | `axiom_swap_valid` (420 lines) | live for 2 arms only → replaced by two lemmas in `Soundness.lean`. **DELETE** |
| `:717-874` | fourteen `axiom_*_valid` helpers + a fourth `and_of_not_imp_not` | DEAD (10 transitively via `axiom_locally_valid`; 4 privates already `occ=1`) — delete |
| `:875-959` | `axiom_temp_linearity_valid`, `axiom_temp_linearity_past_valid`, `axiom_F_until_equiv_valid`, `axiom_P_since_equiv_valid` | **LIVE** — `FrameClassVariants.lean:310,312,314,316`. **MOVE** |
| `:960-969` | `axiom_density_valid` | DEAD — delete |
| `:970-1267` | `axiom_locally_valid` (298 lines, private, zero refs) | DEAD — delete |
| `:1268-1296` | three `*_preserves_*` lemmas | DEAD — delete |

**Consequence**: exactly **eight declarations** survive from `DenseValidity.lean`
(`swap_axiom_mt_valid`, `swap_axiom_m4_valid`, `swap_axiom_mb_valid`, `swap_axiom_mf_valid`,
`axiom_temp_linearity_valid`, `axiom_temp_linearity_past_valid`, `axiom_F_until_equiv_valid`,
`axiom_P_since_equiv_valid`), and every one of them is consumed *only* by
`FrameClassVariants.lean`. Once they move, **`DenseValidity.lean` can be deleted outright** —
which is what review A-01 recommends and which the task description implies but never states.
This is the recommended endpoint; it also removes the file from every import path in one step
rather than leaving a ~150-line rump module.

### 2.2 `Core.lean` (107 lines)

All three declarations go. `valid_at_triple` and `truth_at_swap_swap` are already dead
(§1.3). `IsValid` has **six live consumers** after the DenseValidity sweep:

- `FrameClassVariants.lean:48` (`axiom_swap_valid_general`)
- `FrameClassVariants.lean:402, 442, 481, 543` (`prior_UZ_is_valid`, `prior_SZ_is_valid`,
  `z1_is_valid`, `z1_past_is_valid`)
- **`Decidability/Verified/Decidable.lean:2413`** (`truthAt_of_isValid`) — see §4.1

### 2.3 The other three files

`CoValidity.lean` (141): `co_valid` is live (cross-referenced from `ProofSystem/Axioms.lean:401`,
`Theorems/DedekindDerived.lean:368`, `Syntax/Formula.lean:500`), `always_elim` is used internally,
`and_of_not_imp_not` is a local copy. **No deletions.** But it imports `Core` — that import must be
retargeted when `Core.lean` goes.

`Separability.lean` (352): every declaration is live. `exists_isGLB_of_lub`, `exists_half_le`,
`arch_of_lub`, `exists_null_seq` are private internals; `exists_countable_order_dense`,
`nested_core`, `sep_order`, `sep_order_mirror` are consumed by both `Soundness.lean` and
`Decidable.lean`. **No deletions.**

`FrameClassVariants.lean` (591): all five theorems live. `z1_past_is_valid` is consumed only at
`Soundness.lean:1351` (the `z1` swap arm) — one consumer, but a real one.

---

## 3. Dependency order and phase map

The hard ordering constraints, derived from the ledger:

```
A. Delete the already-dead ranges in DenseValidity.lean + Core.lean's two dead lemmas
   |  (no dependency; shrinks everything downstream)
   v
B. Replace axiom_swap_valid's two live arms with density_swap_valid /
   dense_indicator_swap_valid in Soundness.lean, then delete axiom_swap_valid
   |  MUST come after A only for convenience; MUST come before C because it is
   |  what kills swap_axiom_{F_until,P_since}_equiv_valid
   v
C. Move DenseValidity's eight survivors into FrameClassVariants.lean, delete
   swap_axiom_{F_until,P_since}_equiv_valid, delete DenseValidity.lean
   |  MUST come after B (B is what makes those two dead and what removes the
   |  only other reason DenseValidity.lean exists)
   v
D. One-line the surviving 45-arm dispatcher (extract per-constructor lemmas)
   |  MUST come after C — extracting into a file that is about to receive eight
   |  transplants and then be renumbered is churn
   v
E. IsValid -> ValidIn/ValidDiscrete restatement; delete IsValid and Core.lean;
   retarget Decidable.lean:2413; retarget CoValidity's Core import
   |  MUST come last among the code phases: it rewrites the signature of every
   |  lemma D just created, so doing E before D doubles the work
   v
F. exists_isGLB_of_lub un-private + Soundness copy deletion (INDEPENDENT — can
   run any time, or in parallel; touches only Soundness.lean:1000 and
   Separability.lean:48)
   and_of_not_imp_not consolidation (see §4.3 — recommend DEFERRING)
   v
G. Aggregator import + docstring contents list (A-10 partial); regenerate
   SoundnessLemmas/README.md; C6 manifest check
```

Suggested phase sizing, one agent run each:

| Phase | Work | Est. delta | Risk |
|---|---|---|---|
| 1 | Ranges A — pure deletion in `DenseValidity.lean` (`:98-169`, `:215-296`, `:717-874`, `:960-1296`) and `Core.lean` (`:50-105`) | −694 | **Low** — no live consumer anywhere; one build confirms |
| 2 | B — write `density_swap_valid` + `dense_indicator_swap_valid` beside `sep_swap_valid`; repoint `axiom_swap_validIn_min:1336-1342`; delete `axiom_swap_valid` | −420 in SL, +~25 in Soundness | **Low-Med** — proof bodies lift verbatim from the deleted arms |
| 3 | C — transplant eight survivors to `FrameClassVariants.lean`, add the two Mathlib imports, delete `DenseValidity.lean` and its import line | net ~0, one file gone | **Low** |
| 4 | D — one-line the ~29 inlined arms of `axiom_swap_valid_general`, dropping no-op `simp only` per D-09 | +60 to +90 (signatures) | **Medium** — see §4.2 |
| 5 | E — restate five theorems at `ValidIn .Base` / `ValidDiscrete`, delete `IsValid`/`Core.lean`, retarget `Decidable.lean` and `CoValidity.lean` | −107, −~20 shim lines in Soundness | **High** — see §4.1 |
| 6 | F + G — `exists_isGLB_of_lub`, aggregator, README, invariants | −10 | **Low** |

Phases 1–3 are strictly mechanical and could be merged into two runs if the implementer is
confident; phases 4 and 5 should each stand alone.

---

## 4. Risk analysis

### 4.1 HIGHEST RISK — `IsValid` → `ValidIn` and the out-of-scope `Decidable.lean` edit

**The declared file scope for this task is insufficient.** `IsValid` has a live consumer at
`FormalSystem/Metalogic/Decidability/Verified/Decidable.lean:2413`:

```lean
theorem truthAt_of_isValid {F : FrameOver (TemporalOrder.of D)} {M : TaskModel F}
    {φ : Formula} (h : SoundnessLemmas.IsValid (TemporalOrder.of D) φ)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : D) : TruthAt M τ t φ :=
  h F M τ hτ t
```

used at `:2449`, `:2482`, `:2532` by `ruleSound_priorUZ`, `ruleSound_priorSZ`, `ruleSound_z1Rule`.
Deleting `IsValid` without retargeting this lemma breaks the build. Review A-08 anticipates this
("Keep the `Decidable.lean:2413` landing lemma, retargeted"), but the task description's file
scope does not list the file. **The plan must widen scope to include
`FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`, or Phase 5 must be split out into
its own task.** Recommend widening — splitting would leave `IsValid` alive and the acceptance
criterion unmet.

The retarget itself is small: `truthAt_of_isValid` becomes a wrapper over `ValidDiscrete.apply`
(`Validity.lean:628`), whose signature already binds the four instances instance-implicitly.

**The defeq hazard.** `ValidDiscrete.of_forall`'s own docstring (`Validity.lean:610-617`) warns
that `SuccOrder`/`PredOrder` are *data*, so the existential in `FrameClass.Discrete.Sat` must be
destructured with `obtain` and the witnesses applied **positionally with `@`**, never installed
with `haveI` — routing them through the instance cache breaks definitional equality against
instances already fixed in the types of `F` and `M`. `ruleSound_priorUZ` at `Decidable.lean:2422`
independently makes the same point ("`letI`, not `haveI`, for the two DATA instances"). Any
restatement of `prior_UZ_is_valid` / `prior_SZ_is_valid` / `z1_is_valid` / `z1_past_is_valid` at
`ValidDiscrete` walks straight into this. Mitigation: the existing wrappers at
`Soundness.lean:913-935` already perform exactly this transformation successfully — the
restatement is literally *inlining those wrappers into the lemma statements*, so copy their
`refine ValidDiscrete.of_forall ?_ ; intro F _ _ _ _ M τ h_mem t` opening verbatim rather than
inventing one.

**What makes the restatement sound.** `TaskFrame` is `⟨Duration : TemporalOrder, toFibre :
FrameOver Duration⟩` (`TaskFrame.lean:1613`) and structure eta gives `⟨G.Duration, G.toFibre⟩ = G`,
`(F.toTaskFrame).toFibre = F`, `(F.toTaskFrame).Duration = D` all by `rfl`
(`TaskFrame.lean:35-37`). So `∀ D, IsValid D φ` and `ValidIn .Base φ` are the same statement
modulo eta, and `ValidIn.of_forall_total` (`Validity.lean:494`) / `ValidIn.apply_total` (`:501`)
are the exact intro/elim pair to use for the `.Base` case. `ValidDiscrete.of_forall` / `.apply`
are the pair for the discrete four.

**Import consequence**: `FrameClassVariants.lean` must gain `import FormalSystem.Semantics.Validity`
(its sibling `CoValidity.lean:8` already has it, so no cycle is introduced). `CoValidity.lean`
currently imports `SoundnessLemmas.Core`; when `Core.lean` is deleted that import must be replaced
with whatever `Core` was transitively giving it — `FormalSystem.Semantics.Truth`,
`FormalSystem.ProofSystem.Derivation`, `FormalSystem.ProofSystem.Axioms` (`Core.lean:7-9`). In
practice `Semantics.Truth` is the only one `CoValidity` needs; check by build.

### 4.2 MEDIUM RISK — the 45-arm dispatcher rewrite

`axiom_swap_valid_general` (`FrameClassVariants.lean:46-398`) currently has, of its 45 arms:

- **4 one-line delegating arms**: `modal_t`, `modal_4`, `modal_b` (→ `swap_axiom_m{t,4,b}_valid`),
  `modal_future` (→ `swap_axiom_mf_valid`)
- **4 two-line delegating arms**: `temp_linearity`, `temp_linearity_past`, `F_until_equiv`,
  `P_since_equiv` — these delegate to the *local-validity* survivors at swapped arguments
  (`exact axiom_temp_linearity_past_valid φ.swapTemporal ψ.swapTemporal`), exploiting that the
  swap of temp-linearity *is* temp-linearity-past. Do not "extract a `_swap_valid` lemma" for
  these — the existing shape is already the right one and creating a wrapper would be pure noise.
- **8 `absurd h_fc` arms** for the non-Base constructors (`density`, `dense_indicator`,
  `prior_UZ`, `prior_SZ`, `z1`, `prior_U_gap`, `prior_S_gap`, `sep`) — already one-line
- **~29 fully inlined arms**, the largest being `linear_until` (29 lines, `:234-262`) and
  `linear_since` (32 lines, `:263-294`)

Only those ~29 need extraction. Two cautions:

1. **Extraction is line-*additive*, not subtractive.** Each extracted lemma adds a signature line,
   a `:= by` and (per project convention) a docstring — call it +3 lines each, so +~90. The
   acceptance target of ~1,400 lines still holds comfortably (see §5), but a planner should not
   budget this phase as a shrink.

2. **D-09 is narrower than the description implies.** The review validated that
   `simp only [Formula.swapTemporal, TruthAt]` is a no-op *for purely-propositional cases only*,
   because `TruthAt … (φ.imp ψ)` is definitionally an arrow (`Truth.imp_iff` is `rfl`,
   `Truth.lean:192`). Its own recommendation says: *"Keep it where the case genuinely needs
   `Truth.future_iff`/`past_iff` to expose a quantifier."* The validated sites are `prop_k`,
   `prop_s`, `ex_falso`, `modal_k_dist` (`FrameClassVariants.lean:51,56,71,90`). Arms such as
   `until_F`/`since_P` (`:298`, `:305`) call `simp only [Formula.swap_temporal_some_future, …]`
   followed by `simp only [TruthAt, Truth.some_past_iff]` — those are load-bearing. Blanket
   deletion of every `simp only [Formula.swapTemporal, TruthAt]` line will break the build; the
   plan should say "drop where the next tactic is `intro`/`exact` and the goal is propositional",
   and lean on the build to catch overreach.

3. Note also that "one-line arm" and "no `simp only` anywhere" are different goals. Once every
   arm reads `exact prop_k_swap_valid ψ χ ρ`, the `simp only` lines have *moved into* the
   extracted lemmas, not vanished. Task 522 is the pass that actually reduces
   `simp only [TruthAt` counts; this task should only remove the ones D-09 proved redundant.

### 4.3 LOW RISK, but a scope trap — `and_of_not_imp_not`

Recommendation: **keep this out of task 519's critical path.** The description says "keep ONE
and_of_not_imp_not (it mostly disappears once task 521 lands `Truth.and_iff`)", and `Truth.and_iff`
does not exist yet — I confirmed no `and_iff` in `Semantics/Truth.lean`. After phase 1 deletes the
`DenseValidity.lean:826` and `:280` copies, **three** copies remain: `Soundness.lean:153` (8 uses),
`CoValidity.lean:61` (2 uses), `Decidable.lean:2563` as `and_of_not_imp_not'` (3 uses). Genuinely
consolidating those three requires a common ancestor module, and there isn't a clean one:

- `Separability.lean` is imported by both `Soundness.lean` and `Decidable.lean` and has no
  formula/truth dependencies — it is the natural home for the *order* helper.
- But `CoValidity.lean` does **not** import `Separability`, and making it do so drags in Mathlib's
  Archimedean and `Set.Countable` machinery for a five-line propositional lemma.

Deleting the two DenseValidity copies satisfies the letter of "keep ONE *in the directory*"
(CoValidity's would be the only one left under `SoundnessLemmas/`). Doing more is a
cross-directory refactor better handled once `Truth.and_iff` exists. State this as an explicit
deferral in the plan.

`exists_isGLB_of_lub` (A-09) is genuinely trivial and independent: drop `private` at
`Separability.lean:48`, delete `Soundness.lean:1000-1028`, and the one consumer at
`Soundness.lean:1095` resolves through the existing `import ...SoundnessLemmas.Separability`
(`Soundness.lean:11`). **Do not** also try to eliminate `Decidable.lean:2569`'s
`exists_isGLB_of_lub'` — `Decidable.lean` already imports `Separability` (`:11`), so it *is*
removable, but it is out of scope and out of the acceptance criteria. Mention it, leave it.

### 4.4 What could move the C2 axiom baseline — assessment: nothing, if done as specified

C2 pins `#print axioms` for `BXCanonical.completeness`, `completeness_dense`,
`completeness_discrete`, `Chronicle.countermodel_dense`; C14(ii) pins
`Decidability.sound_of_isValid`, `completeness_dedekind`, `strongCompletenessBase`,
`strongCompletenessDense`. Every operation in this task is either a deletion of an unreferenced
declaration, a verbatim transplant, or a restatement of an existing theorem at a definitionally
equal proposition. None of those can introduce a new axiom **provided**:

- No arm is discharged with `sorry`, `native_decide`, or a new `axiom` declaration. The zero-debt
  policy applies: if an extracted lemma will not close, the plan must decompose it, not stub it.
- The `ValidDiscrete.of_forall` restatement does not reach for `Classical.choice` where the
  original did not. It won't — `ValidDiscrete.of_forall` is itself already in the axiom closure of
  `Decidability.sound_of_isValid` via the current shims.
- `Decidable.lean`'s `truthAt_of_isValid` retarget preserves the proof term. It is currently
  `h F M τ hτ t`; via `ValidDiscrete.apply` it becomes `h F ⟨so,po,hsa,hpa⟩ M ⟨τ,hτ⟩ t`, which
  adds no axiom.

**The one real hazard**: C14(ii) covers `Decidability.sound_of_isValid`, which is downstream of
`truthAt_of_isValid`. Phase 5 is the only phase that can perturb it, and that is another reason
to run Phase 5 last and alone, with `check-module-invariants.sh` (full, not `--no-build`)
immediately after.

### 4.5 Invariant-script obligations

`scripts/check-module-invariants.sh` runs 17 checks. The ones this task can break:

- **C4** (every `import FormalSystem.*` resolves): deleting `Core.lean` and `DenseValidity.lean`
  orphans four import lines — `SoundnessLemmas.lean:8,9`, `CoValidity.lean:7`,
  `FrameClassVariants.lean:7`. All four must be edited in the same commit.
- **C6** (known-unreachable live modules manifest): `scripts/module-invariants-manifest.txt` lists
  `FormalSystem.Metalogic.SoundnessLemmas` (line 34, the aggregator) and
  `FormalSystem.Metalogic.SoundnessLemmas.CoValidity` (line 50). **C6 fails if an entry names a
  module that no longer exists** — neither `Core` nor `DenseValidity` is listed, so no manifest
  edit is required for their deletion. Adding `import ...Separability` to the aggregator does
  **not** change Separability's reachability (`Soundness.lean:11` already imports it directly), so
  no manifest edit there either. Verify anyway: C6 compiles the manifested aggregator in
  isolation, and the aggregator will now import Separability.
- **C5 / C12 / C13** (markdown module paths and links resolve): `SoundnessLemmas/README.md` names
  `Core.lean` and `DenseValidity.lean` in its module table. Regenerating it (with
  `scripts/readme-inventory.sh`, which emits the `| File | Lines | Description |` table with live
  `wc -l` counts) handles this. Outside `specs/`, only
  `docs/development/LEAN_STYLE_GUIDE.md:915-926` mentions `IsValid`, and it already misattributes
  it to `Validity.lean` — no path breakage, but worth a one-line correction while nearby.
- **C14** (documented axiom/sorry counts match, including in `.lean` docstrings): the README's
  per-file line counts and `Metalogic.lean`'s `SoundnessLemmas/  3 files` claim (A-10, already
  wrong at 5) both need updating. After this task the directory holds **three** `.lean` files —
  which, by coincidence, makes the stale claim accidentally correct. Set it deliberately rather
  than leaving it.
- **C9** (zero task-number citations under `FormalSystem/`): none of the new prose may cite
  "task 519". This is also the repo-wide `no-task-references-in-deliverables` rule.

Run `bash scripts/check-module-invariants.sh --no-build` after each structural phase for a fast
pass, and the full run (with `lake build`) after Phases 2, 5 and 6.

---

## 5. Line-count projection against the acceptance criterion

Target: `SoundnessLemmas/` ≤ ~1,400 lines, from 2,487.

| File | Now | After | Reasoning |
|---|---|---|---|
| `Core.lean` | 107 | **0** | deleted (Phase 5) |
| `CoValidity.lean` | 141 | ~141 | import line retargeted only |
| `DenseValidity.lean` | 1,296 | **0** | deleted (Phase 3) |
| `FrameClassVariants.lean` | 591 | ~735 | +~150 transplanted survivors, +~90 extracted-lemma signatures, −~30 no-op `simp only` lines, −~65 arm bodies folded into extracted lemmas |
| `Separability.lean` | 352 | 352 | `private` dropped on one line |
| **Total** | **2,487** | **~1,228** | **comfortably under 1,400** |

`Soundness.lean` (1,741, outside the criterion) nets roughly −5: +~25 for `density_swap_valid` /
`dense_indicator_swap_valid`, −29 for the `exists_isGLB_of_lub` copy, −~20 for the collapsed
`ValidDiscrete.of_forall` shims at `:913-935` and `:1345-1353`.

Acceptance sub-criterion "exactly one 45-arm swap dispatcher with one-line arms": met by
`axiom_swap_valid_general` after Phase 4. Note the tree will still contain a *second* 45-arm
`cases` — `axiom_validIn_min` at `Soundness.lean:1277` — but that is the *local*-validity
dispatcher, it is already fully one-lined, and it is the stated model for the target shape rather
than a duplicate. `axiom_swap_validIn_min` (`:1326`) is a nine-arm dispatcher plus a `.Base`
delegation, not a 45-arm one.

Acceptance sub-criterion "zero declarations in the directory with only their own occurrence":
verified achievable *provided* the five extra dead declarations in §1.3 are included. Re-run the
`occ` sweep at the end:

```bash
for f in FormalSystem/Metalogic/SoundnessLemmas/*.lean; do
  grep -oP '^(private |protected |noncomputable )*(theorem|lemma|def|abbrev|instance) \K[A-Za-z_][A-Za-z0-9_'"'"'.]*' "$f" | while read n; do
    tot=$(grep -rhno "\b$n\b" --include='*.lean' FormalSystem Tests | wc -l)
    [ "$tot" -le 1 ] && echo "DEAD: $n ($f)"
  done
done
```

Caveat: this is a textual sweep. A declaration whose only "second occurrence" is a docstring
backtick (like `truth_at_swap_swap` today) reports `occ=2` and slips through; the sweep must be
read, not just exit-code-checked.

---

## 6. Interaction with sibling tasks 521 and 522

- **521 (Truth layer simp normal form)** defines `Truth.and_iff` as `@[simp]`, registers a
  `truth_norm` simp attribute and a `truth_simp` macro, and rewrites the ten worst soundness
  proofs. It does not exist yet. **519 must not wait on it**: nothing in 519 needs the simp set,
  and 521's own scope explicitly excludes `DenseValidity.lean` because 519 deletes it. The only
  coupling is `and_of_not_imp_not` — see §4.3, where I recommend 519 delete only the two
  DenseValidity copies and leave cross-directory consolidation to whatever follows 521.

- **522 (mechanical `truth_simp`/`swap_norm` application)** declares in `specs/TODO.md:1383` that
  it **DEPENDS ON 519** and 521, and that "the original target DenseValidity.lean (92 intros / 54
  simps) is DELETED by task 519, so do not touch it". 522's completion criterion is an 80% fall in
  `simp only [TruthAt` occurrences across `Soundness.lean` and `FrameClassVariants.lean`. This is
  the reason §4.2 item 3 matters: 519 should extract per-constructor lemmas and drop only the
  D-09-validated no-ops, leaving the remaining `simp only` calls in a *shape 522 can rewrite* —
  small named lemmas rather than 29-line inline arms. Extracting them is the enabling work for
  522; over-optimising them here would collide with it.

**Ordering recommendation**: run 519 to completion first, exactly as the wave numbering implies.
519 has no upstream dependency on either sibling.

---

## 7. Zero-debt note

Nothing in this task requires a `sorry`, and no approach considered here would. Every deletion is
of an unreferenced declaration; every move is a verbatim transplant; the only non-mechanical step
(Phase 5) is a restatement between two definitionally-equal-by-eta propositions with intro/elim
lemmas already written and already exercised at three call sites. If Phase 4's extraction of a
particular arm resists, the correct response is to leave that arm inlined and record it — the
acceptance criterion is about the dispatcher's *shape*, and one stubborn arm is a documented
partial, never a `sorry`.

---

## 8. Open question for the planner

The task description's file scope omits
`FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`, but Phase 5 cannot complete without
editing it (§4.1). The plan should either widen the scope explicitly — my recommendation — or
carve Phase 5 into a follow-on task and drop "delete IsValid and Core.lean" from 519's acceptance
criteria. Choosing silently is the one outcome to avoid: it is how a "green build" gets reported
against a tree that does not compile.

Related: `FrameClassVariants.lean` and `Separability.lean` are both imported by `Decidable.lean`
(`:10`, `:11`), so *any* signature change in those two files reaches it. Phases 3, 4 and 5 all
touch `FrameClassVariants.lean`. If another agent is working in `Decidability/`, that is the
collision surface — nothing indicates one is today, but the implementer should re-check
`git status` before Phase 5.
