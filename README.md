# Ansible VPN server config

### Install dependencies

```bash
sudo apt install ansible
ansible-galaxy collection install -r collections/requirements.yml
```

### Add environment

```bash
cp .env.example .env
```

### Run playbook

```bash
make playbook-run
```

После смены SSH порта подключаться нужно уже на новый порт `SSH_PORT`.

Потребовалась перезагрузка vps, до этого не заработало подключение:

```
ssh -p port root@host
```

### Тесты

```bash
make test
```

Для проверки недоступности подключения по ssh по паролю:

- Задать переменную `ANSIBLE_PASSWORD` - реальный пароль пользователя для теста
- Установить `sudo apt install sshpass` 

