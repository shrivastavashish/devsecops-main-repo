#!/bin/bash


echo $imageName 
#ImageName=openjdk:22

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.46.0 -q image --exit-code 0 --severity HIGH --light $imageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.46.0 -q image --exit-code 0 --severity CRITICAL --light $imageName

    # Trivy scan result processing
    exit_code=$?
    echo "Exit Code : $exit_code"

    # Check scan results
    if [[ ${exit_code} == 1 ]]; then
        echo "Image scanning failed. Vulnerabilities found"
        exit 1;
    else
        echo "Image scanning passed. No vulnerabilities found"
    fi;