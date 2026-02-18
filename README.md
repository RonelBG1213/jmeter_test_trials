# JMeter Performance Testing Framework

Enterprise-grade performance and load testing framework for web applications using Apache JMeter 5.6.3+.

> 📖 **Quick Start**: See [FRAMEWORK_QUICK_REFERENCE.md](FRAMEWORK_QUICK_REFERENCE.md) for comprehensive guide  
> 📋 **Enterprise Test Details**: See [QUICK_REFERENCE.txt](QUICK_REFERENCE.txt) for backend API test card

---

## 🎯 Framework Overview

This framework supports multiple test types from basic load tests to enterprise-grade performance testing:

- **Basic Tests**: Load, Stress, Spike, Soak, Stability (10-200 users)
- **Enterprise Backend**: Large-scale API testing (500+ users, 30min)
- **Enterprise UI**: Frontend/browser simulation (300+ users, 30min)
- **Unified Execution**: Single script to run all test types
- **Security-First**: Template-based configuration, gitignored secrets
- **CI/CD Ready**: Easy integration with Jenkins, GitHub Actions, etc.

---

## Project Structure

```
JmeterTest/
├── test-plans/          # JMeter test plan files (.jmx)
│   ├── LoadTest.jmx                # Basic load test (10 users)
│   ├── StressTest.jmx              # Stress test (100 users)
│   ├── SpikeTest.jmx               # Spike test (200 users, rapid)
│   ├── SoakTest.jmx                # Soak test (50 users, long duration)
│   ├── StabilityTest.jmx           # Stability test
│   ├── EnterpriseLoadTest.jmx      # Enterprise backend API (500 users)
│   └── EnterpriseUILoadTest.jmx    # Enterprise UI/frontend (300 users)
│
├── config/              # Configuration files
│   ├── environments/    # Environment-specific properties
│   │   ├── dev.properties
│   │   ├── staging.properties
│   │   ├── production.properties
│   │   └── ui-production.properties
│   └── credentials/     # Authentication credentials
│       └── credentials.properties
│
├── data/                # Test data files
│   ├── users.csv        # User credentials (gitignored)
│   ├── users.csv.template
│   └── products.csv
│
├── scripts/             # Unified test execution
│   └── run-test.sh      # Single script for all test types
│
├── results/             # Test results (.jtl files)
├── reports/             # HTML dashboard reports
├── logs/                # JMeter log files
│
└── Documentation/       # Comprehensive guides
    ├── FRAMEWORK_QUICK_REFERENCE.md    # Complete framework guide
    ├── QUICK_REFERENCE.txt             # Enterprise backend test card
    ├── ENTERPRISE_TEST_README.md       # Backend API test details
    ├── UI_LOAD_TEST_README.md          # Frontend UI test details
    ├── SECURITY_GUIDE.md               # Security best practices
    └── UI_VS_BACKEND_COMPARISON.md     # Test type comparison
```

### Directory Descriptions

| Directory | Purpose |
|-----------|---------|
| **test-plans/** | Contains all JMeter test plan files (.jmx) - basic and enterprise-grade tests |
| **config/** | Environment-specific properties and credentials (use templates for sensitive data) |
| **data/** | External test data (CSV, JSON) - credentials and test datasets |
| **scripts/** | Unified test execution script supporting all test types |
| **results/** | Raw test results in .jtl format (timestamped, gitignored) |
| **reports/** | HTML dashboard reports with performance metrics (gitignored) |
| **logs/** | JMeter execution logs for debugging (gitignored) |

---

## Installation Guide

### Prerequisites

- Java 8 or higher (JMeter requires Java)
- Git (for cloning the repository)

### Step-by-Step Installation

#### macOS

**Using Homebrew (Recommended)**

**1. Install Homebrew** (if not already installed)

Check if Homebrew is installed:
```bash
brew --version
```

If not installed, install Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**2. Update Homebrew**
```bash
brew update
```

**3. Install Java**

Check if Java is installed:
```bash
java -version
```

Install OpenJDK using Homebrew:
```bash
brew install openjdk@11
```

Link Java to system:
```bash
sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
```

For Intel Macs, use:
```bash
sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
```

Add to PATH in `~/.zshrc`:
```bash
echo 'export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Verify Java installation:
```bash
java -version
```

**4. Install JMeter**

Install JMeter via Homebrew:
```bash
brew install jmeter
```

Verify JMeter installation:
```bash
jmeter -v
```

Expected output:
```
    _    ____   _    ____ _   _ _____       _ __  __ _____ _____ _____ ____
   / \  |  _ \ / \  / ___| | | | ____|     | |  \/  | ____|_   _| ____|  _ \
  / _ \ | |_) / _ \| |   | |_| |  _|    _  | | |\/| |  _|   | | |  _| | |_) |
 / ___ \|  __/ ___ \ |___|  _  | |___  | |_| | |  | | |___  | | | |___|  _ <
/_/   \_\_| /_/   \_\____|_| |_|_____|  \___/|_|  |_|_____| |_| |_____|_| \_\ 5.6.3
```

**5. Install Git** (if not already installed)

```bash
brew install git
git --version
```

**6. Clone Project Repository**

```bash
cd ~/Documents
git clone <repository-url>
cd JmeterTest
```

**7. Setup Credentials**

Copy template:
```bash
cp config/credentials/credentials.properties.template config/credentials/credentials.properties
```

Edit credentials file:
```bash
nano config/credentials/credentials.properties
```

Or use any text editor:
```bash
open -e config/credentials/credentials.properties
```

Update with your test credentials:
```properties
test.username=your_username
test.password=your_password
```

Save and close the editor.

**8. Make Scripts Executable**

```bash
chmod +x scripts/*.sh
```

**9. Run Your First Test**

```bash
./scripts/run-test.sh load
```

**10. View Test Report**

Generate report with your test:
```bash
./scripts/run-test.sh load --report
```

Open report:
```bash
open reports/loadtest-*/index.html
```

---

**Troubleshooting on macOS:**

If you get "command not found: jmeter":
```bash
brew link jmeter
```

If you get Java-related errors:
```bash
brew reinstall openjdk@11
```

To update JMeter:
```bash
brew upgrade jmeter
```

To uninstall:
```bash
brew uninstall jmeter
brew uninstall openjdk@11
```

---

#### Linux (Ubuntu/Debian)

**1. Install Java**

```bash
sudo apt update
sudo apt install openjdk-11-jdk -y
java -version
```

**2. Install JMeter**

```bash
cd /tmp
wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.tgz
tar -xzf apache-jmeter-5.6.3.tgz
sudo mv apache-jmeter-5.6.3 /opt/
echo 'export PATH="/opt/apache-jmeter-5.6.3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**3. Verify Installation**
```bash
jmeter -v
```

**4. Clone Project**
```bash
git clone <repository-url>
cd JmeterTest
```

**5. Setup Credentials**
```bash
cp config/credentials/credentials.properties.template config/credentials/credentials.properties
nano config/credentials/credentials.properties
```

**6. Make Scripts Executable**
```bash
chmod +x scripts/*.sh
```

---

#### Windows

**1. Install Java**

Download and install Java JDK from:
- [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
- Or [Adoptium OpenJDK](https://adoptium.net/)

Verify installation in Command Prompt:
```cmd
java -version
```

**2. Set JAVA_HOME Environment Variable**

- Right-click "This PC" → Properties → Advanced System Settings
- Click "Environment Variables"
- Under System Variables, click "New"
- Variable name: `JAVA_HOME`
- Variable value: `C:\Program Files\Java\jdk-11` (adjust to your path)
- Click OK

**3. Install JMeter**

Download JMeter:
- Visit https://jmeter.apache.org/download_jmeter.cgi
- Download `apache-jmeter-5.6.3.zip`

Extract and setup:
- Extract ZIP to `C:\apache-jmeter-5.6.3`
- Add to PATH:
  - Environment Variables → System Variables → Path → Edit → New
  - Add: `C:\apache-jmeter-5.6.3\bin`
  - Click OK

**4. Verify Installation**

Open Command Prompt:
```cmd
jmeter -v
```

**5. Clone Project**

Using Git Bash or Command Prompt:
```cmd
git clone <repository-url>
cd JmeterTest
```

**6. Setup Credentials**

```cmd
copy config\credentials\credentials.properties.template config\credentials\credentials.properties
notepad config\credentials\credentials.properties
```

Edit and save with your test credentials.

**7. Run Tests**

Using Git Bash (recommended):
```bash
./scripts/run-test.sh load
```

Or using Command Prompt with JMeter directly:
```cmd
jmeter -n -t test-plans\LoadTest.jmx -l results\results.jtl -q config\credentials\credentials.properties
```

---

## How to Use Scripts

### Run Tests Using Unified Script

Navigate to project root and use the run-test.sh script - it supports all test types:

#### Basic Tests

```bash
# Run load test (10 users, 5 loops)
./scripts/run-test.sh load --report

# Run stress test (100 users, 10 loops)
./scripts/run-test.sh stress --report

# Run spike test (200 users, rapid 10s ramp-up, 3 loops)
./scripts/run-test.sh spike --report

# Run soak test (50 users, 200 loops, sustained load)
./scripts/run-test.sh soak --report

# Run stability test
./scripts/run-test.sh stability --report

# Run all basic tests
./scripts/run-test.sh all --report
```

#### Enterprise Tests

```bash
# Enterprise backend API test (500 users, 30 min)
./scripts/run-test.sh enterprise production --report

# Enterprise backend with custom load
./scripts/run-test.sh enterprise staging --users 200 --report

# Enterprise UI/Frontend test (300 users, 30 min)
./scripts/run-test.sh ui --report

# Enterprise UI with custom duration
./scripts/run-test.sh enterprise-ui --users 100 --duration 600 --report
```

#### Advanced Options

```bash
# Use specific environment
./scripts/run-test.sh load dev --report
./scripts/run-test.sh stress staging --report

# Override user count
./scripts/run-test.sh enterprise --users 200 --report

# Override duration (seconds)
./scripts/run-test.sh soak --duration 7200 --report

# Custom properties file
./scripts/run-test.sh load --props /path/to/custom.properties --report

# Distributed testing (for 1000+ users)
./scripts/run-test.sh enterprise production \
  --distributed \
  --hosts jmeter-slave1:1099,jmeter-slave2:1099,jmeter-slave3:1099 \
  --report
```

#### Test Types Explained

| Test Type | Users | Duration | Purpose | JVM Memory |
|-----------|-------|----------|---------|------------|
| **load** | 10 | 5 loops | Baseline performance | 2GB |
| **stress** | 100 | 10 loops | Find breaking point | 3GB |
| **spike** | 200 | 3 loops | Sudden traffic surge | 3GB |
| **soak** | 50 | 200 loops | Memory leak detection | 3GB |
| **stability** | varies | varies | General stability | 2GB |
| **enterprise** | 500 | 30 min | Backend API load test | 4GB |
| **ui** | 300 | 30 min | Frontend browser simulation | 6GB |

#### Script Help

```bash
# Show comprehensive help with all options
./scripts/run-test.sh --help
```

#### Generate HTML Reports

Reports are automatically generated when you use the `--report` flag. They will:
- Auto-open in your default browser
- Be saved to `reports/` directory with timestamp
- Include comprehensive performance metrics and graphs

```bash
# Basic test with report
./scripts/run-test.sh load --report

# Enterprise test with report
./scripts/run-test.sh enterprise production --report

# Reports location
open reports/loadtest-*/index.html
open reports/enterpriseloadtest-*/index.html
```

---

## Test Scenarios Deep Dive

### Load Test
**Configuration:** 10 threads, 10s ramp-up, 5 loops  
**Duration:** ~1 minute  
**Purpose:** Baseline performance under normal conditions  
**Validates:**
- Average response times
- Basic functionality under light load
- System health checks

**When to use:** Daily smoke tests, CI/CD integration, baseline metrics

---

### Stress Test
**Configuration:** 100 threads, 60s ramp-up, 10 loops  
**Duration:** ~5-10 minutes  
**Purpose:** Identify system breaking point  
**Validates:**
- Maximum capacity
- Error rates at high load
- Resource exhaustion points
- Recovery behavior

**When to use:** Capacity planning, infrastructure sizing, pre-release validation

---

### Spike Test
**Configuration:** 200 threads, 10s ramp-up, 3 loops  
**Duration:** ~2 minutes  
**Purpose:** Sudden traffic surge handling  
**Validates:**
- Auto-scaling effectiveness
- Circuit breaker behavior
- Rate limiting
- System recovery from sudden load

**When to use:** Flash sales preparation, product launches, viral event simulation

**Key Point:** Rapid ramp-up simulates real-world traffic spikes

---

### Soak Test
**Configuration:** 50 threads, 60s ramp-up, 200 loops  
**Duration:** ~30-60 minutes  
**Purpose:** Detect memory leaks and degradation  
**Validates:**
- Memory consumption over time
- Connection pool leaks
- Database connection stability
- Performance degradation

**When to use:** Production readiness, long-term stability verification, pre-deployment

**Warning:** Long execution time - plan accordingly

---

### Stability Test
**Configuration:** 25 threads, 30s ramp-up, 100 loops  
**Duration:** ~15-30 minutes  
**Purpose:** Extended reliability under moderate load  
**Validates:**
- Consistent performance
- Resource management
- Error-free execution
- Think time simulation (2-5s)

**When to use:** Weekly regression tests, continuous performance testing

---

## Output Files

After running tests, you'll find:

- **Results:** `results/[testname]-[timestamp].jtl`
- **Reports:** `reports/[testname]-[timestamp]/index.html`
- **Logs:** `logs/jmeter-[testname]-[timestamp].log`

To view HTML report:
```bash
open reports/loadtest-[timestamp]/index.html
```

---

**JMeter Version:** 5.6.3

