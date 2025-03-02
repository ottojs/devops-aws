FROM node:22.14.0-alpine3.21

USER node
WORKDIR /home/node

RUN cat <<EOF > /home/node/index.js
console.log("Running...");
setInterval(function () {
    console.log("Interval", Date.now());
}, 30 * 1000);
EOF

CMD ["node", "index.js"]
