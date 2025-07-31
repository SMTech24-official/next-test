module.exports = {
  apps: [
    {
      name: "next-client",
      script: "node_modules/next/dist/bin/next",
      args: "start",
      env: {
        NODE_ENV: "production",
        PORT: 4000,
      },
    },
  ],
};
