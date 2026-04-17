#!/usr/bin/env bash
# Перевірка, що на EC2 IAM Role бачить S3 (AWS CLI: sudo apt install awscli -y).
set -euo pipefail
BUCKET="${S3_BUCKET_NAME:?export S3_BUCKET_NAME}"
REGION="${AWS_REGION:-eu-central-1}"
TEST_KEY="lab7-smoke-test.txt"
echo "lab7 $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "/tmp/$TEST_KEY"
aws s3 cp "/tmp/$TEST_KEY" "s3://$BUCKET/$TEST_KEY" --region "$REGION"
aws s3 ls "s3://$BUCKET/" --region "$REGION"
echo "OK: об'єкт завантажено. Видали тестовий файл у консолі S3 за потреби."
