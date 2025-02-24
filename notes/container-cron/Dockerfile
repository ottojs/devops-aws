FROM node:22.14.0-alpine3.21

USER node
WORKDIR /home/node

RUN cat <<EOF > /home/node/index.js
console.log("Running...");
console.log("UNIX:", Date.now());
console.log("Date:", new Date().toLocaleString());
console.log("TZ Offset:", new Date().getTimezoneOffset());
console.log("Secret Value:", process.env.MY_SECRET);
EOF

CMD ["node", "index.js"]
