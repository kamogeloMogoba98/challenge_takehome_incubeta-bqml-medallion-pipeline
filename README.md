# Incubeta Data Engineering Screening Challenge
## BQML & Medallion Data Pipeline

## Introduction

I would like to thank the Incubeta team for giving me the opportunity to complete this screening challenge. I really appreciate the chance to work through the case study and showcase my data engineering skills, technical approach and the way I think about building data solutions.

I have also taken the opportunity to go beyond the minimum requirements of the challenge and demonstrate how I would approach extending the solution towards a more production-oriented data pipeline.

## Repository Structure

The numbered folders are intentional. I used them to make the repository easy to navigate and to reflect the way the project is presented.

The numbering keeps the most important parts of the screening challenge at the top, while also clearly separating the additional engineering work I added.

- **01_sql** – Core SQL implementation required by the challenge
- **02_proof** – Proof of execution and BQML evaluation
- **03_doc** – Supporting project documentation
- **04_ingestion** – Additional Python ingestion implementation
- **05_Helper** – Reusable Python helper modules
- **06_orchestration** – Cronicle and Airflow orchestration
- **07_infrastructure** – Terraform infrastructure
- **08_ETA_ipynb** – Exploratory data analysis


### Project Overview

This project implements the Incubeta Data Engineering Screening Challenge using **Google BigQuery, BigQuery ML and a Medallion Architecture**.

The main objective was to take the provided raw retail transaction data, clean and transform it through the **Bronze → Silver → Gold** layers, and use **BigQuery ML K-means clustering** to create customer segments.

---

## Challenge Requirements

I completed the core requirements of the challenge entirely using GCP and BigQuery:

- **Bronze:** Ingested the raw transaction data into `retail_bronze.raw_transactions`.
- **Silver:** Cleaned and transformed the data into `retail_silver.cleaned_transactions`, including data type conversion, missing value handling, anomaly filtering and feature engineering.
- **Gold:** Created a BQML K-means clustering model and used the predictions to produce `retail_gold.analytics_customer_segments`.
- **Proof of Execution:** Screenshots and BQML evaluation results are available in the [`02_proof`](./02_proof) folder.

The SQL implementation required for the challenge is available in [`01_sql`](./01_sql).

---

## Additional Engineering Scope

The challenge could be completed directly within BigQuery. I chose to extend the solution to demonstrate how I would approach the pipeline in a more production-oriented environment.

This additional scope includes:

- **Python ingestion** running on a GCP VM
- **Reusable helper modules** for BigQuery and Cloud Storage
- **Cloud Storage** for raw/Parquet data
- **Terraform** for infrastructure provisioning
- **Cronicle** for scheduling the ingestion process
- **Airflow / Cloud Composer** for dependency-based orchestration

I see this as an extension of the screening solution rather than part of the minimum challenge requirements.

The distinction is intentional: **BigQuery represents the core solution requested by Incubeta, while the additional components demonstrate how I would think about operationalising and scaling the pipeline.**

---

## Architecture

```text
                         Raw CSV
                            │
                            ▼
                     GCP VM / Python
                            │
                            ▼
                    ┌───────────────┐
                    │    Bronze     │
                    │ raw data      │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │    Silver     │
                    │ cleaned data  │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   BigQuery ML │
                    │   K-means     │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │     Gold      │
                    │ segmentation  │
                    └───────────────┘
```

---

## Production-Oriented Orchestration

For a simple production setup, I would run the Python ingestion script on the VM using **Cronicle**, scheduled for 06:00 SAST, followed by BigQuery Scheduled Queries for the Silver transformation at 07:00 and Gold transformation at 07:30.

This is lightweight and cost-effective, but the jobs are not task-dependent. For a more mature production environment, I would use **Cloud Composer/Airflow** to orchestrate the pipeline, allowing task dependencies, retries, backfilling, monitoring and centralised logging.

The orchestration implementation is available in [`05_orchestration`](./05_orchestration).

### Cronicle Access

The Cronicle scheduling environment used for the ingestion process is also available for review via HTTPS. The access link is provided through the GitHub repository so the Incubeta team can view the scheduled ingestion jobs and their execution history.

**[Access Cronicle via HTTPS](http://34.148.179.127/#Schedule)**

The password and username is admin 

---

## Project Documentation

I have also included two supporting project write-ups that go deeper into the implementation and the business use case.

### How I Completed This Project

This document explains my implementation from the initial GCP setup and Terraform infrastructure through to ingestion, transformation, BQML, orchestration and the design decisions I made along the way.

**[Read: How I Completed This Project](YOUR_GOOGLE_SHEET_LINK_HERE)**

### Case Study: Implementing the Customer Segmentation Model

This document takes the segmentation model beyond the technical implementation and looks at how the customer segments could be used for **lifecycle messaging and targeted marketing**.

It explores how customer behaviour and product preferences could be used to target customers with more relevant content, measure campaign engagement and ultimately connect the data engineering pipeline back to marketing outcomes.

**[Read: Implementing the Case Study on the Segmentation Model](YOUR_GOOGLE_SHEET_LINK_HERE)**

---

## Repository Structure

```text
incubeta-data-engineering-challenge/
│
├── README.md
│
├── 01_sql/
│   ├── silver_transform.sql
│   ├── gold_model_training.sql
│   └── gold_prediction.sql
│
├── 02_proof/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   └── model_evaluation/
│
├── 03_ingestion/
│   └── ingest_transactions.py
│
├── 04_helpers/
│   ├── bigquery.py
│   ├── gcs.py
│   └── logger.py
│
├── 05_orchestration/
│   ├── airflow/
│   └── cronicle/
│
├── 06_infrastructure/
│   └── terraform/
│
└── 07_docs/
    ├── design_decisions.md
    └── ai_usage.md
```

---

## AI Usage

AI tools were used as an engineering assistant during the project to help with research, troubleshooting, architecture discussions and documentation.

I remained responsible for the implementation, testing and validation of the solution and used AI as a supporting tool rather than relying on it to complete the project independently.

---

## Technologies

**Google Cloud:** BigQuery, BigQuery ML, Compute Engine, Cloud Storage, Cloud Composer

**Development:** Python, SQL, Terraform

**Orchestration:** Cronicle, Airflow

**Architecture:** Medallion Architecture
