Burrito Vagrant
================

It builds a vagrant box based on the burrito cloud image.

The system OS is a debian 12 bookworm.

Install podman to build vagrant box.::

    $ sudo apt install podman

Start the user's dbus socket.::

    $ systemctl --user start dbus.socket

Build a burrito box.::

    $ ./run.sh --build <burrito_cloud_image>


