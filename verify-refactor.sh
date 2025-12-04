#!/bin/bash
# verify-refactor.sh - Final verification for Logos Layer Architecture Refactor

echo "=== Logos Layer Architecture Refactor - Final Verification ==="

# 1. Build verification
echo "1. Verifying build..."
lake clean
lake build 2>&1 | tee build-final.log
if grep -qi "error" build-final.log; then
  echo "✖ Build failed"
  exit 1
fi
echo "✓ Build successful"

# 2. Namespace verification
echo "2. Verifying namespaces..."
if grep -r "namespace ProofChecker" --include="*.lean" Logos/ LogosTest/; then
  echo "✖ ProofChecker namespaces remain"
  exit 1
fi
echo "✓ No ProofChecker namespaces remain"

# 3. Import verification
echo "3. Verifying imports..."
if grep -r "import ProofChecker" --include="*.lean" .; then
  echo "✖ ProofChecker imports remain"
  exit 1
fi
echo "✓ No ProofChecker imports remain"

# 4. Documentation verification
echo "4. Verifying documentation..."
doc_refs=$(grep -r "ProofChecker" --include="*.md" . | grep -v MIGRATION.md | grep -v ".git" | grep -v "github.com" | grep -v "git clone" | grep -v ".backups" | grep -v "Archive/logos-original" | wc -l)
if [ "$doc_refs" -gt 0 ]; then
  echo "⚠ Warning: $doc_refs ProofChecker references in documentation (excluding MIGRATION.md, backups, archives)"
fi

# 5. Layer structure verification
echo "5. Verifying layer structure..."
test -d Logos/Core && test -f Logos/Core/Core.lean || { echo "✖ Core layer missing"; exit 1; }
test -f Logos/Explanatory.lean || { echo "✖ Explanatory stub missing"; exit 1; }
test -f Logos/Epistemic.lean || { echo "✖ Epistemic stub missing"; exit 1; }
test -f Logos/Normative.lean || { echo "✖ Normative stub missing"; exit 1; }
echo "✓ Layer structure correct"

# 6. Git status
echo "6. Checking git status..."
git status

echo ""
echo "=== Verification Complete ==="
echo "✓ Ready to merge"
