# frp-http

## Server
```bash
docker run -it --rm --name frp-http-server \
    -e FRP_SUBDOMAIN_HOST=domain.com \
    -p 80:80 \
    -p 7000:7000 \
    yanhao98/frp-http-server
```

### Update
```bash
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --cleanup --run-once \
    frp-http-server
```

<!-- ## Client
### Mac
```bash
bash <(curl -s domain.com/client.sh) --local=127.0.0.1:80
``` -->

## Reference
- [Dockerfile for ngx](https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine-slim/Dockerfile)
- [Dockerfile-for-frps](https://github.com/fatedier/frp/blob/dev/dockerfiles/Dockerfile-for-frps)
- [Multi-arch frps's docker image](https://github.com/cloverzrg/frps-docker/blob/master/Dockerfile)
- https://github.com/snowdreamtech/frp/blob/master/frps/amd64/Dockerfile
- [VBScript](https://www.w3school.com.cn/vbscript/index.asp)
- https://stackoverflow.com/questions/4888197/how-To-show-dos-output-when-using-vbscript-exec/4888791#4888791
- [Frps服务端一键配置脚本](https://github.com/MvsCode/frps-onekey)
- [frps-docker](https://github.com/cloverzrg/frps-docker/blob/master/Dockerfile)

```
rm /var/log/nginx/access.log /var/log/nginx/error.log
https://github.com/nginxinc/docker-nginx/blob/4bf0763f4977fff7e9648add59e0540088f3ca9f/mainline/debian/Dockerfile#L102
the nginx log is already redirected to stdout/stderr by default (see Dockerfile#L102)
if we delete the log file, nginx will create a new one, but the new one is not redirected to stdout/stderr
```
