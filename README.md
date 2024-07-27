# ct8socks
ct8创建socks5的一键脚本

运行前提：你必须先要登录CT8的面板，去允许自定义程序和开启一个TCP端口。

用法：

1：直接curl -O https://github.com/Neomanbeta/ct8socks/raw/main/ct8socks.sh && chmod +x ct8socks.sh && ./ct8socks.sh   然后你就可以跳过2和3，直接看4了。

或者ssh登录你的ct8服务器，输入nano ct8socks.sh，然后把ct8socks.sh里面所有的内容黏贴进去，保存退出。或者用winscp等任何支持sshftp的软件直接把ct8socks.sh传上去。

2：给脚本赋予运行权限chmod +x ct8socks.sh

3：运行脚本./ct8socks.sh

4：根据脚本的提示信息进行操作，中途可能需要你停止脚本重连ssh（为了让pm2生效），这里没有条件过多测试，反正提示你成功安装pm2了，接下来出错不能继续了，你就断开ssh再重新连接，按照3的命令再重新运行脚本。

5：里面需要你输入的只有3个地方，socks5的端口，socks5的用户名，socks5的密码，然后等待安装完成。

6：进行保活，下载仓库中的checksocks5.sh放到/domains/用户名小写.ct8.pl/socks5/目录下，或者自己手动进入到这个目录nano checksocks5.sh，把checksocks5.sh里面的所有内容黏贴进去保存并退出，这个脚本必须和socks5.js同目录，否则会判断失败。

7：赋予checksocks5.sh运行权限chmod +x checksocks5.sh

说明：

这个脚本会给你安装pm2然后用pm2管理并运行一个socks5代理。

你可以在socks5.js所在目录下运行pm2 status来查看代理的运行状态，或者用pm2 stop socks_proxy来停止代理服务。

在成功运行并启动socks5代理以后，脚本最后会提示“代理工作正常，脚本结束”，然后你需要用crontab来给代理保活

ssh连接后输入crontab -e，然后把这段里面的两处中文改成对应的你自己的信息，再黏贴进去（这是一分钟执行一次，自己改成需要的时长）

* * * * * /home/用户名/domains/用户名小写.ct8.pl/socks5/checksocks5.sh > /dev/null 2>&1

提醒一下，无任何售后服务，脚本也不会再更新，因为CT8已经把我账号BAN了，所以其实这个脚本我并没有完全修改完，你们想用的就用吧。
