# Round 24 — the `(K4)` dead-conjunct deletion trial (plan v24, Phase 11.36)

**Outcome: (a) — THE BUILD IS GREEN WITHOUT THEM.** With `(K4)`'s two depth conjuncts deleted,
the main library and the test library both build with exit status 0. No library or test proof
consumes `2 * dBack φ + 1 ≤ B` or `2 * dFwd φ + 1 ≤ B`.

The deletion was a trial and is NOT landed: `paramsOkK4` is restored to its filed shape (see
"Restoration" below).

## 1. Consumer set, re-derived at entry

`grep -rn 'paramsOkK4\|hK4\|\.2\.2\.2\.2' FormalSystem/ Tests/` returns about a hundred hits; all
but the following are positional projections on unrelated conjunctions (Kamp, GameTransfer,
BXCanonical, WitnessFamily, BiLasso, PlusSlicedCertificate, `coh_iff`, `kappa_eq_components`).
The hits that touch `(K4)`:

| Site | Role |
|---|---|
| `RaySummary/CounterQuotient.lean:920` | the definition `paramsOkK4` |
| `RaySummary/CounterQuotient.lean:932` | its use inside `ParamsOk` |
| `RaySummary/CounterQuotient.lean:943` (`paramsOk_params`) | PRODUCER — proves the three conjuncts from `Bof` |
| `RaySummary/CounterQuotient.lean:995`, `:999`, `:1020`, `:1029` (`paramsOk_inflate`, `paramsOk_inflate_raise`) | pass-through — `hK4` re-packed unread |
| `RaySummary/LadderWindow.lean:1835` (`cellSubset_of_kappa_eq_window_raise`) | the ONE consumer: `hp.2.2.2.2.2 : 2 ≤ B` |
| `RaySummary/LadderAgree.lean:260`, `:3280-3281` | docstring prose only |

No drift from the single projection site the plan carries. `Tests/` has no hit on `(K4)`.
The projection at `LadderWindow.lean:1835` is positional and therefore silently fragile: it is
indexed by the conjunct count of `(K1)`-`(K4)`, not by a name.

## 2. The deletion diff (applied for the trial, then reverted)

```diff
diff --git a/FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean b/FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean
index c0ca08953..e2b15924e 100644
--- a/FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean
+++ b/FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean
@@ -918,7 +918,7 @@ anchors: `gate1_cell_ne`, which reads the gap at distance two, and the wired pro
 the depth-`0` cell obligation at a gap clip bounded by `dBack` alone — the cell reads the register
 forward through the next region's pin, so the clip must dominate the forward depth too. -/
 def paramsOkK4 (φ : PlusFormula) (B : ℕ) : Prop :=
-  2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧ 2 ≤ B
+  2 ≤ B
 
 /-- **THE PARAMETER CONDITIONS**, the conjunction of the four sources (K1)-(K4). This is NOT a
 predicate on four naturals: (K1) quantifies the certificate graph's cycle lengths on saturated
@@ -940,7 +940,7 @@ theorem paramsOk_params {Q : Type} [Fintype Q] [Nonempty Q] (step : Q → Q →
     ParamsOk step pend lab φ (Tcof step pend lab φ) (Tnof step pend lab φ)
       (Pof step pend lab φ) (Bof step pend lab φ) := by
   classical
-  refine ⟨⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_⟩, ?_, ?_, ?_⟩
+  refine ⟨⟨?_, ?_, ?_⟩, ⟨?_, ?_, ?_⟩, ⟨?_, ?_⟩, ?_⟩
   · intro l hl
     rw [Pof.succ, modulusOf]
     exact Dvd.dvd.mul_right (Finset.dvd_lcm (mem_cycleLensF_of_prod step pend lab φ hl)) _
@@ -959,8 +959,6 @@ theorem paramsOk_params {Q : Type} [Fintype Q] [Nonempty Q] (step : Q → Q →
   · unfold Tnof; omega
   -- (K3)'s `2 T_short + T_idle + 2`: inner `max`, right arm, right.
   · exact le_trans (le_trans (le_max_right _ _) (le_max_right _ _)) (le_max_left _ _)
-  · exact le_max_left _ _
-  · exact le_trans (le_max_left _ _) (le_max_right _ _)
   · exact le_trans (le_max_right _ _) (le_max_right _ _)
 
 /-- **`ParamsOk` IS CLOSED UNDER INFLATING THE MODULUS, GIVEN THE INFLATED ROOM.** `P` may be
diff --git a/FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean b/FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean
index cac30d90a..af45a054e 100644
--- a/FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean
+++ b/FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean
@@ -1832,7 +1832,7 @@ theorem cellSubset_of_kappa_eq_window_raise {Q : Type} [Fintype Q] [Nonempty Q]
     (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) :
     CellSubsetOfKappaEqWindowRaise step pend fwd bwd lab φ Tc Tn P B := by
   intro hp hno q c n c' h h' z hk hwin hwin' hTc hTc' hwup hwdn
-  have hB : 2 ≤ B := hp.2.2.2.2.2
+  have hB : 2 ≤ B := hp.2.2.2
   rcases kappa_collision_window_room Tc Tn P B c n c' hB hk hwin hwin' with heq | ⟨j, hjpos, hcase⟩
   · -- the collision PINS the two countdowns: one state, hence both inclusions by `rfl`
     subst heq
```

**Deviation from the task text, recorded.** The task says to adjust ONLY what the positional
projection requires. One further edit was needed and made: the PRODUCER `paramsOk_params` proves
`(K4)` conjunct by conjunct, so deleting two conjuncts leaves two of its bullets with no goal.
Its `refine` pattern and those two bullets were trimmed. This is not the repair of a breaking
consumer (which the phase prohibits): a producer that fails in `CounterQuotient.lean` would stop
Lake before any downstream module is elaborated, and the trial would then measure nothing.
`paramsOk_inflate` and `paramsOk_inflate_raise` needed no edit.

## 3. Build verdicts under the deletion

| Command | Exit status | Tail |
|---|---|---|
| `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` | `0` | `Build completed successfully (2975 jobs).` / `lake-build-guard: STATUS: exit_status=0`; zero `error` lines; `CounterQuotient`, `LadderAgree`, `LadderRealize`, `LadderWindow` all re-`Built` |
| `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest` | `0` | `Build completed successfully (3043 jobs).` / `lake-build-guard: STATUS: exit_status=0`; zero `error` lines |
| `bash scripts/check-evidence-probes.sh` | `1` | `FAIL  1 of 64 wired probe(s) failed` — `seam-gluing-ray-product/ladder-cell-obligation-refutation      FAIL (does not compile)` |

The only new warning in the library is the unused-variable linter on `paramsOkK4`'s `φ`.

## 4. The one failing declaration, and why it is not a counter-instance to outcome (a)

`Probe836A.not_paramsOkK4_two` (`specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean:164`),
statement `¬ paramsOkK4 chiD 2`. Under the deletion:

```
ladder-cell-obligation-refutation.lean:166:10: error: Invalid projection ... The expression
  h
has type `Nat.le 2 2` which is not a one-constructor inductive type.
ladder-cell-obligation-refutation.lean:164:52: error: unsolved goals
h : paramsOkK4 chiD 2
⊢ False
```

This is not a proof that CONSUMES the depth conjuncts as a hypothesis toward some other
conclusion. It is a statement ABOUT the predicate — that `(K4)` rejects the gap clip `2` at the
separating formula `chiD` (`dBack chiD = 0`, `dFwd chiD = 4`) — and under the deletion it is not
merely unproved but FALSE (`paramsOkK4 chiD 2` is `2 ≤ 2`). Every other declaration of that probe
still compiles, and the other 63 wired probes pass. The failure is the trial measuring exactly
what the forward conjunct was added for: excluding a clip at which a compiled cell collision
exists (`Probe836A.cellLEZeroConstOfKappaEqPre_refuted`).

## 5. Consequence for Phase 11.35

Four rounds of parameter work were conducted against two conjuncts that no landed library or
test proof ever read: the only conjunct of `(K4)` consumed is `2 ≤ B`, at one positional site.
`(K4)`'s depth content is PROSPECTIVE — it exists for the agreement being derived, and its only
compiled obligation today is exclusion: it must keep rejecting clips at which a compiled
collision exists. Phase 11.35 may therefore state the repaired clip freely within Ruling 10's
shape `2 * (dBack φ + dFwd φ) + 2 ≤ B ∧ 2 ≤ B`, subject to two facts this trial surfaces:
(i) the repaired shape must keep `Probe836A.not_paramsOkK4_two` true — it does, since
`2 * (0 + 4) + 2 = 10 > 2`, though that probe's proof projects `h.2.1` positionally and will need
its projection followed; (ii) the repaired shape has two conjuncts where the filed one has three,
so `LadderWindow.lean:1835`'s `hp.2.2.2.2.2` becomes `hp.2.2.2.2`, and `Bof` must grow with it
(`Probe836A.Bof_chiD` pins `Bof … chiD = 9`, below the repaired requirement `10`, so
`paramsOk_params` does not survive the repair at the filed `Bof`, and `Bof_chiD` and
`kappa_D_dissolves` are to be followed).

## 6. Restoration

The trial diff was reversed with `git apply -R`. After the revert:

- `git diff --stat -- FormalSystem/Metalogic/Decidability/RaySummary` is empty
  (`CounterQuotient.lean` and `LadderWindow.lean` unchanged against HEAD);
- `grep -n -A1 'def paramsOkK4'` shows the filed shape
  `2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧ 2 ≤ B`;
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits `0`
  (`Build completed successfully (2975 jobs).`, zero `error` lines, `CounterQuotient` and
  `LadderWindow` re-`Built` from the restored sources);
- `lake env lean specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean`
  compiles with no error and no `sorryAx`.
