#!/usr/bin/env python3
"""Swap the two arguments of untl and snce throughout Lean files.

Handles Formula.untl, Formula.snce, .untl, .snce patterns.
Arguments can be simple identifiers or parenthesized expressions.
Recursively processes nested expressions.
"""

import sys


def consume_dot_suffixes(text, pos):
    """After a parenthesized expression, consume trailing .suffix chains.

    E.g., after (Formula.snce β α), consume .neg, .neg.and, .imp, etc.
    But stop at .untl and .snce (those are separate calls to swap).
    """
    while pos < len(text) and text[pos] == '.':
        rest = text[pos+1:]
        # Stop at .untl and .snce — those are separate swap targets
        if rest.startswith('untl') or rest.startswith('snce'):
            break
        # Consume the .identifier
        end = pos + 1
        while end < len(text) and text[end] not in ' \t\n(){}⟨⟩,;:∈∉→←↔∧∨¬∀∃│|.':
            end += 1
        if end == pos + 1:
            break  # Just a dot with no identifier
        pos = end
    return pos


def find_arg_end(text, start):
    """Find the end of a Lean function argument starting at position start.

    Returns the end position (exclusive).
    Handles parenthesized expressions with trailing dot-suffixes.
    """
    if start >= len(text):
        return start

    ch = text[start]

    if ch == '(':
        depth = 1
        pos = start + 1
        while pos < len(text) and depth > 0:
            if text[pos] == '(':
                depth += 1
            elif text[pos] == ')':
                depth -= 1
            pos += 1
        # After closing paren, consume dot suffixes like .neg, .imp, etc.
        pos = consume_dot_suffixes(text, pos)
        return pos
    elif ch in ' \t\n,;:)]}∈∉→←↔∧∨¬∀∃│|':
        return start  # No argument
    else:
        pos = start
        while pos < len(text):
            c = text[pos]
            if c in ' \t\n(){}⟨⟩,;:∈∉→←↔∧∨¬∀∃│|':
                break
            if c == '.' and pos > start:
                rest = text[pos+1:]
                if rest.startswith('untl') or rest.startswith('snce'):
                    break
            pos += 1
        return pos


def swap_in_text(text, depth=0):
    """Swap all Formula.untl/snce and .untl/.snce arguments in text.

    Recursively processes nested expressions.
    """
    if depth > 20:  # Safety limit
        return text

    result = []
    i = 0

    while i < len(text):
        matched = False

        for keyword in ['Formula.untl', 'Formula.snce']:
            if text[i:].startswith(keyword):
                kw_end = i + len(keyword)

                # If immediately followed by '.' (e.g., Formula.untl.injEq), skip
                if kw_end < len(text) and text[kw_end] == '.':
                    break  # Not a formula construction, skip

                # Skip whitespace
                ws1_end = kw_end
                while ws1_end < len(text) and text[ws1_end] in ' \t':
                    ws1_end += 1

                if ws1_end >= len(text) or text[ws1_end] in '\n):;,':
                    result.append(keyword)
                    i = kw_end
                    matched = True
                    break

                # Find first argument
                arg1_start = ws1_end
                arg1_end = find_arg_end(text, arg1_start)

                if arg1_end == arg1_start:
                    result.append(keyword)
                    i = kw_end
                    matched = True
                    break

                arg1 = text[arg1_start:arg1_end]
                # Recursively process arg1
                arg1 = swap_in_text(arg1, depth + 1)

                # Skip whitespace
                ws2_end = arg1_end
                while ws2_end < len(text) and text[ws2_end] in ' \t':
                    ws2_end += 1

                if ws2_end >= len(text) or text[ws2_end] in '\n):;,∈∉→←↔∧∨¬∀∃│|':
                    # Only one argument
                    ws1 = text[kw_end:ws1_end]
                    result.append(keyword + ws1 + arg1)
                    i = arg1_end
                    matched = True
                    break

                # Find second argument
                arg2_start = ws2_end
                arg2_end = find_arg_end(text, arg2_start)

                if arg2_end == arg2_start:
                    ws1 = text[kw_end:ws1_end]
                    result.append(keyword + ws1 + arg1)
                    i = arg1_end
                    matched = True
                    break

                arg2 = text[arg2_start:arg2_end]
                # Recursively process arg2
                arg2 = swap_in_text(arg2, depth + 1)

                # SWAP
                ws1 = text[kw_end:ws1_end]
                ws2 = text[arg1_end:ws2_end]
                result.append(keyword + ws1 + arg2 + ws2 + arg1)
                i = arg2_end
                matched = True
                break

        if matched:
            continue

        # Check for dot-notation .untl/.snce
        for suffix in ['.untl', '.snce']:
            if text[i:].startswith(suffix):
                # Don't double-process if preceded by "Formula"
                if i >= 7 and text[i-7:i] == 'Formula':
                    break

                sf_end = i + len(suffix)

                ws1_end = sf_end
                while ws1_end < len(text) and text[ws1_end] in ' \t':
                    ws1_end += 1

                if ws1_end >= len(text) or text[ws1_end] in '\n):;,∈∉→←↔∧∨¬∀∃│|':
                    result.append(suffix)
                    i = sf_end
                    matched = True
                    break

                arg1_start = ws1_end
                arg1_end = find_arg_end(text, arg1_start)

                if arg1_end == arg1_start:
                    result.append(suffix)
                    i = sf_end
                    matched = True
                    break

                arg1 = text[arg1_start:arg1_end]
                if arg1.startswith('(') and arg1.endswith(')'):
                    inner = swap_in_text(arg1[1:-1], depth + 1)
                    arg1 = '(' + inner + ')'

                ws2_end = arg1_end
                while ws2_end < len(text) and text[ws2_end] in ' \t':
                    ws2_end += 1

                if ws2_end >= len(text) or text[ws2_end] in '\n):;,∈∉→←↔∧∨¬∀∃│|':
                    ws1 = text[sf_end:ws1_end]
                    result.append(suffix + ws1 + arg1)
                    i = arg1_end
                    matched = True
                    break

                arg2_start = ws2_end
                arg2_end = find_arg_end(text, arg2_start)

                if arg2_end == arg2_start:
                    ws1 = text[sf_end:ws1_end]
                    result.append(suffix + ws1 + arg1)
                    i = arg1_end
                    matched = True
                    break

                arg2 = text[arg2_start:arg2_end]
                if arg2.startswith('(') and arg2.endswith(')'):
                    inner = swap_in_text(arg2[1:-1], depth + 1)
                    arg2 = '(' + inner + ')'

                ws1 = text[sf_end:ws1_end]
                ws2 = text[arg1_end:ws2_end]
                result.append(suffix + ws1 + arg2 + ws2 + arg1)
                i = arg2_end
                matched = True
                break

        if not matched:
            result.append(text[i])
            i += 1

    return ''.join(result)


def process_file(filepath):
    """Process a Lean file, swapping untl/snce arguments while preserving comments."""
    with open(filepath, 'r') as f:
        content = f.read()

    lines = content.split('\n')
    new_lines = []
    in_block_comment = False

    for line in lines:
        if in_block_comment:
            if '-/' in line:
                in_block_comment = False
            new_lines.append(line)
            continue

        stripped = line.lstrip()
        if stripped.startswith('/-'):
            if '-/' not in stripped[2:]:
                in_block_comment = True
            new_lines.append(line)
            continue

        # Process line comments
        comment_pos = line.find('--')
        if comment_pos >= 0:
            code = line[:comment_pos]
            comment = line[comment_pos:]
            new_lines.append(swap_in_text(code) + comment)
        else:
            new_lines.append(swap_in_text(line))

    with open(filepath, 'w') as f:
        f.write('\n'.join(new_lines))


def test():
    tests = [
        ("Formula.untl γ δ", "Formula.untl δ γ"),
        ("Formula.snce γ δ", "Formula.snce δ γ"),
        ("Formula.untl (Formula.and γ δ) ψ", "Formula.untl ψ (Formula.and γ δ)"),
        ("Formula.untl β (Formula.and β γ)", "Formula.untl (Formula.and β γ) β"),
        ("Formula.untl (Formula.and γ δ) (Formula.and α β)",
         "Formula.untl (Formula.and α β) (Formula.and γ δ)"),
        ("Formula.untl (Formula.and γ (Formula.untl γ δ)) δ",
         "Formula.untl δ (Formula.and γ (Formula.untl δ γ))"),
        ("(Formula.untl γ δ).imp", "(Formula.untl δ γ).imp"),
        ("Formula.untl γ δ ∈ A", "Formula.untl δ γ ∈ A"),
        # Nested untl inside parenthesized arg
        ("Formula.untl β (Formula.and β (Formula.untl β γ))",
         "Formula.untl (Formula.and β (Formula.untl γ β)) β"),
        # Double nested
        ("(Formula.untl β (Formula.and β (Formula.untl β γ))).imp (Formula.untl β γ)",
         "(Formula.untl (Formula.and β (Formula.untl γ β)) β).imp (Formula.untl γ β)"),
    ]

    all_pass = True
    for input_text, expected in tests:
        result = swap_in_text(input_text)
        if result != expected:
            print(f"FAIL: '{input_text}'")
            print(f"  Expected: '{expected}'")
            print(f"  Got:      '{result}'")
            all_pass = False
        else:
            print(f"PASS: '{input_text}' -> '{result}'")

    if all_pass:
        print("\nAll tests passed!")
    else:
        print("\nSome tests FAILED!")
        sys.exit(1)


if __name__ == '__main__':
    if len(sys.argv) == 2 and sys.argv[1] == '--test':
        test()
    elif len(sys.argv) >= 2:
        for filepath in sys.argv[1:]:
            print(f"Processing {filepath}...")
            process_file(filepath)
            print(f"  Done.")
    else:
        print("Usage: python swap_untl_snce.py [--test | file1 file2 ...]")
