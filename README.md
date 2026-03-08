# Laravel Docker Template for Coolify

Este es un template listo para desplegar aplicaciones Laravel utilizando Docker Compose en [Coolify](https://coolify.io/).

## Características

- **PHP 8.3-FPM** optimizado para producción.
- **Nginx** configurado para Laravel.
- **MySQL 8** como base de datos por defecto.
- **Scripts de despliegue automatizados** para migraciones, caché y permisos.
- **Configuración de Docker Compose** lista para Coolify.
- **Estructura limpia** separando configuración de Docker del código fuente.

## Estructura del Proyecto

- `src/`: Contiene el código fuente de tu aplicación Laravel.
- `docker/`: Configuraciones específicas de los contenedores (PHP, Nginx).
- `scripts/`: Scripts auxiliares como `deploy.sh`.
- `docker-compose.yml`: Definición de la orquestación de servicios.

## Desarrollo Local

Para levantar el proyecto localmente:

1. Clona el repositorio:
   ```bash
   git clone <tu-repositorio-url>
   cd coolify-laravel-template
   ```

2. Levanta los contenedores:
   ```bash
   docker compose up -d
   ```

3. Entra al contenedor de la aplicación para instalar dependencias:
   ```bash
   docker compose exec app composer install
   docker compose exec app php artisan key:generate
   docker compose exec app php artisan migrate
   ```

4. Tu aplicación estará disponible en `http://localhost`.

## Despliegue en Coolify

Este template está diseñado para usarse con el build pack **Docker Compose** en Coolify.

### Pasos para desplegar:

1. En Coolify, crea un nuevo **Service** o **Resource**.
2. Selecciona **Public Repository** o conecta tu cuenta de GitHub.
3. Elige este repositorio.
4. En **Build Pack**, selecciona **Docker Compose**.
5. Coolify detectará automáticamente el archivo `docker-compose.yml`.
6. Configura las variables de entorno necesarias en la pestaña **Environment Variables** (especialmente las relativas a la base de datos).
7. Haz clic en **Deploy**.

### Automatización del despliegue

El archivo `docker-compose.yml` está configurado para ejecutar el script `scripts/deploy.sh` (o puedes configurarlo en el comando de inicio de Coolify) para asegurar que:
- Se instalen las dependencias de Composer.
- Se apliquen los permisos correctos en `storage` y `bootstrap/cache`.
- Se ejecuten las migraciones (`php artisan migrate --force`).
- Se generen las cachés de configuración, rutas y vistas para un mejor rendimiento.

## Personalización

- **Versión de PHP**: Puedes cambiar la versión en `docker/php/Dockerfile`.
- **Configuración de Nginx**: Está disponible en `docker/nginx/default.conf`.
- **Variables de Entorno**: Asegúrate de que las variables en Coolify coincidan con las esperadas en tu `src/.env`.

---

Creado por [Moises de Abreu](https://github.com/moisesdeabreu)
