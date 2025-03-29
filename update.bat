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
    
    REM �������� ���� �귣ġ Ȯ��
    for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD') do set SUBMODULE_BRANCH=%%b
    
    REM detached HEAD ���¶��, �⺻ ���� �귣ġ�� üũ�ƿ�
    if "%SUBMODULE_BRANCH%"=="HEAD" (
        echo "�������� detached �����Դϴ�. ���� �귣ġ�� �̵�..."
        for /f "delims=" %%r in ('git remote show origin ^| findstr "HEAD branch"') do set DEFAULT_BRANCH=%%r
        git checkout %DEFAULT_BRANCH%
    )

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
    git push origin %SUBMODULE_BRANCH%
    cd ..
)

echo "������Ʈ �� ������ Ǫ�� �Ϸ�."
pause
