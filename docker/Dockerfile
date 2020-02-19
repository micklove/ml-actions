FROM ubuntu:latest

## See Gitbhub actions ubuntu image tools at
# https://help.github.com/en/actions/automating-your-workflow-with-github-actions/software-installed-on-github-hosted-runners#ubuntu-1804-lts

# setup ENV, for sam
ENV PATH="/root/.local/bin:${PATH}"
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install dependencies
# See https://stackoverflow.com/a/36611580/178808
# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common

#RUN add-apt-repository universe
RUN apt-get update && apt-get install -y \
    curl \
    git \
    make \
    jq \
    python3.4 \
    python3-pip \
    unzip \
    wget

# Version of node in apt is old, use a later one
# See https://github.com/nodesource/distributions/blob/master/README.md
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
    apt-get install -y nodejs

# Linters
RUN pip3 install cfn-lint && \
    pip3 install cfn-flip && \
    pip3 install yamllint && \
    cfn-lint --version && \
    cfn-flip --version && \
    yamllint --version

# TODO - fails at the moment
#RUN npm i jsonlint -g && \
#    jsonlint --version

RUN curl -O "https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz" && \
    tar -xvf shellcheck-stable.linux.x86_64.tar.xz && \
    mv shellcheck-stable/shellcheck /usr/bin/ && \
    shellcheck --version

# python based tools, awscli, sam, etc...
RUN  	pip3 install wheel --upgrade && \
    	pip3 install setuptools --upgrade && \
    	pip3 install aws-sam-cli --upgrade && \
    	sam --version

# See https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
RUN curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    aws --version

# saml2aws
RUN CURRENT_VERSION=2.22.0 && \
    wget https://github.com/Versent/saml2aws/releases/download/v${CURRENT_VERSION}/saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz && \
    mkdir -p ~/.local/bin && \
    tar -xzvf saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz -C ~/.local/bin && \
    rm saml2aws_${CURRENT_VERSION}_linux_amd64.tar.gz && \
    chmod u+x ~/.local/bin/saml2aws && \
    saml2aws --version

# Docker
RUN apt-get remove -y docker docker-engine docker.io && \
    apt install -y docker.io && \
    docker --version


WORKDIR /target
