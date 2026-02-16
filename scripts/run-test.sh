#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULTS_DIR="$PROJECT_ROOT/results"
REPORTS_DIR="$PROJECT_ROOT/reports"
LOGS_DIR="$PROJECT_ROOT/logs"
TEST_PLANS_DIR="$PROJECT_ROOT/test-plans"
CONFIG_DIR="$PROJECT_ROOT/config"

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_jmeter() {
    if ! command -v jmeter &> /dev/null; then
        print_error "JMeter is not installed or not in PATH"
        exit 1
    fi
    print_success "JMeter found: $(jmeter --version 2>&1 | head -n 1)"
}

usage() {
    echo "Usage: $0 [test-name] [options]"
    echo ""
    echo "Test Names:"
    echo "  load        Run LoadTest.jmx (10 threads, 5 loops)"
    echo "  stress      Run StressTest.jmx (100 threads, 10 loops)"
    echo "  spike       Run SpikeTest.jmx (200 threads, rapid ramp-up)"
    echo "  soak        Run SoakTest.jmx (50 threads, 200 loops - long duration)"
    echo "  stability   Run StabilityTest.jmx (25 threads, 100 loops)"
    echo "  all         Run all test plans"
    echo ""
    echo "Options:"
    echo "  -r, --report    Generate HTML dashboard report"
    echo "  -h, --help      Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 load                    # Run load test"
    echo "  $0 spike --report          # Run spike test with report"
    echo "  $0 soak --report           # Run soak test with report"
    echo "  $0 all --report            # Run all tests with reports"
    echo ""
    echo "Note: Credentials should be in config/credentials/credentials.properties"
    exit 0
}

run_test() {
    local test_file=$1
    local test_name=$2
    local generate_report=$3
    
    local result_file="$RESULTS_DIR/${test_name}-${TIMESTAMP}.jtl"
    local report_folder="$REPORTS_DIR/${test_name}-${TIMESTAMP}"
    local log_file="$LOGS_DIR/jmeter-${test_name}-${TIMESTAMP}.log"
    
    print_info "Starting test: $test_name"
    print_info "Test plan: $test_file"
    print_info "Results: $result_file"
    print_info "Log file: $log_file"
    
    mkdir -p "$RESULTS_DIR"
    mkdir -p "$LOGS_DIR"
    
    JMETER_OPTS=()
    if [ -f "$CONFIG_DIR/credentials/credentials.properties" ]; then
        JMETER_OPTS+=(-q "$CONFIG_DIR/credentials/credentials.properties")
        print_info "Loading credentials from properties file"
    else
        print_warning "No credentials file found at $CONFIG_DIR/credentials/credentials.properties"
        print_warning "Copy from template: cp $CONFIG_DIR/credentials/credentials.properties.template $CONFIG_DIR/credentials/credentials.properties"
    fi
    
    if [ "$generate_report" = true ]; then
        mkdir -p "$REPORTS_DIR"
        print_info "Report will be generated at: $report_folder"
        
        jmeter "${JMETER_OPTS[@]}" -n -t "$test_file" -l "$result_file" -e -o "$report_folder" -j "$log_file"
    else
        jmeter "${JMETER_OPTS[@]}" -n -t "$test_file" -l "$result_file" -j "$log_file"
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Test completed: $test_name"
        print_info "Results saved to: $result_file"
        
        if [ "$generate_report" = true ]; then
            print_success "Report generated: $report_folder/index.html"
            print_info "Open report with: open $report_folder/index.html"
        fi
        print_info "Log file saved to: $log_file"
    else
        print_error "Test failed: $test_name"
        print_info "Check log file for details: $log_file"
        exit 1
    fi
    
    echo ""
}

main() {
    check_jmeter
    if [ $# -eq 0 ]; then
        usage
    fi
    
    TEST_NAME=$1
    GENERATE_REPORT=false
    
    shift
    while [ $# -gt 0 ]; do
        case $1 in
            -r|--report)
                GENERATE_REPORT=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                ;;
        esac
    done
    
    case $TEST_NAME in
        load)
            run_test "$TEST_PLANS_DIR/LoadTest.jmx" "loadtest" $GENERATE_REPORT
            ;;
        stress)
            run_test "$TEST_PLANS_DIR/StressTest.jmx" "stresstest" $GENERATE_REPORT
            ;;
        spike)
            run_test "$TEST_PLANS_DIR/SpikeTest.jmx" "spiketest" $GENERATE_REPORT
            ;;
        soak)
            run_test "$TEST_PLANS_DIR/SoakTest.jmx" "soaktest" $GENERATE_REPORT
            ;;
        stability)
            run_test "$TEST_PLANS_DIR/StabilityTest.jmx" "stabilitytest" $GENERATE_REPORT
            ;;
        all)
            print_info "Running all test plans..."
            echo ""
            run_test "$TEST_PLANS_DIR/LoadTest.jmx" "loadtest" $GENERATE_REPORT
            run_test "$TEST_PLANS_DIR/StressTest.jmx" "stresstest" $GENERATE_REPORT
            run_test "$TEST_PLANS_DIR/SpikeTest.jmx" "spiketest" $GENERATE_REPORT
            run_test "$TEST_PLANS_DIR/SoakTest.jmx" "soaktest" $GENERATE_REPORT
            run_test "$TEST_PLANS_DIR/StabilityTest.jmx" "stabilitytest" $GENERATE_REPORT
            print_success "All tests completed!"
            ;;
        *)
            print_error "Unknown test name: $TEST_NAME"
            usage
            ;;
    esac
}

main "$@"
