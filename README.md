# CodeIgniter4 API 

Тестовое создание Api, наработки визуализации CRUD API в CodeIgniter4.

## На компьютере установленно:
* Ubuntu 22.04
* Docker version 27.3.1 - официальный сайт https://docs.docker.com/
* Docker Compose version v2.12.2
* Composer 2.2.6 - официальный сайт https://getcomposer.org/

## Создание директории проекта и переход в нее

* Для создания директории проекта `projects/ci4api/` и перехода в нее выполните следующие команды:

    ```bash
    mkdir projects
    cd projects/
    mkdir ci4api
    cd ci4api/
    ```

* Дальнейшие действия выполняйте в директории `projects/ci4api/`

## Установка и настройка CodeIgniter4

* Описание процесса установки CodeIgniter4 в Руководстве пользователя: [Ссылка](https://codeigniter.com/user_guide/index.html)
    ```
        Установка последней стабильной версии в текущую директорию:
    composer create-project codeigniter4/appstarter .

        Установка определенной версии (например, 4.6.0) в текущую директорию:
    composer create-project codeigniter4/appstarter:4.6.0 .

        Установка в новую директорию (например, "project-root"):
    composer create-project codeigniter4/appstarter project-root

        Установка определенной версии в новую директорию:
    composer create-project codeigniter4/appstarter:4.6.0 project-root
    ```

### Конфигурация

* Изменения в файле .env :

    * `.env`:

        ```ini
        CI_ENVIRONMENT = development
        ...
        app.baseURL = 'http://localhost/'
        ...
        database.default.hostname = db
        database.default.database = ci4api
        database.default.username = root
        database.default.password = root
        ```

## Установка виртуального сервера Docker ( php:8.2-apache, MySQL, phpMyAdmin )

### Создаем конфигурацию сервера:
* Файл 1 `docker-compose.yml`:

    ```yaml
    version: "3.8"

    services:
    web:
        build: .
        container_name: ci4_web
        restart: always
        ports:
        - "80:80"
        volumes:
        - .:/var/www/html
        - ./logs:/var/www/html/writable/logs
        depends_on:
        - db

    db:
        image: mysql:8
        container_name: ci4_db
        restart: always
        environment:
        MYSQL_ROOT_PASSWORD: root
        MYSQL_DATABASE: students
        MYSQL_USER: user
        MYSQL_PASSWORD: secret
        ports:
        - "3306:3306"
        volumes:
        - ./db_data:/var/lib/mysql

    phpmyadmin:
        image: phpmyadmin/phpmyadmin
        container_name: ci4_phpmyadmin
        restart: always
        environment:
        PMA_HOST: db
        MYSQL_ROOT_PASSWORD: root
        ports:
        - "8081:80"

    ```

* Файл 2 `Dockerfile`:

    ```dockerfile
    FROM php:8.2-apache

    WORKDIR /var/www/html

    RUN apt-get update && apt-get install -y \
        libpng-dev libjpeg-dev libfreetype6-dev libzip-dev unzip locales \
        libicu-dev \
        && docker-php-ext-configure gd --with-freetype --with-jpeg \
        && docker-php-ext-install gd pdo pdo_mysql zip mysqli intl

    RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf \
        && a2enmod rewrite

    RUN mkdir -p /var/www/html/writable /var/www/html/logs \
        && chown -R www-data:www-data /var/www/html \
        && chmod -R 775 /var/www/html/writable \
        && chmod -R 775 /var/www/html/logs

    EXPOSE 80

    CMD ["apache2-foreground"]
    ```
### Работа с Docker, командами:
* Обычно делается 1 раз для создания контейнеров (сервера) и сразу запуска :

    ```bash
    docker-compose up -d --build
    ```
* Стоп (остановить контейнеры):
    ```bash
    docker-compose stop
    ```
* Запустить :

    ```bash
    docker-compose up -d
    ```
* Выгрузить (остановить и выгрузить контейнеры):
    ```bash
    docker-compose down
    ```

## Доступ к ресурсам этого проекта

* **Веб-сайт:**

    Откройте браузер и перейдите по адресу: `http://localhost/`

* **phpMyAdmin:**

    Откройте браузер и перейдите по адресу: `http://localhost:8081/`

    * **Имя пользователя:** `root`
    * **Пароль:** `root`

### База данных для экспорта через SQL-запрос 

* Файл - БД_для_экспорта_ci4api.sql



## Предупреждения о блокировке работы сервера и базы данных из-за прав доступа

> [!WARNING] Если возникают ошибки 'доступ запрещен', 'недоступен', 'не найден', это может быть связано с недостаточными правами доступа к директориям и файлам. Чаще всего это (logs, writable, db_data)!

**Вариант 1 (рекомендуемый):** Постепенный поиск проблемы через анализ лог-файлов. Начните с предоставления доступа к директориям `logs` и `writable/logs`.

**Вариант 2 (временное, учебное решение):** Предоставление полного доступа (777) к директориям и файлам для проверки, является ли проблема следствием недостаточных прав. После подтверждения проблемы, постепенно ужесточайте права (например, до 775), чтобы определить конкретную причину (например, отсутствие доступа к базе данных `db_data`, кэшу `writable/cache` или ...).

**Пояснения:**

* **Вариант 1** более безопасен и позволяет локализовать проблему, не предоставляя избыточных прав.
* **Вариант 2** подходит для быстрой диагностики, но не рекомендуется для постоянного использования в производственной среде из-за потенциальных рисков безопасности.

**Рекомендации:**

* Всегда начинайте с анализа лог-файлов.
* Избегайте использования прав доступа 777 в производственной среде.
* Постепенно ужесточайте права доступа, чтобы минимизировать риски.


* **Пример команд для установки прав доступа 777 (Ubuntu 22.04), предоставляющих полные права на чтение, запись и выполнение для всех пользователей:**

    ```bash
    sudo chmod -R 777 logs
    sudo chmod -R 777 writable
    sudo chmod -R 777 db_data
    ```

> [!WARNING]

> * Материал предоставлен исключительно в образовательных целях.
> * Используемые логины и пароли предназначены для демонстрации и должны быть заменены на безопасные в реальных условиях.
> * Дополнительную информацию и решения можно найти в ИИ чат-ботах и на специализированных форумах.
> * Автор не несет ответственности за возможные ошибки и проблемы, возникшие в результате использования данного материала.

---
# Описание работы сайта

Данная инструкция описывает, как тестировать API для управления запросами. Добавленна визуализация CRUD.

1.  **Список студентов (GET /api/students)**

    Показывает список всех студентов в формате JSON. [На сайте] (/test/students)

    Пример cURL:

    ```bash
    curl http://localhost/api/students
    ```

2.  **О студенте (GET /api/students/{id})**

    Показывает детали студента с указанным ID. [На сайте] (/test/students/2)

    Пример cURL (замените {id} на реальный ID):

    ```bash
    curl http://localhost/api/students/2
    ```

3.  **Добавить студента (POST /api/students)**

    Позволяет добавить нового студента с помощью формы. [На сайте] (/test/add-student)

    Пример cURL:

    ```bash
    curl -X POST -F "name=Новый Студент" -F "email=new.student@example.com" -F "phone=+3805012*****" http://localhost/api/students
    ```

4.  **Обновить студента (PUT /api/students/{id})**

    Позволяет обновить данные студента с указанным ID с помощью формы. [На сайте] (/test/update-student/2)

    Пример cURL (замените {id} на реальный ID):

    ```bash
    curl -X PUT -H "Content-Type: application/json" -d '{"name": "Обновленный Студент", "phone": "+331123*****"}' http://localhost/api/students/2
    ```

    Пример ответа:

    ```json
    {
        "status": 200,
        "error": null,
        "messages": {
            "success": "Student updated successfully"
        }
    }
    ```

    Пример cURL для проверки ошибки (запрос с ошибкой):

    ```bash
    curl -X PUT -H "Content-Type: application/json" -d '' http://localhost/api/students/2
    ```

    Результат должен быть таким:

    ```json
    {
        "status": 400,
        "error": 400,
        "messages": {
            "error": "Invalid JSON data"
        }
    }
    ```

5.  **Удалить студента (DELETE /api/students/{id})**

    Позволяет удалить студента с указанным ID. [На сайте] (/test/delete-student/2)

    Пример cURL (замените {id} на реальный ID):

    ```bash
    curl -X DELETE http://localhost/api/students/2
    ```

## API Endpoints

-   GET /api/students
-   GET /api/students/{id}
-   POST /api/students
-   PUT /api/students/{id}
-   DELETE /api/students/{id}

## Удачи!