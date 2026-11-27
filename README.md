# 🛡️ XJ Tunnel VPN

An exact, 1:1 pixel-perfect reproduction of **XJ Tunnel VPN** (NoobDEV Build) built with Flutter 3. All screens, colors, typography, models, dialogs, drawers, and interactive behaviors have been implemented from A to Z to match the design.

---

## 📸 Implemented Screens & Features

### 1. Main Home Screen (`XjHomeScreen`)
- **Vivid Green App Bar** (`#43A047`) with Hamburger menu (`☰`), title **"XJ Tunnel VPN"**, Refresh/Sync button, Notification Bell, and 3-dots popup menu.
- **Top Tab Bar**: `HOME` (active with bold text and green indicator bar) and `LOGS` (with instant tab switching).
- **White Rounded Card**:
  - **Network & Live Traffic**: `NetWork: mobily [SA]`, live fluctuating upload (`↑ 24.29 KB`) and download (`↓ 52.18 KB`) with green circular badges.
  - **Protocol / Server Selector Box**: Saudi Arabia flag, `OVPN` bold title, `Stable | Fast | Universal` subtitle, and dark green `OVPN` pill badge. Tapping opens the protocol selector modal.
  - **Status & Custom Setup**: `Status: Connected` in bright green, with `Custom Setup` label and toggle switch.
  - **Payload / Network Selector Box**: Mobily blue logo, `🇸🇦 KSA | Mobily FreeNet ❤️ ✈`, and `Working | Promo | 0 Credit`. Tapping opens the payload selection modal.
  - **Big Action Button**: Full-width stadium button with rich green gradient (`#43A047` to `#2E7D32`), bold white text `STOP` (or `START`), toggles connection state.
  - **Time Left & Add 2hrs Row**: Cyan/blue stopwatch icon with speed lines, `Time Left :` label, live countdown timer (`02h:22m:43s`), and `Add 2hrs` green pill button.
- **Floating Toast Banner**: Rounded white card with drop shadow, circular XJ VPN logo, and `Connected Successfully 😍`.
- **Footer**: `Config Version: 1.0.22`.
- **Bottom Bar**: Solid green accent bar.

### 2. Network / Payload Selection Modal (`NetworkSelectionModal`)
- Triggered by tapping the payload box on the main screen.
- **Search Bar**: Rounded input with `Search network name` and green magnifying glass icon.
- **Segmented Control**: `Local Networks` and `All Networks` (with green active background).
- **Payload Items** (exact list with icons, subtitles, and radio buttons):
  1. `🇸🇦 KSA | Mobily FreeNet ❤️ ✈`
  2. `🇸🇦 KSA | Mobily FreeNet V2ray ❤️ ✈`
  3. `🇸🇦 KSA | Mobily 30+60 SR All Area ❤️ ✈`
  4. `🇸🇦 KSA | Mobily 30+60 SR All Area V2ray ❤️ ✈`
  5. `🇸🇦 KSA | STC-Sawa FreeNet ❤️ ✈`
  6. `🇸🇦 KSA | STC-Sawa FreeNet V2ray ❤️ ✈`
  7. `🇸🇦 KSA | Jawwy FreeNet ❤️ ✈`
  8. `🇸🇦 KSA | Jawwy FreeNet V2ray ❤️ ✈`
  9. `🇸🇦 KSA | Salam FreeNet ❤️ ✈`
  10. `🇸🇦 KSA All SIM Social Package ✈️`
  11. `🇪🇹 ETHO | Ethiotelecom Free-Net ❤️ ✈`

### 3. Navigation Drawer (`XjNavigationDrawer`)
- **Header**: Deep green gradient with glowing circular `XJ -VPN-` badge, `XJ Tunnel VPN` title, and `NoobDEV (Build)` subtitle.
- **Menu Items** (with green icons and interactive dialogs):
  - Custom Server
  - Theme Settings
  - App Settings
  - V2ray Settings
  - OpenVPN Settings
  - Mobile IP Hunter
  - (Divider)
  - SlowDns Checker
  - RedeemTime Voucher
  - Beginner Tutorial
  - Hotspot Share
  - IP Address Checker
  - HostName Finder
  - (Divider)
  - HWID (with copyable device identifier)
  - Export Config

### 4. Live Logs View (`XjLogsTab`)
- Real-time connection events and handshake records with colored tags (`[CORE]`, `[PAYLOAD]`, `[ROUTE]`, `[OVPN]`, `[TUNNEL]`, `[REWARD]`).
- Copy Logs and Clear Logs buttons.

---

## 🚀 How to Run

```bash
flutter pub get
flutter run
```
