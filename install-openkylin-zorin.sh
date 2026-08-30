#!/usr/bin/env bash
# ==============================================================================
# Script cài đặt và hoàn thiện giao diện UKUI / openKylin Desktop trên Zorin OS
# Tác giả: Long Nguyen
# ==============================================================================

set -eo pipefail

echo "=========================================================="
echo "   BẮT ĐẦU CÀI ĐẶT VÀ TỐI ƯU UKUI / OPENKYLIN DESKTOP     "
echo "=========================================================="

# 1. Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo "[-] Vui lòng chạy script với quyền sudo:"
    echo "    sudo bash $0"
    exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$TARGET_USER")

# 2. Cập nhật kho ứng dụng và cài đặt các thành phần cốt lõi
echo "[+] Cập nhật hệ thống và tải các gói giao diện UKUI..."
apt update -y

apt install -y --no-install-recommends \
    ukui-desktop-environment \
    ukui-panel \
    ukui-menu \
    ukui-control-center \
    ukui-settings-daemon \
    ukui-session-manager \
    ukui-notification-daemon \
    ukui-power-manager \
    ukui-sidebar \
    ukui-window-switch \
    ukui-themes \
    ukui-wallpapers \
    ukui-media \
    ukui-greeter \
    peony \
    peony-common \
    peony-extensions \
    peony-open-terminal \
    peony-set-wallpaper \
    papirus-icon-theme \
    fonts-wqy-microhei \
    qt5-style-plugins \
    qt5ct \
    dconf-cli

# 3. Cấu hình biến môi trường Qt/GTK toàn hệ thống
echo "[+] Thiết lập biến môi trường tích hợp Qt5 & GTK..."
cat << 'EOF' > /etc/profile.d/ukui-style.sh
export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CURRENT_DESKTOP=UKUI
EOF
chmod +x /etc/profile.d/ukui-style.sh

# 4. Sửa lỗi kế thừa (Inherits) cho các bộ icon UKUI
echo "[+] Cấu hình fallback kế thừa icon cho UKUI..."
for dir in /usr/share/icons/ukui /usr/share/icons/ukui-classical /usr/share/icons/ukui-fashion; do
    if [ -d "$dir" ]; then
        # Merge các icon app thiếu từ Papirus/Zorin/hicolor
        cp -rn /usr/share/icons/Papirus/* "$dir/" 2>/dev/null || true
        cp -rn /usr/share/icons/Zorin/* "$dir/" 2>/dev/null || true
        cp -rn /usr/share/icons/hicolor/* "$dir/" 2>/dev/null || true
        
        # Sửa file index.theme
        if [ -f "$dir/index.theme" ]; then
            sed -i "/^Inherits=/d" "$dir/index.theme"
            echo "Inherits=Zorin,Papirus,Adwaita,hicolor" >> "$dir/index.theme"
        fi
        gtk-update-icon-cache -f -q "$dir" 2>/dev/null || true
    fi
done

# 5. Đồng bộ Icon từ Flatpak và Snap sang kho icon hệ thống
echo "[+] Khắc phục icon ứng dụng Flatpak và Snap..."
if [ -d /var/lib/flatpak/exports/share/icons ]; then
    cp -rsf /var/lib/flatpak/exports/share/icons/hicolor/* /usr/share/icons/hicolor/ 2>/dev/null || true
fi

if [ -d /var/lib/snapd/desktop/icons ]; then
    cp -rsf /var/lib/snapd/desktop/icons/* /usr/share/icons/hicolor/128x128/apps/ 2>/dev/null || true
fi

if [ -d "$USER_HOME/.local/share/flatpak/exports/share/icons" ]; then
    cp -rsf "$USER_HOME/.local/share/flatpak/exports/share/icons/hicolor/*" /usr/share/icons/hicolor/ 2>/dev/null || true
fi

gtk-update-icon-cache -f -q /usr/share/icons/hicolor 2>/dev/null || true

# 6. Tạo Cronjob tự động sync icon khi cài Flatpak mới sau này
echo "[+] Tạo hook tự động đồng bộ icon Flatpak..."
cat << 'EOF' > /etc/cron.daily/sync-flatpak-icons
#!/bin/bash
if [ -d /var/lib/flatpak/exports/share/icons ]; then
    cp -rsf /var/lib/flatpak/exports/share/icons/hicolor/* /usr/share/icons/hicolor/ 2>/dev/null || true
    gtk-update-icon-cache -f -q /usr/share/icons/hicolor 2>/dev/null || true
fi
EOF
chmod +x /etc/cron.daily/sync-flatpak-icons

# 7. Xóa sạch bộ nhớ đệm (Cache) của người dùng
echo "[+] Dọn dẹp cache giao diện..."
rm -rf "$USER_HOME/.cache/ukui"* "$USER_HOME/.cache/menus" "$USER_HOME/.cache/thumbnails" "$USER_HOME/.cache/icon-cache.kcache"

# 8. Cấu hình gsettings mặc định cho User
echo "[+] Thiết lập theme mặc định..."
sudo -u "$TARGET_USER" dbus-launch gsettings set org.ukui.style icon-theme-name 'ukui-classical' 2>/dev/null || true
sudo -u "$TARGET_USER" dbus-launch gsettings set org.ukui.style gtk-theme-name 'ukui-dark' 2>/dev/null || true
sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.interface icon-theme 'ukui-classical' 2>/dev/null || true
sudo -u "$TARGET_USER" dbus-launch gsettings set org.gnome.desktop.interface gtk-theme 'ukui-dark' 2>/dev/null || true

echo "=========================================================="
echo "                  CÀI ĐẶT HOÀN TẤT!                       "
echo "=========================================================="
echo "Vui lòng ĐĂNG XUẤT (Log Out) hoặc KHỞI ĐỘNG LẠI máy:"
echo "1. Tại màn hình đăng nhập, chọn tài khoản."
echo "2. Nhấp vào biểu tượng BÁNH RĂNG (⚙️) ở góc dưới."
echo "3. Chọn phiên 'UKUI' và đăng nhập."
echo "=========================================================="
