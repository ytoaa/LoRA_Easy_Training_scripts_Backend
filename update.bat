@echo off
REM Git 프로젝트의 모든 서브모듈을 업데이트 후 현재 브랜치에 푸시하는 스크립트

cd /d "%~dp0"

REM 현재 브랜치 확인
for /f "delims=" %%i in ('git rev-parse --abbrev-ref HEAD') do set BRANCH_NAME=%%i

echo 현재 브랜치: %BRANCH_NAME%
echo "Git 서브모듈 업데이트 시작..."

git submodule update --init --recursive

REM 모든 서브모듈 순회하며 최신 브랜치로 체크아웃
for /f %%s in ('git submodule foreach --quiet git rev-parse --show-toplevel') do (
    cd %%s
    echo "서브모듈: %%s 업데이트 중..."
    
    REM 서브모듈의 현재 브랜치 확인
    for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD') do set SUBMODULE_BRANCH=%%b
    
    REM detached HEAD 상태라면, 기본 원격 브랜치로 체크아웃
    if "%SUBMODULE_BRANCH%"=="HEAD" (
        echo "서브모듈이 detached 상태입니다. 원격 브랜치로 이동..."
        for /f "delims=" %%r in ('git remote show origin ^| findstr "HEAD branch"') do set DEFAULT_BRANCH=%%r
        git checkout %DEFAULT_BRANCH%
    )

    git pull origin %SUBMODULE_BRANCH%
    cd ..
)

echo "모든 서브모듈 최신 상태로 업데이트 완료."

REM 변경사항 추가 및 커밋
git add .
git commit -m "Update submodules and main project"

echo "현재 브랜치(%BRANCH_NAME%)에 변경사항을 푸시합니다..."
git push origin %BRANCH_NAME%

REM 각 서브모듈도 푸시
for /f %%s in ('git submodule foreach --quiet git rev-parse --show-toplevel') do (
    cd %%s
    git push origin %SUBMODULE_BRANCH%
    cd ..
)

echo "프로젝트 및 서브모듈 푸시 완료."
pause
