def calculate_depreciation(material_type: str, age_years: float) -> float:
    mt = material_type.lower()
    if 'metal' in mt:
        if age_years < 0.5:
            return 0.0
        if age_years < 1:
            return 5.0
        if age_years < 2:
            return 10.0
        if age_years < 3:
            return 15.0
        if age_years < 4:
            return 25.0
        if age_years < 5:
            return 35.0
        if age_years < 10:
            return 40.0
        return 50.0
    if any(x in mt for x in ['plastic', 'rubber', 'battery', 'tyre']):
        return 50.0
    if 'glass' in mt:
        return 0.0
    if 'labour' in mt or 'paint' in mt:
        return 0.0
    return 0.0


def apply_depreciation(rate: float, material_type: str, age_years: float) -> float:
    percent = calculate_depreciation(material_type, age_years)
    return rate * (1 - percent / 100)
