.pragma library

function normalize(value) {
    return (value ?? "").toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

function score(term, text) {
    if (term === text) return 0;
    if (text.startsWith(term)) return 1;
    const start = text.indexOf(term);
    if (start >= 0) return 5 + Math.min(start, 20) / 10;

    let offset = 0;
    let gaps = 0;
    for (const char of term) {
        const match = text.indexOf(char, offset);
        if (match < 0) return Infinity;
        gaps += match - offset;
        offset = match + 1;
    }
    return 10 + Math.min(gaps, 40) / 10;
}

function search(entries, query, label, keywords) {
    const terms = normalize(query).trim().split(/\s+/).filter(Boolean);
    if (!terms.length) return entries.slice();
    return entries.map(entry => {
        const name = normalize(label(entry));
        const fields = (keywords ? keywords(entry) : []).map(normalize);
        const rank = terms.reduce((total, term) => total + Math.min(
            score(term, name), ...fields.map(field => 20 + score(term, field))), 0);
        return { entry, rank };
    }).filter(result => Number.isFinite(result.rank))
        .sort((a, b) => a.rank - b.rank || label(a.entry).localeCompare(label(b.entry)))
        .map(result => result.entry);
}
