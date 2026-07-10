#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract model name
model=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')

# Extract context usage percentage
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Extract cost
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

# Build status line parts
parts=()

# Add model name
parts+=("${model}")

# Add context usage bar if available
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  filled=$((used_int * 20 / 100))
  empty=$((20 - filled))
  bar="["
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  bar+="]"
  parts+=("Context: ${bar} ${used_int}%")
fi

# Add cost if available
if [ -n "$cost" ]; then
  cost_formatted=$(printf "%.4f" "$cost")
  parts+=("Cost: \$${cost_formatted}")
fi

# Join parts with " | "
output=""
for ((i=0; i<${#parts[@]}; i++)); do
  if [ $i -gt 0 ]; then
    output+=" | "
  fi
  output+="${parts[i]}"
done

echo "$output"
