#!/bin/bash

MAIN="{{MAIN}}"
BRUTE="{{BRUTE}}"
GEN="{{GEN}}"

TIME_LIMIT=2
BRUTE_TIME_LIMIT=5

BUILD_DIR="build"
TMP_DIR="/tmp/stress_$$"

mkdir -p "$BUILD_DIR" "$TMP_DIR"
trap "rm -rf '$TMP_DIR'" EXIT

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

compile() {
    local src="$1" bin="$BUILD_DIR/$(basename "${1%.cpp}")"
    [[ "$src" != *.cpp ]] && return 0
    echo -n "Compiling $(basename "$src")... "
    if g++ -O2 -std=c++17 -o "$bin" "$src" 2>"$TMP_DIR/compile.err"; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAILED${NC}"
        cat "$TMP_DIR/compile.err"
        exit 1
    fi
}

run_limited() {
    local cmd="$1" input="$2" output="$3" errfile="$4" tlimit="$5"
    local start=$(date +%s.%N)
    
    timeout --signal=KILL "$tlimit" bash -c "$cmd < '$input' > '$output' 2> '$errfile'"
    RUN_STATUS=$?
    
    RUN_TIME=$(echo "$(date +%s.%N) - $start" | bc)
    
    case $RUN_STATUS in
        0)   RUN_VERDICT="OK" ;;
        137|124) RUN_VERDICT="TLE" ;;
        139) RUN_VERDICT="RTE (segfault)" ;;
        134) RUN_VERDICT="RTE (abort)" ;;
        136) RUN_VERDICT="RTE (FPE)" ;;
        *)   RUN_VERDICT="RTE (exit $RUN_STATUS)" ;;
    esac
}

get_run_cmd() {
    case "$1" in
        *.cpp) echo "$BUILD_DIR/$(basename "${1%.cpp}")" ;;
        *.py)  echo "python3 $1" ;;
        *)     echo "./$1" ;;
    esac
}

for f in "$MAIN" "$BRUTE" "$GEN"; do
    [[ -f "$f" ]] || { echo -e "${RED}Error: $f not found${NC}"; exit 1; }
done

compile "$MAIN"
compile "$BRUTE"

MAIN_CMD=$(get_run_cmd "$MAIN")
BRUTE_CMD=$(get_run_cmd "$BRUTE")

echo -e "\n${GREEN}Stress testing...${NC} (TL=${TIME_LIMIT}s)"
echo

i=1
while true; do
    printf "\r${YELLOW}Test %-6d${NC}" "$i"
    
    python3 "$GEN" > "$TMP_DIR/in.txt" 2>&1 || { echo -e "\n${RED}Generator failed${NC}"; exit 1; }
    
    run_limited "$MAIN_CMD" "$TMP_DIR/in.txt" "$TMP_DIR/main.txt" "$TMP_DIR/main.err" "$TIME_LIMIT"
    if [[ "$RUN_VERDICT" != "OK" ]]; then
        echo -e "\n${RED}=== $RUN_VERDICT on test $i (${RUN_TIME}s) ===${NC}"
        echo "--- INPUT ---"; cat "$TMP_DIR/in.txt"
        [[ -s "$TMP_DIR/main.err" ]] && { echo "--- STDERR ---"; cat "$TMP_DIR/main.err"; }
        exit 1
    fi
    
    run_limited "$BRUTE_CMD" "$TMP_DIR/in.txt" "$TMP_DIR/brute.txt" "$TMP_DIR/brute.err" "$BRUTE_TIME_LIMIT"
    [[ "$RUN_VERDICT" != "OK" ]] && { echo -e "\n${RED}Brute $RUN_VERDICT${NC}"; exit 1; }
    
    if ! diff -q "$TMP_DIR/main.txt" "$TMP_DIR/brute.txt" > /dev/null 2>&1; then
        echo -e "\n${RED}=== WA on test $i ===${NC}"
        echo "--- INPUT ---";  cat "$TMP_DIR/in.txt"
        echo "--- MAIN ---";   cat "$TMP_DIR/main.txt"
        echo "--- EXPECTED ---"; cat "$TMP_DIR/brute.txt"
        exit 1
    fi
    
    ((i++))
done
