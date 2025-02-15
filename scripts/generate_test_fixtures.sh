#!/bin/bash

# Exit on any error
set -e

# Prevent MSYS from converting paths on Windows
if [[ "$OSTYPE" == "msys"* ]]; then
    export MSYS_NO_PATHCONV=1
fi

echo "Creating test fixtures..."

# Create test/fixtures directory if it doesn't exist
mkdir -p test/fixtures

# Check for OpenSSL
if ! command -v openssl >/dev/null 2>&1; then
    echo "Error: OpenSSL is required but not found"
    exit 1
fi

echo "Generating certificates..."

# Generate password-protected private key (password is "password")
openssl genrsa -des3 -passout pass:password -out test/fixtures/key.pem 2048

# Generate self-signed certificate
openssl req -x509 -new -nodes \
  -key test/fixtures/key.pem \
  -passin pass:password \
  -sha256 -days 365 \
  -out test/fixtures/cert.pem \
  -subj "/C=US/ST=State/L=City/O=Org/CN=Test"

# Generate WWDR certificate (self-signed for testing)
openssl req -x509 -new -nodes \
  -keyout test/fixtures/wwdr_key.pem \
  -out test/fixtures/wwdr.pem \
  -days 365 \
  -subj "/C=US/O=Apple Inc/OU=Apple Worldwide Developer Relations/CN=Apple Worldwide Developer Relations Certification Authority"

echo "Generating test icon..."

# Create a test icon (platform-independent)
if command -v magick >/dev/null 2>&1; then
    magick -size 48x48 xc:white -gravity center -pointsize 12 -annotate 0 "Icon" PNG32:test/fixtures/icon.png
elif command -v convert >/dev/null 2>&1; then
    convert -size 48x48 xc:white -gravity center -pointsize 12 -annotate 0 "Icon" PNG32:test/fixtures/icon.png
else
    echo "ImageMagick not found. Creating an empty icon file."
    if [[ "$OSTYPE" == "msys"* ]]; then
        # Windows
        fsutil file createnew test/fixtures/icon.png 1024
    else
        # Unix-like systems
        dd if=/dev/zero of=test/fixtures/icon.png bs=1024 count=1
    fi
fi

# Set permissions (skip on Windows)
if [[ "$OSTYPE" != "msys"* ]] && [[ "$OSTYPE" != "cygwin"* ]]; then
    chmod 644 test/fixtures/*.pem test/fixtures/icon.png
fi

echo "Test fixtures created successfully" 