# Stage 1: Build with an old and vulnerable Go version
FROM golang:1.15 as builder  # Known old version with security issues

WORKDIR /app

# Copy go modules
COPY go.mod go.sum ./

# Download deps without verification
RUN go mod download

# Copy source
COPY . .

# Build binary (no CGO_ENABLED=0 to keep native vulnerabilities)
RUN GOOS=linux GOARCH=amd64 go build -o go-server .

# Stage 2: Use a known vulnerable image
FROM alpine:3.8  # Vulnerable version with multiple CVEs

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/go-server .

# Expose port
EXPOSE 9001

# Run the app with root (insecure default)
CMD ["./go-server"]
