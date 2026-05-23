# 🖥️ Samsung NT767XCM (Lakefield) — Arch Linux 설정 가이드

> **Intel Core i3-L13G4** | 8GB LPDDR4 | USB SSD 부팅 | Xfce + Xorg

---

## 📋 하드웨어 요약

| 항목 | 사양 | Linux 지원 상태 |
|------|------|:---:|
| CPU | Intel Core i3-L13G4 (Lakefield, 1P+4E, 7W TDP, **AVX 없음**) | ✅ |
| GPU | Intel UHD Graphics (Gen11, PCI ID `8086:9841`) | ❌ i915 미바인딩, llvmpipe 사용 |
| RAM | 8GB LPDDR4 2133MHz | ✅ |
| 내장 스토리지 | UFS 238GB (`sdb`, SCSI) | ⚠️ ufshcd hang — **blacklist 필수** |
| 외장 부팅 | USB SSD (`sda`) | ✅ |
| Wi-Fi | Intel AX200 (Wi-Fi 6) | ✅ |
| 오디오 | SoundWire (PCI ID `8086:98c8`) | ❌ 사운드카드 미인식 |
| 배터리 | ACPI BAT0 미인식 | ❌ 잔량 표시 불가 |
| 키보드/트랙패드 | — | ✅ (커널 5.17+) |
| BIOS | P07AJD.053 | — |

## ⚠️ 알려진 제한사항

- **GPU 가속 불가**: PCI ID `9841`이 i915 PCI ID 테이블에 미등록. `force_probe=9841` 무효. 소프트웨어 렌더링(llvmpipe) 사용.
- **오디오 불가**: DSDT SoundWire 엔드포인트 손상 (`Buffer` vs `Package`). AVS/SOF/HDA 모두 프로브 실패. **USB DAC 또는 Bluetooth 오디오 사용.**
- **배터리 미인식**: ACPI에서 BAT0 자체가 누락. AC 어댑터도 `off-line` 오보. 충전은 정상.
- **reboot → shutdown**: `reboot` 명령 시 실제로는 전원이 꺼짐. `pci`, `efi` 등 reboot 메서드 모두 실패. **전원 버튼으로 재시작.**

---

## 🚀 설치 후 초기 설정

### 1. 커널 부팅 파라미터

```
# /etc/default/grub → GRUB_CMDLINE_LINUX_DEFAULT
BOOT_IMAGE=/vmlinuz-linux root=UUID=<root-uuid> rw loglevel=3 quiet modprobe.blacklist=ufshcd_pci,ufshcd_core
```

> `ufshcd` blacklist는 필수. 내장 UFS 컨트롤러가 hang을 유발함.

### 2. fstab (USB SSD)

```fstab
UUID=<root-uuid>    /          ext4  rw,noatime  0 1
UUID=<boot-uuid>    /boot      ext4  rw,noatime  0 2
UUID=<efi-uuid>     /boot/efi  vfat  rw,relatime,fmask=0022,dmask=0022,...  0 2
UUID=<swap-uuid>    none       swap  defaults    0 0
```

> `noatime`으로 USB SSD 쓰기 감소.

### 3. zram swap

```bash
sudo pacman -S zram-generator
sudo tee /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
EOF
```

> zram(priority=100)이 우선, USB SSD swap(priority=-1)이 fallback.

---

## 🎨 데스크탑 환경 (Xfce + Xorg)

### DPI / 글꼴

```bash
# DPI 120 (1920x1080 13인치에서 적절)
xfconf-query -c xsettings -p /Xft/DPI -s 120

# 기본 글꼴
xfconf-query -c xsettings -p /Gtk/FontName -s "Sans 12"

# 윈도우 제목 글꼴
xfconf-query -c xfwm4 -p /general/title_font -s "Sans Bold 12"

# 패널 높이
xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 36
```

### 테마

```bash
sudo pacman -S arc-gtk-theme papirus-icon-theme

xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
xfconf-query -c xfwm4 -p /general/theme -s "Arc-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
```

### 패널 시계 글꼴 (GTK CSS)

```bash
mkdir -p ~/.config/gtk-3.0
echo '.xfce4-panel .clock-label { font-size: 13px; }' >> ~/.config/gtk-3.0/gtk.css
xfce4-panel -r
```

### LightDM

```bash
# DPI
sudo mkdir -p /etc/lightdm/lightdm.conf.d
echo '[Seat:*]
xserver-command=X -dpi 120' | sudo tee /etc/lightdm/lightdm.conf.d/20-dpi.conf

# Greeter 글꼴
# /etc/lightdm/lightdm-gtk-greeter.conf → [greeter] 아래:
font-name=Sans 13
xft-dpi=120
```

### GRUB 글꼴

```bash
sudo grub-mkfont -s 32 -o /boot/grub/fonts/terminus32.pf2 /usr/share/fonts/misc/ter-x32b.pcf.gz
echo 'GRUB_FONT="/boot/grub/fonts/terminus32.pf2"' | sudo tee -a /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### TTY 콘솔 글꼴

```bash
echo 'FONT=ter-v32b' | sudo tee /etc/vconsole.conf
```

---

## 💻 터미널 (xfce4-terminal)

### 색상 스킴 (Tokyo Night)

```ini
# ~/.config/xfce4/terminal/terminalrc
[Configuration]
ColorForeground=#c0caf5
ColorBackground=#000000
ColorCursor=#c0caf5
ColorPalette=#1a1b26;#f7768e;#9ece6a;#e0af68;#7aa2f7;#bb9af7;#7dcfff;#a9b1d6;#414868;#f7768e;#9ece6a;#e0af68;#7aa2f7;#bb9af7;#7dcfff;#c0caf5
ColorBoldIsBright=TRUE
ColorUseTheme=FALSE
BackgroundMode=TERMINAL_BACKGROUND_TRANSPARENT
BackgroundDarkness=1.000000
FontName=Terminus 14
ShortcutsNoMenukey=TRUE
ShortcutsNoMnemonics=TRUE
```

### 글꼴 설정

- 영문: **Terminus 14**
- 한글 fallback: **D2Coding** (fontconfig 설정)

```xml
<!-- ~/.config/fontconfig/fonts.conf -->
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
    <alias>
        <family>Terminus</family>
        <prefer>
            <family>Terminus</family>
            <family>D2Coding</family>
        </prefer>
    </alias>
</fontconfig>
```

### D2Coding 수동 설치

```bash
cd /tmp
curl -LO https://github.com/naver/d2codingfont/releases/download/VER1.3.2/D2Coding-Ver1.3.2-20180524.zip
unzip D2Coding-Ver1.3.2-20180524.zip -d d2coding
mkdir -p ~/.local/share/fonts
cp d2coding/D2Coding/*.ttf ~/.local/share/fonts/
fc-cache -fv
```

---

## ⌨️ 한글 입력 (fcitx5)

### 패키지

```bash
sudo pacman -S fcitx5-im fcitx5-hangul
```

### 환경변수 (~/.xprofile)

```bash
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
xmodmap ~/.Xmodmap
```

### 한영키 매핑 (~/.Xmodmap)

```
keycode 108 = Hangul
```

> NT767XCM의 한영키는 `Alt_R`로 인식됨. `Hangul` 키심으로 리맵 필수.

### 전환키

- `Shift+Space` — 한/영 전환
- `Hangul` (한영키) — 한/영 전환

---

## 🛠️ 시스템 서비스

### TLP (전원 관리)

```bash
sudo pacman -S tlp
sudo systemctl enable --now tlp
```

> 배터리 미인식으로 항상 BAT 프로파일로 동작. 균형 모드 유지.

### thermald (열 관리)

```bash
sudo pacman -S thermald
sudo systemctl enable --now thermald
```

> Lakefield이 지원 목록에 없으므로 override 필요:

```bash
sudo systemctl edit thermald
# 입력:
[Service]
ExecStart=
ExecStart=/usr/bin/thermald --systemd --dbus-enable --adaptive --ignore-cpuid-check
```

### 방화벽 (ufw)

```bash
sudo pacman -S ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo systemctl enable ufw
```

### USB SSD TRIM

```bash
sudo systemctl enable --now fstrim.timer
```

### 시간 동기화

```bash
sudo timedatectl set-ntp true
```

---

## 📝 Neovim

### 기본 에디터 설정 (~/.bashrc)

```bash
export EDITOR=nvim
export VISUAL=nvim
alias vim="nvim"
alias vi="nvim"
```

### 설정 파일

- `~/.config/nvim/init.lua` — 기본 설정 + 파일 타입 템플릿
- `~/.config/nvim/templates/` — bash, python, c, h, html, makefile 템플릿

---

## 🐚 Bash 프롬프트

```bash
# ~/.bashrc
parse_git_branch() {
    git branch 2>/dev/null | grep '^\*' | sed 's/* / /'
}
PS1='\[\e[38;5;141m\]\u\[\e[0m\]@\[\e[38;5;117m\]\h\[\e[0m\] \[\e[38;5;228m\]\w\[\e[38;5;212m\]$(parse_git_branch)\[\e[0m\] \$ '
```

---

## 🔧 커널 컴파일 (향후)

현재 커널 `7.0.9-arch2-1`은 범용 빌드. 경량화 + PCI ID 패치로 개선 가능:

- **i915**: `9841`을 ICL 디바이스 정보로 PCI ID 테이블에 추가
- **오디오**: SOF/AVS PCI ID 테이블에 `98c8` 추가 (펌웨어 부재로 효과 불확실)
- **불필요 드라이버 제거**: NVIDIA, AMD, 미사용 파일시스템, 서버/가상화 등
- **크로스 컴파일 권장**: 홈 PC(B760M)에서 빌드 → USB SSD에 설치

---

## 📦 설치 복원

```bash
git clone git@github.com:cjun93/arch-dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

---

## 📅 최종 업데이트: 2026-05-23
