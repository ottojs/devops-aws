FROM nginx:1.27.3-alpine3.21

# Replaces listener on port 80 to 8080
RUN sed -i \
    -r 's/^(\s+)listen(\s+)80;/\1listen\28080;/g' \
    /etc/nginx/conf.d/default.conf;
