#!/usr/bin/env bash
# Real-time state collector for Omarchy Focus Hub Plugin
set -euo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/omarchy-study-mode/state.json"
CONFIG_FILE="${HOME}/.config/omarchy/study-mode.json"
STATS_FILE="${HOME}/.config/omarchy/study-stats.json"

NOW=$(date +%s)

# Read State
ACTIVE=false
TYPE="none"
LABEL="Idle"
STARTED_AT=0
ENDS_AT=0
TOTAL_SECS=0
REMAINING_SECS=0
PROGRESS=0.0

PAUSED_STUDY="null"
if [[ -f "$STATE_FILE" ]]; then
  DATA=$(cat "$STATE_FILE" 2>/dev/null || echo "{}")
  IS_ACT=$(jq -r '.active // false' <<< "$DATA" 2>/dev/null || echo "false")
  E_AT=$(jq -r '.ends_at // 0' <<< "$DATA" 2>/dev/null || echo "0")
  E_AT_INT=${E_AT%.*}
  if [[ "$IS_ACT" == "true" && "$E_AT_INT" -gt "$NOW" ]]; then
    ACTIVE=true
    TYPE=$(jq -r '.type // "study"' <<< "$DATA")
    LABEL=$(jq -r '.label // "Focus Session"' <<< "$DATA")
    STARTED_AT=$(jq -r '.started_at // 0' <<< "$DATA")
    ENDS_AT=$E_AT_INT
    TOTAL_SECS=$(jq -r '.total_seconds // 1500' <<< "$DATA")
    REMAINING_SECS=$((ENDS_AT - NOW))
    PAUSED_STUDY=$(jq -c '.paused_study // null' <<< "$DATA" 2>/dev/null || echo "null")
    if (( TOTAL_SECS > 0 )); then
      ELAPSED=$((TOTAL_SECS - REMAINING_SECS))
      PROGRESS=$(awk -v el="$ELAPSED" -v tot="$TOTAL_SECS" 'BEGIN { printf "%.2f", (el / tot) }')
    fi
  fi
fi

# Format remaining time
MINS=$((REMAINING_SECS / 60))
SECS=$((REMAINING_SECS % 60))
REMAINING_FORMATTED=$(printf "%02d:%02d" "$MINS" "$SECS")

# Active Window Info
ACTIVE_WIN=$(hyprctl activewindow -j 2>/dev/null || echo "{}")
WIN_CLASS=$(jq -r '.class // ""' <<< "$ACTIVE_WIN" 2>/dev/null || echo "")
WIN_TITLE=$(jq -r '.title // ""' <<< "$ACTIVE_WIN" 2>/dev/null || echo "")

# Read Config
if [[ ! -f "$CONFIG_FILE" ]]; then
  CONFIG_JSON='{"allowed_domains":[],"blocked_domains":[],"allowed_apps":[],"strict_website_whitelist":false,"sound_alerts":true}'
else
  CONFIG_JSON=$(cat "$CONFIG_FILE" 2>/dev/null || echo "{}")
fi

# Read Today's Stats
TODAY=$(date +%Y-%m-%d)
TODAY_MINS=0
TODAY_SESSIONS=0
if [[ -f "$STATS_FILE" ]]; then
  TODAY_MINS=$(jq -r ".[\"$TODAY\"].minutes // 0" "$STATS_FILE" 2>/dev/null || echo 0)
  TODAY_SESSIONS=$(jq -r ".[\"$TODAY\"].sessions // 0" "$STATS_FILE" 2>/dev/null || echo 0)
fi

# Read Installed Apps Cache
APPS_CACHE="${HOME}/.config/omarchy/installed-apps.json"
if [[ -f "$APPS_CACHE" ]]; then
  INSTALLED_APPS=$(cat "$APPS_CACHE" 2>/dev/null || echo "[]")
else
  INSTALLED_APPS="[]"
fi

# Read Completion Event (for Reward Animation)
COMPLETION_FILE="${XDG_RUNTIME_DIR:-/tmp}/omarchy-study-mode/completion.json"
COMPLETION_DATA="null"
if [[ -f "$COMPLETION_FILE" ]]; then
  COMPLETION_DATA=$(cat "$COMPLETION_FILE" 2>/dev/null || echo "null")
fi

# Produce unified JSON response
jq -n \
  --argjson active "$ACTIVE" \
  --arg type "$TYPE" \
  --arg label "$LABEL" \
  --argjson started_at "$STARTED_AT" \
  --argjson ends_at "$ENDS_AT" \
  --argjson total_seconds "$TOTAL_SECS" \
  --argjson remaining_seconds "$REMAINING_SECS" \
  --arg remaining_formatted "$REMAINING_FORMATTED" \
  --argjson progress "$PROGRESS" \
  --arg win_class "$WIN_CLASS" \
  --arg win_title "$WIN_TITLE" \
  --argjson config "$CONFIG_JSON" \
  --argjson today_minutes "$TODAY_MINS" \
  --argjson today_sessions "$TODAY_SESSIONS" \
  --argjson installed_apps "$INSTALLED_APPS" \
  --argjson paused_study "$PAUSED_STUDY" \
  --argjson completion "$COMPLETION_DATA" \
  '{
    active: $active,
    type: $type,
    label: $label,
    started_at: $started_at,
    ends_at: $ends_at,
    total_seconds: $total_seconds,
    remaining_seconds: $remaining_seconds,
    remaining_formatted: $remaining_formatted,
    progress: $progress,
    active_window: {
      class: $win_class,
      title: $win_title
    },
    allowed_domains: ($config.allowed_domains // []),
    blocked_domains: ($config.blocked_domains // []),
    allowed_apps: ($config.allowed_apps // []),
    strict_website_whitelist: ($config.strict_website_whitelist // false),
    sound_alerts: ($config.sound_alerts // true),
    installed_apps: $installed_apps,
    paused_study: $paused_study,
    completion: $completion,
    stats: {
      today_minutes: $today_minutes,
      today_sessions: $today_sessions
    }
  }'
