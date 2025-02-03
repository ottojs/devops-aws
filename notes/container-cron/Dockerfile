FROM node:22.13.1-alpine3.21

USER node
WORKDIR /home/node

RUN cat <<EOF > /home/node/index.js
console.log("Running...");
console.log("UNIX:", Date.now());
console.log("Date:", new Date().toLocaleString());
console.log("Offset:", new Date().getTimezoneOffset());
console.log("Secret Value:", process.env.THESECRET);
EOF

CMD ["node", "index.js"]
