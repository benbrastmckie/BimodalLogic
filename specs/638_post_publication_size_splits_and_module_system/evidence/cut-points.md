# Cut points (re-derived from the live files at HEAD 0a81522c8)

Both files were unmodified relative to `HEAD` (5,094 / 4,906 lines). Cuts were located by
declaration name and `/-!` section opener, not by the report's line numbers (which agree).

## `EFGames/GapDetection.lean`

Shared preamble: L1-5 copyright, L7 `import ...EFGames.TypeFormulas`, L9-13 module docstring,
L15 `set_option linter.style.longFile 5200`, L17 `namespace FormalSystem.Metalogic.Expressiveness`,
L19 `open FormalSystem.Syntax`. Closing `end` at L5094.

| Family | Lines | First line of text | Last line of text | Declarations |
|--------|-------|--------------------|-------------------|--------------|
| F-defs | 21-360 | `/-! ## Gap Detection Formulas (GHR93 Definition 8.5)` | `    omega` (L359, end of `stavi_depth_right_formula`) | `leftFormulaBase`, `leftFormula`, `rightFormulaBase`, `rightFormula`, private `operator_depth_flatten_stavi_le`, private `stavi_depth_left_formula_base`, `stavi_depth_left_formula`, `stavi_depth_right_formula` |
| F-mu | 361-772 | `/-! ### Mu-Relativized Truth at Actual Points` | `        ((extendPoint_lt_iff u' m).mp hum))` (L771) | `extendPoint_lt_iff`, `temporal_truth_mu_at_point`, `stavi_truth_mu_at_point` |
| F-left | 773-2878 | `/-! ### Gap Uniqueness for Lemma 9` | `            (lt_of_le_of_lt hut (lt_trans ht_uf huf_s₁)) hu_not⟩` (L2877) | `gap_detection_unique`, `stavi_untl_gap_detection`, `left_formula_gap_detection` |
| F-right | 2879-5093 | `/-! ### GHR93 Lemma 9 (Gap detection correctness, right direction)` | `          (hB_mu (extendPoint v) hvt₁ hγv ⟨v, rfl⟩)` (L5091) | `stavi_snce_gap_detection`, `gap_detection_unique_right`, `right_formula_gap_detection` |

Probes (pre-edit gate):
- F-right mentions `stavi_untl_gap_detection` only in a docstring and a `--` comment (three prose
  hits, zero term uses), so F-right does not depend on F-left.
- F-mu mentions none of the F-defs names; it needs only `TypeFormulas`.
- Neither F-left nor F-right mentions either private helper, so both can stay in
  `GapDetection.lean` with their mangled names unchanged.
- Public declaration scan: 15 public + 2 private, matching the plan's hypothesis.

## `GameTransfer/SplitPoint.lean`

Preamble: L1-5 copyright, L7 `import ...GameTransfer.DConsistencyTransport`, L9-13 module
docstring, L15 `set_option linter.style.longFile 5100`, L17 namespace, L19 `open`. Closing `end`
at L4906.

| Block | Lines | First line of text | Last line of text |
|-------|-------|--------------------|-------------------|
| structure | 21-129 | `/-! ## GHR93 Theorem 6: Inductive Step Infrastructure` | `        a'_full ⟨1 + 3 * n, by omega⟩ = d` (L128, last field of `SplitPointProps`) |
| theorem | 130-4905 | `set_option maxHeartbeats 800000 in` | `  refine ⟨c_inf, hc_inf_interval, hform_cd, hgp_cd, hbdy_cd, h_interior_left, h_interior_right⟩` (L4903) |

The theorem block opens with the contiguous run: L130 `set_option maxHeartbeats 800000 in`,
L131-133 the three-line `--` reason comment, L134-159 the docstring, L160
`theorem obtain_split_point_props`.
