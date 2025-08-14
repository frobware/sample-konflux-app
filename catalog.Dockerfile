FROM quay.io/operator-framework/opm:latest

# Default to alpha stream, can be overridden at build time
ARG BUILD_STREAM=alpha

# Copy templates and bundle reference
COPY catalog/templates/ /tmp/templates/
COPY konflux/image-refs/bundle.txt /tmp/bundle.txt

# Generate catalog autonomously - read bundle reference and update template
RUN BUNDLE_IMAGE=$(cat /tmp/bundle.txt | tr -d '\n') && \
    sed "s|image:.*todoapp-bundle.*|image: $BUNDLE_IMAGE|g" /tmp/templates/${BUILD_STREAM}.yaml > /tmp/template-updated.yaml && \
    /bin/opm alpha render-template basic --migrate-level=bundle-object-to-csv-metadata -o yaml /tmp/template-updated.yaml > /configs/index.yaml

# Configure the entrypoint and command
ENTRYPOINT ["/bin/opm"]
CMD ["serve", "/configs", "--cache-dir=/tmp/cache"]

# Pre-build cache (like netobserv does)
RUN ["/bin/opm", "serve", "/configs", "--cache-dir=/tmp/cache", "--cache-only"]

# Set FBC-specific label for the location of the FBC root directory
LABEL operators.operatorframework.io.index.configs.v1=/configs
