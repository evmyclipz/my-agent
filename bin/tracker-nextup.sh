#!/bin/bash
# Refresh the "— next up (from database) —" checkbox block under each course toggle
# on the Notion Homework Tracker page, from the Assignments & Exams database.
# Page body only: never writes the database, never changes a Status. Runs on Haiku.
cd "$(dirname "$0")/.." || exit 1
exec claude -p "Run skills/tracker-nextup/SKILL.md now. Follow it exactly; do not improvise." \
  --model claude-haiku-4-5-20251001 \
  --allowedTools "Read,mcp__claude_ai_Notion__notion-query-data-sources,mcp__claude_ai_Notion__notion-fetch,mcp__claude_ai_Notion__notion-update-page"
