#!/bin/bash
# On-demand coursework sync: Outlook + Moodle + CSSE416 sheet -> Notion Homework Tracker.
# Runs the skill on Haiku for low token cost. Needs: Mac awake, Outlook open in Legacy
# mode, and (for the Moodle step) a live Rose SSO session in Chrome.
cd "$(dirname "$0")/.." || exit 1
exec claude -p "Run skills/coursework-sync/SKILL.md now. Follow it exactly; do not improvise." \
  --model claude-haiku-4-5-20251001 \
  --allowedTools "Bash,Read,Write,Edit,mcp__claude_ai_Notion__notion-query-data-sources,mcp__claude_ai_Notion__notion-create-pages,mcp__claude_ai_Notion__notion-update-page,mcp__claude_ai_Notion__notion-update-view,mcp__claude_ai_Notion__notion-fetch,mcp__claude_ai_Google_Drive__read_file_content,mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__get_page_text,mcp__claude-in-chrome__read_page,mcp__claude-in-chrome__javascript_tool,mcp__claude-in-chrome__tabs_close_mcp"
