# FRNServer — Brazil-FRN Server Setup

> **AlterFRN Server & Client** — Files, configuration and reference guide for running a [Free Radio Network (FRN)](https://freeradionetwork.eu) server on Linux.
>
> Maintained by **PP5PK — Daniel K** | Mafra, SC, Brazil | [pp5pk.net](https://pp5pk.net) | [dvbr.net](https://dvbr.net)

---

## Table of Contents

- [About](#about)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Server Installation](#server-installation)
  - [1. Choose your platform](#1-choose-your-platform)
  - [2. Download and extract](#2-download-and-extract)
  - [3. Rename the binary](#3-rename-the-binary)
  - [4. Copy configuration files](#4-copy-configuration-files)
  - [5. Install and enable the service](#5-install-and-enable-the-service)
  - [6. Verify](#6-verify)
- [Configuration](#configuration)
  - [server.ini](#serverini)
  - [networks.cfg](#networkscfg)
- [Room Welcome Messages](#room-welcome-messages)
- [Client Installation (Bot)](#client-installation-bot)
- [Command Reference](#command-reference)
  - [Server Control](#server-control)
  - [Client Listing](#client-listing)
  - [Client Moderation](#client-moderation)
  - [Room Administration](#room-administration)
  - [Access Rights](#access-rights)
  - [Manager Password Management](#manager-password-management)
  - [Database Reload](#database-reload-without-restart)
- [Database Files Reference](#database-files-reference)
- [FRN System Managers](#frn-system-managers)
- [License](#license)

---

## About

This repository contains everything needed to deploy and manage an AlterFRN server — the alternative implementation of the FRN protocol, compatible with all standard FRN clients (gCLNT, FRNClientConsole, GRN, frn4pi, PiCQ and others).

The AlterFRN server supports up to three simultaneous FRN System Manager connections and can operate in multiple modes per room: `Standalone`, `Notify`, `Light` or `FRN`.

- **AlterFRN project:** http://alterfrn.ucoz.ru
- **Original FRN:** https://freeradionetwork.eu
- **FRN System DE (primary):** https://freeradionetwork.de
- **Protocol documentation:** https://freeradionetwork.eu/frnprotocol.htm

---

## Repository Structure

```
FRNServer/
├── Server/                        # Server binaries (two latest revisions)
│   ├── FRNServerConsole.Linux-amd64.7348r.tgz       # Linux x86_64
│   ├── FRNServerConsole.Linux-aarch64.7348r.tgz     # Linux ARM64
│   ├── FRNServerConsole.Linux-armhf.7348r.tgz       # Linux ARMv6 32bit
│   ├── FRNServerConsole.Linux-armv7.7348r.tgz       # Linux ARMv7 32bit
│   ├── FRNServerConsole.FreeBSD-amd64.7348r.tgz     # FreeBSD x86_64
│   ├── FRNServerConsole.Win32.7348r.zip             # Windows 32bit
│   ├── FRNServerConsole.Linux-aarch64.6584r.tgz     # r6584 ARM64
│   └── FRNServerConsole.Linux-armhf.6584r.tgz       # r6584 ARMv6
├── Client/                        # Client binaries
│   ├── FRNClientConsole.Linux-aarch64.7312r.tgz     # Linux ARM64
│   ├── FRNClientConsole.Linux-armhf.7312r.tgz       # Linux ARMv6
│   └── FRNClientConsole.Linux-armv7.7312r.tgz       # Linux ARMv7
├── frn.service                    # systemd service unit
├── server.ini                     # Server configuration file
├── networks.cfg                   # Rooms configuration file
├── LICENSE
└── README.md
```

---

## Prerequisites

- Linux (amd64, aarch64, armhf or armv7), FreeBSD or Windows
- `systemd` (for service management on Linux)
- Network connectivity with TCP ports **10024**, **20010** and **10025** open
- A registered FRN account at [freeradionetwork.de](https://freeradionetwork.de)

> **All FRN communication uses TCP only** — no UDP required at any point, including audio.

**TCP Ports:**

| Port  | Purpose |
|-------|---------|
| 10024 | FRN client connections (default) |
| 20010 | FRN client connections (alternate, for clients behind firewalls) |
| 10025 | FRN System Manager (sysman) |
| 10023 | Command channel (localhost only) |

---

## Server Installation

### 1. Choose your platform

| Platform | Architecture | File |
|----------|-------------|------|
| Linux x86_64 (VPS, PC) | amd64 | `FRNServerConsole.Linux-amd64.7348r.tgz` |
| Linux ARM 64bit (RPi 4/5, OrangePi, NanoPi NEO2) | aarch64 | `FRNServerConsole.Linux-aarch64.7348r.tgz` |
| Linux ARM 32bit v6 (RPi Zero, RPi 1) | armhf | `FRNServerConsole.Linux-armhf.7348r.tgz` |
| Linux ARM 32bit v7 (RPi 2/3) | armv7 | `FRNServerConsole.Linux-armv7.7348r.tgz` |
| FreeBSD x86_64 | amd64 | `FRNServerConsole.FreeBSD-amd64.7348r.tgz` |
| Windows | win32 | `FRNServerConsole.Win32.7348r.zip` |

### 2. Download and extract

Replace `<filename>` with the appropriate file for your platform:

```bash
cd /usr/src/
wget https://github.com/PP5PK/FRNServer/raw/main/Server/<filename>.tgz
tar -zxvf <filename>.tgz
rm <filename>.tgz
```

Example for Linux amd64:

```bash
cd /usr/src/
wget https://github.com/PP5PK/FRNServer/raw/main/Server/FRNServerConsole.Linux-amd64.7348r.tgz
tar -zxvf FRNServerConsole.Linux-amd64.7348r.tgz
rm FRNServerConsole.Linux-amd64.7348r.tgz
```

### 3. Rename the binary

```bash
mv FRNServerConsole.Linux-amd64.7348r FRNServer
cd FRNServer
mv FRNServerConsole.Linux-amd64.r7348 FRNServer
chmod +x FRNServer
```

> Adapt the filenames to match your downloaded version and platform.

### 4. Copy configuration files

```bash
wget https://github.com/PP5PK/FRNServer/raw/main/server.ini
wget https://github.com/PP5PK/FRNServer/raw/main/networks.cfg
```

Edit `server.ini` and set at minimum:

```ini
PresentServerAddress=your.domain.or.ip
ServerOwnerEMail=your@email.com
ManagerAuthEMail=your@email.com
ManagerAuthPassword=YOURPASSWORD
```

### 5. Install and enable the service

```bash
wget https://github.com/PP5PK/FRNServer/raw/main/frn.service
cp frn.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now frn.service
```

The `frn.service` uses `Type=simple` with the `run` command, which is the correct mode for systemd:

```ini
ExecStart=/usr/src/FRNServer/FRNServer run /usr/src/FRNServer/server.ini
```

> **Note:** Do not use `daemon` in `ExecStart` — it performs a double-fork that causes systemd to lose track of the process.

### 6. Verify

```bash
systemctl status frn.service
journalctl -u frn.service -f
```

A successful start shows:

```
INFO: FRN-System-Manager[0]: sysman.freeradionetwork.de:10025
Start listening: Client: 0.0.0.0:10024
Start listening: Client: 0.0.0.0:20010
Manager[0]: Operating
```

---

## Configuration

### server.ini

Key parameters:

```ini
[Server]
PresentServerAddress=your.domain.or.ip   # Public address announced to clients
PresentServerPort=10024
BackupServerAddress=your.backup.address  # Fallback address sent to clients
BackupServerPort=10024
ServerOwnerEMail=your@email.com
DefaultNetworkName=Brazil                # Default room on connect
DefaultCountry=Brazil
ListenServerPorts=10024 20010            # Ports to listen on
IPVersion=4                              # 4, 6 or 46
ManagerMode=FRN                          # Server-wide manager mode

[Manager]
ManagerEnabled=yes
ManagerAddress=sysman.freeradionetwork.de
ManagerPort=10025
ManagerAuthEMail=your@email.com
ManagerAuthPassword=YOURPASSWORD
ManagerReconnectInterval=60

[Command]
CommandEnabled=yes                       # Required for runtime commands
CommandPort=10023
CommandIPVersion=4

[System]
LogFile=/var/log/frnserver.log
DataDir=/usr/src/FRNServer/
```

> **Important:** Connect only to **one** of the two FRN System Managers (`.de` or `.eu`). Since August 2024, `freeradionetwork.eu` redirects to `freeradionetwork.de` — they are equivalent. Connecting to both simultaneously is considered redundant and may result in your server being blocked.

### networks.cfg

Each line defines a room. Format:

```
RoomName | option1=value; option2=value; option3=value
```

Lines starting with `#` are comments. Room names must be in UTF-8.

---

#### Complete parameter reference

**n.1 — `Hidden`**
Controls whether the room appears in the public room list sent to clients.
Values: `yes` / `no` (default: `no`)

```
Brazil | Hidden=no
Whrebe | Hidden=yes
```

---

**n.2 — `OwnerEMail`**
E-mail of the room owner. A client connecting with this e-mail and the correct password receives room owner privileges (`AL=OWNER` in the handshake). If omitted, the server's `ServerOwnerEMail` applies.

```
Brazil | OwnerEMail=your@email.com
```

---

**n.3 — `MaxSpeechTime`**
Maximum duration of a single transmission in seconds for this room. Overrides the server-wide `MaxSpeechTime` from `server.ini`.
Min: 10s — Max: 1800s (30 min) — Default: uses server-wide value (300s)

```
Papagaio | MaxSpeechTime=60
```

---

**n.4 — `ManagerMode`**
Authentication mode with the FRN System Manager for this specific room. Overrides the server-wide `ManagerMode`.

| Value | Description |
|-------|-------------|
| `Standalone` or `S` | No interaction with manager. Fully autonomous. |
| `Notify` or `N` | Server notifies manager of connecting clients, but negative responses are ignored. |
| `Light` or `L` | If manager is unavailable, client is allowed in. When manager recovers, client is checked and may be kicked. |
| `FRN` or `F` | If manager is unavailable, no clients are allowed. If available, client is checked against manager response. |

```
FRN    | ManagerMode=F
Brazil | ManagerMode=FRN
Teste  | ManagerMode=Standalone
```

---

**n.5 — `ParrotEnable`**
Enables parrot (echo/repeater) mode for the room. Audio received is played back to all connected clients.
Values: `yes` / `no` (default: `no`)

```
Papagaio | ParrotEnable=yes
```

---

**n.6 — `ParrotStartStopEnable`**
Allows users to activate and deactivate parrot mode by sending the text commands `start` and `stop` in the room.
Values: `yes` / `no` (default: `no`)
Requires: `ParrotEnable=yes`

```
Papagaio | ParrotEnable=yes; ParrotStartStopEnable=yes
```

---

**n.7 — `ParrotMaxRecordTime`**
Maximum recording time in seconds for each parrot cycle.
Default: uses server-wide `MaxSpeechTime`

```
Papagaio | ParrotMaxRecordTime=30
```

---

**n.8 — `ParrotRepeatCount`**
Number of times the parrot replays the recorded audio before accepting new input.
Default: `1`

```
Papagaio_5x | ParrotRepeatCount=5
```

---

**n.9 — `MaxClients`**
Maximum number of clients simultaneously connected to this room.
Default: no limit

```
Brazil | MaxClients=20
```

---

**n.10 — `CharsetName`**
ANSI charset name for this specific room, used when sending the room name to legacy clients that do not support Unicode. Overrides the server-wide `ServerCharsetName`.
Example for Portuguese/Latin: `ISO-8859-1`

```
Brazil | CharsetName=ISO-8859-1
```

---

**n.11 — `AccessInfoMode`**
Controls when the room's welcome message (`noticeset`) is sent to connecting clients.

| Value | Description |
|-------|-------------|
| `Original` | Sends the welcome message only when an access list (`rights.dat`) is active for the room. Default. |
| `Always` | Always sends the welcome message on connection, regardless of access list. |
| `Never` | Never sends the welcome message. |

> **Important:** Set `AccessInfoMode=Always` for `noticeset` messages to work in rooms without access list restrictions.

```
Brazil | AccessInfoMode=Always
Teste  | AccessInfoMode=Always
```

---

**n.12 — `QuarantineTime`**
Delay in milliseconds between a client's TCP connection and its appearance in the connected clients list. Useful to avoid flickering in the client list caused by system manager probe connections.
Default: uses server-wide `QuarantineTime` (0)

```
Brazil | QuarantineTime=500
```

---

**n.13 — `SpeechPause`**
Mandatory pause in milliseconds between transmissions in this room. Prevents back-to-back keying.
Min: 0ms — Max: 10000ms (10s) — Default: uses server-wide value (0)

```
Brazil | SpeechPause=1000
```

---

**n.14 — `SpeechLimit`**
Enable or disable the maximum speech time limit for this room. Overrides the server-wide `SpeechLimit`.
Values: `yes` / `no` — Default: `yes`

```
Papagaio | SpeechLimit=yes
```

---

**n.15 — `ClientSessionMaxTime`**
Maximum duration of a client session in seconds before the client is disconnected and must reconnect. Overrides the server-wide `ClientSessionMaxTime`.
Default: `0` (no limit). Accepts time suffixes: `s` (seconds), `m` (minutes), `h` (hours), `d` (days), `y` (years).

```
Brazil | ClientSessionMaxTime=1d
Teste  | ClientSessionMaxTime=0
```

---

**n.16 — `ShortFrames`**
Enable or disable support for short 40ms audio frames in this room. Overrides the server-wide `ShortFrames`.
Values: `yes` / `no` — Default: `yes`

```
Brazil | ShortFrames=yes
```

---

#### Full example — networks.cfg

```
# National names MUST be UTF-8

Brazil     | Hidden=no; OwnerEMail=your@email.com; AccessInfoMode=Always
Teste      | Hidden=yes; OwnerEMail=your@email.com; ManagerMode=F; AccessInfoMode=Always
FRN        | Hidden=no; ManagerMode=F; AccessInfoMode=Always
XLXBRA     | Hidden=no; ManagerMode=F; AccessInfoMode=Always
Whrebe     | Hidden=yes; ManagerMode=F; OwnerEMail=your@email.com
Papagaio   | Hidden=no; ManagerMode=F; ParrotEnable=yes; ParrotStartStopEnable=yes; ParrotMaxRecordTime=30; MaxSpeechTime=60
Papagaio_5x | Hidden=no; ManagerMode=F; ParrotEnable=yes; ParrotRepeatCount=5; ParrotMaxRecordTime=30; ParrotStartStopEnable=yes; MaxSpeechTime=60
```

> **Note:** `AccessInfoMode=Always` must be set for welcome messages (`noticeset`) to be delivered regardless of access list configuration. The default `Original` only sends the message when an access list is active for the room.

---

## Room Welcome Messages

Welcome messages are stored in `notices.dat` and sent to clients upon connection. They are set via the command channel (requires `CommandEnabled=yes`):

```bash
# English room
/usr/src/FRNServer/FRNServer noticeset "Welcome to Brazil-FRN Server! | pp5pk.net | Owner: PP5PK - Daniel K | Mafra, SC, Brazil | 73!" Brazil /usr/src/FRNServer/server.ini

# Portuguese rooms
/usr/src/FRNServer/FRNServer noticeset "Bem-vindo ao servidor Brazil-FRN! | pp5pk.net | Operador: PP5PK - Daniel K | Mafra, SC, Brasil | 73!" FRN /usr/src/FRNServer/server.ini
/usr/src/FRNServer/FRNServer noticeset "Bem-vindo ao servidor Brazil-FRN! | pp5pk.net | Operador: PP5PK - Daniel K | Mafra, SC, Brasil | 73!" XLXBRA /usr/src/FRNServer/server.ini
/usr/src/FRNServer/FRNServer noticeset "Bem-vindo à sala Teste! | Este é um ambiente livre para testes, fique à vontade para usar! | 73!" Teste /usr/src/FRNServer/server.ini

# Remove a welcome message
/usr/src/FRNServer/FRNServer noticeclear Papagaio /usr/src/FRNServer/server.ini
```

> Messages are sent once at connection time. Display duration depends entirely on the client app — it cannot be controlled server-side. The Papagaio room sends its own built-in message and does not need a custom one.

Messages persist across restarts. After manually editing `notices.dat`, reload without restarting:

```bash
/usr/src/FRNServer/FRNServer drereadnotices /usr/src/FRNServer/server.ini
```

---

## Client Installation (Bot)

The `FRNClientConsole` can be installed alongside the server to act as a persistent bot connected to a room, enabling interactive text commands (`#help`, `#info`, `#who`, `#qrz`, etc.).

> ⚠️ **Pending implementation.** Bot setup and commands will be documented here once the client bot (`PP5PK-BOT`) is deployed.

Planned bot commands (triggered via text message with `#` prefix in any room):

| Command | Description |
|---------|-------------|
| `#help` | List all available commands |
| `#info` | Show server information |
| `#ping` | Check if server is responding |
| `#who` | List users in current room |
| `#who_all` | List users in all rooms |
| `#qrz <call>` | QRZ.com lookup for a callsign |

---

## Command Reference

All commands use the format:

```
/usr/src/FRNServer/FRNServer <command> [parameters] /usr/src/FRNServer/server.ini
```

Commands marked with ⚡ require `CommandEnabled=yes` in the `[Command]` section of `server.ini`.

---

### Server Control

| Command | Syntax | Description |
|---------|--------|-------------|
| `run` | `run [config]` | Start in foreground, log to file. **Use this with systemd.** |
| `daemon` | `daemon [config]` | Start as background daemon. |
| `debug` | `debug [config]` | Start in foreground, log to stdout. |
| `stop` | `stop [config]` | Stop the running daemon via PID file. |
| `dstop` ⚡ | `dstop [config]` | Stop server via command channel. |
| `uptime` ⚡ | `uptime [config]` | Show server uptime. |
| `pid` | `pid [config]` | Show PID of running daemon. |
| `dpid` ⚡ | `dpid [config]` | Show PID via command channel. |
| `reopenlog` | `reopenlog [config]` | Reopen log file (use with logrotate). |
| `deletepidfile` | `deletepidfile [config]` | Force delete PID file after power failure. |
| `flushdata` ⚡ | `flushdata [config]` | Force save all .dat databases to disk. |
| `logtext` ⚡ | `logtext "text" [config]` | Write arbitrary text to the server log. |

---

### Client Listing

| Command | Syntax | Description |
|---------|--------|-------------|
| `list` ⚡ | `list [config]` | List all connected clients. |
| `listnet` ⚡ | `listnet "room" [config]` | List clients in a specific room. |

**Flags for list/listnet:**

| Flag | Description |
|------|-------------|
| `-e` | Show e-mail |
| `-d` | Show session ID |
| `-i` | Show IP address |
| `-m` | Show manager IDs |
| `-p` | Show FRN protocol flags |
| `-f` | Show all fields |
| `-l` | Flat output (one line per client) |
| `-u` | UTF-8 output encoding |

```bash
# List all clients with full info
/usr/src/FRNServer/FRNServer -f list /usr/src/FRNServer/server.ini

# List clients in room Brazil with session ID (needed for moderation)
/usr/src/FRNServer/FRNServer -d listnet "Brazil" /usr/src/FRNServer/server.ini
```

---

### Client Moderation

> **Note:** `<clientid>` is the session ID obtained via `list -d` or `listnet -d`.

| Command | Syntax | Description |
|---------|--------|-------------|
| `mute` ⚡ | `mute "clientid" "room" [config]` | Silence a client (can hear, cannot transmit). Saved to `mutes.dat`. |
| `mutetemp` ⚡ | `mutetemp <seconds> "clientid" "room" [config]` | Silence temporarily. Auto-removed after timeout. |
| `unmute` ⚡ | `unmute "clientid" "room" [config]` | Remove mute. |
| `block` ⚡ | `block "clientid" "room" [config]` | Block client (disconnects, prevents reconnect). Saved to `blocks.dat`. |
| `blocktemp` ⚡ | `blocktemp <seconds> "clientid" "room" [config]` | Block temporarily. Auto-removed after timeout. |
| `unblock` ⚡ | `unblock "clientid" "room" [config]` | Remove block. |
| `move` ⚡ | `move <clientid> <roomfrom> <roomto> [config]` | Move client to another room without disconnecting. |
| `movetemp` ⚡ | `movetemp <seconds> <clientid> <roomfrom> <roomto> [config]` | Move temporarily. Auto-returned after timeout. |

```bash
# Silence a client permanently
/usr/src/FRNServer/FRNServer mute "yMDIxqy8tzhyaK7WT9f8hg0a" "Brazil" /usr/src/FRNServer/server.ini

# Silence for 10 minutes
/usr/src/FRNServer/FRNServer mutetemp 600 "yMDIxqy8tzhyaK7WT9f8hg0a" "Brazil" /usr/src/FRNServer/server.ini

# Block for 1 hour
/usr/src/FRNServer/FRNServer blocktemp 3600 "yMDIxqy8tzhyaK7WT9f8hg0a" "Brazil" /usr/src/FRNServer/server.ini

# Move from Brazil to FRN
/usr/src/FRNServer/FRNServer move "yMDIxqy8tzhyaK7WT9f8hg0a" "Brazil" "FRN" /usr/src/FRNServer/server.ini

# Move to Papagaio for 5 minutes, then auto-return
/usr/src/FRNServer/FRNServer movetemp 300 "yMDIxqy8tzhyaK7WT9f8hg0a" "Brazil" "Papagaio" /usr/src/FRNServer/server.ini
```

---

### Room Administration

| Command | Syntax | Description |
|---------|--------|-------------|
| `adminadd` ⚡ | `adminadd "clientid\|email" "room" [config]` | Add administrator by session ID or e-mail. Saved to `admins.dat`. |
| `admindel` ⚡ | `admindel <clientid> <room> [config]` | Remove administrator. |
| `connenable` ⚡ | `connenable <room> [config]` | Restrict connection to marked users only. Saved to `modes.dat`. |
| `conndisable` ⚡ | `conndisable <room> [config]` | Remove connection restriction. |
| `talkenable` ⚡ | `talkenable <room> [config]` | Restrict transmission to marked users only. Saved to `modes.dat`. |
| `talkdisable` ⚡ | `talkdisable <room> [config]` | Remove talk restriction. |
| `noticeset` ⚡ | `noticeset "message" <room> [config]` | Set welcome message. Saved to `notices.dat`. |
| `noticeclear` ⚡ | `noticeclear <room> [config]` | Remove welcome message. |

```bash
# Add administrator by e-mail
/usr/src/FRNServer/FRNServer adminadd "svrutz@gmail.com" "Brazil" /usr/src/FRNServer/server.ini

# Restrict room Whrebe to marked users only
/usr/src/FRNServer/FRNServer connenable "Whrebe" /usr/src/FRNServer/server.ini

# Open it back
/usr/src/FRNServer/FRNServer conndisable "Whrebe" /usr/src/FRNServer/server.ini
```

---

### Access Rights

| Command | Syntax | Description |
|---------|--------|-------------|
| `rightadd` ⚡ | `rightadd <email> <room> [config]` | Add e-mail to access list. Saved to `rights.dat`. |
| `rightdel` ⚡ | `rightdel <email> <room> [config]` | Remove e-mail from access list. |
| `rightmark` ⚡ | `rightmark <email> <room> [config]` | Mark e-mail (required for `connenable`/`talkenable`). |
| `rightunmark` ⚡ | `rightunmark <email> <room> [config]` | Remove mark. |

```bash
# Add and mark user for restricted room
/usr/src/FRNServer/FRNServer rightadd "user@example.com" "Whrebe" /usr/src/FRNServer/server.ini
/usr/src/FRNServer/FRNServer rightmark "user@example.com" "Whrebe" /usr/src/FRNServer/server.ini

# Remove user
/usr/src/FRNServer/FRNServer rightdel "user@example.com" "Whrebe" /usr/src/FRNServer/server.ini
```

---

### Manager Password Management

| Command | Syntax | Description |
|---------|--------|-------------|
| `setmanpassidx` | `setmanpassidx <index> "password" [config]` | Save new password to config by manager index (0=`[Manager]`, 1=`[Manager1]`, 2=`[Manager2]`). Requires restart. |
| `setmanpassaddr` | `setmanpassaddr <address> "password" [config]` | Save new password to config by manager address. Requires restart. |
| `dsetmanpassidx` ⚡ | `dsetmanpassidx <index> <password> [config]` | Apply new password at runtime by index. Does **not** save to config. |
| `dsetmanpassaddr` ⚡ | `dsetmanpassaddr <address> <password> [config]` | Apply new password at runtime by address. Does **not** save to config. |

```bash
# Update and save password for [Manager] (index 0)
/usr/src/FRNServer/FRNServer setmanpassidx 0 "NewPassword" /usr/src/FRNServer/server.ini

# Apply at runtime without restart (does not persist)
/usr/src/FRNServer/FRNServer dsetmanpassidx 0 "NewPassword" /usr/src/FRNServer/server.ini

# Update by manager address
/usr/src/FRNServer/FRNServer setmanpassaddr sysman.freeradionetwork.de "NewPassword" /usr/src/FRNServer/server.ini
```

---

### Database Reload (without restart)

| Command | Syntax | Description |
|---------|--------|-------------|
| `drereadmutes` ⚡ | `drereadmutes [config]` | Reload `mutes.dat`. |
| `drereadblocks` ⚡ | `drereadblocks [config]` | Reload `blocks.dat`. |
| `drereadadmins` ⚡ | `drereadadmins [config]` | Reload `admins.dat`. |
| `drereadrights` ⚡ | `drereadrights [config]` | Reload `rights.dat`. |
| `drereadmodes` ⚡ | `drereadmodes [config]` | Reload `modes.dat`. |
| `drereadnotices` ⚡ | `drereadnotices [config]` | Reload `notices.dat`. |
| `freread*` ⚡ | `freread* <filename> [config]` | Reload any database from a custom file path. |

```bash
# Reload all databases after manual editing
/usr/src/FRNServer/FRNServer drereadmutes /usr/src/FRNServer/server.ini
/usr/src/FRNServer/FRNServer drereadblocks /usr/src/FRNServer/server.ini
/usr/src/FRNServer/FRNServer drereadadmins /usr/src/FRNServer/server.ini
/usr/src/FRNServer/FRNServer drereadrights /usr/src/FRNServer/server.ini
/usr/src/FRNServer/FRNServer drereadmodes /usr/src/FRNServer/server.ini
/usr/src/FRNServer/FRNServer drereadnotices /usr/src/FRNServer/server.ini

# Reload from a custom file (useful for primary/backup server sync)
/usr/src/FRNServer/FRNServer frereadblocks /backup/blocks.dat /usr/src/FRNServer/server.ini
```

---

## Database Files Reference

| File | Managed by | Description |
|------|-----------|-------------|
| `notices.dat` | `noticeset` / `noticeclear` | Welcome messages per room. |
| `admins.dat` | `adminadd` / `admindel` | Room administrators. |
| `mutes.dat` | `mute` / `mutetemp` / `unmute` | Silenced clients. |
| `blocks.dat` | `block` / `blocktemp` / `unblock` | Blocked clients. |
| `rights.dat` | `rightadd` / `rightdel` / `rightmark` / `rightunmark` | Access list per room. |
| `modes.dat` | `connenable` / `conndisable` / `talkenable` / `talkdisable` | Access restriction modes per room. |

All database files are located in `DataDir` (default: `/usr/src/FRNServer/`). They persist across restarts and can be reloaded at runtime without restarting the service.

---

## FRN System Managers

| Manager | Address | Port | Notes |
|---------|---------|------|-------|
| FRN System DE | `sysman.freeradionetwork.de` | 10025 | Primary — recommended |
| FRN System EU | `sysman.freeradionetwork.eu` | 10025 | Redirects to DE since Aug 2024 — equivalent |
| FRN System RU | `sysman.lpd-net.ru` | 10025 | Russian system — independent network |

> Connect your server to **only one** of DE or EU. Connecting to both simultaneously is redundant and against the operator's guidelines. The DE and EU systems share the same server listing.

---

## License

Released under the **Unlicense**. See [LICENSE](LICENSE) for details.

---

*⚡ Requires `CommandEnabled=yes` in `[Command]` section of `server.ini`.*
