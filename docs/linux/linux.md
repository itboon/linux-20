# Linux 基础组件

Linux 核心的部分是「Linux 内核」，它就像硬壳中的种子一样存在于操作系统中，并且控制着硬件的所有主要功能。内核主要负责内存管理、进程管理、设备驱动和系统调用。

此外，安装在主机上的「Linux 操作系统」通常包含以下组件：

- bootloader，引导程序，比如 GRUB。它是将内核加载到内存的程序。
- init，初始化程序，比如 systemd。内核加载完成后，首先启动 init 进程，接着由 init 完成后面的系统启动。
- 基础软件库，比如 glibc (GNU C Library)。
- 基础工具，比如 GNU coreutils，它提供 `cat`、`ls`、`mkdir` 等基础工具。
- 软件包管理系统，比如 dpkg 或 RPM，它用于安装、移除和管理软件包。
- 用户界面，比如 shell 或桌面环境。

以上这些组件中 GRUB、glibc、coreutils 和 bash shell 都属于 GNU 软件，因此有些人把这样的操作系统称为 GNU/Linux，以支持 GNU 的贡献。需要明确的是，Linux 不属于 GNU，Linux 生态中有很多贡献者，GNU 软件在很多 Linux 发行版中占比最大。
