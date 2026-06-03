# Task 269: Export Interestingness Scores to JSONL — Research Report

## Summary

The bug is confirmed. `DatasetRecord` is missing two fields that `LabeledFormula` populates on every formula:
- `interestingnessScore : Option Nat` — composite score on 0-1000 scale
- `interestingnessTier : Option String` — tier string (e.g., "High", "Medium")

The fix requires exactly **3 edit points** in `DatasetExport.lean`, all self-contained.

---

## Edit Points

### 1. `DatasetRecord` structure (line ~213)

Add after `proof_reconstruction_method : Option String`:

```lean
  /-- Interestingness composite score on 0-1000 scale (None if not computed). -/
  interestingness_score : Option Nat
  /-- Interestingness tier classification (None if not computed). -/
  interestingness_tier : Option String
```

### 2. `Inhabited DatasetRecord` instance (line ~215)

Add two fields to the default value after `proof_reconstruction_method := none`:

```lean
     interestingness_score := none
     interestingness_tier := none
```

### 3. `datasetRecordToJson` (line ~268, after `reconStr` serialization)

Add two `let` bindings before the string concatenation:

```lean
  let intScoreStr := match r.interestingness_score with
    | none => "null"
    | some s => toString s
  let intTierStr := match r.interestingness_tier with
    | none => "null"
    | some t => "\"" ++ escapeJsonString t ++ "\""
```

Then append to the JSON string (e.g., after `formula_folded_sexpr`):

```lean
  ++ ", \"interestingness_score\": " ++ intScoreStr
  ++ ", \"interestingness_tier\": " ++ intTierStr
```

### 4. `labeledToRecord` (line ~301)

Add two fields in the record body after `proof_reconstruction_method`:

```lean
    interestingness_score := lf.interestingnessScore
    interestingness_tier := lf.interestingnessTier
```

> Note: This is a 4th edit point (the problem statement said 3), but it is the key transfer step — without it the fields are always `none`.

---

## Verification

`LabeledFormula.toJson` (DatasetGenerator.lean lines 810-815) already serializes both fields correctly. The pattern to follow is established there.

`labeledToRecord` is called in three places (lines 368, 1087, 1127 of DatasetExport.lean) but all go through the same function — only one edit is needed there, not three.

No other files construct `DatasetRecord` directly; the struct is defined and consumed entirely within `DatasetExport.lean`.

---

## Lean Compatibility Notes

- `Option Nat` and `Option String` are straightforward — no typeclass issues.
- `DatasetRecord` derives `Repr` but not `Inhabited` structurally (instance is hand-written), so both new fields need explicit defaults in the `Inhabited` instance.
- No `deriving` changes needed.
