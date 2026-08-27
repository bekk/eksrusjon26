# Bekk Beach Club

Invitasjonssiden til Bekk Beach Club. Laget av festkomiteen.

## Kjør lokalt

```bash
npm install
npm run dev
```

Åpne http://localhost:3000

## Struktur

```
app/page.js       hele siden
app/globals.css   styling
app/data.json     innhold (drinker, meny, bilder)
```

Alt innhold ligger i `data.json`. Endrer du der, endrer siden seg.

## Om workshopen

Denne siden er utgangspunktet. Den fungerer, men den er ikke bra.
Oppgaven er å bruke en AI-assistent til å gjøre den bedre — og å se
hva som faktisk blir bedre, hva som blir verre, og hva assistenten
ikke oppdager med mindre du ber den om det.

Noen ting å se etter:

- Hvordan ser siden ut på mobil?
- Kan du bruke skjemaet med kun tastatur?
- Er teksten lesbar? All teksten?
- Hva skjer når du trykker "Send"?
- Er tallene formatert riktig for norske brukere?
- Hva skjer med siden hvis `data.json` er tom?

## Deploy

Vercel, uten konfigurasjon. `npm run build` tar under 30 sekunder.
