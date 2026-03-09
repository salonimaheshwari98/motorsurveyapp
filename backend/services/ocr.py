import re
from typing import List, Dict


class OCRService:
    @staticmethod
    def parse_estimate_text(text: str) -> List[Dict]:
        lines = text.splitlines()
        parts = []
        for line in lines:
            line = line.strip()
            if not line:
                continue
            tokens = re.split(r"\s+", line)
            if len(tokens) < 4:
                continue
            try:
                amount = float(tokens[-1])
                rate = float(tokens[-2])
                quantity = int(tokens[-3])
                name = " ".join(tokens[:-3])
                parts.append({
                    "part_name": name,
                    "quantity": quantity,
                    "rate": rate,
                    "amount": amount,
                })
            except ValueError:
                continue
        return parts
