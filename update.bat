@echo off
setlocal enabledelayedexpansion

REM 현재 브랜치를 저장
for /f %%b in ('git branch --show-current') do set CURRENT_BRANCH=%%b

REM 모든 브랜치 목록 가져오기
for /f "tokens=*" %%b in ('git branch --format "%%(refname:short)"') do (
    set BRANCH=%%b
    echo ==============================
    echo Switching to branch !BRANCH!
    echo ==============================
    git checkout !BRANCH!

    REM 서브모듈 초기화 및 업데이트
    git submodule update --init --recursive
    git submodule update --remote --recursive

    REM 서브모듈 변경 사항 커밋
    git add .
    git commit -m "Update submodules to latest version on !BRANCH!"

    REM 원격 저장소로 푸시
    git push origin !BRANCH!
)

REM 원래 브랜치로 돌아오기
git checkout %CURRENT_BRANCH%

echo 작업 완료!
pause
