#!/usr/bin/env bash
set -euo pipefail

# HAPPY DIWALI - 2025 historical visual experiment
# One clearly labelled commit per filled pixel.

START_DATE="2025-01-05"
REPO_NAME="happy-diwali-2025"

echo "======================================"
echo "       HAPPY DIWALI 2025 🪔"
echo "======================================"

# Verify repository
git rev-parse --is-inside-work-tree >/dev/null

BRANCH=$(git branch --show-current)
if [[ "$BRANCH" != "main" ]]; then
    echo "Please switch to main branch first."
    exit 1
fi

REMOTE=$(git remote get-url origin)
echo "Remote: $REMOTE"

if [[ "$REMOTE" != *"/rishupatel199/$REPO_NAME.git" ]]; then
    echo "Unexpected remote. Stopping safely."
    exit 1
fi

EMAIL=$(git config user.email || true)
if [[ -z "$EMAIL" ]]; then
    echo "Configure your Git email first."
    exit 1
fi

echo "Git email: $EMAIL"
echo "Ensure this email is associated with your GitHub account."

if [[ -n "$(git status --porcelain)" ]]; then
    echo "Working tree is not clean. Commit or safely save changes first."
    git status
    exit 1
fi

if [[ -e heatmap-experiment.log ]]; then
    echo "Experiment file already exists. Stopping to avoid duplicates."
    exit 1
fi

read -r -p "Is this your verified GitHub email? (yes/no): " answer
if [[ "$answer" != "yes" ]]; then
    echo "Stopping. Check your GitHub email settings first."
    exit 1
fi

read -r -p "Create the labelled 2025 visual experiment? (yes/no): " answer
if [[ "$answer" != "yes" ]]; then
    exit 1
fi

# Add transparent documentation
cat >> README.md <<'EOF'

## 2025 Historical Heatmap Experiment

This is an explicitly labelled Git timestamp visualization demo.
The historical commit dates are synthetic and do not represent
work actually performed on those dates.
EOF

git add README.md
git commit -m "docs: explain historical heatmap experiment"

# 3x5 pixel font
glyph=()
rows=("" "" "" "" "")
WORD="HAPPY DIWALI"

get_glyph() {
    case "$1" in
        H) glyph=("101" "101" "111" "101" "101") ;;
        A) glyph=("010" "101" "111" "101" "101") ;;
        P) glyph=("110" "101" "110" "100" "100") ;;
        Y) glyph=("101" "101" "010" "010" "010") ;;
        D) glyph=("110" "101" "101" "101" "110") ;;
        I) glyph=("111" "010" "010" "010" "111") ;;
        W) glyph=("101" "101" "101" "111" "101") ;;
        L) glyph=("100" "100" "100" "100" "111") ;;
    esac
}

# Construct the five rows
for ((i=0; i<${#WORD}; i++)); do
    char="${WORD:$i:1}"

    if [[ "$char" == " " ]]; then
        for ((r=0; r<5; r++)); do
            rows[$r]+="00"
        done
        continue
    fi

    get_glyph "$char"

    for ((r=0; r<5; r++)); do
        rows[$r]+="${glyph[$r]}"

        if (( i < ${#WORD}-1 )); then
            rows[$r]+="0"
        fi
    done
done

# Generate one commit for each filled pixel
PIXELS=0
TOTAL=0

echo "Generating HAPPY DIWALI pattern..."

for ((week=0; week<${#rows[0]}; week++)); do
    for ((day=0; day<5; day++)); do

        pixel="${rows[$day]:$week:1}"

        if [[ "$pixel" == "1" ]]; then

            offset=$((week*7+day))
            commit_date=$(date -d "$START_DATE + $offset days" +%Y-%m-%d)

            printf "Historical visual experiment: pixel %s,%s\n" \
                "$week" "$day" >> heatmap-experiment.log

            git add heatmap-experiment.log

            GIT_AUTHOR_DATE="$commit_date 12:00:00 +0530" \
            GIT_COMMITTER_DATE="$commit_date 12:00:00 +0530" \
            git commit --quiet \
                -m "experiment: HAPPY DIWALI pixel [$week,$day]"

            ((PIXELS+=1))
            ((TOTAL+=1))
        fi
    done

    if (( week % 5 == 0 )); then
        echo "Processed week $week..."
    fi
done

echo "======================================"
echo "Pattern generation completed!"
echo "Filled pixels: $PIXELS"
echo "Historical commits: $TOTAL"
echo "======================================"

echo "Verifying commit history..."
git log --format="%as %s" -5

read -r -p "Push experiment to GitHub main? (yes/no): " answer

if [[ "$answer" == "yes" ]]; then
    git push origin main
    echo "Push completed."
else
    echo "Commits saved locally. Nothing pushed."
fi

echo "HAPPY DIWALI experiment finished!"
