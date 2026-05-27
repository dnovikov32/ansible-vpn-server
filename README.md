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

Command also copies the client configuration files to the [./clients](./clients) directory.

Remove client:

```bash 
make remove-client
```

List clients:

```bash 
make list-clients
```

Check container logs to view details for IKEv2:

```bash
make logs
```

Check contents of /etc/ipsec.d in the container:

```bash
make contents
```

## Configure IKEv2 VPN clients

[Guide: How to Set Up and Use IKEv2 VPN](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/ikev2-howto.md)

