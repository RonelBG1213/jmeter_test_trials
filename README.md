# JMeter Performance Testing Project

Performance and load testing suite for the **Parabank** application using Apache JMeter.

---

## Project Structure

```
JmeterTest/
├── test-plans/          # JMeter test plan files (.jmx)
│   ├── LoadTest.jmx     # Load test for Parabank homepage (10 threads)
│   ├── StressTest.jmx   # Stress test configuration (100 threads)
│   └── StabilityTest.jmx # Stability test (25 threads, long duration)
├── results/             # Test execution results (.jtl)
├── reports/             # HTML performance test reports
├── logs/                # JMeter log files
├── data/                # Test data files (CSV, JSON, etc.)
├── scripts/             # Helper scripts for test automation
└── README.md            # Project documentation
```

### Directory Descriptions

| Directory | Purpose |
|-----------|---------|
| **test-plans/** | Contains all JMeter test plan files (.jmx). Each test plan is configured for specific testing scenarios. |
| **results/** | Stores raw test results in .jtl format generated during test execution. |
| **reports/** | Contains HTML dashboard reports generated from test results for analysis and sharing. |
| **logs/** | Stores JMeter log files for debugging and tracking test execution details. |
| **data/** | Houses external data files (CSV, JSON) used for parameterizing tests (e.g., user credentials, test data). |
| **scripts/** | Contains utility scripts for test execution automation, CI/CD integration, or data preparation. |

---

## How to Use Scripts

### Run Tests Using Automation Script

Navigate to project root and use the run-test.sh script:

#### Available Test Options

```bash
# Run load test (10 users, 5 loops)
./scripts/run-test.sh load

# Run stress test (100 users, 10 loops)
./scripts/run-test.sh stress

# Run stability test (25 users, 100 loops)
./scripts/run-test.sh stability

# Run all tests
./scripts/run-test.sh all
```

#### Generate HTML Reports

Add `--report` flag to generate HTML dashboard:

```bash
# Run load test with report
./scripts/run-test.sh load --report

# Run stress test with report
./scripts/run-test.sh stress --report

# Run stability test with report
./scripts/run-test.sh stability --report

# Run all tests with reports
./scripts/run-test.sh all --report
```

#### Script Help

```bash
./scripts/run-test.sh --help
```

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

