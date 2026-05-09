# Ansible VPN server config


### Добавить переменные окружения

```bash
cp .env.example .env
```

### Установить коллекции

```bash
make install-collections
```

### Запустить playbook

```bash
make run
```

После смены SSH порта подключаться нужно уже на новый порт `SSH_PORT`.

Потребовалась перезагрузка vps, до этого не заработало подключение:

```
ssh -p port root@host
```

## Тесты

```bash
make test
```

Для проверки недоступности подключения по ssh по паролю:

- Задать переменную `ANSIBLE_PASSWORD` - реальный пароль пользователя для теста
- Установить `sudo apt install sshpass` 

