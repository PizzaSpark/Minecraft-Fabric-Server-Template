@echo off
git fetch
IF NOT "x$(git diff origin/master)" == "x" (
    git pull
) ELSE (
    echo "Your branch is up to date with 'origin/master'."
)