# GPU Thermal Anomaly Detection

Detecting overheating episodes in simulated GPU telemetry by comparing a **naive fixed-threshold alert** against a **statistical alert** built from Maximum Likelihood Estimation (MLE) and a one-sided hypothesis test — evaluated against known ground truth.

**[Read the full project report (PDF)](report/Project_Report.pdf)**

---

## Overview

GPUs continuously emit thermal telemetry, and the simplest way to monitor for overheating is a fixed threshold: alert whenever the reading crosses some absolute cutoff. That rule is easy to reason about, but it treats every reading under the cutoff as equally fine — it can't tell a slightly warm reading apart from one that's wildly outside normal operating range, as long as both sit under the line.

This project tests whether a statistically grounded alert — one that first learns the shape of "normal" GPU temperature from reference data, then flags new readings that are improbable under that model — can catch more of a thermal anomaly episode than a fixed cutoff. It uses a controlled, fully-labeled synthetic dataset so detection performance can be measured exactly.

| | |
|---|---|
| **Language** | R (base + `optim`) |
| **Data** | Simulated, 10,000 GPU temperature readings, seeded (`set.seed(3)`) for exact reproducibility |
| **Approach** | MLE-fitted Gaussian normal-operating model + one-sided upper-tail hypothesis test, vs. a fixed 90°C threshold |
| **Evaluation** | Confusion matrix (TP/FN/TN/FP), Detection Rate, False Alarm Rate, against known injected anomaly episodes |

## Key Results

| Metric | Statistical Alert | Threshold Alert |
|---|---:|---:|
| True Positives (TP) | 138 | 16 |
| False Negatives (FN) | 12 | 134 |
| True Negatives (TN) | 9,744 | 9,850 |
| False Positives (FP) | 106 | 0 |
| **Detection Rate** | **92.0%** | 10.7% |
| **False Alarm Rate** | 1.08% | **0.0%** |

The statistical alert catches **92% of true anomalies** at a small (1.08%) false-alarm cost. The fixed threshold never raises a false alarm, but only catches the extreme tip of each anomaly episode — the 16 points across all five episodes that literally cross 90°C — missing the other 134 points that are well outside normal range but still under the absolute cutoff.

![Telemetry with true anomaly episodes and fixed threshold](figs/fig1_timeseries.png)

![Detection rate and false alarm rate comparison](figs/fig5_comparison.png)

See the [full report](report/Project_Report.pdf) for the complete methodology, discussion, and limitations.

## How It Works

1. **Simulate telemetry** (`simulate_data.R`) — 9,850 "normal" readings ~ N(67°C, 1°C), plus 150 readings forming five 30-point ramp-up/ramp-down anomaly episodes (peaking ~90–93.5°C), spliced into the sequence at fixed, known positions. Saves `Data/telemetry_data.csv` (combined) and `Data/normal_data.csv` (normal-only reference sample).
2. **Fit the normal-operating distribution** (`analysis.R`) — estimate Normal(μ, σ) parameters from the reference sample via Maximum Likelihood, minimizing the negative log-likelihood with `optim()`.
3. **Score every reading** — compute a z-score against the fitted distribution and its one-sided upper-tail p-value.
4. **Flag statistical alerts** — p < α = 0.01 (significant at the 1% level).
5. **Evaluate** — compare both the statistical alert and the fixed 90°C threshold against the known anomaly-episode ground truth using a confusion matrix.

## Repository Structure

```
gpu-anomaly-detection/
├── README.md
├── simulate_data.R          # generates the synthetic telemetry + reference data
├── analysis.R                # MLE fit, hypothesis test, evaluation
├── Data/
│   ├── telemetry_data.csv    # 10,000 readings (combined normal + anomalies)
│   └── normal_data.csv       # 9,850 normal-only reference readings
├── figs/
│   ├── fig1_timeseries.png
│   ├── fig2_histogram.png
│   └── fig5_comparison.png
├── report/
│   └── Project_Report.pdf    # 4-page project report
└── LICENSE
```

## Running It Yourself

Requires R (base install only — no extra packages needed).

```r
# From the project root:
source("simulate_data.R")   # writes Data/telemetry_data.csv and Data/normal_data.csv
source("analysis.R")        # fits the model, computes both alerts, prints the comparison table
```

> **Note:** the original scripts were developed locally with absolute Windows paths (e.g. `C:\\Users\\...\\Data\\telemetry_data.csv`). Before running, replace those two lines in `analysis.R` with relative paths so the project runs on any machine:
> ```r
> df    <- read.csv("Data/telemetry_data.csv")
> x_og  <- read.csv("Data/normal_data.csv")
> ```

Everything is deterministic (`set.seed(3)`), so re-running `simulate_data.R` and `analysis.R` reproduces the exact numbers and figures in this README and the report.

## Limitations & Future Work

- Each reading is scored independently — there's no use of temporal structure (e.g. a run of consecutive mild deviations), which windowed z-scores, EWMA, or CUSUM-style methods could capture.
- Results are reported at a single significance level (α = 0.01); a full sweep would trace out the detection-rate / false-alarm-rate trade-off curve.
- The 90°C threshold is a naive baseline, not a tuned one.
- Data is synthetic and i.i.d. Gaussian; real GPU telemetry likely has load-dependent variance and workload change-points that this benchmark doesn't capture. Validating on real hardware logs, and comparing against unsupervised methods (isolation forests, autoencoder reconstruction error), is a natural next step.

## License

Released under the [MIT License](LICENSE).

## Author

**[Your Name]** — [your.email@example.com] — [linkedin.com/in/yourprofile](https://linkedin.com/in/yourprofile)
