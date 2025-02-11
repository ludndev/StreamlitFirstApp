# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

COPY app /app

SHELL ["/bin/bash", "-c"]

# Set environment variable to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists
RUN apt-get update

# Install build essentials and development libraries
RUN apt-get install -y \
  wget \
  build-essential \
  software-properties-common \
  libreadline-dev \
  gfortran \
  tcl-dev \
  tk-dev \
  uuid-dev \
  lzma-dev \
  liblzma-dev \
  libssl-dev \
  libsqlite3-dev \
  xorg \
  openbox \
  libx11-dev \
  libxext-dev \
  libxft-dev \
  libxrender-dev \
  bzip2 \
  libbz2-dev \
  libcurl4-openssl-dev \
  python3 \
  python3-pip \
  python3.10-venv \
  texinfo \
  texlive \
  texlive-fonts-extra

RUN apt-get install -y libtool autoconf automake

# Add Ondřej's PHP repository
RUN add-apt-repository ppa:ondrej/php

# Update package lists again and install PCRE libraries
RUN apt-get update && apt-get install -y libpcre3 libpcre3-dev

# Download, compile, and install PCRE2
RUN \
  wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz && \
  tar -zxvf pcre2-10.42.tar.gz && \
  cd pcre2-10.42 && \
  ./configure && \
  make -j $(nproc) && \
  make install && \
  cd ..

# Download, compile, and install R (without X support)
RUN \
  wget --timestamping https://cran.r-project.org/src/base/R-4/R-4.4.1.tar.gz && \
  tar zxf R-4.4.1.tar.gz && \
  cd R-4.4.1 && \
  ./configure --without-x --enable-R-shlib && \
  make -j $(nproc) && \
  make install && \
  cd ..

# Clean up temporary build directories (optional)
RUN rm -rf R-4.4.1 pcre2-10.42 R-4.4.1.tar.gz pcre2-10.42.tar.gz

# Set environment variables for R
ENV R_HOME="/usr/local/lib/R"
ENV LD_LIBRARY_PATH="/usr/local/lib/R/lib:/usr/local/lib:/usr/lib/x86_64-linux-gnu"

# Install R package RCurl from RStudio repository
RUN R -e "install.packages('RCurl', repos='https://cran.rstudio.com/')"

# Install R package randomForest from source
RUN R -e 'install.packages("https://github.com/ameudes/StreamlitFirstApp/raw/refs/heads/main/randomForest_4.7-1.1.tar.gz", repos=NULL, type="source")'

# Clone Streamlit application repository
# RUN git clone https://github.com/ameudes/StreamlitFirstApp StreamlitFirstApp

# Create a virtual environment for Python
RUN python3 -m venv .venv

# Set ownership of the virtual environment for the user
RUN chown -R ${USER}:${USER} .venv/

# Activate the virtual environment
RUN source .venv/bin/activate

# Upgrade pip
RUN pip3 install --upgrade pip

# Go in app
WORKDIR /app

# Install Python dependencies from requirements.txt
RUN pip3 install -r requirements.txt

# Expose Streamlit port (default: 8501)
EXPOSE 8501

# Run Streamlit application (entry point might differ)
CMD ["streamlit", "run", "app.py"]
