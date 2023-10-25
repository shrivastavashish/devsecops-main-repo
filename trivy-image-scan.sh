# #!/bin/bash

# dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
# echo $dockerImageName

# docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.46.0 -q image --exit-code 0 --severity HIGH --light $dockerImageName
# docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.46.0 -q image --exit-code 1 --severity CRITICAL --light $dockerImageName

#     # Trivy scan result processing
#     exit_code=$?
#     echo "Exit Code : $exit_code"

#     # Check scan results
#     if [[ "${exit_code}" == 1 ]]; then
#         echo "Image scanning failed. Vulnerabilities found"
#         exit 1;
#     else
#         echo "Image scanning passed. No CRITICAL vulnerabilities found"
#     fi;

#!/bin/bash

# Check if the Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker daemon is not running. Please start Docker and try again."
    exit 1
fi

#!/bin/bash

# Check if the Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker daemon is not running. Please start Docker and try again."
    exit 1
fi

# Define the Docker image name
dockerImageName="dsocouncil/node-service:b9b977a211d98b6389b8ea752c921c6729215adc"  # Replace with the correct image name and tag

# Pull the Docker image (if not already available locally)
docker pull $dockerImageName

# Run Trivy to scan the Docker image using Docker explicitly
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.46.0 -q image --exit-code 0 --severity HIGH --light --input $dockerImageName

# Trivy scan result processing
exit_code=$?
echo "Exit Code : $exit_code"

# Check scan results
if [[ "${exit_code}" == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found"
    exit 1
else
    echo "Image scanning passed. No CRITICAL vulnerabilities found"
fi

