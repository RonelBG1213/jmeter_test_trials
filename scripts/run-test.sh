#!/bin/bash

#############################################################
# Unified JMeter Test Execution Script
# Purpose: Execute all types of performance tests from one script
# Supports: Load, Stress, Spike, Soak, Stability, Enterprise Backend, Enterprise UI
#############################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_PLANS_DIR="$PROJECT_ROOT/test-plans"
RESULTS_DIR="$PROJECT_ROOT/results"
REPORTS_DIR="$PROJECT_ROOT/reports"
LOGS_DIR="$PROJECT_ROOT/logs"
CONFIG_DIR="$PROJECT_ROOT/config"

# Timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Default values
TEST_TYPE=""
ENVIRONMENT="production"
GENERATE_REPORT=false
DISTRIBUTED=false
REMOTE_HOSTS=""
CUSTOM_USERS=""
CUSTOM_DURATION=""
CUSTOM_PROPS_FILE=""

#############################################################
# Functions
#############################################################

print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║         JMeter Performance Test Orchestrator             ║
    ║              Unified Test Execution Script               ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    cat << EOF
${GREEN}Usage:${NC} $0 <test-type> [environment] [options]

${YELLOW}TEST TYPES:${NC}
  ${CYAN}Basic Tests:${NC}
    load              LoadTest.jmx          - Basic load test (10 users)
    stress            StressTest.jmx        - Stress test (100 users)
    spike             SpikeTest.jmx         - Spike test (200 users, rapid)
    soak              SoakTest.jmx          - Soak test (50 users, long duration)
    stability         StabilityTest.jmx     - Stability test
    all               Run all basic tests

  ${CYAN}Enterprise Tests:${NC}
    enterprise        EnterpriseLoadTest.jmx      - Backend API (500 users)
    enterprise-backend EnterpriseLoadTest.jmx     - Backend API (500 users)
    ui                EnterpriseUILoadTest.jmx    - Frontend UI (300 users)
    enterprise-ui     EnterpriseUILoadTest.jmx    - Frontend UI (300 users)

${YELLOW}ENVIRONMENTS:${NC} (default: production)
    dev               Development environment
    staging           Staging environment
    production        Production environment

${YELLOW}OPTIONS:${NC}
    --report, -r                Generate HTML dashboard report
    --distributed, -d           Run in distributed mode
    --hosts HOST1,HOST2         Remote JMeter server hosts (comma-separated)
    --users N                   Override number of users
    --duration N                Override test duration (seconds)
    --props FILE                Custom properties file path
    --env ENV                   Environment (dev/staging/production)
    --help, -h                  Show this help message

${YELLOW}EXAMPLES:${NC}
    ${CYAN}# Basic tests${NC}
    $0 load --report
    $0 stress staging --report
    $0 spike dev --users 50 --report
    $0 all --report

    ${CYAN}# Enterprise backend API test${NC}
    $0 enterprise production --report
    $0 enterprise-backend staging --users 200 --report

    ${CYAN}# Enterprise UI test${NC}
    $0 ui --report
    $0 enterprise-ui staging --users 100 --duration 600 --report

    ${CYAN}# Distributed testing${NC}
    $0 enterprise production --distributed --hosts slave1,slave2,slave3 --report

    ${CYAN}# Soak test (long duration)${NC}
    $0 soak production --duration 7200 --report

${YELLOW}TEST TYPE DETAILS:${NC}
    ${CYAN}load${NC}          - 10 users, 5 loops, 10s ramp-up
    ${CYAN}stress${NC}        - 100 users, 10 loops, 60s ramp-up
    ${CYAN}spike${NC}         - 200 users, 3 loops, 10s ramp-up (rapid load increase)
    ${CYAN}soak${NC}          - 50 users, 200 loops, 30s ramp-up (long duration)
    ${CYAN}enterprise${NC}    - 500 users (200+200+100), 30min, backend API
    ${CYAN}ui${NC}            - 300 users (100+150+50), 30min, full browser simulation

EOF
    exit 0
}

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command -v jmeter &> /dev/null; then
        print_error "JMeter is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v java &> /dev/null; then
        print_error "Java is not installed"
        exit 1
    fi
    
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 8 ]; then
        print_error "Java 8 or higher is required"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

get_test_plan_file() {
    local test_type=$1
    local test_file=""
    
    case $test_type in
        load)
            test_file="LoadTest.jmx"
            ;;
        stress)
            test_file="StressTest.jmx"
            ;;
        spike)
            test_file="SpikeTest.jmx"
            ;;
        soak)
            test_file="SoakTest.jmx"
            ;;
        stability)
            test_file="StabilityTest.jmx"
            ;;
        enterprise|enterprise-backend)
            test_file="EnterpriseLoadTest.jmx"
            ;;
        ui|enterprise-ui)
            test_file="EnterpriseUILoadTest.jmx"
            ;;
        all)
            echo "all"
            return
            ;;
        *)
            print_error "Unknown test type: $test_type"
            usage
            ;;
    esac
    
    local full_path="$TEST_PLANS_DIR/$test_file"
    if [ ! -f "$full_path" ]; then
        print_error "Test plan not found: $full_path"
        exit 1
    fi
    
    echo "$full_path"
}

get_properties_file() {
    local test_type=$1
    local env=$2
    local props_file=""
    
    # Custom properties file takes precedence
    if [ -n "$CUSTOM_PROPS_FILE" ]; then
        if [ -f "$CUSTOM_PROPS_FILE" ]; then
            echo "$CUSTOM_PROPS_FILE"
            return
        else
            print_warning "Custom properties file not found: $CUSTOM_PROPS_FILE"
        fi
    fi
    
    # Determine properties file based on test type and environment
    case $test_type in
        ui|enterprise-ui)
            props_file="$CONFIG_DIR/environments/ui-${env}.properties"
            ;;
        enterprise|enterprise-backend)
            props_file="$CONFIG_DIR/environments/${env}.properties"
            ;;
        *)
            props_file="$CONFIG_DIR/environments/${env}.properties"
            # Also check for credentials
            if [ -f "$CONFIG_DIR/credentials/credentials.properties" ]; then
                echo "$CONFIG_DIR/credentials/credentials.properties"
                return
            fi
            ;;
    esac
    
    if [ -f "$props_file" ]; then
        echo "$props_file"
    else
        print_warning "Properties file not found: $props_file"
        echo ""
    fi
}

setup_jvm_args() {
    local test_type=$1
    
    case $test_type in
        ui|enterprise-ui)
            # UI tests need more memory
            export JVM_ARGS="-Xms2g -Xmx6g -XX:MaxMetaspaceSize=1g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
            print_info "JVM configured for UI testing (6GB heap)"
            ;;
        enterprise|enterprise-backend)
            # Backend tests need moderate memory
            export JVM_ARGS="-Xms1g -Xmx4g -XX:MaxMetaspaceSize=512m -XX:+UseG1GC"
            print_info "JVM configured for backend testing (4GB heap)"
            ;;
        stress|spike|soak)
            # High-load tests need more memory
            export JVM_ARGS="-Xms1g -Xmx3g -XX:MaxMetaspaceSize=512m -XX:+UseG1GC"
            print_info "JVM configured for high-load testing (3GB heap)"
            ;;
        *)
            # Basic tests use default
            export JVM_ARGS="-Xms512m -Xmx2g"
            print_info "JVM configured for basic testing (2GB heap)"
            ;;
    esac
}

create_directories() {
    mkdir -p "$RESULTS_DIR"
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$LOGS_DIR"
}

build_jmeter_command() {
    local test_type=$1
    local test_plan=$2
    local props_file=$3
    local cmd="jmeter -n"
    
    # Test plan
    cmd="$cmd -t $test_plan"
    
    # Properties file
    if [ -n "$props_file" ]; then
        cmd="$cmd -q $props_file"
        print_info "Using properties: $(basename $props_file)"
    fi
    
    # Results file
    local test_name=$(basename "$test_plan" .jmx | tr '[:upper:]' '[:lower:]')
    local results_file="$RESULTS_DIR/${test_name}-${TIMESTAMP}.jtl"
    cmd="$cmd -l $results_file"
    
    # Log file
    local log_file="$LOGS_DIR/jmeter-${test_name}-${TIMESTAMP}.log"
    cmd="$cmd -j $log_file"
    
    # Custom users
    if [ -n "$CUSTOM_USERS" ]; then
        print_info "Overriding user count: $CUSTOM_USERS"
        
        case $test_type in
            enterprise|enterprise-backend)
                # Scale proportionally: 40%, 40%, 20%
                local browse_users=$((CUSTOM_USERS * 40 / 100))
                local shopping_users=$((CUSTOM_USERS * 40 / 100))
                local checkout_users=$((CUSTOM_USERS * 20 / 100))
                cmd="$cmd -Jbrowse.users=$browse_users"
                cmd="$cmd -Jshopping.users=$shopping_users"
                cmd="$cmd -Jcheckout.users=$checkout_users"
                ;;
            ui|enterprise-ui)
                # Scale proportionally: 33%, 50%, 17%
                local homepage_users=$((CUSTOM_USERS * 33 / 100))
                local shopping_users=$((CUSTOM_USERS * 50 / 100))
                local checkout_users=$((CUSTOM_USERS * 17 / 100))
                cmd="$cmd -Jhomepage.users=$homepage_users"
                cmd="$cmd -Jshopping.users=$shopping_users"
                cmd="$cmd -Jcheckout.users=$checkout_users"
                ;;
        esac
    fi
    
    # Custom duration
    if [ -n "$CUSTOM_DURATION" ]; then
        print_info "Overriding test duration: ${CUSTOM_DURATION}s"
        cmd="$cmd -Jtest.duration=$CUSTOM_DURATION"
    fi
    
    # HTML Report
    if [ "$GENERATE_REPORT" = true ]; then
        local report_dir="$REPORTS_DIR/${test_name}-${TIMESTAMP}"
        cmd="$cmd -e -o $report_dir"
        print_info "Report will be generated: $report_dir"
    fi
    
    # Distributed mode
    if [ "$DISTRIBUTED" = true ]; then
        if [ -z "$REMOTE_HOSTS" ]; then
            print_error "Remote hosts must be specified for distributed mode"
            exit 1
        fi
        cmd="$cmd -R $REMOTE_HOSTS"
        print_info "Distributed mode: $REMOTE_HOSTS"
    fi
    
    echo "$cmd"
}

print_test_info() {
    local test_type=$1
    local environment=$2
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Test Configuration${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "Test Type:        ${YELLOW}$test_type${NC}"
    echo -e "Environment:      ${YELLOW}$environment${NC}"
    echo -e "Timestamp:        ${YELLOW}$TIMESTAMP${NC}"
    
    if [ -n "$CUSTOM_USERS" ]; then
        echo -e "Users:            ${YELLOW}$CUSTOM_USERS${NC}"
    fi
    
    if [ -n "$CUSTOM_DURATION" ]; then
        echo -e "Duration:         ${YELLOW}${CUSTOM_DURATION}s${NC}"
    fi
    
    if [ "$DISTRIBUTED" = true ]; then
        echo -e "Mode:             ${YELLOW}Distributed${NC}"
        echo -e "Hosts:            ${YELLOW}$REMOTE_HOSTS${NC}"
    else
        echo -e "Mode:             ${YELLOW}Standalone${NC}"
    fi
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

run_single_test() {
    local test_type=$1
    local test_plan=$2
    local props_file=$3
    
    # Setup JVM
    setup_jvm_args "$test_type"
    
    # Build command
    local cmd=$(build_jmeter_command "$test_type" "$test_plan" "$props_file")
    
    print_info "Executing: $cmd"
    echo ""
    
    # Execute
    eval $cmd
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo ""
        print_success "Test completed successfully! ✓"
        
        if [ "$GENERATE_REPORT" = true ]; then
            local test_name=$(basename "$test_plan" .jmx | tr '[:upper:]' '[:lower:]')
            local report_dir="$REPORTS_DIR/${test_name}-${TIMESTAMP}"
            print_info "Opening HTML report..."
            open "$report_dir/index.html" 2>/dev/null || xdg-open "$report_dir/index.html" 2>/dev/null || print_info "Report available at: $report_dir/index.html"
        fi
        return 0
    else
        print_error "Test failed with exit code: $exit_code"
        return $exit_code
    fi
}

run_test() {
    local test_type=$1
    
    if [ "$test_type" = "all" ]; then
        print_info "Running all basic test plans..."
        echo ""
        
        local all_passed=true
        for type in load stress spike soak stability; do
            local test_plan=$(get_test_plan_file "$type")
            if [ -f "$test_plan" ]; then
                print_test_info "$type" "$ENVIRONMENT"
                local props_file=$(get_properties_file "$type" "$ENVIRONMENT")
                run_single_test "$type" "$test_plan" "$props_file"
                if [ $? -ne 0 ]; then
                    all_passed=false
                fi
                echo ""
            else
                print_warning "Test plan not found, skipping: $type"
            fi
        done
        
        if [ "$all_passed" = true ]; then
            print_success "All tests completed successfully!"
        else
            print_error "Some tests failed"
            exit 1
        fi
    else
        local test_plan=$(get_test_plan_file "$test_type")
        local props_file=$(get_properties_file "$test_type" "$ENVIRONMENT")
        
        print_test_info "$test_type" "$ENVIRONMENT"
        run_single_test "$test_type" "$test_plan" "$props_file"
        
        if [ $? -ne 0 ]; then
            exit 1
        fi
    fi
}

print_summary() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Test Execution Summary${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "Test Type:        ${YELLOW}$TEST_TYPE${NC}"
    echo -e "Environment:      ${YELLOW}$ENVIRONMENT${NC}"
    echo -e "Timestamp:        ${YELLOW}$TIMESTAMP${NC}"
    echo -e "Results:          ${YELLOW}$RESULTS_DIR${NC}"
    
    if [ "$GENERATE_REPORT" = true ]; then
        echo -e "Reports:          ${YELLOW}$REPORTS_DIR${NC}"
    fi
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

#############################################################
# Main Script
#############################################################

# Show banner
print_banner

# Check arguments
if [ $# -eq 0 ]; then
    print_error "No test type specified"
    echo ""
    usage
fi

# Parse arguments
TEST_TYPE="$1"
shift

# Check for help
if [ "$TEST_TYPE" = "--help" ] || [ "$TEST_TYPE" = "-h" ] || [ "$TEST_TYPE" = "help" ]; then
    usage
fi

# Parse optional environment (second argument without dashes)
if [ $# -gt 0 ] && [[ ! "$1" =~ ^- ]]; then
    ENVIRONMENT="$1"
    shift
fi

# Parse remaining options
while [[ $# -gt 0 ]]; do
    case $1 in
        --report|-r)
            GENERATE_REPORT=true
            shift
            ;;
        --distributed|-d)
            DISTRIBUTED=true
            shift
            ;;
        --hosts)
            REMOTE_HOSTS="$2"
            shift 2
            ;;
        --users)
            CUSTOM_USERS="$2"
            shift 2
            ;;
        --duration)
            CUSTOM_DURATION="$2"
            shift 2
            ;;
        --props)
            CUSTOM_PROPS_FILE="$2"
            shift 2
            ;;
        --env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Execute
check_prerequisites
create_directories
run_test "$TEST_TYPE"
print_summary

exit 0
