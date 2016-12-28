# language: ru

Функционал: Выполнение файловых операций
    Как Пользователь
    Я хочу иметь возможность выполнять различные файловые операции в тексте фич
    Чтобы я мог проще протестировать и автоматизировать больше действий на OneScript

Контекст: Инициализация рабочего каталога и создание каталогов
    Допустим Я создаю временный каталог и сохраняю его в контекст
    И Я устанавливаю временный каталог как рабочий каталог

    И Я создаю каталог "folder0/folder01" в рабочем каталоге
    И Я создаю каталог "folder011" в подкаталоге "folder0/folder01" рабочего каталога

Сценарий: Создание каталогов
    Тогда В рабочем каталоге существует каталог "folder0/folder01"
    И В подкаталоге "folder0/folder01" рабочего каталога существует каталог "folder011"

Сценарий: Создание файлов
    Когда Я создаю файл "folder0/file01.txt" в рабочем каталоге
    И Я создаю файл "file01" в подкаталоге "folder0/folder01" рабочего каталога
    Тогда В рабочем каталоге существует файл "folder0/file01.txt"
    И В подкаталоге "folder0/folder01" рабочего каталога существует файл "file01"

Сценарий: Копирование файлов
    Когда Я копирую файл "step_definitions/БезПараметров.os" из каталога "tests/fixtures" проекта в рабочий каталог
    И Я копирую файл "fixtures/test-report.xml" из каталога "tests" проекта в подкаталог "folder0/folder01" рабочего каталога

    Тогда В рабочем каталоге существует файл "БезПараметров.os"
    И В подкаталоге "folder0/folder01" рабочего каталога существует файл "test-report.xml"

Сценарий: Копирование каталогов
    Когда Я копирую каталог "fixtures/step_definitions" из каталога "tests/fixtures" проекта в рабочий каталог
    И Я копирую каталог "fixtures/step_definitions" из каталога "tests" проекта в подкаталог "folder0/folder01" рабочего каталога
    
    Тогда В рабочем каталоге существует каталог "step_definitions"
    И В подкаталоге "folder0/folder01" рабочего каталога существует каталог "step_definitions"

Сценарий: Управление стеком текущих каталогов
    Когда Я создаю файл "folder0/file01.txt" в рабочем каталоге
    И Я установил рабочий каталог как текущий каталог
    И Я установил подкаталог "folder0" рабочего каталога как текущий каталог

    Тогда Каталог "folder01" существует
    И Каталог "folder0/folder01" не существует
    И Файл "file01.txt" существует
    И Файл "folder0/file01.txt" не существует

    И Я восстановил предыдущий каталог
    И Я восстановил предыдущий каталог

Сценарий: Каталог проекта
    Когда Я сохраняю каталог проекта в контекст
    Тогда Я показываю каталог проекта
    И Я показываю рабочий каталог