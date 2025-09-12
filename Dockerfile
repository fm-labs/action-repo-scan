FROM python:3.13-alpine3.22

ARG TARGETARCH

# Install necessary packages
RUN apk add --no-cache \
    bash \
    curl \
    && rm -rf /var/cache/apk/*


# Install astral uv
RUN pip install --no-cache-dir --upgrade uv pip

# Install trivy
#RUN curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.66.0
RUN curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /opt/trivy -d v0.66.0
RUN ln -s /opt/trivy/trivy /usr/local/bin/trivy

# Create a non-root user
RUN addgroup -S appuser &&  \
    adduser -S appuser -G appuser

# Set the working directory
WORKDIR /app

# Install application
COPY ./reposcan ./reposcan
COPY ./poetry.lock ./pyproject.toml ./scan.py /app/
RUN uv sync --no-cache-dir

# Create the custom script that the action will execute
#RUN mkdir -p /usr/local/bin
#COPY script.sh /usr/local/bin/script.sh
#RUN chmod +x /usr/local/bin/script.sh

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

USER appuser
