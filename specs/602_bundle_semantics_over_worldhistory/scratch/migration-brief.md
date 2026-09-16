# WorldHistory migration brief (task 602, batch phases 5-9)

Repo: /home/benjamin/Projects/BimodalLogic (Lean 4 + Mathlib). The working tree is deliberately
RED mid-refactor; do NOT commit, do NOT run git stash/reset/checkout, do NOT touch files outside
your assigned scope (report instead).

## What changed (already landed in the tree, compiles)

`FormalSystem/Semantics/PartialHistory.lean` defines
`def WorldHistory (F : TaskFrame) : Type _ := {τ : PartialHistory F // τ.IsTotal}` with API:
- `τ.state t : F.WorldState` (= `τ.val.states t (τ.property t)`); `@[simp] states_eq_state`
  (`τ.val.states t h = τ.state t`, rfl)
- `WorldHistory.ext_state : (∀ t, τ.state t = σ.state t) → τ = σ` (uses propext + funext)
- `WorldHistory.ofTotal F f h : WorldHistory F` with `@[simp] ofTotal_state : (ofTotal F f h).state t = f t` (rfl)
- `τ.timeShift Δ : WorldHistory F`, `@[simp] timeShift_state : (τ.timeShift Δ).state t = τ.state (t + Δ)` (rfl),
  `timeShift_neg_timeShift : (τ.timeShift (-Δ)).timeShift Δ = τ`
- `CoeOut (WorldHistory F) (PartialHistory F)`; `state_congr`.
- `WorldHistory.path` (over `intOrder` frames, IntNormalForm) = the state function.

Every truth relation now evaluates at `τ : WorldHistory F` and quantifies over `WorldHistory F`:
- `TruthAt M τ t φ`: atom `M.valuation (τ.state t) p` (no domain conjunct); box `∀ σ : WorldHistory F, TruthAt M σ t φ`.
- `MinusTruthAt`, `PlusTruthAt`, `StarTruthAt M τ t v` likewise; stab clause
  `∀ σ : WorldHistory F, τ.state t = σ.state t → …`. `SameStateAt` is DELETED (use the plain state
  equation; `.refl` → `rfl`, `.symm/.trans` → `Eq.symm/Eq.trans`).
- `Truth.atom_iff : TruthAt M τ t (atom p) ↔ M.valuation (τ.state t) p` (Iff.rfl);
  `Truth.atom_iff_of_domain`, `atom_false_of_not_domain` DELETED.
- `Truth.box_iff`, `diamond_iff : … ↔ ∃ σ : WorldHistory F, TruthAt M σ t φ`;
  `PlusTruth.dstab_iff : … ↔ ∃ σ : WorldHistory F, τ.state t = σ.state t ∧ …`.
- `Truth.box_const M τ σ t s φ`, `box_time_const M τ t s φ` (no totality args).
- `TimeShift.timeShift_preserves_truth M (σ : WorldHistory F) x y φ : TruthAt M (σ.timeShift (y - x)) x φ ↔ TruthAt M σ y φ`;
  `timeShift_preserves_truth_total` DELETED. `exists_shifted_history` over WorldHistory.
- `TruthCorr`: `Rel : WorldHistory F → WorldHistory F' → Prop`, `atom : Rel σ σ' → ∀ t p, M.valuation (σ.state t) p ↔ M'.valuation (σ'.state (dur t)) p`,
  fields `fwd : ∀ σ, ∃ σ', Rel σ σ'` and `bwd : ∀ σ', ∃ σ, Rel σ σ'` (renamed from total_fwd/total_bwd).
  `TruthIso`/`TruthAntiIso.atom` stated with `.state`; `truthAt_of_truthIso I φ τ t : TruthAt M τ t φ ↔ TruthAt M' (I.hist τ) (I.dur t) φ`.
- Plus: `stab_congr_sameState` → `stab_congr_state M τ σ t (h : τ.state t = σ.state t) φ`;
  `of_stab M τ t φ h`, `stab_five M τ t φ h` (no hτ); `truth_congr_ext M φ τ σ t (h : ∀ s, τ.state s = σ.state s)`;
  `star_truth_congr_ext M φ τ σ x v (h : ∀ s, …)`; `stab_state_only M τ σ t s (h : τ.state t = σ.state s) φ`;
  `states_eq_of_deterministic hD (h : τ.state t = σ.state t) s : τ.state s = σ.state s`;
  `TaskFrame.SingletonClasses : ∀ τ σ x, τ.state x = σ.state x → ∀ y, τ.state y = σ.state y`;
  `plusTruthAt_timeShift`, `starTruthAt_timeShift` over WorldHistory; `timeShift_isTotal'`,
  `shift_neg_shift_domain/_states`, `states_congr`, `sameStateAt_*` DELETED.
  `paste ρ σ t (hsame : ρ.state t = σ.state t) : WorldHistory F`; `paste_isTotal` DELETED;
  `AgreeFrom/AgreeUpTo τ σ t := ∀ s, t ≤ s → τ.state s = σ.state s` (resp. `s ≤ t`).
  `natHist f : WorldHistory NF`; `natHist_isTotal` DELETED. `IsPlusStateLocal`/`IsStateLocal` take `(τ σ : WorldHistory F) t (h : τ.state t = σ.state t)`.
  `plusStateLocal_stab_iff hφ M τ t`, `stab_of_stateLocal hφ M τ t h`, `stateLocal_stab_iff hφ M τ t v`.
  `not_starValidOn_sentDet M τ x y hxy σ₁ σ₂ hs₁ hs₂ hpos hneg` (no totality args).
- ShiftSet: `S.hist w : WorldHistory S.frame`; `hist_isTotal`, `wh_ext` DELETED (use `WorldHistory.ext_state`);
  `total_eq_orbit S (σ : WorldHistory _) : σ = S.hist (σ.state 0)`; `ts_zero`/`ts_add` on WorldHistory.
- IntTransfer: `WorldHistory.map`/`comap`, `Aligned e σ σ' := ∀ n, σ'.state n = σ.state (e.symm n)`, `isTotal_map` DELETED.
- DurationFrames: `translationHist D`, `permissiveHist D so nm f` are WorldHistorys.
- FwdRecBridge: `hist_periodic F hF (τ : WorldHistory _)`, `hist_deterministic F hF τ ρ t h` with `.state`.

## Validity layer

`Valid`, `ValidIn fc`, `ValidOnFrames P`, `TaskFrame.ValidOn`, `ConsequenceOnFrames`,
`SemanticConsequenceIn`, and the Minus/Plus/Star mirrors now all quantify
`∀ … (M) (τ : WorldHistory F) (t)` with no totality binder. `satisfiable`/`FormulaSatisfiable`:
`∃ F M (τ : WorldHistory F) t, …`. `ValidInt`, `MinusValidZTimeSucc`, `MinusSemanticConsequence` likewise.

**All identity binder-shape adapters are DELETED**: `ValidIn/ValidOnFrames/SemanticConsequenceIn/
MinusValidIn/MinusValidOnFrames/PlusValidIn/PlusValidOnFrames/StarValidIn/StarValidOnFrames/
TaskFrame.StarValidOn/GenericValid*/... .of_forall_total / .apply_total / .of_not`,
`validOn_iff_total`, `genericValidOn_iff_total`. Migration:
- `refine ValidIn.of_forall_total ?_` + `intro F hF M τ hτ t` → just `intro F hF M τ t` (intro unfolds defs).
- `h.apply_total F hF M τ hτ t` / `ValidIn.apply_total h F hF M τ hτ t` → `h F hF M τ t`.
- `ValidIn.of_not h` (then `push Not`) → work with `h` directly, e.g. `simp only [ValidIn, ValidOnFrames, TaskFrame.ValidOn, not_forall] at h` or `by_contra`/`intro`, keeping axioms in check.
- Only the `.Base` adapters survive, RENAMED: `Valid.of_forall`, `Valid.apply F M τ t`, `Valid.of_not`;
  `SemanticConsequence.of_forall`, `.apply F M τ t hall`; `MinusValid.of_forall/apply`,
  `PlusValid.of_forall/apply`, `StarValid.of_forall/apply F M τ x v`, `GenericValid.of_forall/apply/of_not`.
  (`X.of_forall_total` → `X.of_forall` for these; drop the `hτ` binder.)

## Migration idioms

- `(τ : PartialHistory F) (hτ : τ.IsTotal)` binders → `(τ : WorldHistory F)`; delete `hτ` uses.
- `∀ σ : PartialHistory F, σ.IsTotal → P σ` → `∀ σ : WorldHistory F, P σ`; `∃ σ, σ.IsTotal ∧ P σ` → `∃ σ : WorldHistory F, P σ`.
- `τ.states t (hτ t)` → `τ.state t`; `τ.val.states t (τ.property t)` → `τ.state t`.
- Atom truth used to be `⟨domainProof, v⟩`: now it is just `v`. `rintro ⟨_, hv⟩` → `intro hv`; `⟨trivial, h⟩` → `h`.
- `⟨τ, hτ⟩ : WorldHistory` pairs where τ was a raw PartialHistory: build histories with
  `WorldHistory.ofTotal F f h` (and use `ofTotal_state`/rfl), or `⟨rec, fun _ => trivial⟩`.
- A `def fooHist : PartialHistory F := PartialHistory.ofTotal …` + `fooHist_isTotal` pair → make
  `fooHist : WorldHistory F := WorldHistory.ofTotal …` and delete `fooHist_isTotal` (and its uses).
- State equalities through `rw`: `show M.valuation (τ.state t) p ↔ _; rw [h]`. `congrArg ρ.state h`
  sometimes needs a type ascription `(congrArg ρ.state h : ρ.state a = ρ.state b)`.
- Equal histories: `WorldHistory.ext_state fun t => …`.
- Set equalities over `{σ | ∀ t, σ.domain t}` → restate over `WorldHistory` (surjectivity / `Set.univ = Set.range`).
- If a proof body used a hypothesis about a non-total history being passed to a truth relation,
  STOP and report the exact declaration (do not invent a parallel partial-history truth relation).

## Rules

- Zero `sorry`, no `axiom`, no `admit`. Keep proofs choice-light: prefer term/`rw`/`exact` over `simp`/`by_contra`
  where the old proof avoided classical tactics (axiom baselines are pinned by
  `scripts/check-module-invariants.sh` C2/C14).
- Remove *every* textual mention (including docstrings/comments) of deleted names in your files:
  `SameStateAt`, `sameStateAt_*`, `IsTotal →`/`IsTotal ∧` quantifier patterns, `∃ (ht : τ.domain t)`,
  `of_forall_total`, `apply_total`, `atom_iff_of_domain`, `hist_isTotal`, `natHist_isTotal`, `wh_ext`,
  `total_fwd`/`total_bwd`, `\bHF\b`. Update docstrings that describe totality hypotheses so they stay true
  (short, accurate edits; no task numbers in files).
- Do not rename or restate declarations outside your scope's needs; if a Semantics-level API is
  missing something you need, add nothing there — report it.
- Build: `bash /tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/97c0f227-17d3-4f6d-aeab-70518d0f4786/scratchpad/lb.sh Module.Name [Module.Name …]`
  (guarded `lake build`; prints the first errors and EXIT code; full log at `…/scratchpad/lastbuild.log`).
  Build modules by dotted name, e.g. `FormalSystem.Metalogic.Soundness`. Individual modules take seconds.
  Never run a bare foreground `lake build`. You may also use `lake env lean <file>` (timeout 900) once deps are built.
- Do NOT use the lean-lsp `lean_diagnostic_messages` or `lean_file_outline` tools.
- Final report (your last message): list of files edited, declarations whose statement changed
  (old → new, one line each), declarations deleted, anything left failing with the exact error, and
  any place you had to deviate from the idioms above.

## Already-migrated layers (wave 1) — API notes

- Metalogic core (Soundness, SoundnessLemmas, SetConsequence, Algebraic, Automation/PrefilterSoundness) and Decidability/** build.
- Algebraic/FlowFrame: `multiFamHistoryGen` and `bundleFlowHistory` now return `WorldHistory`;
  `multiFamHistoryGen_total`, `bundleFlowHistory_total` DELETED; `multiFamGen_total_eq σ`,
  `bundleFlow_total_eq σ` take no totality argument; `*_total_eq_range` are now
  `Set.univ = Set.range …`; new `@[simp] multiFamHistoryGen_state` (rfl).
- StrongCompleteness/Compactness/DedekindNonCompactness/DiscreteNonCompactness are edited but
  wait on BXCanonical (`completeness_base`, `completeness_dense`).
