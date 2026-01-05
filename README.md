# LoverDOT

Dotfiles для **Parrot OS Security Home** и **Arch Linux** с Hyprland.

## Быстрая установка

### Одна команда (рекомендуется)

```bash
git clone https://github.com/nitzlover/LoverDOT.git && cd LoverDOT && chmod +x install.sh && ./install.sh
```

### Или curl (без клонирования)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nitzlover/LoverDOT/main/install.sh)
```

## Поддерживаемые дистрибутивы

| Дистрибутив | Статус | Пакетный менеджер |
|-------------|--------|-------------------|
| **Parrot OS Security Home** | ✅ Полная поддержка | apt |
| **Arch Linux** | ✅ Полная поддержка | pacman + AUR |
| Debian/Ubuntu | ✅ Работает | apt |
| Manjaro/EndeavourOS | ✅ Работает | pacman |
| Fedora | ⚠️ Базовая | dnf |

## Опции установки

```bash
./install.sh              # Полная установка с зависимостями
./install.sh --no-deps    # Только конфиги (без установки пакетов)
./install.sh --no-backup  # Без бэкапа существующих конфигов
./install.sh -h           # Справка
```

---

## Тема: Carbon Black

Чёрно-угольная тематика с карбоновыми градиентами.

### Цветовая палитра

| Название | Hex | Использование |
|----------|-----|---------------|
| `bg-deep` | `#0a0a0a` | Основной фон |
| `bg-dark` | `#121212` | Вторичный фон |
| `bg-card` | `#1a1a1a` | Карточки, попапы |
| `bg-elevated` | `#242424` | Выделенные элементы |
| `border` | `#2a2a2a` | Границы |
| `text-muted` | `#666666` | Приглушённый текст |
| `text-secondary` | `#888888` | Вторичный текст |
| `text-primary` | `#e0e0e0` | Основной текст |
| `accent` | `#3d3d3d` | Акцент (угольный) |
| `accent-bright` | `#4a4a4a` | Яркий акцент |

---

## Структура

```
LoverDOT/
├── install.sh           # Универсальный установщик
├── README.md
└── .config/
    ├── alacritty/
    │   └── alacritty.toml
    ├── hypr/
    │   └── hyprland.conf
    ├── waybar/
    │   ├── config.jsonc
    │   └── style.css
    ├── wofi/
    │   ├── config
    │   └── style.css
    ├── swaync/
    │   ├── config.json
    │   └── style.css
    └── firefox/
        └── chrome/
            └── userChrome.css
```

---

## Зависимости

Автоматически устанавливаются через `install.sh`:

### Основные
- hyprland
- waybar
- wofi
- alacritty
- swaync

### Дополнительные
- grim, slurp (скриншоты)
- wl-clipboard (буфер обмена)
- brightnessctl (яркость)
- playerctl (медиа)
- thunar (файловый менеджер)
- pavucontrol (звук)
- polkit-gnome (авторизация)

### Шрифты
- **Arch**: `ttf-jetbrains-mono-nerd`
- **Debian/Parrot**: `fonts-jetbrains-mono`

---

## Горячие клавиши

| Комбинация | Действие |
|------------|----------|
| `Super + D` | Wofi (лаунчер) |
| `Super + Return` | Alacritty (терминал) |
| `Super + Q` | Закрыть окно |
| `Super + F` | Полноэкранный режим |
| `Super + V` | Плавающий режим |
| `Super + N` | Центр уведомлений |
| `Super + 1-6` | Рабочие столы |
| `Super + Shift + 1-6` | Переместить окно |
| `Print` | Скриншот области |
| `Shift + Print` | Скриншот экрана |

---

## Firefox

Firefox требует отдельной настройки CSS:

1. Откройте `about:config`
2. Установите `toolkit.legacyUserProfileCustomizations.stylesheets` = `true`
3. Перезапустите Firefox

Тема автоматически устанавливается в профиль при запуске `install.sh`.

---

## Troubleshooting

### Parrot OS: Hyprland не найден
```bash
# Проверить доступность
apt search hyprland

# Если нет в репозиториях — собрать из исходников
# https://wiki.hyprland.org/Getting-Started/Installation/
```

### Arch: AUR пакеты
```bash
# Установить yay если нет
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# Дополнительные пакеты
yay -S hyprpaper hypridle hyprlock
```

### Waybar не запускается
```bash
# Проверить конфиг
waybar -l debug

# Перезапустить
killall waybar && waybar &
```

---

## Лицензия

MIT
