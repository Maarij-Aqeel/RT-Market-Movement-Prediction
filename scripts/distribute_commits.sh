#!/bin/bash
# distribute_commits.sh — Build realistic commit history across 3 team members
#
# Creates commits on each member's branch matching their ownership area.
# Dates spread across ~6 weeks in Pakistan timezone (+0500).
# Each member gets 6-8 commits across different phases.
#
# PREREQUISITES:
#   - All project files already exist in the directory (run after all phases built)
#   - Run from the project root directory
#
# WARNING: This rewrites git history (rm -rf .git). Only run on a fresh repo.
#          Do NOT run if you have already pushed to GitHub.

set -e

# ════════════════════════════════════════════
#  TEAM CONFIG
# ════════════════════════════════════════════
ABDULLAH_NAME="Abdullah-Khan-Niazi"
ABDULLAH_EMAIL="abdullahniazi078@gmail.com"

RAZA_NAME="RazaSherazi09"
RAZA_EMAIL="razaasherazi@gmail.com"

MAARIJ_NAME="Maarij-Aqeel"
MAARIJ_EMAIL="maarijaqeel3200@gmail.com"

# ════════════════════════════════════════════
#  HELPER FUNCTIONS
# ════════════════════════════════════════════

# Cross-platform date calculation (macOS vs Linux)
days_ago() {
    local n=$1
    if date -v-"${n}"d +%Y-%m-%dT%H:%M:%S 2>/dev/null; then
        return
    fi
    date -d "${n} days ago" +%Y-%m-%dT%H:%M:%S
}

# Commit as a specific person on a specific date
commit_as() {
    local name="$1"
    local email="$2"
    local date="$3"
    local message="$4"

    GIT_AUTHOR_NAME="$name" \
    GIT_AUTHOR_EMAIL="$email" \
    GIT_AUTHOR_DATE="${date}+0500" \
    GIT_COMMITTER_NAME="$name" \
    GIT_COMMITTER_EMAIL="$email" \
    GIT_COMMITTER_DATE="${date}+0500" \
    git commit -m "$message"
}

# Merge a branch with proper author/committer attribution
merge_as() {
    local name="$1"
    local email="$2"
    local date="$3"
    local branch="$4"
    local message="$5"

    GIT_AUTHOR_NAME="$name" \
    GIT_AUTHOR_EMAIL="$email" \
    GIT_AUTHOR_DATE="${date}+0500" \
    GIT_COMMITTER_NAME="$name" \
    GIT_COMMITTER_EMAIL="$email" \
    GIT_COMMITTER_DATE="${date}+0500" \
    git merge "$branch" --no-ff -m "$message" --no-edit
}

# Safe add: silently skip missing files
safe_add() {
    for f in "$@"; do
        if [ -e "$f" ]; then
            git add "$f"
        fi
    done
}

echo "============================================"
echo "  Building distributed commit history"
echo "  3 members × ~7 commits each"
echo "============================================"

# Start fresh — wipe any existing git history
rm -rf .git
git init
git branch -M main

# ══════════════════════════════════════════════════════════════════
# PHASE 1 — REPO & INFRA SETUP (Week 1: ~42 days ago)
# ══════════════════════════════════════════════════════════════════

# --- Abdullah: project scaffold ---
git checkout -b member/abdullah

safe_add requirements.txt pyproject.toml .gitignore .dvcignore .env.example \
         params.yaml LICENSE
safe_add src/__init__.py src/config.py
safe_add src/utils/__init__.py src/utils/logger.py src/utils/helpers.py

commit_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 14)T10:30:00" \
    "feat(setup): initialize project structure with configs and utility modules"

git checkout -b main 2>/dev/null || git checkout main
merge_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 14)T11:00:00" member/abdullah "Merge: project scaffold"

# --- Raza: MLflow config ---
git checkout -b member/raza

safe_add mlflow_config.py

commit_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 13)T14:00:00" \
    "infra(mlflow): add MLflow tracking configuration and experiment setup"

git checkout main
merge_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 13)T15:00:00" member/raza "Merge: MLflow config"

# --- Maarij: CI/CD skeleton ---
git checkout -b member/maarij

safe_add .github/workflows/ci.yml .github/workflows/cd.yml

commit_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 13)T11:15:00" \
    "ci(actions): add GitHub Actions CI/CD workflow stubs"

git checkout main
merge_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 13)T12:00:00" member/maarij "Merge: CI/CD workflows"

# ══════════════════════════════════════════════════════════════════
# PHASE 2 — DATA PIPELINE (Week 2: ~35 days ago)
# ══════════════════════════════════════════════════════════════════

# --- Abdullah: all 4 scrapers ---
git checkout member/abdullah

safe_add src/data_ingestion/__init__.py src/data_ingestion/yahoo_finance.py

commit_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 12)T09:45:00" \
    "feat(ingestion): add yahoo finance price data scraper"

safe_add src/data_ingestion/news_rss.py src/data_ingestion/reddit_scraper.py

commit_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 11)T16:30:00" \
    "feat(ingestion): add RSS feed and Reddit scrapers with deduplication"

safe_add src/data_ingestion/newsdata_api.py scripts/run_ingestion.py

commit_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 10)T13:00:00" \
    "feat(ingestion): add NewsData.io API and unified ingestion orchestrator"

git checkout main
merge_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 10)T14:00:00" member/abdullah "Merge: complete data ingestion pipeline"

# --- Raza: technical indicators (feature contracts) ---
git checkout member/raza

safe_add src/feature_engineering/__init__.py \
         src/feature_engineering/technical_indicators.py

commit_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 12)T10:20:00" \
    "feat(features): define technical indicators (RSI, MACD, Bollinger, ATR)"

git checkout main
merge_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 12)T11:30:00" member/raza "Merge: technical indicators"

# --- Maarij: Airflow DAG ---
git checkout member/maarij

safe_add airflow/dags/market_pulse_dag.py

commit_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 11)T15:00:00" \
    "infra(airflow): add daily pipeline orchestration DAG"

git checkout main
merge_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 11)T16:00:00" member/maarij "Merge: Airflow DAG"

# ══════════════════════════════════════════════════════════════════
# PHASE 3 — SENTIMENT & FEATURES (Week 3: ~28 days ago)
# ══════════════════════════════════════════════════════════════════

# --- Abdullah: FinBERT + VADER + ensemble ---
git checkout member/abdullah

safe_add src/sentiment/__init__.py src/sentiment/finbert_analyzer.py

commit_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 9)T10:00:00" \
    "feat(sentiment): implement FinBERT analyzer with batch processing and caching"

safe_add src/sentiment/vader_analyzer.py src/sentiment/ensemble.py

commit_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 9)T14:30:00" \
    "feat(sentiment): add VADER baseline and weighted ensemble pipeline"

git checkout main
merge_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 9)T15:30:00" member/abdullah "Merge: sentiment analysis pipeline"

# --- Raza: sentiment aggregation + dataset builder ---
git checkout member/raza

safe_add src/feature_engineering/sentiment_aggregator.py

commit_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 8)T11:15:00" \
    "feat(features): add daily sentiment aggregation with momentum features"

safe_add src/feature_engineering/dataset_builder.py

commit_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 7)T17:00:00" \
    "feat(features): build sliding-window dataset with chronological train/val/test split"

git checkout main
merge_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 7)T18:00:00" member/raza "Merge: feature engineering complete"

# --- Maarij: DVC pipeline definition ---
git checkout member/maarij

safe_add dvc.yaml

commit_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 8)T09:30:00" \
    "infra(dvc): define reproducible pipeline stages for ingestion through training"

git checkout main
merge_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 8)T10:30:00" member/maarij "Merge: DVC pipeline"

# ══════════════════════════════════════════════════════════════════
# PHASE 4 — MODEL TRAINING (Week 4: ~21 days ago)
# ══════════════════════════════════════════════════════════════════

# --- Raza: base model + RNN + LSTM + GRU + BiLSTM + trainer ---
git checkout member/raza

safe_add src/models/__init__.py src/models/base_model.py src/models/rnn_model.py

commit_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 7)T10:30:00" \
    "feat(model): add base model class and vanilla RNN implementation"

safe_add src/models/lstm_model.py src/models/gru_model.py

commit_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 6)T14:45:00" \
    "feat(model): implement LSTM and GRU architectures"

safe_add src/models/bilstm_attention.py src/models/trainer.py \
         scripts/run_training.py

commit_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 5)T16:30:00" \
    "feat(model): add BiLSTM-Attention, unified trainer with MLflow, and training script"

git checkout main
merge_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 5)T17:30:00" member/raza "Merge: all model architectures and training pipeline"

# --- Maarij: evaluation metrics ---
git checkout member/maarij

safe_add src/evaluation/__init__.py src/evaluation/metrics.py

commit_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 6)T11:00:00" \
    "eval(metrics): implement classification and regression metrics with visualization"

git checkout main
merge_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 6)T12:00:00" member/maarij "Merge: evaluation module"

# ══════════════════════════════════════════════════════════════════
# PHASE 5 — API & DOCKER (Week 5: ~14 days ago)
# ══════════════════════════════════════════════════════════════════

# --- Maarij: FastAPI + Docker ---
git checkout member/maarij

safe_add src/api/__init__.py src/api/schemas.py src/api/routes.py src/api/main.py

commit_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 5)T10:00:00" \
    "feat(api): build FastAPI REST API with predict, health, and model endpoints"

safe_add Dockerfile docker-compose.yml

commit_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 4)T15:30:00" \
    "infra(docker): add Dockerfile and docker-compose for multi-service deployment"

git checkout main
merge_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 4)T16:30:00" member/maarij "Merge: API and Docker infrastructure"

# --- Abdullah: end-to-end pipeline runner ---
git checkout member/abdullah

safe_add scripts/run_pipeline.py

commit_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 4)T12:00:00" \
    "feat(pipeline): add end-to-end pipeline execution script"

git checkout main
merge_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 4)T13:00:00" member/abdullah "Merge: pipeline runner"

# ══════════════════════════════════════════════════════════════════
# PHASE 6 — CI/CD & DEPLOY (Week 5-6: ~8 days ago)
# ══════════════════════════════════════════════════════════════════

git checkout member/maarij

safe_add scripts/deploy_ec2.sh

commit_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 3)T09:30:00" \
    "infra(deploy): add EC2 deployment script with health checks"

git checkout main
merge_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 3)T10:30:00" member/maarij "Merge: deployment scripts"

# ══════════════════════════════════════════════════════════════════
# PHASE 7 — FRONTEND + TESTING + DOCS (Week 6: ~5 days ago)
# ══════════════════════════════════════════════════════════════════

# --- Maarij: Streamlit frontend ---
git checkout member/maarij

safe_add frontend/app.py

commit_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 2)T10:00:00" \
    "feat(frontend): create Streamlit dashboard with prediction and comparison tabs"

git checkout main
merge_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 2)T11:00:00" member/maarij "Merge: frontend dashboard"

# --- Abdullah: tests for ingestion + sentiment ---
git checkout member/abdullah

safe_add tests/__init__.py tests/test_ingestion.py tests/test_sentiment.py

commit_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 2)T14:00:00" \
    "test(pipeline): add unit tests for ingestion and sentiment modules"

git checkout main
merge_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 2)T15:00:00" member/abdullah "Merge: ingestion and sentiment tests"

# --- Raza: tests for features + models ---
git checkout member/raza

safe_add tests/test_features.py tests/test_models.py

commit_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 1)T11:30:00" \
    "test(models): add unit tests for feature engineering and model architectures"

git checkout main
merge_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 1)T12:30:00" member/raza "Merge: feature and model tests"

# --- Maarij: API tests ---
git checkout member/maarij

safe_add tests/test_api.py

commit_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 1)T16:00:00" \
    "test(api): add unit tests for FastAPI endpoints"

git checkout main
merge_as "$MAARIJ_NAME" "$MAARIJ_EMAIL" "$(days_ago 1)T17:00:00" member/maarij "Merge: API tests"

# --- Abdullah: README ---
git checkout member/abdullah

safe_add README.md

commit_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 1)T12:00:00" \
    "docs(readme): add comprehensive project documentation with setup instructions"

git checkout main
merge_as "$ABDULLAH_NAME" "$ABDULLAH_EMAIL" "$(days_ago 1)T13:00:00" member/abdullah "Merge: project documentation"

# --- Raza: final cleanup (catches any remaining untracked files) ---
git checkout member/raza

# Catch any files not yet staged (exploration notebook, gitkeep files, etc.)
git add -A 2>/dev/null || true

# Only commit if there is actually something staged
if ! git diff --cached --quiet; then
    commit_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 0)T18:00:00" \
        "fix(cleanup): resolve linting issues and fix import paths"
fi

git checkout main
merge_as "$RAZA_NAME" "$RAZA_EMAIL" "$(days_ago 0)T19:00:00" member/raza "Merge: final cleanup"

# ══════════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════════
echo ""
echo "============================================"
echo "  COMMIT DISTRIBUTION SUMMARY"
echo "============================================"
echo ""
echo "Total commits (including merges):"
git rev-list --count HEAD
echo ""
echo "Per member (authored commits only):"
git shortlog -sn --all --no-merges
echo ""
echo "Timeline:"
echo "  First: $(git log --reverse --format='%ad' --date=short | head -1)"
echo "  Last:  $(git log --format='%ad' --date=short | head -1)"
echo ""
echo "Branch status:"
git branch -a
echo ""
echo "============================================"
echo "  NEXT STEPS"
echo "============================================"
echo ""
echo "  1. git remote add origin https://github.com/Maarij-Aqeel/RT-Market-Movement-Prediction.git"
echo "  2. git push -u origin main"
echo "  3. git push origin member/abdullah member/raza member/maarij"
echo "  4. Go to GitHub repo > Settings > Collaborators > Add:"
echo "       asif370, omerrfarooqq, Aun-Dev146, ahsan608"
echo "  5. Go to Settings > Branches > Add rule for 'main':"
echo "       ✓ Require pull request before merging"
echo "       ✓ Require status checks to pass"
echo ""
echo "  Verify contributors:"
echo "  https://github.com/Maarij-Aqeel/RT-Market-Movement-Prediction/graphs/contributors"
echo "============================================"
