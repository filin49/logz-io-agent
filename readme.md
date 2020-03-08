# logz-io-agent
Lightweight bash script for sending data to logz.io
### Configuration
Put your config file to ```/conf/``` directory. Filename will be use as ```type``` (used in logz.io for parse file).

```nginx``` file example:
```
/usr/logs/nginx/access.log
/usr/logs/nginx/access-site1.log
```

```json``` file example:
```
/var/www/html/storage/logs/laravel.json
```

If you use log rotation, you can use file mask:
```
/usr/logs/nginx/access-*.log
```
Script will be detect new files automaticaly by mask.

In ```monitor.sh``` you can change ```TIME_INTERVAL``` for specify time, while script will be send data. By default - script check files for sending every 10 sec.
Also, you can specify ```LOGZ_TOKEN``` or set environment variable.

### Run
If you specify your Logz.io token in script file, just run:
```sh
./monitor.sh
```
Or, you can set token as environment variable:
```sh
LOGZ_TOKEN="your_token_here" ./monitor.sh
```

You can get your token in "[GENERAL SETTINGS](https://app.logz.io/#/dashboard/settings/general)" page of your Logz.io account.
