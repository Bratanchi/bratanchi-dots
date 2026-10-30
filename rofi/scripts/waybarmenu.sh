#!/bin/bash

# Директория с конфигами Waybar
WAYBAR_DIR="$HOME/.config/waybar"

# Ищем все папки внутри WAYBAR_DIR (кроме скрытых)
THEMES=$(find "$WAYBAR_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort)

# Если папок нет, выходим
if [ -z "$THEMES" ]; then
    notify-send "Waybar Switcher" "Не найдено папок с темами в $WAYBAR_DIR"
    exit 1
fi

# Показываем меню выбора через Rofi
SELECTED_THEME=$(echo "$THEMES" | rofi -dmenu -i -p "Waybar Theme" -theme ~/.config/rofi/waybarmenu.rasi)

# Если тема выбрана (нажали Enter, а не Esc)
if [[ -n "$SELECTED_THEME" ]]; then
    THEME_PATH="$WAYBAR_DIR/$SELECTED_THEME"

    # Проверяем, есть ли в папке нужные файлы
    if [[ ! -f "$THEME_PATH/config.jsonc" && ! -f "$THEME_PATH/config" ]]; then
        notify-send "Waybar Switcher" "В папке $SELECTED_THEME нет config.jsonc"
        exit 1
    fi

    # Делаем бэкап текущих конфигов (на всякий случай)
    cp "$WAYBAR_DIR/config.jsonc" "$WAYBAR_DIR/config.jsonc.bak" 2>/dev/null
    cp "$WAYBAR_DIR/style.css" "$WAYBAR_DIR/style.css.bak" 2>/dev/null

    # Создаем символические ссылки (-f перезаписывает, если уже есть)
    # Если у темы есть config.jsonc
    if [ -f "$THEME_PATH/config.jsonc" ]; then
        ln -sf "$THEME_PATH/config.jsonc" "$WAYBAR_DIR/config.jsonc"
    fi
    
    # Если у темы есть style.css
    if [ -f "$THEME_PATH/style.css" ]; then
        ln -sf "$THEME_PATH/style.css" "$WAYBAR_DIR/style.css"
    fi

    # Перезапускаем Waybar
    killall waybar 2>/dev/null
    sleep 0.5 # Небольшая пауза, чтобы старый процесс точно завершился
    waybar & disown

    notify-send "Waybar" "Тема изменена на: $SELECTED_THEME"
fi
