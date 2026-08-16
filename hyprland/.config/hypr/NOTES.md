# Note sulla conversione a Lua

## Cosa NON è stato convertito (e perché)

`hyprlock.conf`, `hypridle.conf`, `hyprpaper.conf`, `hyprtoolkit.conf`
restano in hyprlang classico. Il team di Hyprland ha dichiarato che questi
tool satellite (hyprlock, hypridle, ecc.) continueranno a usare hyprlang
come config language, perché sono abbastanza semplici da non richiedere un
linguaggio Turing-completo. Solo `hyprland.conf` e i file che sorgeva sono
stati portati a Lua.

## Come installare

1. Copia tutti i file `.lua` in `~/.config/hypr/` (stesso posto dove
   avevi i `.conf`).
2. Hyprland, se trova `hyprland.lua`, lo carica al posto di
   `hyprland.conf` automaticamente -- non serve nessun flag. Se vuoi tenere
   entrambe le versioni per sicurezza, rinomina temporaneamente
   `hyprland.conf` (es. `hyprland.conf.bak`) così non c'è ambiguità.
3. `hyprctl reload` per applicare senza riavviare la sessione.

## Cose da verificare / a rischio di essere sbagliate

L'API Lua (`hl.*`) è uscita con la 0.55 (9 maggio 2026) e a metà agosto
2026 la documentazione è ancora incompleta in alcuni punti (lamentele della
community su Reddit riguardo alla doc del 0.55). Ho segnato nei file con
commenti i punti più incerti, in particolare:

- **`keybindings.lua`**: i dispatcher "tipizzati" confermati dalla wiki
  sono `hl.dsp.exec_cmd`, `hl.dsp.window.close/float/fullscreen`,
  `hl.dsp.focus({direction=...})`. Per tutto il resto (cambio workspace,
  movetoworkspace, i comandi `layoutmsg` dello scrolling layout, i bind
  mouse tipo `bindm`) ho usato un fallback che richiama `hyprctl dispatch`
  con il nome classico del dispatcher -- funziona sempre, ma non è lo stile
  "nativo" Lua. Man mano che la pagina
  https://wiki.hypr.land/Configuring/Dispatchers/ si completa, conviene
  sostituirli con le chiamate tipizzate.
- **`input.lua`**: la sintassi esatta per il blocco `device { ... }`
  (mouse specifico) via `hl.config()` non l'ho trovata confermata da
  nessuna fonte -- verifica su
  https://wiki.hypr.land/Configuring/Variables/#input.
- **`monitors.lua`**: `hl.get_monitors()` potrebbe non vedere ancora i
  monitor collegati nel momento esatto in cui il file viene valutato al
  primo avvio (vedi discussione GitHub linkata nei commenti). Ho lasciato
  un fallback alternativo basato su hostname, commentato in fondo al file.

## Il vantaggio dell'if/else automatico sui monitor

`monitors.lua` ora riconosce da solo quale profilo applicare:

- entrambi i monitor (DP-1 + DP-2) collegati → setup desktop completo
- solo DP-1 → posizionato da solo
- solo DP-2 → posizionato da solo
- nessuno dei due (es. portatile con schermo interno, o macchina diversa)
  → fallback generico con `mode = "preferred"`, `position/scale = "auto"`

Così le stesse dotfiles funzionano sia sulla postazione doppio-monitor sia
altrove, senza dover commentare/scommentare righe a mano.
