# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Set environment variables for R installation
ENV R_VERSION=4.4.1
ENV R_PAPERSIZE=letter

# Add the docker user and create a home directory
RUN useradd -m docker && usermod -aG staff docker

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    make \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    unzip \
    wget \
    zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip3 install --upgrade pip

# Set the working directory
WORKDIR /root/local/src

# Download and install R using the specified version from ENV
RUN wget --timestamping https://cran.r-project.org/src/base/R-4/R-4.4.1.tar.gz && \
    tar zxf R-4.4.1.tar.gz && \
    cd R-4.4.1 && \
    ./configure --prefix=/root/local/4.4.1 && \
    make && \
    make install

# Set the installed R binary in the PATH
ENV PATH="/root/local/${R_VERSION}/bin:${PATH}"

# Install the specific version of the randomForest package
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/randomForest/randomForest_4.7-1.1.tar.gz', repos=NULL, type='source')"

# Set the working directory for the Streamlit app
WORKDIR /app

# Copy the application code
COPY ./app .

# Install Python dependencies
RUN pip install -r requirements.txt

# Expose the port Streamlit will run on
EXPOSE 8501

# Run the Streamlit app
CMD ["streamlit", "run", "app.py"]
