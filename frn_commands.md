# AlterFRN Server — Command Reference
**Brazil-FRN | dvbr.net | PP5PK**
Revision r7348 — All commands use the format:
`FRNServer <command> [parameters] [/usr/src/FRNServer/server.ini]`
Commands marked with ⚡ require the `[Command]` channel active in `server.ini`.

---

## Server Control

| Command | Syntax | Description |
|---------|--------|-------------|
| `daemon` | `daemon [config]` | Start server as background daemon. Log goes to file. |
| `run` | `run [config]` | Start server in foreground, log goes to file. |
| `debug` | `debug [config]` | Start server in foreground, log goes to stdout. |
| `stop` | `stop [config]` | Stop the running daemon (sends SIGTERM via PID file). |
| `dstop` ⚡ | `dstop [config]` | Stop the running server via command channel. |
| `uptime` ⚡ | `uptime [config]` | Show how long the server has been running. |
| `pid` | `pid [config]` | Show PID of the running daemon. |
| `dpid` ⚡ | `dpid [config]` | Show PID via command channel. |
| `pidfilename` | `pidfilename [config]` | Show full path of the PID file. |
| `logfilename` | `logfilename [config]` | Show full path of the log file. |
| `reopenlog` | `reopenlog [config]` | Reopen log file (for use with logrotate). |
| `deletepidfile` | `deletepidfile [config]` | Force delete PID file (useful after power failure). |
| `flushdata` ⚡ | `flushdata [config]` | Force save all .dat databases to disk immediately. |
| `logtext` ⚡ | `logtext "text" [config]` | Write arbitrary text to the server log. |

---

## Client Listing

| Command | Syntax | Description |
|---------|--------|-------------|
| `list` ⚡ | `list [config]` | List all clients connected to the server. |
| `listnet` ⚡ | `listnet "room" [config]` | List clients connected to a specific room. |

**Useful flags for list/listnet:**

| Flag | Description |
|------|-------------|
| `-e` | Show client e-mail as separate field. |
| `-d` | Show client session ID as separate field. |
| `-i` | Show client IP address as separate field. |
| `-m` | Show manager IDs as separate field. |
| `-p` | Show FRN protocol flags as separate field. |
| `-f` | Show all of the above (full info). |
| `-l` | Flat list format (one line per client). |
| `-u` | Use UTF-8 encoding for output. |

---

## Client Moderation

| Command | Syntax | Description |
|---------|--------|-------------|
| `mute` ⚡ | `mute "clientid" "room" [config]` | Silence a client in a room (can hear but cannot transmit). Saved to `mutes.dat`. |
| `mutetemp` ⚡ | `mutetemp <seconds> "clientid" "room" [config]` | Silence a client for a specified time in seconds. Auto-removed after timeout. |
| `unmute` ⚡ | `unmute "clientid" "room" [config]` | Remove mute from a client. |
| `block` ⚡ | `block "clientid" "room" [config]` | Block a client from a room (disconnects and prevents reconnect). Saved to `blocks.dat`. |
| `blocktemp` ⚡ | `blocktemp <seconds> "clientid" "room" [config]` | Block a client for a specified time in seconds. Auto-removed after timeout. |
| `unblock` ⚡ | `unblock "clientid" "room" [config]` | Remove block from a client. |
| `move` ⚡ | `move <clientid> <roomfrom> <roomto> [config]` | Move a client from one room to another without disconnecting. |
| `movetemp` ⚡ | `movetemp <seconds> <clientid> <roomfrom> <roomto> [config]` | Move a client temporarily. Auto-returned after timeout. |

> **Note:** `clientid` is the session ID obtained via `list -d` or `listnet -d`.

---

## Room Administration

| Command | Syntax | Description |
|---------|--------|-------------|
| `adminadd` ⚡ | `adminadd "clientid\|email" "room" [config]` | Add a client as room administrator by session ID or e-mail. Saved to `admins.dat`. |
| `admindel` ⚡ | `admindel <clientid> <room> [config]` | Remove a client from room administrators. |
| `connenable` ⚡ | `connenable <room> [config]` | Restrict room access: only marked clients in `rights.dat` can connect. Saved to `modes.dat`. |
| `conndisable` ⚡ | `conndisable <room> [config]` | Remove connection restriction from room. |
| `talkenable` ⚡ | `talkenable <room> [config]` | Restrict talking: only marked clients in `rights.dat` can transmit. Saved to `modes.dat`. |
| `talkdisable` ⚡ | `talkdisable <room> [config]` | Remove talk restriction from room. |
| `noticeset` ⚡ | `noticeset "message" <room> [config]` | Set welcome message for a room. Saved to `notices.dat`. |
| `noticeclear` ⚡ | `noticeclear <room> [config]` | Remove welcome message from a room. |

---

## Access Rights

| Command | Syntax | Description |
|---------|--------|-------------|
| `rightadd` ⚡ | `rightadd <email> <room> [config]` | Add an e-mail to the room access list. Saved to `rights.dat`. |
| `rightdel` ⚡ | `rightdel <email> <room> [config]` | Remove an e-mail from the room access list. |
| `rightmark` ⚡ | `rightmark <email> <room> [config]` | Mark an e-mail in the access list (required for connenable/talkenable). |
| `rightunmark` ⚡ | `rightunmark <email> <room> [config]` | Remove mark from an e-mail in the access list. |

---

## Manager Password Management

| Command | Syntax | Description |
|---------|--------|-------------|
| `setmanpassidx` | `setmanpassidx <index> "password" [config]` | Save new manager password to config file by index (0=Manager, 1=Manager1, 2=Manager2). Requires restart. |
| `setmanpassaddr` | `setmanpassaddr <address> "password" [config]` | Save new manager password to config file by manager address. Requires restart. |
| `dsetmanpassidx` ⚡ | `dsetmanpassidx <index> <password> [config]` | Apply new manager password at runtime by index. Does NOT save to config file. |
| `dsetmanpassaddr` ⚡ | `dsetmanpassaddr <address> <password> [config]` | Apply new manager password at runtime by address. Does NOT save to config file. |

---

## Database Reload (without restart)

| Command | Syntax | Description |
|---------|--------|-------------|
| `drereadmutes` ⚡ | `drereadmutes [config]` | Reload `mutes.dat` from disk. |
| `drereadblocks` ⚡ | `drereadblocks [config]` | Reload `blocks.dat` from disk. |
| `drereadadmins` ⚡ | `drereadadmins [config]` | Reload `admins.dat` from disk. |
| `drereadrights` ⚡ | `drereadrights [config]` | Reload `rights.dat` from disk. |
| `drereadmodes` ⚡ | `drereadmodes [config]` | Reload `modes.dat` from disk. |
| `drereadnotices` ⚡ | `drereadnotices [config]` | Reload `notices.dat` from disk. |
| `frereadmutes` ⚡ | `frereadmutes <filename> [config]` | Reload mutes from a specific file. |
| `frereadblocks` ⚡ | `frereadblocks <filename> [config]` | Reload blocks from a specific file. |
| `frereadadmins` ⚡ | `frereadadmins <filename> [config]` | Reload admins from a specific file. |
| `frereadrights` ⚡ | `frereadrights <filename> [config]` | Reload rights from a specific file. |
| `frereadmodes` ⚡ | `frereadmodes <filename> [config]` | Reload modes from a specific file. |
| `frereadnotices` ⚡ | `frereadnotices <filename> [config]` | Reload notices from a specific file. |

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

---

*⚡ Requires `CommandEnabled=yes` in `[Command]` section of `server.ini`.*
