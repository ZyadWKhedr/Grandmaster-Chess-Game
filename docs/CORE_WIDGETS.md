# Core Widgets & Design System

## 1. Design System & Theme Foundations

Grandmaster Chess features a tournament-grade visual identity inspired by physical master boards (wood, slate, and marble) paired with modern digital ergonomics.

### 1.1 Color Tokens (`AppColors`)

| Token | Hex Value | Usage |
|---|---|---|
| `primaryGreen` | `#81B64C` | Iconic Chess Green CTA, play actions, and active indicators |
| `primaryGreenDark` | `#629924` | Pressed / emphasized green borders |
| `accentGold` | `#F59E0B` | Grandmaster gold for crowns, ratings, trophies, and pro badges |
| `darkBackground` | `#121316` | Deep Obsidian / Graphite canvas (zero eye strain, anti-glare) |
| `darkSurface` | `#1B1E24` | Card, container, and board wrapper background |
| `darkSurfaceElevated` | `#232732` | Elevated dialogs, drawers, and modal sheets |
| `darkBorder` | `#2A2F3D` | Refined subtle dark borders |
| `lightBackground` | `#F6F7F9` | Clean tournament linen canvas |
| `lightSurface` | `#FFFFFF` | Crisp card surfaces |
| `boardWoodLight` | `#EEEED2` | Tournament light squares (natural parchment cream) |
| `boardWoodDark` | `#769656` | Tournament dark squares (official Chess.com sage olive) |
| `squareSelected` | `0xB3F7E04C` | Warm amber square selection overlay |
| `squareLastMove` | `0x6660A5FA` | Cool blue last-move indicator |
| `squareCheck` | `0xB3EF4444` | Red king-in-check alert glow |
| `success` | `#10B981` | Checkmate / win indicators, brilliant move badges |
| `warning` | `#F59E0B` | Inaccuracy alerts, clock warnings (<30s) |
| `error` | `#EF4444` | Blunder alerts, timeout flags |

---

## 2. Reusable Core Widgets Catalog (`lib/core/widgets/`)

All core widgets are located in `lib/core/widgets/`, are strictly `StatelessWidget`s, and stay well under the 200-line limit.

### 2.1 `AppButton`
```dart
AppButton(
  label: 'Play vs Computer',
  icon: Icons.smart_toy_rounded,
  variant: AppButtonVariant.primary,
  onPressed: () => ...,
)
```
- **Variants**:
  - `primary`: Solid brand background with tactile haptic feedback.
  - `secondary`: Subtle surface background with high contrast text.
  - `outline`: Transparent with a thin accent border.
  - `danger`: Red destructive action button (e.g. Restart confirmation).
- **Features**: Built-in `isLoading` spinner state, tactile `HapticFeedback.lightImpact()`, text overflow prevention, and flexible sizing.

### 2.2 `AppCard`
```dart
AppCard(
  padding: EdgeInsets.all(16.w),
  onTap: () => ...,
  child: ...,
)
```
- **Purpose**: Elevated card surface used for player status cards, difficulty selection tiles, theme choices, and dialog content.
- **Features**: Automatic theme surface color resolution, subtle outer border, low-elevation shadow, optional ink splash on tap.

### 2.3 `AppDialog`
```dart
AppDialog(
  title: 'Choose Side',
  subtitle: 'Select who plays first',
  icon: Icons.shield_rounded,
  child: ...,
  actions: [...],
)
```
- **Purpose**: Unified modal wrapper replacing disparate ad-hoc dialogs.
- **Features**: Rounded 22dp corners, header with icon badge, title/subtitle typography, responsive maximum width constraints, and standardized action bar padding.

### 2.4 `AppBadge`
```dart
AppBadge(
  label: 'TOURNAMENT EDITION',
  icon: Icons.workspace_premium_rounded,
  color: Color(0xFF242938),
)
```
- **Purpose**: Compact pill badge for move count, rating tiers, material point advantage (`+3`), and game status flags.
- **Features**: `Flexible` text truncation to eliminate layout overflows on narrow mobile screens.

### 2.5 `ResponsiveLayout`
```dart
ResponsiveLayout(
  narrow: (context) => NarrowGameLayout(state: state),
  wide: (context) => WideGameLayout(state: state),
  breakpoint: 768,
)
```
- **Purpose**: Clean layout abstraction that decouples mobile and tablet/desktop/web presentation.
- **Features**: Pure `LayoutBuilder` wrapper, eliminates inline constraint logic in page controllers.

### 2.6 `GlowContainer`
```dart
GlowContainer(
  glowColor: Color(0x336366F1),
  blurRadius: 28,
  child: ...,
)
```
- **Purpose**: Subtle atmospheric lighting for the hero logo and game victory dialogs.
- **Features**: GPU-accelerated backdrop shadow with customizable radius and spread.

---

## 3. The 100% Stateless UI Architecture

### Why Stateless?
1. **Predictability**: Stateless widgets are pure functions of their input properties and Riverpod providers:
   $$\text{UI} = f(\text{State})$$
2. **Performance**: Flutter can cheaply mount, unmount, and diff stateless elements.
3. **Testability**: Any widget can be rendered in isolation without instantiating complex state machines or ticker providers.
4. **Clean Code**: Zero boilerplate `createState()`, zero `dispose()` forgets, and zero memory leaks from uncancelled animations.

