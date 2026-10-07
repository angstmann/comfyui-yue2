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

COPY patches/0001-yue2-lora-support.patch /tmp/yue2-lora-support.patch

RUN set -eux; \
    mkdir -p "$COMFYUI_PATH/custom_nodes"; \
    cd "$COMFYUI_PATH/custom_nodes"; \
    rm -rf ComfyUI-YuE2; \
    git clone https://github.com/nvmax/ComfyUI-YuE2.git; \
    cd ComfyUI-YuE2; \
    git checkout 3081a5ea74d6cfcf5a2cb21e62c2d6e06f37fef6; \
    git apply /tmp/yue2-lora-support.patch; \
    rm /tmp/yue2-lora-support.patch; \
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
# -------------------------------------------------------
# TRBDR Porch LoRA
# -------------------------------------------------------

RUN set -eux; \
    mkdir -p "$COMFYUI_PATH/models/yue2/loras"; \
    wget -O "$COMFYUI_PATH/models/yue2/loras/trbdr_porch.safetensors" \
      "https://huggingface.co/becausereasons/yue2-trbdr-folk-troubadour/resolve/main/trbdr_porch.safetensors"; \
    echo "a6a9cdbb980ded2f05d08ccb23b35ef1ef949a1e8da900683816020eaeb41832  $COMFYUI_PATH/models/yue2/loras/trbdr_porch.safetensors" \
      | sha256sum -c -

# -------------------------------------------------------
# Install official ComfyUI YuE2 workflows
# -------------------------------------------------------

RUN set -eux; \
    mkdir -p "$COMFYUI_PATH/user/default/workflows/YuE2"; \
    git clone --depth=1 https://github.com/Comfy-Org/workflow_templates.git /tmp/workflow_templates; \
    find /tmp/workflow_templates/templates \
      -maxdepth 1 \
      -type f \
      -iname 'audio_yue2_*.json' \
      -exec cp {} "$COMFYUI_PATH/user/default/workflows/YuE2/" \; ; \
    echo "Installed YuE2 workflows:"; \
    ls -lh "$COMFYUI_PATH/user/default/workflows/YuE2/"; \
    rm -rf /tmp/workflow_templates
      
