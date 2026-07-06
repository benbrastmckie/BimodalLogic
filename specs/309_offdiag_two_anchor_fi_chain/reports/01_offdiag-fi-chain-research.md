# Report 01 — Off-Diagonal Two-Anchor F_i Chain (task 309)

- **Task**: 309 — offdiag_two_anchor_fi_chain
- **Type**: lean4 (hard-mode research; H2/H3/H4/H5)
- **Session**: sess_1783357355_777b72
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, Cor 5.4 §5)
- **Spawned from**: task 307 Phase 7 blocker audit (reports/03_endpoint-hook-blocker-audit.md, VERDICT BINDS)
- **Goal**: build the off-diagonal (`x ≠ t`) two-anchor navigated characteristic (non-trivial-segment
  F_i chain) so `KampPrior.lean:350` can be rewired to `A_past ∨ A_diag ∨ A_future`, dropping the
  live-path sorry at `:350` (live sorries 2 → 1).

All file:line citations below were verified by `Read`/`grep` in this session (not recalled). The full
consumed-asset signature verification is in the Adversarial Self-Verification section.

---

## 1. Exact current state of `KampPrior.lean:350` and its goal

`:350` is the `n = 1` match arm inside the `k + 1` case of the recursive definition
`nf_nvar_exist_all_depths` (KampPrior.lean:211–353). The definition's signature (KampPrior:211–222) is:

```lean
noncomputable def nf_nvar_exist_all_depths
    {sig} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p) :
    (k n : Nat) → (sub_nf : NormalForm sig k (n + 1)) →
      ∃ (A : Formula),
        ∀ (M) (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap) (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub_nf
```

**Obligation at `:350`** (the `k+1, 1, sub_nf` arm), with `sub_nf : NormalForm sig (k+1) 2`:

```
⊢ ∃ (A : Formula), ∀ M h_UZ h_SZ t,
    temporal_truth M atomMap t A ↔
    ∃ env : Fin 1 → M.carrier, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf
```

**In-scope local assets at `:350`** (all built earlier in the same proof body):
- `ih_exist_1` (KampPrior:264–290): the depth-`k` IH specialised to arity 2, with the
  `insertEnv env t = Fin.cons (env 0) (fun _ => t)` bridge (`h_env_eq`, :276–285) that rewrites the
  `Fin 1` existential to the single-anchor form `∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf'`.
- `exist_tl_fn_k : NormalForm sig k 2 → Formula := fun s => (ih_exist_1 s).choose` (KampPrior:293) with
  `exist_tl_fn_k_correct` (:296–303): `temporal_truth M t (exist_tl_fn_k s) ↔ ∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _=>t)) s`.
- `char_k1 : NormalForm sig (k+1) 1 → Formula := nf_succ_char_formula … exist_tl_fn_k` (KampPrior:306)
  with `char_k1_correct` (:309–320): `temporal_truth M t (char_k1 nf') ↔ nf_eval_nf M (k+1) 1 (fun _=>t) nf'`.

Via the `Fin 1 ↔ ∃ x` bridge (the same `h_env_eq` shape as :276–290), the `:350` RHS is
`∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` — **verbatim the LHS of**
`nf_zone_exists_trichotomy_k1` (NfZoneFlattenNavigable:188–196). So the rewire is:
`rw`/bridge to the `∃ x` form → `rw [nf_zone_exists_trichotomy_k1]` → three-way `or_congr` discharged by
`A_past_correct` / `A_diag_correct` / `A_future_correct`.

> Note (matches audit report 03 §1.1): `lean_goal` at `:350` returns empty goals — a match-arm/sorry
> artifact. The obligation shape above is read directly off the `def` binder (KampPrior:211–222), not
> from the goal printer.

---

## 2. H3 Tier-1 lemma mapping table (Rabinovich Cor 5.4 F_i chain → Lean)

Rabinovich Cor 5.4 (md:154–157): `F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`;
`[α_0,…,α_n](z_0,z)` holds iff there is an increasing sequence in `(z_0,z_1)` with `F_0(z_0)`. The
endpoint coupling `z_0 ↔ z_1` rides the **non-trivial** segment types `β_i` inside the Until nesting.

| Literature item | Statement | Lean target name | Existing asset consumed | Status |
|---|---|---|---|---|
| Cor 5.4 nested Until with non-trivial `β_i` segment | `∃ z0<t, endpoint(z0) ∧ β holds on (z0,t)` | `A_past` (segment-carrying, **to revise**) | `bracketBuildLeft` / `bracketBuildLeft_correct` (VecEATranslation:273/503) | Asset exists; A_past must take `seg` (deliverable 1) |
| Cor 5.4 future dual (`z0 < z`) | `∃ z1>t, endpoint(z1) ∧ β holds on (t,z1)` | `A_future` (segment-carrying, **to revise**) | `bracketBuildRight` / `_correct` (VecEATranslation:50/234) | Asset exists; A_future must take `seg` (deliverable 1) |
| Cor 5.4 F_i chain endpoint = arity-2 char at `[x,t]` (off-diagonal) | temporal formula ⇔ `∃ x, x<t ∧ nf_eval_nf M (k+1) 2 [x,t] sub_nf` | **`nf_char2_past_formula`** (new, load-bearing) | see §4/§5 (brick + IH + bracket) | **DOES NOT EXIST — build (deliverable 2)** |
| Cor 5.4 F_i chain, future arm (`t<x`) | temporal formula ⇔ `∃ x, t<x ∧ nf_eval_nf M (k+1) 2 [x,t] sub_nf` | **`nf_char2_future_formula`** (new dual) | dual of above | **DOES NOT EXIST — build (deliverable 2)** |
| Interval split at new point `z` (Lemma 5.1 case split) | single-anchor `x`-trichotomy of the `:350` RHS | `nf_zone_exists_trichotomy_k1` | `exists_trichotomy_split` (NfZoneFlattenNavigable:188) | Available (sorry-free) |
| Diagonal degenerate interval (point collapse, `β=True` sound) | arity-2 char at `[t,t]` | `A_diag` / `nf_char2_formula` | NfMultiAnchorBridge:614/327 | Available (sorry-free, hook-parametric) |
| Coupled inner `∃w` five-zone flatten (Lemma 5.1 interior) | `∃w, nf_eval M k 3 (zoneEnv3 w x t) q` ⇔ 5-zone navigated disjunction | `nf_zone_flatten_navigable_brick` | NfMultiAnchorBridge:686 (= `_correct` :560) | Available (sorry-free, hook-parametric) |
| Base of recursion (depth-`k` IH, endpoint bottom-out) | arity-(n+1) existential at depth k | `nf_nvar_exist_all_depths` / local `exist_tl_fn_k` | KampPrior:211 / :293 | Available (see divergence D2) |
| Depth-0 off-diagonal base (all arities, general env) | `∃env, nf_eval_nf M 0 (n+1) (insertEnv env t) sub_nf` | `nf_nvar_exist_depth0_tl_fn` / `_correct` | NfDepth0Generalized:1615/1622 | Available (sorry-free) |

---

## 3. Deliverable 1 — segment-carrying `A_past` / `A_future` (exact refactor)

**Current** (NfZoneFlattenNavigable.lean:332, :383) — trivial-top hardcoded:
```lean
noncomputable def A_past   (pastEnd   : TemporalPred) : Formula :=
  bracketBuildLeft  (BracketFormula.trivial TemporalPred.top) pastEnd
noncomputable def A_future (futureEnd : TemporalPred) : Formula :=
  bracketBuildRight (BracketFormula.trivial TemporalPred.top) futureEnd
```
`A_past_correct` (:342–354) / `A_future_correct` (:393–405) are **hook-parametric** on
`h_past : ∀ x < t, pastEnd.eval_at x ↔ nf_eval_nf M (k+1) 2 [x,t] sub_nf`. That hypothesis is
**unsatisfiable off-diagonal** (audit report 03 §1.2): a closed, model-independent `pastEnd` evaluated
at `x` alone cannot re-identify the distinct origin `t`. The theorems compile but can never be applied.

**Revised** (deliverable 1): take a segment `seg : BracketFormula 0` (or `TemporalPred` lifted to a
1-segment bracket):
```lean
noncomputable def A_past   (seg : BracketFormula 0) (pastEnd   : TemporalPred) : Formula :=
  bracketBuildLeft  seg pastEnd
noncomputable def A_future (seg : BracketFormula 0) (futureEnd : TemporalPred) : Formula :=
  bracketBuildRight seg futureEnd
```
`_correct` now goes **directly through `bracketBuildLeft_correct`** (VecEATranslation:503), which for a
non-trivial `seg` gives:
```
temporal_truth M t (bracketBuildLeft seg endLeft) ↔ ∃ z0, z0 < t ∧ endLeft.eval_at z0 ∧ seg.holds M z0 t
```
The `(x,t)` coupling now rides `seg.holds M x t` (the whole formula still evaluated at origin `t`), and
`pastEnd.eval_at x` may stay closed. This is the exact Rabinovich `β_i Until F_i` realization.

**Scoping constraint (guard against over-refactor).** `nf_zone_flatten_navigable` (NfMultiAnchorBridge:540)
and `nf_char2_diag_exist_tl` (:190) **also** hardcode `BracketFormula.trivial TemporalPred.top`, but
those are for the **inner-`w` exterior zones** (`w<x`, `t<w`), which legitimately bottom out via the
depth-`k` IH endpoints and are sound with a trivial segment. **Only the outer `A_past`/`A_future`
require segments.** Do NOT touch the inner brick's trivial-top brackets.

---

## 4. Deliverable 2 — `nf_char2_past_formula` (the load-bearing new object)

**Target signature** (matching NfMultiAnchorBridge conventions for `nf_char2_formula`, §Adversarial
row confirms the pattern):
```lean
noncomputable def nf_char2_past_formula {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj  : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (⟨recursion hooks: arity-3 char TemporalPreds / diag Formulas one depth down⟩)
    (sub_nf : NormalForm sig (k + 1) 2) : Formula
```
**Target correctness:**
```lean
theorem nf_char2_past_formula_correct … (M) (t : M.carrier) (⟨hook-correctness = depth-k IH⟩) :
    temporal_truth M atomMap t (nf_char2_past_formula … sub_nf) ↔
      ∃ x : M.carrier, x < t ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf
```
Future dual: replace `x < t` by `t < x`. Universe/implicit conventions: `{sig : MonadicSignature}`,
`{k : Nat}` implicit; `atomMap`, `h_surj`, hooks, `sub_nf` explicit; `M`/`t` explicit in `_correct`;
correctness hooks (`h_past`/`h_fut`/`h_diag`, each `∀ (qnf) (w), … eval_at w ↔ nf_eval_nf M k 3 …`)
explicit — mirroring `nf_char2_formula_correct` (NfMultiAnchorBridge:345–359) and `A_diag_correct`
(:631–650) exactly.

### The construction (Rabinovich Cor 5.4, F_i chain — the central design challenge)

The target RHS `∃ x, x<t ∧ nf_eval_nf M (k+1) 2 [x,t] sub_nf`. Unfolding the arity-2 evaluation at the
quant layer (via `nf_char3_eq_succ_iff`-style decomposition, the same shape `nf_char2_formula` uses):
```
nf_eval_nf M (k+1) 2 [x,t] sub_nf  ⇔  (atom layer at [x,t] agrees with sub_nf.1)
                                       ∧ (∀ qnf, (∃w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ sub_nf.2 qnf)
```
The formula at origin `t` must navigate to a past `x` and then assert this. The `bracketBuildLeft seg pastEnd`
skeleton (deliverable 1) supplies `∃ x < t, pastEnd.eval_at x ∧ seg.holds x t`. The decomposition
partitions the `[x,t]` characteristic into pieces by their locus:
- **at `x`** (navigated endpoint `pastEnd`): the `x`-position atom literals; the inner-`w` **past-exterior**
  zone `w < x` (navigated bracket into `x`'s past); the point zone `w = x`.
- **along `(x,t)`** (the non-trivial segment `seg`, i.e. Rabinovich `β`): the inner-`w` **bounded-interior**
  zone `x < w < t` (`nf_zone_flatten_navigable_brick`'s middle zone, NfMultiAnchorBridge:548).
- **at / future of `t`** (asserted at the origin `t` directly, outside the bracket): the `t`-position
  atom literals; the point zone `w = t`; the future-exterior zone `t < w` (navigated `bracketBuildRight`
  from `t`).

Each inner `∃w` per `qnf` is flattened by `nf_zone_flatten_navigable_brick` (NfMultiAnchorBridge:686)
into its five zones; the two **open exterior** zones become navigated `bracketBuild*` endpoints whose
`.eval_at`-correctness one depth down **is the depth-`k` IH**; the three **residual** zones
(`w=x`, `x<w<t`, `w=t`) stay honest arity-3 `nf_eval_nf` on the full env `zoneEnv3 · x t` (route (c);
`zoneEnv3_arity_invariant`) and are discharged by the depth-`k` IH / `nf_char3_deeper_split`
(NfMultiAnchorBridge:476). **`w` is always a bracket witness** — env arity `{w,x,t}=3 → {x,t}=2`, never
a third anchor (guard G4).

The order-atom `order 0 1` at `[x,t]` is **true** (`x < t`) — this is precisely why the off-diagonal
atom layer is NOT the existing diagonal `nf_char2_atom_part` (see divergence D3). The off-diagonal atom
characteristic is a new sub-piece (x-atoms navigated to `x`, `t`-atoms at origin `t`, order fixed by the
bracket direction).

---

## 5. Recursion structure on `k` (where the IH lives, how residuals thread)

- The **outer recursion is `nf_nvar_exist_all_depths`** (KampPrior:211, `Nat.rec` on `k`). Base `k=0`
  routes to `nf_nvar_exist_depth0_tl_fn` (NfDepth0Generalized:1615) which already handles **all arities
  off-diagonal** via general `insertEnv env t`. Step `k+1` is where `:350` lives.
- The **depth-`k` IH** available at `:350` is `ih_exist_1` / the local `exist_tl_fn_k`
  (KampPrior:264–303). It converts depth-`k` arity-2 existentials. The endpoint hooks that
  `nf_char2_past_formula` needs are **arity-3 characteristics at navigated witnesses**
  (`NormalForm sig k 3 → TemporalPred`), which the arity-2 existential converter does not directly
  supply — see divergence D2. The construction must build the arity-3 endpoint characteristics from the
  depth-`k` machinery (the same way `nf_char2_diag_exist_tl` obtains its hooks in the diagonal case).
- **Residual arity-3 zones** (`w=x`, `x<w<t`, `w=t`) are discharged one depth down by the depth-`k`
  IH via `nf_char3_deeper_split` (NfMultiAnchorBridge:476), exactly as the diagonal `A_diag`/brick do.

---

## 6. File placement plan (import DAG)

**Verified DAG** (this session):
- `KampPrior` imports: `ExistsForallNF`, `NfToVecEA`, `NfDepth0Generalized`, `NormalForm`, `PriorDefs`,
  `Separation.KampTranslation`. It imports **none** of `NfMultiAnchorBridge` / `NfZoneFlattenNavigable`
  / `VecEATranslation`.
- `NfMultiAnchorBridge` imports only `NfZoneFlattenNavigable` → `{VecEATranslation, NfZoneDepthK,
  NfDepth0Generalized}`. `NfMultiAnchorBridge` is imported by **nobody** (leaf, off the live path).
- `KampPrior` is imported by `PriorExpressiveness` (live) and `Boneyard/KampNegationClosure`.
- The relocation commit `69998c02d` moved `nf_quant_clause_tl` into `NfDepth0Generalized:1745` (a shared
  ancestor of both `KampPrior` and the bridge), breaking the earlier cycle.

**Plan:**
1. **Deliverable 1** (`A_past`/`A_future` segment revision + `_correct`) stays in
   `NfZoneFlattenNavigable.lean` (its current home; depends only on `bracketBuildLeft/Right_correct`).
2. **Deliverable 2** (`nf_char2_past_formula`/`nf_char2_future_formula` + `_correct`) goes in
   `NfMultiAnchorBridge.lean` alongside `A_diag`/`nf_char2_formula`, **hook-parametric** (like
   `nf_char2_formula`). This keeps them off the live path until KampPrior imports them.
3. **Deliverable 3** (`:350` rewire) requires **adding `import …Kamp.NfMultiAnchorBridge` to
   `KampPrior.lean`** (transitively pulling `NfZoneFlattenNavigable`/`VecEATranslation`). This is
   **cycle-safe**: nothing in that subtree imports `KampPrior` (only `PriorExpressiveness` + Boneyard
   do). At `:350`, KampPrior supplies the recursion hooks from its local `exist_tl_fn_k`/`char_k1` and
   discharges the three arms. See divergence D1 — this new import edge is not stated in the task and
   moves the 307/308 assets onto the live import path.

---

## 7. Divergences from the task description (H5)

| # | Task/audit assumption | Actual codebase state (verified) | Impact |
|---|---|---|---|
| **D1** | "NfMultiAnchorBridge no longer imports KampPrior … where do new defs go so KampPrior can consume them without cycles" (framed as solved) | `KampPrior` imports **none** of NfMultiAnchorBridge/NfZoneFlattenNavigable/VecEATranslation (grep confirmed). Deliverable 3 must **add** `import …NfMultiAnchorBridge` to `KampPrior`. Cycle-safe (only PriorExpressiveness+Boneyard import KampPrior), but the 307/308 assets move ONTO the live path. | Planner must add the import edge; full-tree axiom re-verification needed after; "off the live import path" applies only to deliverables 1–2, not the `:350` rewire. |
| **D2** | "residual arity-3 zones discharged by the depth-k IH (`exist_tl_fn_k` / `nf_nvar_exist_all_depths`)"; treats `exist_tl_fn_k` as a consumable asset with an exact statement | `exist_tl_fn_k` and `char_k1` are **local `let`-bindings inside the proof** of `nf_nvar_exist_all_depths` (KampPrior:293/306), NOT top-level defs. They convert depth-`k` **arity-2 existentials**; the endpoint hooks need **arity-3 characteristics** at navigated witnesses. | The endpoint hooks are not a verbatim consume of `exist_tl_fn_k`; the construction must build arity-3 char hooks from depth-`k` machinery within the recursion (template: `nf_char2_diag_exist_tl`). Genuine construction work. |
| **D3** | Lists `nf_char2_atom_part(_correct)` as a consumed asset for the off-diagonal `nf_char2_past_formula` | `nf_char2_atom_part` is **diagonal-only**: it returns `⊥` whenever any order atom is true (NfMultiAnchorBridge:257–264). The off-diagonal `[x,t]` has `order 0 1 = true` (`x<t`). | The off-diagonal atom layer needs a **new** atom characteristic (not `nf_char2_atom_part`): `x`-atoms navigated to `x`, `t`-atoms at origin, order fixed. Cannot consume verbatim. |
| **D4** | "drop the forced `trivial top`" on the off-diagonal arms (deliverable 1) | Confirmed correct for `A_past`/`A_future` (NfZoneFlattenNavigable:332/383). BUT `nf_zone_flatten_navigable` (NfMultiAnchorBridge:540) and `nf_char2_diag_exist_tl` (:190) ALSO hardcode trivial-top for the **inner-`w` exterior** zones, which are legitimately trivial. | Scope the refactor to `A_past`/`A_future` **only**; do not change the inner brick's trivial-top brackets (they are sound). |

None of these refutes the task VERDICT (the F_i chain is the constructive `A`); they refine the
interface and flag two "consume verbatim" claims (D2, D3) that are actually construction work.

---

## 8. Scope / recommendation for the planner

- Deliverable 1: ~80–120 lines (refactor + generalized `_correct` through `bracketBuildLeft/Right_correct`).
- Deliverable 2: ~300–500 lines, recursion on `k` — the load-bearing object; budget for the off-diagonal
  atom layer (D3) and the arity-3 endpoint-hook construction (D2) as genuine new sub-pieces.
- Deliverable 3: ~40–80 lines glue (add import; `nf_zone_exists_trichotomy_k1` + three `_correct`).
- Total ~400–700 lines. **Phase-decompose** (R-B from audit): (P1) A_past/A_future segment refactor →
  (P2) off-diagonal atom layer + `nf_char2_past_formula` past arm → (P3) future dual → (P4) `:350`
  rewire + import edge + full-build axiom check.
- **Forbidden routes G1–G5** (audit report 03 §4) carry over verbatim: no arity-1 collapse; no
  projection `VecEA2`/third-anchor tower; **no trivial-top segment on the off-diagonal arms**; `w` a
  bracket witness (anchor set `{x,t}`, ≤2 cap); step-by-step Cor 5.4 (no simp/omega/aesop shortcut of a
  chain step — literature-fidelity policy).
- **Goal state**: `lake build` GREEN (full); axioms exactly `[propext, Classical.choice, Quot.sound]`
  (0 domain axioms; verify with `#print axioms` on the live-path theorem after the import edge lands);
  live-path sorries 2 → 1 (`:350` closed, `:353` remains, per task 305 scope).

---

## Adversarial Self-Verification

Every load-bearing claim below was checked against the actual file this session. `Verification Method`
uses lean4 domain values: `lean_hover_info`-equivalent source read of the signature, `grep`-confirmed
presence/absence, or literature read.

| Claim | Source/Counterexample | Verdict |
|---|---|---|
| `:350` is the `n=1` arm of `nf_nvar_exist_all_depths`, RHS `∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf` | KampPrior:211–222 (def binder) + :346–350 (match arm) — source read | Confirmed |
| `:350` RHS bridges to `∃ x, nf_eval_nf M (k+1) 2 [x,t] sub_nf` = LHS of trichotomy | KampPrior:276–290 (`h_env_eq`/`ih_exist_1` bridge) + NfZoneFlattenNavigable:188–196 — source read | Confirmed |
| `nf_zone_exists_trichotomy_k1` splits that existential into past/diag/future (sorry-free) | NfZoneFlattenNavigable:188–196 (`= exists_trichotomy_split …`) — source read | Confirmed |
| `A_past`/`A_future` hardcode `BracketFormula.trivial TemporalPred.top` (need segment) | NfZoneFlattenNavigable:332, :383 — source read | Confirmed |
| `A_past_correct`/`A_future_correct` are hook-parametric on an off-diagonal-unsatisfiable `h_past`/`h_fut` | NfZoneFlattenNavigable:342–354, :393–405 + audit report 03 §1.2 — source read | Confirmed |
| `bracketBuildLeft_correct` : `↔ ∃ z0<t, endLeft.eval_at z0 ∧ bf.holds z0 t` (segment carries coupling) | VecEATranslation:503–510 — source read | Confirmed |
| `bracketBuildRight_correct` dual : `↔ ∃ z1>t, endRight.eval_at z1 ∧ bf.holds t z1` | VecEATranslation:234–241 — source read | Confirmed |
| `nf_char2_formula`/`_correct` = **diagonal** char at `[t,t]` (`fun _=>t`), hook-parametric | NfMultiAnchorBridge:327–338, :345–359 (RHS `nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf`) — source read | Confirmed |
| `A_diag`/`_correct` = `nf_char2_formula` at the diagonal disjunct `[t,t]`, sorry-free | NfMultiAnchorBridge:614–621, :631–659 — source read | Confirmed |
| `nf_zone_flatten_navigable_brick`/`_correct` flatten `∃w, nf_eval M k 3 (zoneEnv3 w x t) q` into 5 zones, hook-parametric | NfMultiAnchorBridge:686–699 (= `_correct` :560–579) — source read | Confirmed |
| `nf_char2_zone_split5` : direct full-env 5-zone split (route (a)) | NfMultiAnchorBridge:457–466 — source read | Confirmed |
| `nf_char2_atom_part` is **diagonal-only**, `⊥` when any order atom true (D3) | NfMultiAnchorBridge:253–264 (`if (∀p …)=… ∧ (∀ i j h, order i j h = false) then … else ⊥`) — source read | Confirmed |
| `nf_char2_atom_part_correct` : `↔ nf_eval_nf M 0 2 (fun _=>t) nf2` (constant/diagonal env) | NfMultiAnchorBridge:269–279 — source read | Confirmed |
| `nf_quant_clause_tl`/`_correct` relocated to `NfDepth0Generalized:1745`/:1752 (shared ancestor) | NfDepth0Generalized:1745–1770 + git 69998c02d — source read + git log | Confirmed |
| `nf_char2_diag_exist_tl`/`_correct` = diagonal 3-zone converter, hook template | NfMultiAnchorBridge:190–227 — source read | Confirmed |
| `exist_tl_fn_k` is a **local `let`** inside the proof (not top-level), arity-2 existential (D2) | KampPrior:293–303 (`let exist_tl_fn_k := …`) — source read | Confirmed |
| `nf_nvar_exist_all_depths` recurses on `k`; base `k=0` = `nf_nvar_exist_depth0_tl_fn` (all arities, off-diagonal) | KampPrior:211–226 + NfDepth0Generalized:1615–1629 — source read | Confirmed |
| `nf_char3_deeper_split` discharges residual zones one depth down | NfMultiAnchorBridge:476–493 — source read | Confirmed |
| `KampPrior` imports none of NfMultiAnchorBridge/NfZoneFlattenNavigable/VecEATranslation (D1) | KampPrior:1–6 (import list) — grep | Confirmed |
| Adding `import …NfMultiAnchorBridge` to KampPrior is cycle-safe | only `PriorExpressiveness`+Boneyard import KampPrior; nothing in the bridge subtree does — grep | Confirmed |
| `nf_char2_past_formula`/`nf_char2_future_formula` do NOT exist | grep across `Kamp/*.lean` — grep-confirmed absence | Confirmed |
| Consumed assets are sorry-free (NfMultiAnchorBridge, NfZoneFlattenNavigable, VecEATranslation) | grep "sorry" → only in docstrings/comments; VecEATranslation zero hits — grep | Confirmed |
| Live-path sorries are exactly KampPrior `:350`, `:353` | grep "sorry" KampPrior → code sorries only :350/:353 (others are doc/comment lines 33–38,196,491) — grep | Confirmed |
| Cor 5.4 F_i chain uses non-trivial `β_i` segments; trivial-top = `β=True` severs coupling | Rabinovich md:154–157 vs NfZoneFlattenNavigable:332 — literature + source read | Confirmed |
| Axioms exactly `[propext, Classical.choice, Quot.sound]` at goal state | Not build-verified this session (research; full build deferred to implementation) | Unverified (deferred) |

**Contradiction Log.**
- *Task "consume nf_char2_atom_part / exist_tl_fn_k verbatim" vs. §7 D2/D3 (they are diagonal-only /
  local-let arity-2).* **Resolved** by precedence "actual asset type > task prose": these are partial
  templates, not verbatim consumes for the off-diagonal; the off-diagonal atom layer and arity-3
  endpoint hooks are genuine new sub-pieces. No contradiction on the VERDICT (F_i chain is `A`).
- *Task "off the live import path" vs. §6/D1 (deliverable 3 puts assets on the live path).* **Resolved**:
  "off-path" scopes deliverables 1–2; deliverable 3 (the `:350` rewire) is necessarily live and is the
  intended sorry-reduction. No unresolved contradiction.

**Forbidden-output check.** No "mathlib likely has this" claim (codebase-internal construction; every
asset cited with file:line). No sorry-deferral or axiom-introduction recommended. Guards G1–G5 carried
forward. The single unverified claim (axiom baseline) is explicitly flagged deferred to build time, not
asserted.

**Recommendations modified after verification.** Added D1 (KampPrior import edge required — not in task),
D2 (exist_tl_fn_k is a local let, arity-2, not the arity-3 hook), D3 (nf_char2_atom_part is diagonal-only
— off-diagonal atom layer is new), D4 (scope segment refactor to A_past/A_future only, not the inner
brick). These correct the "consume verbatim" framing for two assets.
