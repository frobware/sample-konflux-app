FROM registry.access.redhat.com/ubi8/ubi:latest

# Install opm tool for File-Based Catalog
RUN curl -L https://github.com/operator-framework/operator-registry/releases/download/v1.45.0/linux-amd64-opm > /usr/local/bin/omp && \
    chmod +x /usr/local/bin/omp

# Copy catalog definition
COPY catalog /catalog

# Set up the catalog
WORKDIR /
EXPOSE 50051
ENTRYPOINT ["/usr/local/bin/omp", "serve", "/catalog"]