# scripts/dbt_incident_summarizer.py
#
# Runs dbt tests and generates an AI-powered incident summary
# when failures are detected. Designed for healthcare claims
# pipelines where data quality failures have direct business impact.

import subprocess
import os
import sys
import anthropic
from datetime import datetime


def run_dbt_tests():
    """Run dbt test suite and return output with failure status."""
    print("Running dbt tests...")
    print("-" * 50)

    result = subprocess.run(
        ["dbt", "test"],
        capture_output=True,
        text=True,
        cwd="."
    )

    full_output = result.stdout + result.stderr
    print(full_output)

    return full_output, result.returncode != 0


def summarize_with_claude(dbt_output):
    """Send dbt failure output to Claude and return plain-English summary."""
    client = anthropic.Anthropic()

    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=[
            {
                "role": "user",
                "content": f"""You are a Data Engineering assistant helping a QA Lead 
communicate pipeline failures to a non-technical business team.

Analyze the dbt test output below from a healthcare claims coverage 
validation pipeline and provide:

1. SUMMARY: What failed and which pipeline layer is affected
2. BUSINESS IMPACT: What this means for claims data, eligibility 
   validation, or PMPM reporting
3. RECOMMENDED ACTION: What the engineering team should investigate first

Use plain English. Assume the reader understands healthcare but not dbt.

dbt test output:
{dbt_output}"""
            }
        ]
    )

    return message.content[0].text


def log_incident(summary, dbt_output):
    """Append incident report to log file with timestamp."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    os.makedirs("logs", exist_ok=True)

    with open("logs/incident_log.txt", "a") as log_file:
        log_file.write(f"""
{'='*60}
INCIDENT REPORT — {timestamp}
{'='*60}

AI SUMMARY:
{summary}

RAW DBT OUTPUT:
{dbt_output}

""")

    print("Incident logged to logs/incident_log.txt")


def main():
    dbt_output, had_failures = run_dbt_tests()

    if not had_failures:
        print("\n✅ All dbt tests passed. Pipeline is healthy.")
        sys.exit(0)

    print("\n❌ Failures detected. Generating incident summary...")

    summary = summarize_with_claude(dbt_output)

    print("\n" + "=" * 60)
    print("AI INCIDENT SUMMARY")
    print("=" * 60)
    print(summary)
    print("=" * 60)

    log_incident(summary, dbt_output)

    sys.exit(1)


if __name__ == "__main__":
    main()