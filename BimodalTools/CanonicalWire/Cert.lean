/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.CanonicalWire.Fuel
import BimodalTools.CertificateRecords

/-!
# Canonical Wire Format, Layer 2: the certificate schema

`encodeCert` / `decodeCert` over the canonical JSON value, the canonical certificate printer and
parser built from them, and the five theorems that state the export contract as mathematics rather
than as prose.

## Why there are two layers

Every lexical question — escapes, numerals, whitespace, fuel, trailing bytes — was answered once,
generically, in `RoundTrip.lean` and `Fuel.lean`. Nothing in this module reasons about characters.
`decode_encode` is structural induction over `RawCertificate` and its components, and no goal in
its proof mentions the parser's fuel argument. `parse_print` is then one composition of the two
layers. That factoring is what makes a verified codec finite work rather than an open-ended one.

## The export contract, unchanged

Field names, requiredness and defaults are frozen exactly as they were:

- `target` — **required**. Its `time` is **required and undefaulted**, because it is the target
  condition's existential witness; its `premises` and `conclusions` default to `[]`, because `[]`
  is the identity of a context and `0` is not the identity of a time.
- `bx` — the box guess, sparse: a formula not listed reads `false`.
- `lassos` — index `0` is the main lasso; each lasso's `back`, `mid`, `fwd` default to `[]`.
- Atom identity is base-only: `Atom.freshIndex` has no field on the wire, so a certificate
  carrying a fresh or Skolem atom is **rejected outright** rather than silently re-identified.
- Unrecognised keys are ignored at the envelope, target and lasso levels — but only after the
  generic parser has fully parsed their values, which is what closes the defect where malformed
  JSON hid inside a field the checker did not read. Inside a *formula* they are not ignored: a
  formula object must carry precisely its tag's own keys.

The two required-field error messages are produced by the existing `PartialTarget.complete` and
`PartialCertificate.complete`, unchanged, so a producer sees the same bytes it saw before.

## Main Definitions

- `encodeFormula`, `decodeFormula` — the tag-format formula codec, structurally recursive
- `encodeTarget`, `encodeLasso`, `encodeBx`, `encodeCert` and their readers — the schema codec
- `printCertificate`, `parseCertificateCanonical` — the two directions of the wire format

## Main Results

- `decode_encode` — decoding an encoded certificate returns it
- `parse_print` — parsing a printed certificate returns that same certificate
- `printCertificate_injective` — the printer is injective on base-atom certificates
- `print_parse_canonical` — on canonical bytes the echo is byte-identical to what was sent
- `parse_base_only` — atom identity is base-only on anything the parser returns

## References

* `BimodalTools/CanonicalWire/Fuel.lean` — the layer-1 entry-point round trip this composes with
* `BimodalTools/CertificateRecords.lean` — the records this codec is about
* `BimodalTools/README.md` — the certificate protocol and the joint canonical contract
-/

set_option autoImplicit false

namespace BimodalTools.CanonicalWire

open FormalSystem.Syntax
open BimodalTools.CertificateImport

/-!
## The formula codec

The tag format, exactly as `BimodalTools.DataExport`'s `Formula.toJson` emits it and
`BimodalTools/README.md` documents it.
-/

/-- The `"tag"` key of a formula object. -/
def keyTag : List Char := "tag".toList
/-- The `"name"` key of an `atom` formula: its base name, and nothing else. -/
def keyName : List Char := "name".toList
/-- The `"left"` key of an `imp` formula. -/
def keyLeft : List Char := "left".toList
/-- The `"right"` key of an `imp` formula. -/
def keyRight : List Char := "right".toList
/-- The `"child"` key of a `box` formula. -/
def keyChild : List Char := "child".toList
/-- The `"event"` key of an `untl` or `snce` formula: the *second* Lean argument. -/
def keyEvent : List Char := "event".toList
/-- The `"guard"` key of an `untl` or `snce` formula: the *first* Lean argument. -/
def keyGuard : List Char := "guard".toList
/-- The `atom` tag. -/
def tagAtom : List Char := "atom".toList
/-- The `bot` tag. -/
def tagBot : List Char := "bot".toList
/-- The `imp` tag. -/
def tagImp : List Char := "imp".toList
/-- The `box` tag. -/
def tagBox : List Char := "box".toList
/-- The `untl` tag. -/
def tagUntl : List Char := "untl".toList
/-- The `snce` tag. -/
def tagSnce : List Char := "snce".toList

/-- The canonical value of a formula, in the frozen tag format.

The key order mirrors `BimodalTools.DataExport`'s `Formula.toJson` exactly, including the fact
that `"event"` carries an `untl`/`snce`'s *second* argument and `"guard"` its first. An atom
contributes its base name only: `Atom.freshIndex` has no field on the wire, which is what makes
atom identity base-only. -/
def encodeFormula : Formula → CJson
  | .atom a => .obj (.cons keyTag (.str tagAtom) (.cons keyName (.str a.base.toList) .nil))
  | .bot => .obj (.cons keyTag (.str tagBot) .nil)
  | .imp φ ψ => .obj (.cons keyTag (.str tagImp)
      (.cons keyLeft (encodeFormula φ) (.cons keyRight (encodeFormula ψ) .nil)))
  | .box φ => .obj (.cons keyTag (.str tagBox) (.cons keyChild (encodeFormula φ) .nil))
  | .untl ψ φ => .obj (.cons keyTag (.str tagUntl)
      (.cons keyEvent (encodeFormula φ) (.cons keyGuard (encodeFormula ψ) .nil)))
  | .snce ψ φ => .obj (.cons keyTag (.str tagSnce)
      (.cons keyEvent (encodeFormula φ) (.cons keyGuard (encodeFormula ψ) .nil)))

/-- Read a formula from a canonical value.

**Exact shape, not a field lookup.** A formula object must carry precisely the tag's own keys, in
canonical order and no others. That single rule closes three recorded defects at once: an `atom`
with no `"name"` (which the old parser silently decoded as the empty-base atom), an extra
sub-formula field on a tag that does not take one, and an atom carrying a `freshIndex` — the
last because any such key is simply not part of any tag's shape. Unknown keys *are* tolerated at
the envelope, target and lasso levels, where the export contract says to tolerate them; inside a
formula they are not, because a formula is data in the trust base rather than a place to hang
metadata.

Structural recursion: every recursive call is on a field of the matched object, so this is a
total `def` with equation lemmas and no fuel parameter. -/
def decodeFormula : CJson → Except String Formula
  | .obj (.cons kt (.str tag) rest) =>
    if kt ≠ keyTag then .error "a formula's first field must be \"tag\""
    else if tag = tagAtom then
      match rest with
      | .cons kn (.str nm) .nil =>
        if kn = keyName then .ok (Formula.atomS (String.ofList nm))
        else .error "an atom formula's second field must be \"name\""
      | _ => .error "an atom formula carries exactly \"tag\" and a string \"name\""
    else if tag = tagBot then
      match rest with
      | .nil => .ok Formula.bot
      | _ => .error "a bot formula carries exactly the field \"tag\""
    else if tag = tagImp then
      match rest with
      | .cons kl l (.cons kr r .nil) =>
        if kl = keyLeft ∧ kr = keyRight then
          match decodeFormula l with
          | .error m => .error m
          | .ok a =>
            match decodeFormula r with
            | .error m => .error m
            | .ok b => .ok (Formula.imp a b)
        else .error "an imp formula's fields must be \"left\" and \"right\""
      | _ => .error "an imp formula carries exactly \"tag\", \"left\" and \"right\""
    else if tag = tagBox then
      match rest with
      | .cons kc ch .nil =>
        if kc = keyChild then
          match decodeFormula ch with
          | .error m => .error m
          | .ok a => .ok (Formula.box a)
        else .error "a box formula's second field must be \"child\""
      | _ => .error "a box formula carries exactly \"tag\" and \"child\""
    else if tag = tagUntl then
      match rest with
      | .cons ke ej (.cons kg gj .nil) =>
        if ke = keyEvent ∧ kg = keyGuard then
          match decodeFormula ej with
          | .error m => .error m
          | .ok e =>
            match decodeFormula gj with
            | .error m => .error m
            | .ok g => .ok (Formula.untl g e)
        else .error "an untl formula's fields must be \"event\" and \"guard\""
      | _ => .error "an untl formula carries exactly \"tag\", \"event\" and \"guard\""
    else if tag = tagSnce then
      match rest with
      | .cons ke ej (.cons kg gj .nil) =>
        if ke = keyEvent ∧ kg = keyGuard then
          match decodeFormula ej with
          | .error m => .error m
          | .ok e =>
            match decodeFormula gj with
            | .error m => .error m
            | .ok g => .ok (Formula.snce g e)
        else .error "an snce formula's fields must be \"event\" and \"guard\""
      | _ => .error "an snce formula carries exactly \"tag\", \"event\" and \"guard\""
    else .error "unknown formula tag"
  | _ => .error "a formula must be an object whose first field is a string \"tag\""

/-- **The formula codec is a round trip** on base-atom formulas. Structural induction on the
formula;
no parser state appears anywhere in the proof. -/
theorem decodeFormula_encodeFormula (φ : Formula) (h : hasFreshAtom φ = false) :
    decodeFormula (encodeFormula φ) = .ok φ := by
  induction φ with
  | atom a =>
    simp only [hasFreshAtom, Option.isSome_eq_false_iff, Option.isNone_iff_eq_none] at h
    simp only [encodeFormula, decodeFormula, String.ofList_toList, Formula.atomS, Atom.mkBase,
      reduceIte, ne_eq, not_true_eq_false]
    cases a with
    | mk base idx => simp_all
  | bot => simp [encodeFormula, decodeFormula, tagBot, tagAtom]
  | imp a b iha ihb =>
    simp only [hasFreshAtom, Bool.or_eq_false_iff] at h
    simp only [encodeFormula, decodeFormula, iha h.1, ihb h.2]
    simp [tagImp, tagAtom, tagBot]
  | box c ihc =>
    simp only [hasFreshAtom] at h
    simp only [encodeFormula, decodeFormula, ihc h]
    simp [tagBox, tagAtom, tagBot, tagImp]
  | untl g e ihg ihe =>
    simp only [hasFreshAtom, Bool.or_eq_false_iff] at h
    simp only [encodeFormula, decodeFormula, ihg h.1, ihe h.2]
    simp [tagUntl, tagAtom, tagBot, tagImp, tagBox]
  | snce g e ihg ihe =>
    simp only [hasFreshAtom, Bool.or_eq_false_iff] at h
    simp only [encodeFormula, decodeFormula, ihg h.1, ihe h.2]
    simp [tagSnce, tagAtom, tagBot, tagImp, tagBox, tagUntl]

/-- The envelope's `"target"` key. **Required.** -/
def keyTarget : List Char := "target".toList
/-- The envelope's `"bx"` key: the box guess, sparse, unlisted formulas reading `false`. -/
def keyBx : List Char := "bx".toList
/-- The envelope's `"lassos"` key; index `0` is the main lasso. -/
def keyLassos : List Char := "lassos".toList
/-- The target's `"premises"` key. Optional, defaulting to `[]`. -/
def keyPremises : List Char := "premises".toList
/-- The target's `"conclusions"` key. Optional, defaulting to `[]`. -/
def keyConclusions : List Char := "conclusions".toList
/-- The target's `"time"` key. **Required and undefaulted**: it is the target condition's
existential witness. -/
def keyTime : List Char := "time".toList
/-- A lasso's `"back"` key: the leftward cycle. -/
def keyBack : List Char := "back".toList
/-- A lasso's `"mid"` key: the finite window. -/
def keyMid : List Char := "mid".toList
/-- A lasso's `"fwd"` key: the rightward cycle. -/
def keyFwd : List Char := "fwd".toList

/-- Find a key's value in an object, or `none`. Used at the envelope, target and lasso levels,
where unrecognised keys are tolerated — but only *after* the generic parser has fully parsed their
values, which is what closes the defect where malformed JSON hid inside an unread field. -/
def lookup (k : List Char) : CJsonObj → Option CJson
  | .nil => none
  | .cons k' v fs => if k = k' then some v else lookup k fs

/-- The canonical values of a formula list. -/
def encodeFormulas : List Formula → CJsonList
  | [] => .nil
  | φ :: φs => .cons (encodeFormula φ) (encodeFormulas φs)

/-- Read a formula list. -/
def decodeFormulas : CJsonList → Except String (List Formula)
  | .nil => .ok []
  | .cons x xs =>
    match decodeFormula x with
    | .error m => .error m
    | .ok φ =>
      match decodeFormulas xs with
      | .error m => .error m
      | .ok φs => .ok (φ :: φs)

/-- Read a formula list from a value that must be an array. -/
def decodeFormulaArray : CJson → Except String (List Formula)
  | .arr xs => decodeFormulas xs
  | _ => .error "expected an array of formulas"

/-- Read an optional formula list, absent reading as `[]`. -/
def decodeOptFormulaArray : Option CJson → Except String (List Formula)
  | none => .ok []
  | some j => decodeFormulaArray j

/-- The canonical values of a lasso segment: a list of labels, each a list of formulas. -/
def encodeSegment : List (List Formula) → CJsonList
  | [] => .nil
  | X :: Xs => .cons (.arr (encodeFormulas X)) (encodeSegment Xs)

/-- Read a lasso segment. -/
def decodeSegment : CJsonList → Except String (List (List Formula))
  | .nil => .ok []
  | .cons x xs =>
    match decodeFormulaArray x with
    | .error m => .error m
    | .ok X =>
      match decodeSegment xs with
      | .error m => .error m
      | .ok Xs => .ok (X :: Xs)

/-- Read a lasso segment from a value that must be an array. -/
def decodeSegmentValue : CJson → Except String (List (List Formula))
  | .arr xs => decodeSegment xs
  | _ => .error "a lasso segment must be an array of labels"

/-- Read an optional lasso segment, absent reading as `[]`. -/
def decodeOptSegment : Option CJson → Except String (List (List Formula))
  | none => .ok []
  | some j => decodeSegmentValue j

/-- The canonical value of one box-guess entry: the two-element array `[formula, bool]`. -/
def encodeBxPair (p : Formula × Bool) : CJson :=
  .arr (.cons (encodeFormula p.1) (.cons (.bool p.2) .nil))

/-- Read one box-guess entry. -/
def decodeBxPair : CJson → Except String (Formula × Bool)
  | .arr (.cons φj (.cons (.bool b) .nil)) =>
    match decodeFormula φj with
    | .error m => .error m
    | .ok φ => .ok (φ, b)
  | _ => .error "a box-guess entry must be the two-element array [formula, bool]"

/-- The canonical values of the box guess. -/
def encodeBx : List (Formula × Bool) → CJsonList
  | [] => .nil
  | p :: ps => .cons (encodeBxPair p) (encodeBx ps)

/-- Read the box guess. -/
def decodeBx : CJsonList → Except String (List (Formula × Bool))
  | .nil => .ok []
  | .cons x xs =>
    match decodeBxPair x with
    | .error m => .error m
    | .ok p =>
      match decodeBx xs with
      | .error m => .error m
      | .ok ps => .ok (p :: ps)

/-- Read the box guess from a value that must be an array. -/
def decodeBxValue : CJson → Except String (List (Formula × Bool))
  | .arr xs => decodeBx xs
  | _ => .error "certificate field \"bx\" must be an array"

/-- Read an optional box guess, absent reading as `[]` — the sparse reading the contract fixes. -/
def decodeOptBx : Option CJson → Except String (List (Formula × Bool))
  | none => .ok []
  | some j => decodeBxValue j

/-- The canonical value of one lasso: `back`, `mid`, `fwd`, in that frozen order. -/
def encodeLasso (L : RawLasso) : CJson :=
  .obj (.cons keyBack (.arr (encodeSegment L.back))
        (.cons keyMid (.arr (encodeSegment L.mid))
         (.cons keyFwd (.arr (encodeSegment L.fwd)) .nil)))

/-- Read one lasso. Each segment is optional and defaults to `[]`; unrecognised keys are ignored. -/
def decodeLasso : CJson → Except String RawLasso
  | .obj fs =>
    match decodeOptSegment (lookup keyBack fs) with
    | .error m => .error m
    | .ok back =>
      match decodeOptSegment (lookup keyMid fs) with
      | .error m => .error m
      | .ok mid =>
        match decodeOptSegment (lookup keyFwd fs) with
        | .error m => .error m
        | .ok fwd => .ok { back := back, mid := mid, fwd := fwd }
  | _ => .error "a lasso must be an object"

/-- The canonical values of the lasso list. Index `0` is the main lasso. -/
def encodeLassos : List RawLasso → CJsonList
  | [] => .nil
  | L :: Ls => .cons (encodeLasso L) (encodeLassos Ls)

/-- Read the lasso list. -/
def decodeLassos : CJsonList → Except String (List RawLasso)
  | .nil => .ok []
  | .cons x xs =>
    match decodeLasso x with
    | .error m => .error m
    | .ok L =>
      match decodeLassos xs with
      | .error m => .error m
      | .ok Ls => .ok (L :: Ls)

/-- Read the lasso list from a value that must be an array. -/
def decodeLassosValue : CJson → Except String (List RawLasso)
  | .arr xs => decodeLassos xs
  | _ => .error "certificate field \"lassos\" must be an array"

/-- Read an optional lasso list, absent reading as `[]`. -/
def decodeOptLassos : Option CJson → Except String (List RawLasso)
  | none => .ok []
  | some j => decodeLassosValue j

/-- The canonical value of the target condition: `premises`, `conclusions`, `time`, in that frozen
order. `time` is always emitted. -/
def encodeTarget (t : RawTarget) : CJson :=
  .obj (.cons keyPremises (.arr (encodeFormulas t.premises))
        (.cons keyConclusions (.arr (encodeFormulas t.conclusions))
         (.cons keyTime (.int t.time) .nil)))

/-- Read the target condition. `premises` and `conclusions` default to `[]`; `time` is required, and
the requirement is enforced by the existing `PartialTarget.complete`, so the error message a
producer sees is byte-for-byte the one it saw before this codec existed. -/
def decodeTarget : CJson → Except String RawTarget
  | .obj fs =>
    match decodeOptFormulaArray (lookup keyPremises fs) with
    | .error m => .error m
    | .ok prem =>
      match decodeOptFormulaArray (lookup keyConclusions fs) with
      | .error m => .error m
      | .ok conc =>
        match lookup keyTime fs with
        | some (.int t) =>
          PartialTarget.complete { premises := prem, conclusions := conc, time := some t }
        | some _ => .error "certificate field \"target\" has a non-integer \"time\""
        | none =>
          PartialTarget.complete { premises := prem, conclusions := conc, time := none }
  | _ => .error "certificate field \"target\" must be an object"

/-- The canonical value of a whole certificate: `target`, `bx`, `lassos`, in that frozen order. -/
def encodeCert (c : RawCertificate) : CJson :=
  .obj (.cons keyTarget (encodeTarget c.target)
        (.cons keyBx (.arr (encodeBx c.bx))
         (.cons keyLassos (.arr (encodeLassos c.lassos)) .nil)))

/-- Read a whole certificate.

The required-field checks go through the existing `PartialTarget.complete` and
`PartialCertificate.complete`, so both required-field messages are preserved verbatim.

The final guard is the export contract's atom-identity clause made executable: a certificate
carrying a fresh or Skolem atom is rejected outright rather than silently re-identified. On input
`decodeFormula` produced the guard is provably unreachable — `decodeFormula_base_only` below says
so — and it is kept for the same reason `mkFamily`'s `atomNotBase` fault is kept: the clause is
part of the contract, so it is checked where the contract states it rather than left to a
property of a different function. -/
def decodeCert : CJson → Except String RawCertificate
  | .obj fs =>
    match lookup keyTarget fs with
    | none => PartialCertificate.complete { target := none }
    | some tj =>
      match decodeTarget tj with
      | .error m => .error m
      | .ok tgt =>
        match decodeOptBx (lookup keyBx fs) with
        | .error m => .error m
        | .ok bx =>
          match decodeOptLassos (lookup keyLassos fs) with
          | .error m => .error m
          | .ok ls =>
            let c : RawCertificate := { target := tgt, bx := bx, lassos := ls }
            if c.formulas.all (fun φ => !hasFreshAtom φ) then .ok c
            else .error "an atom carries a fresh index, which the wire format does not preserve"
  | _ => .error "a certificate must be a JSON object"

/-- **The canonical bytes of a certificate.** The serializing half of the wire format. -/
def printCertificate (c : RawCertificate) : String := printCanonical (encodeCert c)

/-- **Read a certificate from one line of canonical bytes.** The deserializing half of the wire
format, and the function whose correctness the whole directory exists to establish. -/
def parseCertificateCanonical (s : String) : Except String RawCertificate :=
  match parseCanonical s with
  | .error m => .error m
  | .ok j => decodeCert j

/-- No key occurs in the empty object. -/
theorem hasKey_nil (k : List Char) : hasKey k .nil = false := rfl

/-- A key that differs from an object's first key, and does not occur in its tail, does not
occur. -/
theorem hasKey_cons_of_ne (k k' : List Char) (v : CJson) (fs : CJsonObj)
    (h : ¬ (k = k')) (h2 : hasKey k fs = false) : hasKey k (.cons k' v fs) = false := by
  simp only [hasKey, h2, Bool.or_false, beq_eq_false_iff_ne, ne_eq]
  exact h

/-- Encoded formulas are canonical: no key repeats. -/
theorem canonical_encodeFormula (φ : Formula) : Canonical (encodeFormula φ) := by
  induction φ with
  | atom a => simp [encodeFormula, Canonical, CanonicalObj, hasKey, keyTag, keyName]
  | bot => simp [encodeFormula, Canonical, CanonicalObj, hasKey]
  | imp a b iha ihb =>
    simp [encodeFormula, Canonical, CanonicalObj, hasKey, keyTag, keyLeft, keyRight, iha, ihb]
  | box c ihc => simp [encodeFormula, Canonical, CanonicalObj, hasKey, keyTag, keyChild, ihc]
  | untl g e ihg ihe =>
    simp [encodeFormula, Canonical, CanonicalObj, hasKey, keyTag, keyEvent, keyGuard, ihg, ihe]
  | snce g e ihg ihe =>
    simp [encodeFormula, Canonical, CanonicalObj, hasKey, keyTag, keyEvent, keyGuard, ihg, ihe]

/-- Encoded formula lists are canonical. -/
theorem canonicalList_encodeFormulas (φs : List Formula) :
    CanonicalList (encodeFormulas φs) := by
  induction φs with
  | nil => simp [encodeFormulas, CanonicalList]
  | cons φ φs ih => exact ⟨canonical_encodeFormula φ, ih⟩

/-- Encoded segments are canonical. -/
theorem canonicalList_encodeSegment (Xs : List (List Formula)) :
    CanonicalList (encodeSegment Xs) := by
  induction Xs with
  | nil => simp [encodeSegment, CanonicalList]
  | cons X Xs ih => exact ⟨canonicalList_encodeFormulas X, ih⟩

/-- Encoded box-guess entries are canonical. -/
theorem canonical_encodeBxPair (p : Formula × Bool) : Canonical (encodeBxPair p) :=
  ⟨canonical_encodeFormula p.1, trivial, trivial⟩

/-- Encoded box guesses are canonical. -/
theorem canonicalList_encodeBx (ps : List (Formula × Bool)) :
    CanonicalList (encodeBx ps) := by
  induction ps with
  | nil => simp [encodeBx, CanonicalList]
  | cons p ps ih => exact ⟨canonical_encodeBxPair p, ih⟩

/-- Encoded lassos are canonical. -/
theorem canonical_encodeLasso (L : RawLasso) : Canonical (encodeLasso L) :=
  ⟨hasKey_cons_of_ne _ _ _ _ (by decide) (hasKey_cons_of_ne _ _ _ _ (by decide) (hasKey_nil _)),
    canonicalList_encodeSegment L.back,
    hasKey_cons_of_ne _ _ _ _ (by decide) (hasKey_nil _), canonicalList_encodeSegment L.mid,
    hasKey_nil _, canonicalList_encodeSegment L.fwd, trivial⟩

/-- Encoded lasso lists are canonical. -/
theorem canonicalList_encodeLassos (Ls : List RawLasso) :
    CanonicalList (encodeLassos Ls) := by
  induction Ls with
  | nil => simp [encodeLassos, CanonicalList]
  | cons L Ls ih => exact ⟨canonical_encodeLasso L, ih⟩

/-- Encoded targets are canonical. -/
theorem canonical_encodeTarget (t : RawTarget) : Canonical (encodeTarget t) :=
  ⟨hasKey_cons_of_ne _ _ _ _ (by decide) (hasKey_cons_of_ne _ _ _ _ (by decide) (hasKey_nil _)),
    canonicalList_encodeFormulas t.premises,
    hasKey_cons_of_ne _ _ _ _ (by decide) (hasKey_nil _),
    canonicalList_encodeFormulas t.conclusions, hasKey_nil _, trivial, trivial⟩

/-- **Encoded certificates are canonical**, which is the hypothesis the generic layer-1 round-trip
theorem needs in order to apply here at all. -/
theorem canonical_encodeCert (c : RawCertificate) : Canonical (encodeCert c) :=
  ⟨hasKey_cons_of_ne _ _ _ _ (by decide) (hasKey_cons_of_ne _ _ _ _ (by decide) (hasKey_nil _)),
    canonical_encodeTarget c.target,
    hasKey_cons_of_ne _ _ _ _ (by decide) (hasKey_nil _), canonicalList_encodeBx c.bx,
    hasKey_nil _, canonicalList_encodeLassos c.lassos, trivial⟩

/-- Looking up an object's own first key finds its value. -/
theorem lookup_cons_self (k : List Char) (v : CJson) (fs : CJsonObj) :
    lookup k (.cons k v fs) = some v := by simp [lookup]

/-- Looking up a key other than an object's first skips that field. -/
theorem lookup_cons_of_ne (k k' : List Char) (v : CJson) (fs : CJsonObj) (h : ¬ (k = k')) :
    lookup k (.cons k' v fs) = lookup k fs := by simp [lookup, h]

/-- The formula-list codec is a round trip. -/
theorem decodeFormulas_encodeFormulas (φs : List Formula)
    (h : ∀ φ ∈ φs, hasFreshAtom φ = false) :
    decodeFormulas (encodeFormulas φs) = .ok φs := by
  induction φs with
  | nil => rfl
  | cons φ φs ih =>
    simp only [encodeFormulas, decodeFormulas, decodeFormula_encodeFormula φ (h φ (by simp)),
      ih (fun ψ hψ => h ψ (by simp [hψ]))]

/-- The formula-array codec is a round trip. -/
theorem decodeFormulaArray_encode (X : List Formula) (h : ∀ φ ∈ X, hasFreshAtom φ = false) :
    decodeFormulaArray (.arr (encodeFormulas X)) = .ok X := by
  simp only [decodeFormulaArray, decodeFormulas_encodeFormulas X h]

/-- The segment codec is a round trip. -/
theorem decodeSegment_encodeSegment (Xs : List (List Formula))
    (h : ∀ X ∈ Xs, ∀ φ ∈ X, hasFreshAtom φ = false) :
    decodeSegment (encodeSegment Xs) = .ok Xs := by
  induction Xs with
  | nil => rfl
  | cons X Xs ih =>
    simp only [encodeSegment, decodeSegment, decodeFormulaArray_encode X (h X (by simp)),
      ih (fun Y hY => h Y (by simp [hY]))]

/-- The optional-segment codec is a round trip on a present segment. -/
theorem decodeOptSegment_encode (Xs : List (List Formula))
    (h : ∀ X ∈ Xs, ∀ φ ∈ X, hasFreshAtom φ = false) :
    decodeOptSegment (some (.arr (encodeSegment Xs))) = .ok Xs := by
  simp only [decodeOptSegment, decodeSegmentValue, decodeSegment_encodeSegment Xs h]

/-- The lasso codec is a round trip. -/
theorem decodeLasso_encodeLasso (L : RawLasso)
    (h : ∀ X ∈ L.back ++ L.mid ++ L.fwd, ∀ φ ∈ X, hasFreshAtom φ = false) :
    decodeLasso (encodeLasso L) = .ok L := by
  have hb : ∀ X ∈ L.back, ∀ φ ∈ X, hasFreshAtom φ = false := fun X hX => h X (by simp [hX])
  have hm : ∀ X ∈ L.mid, ∀ φ ∈ X, hasFreshAtom φ = false := fun X hX => h X (by simp [hX])
  have hf : ∀ X ∈ L.fwd, ∀ φ ∈ X, hasFreshAtom φ = false := fun X hX => h X (by simp [hX])
  simp only [encodeLasso, decodeLasso, lookup_cons_self,
    lookup_cons_of_ne keyMid keyBack _ _ (by decide),
    lookup_cons_of_ne keyFwd keyBack _ _ (by decide),
    lookup_cons_of_ne keyFwd keyMid _ _ (by decide),
    decodeOptSegment_encode _ hb, decodeOptSegment_encode _ hm, decodeOptSegment_encode _ hf]

/-- The lasso-list codec is a round trip. -/
theorem decodeLassos_encodeLassos (Ls : List RawLasso)
    (h : ∀ L ∈ Ls, ∀ X ∈ L.back ++ L.mid ++ L.fwd, ∀ φ ∈ X, hasFreshAtom φ = false) :
    decodeLassos (encodeLassos Ls) = .ok Ls := by
  induction Ls with
  | nil => rfl
  | cons L Ls ih =>
    simp only [encodeLassos, decodeLassos, decodeLasso_encodeLasso L (h L (by simp)),
      ih (fun M hM => h M (by simp [hM]))]

/-- The box-guess-entry codec is a round trip. -/
theorem decodeBxPair_encodeBxPair (p : Formula × Bool) (h : hasFreshAtom p.1 = false) :
    decodeBxPair (encodeBxPair p) = .ok p := by
  simp only [encodeBxPair, decodeBxPair, decodeFormula_encodeFormula p.1 h]

/-- The box-guess codec is a round trip. -/
theorem decodeBx_encodeBx (ps : List (Formula × Bool)) (h : ∀ p ∈ ps, hasFreshAtom p.1 = false) :
    decodeBx (encodeBx ps) = .ok ps := by
  induction ps with
  | nil => rfl
  | cons p ps ih =>
    simp only [encodeBx, decodeBx, decodeBxPair_encodeBxPair p (h p (by simp)),
      ih (fun q hq => h q (by simp [hq]))]

/-- The target codec is a round trip, `time` included. -/
theorem decodeTarget_encodeTarget (t : RawTarget)
    (hp : ∀ φ ∈ t.premises, hasFreshAtom φ = false)
    (hc : ∀ φ ∈ t.conclusions, hasFreshAtom φ = false) :
    decodeTarget (encodeTarget t) = .ok t := by
  simp only [encodeTarget, decodeTarget, lookup_cons_self,
    lookup_cons_of_ne keyConclusions keyPremises _ _ (by decide),
    lookup_cons_of_ne keyTime keyPremises _ _ (by decide),
    lookup_cons_of_ne keyTime keyConclusions _ _ (by decide),
    decodeOptFormulaArray, decodeFormulaArray_encode _ hp, decodeFormulaArray_encode _ hc,
    PartialTarget.complete]

/-- **The schema layer: decoding an encoded certificate returns it.** Pure structural induction over
`RawCertificate` and its components — no goal in this proof mentions the parser's fuel, which is
the point of the two-layer split. -/
theorem decode_encode (c : RawCertificate)
    (h : c.formulas.all (fun φ => !hasFreshAtom φ)) :
    decodeCert (encodeCert c) = .ok c := by
  have hall : ∀ φ ∈ c.formulas, hasFreshAtom φ = false := by
    intro φ hφ
    have hb := List.all_eq_true.mp h φ hφ
    simpa using hb
  have hprem : ∀ φ ∈ c.target.premises, hasFreshAtom φ = false := fun φ hφ =>
    hall φ (by
      simp only [RawCertificate.formulas, List.mem_append]
      exact Or.inl (Or.inl (Or.inl hφ)))
  have hconc : ∀ φ ∈ c.target.conclusions, hasFreshAtom φ = false := fun φ hφ =>
    hall φ (by
      simp only [RawCertificate.formulas, List.mem_append]
      exact Or.inl (Or.inl (Or.inr hφ)))
  have hbx : ∀ p ∈ c.bx, hasFreshAtom p.1 = false := fun p hp =>
    hall p.1 (by
      simp only [RawCertificate.formulas, List.mem_append]
      exact Or.inl (Or.inr (List.mem_map_of_mem hp)))
  have hlas : ∀ L ∈ c.lassos, ∀ X ∈ L.back ++ L.mid ++ L.fwd,
      ∀ φ ∈ X, hasFreshAtom φ = false := fun L hL X hX φ hφ =>
    hall φ (by
      simp only [List.mem_append] at hX
      simp only [RawCertificate.formulas, List.mem_append, List.mem_flatMap, List.mem_flatten]
      exact Or.inr ⟨L, hL, X, hX, hφ⟩)
  simp only [encodeCert, decodeCert, lookup_cons_self,
    lookup_cons_of_ne keyBx keyTarget _ _ (by decide),
    lookup_cons_of_ne keyLassos keyTarget _ _ (by decide),
    lookup_cons_of_ne keyLassos keyBx _ _ (by decide),
    decodeTarget_encodeTarget _ hprem hconc, decodeOptBx, decodeBxValue,
    decodeBx_encodeBx _ hbx, decodeOptLassos, decodeLassosValue,
    decodeLassos_encodeLassos _ hlas]
  simp only [h, if_true]

/-- **The task's headline theorem: parsing a printed certificate returns that same certificate.**

One composition: the canonical printer is a section of the total parser (layer 1), and the schema
encoder is a section of the schema decoder (layer 2). -/
theorem parse_print (c : RawCertificate)
    (h : c.formulas.all (fun φ => !hasFreshAtom φ)) :
    parseCertificateCanonical (printCertificate c) = .ok c := by
  simp only [parseCertificateCanonical, printCertificate,
    parseCanonical_printCanonical (encodeCert c) (canonical_encodeCert c), decode_encode c h]

/-- **The canonical printer is injective on base-atom certificates.** Two certificates with the same
bytes are the same certificate, so the bytes determine what was checked. -/
theorem printCertificate_injective (c c' : RawCertificate)
    (hc : c.formulas.all (fun φ => !hasFreshAtom φ))
    (hc' : c'.formulas.all (fun φ => !hasFreshAtom φ))
    (h : printCertificate c = printCertificate c') : c = c' := by
  have h1 := parse_print c hc
  rw [h, parse_print c' hc'] at h1
  exact (Except.ok.inj h1).symm

/-- **The guarantee the paired consuming-side echo comparison rests on.** On bytes in the image
of the printer, the echo of what was parsed is byte-identical to what was sent — so a consumer that
compares its own bytes against the echo is comparing the certificate the verified side actually
checked, not a re-rendering of a different one. -/
theorem print_parse_canonical (c c' : RawCertificate)
    (hc' : c'.formulas.all (fun φ => !hasFreshAtom φ))
    (h : parseCertificateCanonical (printCertificate c') = .ok c) :
    printCertificate c = printCertificate c' := by
  rw [parse_print c' hc'] at h
  rw [Except.ok.inj h]

/-- Base-only-ness, lifted to the decoder's result type so that the statement mentions no equation
and functional induction applies directly. -/
def OkBaseOnly : Except String Formula → Prop
  | .ok φ => hasFreshAtom φ = false
  | .error _ => True

/-- Anything `decodeFormula` returns carries base-only atoms: it builds atoms through
`Formula.atomS`, which is `Atom.mkBase`, and the wire format has no field for a fresh index. This
is what makes
`decodeCert`'s atom-identity guard unreachable on decoded input. -/
theorem decodeFormula_base_only (j : CJson) : OkBaseOnly (decodeFormula j) := by
  fun_induction decodeFormula j <;>
    simp_all [OkBaseOnly, hasFreshAtom, Formula.atomS, Atom.mkBase]

/-- The equational reading of `decodeFormula_base_only`. -/
theorem hasFreshAtom_of_decodeFormula (j : CJson) (φ : Formula)
    (h : decodeFormula j = .ok φ) : hasFreshAtom φ = false := by
  have hb := decodeFormula_base_only j
  rw [h] at hb
  exact hb

/-- Anything `decodeCert` returns carries base-only atoms, read off its final guard. -/
theorem decodeCert_base_only (j : CJson) (c : RawCertificate) (h : decodeCert j = .ok c) :
    c.formulas.all (fun φ => !hasFreshAtom φ) := by
  cases j <;> simp only [decodeCert] at h
  repeat' split at h
  all_goals simp_all [PartialCertificate.complete]

/-- **Atom identity is base-only on anything the parser returns**, which makes the base-atom
hypothesis of `parse_print` vacuous on the real pipeline and re-proves that clause of the export
contract as a
theorem rather than a convention. -/
theorem parse_base_only (s : String) (c : RawCertificate)
    (h : parseCertificateCanonical s = .ok c) :
    c.formulas.all (fun φ => !hasFreshAtom φ) := by
  simp only [parseCertificateCanonical] at h
  cases hp : parseCanonical s with
  | error m => rw [hp] at h; simp at h
  | ok j => rw [hp] at h; exact decodeCert_base_only j c h

end BimodalTools.CanonicalWire
