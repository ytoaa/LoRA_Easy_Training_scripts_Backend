@echo off
REM Git ������Ʈ�� ��� �������� ������Ʈ �� ���� �귣ġ�� Ǫ���ϴ� ��ũ��Ʈ

cd /d "%~dp0"

REM ���� �귣ġ Ȯ��
for /f "delims=" %%i in ('git rev-parse --abbrev-ref HEAD') do set BRANCH_NAME=%%i

echo ���� �귣ġ: %BRANCH_NAME%
echo "Git ������ ������Ʈ ����..."

git submodule update --init --recursive

REM ��� ������ ��ȸ�ϸ� �ֽ� �귣ġ�� üũ�ƿ�
for /f %%s in ('git submodule foreach --quiet git rev-parse --show-toplevel') do (
    cd %%s
    echo "������: %%s ������Ʈ ��..."
    
    REM �������� HEAD detached �������� Ȯ��
    for /f "delims=" %%b in ('git symbolic-ref --short HEAD 2^>nul') do set SUBMODULE_BRANCH=%%b

    if "%SUBMODULE_BRANCH%"=="" (
        echo "�������� detached �����Դϴ�. �⺻ �귣ġ Ȯ�� ��..."
        for /f "tokens=3" %%r in ('git remote show origin ^| findstr /C:"HEAD branch"') do set DEFAULT_BRANCH=%%r
        REM �⺻ �귣ġ�� Ȯ�εǾ����� �� �귣ġ�� üũ�ƿ�
        git checkout %DEFAULT_BRANCH%
        set SUBMODULE_BRANCH=%DEFAULT_BRANCH%
    )

    REM �ش� �귣ġ�� pull
    git pull origin %SUBMODULE_BRANCH%
    cd ..
)

echo "��� ������ �ֽ� ���·� ������Ʈ �Ϸ�."

REM ������� �߰� �� Ŀ��
git add .
git commit -m "Update submodules and main project"

echo "���� �귣ġ(%BRANCH_NAME%)�� ��������� Ǫ���մϴ�..."
git push origin %BRANCH_NAME%

REM �� �����⵵ Ǫ��
for /f %%s in ('git submodule foreach --quiet git rev-parse --show-toplevel') do (
    cd %%s

    REM �ش� �������� Ǫ�� ������ ��������� Ȯ��
    git remote -v | findstr /C:"origin" | findstr /V /C:"kohya-ss" > nul
    if %ERRORLEVEL%==0 (
        echo "������ Ǫ��: %%s"
        if "%SUBMODULE_BRANCH%"=="" (
            REM HEAD ���¿��� Ǫ��
            git push origin HEAD:%DEFAULT_BRANCH%
        ) else (
            git push origin %SUBMODULE_BRANCH%
        )
    ) else (
        echo "Ǫ�� ������ ���� ������: %%s (Ǫ�� ����)"
    )

    cd ..
)

echo "������Ʈ �� ������ Ǫ�� �Ϸ�."
pause
