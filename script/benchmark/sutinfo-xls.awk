#!/usr/bin/gawk
#
# Apache v2 license
# Copyright (C) 2023 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#

function add_sutinfo_cell(vv) {
    t=(vv==vv*1)?"Number":"String"
    print "<Cell ss:StyleID=\"sutinfo\"><Data ss:Type=\"" t "\">" escape(vv) "</Data></Cell>"
}

function ws_p_s_c_g(ws, p, s, c, g) {
    if (length(sutinfo_values[ws][p][s])>0)
        if (length(sutinfo_values[ws][p][s][c])>0)
            return length(sutinfo_values[ws][p][s][c][g])
    return 0
}

function ws_p_s_c_g_i(ws, p, s, c, g, i) {
    if (ws_p_s_c_g(ws, p, s, c, g)==0) return 0
    return length(sutinfo_values[ws][p][s][c][g][i])
}

function add_sutinfo_row(ws, c, g, k, cp, gp, kp) {
    print "<Row>"
    add_sutinfo_cell(g"."k)
    for (p in sutinfo_values[ws])
        for (s in sutinfo_values[ws][p])
            vv=""
            if (ws_p_s_c_g_i(ws, p, s, cp, gp, 1)>0)
                vv=sutinfo_values[ws][p][s][cp][gp][1][kp]
            if (ws_p_s_c_g_i(ws, p, s, c, g, 1)>0)
                vv=sutinfo_values[ws][p][s][c][g][1][k]
            add_sutinfo_cell(vv)
    print "</Row>"
}

function add_sutinfo_isa_summary(ws, c, g, kn, kc, kk, y, cp, gp, yp) {
    print "<Row>"
    add_sutinfo_cell(g)
    for (p in sutinfo_values[ws]) {
        for (s in sutinfo_values[ws][p]) {
            vv=""
            if (ws_p_s_c_g(ws, p, s, cp, gp)>0)
                for (i in sutinfo_values[ws][p][s][cp][gp])
                    if (ws_p_s_c_g_i(ws, p, s, cp, gp, i)>0)
                        for (kp in sutinfo_values[ws][p][s][cp][gp][i])
                            if (sutinfo_values[ws][p][s][cp][gp][i][kp] == yp)
                                vv=vv", "kp
            if (ws_p_s_c_g(ws, p, s, c, g)>0)
                for (i in sutinfo_values[ws][p][s][c][g])
                    if (ws_p_s_c_g_i(ws, p, s, c, g, i)>0)
                        if ((sutinfo_values[ws][p][s][c][g][i][kc] == y) && (sutinfo_values[ws][p][s][c][g][i][kc] == y))
                            vv=vv", "sutinfo_values[ws][p][s][c][g][i][kn]
            add_sutinfo_cell(gensub(/^, /,"",1,vv))
        }
    }
    print "</Row>"
}

function find_sutinfo_phost(ws, p) {
    if (length(sutinfo_values[ws][p])==1)
        for (s in sutinfo_values[ws][p])
            return s
    for (s in sutinfo_values[ws][p])
        if (s==sutinfo_phostip[ws][p])
            return s
    return s
}

function add_sutinfo_cell_ex(i, vv) {
    style=(vv==vv*1)?"Number":"String"
    print "<Cell ss:Index=\"" i "\" ss:StyleID=\"sutinfo\"><Data ss:Type=\"" style "\">" escape(vv) "</Data></Cell>"
}

function add_sutinfo_row_ex(ws, psp, ith, c, g, k, cp, gp, kp) {
    print "<Row>"
    add_sutinfo_cell(g"."k)
    np=length(psp)
    for (p1=1;p1<=np;p1++) {
        s=find_sutinfo_phost(ws, psp[p1])
        vv=""
        if (ws_p_s_c_g_i(ws,psp[p1],s,cp,gp,1)>0)
            vv=sutinfo_values[ws][psp[p1]][s][cp][gp][1][kp]
        if (ws_p_s_c_g_i(ws,psp[p1],s,c,g,1)>0)
            vv=sutinfo_values[ws][psp[p1]][s][c][g][1][k]
        add_sutinfo_cell_ex(ith[p1], vv)
    }
    print "</Row>"
}

function add_sutinfo_row_ex_brief(tcsp, ptsp, ith, c, g, k, cp, gp, kp) {
    print "<Row>"
    add_sutinfo_cell(k)
    n1=length(tcsp)
    for(t1=1;t1<=n1;t1++) {
        n2=length(ptsp[t1])
        if (np==0) np=1
        for (p1=1;p1<=n2;p1++) {
            vv=""
            if (length(sutinfo_values[tcsp[t1]])>0)
                if (length(sutinfo_values[tcsp[t1]][ptsp[t1][p1]])>0) {
                    s=find_sutinfo_phost(tcsp[t1], ptsp[t1][p1])
                    if (ws_p_s_c_g_i(tcsp[t1],ptsp[t1][p1],s,cp,gp,1)>0)
                        vv=sutinfo_values[tcsp[t1]][ptsp[t1][p1]][s][cp][gp][1][kp]
                    if (ws_p_s_c_g_i(tcsp[t1],ptsp[t1][p1],s,c,g,1)>0)
                        vv=sutinfo_values[tcsp[t1]][ptsp[t1][p1]][s][c][g][1][k]
                }
            add_sutinfo_cell_ex(ith[t1][p1], vv)
        }
    }
    print "</Row>"
}

function add_sutinfo(ws) {
    print "<Worksheet ss:Name=\"" ws_name(ws"-INF") "\">"
    print "<Table>"

    add_sutinfo_row(ws, "Configuration", "Host", "Name", "perfspect", "Host", "Host Name")
    add_sutinfo_row(ws, "Configuration", "Host", "Time", "perfspect", "Host", "Time")
    add_sutinfo_row(ws, "Configuration", "System", "Manufacturer", "perfspect", "Host", "Manufacturer")
    add_sutinfo_row(ws, "Configuration", "System", "Product Name", "perfspect", "Host", "System")
    add_sutinfo_row(ws, "Configuration", "System", "Version", "perfspect", "Host", "Version")
    add_sutinfo_row(ws, "Configuration", "System", "Serial #", "perfspect", "Host", "Serial #")
    add_sutinfo_row(ws, "Configuration", "System", "UUID", "perfspect", "Host", "UUID")

    add_sutinfo_row(ws, "Configuration", "Baseboard", "Manufacturer", "perfspect", "Host", "Manufacturer")
    add_sutinfo_row(ws, "Configuration", "Baseboard", "Product Name", "perfspect", "Host", "System")
    add_sutinfo_row(ws, "Configuration", "Baseboard", "Version", "perfspect", "Baseboard", "Version")
    add_sutinfo_row(ws, "Configuration", "Baseboard", "Serial #", "perfspect", "Baseboard", "Serial #")
    
    add_sutinfo_row(ws, "Configuration", "Chassis", "Manufacturer", "perfspect", "Chassis", "Manufacturer")
    add_sutinfo_row(ws, "Configuration", "Chassis", "Type", "perfspect", "Chassis", "Type")
    add_sutinfo_row(ws, "Configuration", "Chassis", "Version", "perfspect", "Chassis", "Version")
    add_sutinfo_row(ws, "Configuration", "Chassis", "Serial #", "perfspect", "Chassis", "Serial #")

    add_sutinfo_row(ws, "Configuration", "BIOS", "Vendor", "perfspect", "BIOS", "Vendor")
    add_sutinfo_row(ws, "Configuration", "BIOS", "Version", "perfspect", "BIOS", "Version")
    add_sutinfo_row(ws, "Configuration", "BIOS", "Release Date", "perfspect", "BIOS", "Release Date")

    add_sutinfo_row(ws, "Configuration", "Operating System", "OS", "perfspect", "Operating System", "OS")
    add_sutinfo_row(ws, "Configuration", "Operating System", "Kernel", "perfspect", "Operating System", "Kernel")
    add_sutinfo_row(ws, "Configuration", "Operating System", "Microcode", "perfspect", "Operating System", "Microcode")

    add_sutinfo_row(ws, "Configuration", "Software Version", "GCC", "perfspect", "Software Version", "GCC")
    add_sutinfo_row(ws, "Configuration", "Software Version", "GLIBC", "perfspect", "Software Version", "GLIBC")
    add_sutinfo_row(ws, "Configuration", "Software Version", "Binutils", "perfspect", "Software Version", "Binutils")
    add_sutinfo_row(ws, "Configuration", "Software Version", "Python", "perfspect", "Software Version", "Python")
    add_sutinfo_row(ws, "Configuration", "Software Version", "Python3", "perfspect", "Software Version", "Python3")
    add_sutinfo_row(ws, "Configuration", "Software Version", "Java", "perfspect", "Software Version", "Java")
    add_sutinfo_row(ws, "Configuration", "Software Version", "OpenSSL", "perfspect", "Software Version", "OpenSSL")

    add_sutinfo_row(ws, "Configuration", "CPU", "CPU Model", "perfspect", "CPU", "CPU Model")
    add_sutinfo_row(ws, "Configuration", "CPU", "Architecture", "perfspect", "CPU", "Architecture")
    add_sutinfo_row(ws, "Configuration", "CPU", "Microarchitecture", "perfspect", "CPU", "Microarchitecture")
    add_sutinfo_row(ws, "Configuration", "CPU", "Family", "perfspect", "CPU", "Family")
    add_sutinfo_row(ws, "Configuration", "CPU", "Model", "perfspect", "CPU", "Model")
    add_sutinfo_row(ws, "Configuration", "CPU", "Stepping", "perfspect", "CPU", "Stepping")
    add_sutinfo_row(ws, "Configuration", "CPU", "Base Frequency", "perfspect", "CPU", "Base Frequency")
    add_sutinfo_row(ws, "Configuration", "CPU", "Maximum Frequency", "perfspect", "CPU", "Maximum Frequency")
    add_sutinfo_row(ws, "Configuration", "CPU", "All-core Maximum Frequency", "perfspect", "CPU", "All-core Maximum Frequency")
    add_sutinfo_row(ws, "Configuration", "CPU", "CPUs", "perfspect", "CPU", "CPUs")
    add_sutinfo_row(ws, "Configuration", "CPU", "On-line CPU List", "perfspect", "CPU", "On-line CPU List")
    add_sutinfo_row(ws, "Configuration", "CPU", "Hyperthreading", "perfspect", "CPU", "Hyperthreading")
    add_sutinfo_row(ws, "Configuration", "CPU", "Cores per Socket", "perfspect", "CPU", "Cores per Socket")
    add_sutinfo_row(ws, "Configuration", "CPU", "Sockets", "perfspect", "CPU", "Sockets")
    add_sutinfo_row(ws, "Configuration", "CPU", "NUMA Nodes", "perfspect", "CPU", "NUMA Nodes")
    add_sutinfo_row(ws, "Configuration", "CPU", "NUMA CPU List", "perfspect", "CPU", "NUMA CPU List")
    add_sutinfo_row(ws, "Configuration", "Uncore", "CHA Count", "perfspect", "Uncore", "CHA Count")
    add_sutinfo_row(ws, "Configuration", "Uncore", "Maximum Frequency", "perfspect", "Uncore", "Maximum Frequency")
    add_sutinfo_row(ws, "Configuration", "Uncore", "Minimum Frequency", "perfspect", "Uncore", "Minimum Frequency")
    add_sutinfo_row(ws, "Configuration", "CPU", "L1d Cache", "perfspect", "CPU", "L1d Cache")
    add_sutinfo_row(ws, "Configuration", "CPU", "L1i Cache", "perfspect", "CPU", "L1i Cache")
    add_sutinfo_row(ws, "Configuration", "CPU", "L2 Cache", "perfspect", "CPU", "L2 Cache")
    add_sutinfo_row(ws, "Configuration", "CPU", "L3 Cache", "perfspect", "CPU", "L3 Cache")
    add_sutinfo_row(ws, "Configuration", "CPU", "L3 per Core", "perfspect", "CPU", "L3 per Core")
    add_sutinfo_row(ws, "Configuration", "CPU", "Memory Channels", "perfspect", "CPU", "Memory Channels")
    add_sutinfo_row(ws, "Configuration", "CPU", "Prefetchers", "perfspect", "CPU", "Prefetchers")
    add_sutinfo_row(ws, "Configuration", "CPU", "Intel Turbo Boost", "perfspect", "CPU", "Intel Turbo Boost")
    add_sutinfo_row(ws, "Configuration", "CPU", "PPINs", "perfspect", "CPU", "PPINs")

    add_sutinfo_isa_summary(ws, "Configuration", "ISA", "Name", "CPU Support", "Kernel Support", "Yes", "perfspect", "ISA", "Yes")

    add_sutinfo_row(ws, "Brief", "Accelerator", "Accelerators Available [used]", "perfspect", "System Summary", "Accelerators Available [used]")

    add_sutinfo_row(ws, "Configuration", "Power", "TDP", "perfspect", "Power", "TDP")
    add_sutinfo_row(ws, "Configuration", "Power", "Power \\u0026 Perf Policy", "perfspect", "Power", "Energy Performance Bias")
    add_sutinfo_row(ws, "Configuration", "Power", "Frequency Governor", "perfspect", "Power", "Scaling Governor")
    add_sutinfo_row(ws, "Configuration", "Power", "Frequency Driver", "perfspect", "Power", "Scaling Driver")
    add_sutinfo_row(ws, "Configuration", "Power", "Max C-State", "perfspect", "System Summary", "C-states")

    add_sutinfo_row(ws, "Configuration", "Memory", "Installed Memory", "perfspect", "Memory", "Installed Memory")
    add_sutinfo_row(ws, "Configuration", "Memory", "MemTotal", "perfspect", "Memory", "MemTotal")
    add_sutinfo_row(ws, "Configuration", "Memory", "MemFree", "perfspect", "Memory", "MemFree")
    add_sutinfo_row(ws, "Configuration", "Memory", "MemAvailable", "perfspect", "Memory", "MemAvailable")
    add_sutinfo_row(ws, "Configuration", "Memory", "Buffers", "perfspect", "Memory", "Buffers")
    add_sutinfo_row(ws, "Configuration", "Memory", "Cached", "perfspect", "Memory", "Cached")
    add_sutinfo_row(ws, "Configuration", "Memory", "HugePages_Total", "perfspect", "Memory", "HugePages_Total")
    add_sutinfo_row(ws, "Configuration", "Memory", "Hugepagesize", "perfspect", "Memory", "Hugepagesize")
    add_sutinfo_row(ws, "Configuration", "Memory", "Transparent Huge Pages", "perfspect", "Memory", "Transparent Huge Pages")
    add_sutinfo_row(ws, "Configuration", "Memory", "Automatic NUMA Balancing", "perfspect", "Memory", "Automatic NUMA Balancing")
    add_sutinfo_row(ws, "Configuration", "Memory", "Populated Memory Channels", "perfspect", "Memory", "Populated Memory Channels")

    add_sutinfo_row(ws, "Configuration", "GPU", "Manufacturer", "perfspect", "GPU", "Manufacturer")
    add_sutinfo_row(ws, "Configuration", "GPU", "Model", "perfspect", "GPU", "Model")

    add_sutinfo_row(ws, "Brief", "NIC", "NIC", "perfspect", "System Summary", "NIC")
    add_sutinfo_row(ws, "Brief", "Disk", "Disk", "perfspect", "System Summary", "Disk")
    add_sutinfo_row(ws, "Brief", "Vulnerability", "Vulnerability", "perfspect", "System Summary", "CVEs")

    add_sutinfo_row(ws, "Configuration", "PMU", "cpu_cycles", "perfspect", "PMU", "cpu_cycles")
    add_sutinfo_row(ws, "Configuration", "PMU", "instructions", "perfspect", "PMU", "instructions")
    add_sutinfo_row(ws, "Configuration", "PMU", "ref_cycles", "perfspect", "PMU", "ref_cycles")
    add_sutinfo_row(ws, "Configuration", "PMU", "topdown_slots", "perfspect", "PMU", "topdown_slots")
    print "</Table>"
    print "</Worksheet>"
}

function add_sutinfo_ex(ws, psp, ith) {
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Host", "Name", "perfspect", "Host", "Host Name")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Host", "Time", "perfspect", "Host", "Time")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "System", "Manufacturer", "perfspect", "Host", "Manufacturer")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "System", "Product Name", "perfspect", "Host", "System")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "BIOS", "Version", "perfspect", "BIOS", "Version")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Operating System", "OS", "perfspect", "Operating System", "OS")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Operating System", "Kernel", "perfspect", "Operating System", "Kernel")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Operating System", "Microcode", "perfspect", "Operating System", "Microcode")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "CPU Model", "perfspect", "CPU", "CPU Model")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "Base Frequency", "perfspect", "CPU", "Base Frequency")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "Maximum Frequency", "perfspect", "CPU", "Maximum Frequency")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "All-core Maximum Frequency", "perfspect", "CPU", "All-core Maximum Frequency")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "CPUs", "perfspect", "CPU", "CPUs")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "Cores per Socket", "perfspect", "CPU", "Cores per Socket")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "Sockets", "perfspect", "CPU", "Sockets")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "NUMA Nodes", "perfspect", "CPU", "NUMA Nodes")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "Prefetchers", "perfspect", "CPU", "Prefetchers")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "Intel Turbo Boost", "perfspect", "CPU", "Intel Turbo Boost")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "CPU", "PPINs", "perfspect", "CPU", "PPINs")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Power", "Power \\u0026 Perf Policy", "perfspect", "Power", "Energy Performance Bias")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Power", "TDP", "perfspect", "Power", "TDP")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Power", "Frequency Driver", "perfspect", "Power", "Scaling Driver")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Power", "Frequency Governor", "perfspect", "Power", "Scaling Governor")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Power", "Max C-State", "perfspect", "System Summary", "C-states")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Memory", "Installed Memory", "perfspect", "Memory", "Installed Memory")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Memory", "Hugepagesize", "perfspect", "Memory", "Hugepagesize")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Memory", "Transparent Huge Pages", "perfspect", "Memory", "Transparent Huge Pages")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Memory", "Automatic NUMA Balancing", "perfspect", "Memory", "Automatic NUMA Balancing")
    add_sutinfo_row_ex(ws, psp, ith, "Brief", "NIC", "NIC", "perfspect", "System Summary", "NIC")
    add_sutinfo_row_ex(ws, psp, ith, "Brief", "Disk", "Disk", "perfspect", "System Summary", "Disk")
    add_sutinfo_row_ex(ws, psp, ith, "Configuration", "Vulnerability", "Vulnerability", "perfspect", "System Summary", "CVEs")
}

function add_sutinfo_brief(tcsp, ptsp, ith) {
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Configuration", "Host", "Name", "perfspect", "System Summary", "Host Name")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Configuration", "Host", "Time", "perfspect", "System Summary", "Time")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "System", "System", "perfspect", "System Summary", "System")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Chassis", "Chassis", "perfspect", "System Summary", "Chassis")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "CPU Model", "perfspect", "System Summary", "CPU Model")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "Microarchitecture", "perfspect", "System Summary", "Microarchitecture")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "Sockets", "perfspect", "System Summary", "Sockets")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "Cores per Socket", "perfspect", "System Summary", "Cores per Socket")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "Hyperthreading", "perfspect", "System Summary", "Hyperthreading")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "CPUs", "perfspect", "System Summary", "CPUs")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "Intel Turbo Boost", "perfspect", "System Summary", "Intel Turbo Boost")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "Base Frequency", "perfspect", "System Summary", "Base Frequency")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "All-core Maximum Frequency", "perfspect", "System Summary", "All-core Maximum Frequency")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "Maximum Frequency", "perfspect", "System Summary", "Maximum Frequency")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "NUMA Nodes", "perfspect", "System Summary", "NUMA Nodes")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "Prefetchers", "perfspect", "System Summary", "Prefetchers")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "CPU", "PPINs", "perfspect", "System Summary", "PPINs")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Accelerator", "Accelerators Available [used]", "perfspect", "System Summary", "Accelerators Available [used]")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Memory", "Installed Memory", "perfspect", "System Summary", "Installed Memory")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Memory", "Hugepagesize", "perfspect", "System Summary", "Hugepagesize")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Memory", "Transparent Huge Pages", "perfspect", "System Summary", "Transparent Huge Pages")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Memory", "Automatic NUMA Balancing", "perfspect", "System Summary", "Automatic NUMA Balancing")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "NIC", "NIC", "perfspect", "System Summary", "NIC")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Disk", "Disk", "perfspect", "System Summary", "Disk")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "BIOS", "BIOS", "perfspect", "System Summary", "BIOS")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "OS", "Microcode", "perfspect", "System Summary", "Microcode")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "OS", "Kernel", "perfspect", "System Summary", "Kernel")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Power", "TDP", "perfspect", "System Summary", "TDP")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Power", "Power \\u0026 Perf Policy", "perfspect", "System Summary", "Energy Performance Bias")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Power", "Frequency Governor", "perfspect", "System Summary", "Scaling Governor")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Power", "Frequency Driver", "perfspect", "System Summary", "Scaling Driver")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Power", "Max C-State", "perfspect", "System Summary", "C-states")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Vulnerability", "Vulnerability", "perfspect", "System Summary", "CVEs")
    add_sutinfo_row_ex_brief(tcsp, ptsp, ith, "Brief", "Marketing Claim", "System Summary", "perfspect", "System Summary", "System Summary")
}

