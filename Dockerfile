FROM quickpod/comfyui:minimal

USER root

ENV COMFYUI_PATH=/workspace/ComfyUI

# -------------------------------------------------------
# Update the QuickPod base image's old ComfyUI checkout
# to current ComfyUI master.
# YuE2 native support was added in September 2026.
# -------------------------------------------------------

RUN set -eux; \
    cd "$COMFYUI_PATH"; \
    git remote set-url origin https://github.com/Comfy-Org/ComfyUI.git; \
    git fetch --depth=1 origin master; \
    git reset --hard FETCH_HEAD; \
    "$COMFYUI_PATH/venv/bin/python" -m pip install --upgrade pip; \
    "$COMFYUI_PATH/venv/bin/python" -m pip install -r requirements.txt

# -------------------------------------------------------
# Install ComfyUI-YuE2
# -------------------------------------------------------

RUN set -eux; \
    mkdir -p "$COMFYUI_PATH/custom_nodes"; \
    cd "$COMFYUI_PATH/custom_nodes"; \
    rm -rf ComfyUI-YuE2; \
    git clone --depth=1 https://github.com/nvmax/ComfyUI-YuE2.git; \
    cd ComfyUI-YuE2; \
    "$COMFYUI_PATH/venv/bin/python" -m pip install -r requirements.txt

# -------------------------------------------------------
# YuE2 models
# -------------------------------------------------------

RUN set -eux; \
    mkdir -p "$COMFYUI_PATH/models/checkpoints"; \
    mkdir -p "$COMFYUI_PATH/models/audio_encoders"; \
    wget -O "$COMFYUI_PATH/models/checkpoints/yue2_3b_int8_convrot.safetensors" \
      "https://huggingface.co/Comfy-Org/YuE2/resolve/main/checkpoints/yue2_3b_int8_convrot.safetensors"; \
    wget -O "$COMFYUI_PATH/models/audio_encoders/sheetsage2_bf16.safetensors" \
      "https://huggingface.co/Comfy-Org/YuE2/resolve/main/audio_encoders/sheetsage2_bf16.safetensors"
