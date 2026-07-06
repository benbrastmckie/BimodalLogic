# Implementation Summary: Task #305 (plan v38 — Lemma 3.4 m=1 rewire)

- **Plan**: plans/38_lemma34-m1-rewire.md
- **Session**: sess_1783306400_33dd64

## Phase 7: Leftward existential closure — bracketBuildLeft + existClosureLeft + iff [COMPLETED]

**Goal**: Build the Since-mirror of the proven rightward absorption (`bracketBuildLeft` +
`existClosureLeft` + the leftward absorption iff), sorry-free and off the live import path.

### What landed

- **`VecEATranslation.lean`** (canonical, upstream): `chainHoldsLeft`, `bracketBuildLeft`
  (Since-nested via `Formula.snce`, peeling the rightmost witness), the private witness lemmas
  `bracket_append_witness` / `bracket_extract_last_witness`, definitional equation lemmas
  (`chainHoldsLeft_{zero,succ}_eq`, `bracketBuildLeft_{zero,succ}_eq`), `chainHoldsLeft_iff_holds`,
  `bracketBuildLeft_iff_chainHoldsLeft`, and `bracketBuildLeft_correct`:
  `temporal_truth M atomMap t (bracketBuildLeft bf endLeft) ↔ ∃ z0 < t, endLeft.eval_at z0 ∧ bf.holds z0 t`.
- **`VecEA_m.lean`**: `prependEnv` (index-0 prepend) + `prependEnv_zero`/`prependEnv_succ`
  (`@[simp]`), `VecEA_m.existClosureLeft` (absorbs the leftmost free variable `z_0` by folding the
  leftmost interval bracket + endpoint into `z_1`'s endpoint via `bracketBuildLeft`), and the two
  directions `existClosureLeft_correct` / `existClosureLeft_correct_rev`:
  `existClosureLeft.holds env ↔ ∃ z < env 0, vea.holds (prependEnv z env)`.

### Deviation — `bracketBuildLeft` already existed

Report 38 asserted `bracketBuildLeft`/`_correct` were MISSING. In fact a complete, sorry-free copy
existed in `NfToVecEA.lean` (downstream of `VecEATranslation.lean`), under an outdated
"sorries at n > 0" docstring. Because `VecEA_m` (home of `existClosureLeft`) is upstream of
`NfToVecEA`, that copy was unreachable. Resolution: the canonical copy was placed in
`VecEATranslation.lean`; the duplicate block was deleted from `NfToVecEA.lean` and its two
`bracketBuildLeft_correct_zero` usages repointed to the general `bracketBuildLeft_correct`. Single
source of truth, still sorry-free.

### Verification (actual output)

- `lake build` — **Build completed successfully (1700 jobs)**.
- `lean_verify VecEA_m.existClosureLeft_correct` → `axioms: [propext, Classical.choice, Quot.sound]`, no warnings.
- `lean_verify VecEA_m.existClosureLeft_correct_rev` → `axioms: [propext, Classical.choice, Quot.sound]`, no warnings.
- `lean_verify bracketBuildLeft_correct` → `axioms: [propext, Classical.choice, Quot.sound]`, no warnings.
- Live-path sorry baseline **UNCHANGED at 2** (`KampPrior.lean:391`, `:394` — untouched; Phase 7 is off-path).
- New Phase 7 declarations: **0 sorries**. No new top-level `axiom` in `Theories/`.

### Follow-up

- Phase 8 (n=1 witness-position split + live rewire of `KampPrior:391`) can now consume
  `VecEA_m.existClosureLeft` (leftward), the existing `existClosure` (rightward), and `VVecEA_m.disj`.

---

## Phase 8 — n=1 witness-position split + live rewire of KampPrior:391 [BLOCKED]

**Dispatch**: sess_1783306400_33dd64 (lean-implementation-hard-agent, single-phase).

**Outcome**: BLOCKED. `:391` sorry kept; build GREEN at baseline HEAD (326adc4e1); `git diff` clean;
live-path sorry count unchanged at 2 (`:391`, `:394`); no code landed (no regression, no partial
rewire). Zero new axioms.

**Why** (full detail in plan Phase 8 BLOCKER block): the plan scoped Phase 8 as *wiring* the
existing `existClosure`/`existClosureLeft`/`disj` into the `| 1 =>` arm. That wiring is
inapplicable at general depth: those combinators consume `VecEA_m` structures and their
correctness (`VecEA_m.lean:245`,`:426`,`:135`) is stated over `VecEA_m.holds`, but the arm target
is `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`. The required bridge
`nf_eval_nf M (k+1) 2 env sub_nf ↔ (vea : VecEA_m 2).holds M atomMap env` **does not exist at any
depth > 0** — every NF→VecEA/temporal converter (`nf_2var_exist_depth0_tl` `NfToVecEA.lean:503`,
`nf_vecEA2_future/past_correct`, VecEADecomp `nf_3var_zone_*`) is depth-0.

**Per-arm status**:
- `x = t` (middle): diagonal collapse `mergeNF_succ` (`NfDepth0Generalized.lean:593`) exists but
  only its atom layer (`mergeNF_succ_atom`) is proven; quant-layer collapse correctness is open —
  the general `renameNF_eval_iff` (`:440`) needs a bijection (`f∘r = id` on the larger arity),
  which the non-injective merge violates.
- `x < t` / `t < x` (directional): depth-(k+1) Since/Until bracket builders do not exist (only
  the depth-0 `nf_vecEA2_past`/`future`).

**Recommendation**: revise plan 38 to insert a dedicated phase building the depth-(k+1) NF→VecEA_m
bridge (mirror `VecEADecomp.lean` + `NfToVecEA.lean` at depth k+1 via the depth-k IH
`exist_tl_fn_k`) BEFORE the `:391` rewire. Only then does the 3-arm wiring become executable.
