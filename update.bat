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
    
    REM 서브모듈이 HEAD detached 상태인지 확인
    for /f "delims=" %%b in ('git symbolic-ref --short HEAD 2^>nul') do set SUBMODULE_BRANCH=%%b

    if "%SUBMODULE_BRANCH%"=="" (
        echo "서브모듈이 detached 상태입니다. 기본 브랜치 확인 중..."
        for /f "tokens=3" %%r in ('git remote show origin ^| findstr /C:"HEAD branch"') do set DEFAULT_BRANCH=%%r
        REM 기본 브랜치가 확인되었으면 그 브랜치로 체크아웃
        git checkout %DEFAULT_BRANCH%
        set SUBMODULE_BRANCH=%DEFAULT_BRANCH%
    )

    REM 해당 브랜치로 pull
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

    REM 해당 서브모듈이 푸시 가능한 저장소인지 확인
    git remote -v | findstr /C:"origin" | findstr /V /C:"kohya-ss" > nul
    if %ERRORLEVEL%==0 (
        echo "서브모듈 푸시: %%s"
        if "%SUBMODULE_BRANCH%"=="" (
            REM HEAD 상태에서 푸시
            git push origin HEAD:%DEFAULT_BRANCH%
        ) else (
            git push origin %SUBMODULE_BRANCH%
        )
    ) else (
        echo "푸시 권한이 없는 서브모듈: %%s (푸시 생략)"
    )

    cd ..
)

echo "프로젝트 및 서브모듈 푸시 완료."
pause
