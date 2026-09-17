FROM quickpod/comfyui:minimal

USER root

ENV COMFYUI_PATH=/workspace/ComfyUI

RUN set -eux; \
    cd "$COMFYUI_PATH"; \
    git pull --ff-only || true; \
    "$COMFYUI_PATH/venv/bin/python" -m pip install -r requirements.txt; \
    mkdir -p "$COMFYUI_PATH/custom_nodes"; \
    cd "$COMFYUI_PATH/custom_nodes"; \
    git clone https://github.com/nvmax/ComfyUI-YuE2.git; \
    cd "$COMFYUI_PATH/custom_nodes/ComfyUI-YuE2"; \
    "$COMFYUI_PATH/venv/bin/python" -m pip install -r requirements.txt; \
    mkdir -p "$COMFYUI_PATH/models/checkpoints"; \
    mkdir -p "$COMFYUI_PATH/models/audio_encoders"; \
    wget -O "$COMFYUI_PATH/models/checkpoints/yue2_3b_int8_convrot.safetensors" \
      "https://huggingface.co/Comfy-Org/YuE2/resolve/main/checkpoints/yue2_3b_int8_convrot.safetensors"; \
    wget -O "$COMFYUI_PATH/models/audio_encoders/sheetsage2_bf16.safetensors" \
      "https://huggingface.co/Comfy-Org/YuE2/resolve/main/audio_encoders/sheetsage2_bf16.safetensors"

LABEL org.opencontainers.image.source="https://github.com/angstmann/comfyui-yue2"
