# Ansible VPN server config


### Required
- ssh
- nc
- sshpass (for test)

Used [IPsec VPN Server on Docker](https://github.com/hwdsl2/docker-ipsec-vpn-server)

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
make bootstrap
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

- Установить `sudo apt install sshpass`
- Задать переменную `ANSIBLE_PASSWORD` - реальный пароль пользователя для теста

### IPsec VPN commands

Add new client:

```bash 
make add-client
```

Remove client:

```bash 
make remove-client
```

List clients:

```bash 
make list-clients
```

## Client

## TODO: change to IPsec VPN

```bash
sudo apt install wireguard
```

```bash
sudo chmod o+r /etc/wireguard 
```

```bash
sudo cp ./clients/client-name.conf /etc/wireguard/client-name.conf
```

```bash
sudo wg-quick up client-name
```

```bash
sudo wg-quick down client-name
```

```bash
sudo wg show
```
