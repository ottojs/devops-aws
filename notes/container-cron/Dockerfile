FROM node:24.11.1-alpine

USER node
WORKDIR /home/node

RUN cat <<EOF > /home/node/index.js
console.log("Running...");
console.log("UNIX:", Date.now());
console.log("Date:", new Date().toLocaleString());
console.log("TZ Offset:", new Date().getTimezoneOffset());
console.log("Secret Value:", process.env.MY_SECRET);
console.log("DONE!");
EOF

CMD ["node", "index.js"]
