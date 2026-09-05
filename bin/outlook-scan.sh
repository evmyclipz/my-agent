#!/bin/bash
# Scan the Outlook inbox for messages received in the last N days (default 10).
# Usage: outlook-scan.sh [days]
# Output: one message per block, pipe-delimited header line then body:
#   ---MSG--- <id>|<time received>|<sender address>|<subject>
#   <plain text body>
#   ---END---
# Uses a `whose time received > cutoff` filter (fast — lets Outlook do the
# filtering) instead of iterating the whole inbox, which is what timed out
# under a smaller model composing this script inline. Kept as a single fixed
# script specifically so nothing has to write AppleScript at call time.

DAYS="${1:-10}"
ACCOUNT="maliper@rose-hulman.edu"

osascript <<EOF
tell application "Microsoft Outlook"
	set acct to exchange account "$ACCOUNT"
	set theInbox to mail folder "Inbox" of acct
	set cutoff to (current date) - ($DAYS * days)
	set msgs to (messages of theInbox whose time received > cutoff)
	set n to count of msgs
	set out to ""
	repeat with i from 1 to n
		try
			set m to item i of msgs
			set mid to (id of m) as string
			set tr to (time received of m) as string
			set se to "?"
			try
				set se to (address of (sender of m)) as string
			end try
			set su to "?"
			try
				set su to (subject of m) as string
			end try
			set bd to "?"
			try
				set bd to (plain text content of m) as string
			end try
			set out to out & "---MSG--- " & mid & "|" & tr & "|" & se & "|" & su & linefeed & bd & linefeed & "---END---" & linefeed
		end try
	end repeat
	return out
end tell
EOF
