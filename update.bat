@echo off
setlocal enabledelayedexpansion

REM ���� �귣ġ�� ����
for /f %%b in ('git branch --show-current') do set CURRENT_BRANCH=%%b

REM ��� �귣ġ ��� ��������
for /f "tokens=*" %%b in ('git branch --format "%%(refname:short)"') do (
    set BRANCH=%%b
    echo ==============================
    echo Switching to branch !BRANCH!
    echo ==============================
    git checkout !BRANCH!

    REM ������ �ʱ�ȭ �� ������Ʈ
    git submodule update --init --recursive
    git submodule update --remote --recursive

    REM ������ ���� ���� Ŀ��
    git add .
    git commit -m "Update submodules to latest version on !BRANCH!"

    REM ���� ����ҷ� Ǫ��
    git push origin !BRANCH!
)

REM ���� �귣ġ�� ���ƿ���
git checkout %CURRENT_BRANCH%

echo �۾� �Ϸ�!
pause
