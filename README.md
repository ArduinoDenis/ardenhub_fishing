# 🎣 ArDenHub Fishing Script  
Sistema di pesca avanzato per FiveM ESX — **accessibile a tutti i giocatori, senza whitelist o job dedicati**.

Un’esperienza di pesca completa, realistica e completamente configurabile, basata su **ESX**, **ox_lib**, **ox_inventory** e **ox_target**.

---

## ✨ Funzionalità Principali

- **Accessibile a tutti** — nessun job richiesto
- **Skillcheck ox_lib** per una pesca dinamica e coinvolgente
- **5 tipi di pesci** con rarità, prezzi e pesi variabili
- **4 zone di pesca personalizzabili**
- **Sistema di vendita dinamico** con bonus notturno (+20%)
- **Negozio dedicato** per canne da pesca ed esche
- **Anti-exploit integrato** (cooldown, spam, eventi non autorizzati)
- **Log Discord opzionali**
- **Markers, blips e NPC configurabili**
- **Compatibile con ox_target**
- **Completamente configurabile** tramite `config.lua`

---

## 📋 Requisiti

- [ESX Legacy](https://github.com/esx-framework/esx-legacy)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [oxmysql](https://github.com/overextended/oxmysql)

---

## 📦 Installazione

### 1. Inserisci la risorsa
Posiziona la cartella nella directory:

```
resources/[esx]/ardenhub_fishing/
```

### 2. Aggiungi gli items a ox_inventory

Modifica `ox_inventory/data/items.lua` aggiungendo:

```lua
['fishingrod'] = {
    label = 'Canna da Pesca',
    weight = 2000,
    stack = false,
    close = true,
    description = 'Una canna da pesca professionale'
},

['fishbait'] = {
    label = 'Esca',
    weight = 50,
    stack = true,
    close = true,
    description = 'Esca per pescare'
},

['anchovy'] = {
    label = 'Acciuga',
    weight = 200,
    stack = true,
    close = true,
    description = 'Un\'acciuga fresca'
},

['trout'] = {
    label = 'Trota',
    weight = 500,
    stack = true,
    close = true,
    description = 'Una trota fresca'
},

['salmon'] = {
    label = 'Salmone',
    weight = 800,
    stack = true,
    close = true,
    description = 'Un salmone fresco'
},

['tuna'] = {
    label = 'Tonno',
    weight = 3000,
    stack = true,
    close = true,
    description = 'Un tonno fresco'
},

['swordfish'] = {
    label = 'Pesce Spada',
    weight = 8000,
    stack = true,
    close = true,
    description = 'Un pesce spada leggendario!'
},
```

### 3. Aggiungi le immagini degli items

Copia le immagini da:

```
items-images/
```

a:

```
ox_inventory/web/images/
```

### 4. Aggiungi al server.cfg

```cfg
ensure ardenhub_fishing
```

### 5. Riavvia il server

```bash
restart ardenhub_fishing
```

---

## 🎮 Gameplay

### 1. Acquista l’attrezzatura 🏪
- Canna da pesca
- Esche (10 per $50)

### 2. Vai in una zona di pesca 🎣
- Entra nell’area segnata
- Premi **E** per iniziare
- Completa lo skillcheck per catturare il pesce

### 3. Vendi il pescato 💰
- Recati al mercato del pesce
- Bonus notturno: **+20%** dalle 22:00 alle 06:00

---

## 🐟 Tipologie di Pesce

| Pesce | Rarità | Probabilità | Prezzo | Peso |
|-------|--------|-------------|--------|------|
| Acciuga | Comune | 40% | $25–45 | 0.1–0.8 kg |
| Trota | Non Comune | 30% | $50–75 | 0.5–2.5 kg |
| Salmone | Non Comune | 20% | $70–100 | 1.0–4.0 kg |
| Tonno | Raro | 8% | $120–180 | 3.0–10.0 kg |
| Pesce Spada | Leggendario | 2% | $250–400 | 8.0–20.0 kg |

---

## 📍 Posizioni

### Zone di Pesca
- **Molo della Spiaggia** — `-1849.68, -1250.14, 8.62`
- **Lago Alamo** — `1301.19, 4218.46, 33.91` *(+30% rarità)*
- **Molo di Chumash** — `-3428.19, 968.53, 8.35` *(+10% rarità)*
- **Pier del Pacifico** — `-1850.28, -1248.13, 8.62`

### Negozi e Mercati
- **Negozio di Pesca** — `-1592.07, 5202.9, 4.31`
- **Mercato del Pesce** — `-1038.45, -1397.97, 5.55`

---

## ⚙️ Configurazione

Tutto è gestito tramite `config.lua`:

- Prezzi e probabilità
- Zone di pesca
- Bonus notturno
- Cooldown
- Difficoltà skillcheck
- Webhook Discord
- Anti-exploit

### Esempio Webhook

```lua
Config.Webhooks = {
    enabled = true,
    url = "IL_TUO_WEBHOOK_URL",
    logFishing = true,
    logSelling = true,
    logPurchases = true
}
```

---

## 🛡️ Sistema Anti-Exploit

Protezione contro:
- Spam azioni
- Eventi non autorizzati
- Bypass cooldown
- Duplicazione items

```lua
Config.AntiExploit = {
    enabled = true,
    maxActionsPerMinute = 15,
    kickOnExploit = true,
    logToDiscord = true
}
```

---

## 🛠️ Personalizzazione

### Aggiungere nuovi pesci

```lua
{
    name = "Nome Pesce",
    item = "nome_item",
    rarity = "comune/non comune/raro/leggendario",
    chance = 10,
    price = {min = 50, max = 100},
    weight = {min = 1.0, max = 5.0}
}
```

### Aggiungere nuove zone

```lua
{
    name = "Nome Zona",
    coords = vector3(x, y, z),
    radius = 50.0,
    rarityBonus = 1.0,
    blip = {
        enabled = true,
        sprite = 68,
        color = 38,
        scale = 0.7,
        label = "🎣 Zona di Pesca"
    }
}
```

---

## ❓ Troubleshooting

- **Non puoi pescare**: controlla canna, esche e cooldown  
- **Items mancanti**: verifica `items.lua` e riavvia ox_inventory  
- **NPC non visibili**: controlla ox_target e coordinate  
- **Errori console**: verifica dipendenze e ordine di avvio  

---

## 🔄 Roadmap

- [ ] Sistema livelli pescatore  
- [ ] Missioni giornaliere  
- [ ] Tornei di pesca  
- [ ] Pesci stagionali  
- [ ] Crafting esche speciali  
- [ ] Supporto barche da pesca  

---

## 📄 Licenza

Rilasciato sotto licenza **MIT**. Consulta il file `LICENSE`.

---

## 💬 Supporto

- Apri una issue su GitHub  
- Entra nel server Discord ufficiale  
- Contact the author on [Discord Official](https://link.arduinodenis.it/discord)

## 👨‍💻 Author

Created by [ArduinoDenis](https://arduinodenis.it)

---

## 🙏 Credits

- **ESX Framework**  
- **Overextended** (ox_lib, ox_target, ox_inventory)
