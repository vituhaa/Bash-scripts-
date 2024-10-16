# 1) Функция 1.
function generate_test_files {
    param (
        [string]$path, # путь, где будут созданы файлы
        [int]$fileCount, # количество файлов для генерации 
        [int]$fileSizeMB # размер каждого файла в Мб
    )

    if (-not $path) {    # если путь не указан 
        Write-Host "The path for generating files cannot be empty."
        exit 1
    }

    if (-not (Test-Path -Path $path)) {   
    # Test-Path - команда проверки существования директории.  Test-Path -Path $path  - команда проверяет, существует ли файл по пути $path. 
    # True - возвращает, если элемент существует.
        New-Item -Path $path -ItemType Directory | Out-Null
        # New-Item - команда для создания новых файлов, директорий или других объектов.
        # -Path $path - указывает путь, по которому нужно создать новый объект. (-Path - параметр, который указывавеи путь к файлу, директории или другому объекту).
        # -ItemType Directory - указыавает тип создаваемого объекта - в данном случае, директорию (папку).
        # Out-Null - команда для подавления вывода. она указывает повершеллу не выводить информацию о результатах команды.
    }

    Write-Host " Generating $fileCount files to $fileSizeMB MB in directory $path..."
    for ($i = 1; $i -le $fileCount; $i++) { 
        $fileName = Join-Path $path "test_file_$i.dat"
        fsutil file createnew $fileName ($fileSizeMB * 1MB) | Out-Null
    }
    # -le - less or equal.
    # Join-Path - команда объединяет путь к директории $path и имя файла "test_file_$i.dat" в единый путь.
    # Файл с расширением .dat — это общий формат данных, который может использоваться для хранения информации в различных форматах, в зависимости от приложения, 
    # которое его создало. Само по себе расширение .dat не указывает на какой-то определённый тип данных, и такой файл может содержать как текстовую информацию,
    # так и двоичные данные.
    # fsutil file createnew - это утилита, которая создаёт новый файл. Она принимает два аргумента:
    # 1) имя файла
    # 2) размер файла в байтах
    # $fileName - переменная содержит полное имя файла, который будет создан, включая путь.
    # $fileSizeMB - переменная, которая содержит размер файла в мб.
    # умножение позволяет легко получить размер файла в байтах.
}


# 2) Функция 2.
function run_test {
    param (
        [string]$sourcePath, # строка указывающая путь к директории, содержащей файлы, которые будут архивированы.
        [string]$archivePath, # стркоа, указывающая путь, куда будет сохранён архив
        [int]$diskUsageThreshold, # порог использования в процентах
        [int]$fileCount, # кол-во файлов, котооые будет обработаны в тесте.
        [int64]$maxSize, # макс размер архива.
        [string]$testName # строка, представляющая имя теста.
    )

    if (-not $sourcePath) {
        Write-Host "sourcePath cannot be empty"
        exit 1
    }

    if (-not $archivePath) {
        Write-Host "archivePath cannot be empty"
        exit 1
    }

    Write-Host "`nTest: $testName" # `n - переход на новую строку.
    Write-Host "------------------------------------"
    
    & .\test_0.ps1 -sourcePath $sourcePath -archivePath $archivePath -diskUsageThreshold $diskUsageThreshold -fileCount $fileCount -maxSize $maxSize
    # & - оператор вызова.
    # В PowerShell, если вы просто напишете путь к скрипту, система попытается интерпретировать это как текст или строку, а не как команду.
    # .\test_0.ps1 - запуск как скрипт.
    # запрос 5 параметров.
    $archiveName = Join-Path $archivePath "archive.zip"
    # переменная $archiveName созда1тся для хранения полного пути к файлу архива, который будет называться "archive.zip"
    # Join-Path — это команда PowerShell, которая объединяет компоненты пути в файловой системе, делая это корректно с учётом разделителей пути
    # (например, слэши \ или /).
    if (Test-Path $archiveName) { # Test-Path - команда проверки существования директории.
        Write-Host "The $testName test was successful: The $archiveName archive was created."
    } else {
        Write-Host "The $testName test failed: The $archiveName archive was not created."
    }
    Write-Host "------------------------------------"
}



# 3) Создание тестовых файлов.
$logDir = "$HOME/log"
# $logDir — это переменная, которая хранит путь к директории, где будут сгенерированы файлы.
# $HOME — это системная переменная, которая ссылается на домашнюю директорию текущего пользователя. В Windows эта директория обычно находится по пути типа 
# C:\Users\<имя_пользователя>.
# "/log" — это поддиректория, которая будет добавлена к домашней директории.
$backupDir = "$HOME/backup"
# $backupDir — это переменная, в которую будет сохранён путь к директории backup.
# "$HOME/backup" — это строка, которая содержит путь к директории.
generate_test_files -path $logDir -fileCount 20 -fileSizeMB 25
# generate_test_files — это имя функции, которая отвечает за создание тестовых файлов.
# -path $logDir — параметр -path передаёт путь к директории, в которой будут созданы файлы.
# -fileCount 20 — параметр -fileCount указывает количество файлов, которые нужно создать. В данном случае будет сгенерировано 20 файлов.
# -fileSizeMB 25 — параметр -fileSizeMB задаёт размер каждого файла в мегабайтах. В данном случае каждый файл будет иметь размер 25 МБ.


# 4) Запуск тестов.
run_test -sourcePath $logDir -archivePath $backupDir -diskUsageThreshold 50 -fileCount 10 -maxSize 1GB -testName "Test1"
run_test -sourcePath $logDir -archivePath $backupDir -diskUsageThreshold 30 -fileCount 15 -maxSize 1GB -testName "Test2"
run_test -sourcePath $logDir -archivePath $backupDir -diskUsageThreshold 80 -fileCount 10 -maxSize 1GB -testName "Test3"
run_test -sourcePath $logDir -archivePath $backupDir -diskUsageThreshold 50 -fileCount 20 -maxSize 2GB -testName "Test4"



# Краткое описание:
# 1) Функция 1: эта функция генерирует тестовые файлы в указанной директории.
# 2) Функция 2: эта функция запускает тест, который выполняет архивирование файлов из указанной директории на основе заданных параметров.
# 3) Создание тестовых файлов.
# 4) Запуск тестов.






