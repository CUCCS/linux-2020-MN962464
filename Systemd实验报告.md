## 实验三 Systemd实操

<hr style="height:1px" />

### 实验环境
- Ubuntu18.04.4
- puTTy
- asciinema 录屏

<hr style="height:1px" />

### 实验要求
- 阅读阮一峰的「Systemd 入门教程：命令篇」与「Systemd 入门教程：实战篇」并进行动手实操
- 按照入门教程的章节划分分段录屏上传到asciinema，并按照见名知意的标准编辑录像文件名
- 完成本章课件中的[自查清单]

<hr style="height:1px" />

### 实验过程
#### 命令篇
- 3.1~4.2

[![asciicast](https://asciinema.org/a/hVR9u7z8m80uVKHBehVj0UAcC.svg)](https://asciinema.org/a/hVR9u7z8m80uVKHBehVj0UAcC)

<hr style="height:1px" />

- 4.3~5.4

[![asciicast](https://asciinema.org/a/PHmhQIZox4ddmWbtHWk3FiAR0.svg)](https://asciinema.org/a/PHmhQIZox4ddmWbtHWk3FiAR0)

<hr style="height:1px" />

- 6~7

[![asciicast](https://asciinema.org/a/QbsmDcHlowiGTymUYfCuJsE6A.svg)](https://asciinema.org/a/QbsmDcHlowiGTymUYfCuJsE6A)

<hr style="height:1px" />

#### 实战篇

- 1~6

[![asciicast](https://asciinema.org/a/LPbpb51ytJV0k6L349n6zWZiM.svg)](https://asciinema.org/a/LPbpb51ytJV0k6L349n6zWZiM)

<hr style="height:1px" />

- 7~9

[![asciicast](https://asciinema.org/a/fGxH7GLvBAxC8YxfHeCvglji7.svg)](https://asciinema.org/a/fGxH7GLvBAxC8YxfHeCvglji7)

<hr style="height:1px" />

### 自查清单
- **如何添加一个用户并使其具备sudo执行程序的权限？**
    + ```usermod -a -G sudo username```

    <hr style="height:1px" />

- **如何将一个用户添加到一个用户组？**
    + ```usermod -a -G groupname username```
    + ```sudo adduser username groupname```

    <hr style="height:1px" />

- **如何查看当前系统的分区表和文件系统详细信息？**
    + 查看分区表
      1. `sudo sfdisk -l`
      2. `sudo cfdisk`
      3. `cfdisk`
      4. `cat /proc/partitions`
    + 查看文件系统（磁盘）
    `df -a`
    + 同时查看分区表和文件系统信息
    `lsblk -a` 

    <hr style="height:1px" />

- **如何实现开机自动挂载Virtualbox的共享目录分区？**
    + 在桌面上新建一个文件，内容为： 
        ```
        #!/bin/sh  sudo mount -t vboxsf sharing /mnt/share
        ```
    + 在文件 /etc/rc.local 中（用root用户）追加如下命令
        ```
        mount -t vboxsf sharing /mnt/share
        ```
    + 重启系统

    <hr style="height:1px" />

- **基于LVM（逻辑分卷管理）的分区如何实现动态扩容和缩减容量？**
    ```
    扩容：
    lvextend -L size dir
    缩减：
    lvreduce -L size dir
    ```

    <hr style="height:1px" />

- **如何通过systemd设置实现在网络连通时运行一个指定脚本，在网络断开时运行另一个脚本？**
  + 在networking.service配置文件中的[Service]模块增加以下内容：
    ```
    [Service]
    ...
    ExecStartPost=一个指定脚本路径
    ExecStopPost=另一个脚本路径 
    ...
    ```

    <hr style="height:1px" />

- **如何通过systemd设置实现一个脚本在任何情况下被杀死之后会立即重新启动？实现杀不死？**
    + 在写配置服务文件时，在[Service]模块中加上：
        ```
        StartLimitIntervalSec=0
        Restart=always
        RestartSec=1
        ```
        例如：在`/etc/systemd/system/rot13.service`创建一个配置文件`rot13.service`：
        ```
        [Unit]
        Description=ROT13 demo service
        After=network.target
        StartLimitIntervalSec=0

        [Service]
        Type=simple
        Restart=always
        RestartSec=1
        User=ltpc
        ExecStart=/usr/bin/env php /path/to/server.php
 
        [Install]
        WantedBy=multi-user.target
        ```

<hr style="height:1px" />

### 参考文献

- [Linux之systemd服务配置及自动重启](https://www.cnblogs.com/nxzblogs/p/11755972.html)
- [virtualbox下ubuntu共享文件夹自动挂载](https://blog.csdn.net/u013394556/article/details/49894999)
