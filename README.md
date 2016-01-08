docker-pureftpd
==
Host [Pure-FTPd](https://www.pureftpd.org/project/pure-ftpd) for virtual users only.

* reference:
  - [bamarni/docker-pureftp](https://github.com/bamarni/docker-pureftp)
  - [snasello/docker-pureftp](https://github.com/snasello/docker-pureftp)


Setup docker image
==

Method 1: Building
--
Copy the sources to your docker host and build the container:

    # docker build --rm -t <username>/pure-ftpd .


Method 2: Pull from Docker Hub
--
Get it from Docker Hub,

    # docker pull docker.io/koyeung/pure-ftpd


Running
==

Setup ftp directory, (on docker host),

    # FTPDIR=/tmp/ftpdir
    # mkdir -p ${FTPDIR}
    # chcon -Rt svirt_sandbox_file_t ${FTPDIR}

Launch the container,

    # docker run --name ftp -d  \
        -p 21:21 -p 30000-30009:30000-30009  \
        -v ${FTPDIR}:/home/ftpuser <username>/pure-ftpd


Setup new virtual user,

    # docker exec -it ftp bash
    # VIRTUAL_USER=joe
    # pure-pw useradd ${VIRTUAL_USER} -m -u ftpuser -d /home/ftpuser/${VIRTUAL_USER}
    # su - ftpuser -c  "mkdir -p /home/ftpuser/${VIRTUAL_USER}"

If your want to change password later,

    # docker exec -it ftp bash
    # pure-pw passwd ${VIRTUAL_USER} -m
