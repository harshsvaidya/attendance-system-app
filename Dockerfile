# Use an official NVIDIA L4T base image that matches your Jetson's JetPack version
# Example: r32.7.1 is for JetPack 4.6.1. Find your version with `cat /etc/nv_tegra_release`
FROM nvcr.io/nvidia/l4t-base:r32.7.1

# Set the working directory
WORKDIR /app

# Install system dependencies, including python3 and pip
RUN apt-get update && apt-get install -y \
    build-essential \
    python3.8 \
    python3.8-dev \
    python3-pip \
    libglib2.0-0 libsm6 libxrender1 libxext6 \
    && rm -rf /var/lib/apt/lists/*

# --- CRITICAL STEP: Install the correct ONNX Runtime for Jetson GPU ---
# Find the correct wheel URL from NVIDIA for your JetPack and Python version.
# This example is for JetPack 4.6.1 (L4T r32.7.1) and Python 3.8.
# See: https://developer.nvidia.com/embedded/downloads
RUN pip3 install --no-cache-dir \
    https://developer.download.nvidia.com/compute/redist/onnxruntime/v1.10.0/jetson/onnxruntime_gpu-1.10.0-cp38-cp38-linux_aarch64.whl

# Install Python dependencies
# Note: Using pip3 now. insightface will use the pre-installed onnxruntime-gpu.
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the application code and .env file
COPY . /app
COPY .env /app/.env

# Create a non-root user and switch to it
# Note: Using /bin/bash for a shell, and giving ownership of the app directory
RUN useradd -ms /bin/bash appuser && chown -R appuser:appuser /app
USER appuser

# Expose the default Streamlit port
EXPOSE 8501

# Define the command to run the Streamlit app
CMD ["streamlit", "run", "Home.py", "--server.port=8501", "--server.address=0.0.0.0"]
