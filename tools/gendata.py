#!/usr/bin/env python3
"""Generate a deterministic CLEARPOINT test data set."""

import argparse
import datetime as dt
import random
from pathlib import Path

NETWORK_PREFIXES = {"VISA": "4", "MCRD": "51", "AMEX": "37", "DISC": "6011"}
NETWORK_WEIGHTS = [("VISA", 50), ("MCRD", 30), ("AMEX", 12), ("DISC", 8)]

PRODUCTS = {
    "PLAT": (1_500_000, 5_000_000),
    "GOLD": (500_000, 1_500_000),
    "CLSC": (100_000, 500_000),
}
PRODUCT_WEIGHTS = [("PLAT", 15), ("GOLD", 35), ("CLSC", 50)]

MERCHANT_MCCS = [
    (5411, "FRESHWAY GROCERY"), (5499, "CORNER MARKET"),
    (5541, "QUIKFUEL"), (5542, "PUMP AND GO"),
    (4511, "SKYLINE AIR"), (7011, "HARBOR HOTEL"),
    (4111, "METRO TRANSIT"), (3058, "COASTAL AIRWAYS"),
    (5812, "BISTRO 41"), (5814, "BURGER BARN"),
    (4900, "CITY POWER AND WATER"), (5311, "VALUE DEPOT"),
    (5651, "THREADS APPAREL"), (5732, "CIRCUIT CITY ELEC"),
    (5912, "WELLCARE PHARMACY"), (5942, "PAGE TURNER BOOKS"),
    (5999, "GENERAL STORE"), (7832, "STARLIGHT CINEMA"),
]
CITIES = [
    ("CHARLOTTE", "NC"), ("DALLAS", "TX"), ("PHOENIX", "AZ"),
    ("COLUMBUS", "OH"), ("DENVER", "CO"), ("TAMPA", "FL"),
    ("OMAHA", "NE"), ("BOISE", "ID"), ("RICHMOND", "VA"),
]

ERROR_KINDS = [
    "luhn", "nonnumeric_amount", "zero_amount", "large_amount",
    "currency", "bad_date", "future_date", "stale_date", "bad_time",
    "no_auth", "bad_type", "bad_entry", "unknown_card",
    "unknown_merchant", "duplicate",
]


def weighted(rng, pairs):
    total = sum(w for _, w in pairs)
    pick = rng.uniform(0, total)
    upto = 0
    for value, weight in pairs:
        upto += weight
        if pick <= upto:
            return value
    return pairs[-1][0]


def luhn_digit(partial):
    total = 0
    for i, ch in enumerate(reversed(partial)):
        d = int(ch)
        if i % 2 == 0:
            d *= 2
            if d > 9:
                d -= 9
        total += d
    return str((10 - total % 10) % 10)


def card_number(rng, network):
    prefix = NETWORK_PREFIXES[network]
    body = prefix + "".join(rng.choice("0123456789")
                            for _ in range(15 - len(prefix)))
    return body + luhn_digit(body)


def alpha(value, width):
    return str(value)[:width].ljust(width)


def num(value, width):
    text = str(int(value))
    if len(text) > width:
        raise ValueError(f"{value} does not fit in {width} digits")
    return text.zfill(width)


def signed(cents, digits=11):
    sign = "-" if cents < 0 else "+"
    return sign + num(abs(cents), digits)


def ymd(day):
    return day.strftime("%Y%m%d")


def write_fixed(path, records, lrecl):
    with open(path, "wb") as handle:
        for rec in records:
            if len(rec) != lrecl:
                raise ValueError(f"{path.name}: record length {len(rec)}"
                                 f" expected {lrecl}: {rec!r}")
            handle.write(rec.encode("ascii"))


def build_accounts(rng, count, bus_date):
    accounts = []
    for i in range(count):
        acct = num(100000000000 + i * 17, 12)
        product = weighted(rng, PRODUCT_WEIGHTS)
        low, high = PRODUCTS[product]
        limit = rng.randrange(low, high, 50_000)
        status = weighted(rng, [("A", 94), ("C", 2), ("F", 2), ("W", 2)])
        accounts.append({
            "acct": acct,
            "cust": "C" + num(rng.randrange(10**8, 10**9), 9),
            "product": product,
            "status": status,
            "open": ymd(bus_date - dt.timedelta(days=rng.randrange(60, 4000))),
            "limit": limit,
            "cash_limit": limit * 3 // 10,
            "balance": rng.randrange(0, limit * 6 // 10),
            "cash_balance": rng.choice([0, 0, 0, 10_000, 25_000]),
            "network": weighted(rng, NETWORK_WEIGHTS),
        })
    return accounts


def account_record(a, bus_date):
    rec = (alpha(a["acct"], 12) + alpha(a["cust"], 10)
           + alpha(a["product"], 4) + a["status"] + a["open"]
           + signed(a["limit"]) + signed(a["cash_limit"])
           + signed(a["balance"]) + signed(a["cash_balance"])
           + signed(0) + signed(0) + num(0, 7)
           + ymd(bus_date - dt.timedelta(days=1)))
    return rec.ljust(200)


def build_cards(rng, accounts, bus_date):
    cards = []
    seen = set()
    for a in accounts:
        for _ in range(rng.choice([1, 1, 1, 2])):
            while True:
                pan = card_number(rng, a["network"])
                if pan not in seen:
                    seen.add(pan)
                    break
            status = weighted(rng, [("A", 96), ("L", 2), ("C", 2)])
            if rng.random() < 0.01:
                expiry = (bus_date.year - 1) * 100 + rng.randrange(1, 13)
            else:
                expiry = (bus_date.year + rng.randrange(1, 5)) * 100 \
                    + rng.randrange(1, 13)
            cards.append({"pan": pan, "acct": a["acct"], "status": status,
                          "expiry": expiry, "network": a["network"]})
    cards.sort(key=lambda c: c["pan"])
    return cards


def card_record(c):
    rec = (c["pan"] + alpha(c["acct"], 12) + c["status"]
           + num(c["expiry"], 6))
    return rec.ljust(50)


def build_merchants(rng, count):
    merchants = []
    for i in range(count):
        mcc, name = rng.choice(MERCHANT_MCCS)
        city, state = rng.choice(CITIES)
        merchants.append({
            "id": "M" + num(i + 1, 14),
            "name": f"{name} {i + 1:04d}",
            "mcc": mcc,
            "city": city,
            "state": state,
            "status": "T" if rng.random() < 0.01 else "A",
        })
    for j in range(max(5, count // 50)):
        city, state = rng.choice(CITIES)
        merchants.append({
            "id": "M" + num(count + j + 1, 14),
            "name": f"ATM NETWORK {j + 1:04d}",
            "mcc": 6011,
            "city": city,
            "state": state,
            "status": "A",
        })
    return merchants


def merchant_record(m):
    rec = (alpha(m["id"], 15) + alpha(m["name"], 25) + num(m["mcc"], 4)
           + alpha(m["city"], 15) + m["state"] + "USA" + m["status"])
    return rec.ljust(100)


def build_fee_schedule(bus_date):
    eff = "20250101"
    future = ymd(bus_date + dt.timedelta(days=30))
    rows = []
    base = {"VISA": (151, 10), "MCRD": (158, 10),
            "AMEX": (230, 0), "DISC": (156, 10)}
    for network, (bps, per_item) in base.items():
        rows.append((network, "****", "**", "*", bps, per_item, 0, eff))
        rows.append((network, "****", "CA", "*", 0, 50, 0, eff))
        rows.append((network, "****", "FU", "*", bps - 20, 5, 95, eff))
        rows.append((network, "****", "SM", "*", bps - 30, 5, 0, eff))
        rows.append((network, "****", "UT", "*", 100, 0, 150, eff))
        rows.append((network, "****", "TR", "N", bps + 40, 10, 0, eff))
        rows.append((network, "****", "RS", "*", bps + 10, 10, 0, eff))
        rows.append((network, "PLAT", "**", "*", bps + 70, 10, 0, eff))
        rows.append((network, "PLAT", "TR", "*", bps + 90, 10, 0, eff))
        rows.append((network, "GOLD", "**", "*", bps + 20, 10, 0, eff))
        rows.append((network, "GOLD", "SM", "P", bps - 25, 5, 0, eff))
    rows.append(("VISA", "PLAT", "GN", "N", 260, 10, 0, future))
    rows.sort(key=lambda r: (r[0] + r[1] + r[2] + r[3]).encode("ascii"))
    records = []
    for network, product, mcc_class, presence, bps, per_item, cap, eff_dt \
            in rows:
        rec = (network + product + mcc_class + presence
               + num(bps, 5) + num(per_item, 5) + num(cap, 7) + eff_dt)
        records.append(rec.ljust(80))
    return records


def transaction_amount(rng, tran_type):
    if tran_type == "CA":
        return rng.choice([2000, 4000, 6000, 10000, 20000, 40000])
    band = rng.random()
    if band < 0.55:
        return rng.randrange(150, 6000)
    if band < 0.90:
        return rng.randrange(6000, 30000)
    if band < 0.99:
        return rng.randrange(30000, 250000)
    return rng.randrange(250000, 1500000)


def build_transactions(rng, count, bus_date, cards, merchants):
    regular = [m for m in merchants if m["mcc"] != 6011]
    atms = [m for m in merchants if m["mcc"] == 6011]
    details = []
    last_good = None
    for seq in range(1, count + 1):
        tran_type = weighted(rng, [("PU", 85), ("RF", 6),
                                   ("CA", 5), ("RV", 4)])
        card = rng.choice(cards)
        merchant = rng.choice(atms if tran_type == "CA" else regular)
        tran_day = bus_date - dt.timedelta(days=rng.randrange(0, 5))
        fields = {
            "id": "T" + ymd(bus_date) + num(seq, 7),
            "card": card["pan"],
            "merchant": merchant["id"],
            "type": tran_type,
            "amount": num(transaction_amount(rng, tran_type), 11),
            "currency": "USD",
            "date": ymd(tran_day),
            "time": f"{rng.randrange(24):02d}{rng.randrange(60):02d}"
                    f"{rng.randrange(60):02d}",
            "auth": "".join(rng.choice("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
                            for _ in range(6)),
            "entry": weighted(rng, [("05", 45), ("07", 30),
                                    ("81", 20), ("01", 5)]),
            "network": card["network"],
        }
        if tran_type == "CA":
            fields["entry"] = "05"
        if rng.random() < 0.035:
            kind = rng.choice(ERROR_KINDS)
            if kind == "duplicate" and last_good is not None:
                details.append(dict(last_good))
                continue
            inject_error(rng, kind, fields, bus_date)
        else:
            last_good = fields
        details.append(fields)
    return details


def inject_error(rng, kind, f, bus_date):
    if kind == "luhn":
        last = int(f["card"][-1])
        f["card"] = f["card"][:-1] + str((last + 1) % 10)
    elif kind == "nonnumeric_amount":
        f["amount"] = "00000012A50"
    elif kind == "zero_amount":
        f["amount"] = num(0, 11)
    elif kind == "large_amount":
        f["amount"] = num(rng.randrange(5_000_001, 9_000_000), 11)
    elif kind == "currency":
        f["currency"] = rng.choice(["EUR", "GBP", "CAD"])
    elif kind == "bad_date":
        f["date"] = f"{bus_date.year}1340"
    elif kind == "future_date":
        f["date"] = ymd(bus_date + dt.timedelta(days=rng.randrange(1, 5)))
    elif kind == "stale_date":
        f["date"] = ymd(bus_date - dt.timedelta(days=rng.randrange(40, 90)))
    elif kind == "bad_time":
        f["time"] = "256199"
    elif kind == "no_auth":
        f["type"] = "PU"
        f["auth"] = ""
    elif kind == "bad_type":
        f["type"] = "XX"
    elif kind == "bad_entry":
        f["entry"] = "99"
    elif kind == "unknown_card":
        f["card"] = card_number(rng, f["network"])
    elif kind == "unknown_merchant":
        f["merchant"] = "X" + num(rng.randrange(10**13), 14)


def detail_record(f):
    rec = ("D" + alpha(f["id"], 16) + alpha(f["card"], 16)
           + alpha(f["merchant"], 15) + alpha(f["type"], 2)
           + alpha(f["amount"], 11) + alpha(f["currency"], 3)
           + alpha(f["date"], 8) + alpha(f["time"], 6)
           + alpha(f["auth"], 6) + alpha(f["entry"], 2)
           + alpha(f["network"], 4))
    return rec.ljust(150)


def transaction_file(details, bus_date):
    header = ("H" + "CPTRAN  " + ymd(bus_date) + "ACQGW01 ").ljust(150)
    records = [header]
    hash_total = 0
    for f in details:
        records.append(detail_record(f))
        if f["amount"].isdigit():
            hash_total += int(f["amount"])
    trailer = ("T" + num(len(details), 9) + num(hash_total, 15)).ljust(150)
    records.append(trailer)
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--business-date", default="20261108")
    parser.add_argument("--transactions", type=int, default=20000)
    parser.add_argument("--seed", type=int, default=20261108)
    args = parser.parse_args()

    rng = random.Random(args.seed)
    bus_date = dt.datetime.strptime(args.business_date, "%Y%m%d").date()
    args.out.mkdir(parents=True, exist_ok=True)

    accounts = build_accounts(rng, max(200, args.transactions // 8),
                              bus_date)
    cards = build_cards(rng, accounts, bus_date)
    merchants = build_merchants(rng, max(100, args.transactions // 40))
    details = build_transactions(rng, args.transactions, bus_date,
                                 cards, merchants)

    write_fixed(args.out / "ACCTEXT.dat",
                [account_record(a, bus_date) for a in accounts], 200)
    write_fixed(args.out / "CARDXREF.dat",
                [card_record(c) for c in cards], 50)
    write_fixed(args.out / "MERCHANT.dat",
                [merchant_record(m) for m in merchants], 100)
    write_fixed(args.out / "FEESCHED.dat", build_fee_schedule(bus_date), 80)
    write_fixed(args.out / "TRANIN.dat",
                transaction_file(details, bus_date), 150)

    print(f"accounts={len(accounts)} cards={len(cards)} "
          f"merchants={len(merchants)} transactions={len(details)}")


if __name__ == "__main__":
    main()
