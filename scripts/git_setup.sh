#!/bin/bash
# git_setup.sh — Initialize repo, branches, and contributor structure
# Run ONCE from the project root directory BEFORE distribute_commits.sh

set -e

echo "=== Initializing Git Repository ==="
git init
git branch -M main

echo "=== Creating member branches ==="
git checkout -b member/abdullah
git checkout -b member/raza
git checkout -b member/maarij
git checkout main

echo ""
echo "============================================"
echo "  Repository initialized with branches:"
echo "    - main (protected)"
echo "    - member/abdullah"
echo "    - member/raza"
echo "    - member/maarij"
echo "============================================"
echo ""
echo "NEXT STEPS:"
echo "  1. Create repo on GitHub: https://github.com/new"
echo "     Name: market-pulse-predictor"
echo ""
echo "  2. Add remote:"
echo "     git remote add origin https://github.com/<YOUR_USERNAME>/market-pulse-predictor.git"
echo ""
echo "  3. Add these as COLLABORATORS (Settings > Collaborators):"
echo "     - asif370       (Sir Asif Ameer — Instructor)"
echo "     - omerrfarooqq  (Omer Farooq Khan — TA ANN-A1)"
echo "     - Aun-Dev146    (Aun Ali — TA ANN-A2)"
echo "     - ahsan608      (Ahsan Butt — TA MLOps)"
echo ""
echo "  4. Protect main branch (Settings > Branches > Add rule):"
echo "     - Branch name pattern: main"
echo "     - Require pull request before merging"
echo "     - Require status checks to pass (CI)"
echo ""
echo "  5. Run: bash scripts/distribute_commits.sh"
echo "============================================"
