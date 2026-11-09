# Reachy Mini setup on Rubik Pi

Ubuntu 24.04 ARM64 setup for the Reachy Mini daemon.

## Setup

The repository already defines the Ubuntu and Python dependencies. Install the host prerequisites first, then let `uv` create the project environment from `pyproject.toml` and `uv.lock`.

```bash
./setup-ubuntu.sh
uv sync
```

## Install Rust WebRTC plugin

Reachy Mini uses GStreamer WebRTC for media streaming. On Linux ARM64, build the Rust WebRTC plugin once and install it under `/opt/gst-plugins-rs`.

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

cargo install cargo-c

git clone https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs.git
cd gst-plugins-rs
git checkout 0.14.1

sudo mkdir -p /opt/gst-plugins-rs
sudo chown "$USER" /opt/gst-plugins-rs

cargo cinstall -p gst-plugin-webrtc \
  --prefix=/opt/gst-plugins-rs \
  --release
```

Expose the ARM64 plugin directory so GStreamer can discover the plugin:

```bash
echo 'export GST_PLUGIN_PATH=/opt/gst-plugins-rs/lib/aarch64-linux-gnu:$GST_PLUGIN_PATH' >> ~/.profile
source ~/.profile
```

Verify that GStreamer can load the WebRTC sink:

```bash
gst-inspect-1.0 webrtcsink
```

## Run the daemon

The daemon exposes Reachy Mini to clients such as Reachy Mini Control. Use headless mode on the Rubik Pi because it has no display.

### Real robot, headless

Use the physical Reachy Mini connected to the Rubik Pi.

```bash
uv run reachy-mini-daemon --headless --fastapi-host 0.0.0.0
```

### Simulation, headless

Use MuJoCo without opening a graphical viewer.

```bash
uv run reachy-mini-daemon --sim --headless --fastapi-host 0.0.0.0
```

### Simulation with GUI

Requires a graphical display:

```bash
uv run reachy-mini-daemon --sim --fastapi-host 0.0.0.0
```

## systemd

Use systemd to start the real-hardware daemon automatically at boot. Create this file on the Rubik Pi as `/etc/systemd/system/reachy-mini-daemon.service`.

```bash
sudo nano /etc/systemd/system/reachy-mini-daemon.service
```

Paste:


```ini
[Unit]
Description=Reachy Mini Daemon
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/reachy_mini_daemon
Environment=GST_PLUGIN_PATH=/opt/gst-plugins-rs/lib/aarch64-linux-gnu
ExecStart=/home/ubuntu/reachy_mini_daemon/.venv/bin/reachy-mini-daemon --headless --fastapi-host 0.0.0.0
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Reload systemd, enable the service at boot, and start it now:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now reachy-mini-daemon
systemctl status reachy-mini-daemon
```

Logs:

```bash
journalctl -u reachy-mini-daemon -f
```

