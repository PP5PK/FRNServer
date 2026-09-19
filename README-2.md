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

---

#### Section `[Server]`

**s.1.1 — `PresentServerAddress`**
Public address (hostname or IP) announced to the FRN System Manager. The manager uses this address to probe the server and verify it is reachable.

```ini
PresentServerAddress=Brazil-FRN.dvbr.net
```

---

**s.1.2 — `PresentServerPort`**
Public port announced to the FRN System Manager for probe checks.

```ini
PresentServerPort=10024
```

---

**s.1.3 — `ServerOwnerEMail`**
Primary e-mail of the server owner. A client connecting with this e-mail and the correct password receives full server owner privileges (`AL=OWNER`). Also used as the default authentication e-mail for all `[Manager*]` sections unless overridden by `ManagerAuthEMail`.

```ini
ServerOwnerEMail=your@email.com
```

---

**s.1.4 — `ServerCharsetName`**
ANSI charset name used server-wide when sending room names to legacy clients that do not support Unicode. FRN clients with Unicode support always receive UTF-8. Each room can override this with its own `CharsetName` attribute in `networks.cfg`.
Example for Portuguese/Latin: `ISO-8859-1`

```ini
ServerCharsetName=ISO-8859-1
```

---

**s.1.5 — `BackupServerAddress`**
Backup server address sent to FRN clients during handshake (`<BN>` field). If the client loses connection to the primary server, it automatically attempts to reconnect using this address. Requires a second independent FRNServer instance for true redundancy.

```ini
BackupServerAddress=pp5pk.net
```

---

**s.1.6 — `BackupServerPort`**
Port of the backup server sent to clients.

```ini
BackupServerPort=10024
```

---

**s.1.7 — `ListenServerPorts`**
List of TCP ports the server actually listens on for incoming client connections. Multiple ports separated by spaces. Defaults to `PresentServerPort` if not set.

```ini
ListenServerPorts=10024 20010
```

---

**s.1.8 — `DefaultNetworkName`**
Room where clients are placed if they attempt to connect to a room that does not exist on this server. Avoid setting a restricted-access room here.

```ini
DefaultNetworkName=Brazil
```

---

**s.1.9 — `IPVersion`**
IP protocol version(s) used for incoming client connections.
Values: `4` (IPv4 only) / `6` (IPv6 only) / `46` (both) — Default: `46`

```ini
IPVersion=4
```

---

**s.1.10 — `ManagerMode`**
Server-wide authentication mode with the FRN System Manager. Each room in `networks.cfg` can override this with its own `ManagerMode` attribute.

| Value | Description |
|-------|-------------|
| `Standalone` or `S` | No interaction with manager. Fully autonomous. Default. |
| `Notify` or `N` | Server notifies manager but ignores negative responses. Client always allowed in. |
| `Light` or `L` | If manager unavailable, client is allowed in. When manager recovers, client is re-checked and may be kicked. |
| `FRN` or `F` | If manager unavailable, no clients allowed. If available, client is validated against manager response. |

> Note: The server does not cache valid client passwords. The `Light` mode is the recommended alternative to caching.

```ini
ManagerMode=FRN
```

---

**s.1.11 — `MaxTotalConnections`**
Maximum total simultaneous incoming connections across the entire server.
Default: `1000`

```ini
MaxTotalConnections=150
```

---

**s.1.12 — `ClientHandshakeTimeout`**
Time in seconds a client has to complete authentication after connecting.
Min: 1s — Max: 20s — Default: 2s

```ini
ClientHandshakeTimeout=2
```

---

**s.1.13 — `ClientActivityTimeout`**
Time in seconds after which a client connection is dropped if the client stops responding to protocol commands (e.g. due to poor network).
Min: 3s — Max: 30s — Default: 8s

```ini
ClientActivityTimeout=8
```

---

**s.1.14 — `MaxSpeechTime`**
Server-wide maximum duration of a single transmission in seconds. Each room can override this with its own `MaxSpeechTime` attribute.
Min: 10s — Max: 1800s (30 min) — Default: 300s (5 min)

```ini
MaxSpeechTime=180
```

---

**s.1.15 — `SpeechPause`**
Server-wide mandatory pause in milliseconds between transmissions. Prevents back-to-back keying. Each room can override with its own `SpeechPause` attribute.
Min: 0ms — Max: 10000ms (10s) — Default: 0ms

```ini
SpeechPause=2000
```

---

**s.1.16 — `ClientSessionMaxTime`**
Server-wide maximum duration of a client session. After this time the client is disconnected and must reconnect. Each room can override with its own `ClientSessionMaxTime` attribute.
Default: `0` (no limit). Accepts time suffixes: `s`, `m`, `h`, `d`, `y`.

```ini
ClientSessionMaxTime=1y
```

---

**s.1.17 — `ManagerInvalidPasswordScript`**
*(Linux/Unix only)* External script executed when the FRN System Manager returns an "invalid password" error. The script can use the `register` command of the AlterFRN client to request a new password, which can then be applied via `setmanpassidx` or `dsetmanpassidx` without restarting the server. Each `[Manager*]` section can define its own `ManagerInvalidPasswordScript`.

```ini
ManagerInvalidPasswordScript=/usr/src/FRNServer/invalid_pass.sh
```

---

**s.1.18 — `MaxWaitConnections`**
Maximum number of incoming connections simultaneously queued waiting for server processing (socket `listen` backlog).
Default: `5`

```ini
MaxWaitConnections=5
```

---

**s.1.19 — `SpeechLimit`**
Enable or disable the maximum speech time limit server-wide. Each room can override with its own `SpeechLimit` attribute.
Values: `yes` / `no` — Default: `yes`

```ini
SpeechLimit=yes
```

---

**s.1.20 — `ShortFrames`**
Enable or disable support for short 40ms audio frames server-wide. Each room can override with its own `ShortFrames` attribute.
Values: `yes` / `no` — Default: `yes`

```ini
ShortFrames=yes
```

---

**s.1.21 — `QuarantineTime`**
Delay in milliseconds between a client's TCP connection and its appearance in the connected clients list. Prevents flickering caused by system manager probe connections. Each room can override with its own `QuarantineTime` attribute.
Default: `0`

```ini
QuarantineTime=0
```

---

**s.1.22 — `MaxConnectionsPerAddress`**
Maximum simultaneous connections from a single IP address.
Default: `7`

```ini
MaxConnectionsPerAddress=7
```

---

**s.1.23 — `ManagerEmptyDescription`**
When enabled, sends an empty `Description` field to the FRN System Manager instead of the actual client description. Can also be set per `[Manager*]` section.
Values: `yes` / `no` — Default: `no`

```ini
ManagerEmptyDescription=no
```

---

#### Section `[Manager]`, `[Manager1]`, `[Manager2]`, `[Manager3]`

Up to four FRN System Manager connections can be configured. `[Manager]` is index 0, `[Manager1]` is index 1, and so on.

> **Important:** Connect only to **one** of `.de` or `.eu`. Since August 2024, `freeradionetwork.eu` redirects to `freeradionetwork.de` — they are equivalent. Connecting to both simultaneously is considered redundant and may result in your server being blocked.

**s.2.1 — `ManagerEnabled`**
Enable or disable this manager section.
Values: `yes` / `no` — Default: `no`

**s.2.2 — `ManagerAddress`**
Hostname or IP of the FRN System Manager.
Default: `sysman.lpd-net.ru`

**s.2.3 — `ManagerPort`**
Port of the FRN System Manager.
Default: `10025`

**s.2.4 — `ManagerAuthEMail`**
E-mail used to authenticate the server with this specific manager. Defaults to `ServerOwnerEMail` if not set. A previously registered client account (e-mail + password) can be used here.

**s.2.5 — `ManagerAuthPassword`**
Password for authenticating the server with this manager. Obtained via the AlterFRN client `register` command.

**s.2.6 — `ManagerInvalidPasswordScript`**
*(Linux/Unix only)* Script to execute when this specific manager returns an "invalid password" error. Overrides the server-wide `ManagerInvalidPasswordScript` (s.1.17) for this manager only.

**s.2.7 — `ManagerEmptyDescription`**
When enabled, sends an empty description to this specific manager instead of the actual client description. Overrides the server-wide `ManagerEmptyDescription` (s.1.23) for this manager only.
Values: `yes` / `no`

```ini
[Manager]
ManagerEnabled=yes
ManagerAddress=sysman.freeradionetwork.de
ManagerPort=10025
ManagerAuthEMail=your@email.com
ManagerAuthPassword=YOURPASSWORD
ManagerConnectTimeout=3
ManagerActivityTimeout=8
ManagerReconnectInterval=60
ManagerLogErrors=yes
ManagerLogDebug=0
ManagerPreferIPv4=yes
```

---

#### Section `[System]`

**s.3.1 — `PidFile`** *(Linux/Unix only)*
Path to the PID file for the background daemon process.
Default: `/var/run/frnserver.pid`

**s.3.2 — `LogFile`**
Path to the server event log file, used by the `daemon` and `run` commands.
Default: `./frnserver.log`

**s.3.3 — `LogClientLevel`**
Level of detail for client event logging.

| Value | Description |
|-------|-------------|
| `0` | No client events logged. |
| `1` | Dangerous events only (empty connections, wrong protocol). |
| `2` | Warnings and dangerous events. **Default.** |
| `3` | Failed client connections and all above. |
| `4` | Successful client connections and all above. |
| `5` | All incoming connections and all above. |

**s.3.4 — `LogExec`**
Log the execution of external scripts with their command line parameters.
Values: `yes` / `no` — Default: `no`

**s.3.5 — `ListDelimiter`**
Field delimiter used in `list` and `listnet` command output.
Default: `;`

**s.3.6 — `DataChangeScript`** *(Linux/Unix only)*
External script called whenever any `.dat` database file changes. Receives the type of changed data and the full file path as arguments. Useful for synchronizing primary and backup server databases using the `freread*` commands.

**s.3.7 — `DataDir`**
Directory where the server stores its `.dat` database files (`notices.dat`, `mutes.dat`, `blocks.dat`, etc.).
Default: same directory as the server binary.

```ini
[System]
PidFile=/var/run/frnserver.pid
LogFile=/var/log/frnserver.log
LogClientLevel=5
LogExec=yes
DataDir=/usr/src/FRNServer/
```

---

#### Section `[Command]`

The command channel enables runtime administration without restarting the server. It listens only on `localhost` — it is never exposed externally.

**s.6.1 — `CommandEnabled`**
Enable the command channel. Required for all `⚡` commands in this guide.
Values: `yes` / `no` — Default: `no`

**s.6.2 — `CommandPort`**
Port for the command channel. Use different ports if running multiple server instances on the same machine.
Default: `10023`

**s.6.3 — `CommandIPVersion`**
IP version for the command channel.
Values: `4` / `6` / `46` — Default: `4`

> **Note:** If the system does not support IPv6 (check with `journalctl -u frn.service`), use `CommandIPVersion=4` to avoid the bind error on `[::1]:10023`.

**s.6.4 — `CommandPreferIPv4`**
Prefer IPv4 for command channel connections.
Values: `yes` / `no` — Default: `yes`

```ini
[Command]
CommandEnabled=yes
CommandPort=10023
CommandIPVersion=4
CommandPreferIPv4=yes
```

### networks.cfg

Each line defines a room. Format:

```
RoomName | option1=value; option2=value; option3=value
```

Lines starting with `#` are comments. Room names must be in UTF-8. Multiple attributes are separated by `;`.

---

#### Complete parameter reference

**n.1 — `OwnerEMail`**
E-mail of the room owner. A client connecting with this e-mail and the correct password receives room owner privileges. Multiple owners can be specified separated by commas (r5195+). If omitted, the server's `ServerOwnerEMail` applies.

```
Brazil | OwnerEMail=your@email.com
Brazil | OwnerEMail=owner1@email.com,owner2@email.com
```

---

**n.2 — `MaxClients`**
Maximum number of clients simultaneously connected to this room.
Default: `65535`

```
Brazil | MaxClients=20
```

---

**n.3 — `MaxSpeechTime`**
Maximum duration of a single transmission in seconds. After this time, the server sends a command to the client to stop transmitting. Overrides the server-wide `MaxSpeechTime`.
Min: 10s — Max: 1800s (30 min) — Default: 300s (5 min)

```
Papagaio | MaxSpeechTime=60
```

---

**n.4 — `ParrotEnable`**
Enables parrot (echo/repeater) mode for the room. Audio received is recorded and played back to all connected clients.
Values: `yes` / `no` — Default: `no`

```
Papagaio | ParrotEnable=yes
```

---

**n.5 — `ParrotStartStopEnable`**
Allows users to activate and deactivate parrot mode by sending the text commands `start` and `stop` in the room.
Values: `yes` / `no` — Default: `no`
Requires: `ParrotEnable=yes`

```
Papagaio | ParrotEnable=yes; ParrotStartStopEnable=yes
```

---

**n.6 — `ParrotMuteEnable`**
Allows the parrot itself to be muted (silenced) by room administrators.
Values: `yes` / `no` — Default: `no`

```
Papagaio | ParrotEnable=yes; ParrotMuteEnable=yes
```

---

**n.7 — `ParrotMaxRecordTime`**
Maximum audio recording time in seconds for each parrot cycle.
Default: `600s` (10 min)

```
Papagaio | ParrotMaxRecordTime=30
```

---

**n.8 — `ParrotPause`**
Pause in milliseconds before the parrot starts playing back the recorded audio.
Default: `2000ms` (2 seconds)

```
Papagaio | ParrotPause=1000
```

---

**n.9 — `ParrotRepeatCount`**
Number of times the parrot replays the recorded audio before accepting new input.
Default: `1`

```
Papagaio_5x | ParrotRepeatCount=5
```

---

**n.10 — `CharsetName`**
ANSI charset name for this specific room. Used when sending the room name to legacy clients that do not support Unicode. Also used for transcoding client information in the server log and in `list`/`listnet` output. Overrides the server-wide `ServerCharsetName`.
Example for Portuguese/Latin: `ISO-8859-1`

```
Brazil | CharsetName=ISO-8859-1
```

---

**n.11 — `ManagerMode`**
Authentication mode with the FRN System Manager for this specific room. Overrides the server-wide `ManagerMode`.

| Value | Description |
|-------|-------------|
| `Standalone` or `S` | No interaction with manager. Fully autonomous. |
| `Notify` or `N` | Server notifies manager but ignores negative responses. Client is always allowed in. |
| `Light` or `L` | If manager unavailable, client is allowed in. When manager recovers, client is re-checked and may be kicked. |
| `FRN` or `F` | If manager unavailable, no clients are allowed. If available, client is validated against manager response. |

```
FRN    | ManagerMode=F
Brazil | ManagerMode=FRN
Teste  | ManagerMode=Standalone
```

---

**n.12 — `ManagersMask`**
Bitmask that enables or disables interaction with specific FRN System Managers for this room. Uses bits 0–2 corresponding to `[Manager]`, `[Manager1]` and `[Manager2]` respectively.
Default: `7` (all managers enabled)

| Value | Managers active |
|-------|----------------|
| `7` | All (Manager + Manager1 + Manager2) |
| `1` | Manager only |
| `2` | Manager1 only |
| `4` | Manager2 only |
| `3` | Manager + Manager1 |

```
Brazil | ManagersMask=1
```

---

**n.13 — `SpeechPause`**
Mandatory pause in milliseconds between transmissions in this room. Prevents back-to-back keying.
Min: 0ms — Max: 10000ms (10s) — Default: uses server-wide value (0)

```
Brazil | SpeechPause=1000
```

---

**n.14 — `AccessInfoMode`**
Controls when the room's welcome message (set via `noticeset`) is sent to connecting clients.

| Value | Alias | Description |
|-------|-------|-------------|
| `Original` | `O` or `0` | Sends welcome message only when an access list is active for the room. **Default.** |
| `Always` | `A` or `1` | Always sends the welcome message on connection. |
| `Never` | `N` or `2` | Never sends the welcome message. |

> **Important:** Set `AccessInfoMode=Always` for `noticeset` messages to work in rooms without access list restrictions.

```
Brazil | AccessInfoMode=Always
Teste  | AccessInfoMode=Always
```

---

**n.15 — `ClientSessionMaxTime`**
Maximum duration of a client session before the client is disconnected and must reconnect. Overrides the server-wide `ClientSessionMaxTime`.
Default: `0` (no limit). Accepts time suffixes: `s` (seconds), `m` (minutes), `h` (hours), `d` (days), `y` (years).

```
Brazil | ClientSessionMaxTime=1d
Teste  | ClientSessionMaxTime=0
```

---

**n.16 — `SpeechLimit`**
Enable or disable the maximum speech time limit for this room. Overrides the server-wide `SpeechLimit`.
Values: `yes` / `no` — Default: uses server-wide value (`yes`)

```
Papagaio | SpeechLimit=yes
```

---

**n.17 — `ShortFrames`**
Enable or disable support for short 40ms audio frames in this room. Overrides the server-wide `ShortFrames`.
Values: `yes` / `no` — Default: uses server-wide value (`yes`)

```
Brazil | ShortFrames=yes
```

---

**n.18 — `QuarantineTime`**
Delay in milliseconds between a client's TCP connection and its appearance in the connected clients list. Useful to avoid flickering caused by system manager probe connections. Overrides the server-wide `QuarantineTime`.
Default: uses server-wide value (0)

```
Brazil | QuarantineTime=500
```

---

**n.19 — `Hidden`**
Controls whether the room appears in the public room list sent to clients. Clients must know the exact room name to connect to a hidden room. To also hide the room from the FRN System Manager server listing, combine with `ManagerMode=Standalone`.
Values: `yes` / `no` — Default: `no`

```
Whrebe | Hidden=yes; ManagerMode=Standalone
```

---

#### Full example — networks.cfg

```
# National names MUST be UTF-8

Brazil      | Hidden=no; OwnerEMail=your@email.com; AccessInfoMode=Always
Teste       | Hidden=yes; OwnerEMail=your@email.com; ManagerMode=F; AccessInfoMode=Always
FRN         | Hidden=no; ManagerMode=F; AccessInfoMode=Always
XLXBRA      | Hidden=no; ManagerMode=F; AccessInfoMode=Always
Whrebe      | Hidden=yes; ManagerMode=Standalone; OwnerEMail=your@email.com
Papagaio    | Hidden=no; ManagerMode=F; ParrotEnable=yes; ParrotStartStopEnable=yes; ParrotMaxRecordTime=30; MaxSpeechTime=60
Papagaio_5x | Hidden=no; ManagerMode=F; ParrotEnable=yes; ParrotRepeatCount=5; ParrotMaxRecordTime=30; ParrotStartStopEnable=yes; MaxSpeechTime=60
```

> **Note:** `AccessInfoMode=Always` must be set for welcome messages (`noticeset`) to be delivered to clients in rooms without an active access list.

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
