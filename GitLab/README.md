# Install GitLab

## Docker should have at least 8 GB of RAM.

## Othervice GitLab server will give 502 error for ecery action.

https://docs.gitlab.com/install/docker/

Create a directory for the volumes
Create a directory for the configuration files, logs, and data files. The directory can be in your user’s home directory (for example ~/gitlab-docker), or in a directory like /srv/gitlab.

Create the directory:

    sudo mkdir -p <DIRNAME>

For example:

    sudo mkdir -p /srv/gitlab

If you’re running Docker with a user other than root, grant the appropriate permissions to the user for the new directory.

Configure a new environment variable $GITLAB_HOME that sets the path to the directory you created:

    export GITLAB_HOME=<DIRNAME>

For example:

    export GITLAB_HOME=/srv/gitlab

Create folders:

    config
    logs
    data

folders in the <DIRNAME> repo.

### Use docker-compose in current dir.

## Setup

Visit the GitLab URL, and sign in with the username "root" and the password from the following command:

    sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password

Or find the password in mapped directory on
local machine: 'config/initial_root_password'

or

$GITLAB_HOME/dir/config/initial_root_password

# Create backup

    docker exec -it gitlab gitlab-backup create

This command creates a backup of the GitLab database,
repositories, and other important data.

The backup is stored in the default backup directory: /var/opt/gitlab/backups.

NOT RELEVANT FOR MAC OS
When you run the backup command, the backup file is stored inside
the Docker container at /var/opt/gitlab/backups. However,
since you mapped this directory to a local directory using
Docker volumes (in your docker-compose.yml),
the backup will also be available on your local machine.

The backup directory inside the container (/var/opt/gitlab/backups) is mapped to $GITLAB_HOME/data/backups on your local machine.

Example of backup file name: 1698765432_2025_02_26_17.8.4_gitlab_backup.tar

# Error on launch

### On Mac OS needs to create docker volume to store the data from:

/var/opt/gitlab

Check Filesystem Support
If you're using Docker on macOS or Windows, the underlying filesystem (e.g., osxfs on macOS) might not fully support Unix sockets.

To resolve this, consider using a Linux host or a Docker volume driver that supports Unix sockets.

3. Use a Docker Volume Instead of Bind Mount
   Instead of using a bind mount (e.g., $GITLAB_HOME/data:/var/opt/gitlab), use a Docker volume:

Create a Docker volume:

    docker volume create gitlab-data

Update your docker-compose.yml to use the volume:

```yml
     - "gitlab-data:/var/opt/gitlab"
    shm_size: "256m"
    # restart: always
    restart: unless-stopped

volumes:
  gitlab-data:
    external: true
```

```bash
docker-compose up -d
```

4. Recreate the Socket File
   If the socket file is corrupted, delete it and restart GitLab to recreate it:

Exec into the GitLab container:

    docker exec -it gitlab bash

Delete the socket file:

    rm -f /var/opt/gitlab/gitlab-rails/sockets/gitlab.socket

Restart GitLab services:

    gitlab-ctl restart

5. Use TCP Instead of Unix Sockets (Optional)
   If the issue persists, configure GitLab to use TCP instead of Unix sockets:

Edit the gitlab.rb file:

puma['socket'] = nil
puma['port'] = 8080

    gitlab-ctl reconfigure
    gitlab-ctl restart

## Back up from Docker Volume to host machine

Steps to Backup Data from a Docker Volume
Create a Backup Directory on the Host:
Create a directory on your host machine
where you want to store the backup.

For example:

    mkdir -p /backup/gitlab-data

Run a Temporary Container to Access the Volume:

Use a temporary container to mount the gitlab-data volume
and copy its contents to the host.
You can use a lightweight image like alpine or busybox for this purpose.

    docker run --rm -v gitlab-data:/volume -v /backup/gitlab-data:/backup alpine \
    sh -c "cp -r /volume/\* /backup/"

Explanation:

--rm: Automatically remove the container after it exits.

-v gitlab-data:/volume: Mount the gitlab-data volume to /volume inside the container.

-v /backup/gitlab-data:/backup: Mount the host's backup directory (/backup/gitlab-data) to /backup inside the container.

"cp -r /volume/\* /backup/": Copy the contents of the volume to the backup directory.

Verify the Backup:
After the command completes, check the /backup/gitlab-data directory on your host to ensure the data has been copied successfully:

    ls -l /backup/gitlab-data

Alternative: Use docker cp with a Running Container
If the gitlab-data volume is already in use by a running container
(e.g., a GitLab container),
you can directly copy the data from the container to the host using docker cp.

Find the Container Using the Volume:
Run the following command to find the container using the gitlab-data volume:

    docker ps --format "{{.Names}}"

Copy Data from the Container:
Use docker cp to copy the data from the container to the host.
For example, if the container name is gitlab
and the data is stored in /var/opt/gitlab:

    docker cp gitlab:/var/opt/gitlab /backup/gitlab-data

Optional: Compress the Backup
To save space, you can compress the backup into a .tar.gz file. For example:

Run a Temporary Container to Create a Compressed Backup:

    docker run --rm -v gitlab-data:/volume -v /backup:/backup alpine \
    sh -c "tar -czvf /backup/gitlab-data-backup.tar.gz -C /volume ."

Verify the Compressed Backup:
The compressed backup will be located
at /backup/gitlab-data-backup.tar.gz on your host.

Summary
Use a temporary container to access the Docker volume and copy its contents to the host.

Alternatively, use docker cp if the volume is already in use by a running container.

Compress the backup if needed to save space.
