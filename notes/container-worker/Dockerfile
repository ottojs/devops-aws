FROM node:24.11.1-alpine

USER node
WORKDIR /home/node

RUN cat <<EOF > /home/node/index.js
console.log("Running...");
console.log("SECRET:", process.env.MY_SECRET);
setInterval(function () {
    console.log("Interval", Date.now());
}, 30 * 1000);
EOF

CMD ["node", "index.js"]
