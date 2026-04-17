/**
 * PM2 на EC2: після `npm ci` та `npm run build` у каталозі my-app.
 * Шлях APP_DIR підлаштуй під свій клон репозиторію на сервері.
 */
module.exports = {
  apps: [
    {
      name: 'vite-lab1',
      cwd: '/home/ubuntu/lab-1-setup/my-app',
      script: 'npm',
      args: ['run', 'preview:ec2'],
      env: {
        NODE_ENV: 'production',
      },
    },
  ],
}
