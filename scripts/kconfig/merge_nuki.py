#!/usr/bin/env python3
"""
merge_nuki.py - NUKI staged merge: base non-negotiable, middle stages, ending non-negotiable

Base keys are sacred: middle fragments cannot disable/overwrite base.
Ending fragments are final: they overwrite everything (base+middle).

Usage:
  merge_nuki.py --base ksu-nh.defconfig --middle consolidate.fragment defconfig.fragment moto-parrot-sm6450.config debug-parrot-genevn.config --ending debug_moto_parrot_genevn.config nurfs-linux.fragment -o out/.config

If --middle/--ending not given, falls back to positional: first is base, middle bulk, last 1-2 are ending (heuristic).
"""
import re, sys, argparse, pathlib

def parse_config(path):
    """return list of (raw_line, key, value) where value is 'y'/'m'/'n'/str or 'is not set' -> 'n' """
    entries=[]
    for line in pathlib.Path(path).read_text(errors='ignore').splitlines():
        s=line.strip()
        if not s or s.startswith('#') and 'CONFIG_' not in s:
            entries.append((line, None, None))
            continue
        m=re.match(r'^(CONFIG_[A-Za-z0-9_]+)=(.*)', line)
        if m:
            entries.append((line, m.group(1), m.group(2).strip()))
            continue
        m=re.match(r'^#\s*(CONFIG_[A-Za-z0-9_]+)\s+is not set', line)
        if m:
            entries.append((line, m.group(1), 'n'))
            continue
        entries.append((line, None, None))
    return entries

def key_of(line):
    m=re.match(r'^(CONFIG_[A-Za-z0-9_]+)=', line.strip())
    if m: return m.group(1)
    m=re.match(r'^#\s*(CONFIG_[A-Za-z0-9_]+)\s+is not set', line.strip())
    if m: return m.group(1)
    return None

def merge(base_paths, middle_paths, ending_paths, out_path):
    # Collect base keys as protected (skip missing)
    base_entries=[]
    for p in base_paths:
        if not pathlib.Path(p).exists():
            print(f"merge_nuki: skip missing base {p}", file=sys.stderr)
            continue
        base_entries.extend(parse_config(p))
    # Map base key -> final line (last occurrence within base files, deduped)
    base_map={}
    base_order=[]
    for raw,k,v in base_entries:
        if k:
            if k in base_map:
                # remove previous
                base_order = [x for x in base_order if x[0]!=k]
            base_map[k]=raw
            base_order.append((k,raw))
        else:
            base_order.append((None,raw))
    # dedup base_order for output later, but keep as base_map for protection

    # Middle: last-wins among themselves, but skip if key is in base_map and middle tries to set to n when base is y/m
    middle_map={}
    middle_order=[]
    for p in middle_paths:
        if not pathlib.Path(p).exists():
            print(f"merge_nuki: skip missing middle {p}", file=sys.stderr)
            continue
        for raw,k,v in parse_config(p):
            if not k:
                middle_order.append((None,raw))
                continue
            # if already in middle_map, remove previous middle occurrence
            if k in middle_map:
                middle_order = [x for x in middle_order if x[0]!=k]
            middle_map[k]=raw
            middle_order.append((k,raw))

    # Build intermediate: base protected + middle that doesn't clobber base
    # For each middle key, if it's in base_map, compare: if base is y/m and middle is n (is not set), skip middle (keep base)
    # Otherwise, if middle is y/m and base is y/m, middle is same so skip (keep base) - base wins anyway
    # If middle introduces new key not in base, keep it
    # If middle has same key but different non-n value, keep base (non-negotiable)
    final_map=dict(base_map)
    final_order=list(base_order)  # copy

    for k,raw in middle_order:
        if k is None:
            final_order.append((k,raw))
            continue
        if k in base_map:
            # base is sacred: ignore middle's attempt to change it
            # We keep base_map[k], do not overwrite
            continue
        else:
            # new key from middle: add, but dedup if already added from earlier middle
            if k in final_map:
                # remove previous occurrence from final_order if it was from middle
                final_order = [x for x in final_order if x[0]!=k]
            final_map[k]=raw
            final_order.append((k,raw))

    # Ending: unconditional last-wins, overwrites everything
    for p in ending_paths:
        if not pathlib.Path(p).exists():
            print(f"merge_nuki: skip missing ending {p}", file=sys.stderr)
            continue
        for raw,k,v in parse_config(p):
            if not k:
                final_order.append((k,raw))
                continue
            if k in final_map:
                final_order = [x for x in final_order if x[0]!=k]
            final_map[k]=raw
            final_order.append((k,raw))

    # Rebuild output: iterate final_order, skip None keys, emit raw lines
    # Need to dedup final_order to last occurrence already done, now emit
    seen=set()
    out_lines=[]
    # We need to emit in order of last occurrence: final_order already is in order of last occurrence due to removals
    for k,raw in final_order:
        if k and k in seen:
            continue
        if k:
            seen.add(k)
        out_lines.append(raw)

    pathlib.Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    pathlib.Path(out_path).write_text("\n".join(out_lines)+"\n")
    print(f"merge_nuki: base={len(base_paths)} middle={len(middle_paths)} ending={len(ending_paths)} -> {len([k for k,_ in final_order if k])} CONFIGs, {len(out_lines)} lines -> {out_path}")

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("--base", nargs="+", default=[])
    ap.add_argument("--middle", nargs="+", default=[])
    ap.add_argument("--ending", nargs="+", default=[])
    ap.add_argument("-o", required=True)
    ap.add_argument("positional", nargs="*", help="fallback: first 1 is base, middle bulk, last 2 are ending if no -- flags")
    args=ap.parse_args()
    if not args.base and args.positional:
        # heuristic: first is base, last 2 are ending, middle is rest
        if len(args.positional) >=3:
            args.base=[args.positional[0]]
            args.ending=args.positional[-2:]
            args.middle=args.positional[1:-2]
        else:
            args.base=[args.positional[0]]
            args.middle=args.positional[1:]
    merge(args.base, args.middle, args.ending, args.o)
