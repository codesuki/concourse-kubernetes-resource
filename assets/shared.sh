#!/bin/sh

function readSourceArguments() {
    master=$(jq -r '.source.master // empty' < $1)
    if [ -z "$master" ]; then
        echo master not set >&2
        exit 1
    fi

    namespace=$(jq -r '.source.namespace // empty' < $1)
    if [ -z "$namespace" ]; then
        echo namespace not set >&2
        exit 1
    fi

    resource_type=$(jq -r '.source.resource_type // empty' < $1)
    if [ -z "$resource_type" ]; then
        echo resource_type not set >&2
        exit 1
    fi

    resource_name=$(jq -r '.source.resource_name // empty' < $1)
    if [ -z "$resource_name" ]; then
        echo resource_name not set >&2
        exit 1
    fi

    container=$(jq -r '.source.container // empty' < $1)
    if [ -z "$container" ]; then
        echo container not set >&2
        exit 1
    fi

    insecure_skip_tls_verify=""
    skip_tls_verify=$(jq -r '.source.skip_tls_verify // empty' < $payload)
    if [ -n "$skip_tls_verify" ]; then
        insecure_skip_tls_verify="--insecure-skip-tls-verify"
    fi

    # { list; } is needed to run the functions in the current shell
    if ! { checkCerts $1 || checkBasicAuth $1; }; then
        echo neither certs nor basic authentication parameters are set. >&2
        exit 1
    fi

    if checkCerts $1 && checkBasicAuth $1; then
        echo certs and basic authentication parameters are both set. falling back to using certs. >&2
    fi
}

function checkCerts() {
    cluster_cert=$(jq -r '.source.cluster_cert // empty' < $1)
    if [ -z "$cluster_cert" ]; then
        return 1
    fi

    client_cert=$(jq -r '.source.client_cert // empty' < $1)
    if [ -z "$client_cert" ]; then
        return 1
    fi

    client_key=$(jq -r '.source.client_key // empty' < $1)
    if [ -z "$client_key" ]; then
        return 1
    fi

    return 0
}

function checkBasicAuth() {
    username=$(jq -r '.source.username // empty' < $1)
    if [ -z "$username" ]; then
        return 1
    fi

    password=$(jq -r '.source.password // empty' < $1)
    if [ -z "$password" ]; then
        return 1
    fi

    return 0
}
