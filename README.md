# New VPN server setup

```bash
cp .env.example .env
```

## Установить коллекции

```bash
make install-collections
```

## Запустить playbook

```bash
make run
```

После смены SSH порта подключаться нужно уже на новый порт `SSH_PORT`.

Потребовалась перезагрузка vps, до этого не заработал 
```
ssh -p 39364 root@132.243.23.251
```
