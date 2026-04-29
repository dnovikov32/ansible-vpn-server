# New VPN server setup

## 1) Заполнить inventory

Отредактируйте `inventory/hosts.ini`:
- `YOUR_SERVER_IP` -> IP вашего сервера
- `ansible_user` -> пользователь для SSH (например `root`)
- `ansible_port` -> текущий SSH порт сервера (до применения playbook)

## 2) Проверить переменные

В `group_vars/all.yml`:
- `ssh_port` — новый SSH порт (должен быть не `39364`)
- `disable_ssh_password_auth` — оставить `true`, если вход по ключу уже работает

## 3) Установить коллекции

```bash
ansible-galaxy collection install -r collections/requirements.yml
```

## 4) Запустить playbook

```bash
ansible-playbook playbooks/vpn-fin.yml
```

После смены SSH порта подключаться нужно уже на новый порт `ssh_port`.

Потребовалась перезагрузка vps, до этого не заработал 
```
ssh -p 39364 root@132.243.23.251
```
