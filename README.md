# Lệnh cài đặt
````bash
curl -fsSL https://raw.githubusercontent.com/<username>/<repo-name>/main/install-openkylin-zorin.sh | sudo bash
````

Khi cài mới lại Zorin OS, bạn chỉ cần thực hiện theo các bước sau để chạy script một lần là hoàn tất:

**1. Cập nhật hệ thống lần đầu**

```bash
sudo apt update && sudo apt upgrade -y

```

**2. Chạy script cài đặt giao diện openKylin**
Tải script về hoặc clone từ repo GitHub của bạn rồi chạy với quyền root:

```bash
sudo bash install-openkylin-zorin.sh

```

**3. Khởi động lại và đăng nhập**

1. Khởi động lại máy:
```bash
sudo reboot

```


2. Tại màn hình khóa đăng nhập, bấm vào tên tài khoản.
3. Chọn biểu tượng **bánh răng (⚙️)** ở góc dưới bên phải màn hình > chọn **UKUI**.
4. Nhập mật khẩu và đăng nhập.

Nếu sau khi cài mới gặp bất kỳ lỗi phát sinh nào trong quá trình chạy script, bạn cứ gửi phản hồi để được hỗ trợ kiểm tra ngay nhé.
