# WSL 초기 설정 가이드

## 1️⃣ 재부팅 후 첫 실행

재부팅이 완료되면 자동으로 Ubuntu 터미널이 열립니다. 열리지 않으면:

```powershell
# PowerShell 또는 CMD에서 실행
wsl
```

## 2️⃣ Ubuntu 사용자 설정

처음 실행 시 사용자 이름과 비밀번호를 설정합니다:

```
Enter new UNIX username: [원하는 사용자명 입력]
New password: [비밀번호 입력]
Retype new password: [비밀번호 재입력]
```

> **참고**: 비밀번호 입력 시 화면에 표시되지 않습니다 (정상 동작)

## 3️⃣ 시스템 업데이트

```bash
sudo apt update && sudo apt upgrade -y
```

## 4️⃣ 필수 도구 설치

### Git 설치
```bash
sudo apt install git -y
git --version
```

### Node.js 및 npm 설치 (LTS 버전)
```bash
# NodeSource 저장소 추가
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Node.js 설치
sudo apt install -y nodejs

# 버전 확인
node --version
npm --version
```

### Docker 설치 (선택사항 - Docker Desktop 사용 시 불필요)
```bash
# Docker 공식 설치 스크립트
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# Docker Compose 설치
sudo apt install docker-compose -y
```

## 5️⃣ 프로젝트 디렉토리 접근

Windows 파일 시스템은 `/mnt/` 아래에 마운트됩니다:

```bash
# 프로젝트 디렉토리로 이동
cd /mnt/c/Users/hello/OneDrive/바탕\ 화면/Karravan/karaban

# 또는 심볼릭 링크 생성 (편의성)
ln -s /mnt/c/Users/hello/OneDrive/바탕\ 화면/Karravan/karaban ~/karaban
cd ~/karaban
```

## 6️⃣ 프로젝트 의존성 설치

```bash
# 프로젝트 디렉토리에서
npm install

# 프론트엔드 의존성 설치
cd frontend
npm install
cd ..
```

## 7️⃣ Docker Desktop WSL2 백엔드 설정 (권장)

1. **Docker Desktop 실행**
2. **Settings** → **General**
3. **"Use the WSL 2 based engine"** 체크
4. **Settings** → **Resources** → **WSL Integration**
5. **"Enable integration with my default WSL distro"** 체크
6. **Ubuntu** 토글 활성화
7. **Apply & Restart**

## 8️⃣ SSH 키 설정 (EC2 배포용)

```bash
# .ssh 디렉토리 생성
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Windows에서 SSH 키를 WSL로 복사 (키가 있는 경우)
cp /mnt/c/Users/hello/.ssh/your-key.pem ~/.ssh/
chmod 400 ~/.ssh/your-key.pem
```

## 9️⃣ 유용한 WSL 명령어

### Windows PowerShell에서:
```powershell
# WSL 상태 확인
wsl --status

# WSL 버전 확인
wsl --list --verbose

# WSL 종료
wsl --shutdown

# 특정 배포판 실행
wsl -d Ubuntu
```

### WSL Ubuntu 내에서:
```bash
# Windows 탐색기에서 현재 디렉토리 열기
explorer.exe .

# Windows 프로그램 실행
code .  # VS Code 열기
```

## 🔟 VS Code WSL 확장 설치

1. VS Code에서 **WSL** 확장 설치
2. WSL Ubuntu 터미널에서:
   ```bash
   code .
   ```
3. VS Code가 WSL 모드로 열립니다 (왼쪽 하단에 "WSL: Ubuntu" 표시)

## ✅ 설치 확인

모든 설정이 완료되었는지 확인:

```bash
# 버전 확인
git --version
node --version
npm --version
docker --version  # Docker 설치 시
docker-compose --version  # Docker 설치 시

# 프로젝트 디렉토리 접근 확인
cd ~/karaban  # 또는 /mnt/c/Users/hello/OneDrive/바탕\ 화면/Karravan/karaban
ls -la
```

## 🚀 다음 단계: EC2 배포 준비

WSL 설정이 완료되면 `EC2_DEPLOYMENT.md`를 참고하여 배포를 진행합니다:

```bash
# 배포 문서 확인
cat EC2_DEPLOYMENT.md
```

---

## 💡 팁

### 성능 최적화
- **프로젝트를 WSL 파일 시스템에 복사**하면 성능이 향상됩니다:
  ```bash
  cp -r /mnt/c/Users/hello/OneDrive/바탕\ 화면/Karravan/karaban ~/karaban-wsl
  cd ~/karaban-wsl
  ```

### Windows와 WSL 간 파일 공유
- Windows에서 WSL 파일 접근: `\\wsl$\Ubuntu\home\[username]\`
- WSL에서 Windows 파일 접근: `/mnt/c/`, `/mnt/d/` 등

### 문제 해결
- WSL이 느린 경우: Docker Desktop의 WSL2 백엔드 사용
- 파일 권한 문제: `chmod`, `chown` 명령어 사용
- WSL 재시작: `wsl --shutdown` 후 다시 실행

---

**재부팅 후 이 가이드를 따라 WSL을 설정하세요!** 🎉
