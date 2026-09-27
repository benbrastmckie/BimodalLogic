/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.CanonicalWire.Parse

/-!
# Canonical Wire Format, Layer 1: the round trip

The theorems that say the canonical printer is a section of the total parser. Everything here is
generic in the JSON value: the certificate schema appears nowhere, which is the whole point of the
two-layer split — the lexical reasoning is done once, and `Cert.lean` only applies it.

## The shape of every lemma here

`parse (print x ++ rest) = .ok (x, rest)`. The trailing `rest` is what makes the lemmas compose:
an element of an array is printed with the rest of the array behind it, and the induction hypothesis
has to say what the parser does in exactly that situation. A lemma stated only for `rest = []`
would be useless one level up.

## The one side condition, and why it is real

`parseCJson_printCJson` carries `NoDigitHead rest`: the remainder must not begin with a decimal
digit. This is not a proof convenience but a fact about the format. `printCJson (.int 1) ++ ['2']`
is the byte string `12`, and any correct parser reads that as the integer twelve — so the
unconditional statement is false at the integer leaf. Every *use* discharges the condition for
free: an element is always followed by `,` or `]`, a field value by `,` or `}`, and a whole
document by nothing at all.

## Main Results

- `unescapeBody_escapeChar`, `unescapeBody_escapeBody`, `unescape_escape` — the escape codec is a
  round trip on every character list, including the `\u00XX` control-character form
- `parseDigits_printDigits`, `parseInt_printInt` — the decimal codec is a round trip
- `size_le_print_length`, `sizeList_le_print_length`, `sizeObj_le_print_length` — the measure
  bound `Fuel.lean` needs: a value's fuel budget never exceeds its own printed length
- `printCJson_head`, `printCJsonList_cons_head_ne`, `printCJsonObj_cons_head` — the arm-overlap
  side conditions, with explicit witnesses rather than left to `simp`

## References

* `BimodalTools/CanonicalWire/Json.lean` — the printer and the measure
* `BimodalTools/CanonicalWire/Parse.lean` — the parser
* `BimodalTools/CanonicalWire/Fuel.lean` — fuel sufficiency, which composes these
-/

set_option autoImplicit false

namespace BimodalTools.CanonicalWire

/-!
## The string escape codec
-/

/-- The hexadecimal codec is a round trip below `16`. Sixteen cases, each decided. -/
theorem hexVal_hexDigit (n : Nat) (h : n < 16) : hexVal (hexDigit n) = some n := by
  interval_cases n <;> decide

/-- Reading the canonical escape of one character consumes exactly that escape and prepends the
character. The single-character version of the round trip, with the remainder left abstract, which
is what lets the list version be a three-line induction. -/
theorem unescapeBody_escapeChar (c : Char) (t : List Char) :
    unescapeBody (escapeChar c ++ t) = consResult c (unescapeBody t) := by
  unfold escapeChar
  split_ifs with h1 h2 h3 h4 h5 h6 h7 h8
  · subst h1; conv_lhs => rw [unescapeBody.eq_def]
    simp [unescapeAfterBackslash, simpleEscape]
  · subst h2; conv_lhs => rw [unescapeBody.eq_def]
    simp [unescapeAfterBackslash, simpleEscape]
  · subst h3; conv_lhs => rw [unescapeBody.eq_def]
    simp [unescapeAfterBackslash, simpleEscape]
  · subst h4; conv_lhs => rw [unescapeBody.eq_def]
    simp [unescapeAfterBackslash, simpleEscape]
  · subst h5; conv_lhs => rw [unescapeBody.eq_def]
    simp [unescapeAfterBackslash, simpleEscape]
  · subst h6; conv_lhs => rw [unescapeBody.eq_def]
    simp [unescapeAfterBackslash, simpleEscape, chBackspace]
  · subst h7; conv_lhs => rw [unescapeBody.eq_def]
    simp [unescapeAfterBackslash, simpleEscape, chFormFeed]
  · have hd : hexVal (hexDigit (c.toNat / 16)) = some (c.toNat / 16) :=
      hexVal_hexDigit _ (by omega)
    have hg : hexVal (hexDigit (c.toNat % 16)) = some (c.toNat % 16) :=
      hexVal_hexDigit _ (by omega)
    have hsum : 16 * (c.toNat / 16) + c.toNat % 16 = c.toNat := Nat.div_add_mod _ _
    conv_lhs => rw [unescapeBody.eq_def]
    simp [unescapeAfterBackslash, unescapeUEscape, hd, hg, hsum, h8, Char.ofNat_toNat]
  · conv_lhs => rw [unescapeBody.eq_def]
    simp [h1, h2, h8]

/-- **The escape round trip, in the prefix form the generic theorem uses.** Reading a canonical
string literal's body returns the characters that were escaped and the bytes after the closing
quote. No well-formedness hypothesis is needed: `escapeBody` never emits a bare `"`, so the reader
cannot stop early, and it never emits a raw control character, so the reader cannot reject. -/
theorem unescapeBody_escapeBody (s rest : List Char) :
    unescapeBody (escapeBody s ++ '"' :: rest) = .ok (s, rest) := by
  induction s with
  | nil =>
    conv_lhs => rw [unescapeBody.eq_def]
    simp [escapeBody]
  | cons c cs ih =>
    rw [escapeBody, List.append_assoc, unescapeBody_escapeChar, ih, consResult]

/-- **The escape codec is a round trip.** The `rest = []` case of `unescapeBody_escapeBody`.

The closing quote is written explicitly because `unescapeBody` *consumes* it: it reads the body of
a string literal up to and including the delimiter, so `unescapeBody (escapeBody s)` alone runs off
the end of the input and reports an unterminated literal. The delimiter is part of the printed
form (`printCJson (.str s)` emits it), so nothing about the codec's coverage is weakened by naming
it here. -/
theorem unescape_escape (s : List Char) :
    unescapeBody (escapeBody s ++ ['"']) = .ok (s, []) :=
  unescapeBody_escapeBody s []

/-!
## The decimal codec
-/

/-- The digit codec is a round trip below `10`. -/
theorem charDigit_digitChar (d : Nat) (h : d < 10) : charDigit (digitChar d) = d := by
  interval_cases d <;> decide

/-- Every decimal character the printer emits is a digit. -/
theorem isDigit_digitChar (d : Nat) (h : d < 10) : (digitChar d).isDigit = true := by
  interval_cases d <;> decide

/-- The digit codec is a round trip pointwise along a list of digit values. -/
theorem map_charDigit_map_digitChar (l : List Nat) (h : ∀ d ∈ l, d < 10) :
    (l.map digitChar).map charDigit = l := by
  induction l with
  | nil => simp
  | cons a as ih =>
    simp only [List.map_cons]
    rw [charDigit_digitChar a (h a (by simp)), ih (fun d hd => h d (by simp [hd]))]

/-- A canonical numeral is never empty. -/
theorem printDigits_ne_nil (n : Nat) : printDigits n ≠ [] := by
  unfold printDigits
  split_ifs with h
  · simp
  · simp [Nat.digits_ne_nil_iff_ne_zero.mpr h]

/-- A canonical numeral consists of digits. -/
theorem printDigits_isDigit (n : Nat) : ∀ c ∈ printDigits n, c.isDigit = true := by
  unfold printDigits
  split_ifs with h
  · intro c hc
    simp only [List.mem_singleton] at hc
    subst hc; decide
  · intro c hc
    simp only [List.mem_reverse, List.mem_map] at hc
    obtain ⟨d, hd, rfl⟩ := hc
    exact isDigit_digitChar d (Nat.digits_lt_base (by norm_num) hd)

/-- Reading a canonical numeral's digits recovers the number, through `Nat.ofDigits_digits`. -/
theorem natOfDigitChars_printDigits (n : Nat) : natOfDigitChars (printDigits n) = n := by
  unfold natOfDigitChars printDigits
  split_ifs with h
  · subst h; simp [charDigit]
  · rw [List.reverse_reverse,
      map_charDigit_map_digitChar _ (fun _ hd => Nat.digits_lt_base (by norm_num) hd),
      Nat.ofDigits_digits]

/-- A canonical integer numeral is never empty. -/
theorem printInt_ne_nil (i : Int) : printInt i ≠ [] := by
  unfold printInt
  split_ifs <;> simp [printDigits_ne_nil]

/-- A canonical numeral's first character, with the fact that it is a digit. -/
theorem printDigits_head (n : Nat) : ∃ c r, printDigits n = c :: r ∧ c.isDigit = true := by
  cases hp : printDigits n with
  | nil => exact absurd hp (printDigits_ne_nil n)
  | cons c r =>
    refine ⟨c, r, rfl, printDigits_isDigit n c ?_⟩
    rw [hp]; exact List.mem_cons_self

/-- A canonical integer numeral's first character: a minus sign or a digit, and nothing else.
This is what tells `parseCJson`'s dispatch that a printed integer is not a string, an array, an
object or a keyword. -/
theorem printInt_head (i : Int) :
    ∃ c r, printInt i = c :: r ∧ (c = '-' ∨ c.isDigit = true) := by
  unfold printInt
  split_ifs with h
  · exact ⟨'-', printDigits i.natAbs, rfl, Or.inl rfl⟩
  · obtain ⟨c, r, hcr, hd⟩ := printDigits_head i.natAbs
    exact ⟨c, r, hcr, Or.inr hd⟩

/-- Splitting off a digit run finds exactly the digits that were printed, provided the remainder
cannot extend the numeral. -/
theorem takeDigits_append (ds rest : List Char) (hd : ∀ c ∈ ds, c.isDigit = true)
    (hr : ∀ c ∈ rest.head?, ¬ (c.isDigit = true)) : takeDigits (ds ++ rest) = (ds, rest) := by
  induction ds with
  | nil =>
    cases rest with
    | nil => simp [takeDigits]
    | cons c cs =>
      have hc : ¬ (c.isDigit = true) := hr c rfl
      simp [takeDigits, hc]
  | cons c cs ih =>
    have hc : c.isDigit = true := hd c (by simp)
    simp [takeDigits, hc, ih (fun x hx => hd x (by simp [hx]))]

/-- **The decimal codec is a round trip**, given a remainder that cannot extend the numeral.

The canonicality check inside `parseDigits` — "reprinting what was read reproduces the bytes" — is
free here: the bytes *are* what the printer emitted. -/
theorem parseDigits_printDigits (n : Nat) (rest : List Char)
    (h : ∀ c ∈ rest.head?, ¬ (c.isDigit = true)) :
    parseDigits (printDigits n ++ rest) = .ok (n, rest) := by
  rw [parseDigits, takeDigits_append _ _ (printDigits_isDigit n) h]
  simp [List.isEmpty_iff, printDigits_ne_nil n, natOfDigitChars_printDigits n]

/-- **The signed decimal codec is a round trip**, under the same side condition. -/
theorem parseInt_printInt (i : Int) (rest : List Char)
    (h : ∀ c ∈ rest.head?, ¬ (c.isDigit = true)) :
    parseInt (printInt i ++ rest) = .ok (i, rest) := by
  unfold printInt
  split_ifs with hneg
  · rw [List.cons_append, parseInt]
    have hnz : i.natAbs ≠ 0 := by omega
    simp only [parseDigits_printDigits _ _ h, hnz, if_false, if_true]
    have hi : -(i.natAbs : Int) = i := by omega
    rw [hi]
  · cases hp : printDigits i.natAbs with
    | nil => exact absurd hp (printDigits_ne_nil _)
    | cons c cs =>
      have hcd : c.isDigit = true := by
        refine printDigits_isDigit i.natAbs c ?_
        rw [hp]; exact List.mem_cons_self
      have hcm : ¬ (c = '-') := by
        intro hcc; rw [hcc] at hcd; exact absurd hcd (by decide)
      rw [List.cons_append, parseInt, if_neg hcm,
        show c :: (cs ++ rest) = printDigits i.natAbs ++ rest from by rw [hp]; simp,
        parseDigits_printDigits _ _ h]
      have hi : ((i.natAbs : Nat) : Int) = i := by omega
      simp [hi]

/-!
## The measure bound

`Fuel.lean` composes this with the round-trip theorem to show the public entry point's fuel is
always enough. The bound is what forced `size`'s empty cases to `0`: at the empty array, `[]` is
two bytes, and a measure charging one unit per node would have demanded three.
-/

mutual

/-- A value's fuel budget never exceeds its own printed length. -/
theorem size_le_print_length : ∀ j : CJson, size j ≤ (printCJson j).length
  | .str _ => by simp [size, printCJson]
  | .int i => by
    have h : 0 < (printInt i).length := List.length_pos_of_ne_nil (printInt_ne_nil i)
    simp only [size, printCJson]
    omega
  | .bool b => by cases b <;> simp [size, printCJson]
  | .arr xs => by
    have h := sizeList_le_print_length xs
    simp only [size, printCJson, List.length_cons]
    omega
  | .obj fs => by
    have h := sizeObj_le_print_length fs
    simp only [size, printCJson, List.length_cons]
    omega

/-- An array's fuel budget never exceeds its own printed length. -/
theorem sizeList_le_print_length : ∀ xs : CJsonList, sizeList xs ≤ (printCJsonList xs).length
  | .nil => by simp [sizeList, printCJsonList]
  | .cons x .nil => by
    have h := size_le_print_length x
    simp only [sizeList, printCJsonList, List.length_append, List.length_cons, List.length_nil]
    omega
  | .cons x (.cons y ys) => by
    have hx := size_le_print_length x
    have h2 := sizeList_le_print_length (.cons y ys)
    have hs : sizeList (CJsonList.cons x (.cons y ys))
        = size x + sizeList (CJsonList.cons y ys) + 1 := by simp only [sizeList]
    have hp : printCJsonList (CJsonList.cons x (.cons y ys))
        = printCJson x ++ ',' :: printCJsonList (CJsonList.cons y ys) := by
      simp only [printCJsonList]
    rw [hs, hp]
    simp only [List.length_append, List.length_cons]
    omega

/-- An object's fuel budget never exceeds its own printed length. -/
theorem sizeObj_le_print_length : ∀ fs : CJsonObj, sizeObj fs ≤ (printCJsonObj fs).length
  | .nil => by simp [sizeObj, printCJsonObj]
  | .cons _ v .nil => by
    have h := size_le_print_length v
    simp only [sizeObj, printCJsonObj, printKey, List.length_append, List.length_cons,
      List.length_nil]
    omega
  | .cons k v (.cons k2 v2 fs) => by
    have hv := size_le_print_length v
    have h2 := sizeObj_le_print_length (.cons k2 v2 fs)
    have hs : sizeObj (CJsonObj.cons k v (.cons k2 v2 fs))
        = size v + sizeObj (CJsonObj.cons k2 v2 fs) + 1 := by simp only [sizeObj]
    have hp : printCJsonObj (CJsonObj.cons k v (.cons k2 v2 fs))
        = printKey k ++ printCJson v ++ ',' :: printCJsonObj (CJsonObj.cons k2 v2 fs) := by
      simp only [printCJsonObj]
    rw [hs, hp]
    simp only [List.length_append, List.length_cons]
    omega

end

/-!
## The arm-overlap side conditions

Each with an explicit witness. `parseCJson` checks `cs.head? = some ']'` to recognise the empty
array before descending, so the round-trip proof owes it the fact that a *non-empty* printed
element list does not begin with `]`. The object case is easier: a printed field list always
begins with the quote of its first key.
-/

/-- A printed value's first character, and the fact that it is not a closing bracket. -/
theorem printCJson_head (j : CJson) : ∃ c r, printCJson j = c :: r ∧ c ≠ ']' := by
  cases j with
  | str s => exact ⟨'"', escapeBody s ++ ['"'], rfl, by decide⟩
  | int i =>
    obtain ⟨c, r, hcr, hd⟩ := printInt_head i
    refine ⟨c, r, hcr, ?_⟩
    rcases hd with h | h
    · rw [h]; decide
    · intro hc; rw [hc] at h; exact absurd h (by decide)
  | bool b =>
    cases b
    · exact ⟨'f', ['a', 'l', 's', 'e'], rfl, by decide⟩
    · exact ⟨'t', ['r', 'u', 'e'], rfl, by decide⟩
  | arr xs => exact ⟨'[', printCJsonList xs, rfl, by decide⟩
  | obj fs => exact ⟨'{', printCJsonObj fs, rfl, by decide⟩

/-- A non-empty printed element list never begins with `]`, whatever follows it. -/
theorem printCJsonList_cons_head_ne (x : CJson) (xs : CJsonList) (rest : List Char) :
    (printCJsonList (.cons x xs) ++ rest).head? ≠ some ']' := by
  obtain ⟨c, r, hcr, hne⟩ := printCJson_head x
  cases xs with
  | nil => simp only [printCJsonList, hcr]; simp [hne]
  | cons y ys => simp only [printCJsonList, hcr]; simp [hne]

/-- A non-empty printed field list always begins with the quote of its first key. -/
theorem printCJsonObj_cons_head (k : List Char) (v : CJson) (fs : CJsonObj) (rest : List Char) :
    (printCJsonObj (.cons k v fs) ++ rest).head? = some '"' := by
  cases fs <;> simp [printCJsonObj, printKey]

end BimodalTools.CanonicalWire
