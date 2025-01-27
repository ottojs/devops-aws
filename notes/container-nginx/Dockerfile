FROM nginx:1.27.3-alpine3.20

# Replaces listener on port 80 to 8080
RUN sed -i \
    -r 's/^(\s*)listen(\s+)80;/\1listen\28080;/gm' \
    /etc/nginx/conf.d/default.conf;
