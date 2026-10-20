# ChessLume — prototipo mobile di scacchi

Progetto Flutter multipiattaforma (Android + iOS) con interfaccia moderna, partita locale a due giocatori, mosse legali, cronologia mosse, annullamento, promozione pedone e temi chiaro/scuro.

## Nota sullo stato del progetto
Questo è un prototipo sorgente, non una release pronta per gli store. Prima della pubblicazione servono test su dispositivi reali, icone/screenshot, privacy policy, schede store, eventuale account sviluppatore, e una revisione completa delle regole e dei flussi.

## Requisiti
- Flutter stable recente
- Android Studio + Android SDK per Android
- Xcode su macOS per compilare iOS
- Connessione internet al primo `flutter pub get`

## Avvio
Da terminale nella cartella del progetto:
```bash
flutter pub get
flutter run
```

## Build
Android APK:
```bash
flutter build apk --release
```
Android App Bundle per Google Play:
```bash
flutter build appbundle --release
```
iOS (richiede macOS e Xcode):
```bash
flutter build ios --release
```

## Funzioni MVP
- Scacchiera responsive con coordinate.
- Tocca un pezzo e poi la casella di destinazione.
- Evidenzia mosse legali e ultima mossa.
- Partita locale per due persone sullo stesso dispositivo.
- Cronologia delle mosse in notazione algebrica semplice.
- Annulla ultima mossa e nuova partita.
- Promozione del pedone a donna automatica (versione MVP).
- Tema scuro elegante.

## Monetizzazione consigliata
Per un gioco di scacchi, non è realistico garantire vendite o successo. Un MVP dovrebbe prima validare retention e feedback. Monetizzazione possibile in seguito: temi/scacchiere premium, puzzle pack, analisi avanzata o abbonamento; evita pay-to-win e pubblicità invasiva. Prima di integrare pagamenti o ads, aggiungere le SDK ufficiali e rispettare le policy degli store.
