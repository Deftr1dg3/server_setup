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

# Prometheus and Grafana:

## 1. Bind Prometheus to all inerfaces 0.0.0.0:9090:

Add to "gitlab.rb" file:

    prometheus['listen_address'] = '0.0.0.0:9090'

## 2. Expose 9090 in the docker-compose.yml

```yml
ports:
  - "80:80"
  - "443:443"
  - "2222:22"
  - "9090:9090"
```

## 3. Run Grafana in a separate container and connect to Prometheus via exposed 9090 port.

Add to docekr compose separate Grafana container:

```yml
services:
    ...
    ...
    ...
    grafana:
        image: grafana/grafana:latest
        container_name: grafana
        volumes:
            - "./grafana_storage:/var/lib/grafana"
        ports:
            - "3000:3000" # Grafana default port
        environment:
            - GF_SECURITY_ADMIN_PASSWORD=admin # Set admin password
        depends_on:
            - gitlab
        restart: unless-stopped
```

Username: admin
Password: admin

# Connect Grafana to GitLab’s Prometheus

Once Grafana is running:

### 1. Access Grafana:

    http://localhost:3000

### 2. Login with:

    admin / admin

And set the new password

### 3 Go to: Gear Icon (⚙️) → Data Sources → Add Data Source → Prometheus

In Connection -> Prometheus server URL section put:

    http://host.docker.internal:9090

## Or use common docker network:

```yml
version: "3.8"

services:
  gitlab:
    image: gitlab/gitlab-ce:17.7.6-ce.0
    container_name: gitlab
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        prometheus['listen_address'] = '0.0.0.0:9090'
    ports:
      - "80:80"
      - "443:443"
      - "2222:22"
      - "9090:9090"
    volumes:
      - "$GITLAB_HOME/config:/etc/gitlab"
      - "$GITLAB_HOME/logs:/var/log/gitlab"
      - "$GITLAB_HOME/data:/var/opt/gitlab"
    shm_size: "256m"
    restart: unless-stopped
    networks:
      - monitoring-net

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-storage:/var/lib/grafana
    # For Linux
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: unless-stopped
    depends_on:
      - gitlab
    networks:
      - monitoring-net

volumes:
  grafana-storage:

networks:
  monitoring-net:
    driver: bridge
```

Since everything is local, no domain name, and running
inside Docker containers on the same Docker network,
here’s exactly what you need to put for
Prometheus server URL in Grafana:

    http://gitlab:9090

"gitlab" container name, that will be resolved by Docker DNS.

Why?
gitlab = Docker Compose service name → resolves to the GitLab container inside the custom Docker network.

9090 = Prometheus exposed port inside container (we configured Prometheus to listen on 0.0.0.0:9090).

No need to use localhost or IP addresses. Docker networking handles internal DNS resolution using service names.

# Setup CI/CD Gitlab runner

Docker compose:

```yml
version: "3.8"

services:
  gitlab-runner:
    image: gitlab/gitlab-runner:latest
    container_name: gitlab-runner
    restart: always
    # For Linux
    extra_hosts:
      - "host.docker.internal:host-gateway"
    volumes:
      - ./config:/etc/gitlab-runner
      - /var/run/docker.sock:/var/run/docker.sock
```

## INFO

Config file is called "config.toml" and
the folder with this file should be mapped to "/etc/gitlab-runner"

## EXAMPLE of config.toml

## INFO

If you use config.toml file you do not need
to register the runner manually via terminal.

```toml
concurrent = 1
check_interval = 0

[[runners]]
  name = "docker-local-runner"
  url = "http://your-local-gitlab-host:port/"  # Change to match your GitLab server URL
  token = "YOUR_REGISTRATION_TOKEN"            # Replace with your runner registration token
  executor = "docker"

  [runners.docker]
    tls_verify = false
    image = "alpine:latest"                     # Default image for jobs, you can change it
    privileged = true                           # Needed for Docker-in-Docker builds
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock",  # Allow Docker access
      "/cache"                                      # Optional: job cache directory
    ]
    shm_size = 0

  [runners.cache]
    [runners.cache.s3]    # Leave empty unless using S3 cache
    [runners.cache.gcs]   # Leave empty unless using Google Cloud cache
```

Demo example with several runners:

```toml
# Single table
[server]
host = "localhost"
port = 8080

# Array of tables
[[runners]]
name = "Runner A"
executor = "shell"

[[runners]]
name = "Runner B"
executor = "docker"
```

## Register runner

## INFO

You need to register the runner via terminal if you
do not provide the config.toml file only.

    docker exec -it gitlab-runner gitlab-runner register

You would need token for registration.

## Where to get the Runner Registration Token:

### 1️⃣ Global (For ALL Projects - Shared Runner)

If you're an admin and want to register a runner available for all projects:

Go to:
GitLab → Admin Area (wrench icon) → Overview → Runners

Look for:
Registration Token at the top.
Copy that token.

### 2️⃣ Project-Specific Runner (Only for ONE Project)

If you want a runner only for one specific project:

Go to your GitLab project.

Click:
Settings → CI/CD → Expand 'Runners' Section

You'll see:

Set up a specific Runner manually

There, you'll find:

Registration token for this project: xxxxx

👉 Copy THAT token!

# Example of ".gitlab-ci.yml" file with all options:

```yml
# Define stages
stages:
  - prepare
  - build
  - test
  - deploy
  - cleanup

# Variables (env variables available in all jobs)
variables:
  GLOBAL_VAR: "global_value"
  DOCKER_DRIVER: overlay2

# Cache settings (shared cache across jobs)
cache:
  key: "$CI_COMMIT_REF_SLUG"
  paths:
    - .cache/
  policy: push

# Before script: Runs before all jobs
before_script:
  - echo "Starting job for $CI_PROJECT_NAME"

# After script: Runs after all jobs
after_script:
  - echo "Job finished for $CI_PROJECT_NAME"

####################
# Job: Preparation
####################
prepare-job:
  stage: prepare
  image: alpine:latest
  script:
    - echo "Preparing..."
    - apk add curl
  tags:
    - docker
  only:
    - branches
  except:
    - tags
  allow_failure: false
  timeout: 5 minutes
  retry: 2

####################
# Job: Build
####################
build-job:
  stage: build
  image: node:18
  variables:
    NODE_ENV: production
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 hour

####################
# Job: Test
####################
test-job:
  stage: test
  image: python:3.10
  services:
    - name: postgres:14
      alias: db
  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password
  script:
    - pip install -r requirements.txt
    - pytest
  dependencies:
    - build-job
  parallel:
    matrix:
      - TEST_SUITE: unit
      - TEST_SUITE: integration
  coverage: '/TOTAL\s+\d+\s+\d+\s+(\d+%)/'
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: always
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: manual
  tags:
    - docker

####################
# Job: Deploy
####################
deploy-job:
  stage: deploy
  image: alpine
  script:
    - echo "Deploying to production..."
    - ./deploy.sh
  environment:
    name: production
    url: https://yourapp.com
    on_stop: stop-deploy
  only:
    - tags
  when: manual

####################
# Job: Stop Deploy
####################
stop-deploy:
  stage: deploy
  script:
    - echo "Stopping deployment..."
  environment:
    name: production
    action: stop
  when: manual

####################
# Job: Cleanup
####################
cleanup-job:
  stage: cleanup
  script:
    - echo "Cleaning up..."
  when: always
  tags:
    - docker
```

## Key Features Demonstrated:

Feature Description

stages -> Defines pipeline stages
variables -> Global environment variables
cache -> Speeds up builds by caching files
before_script / after_script -> Common pre/post actions for all jobs
tags -> Specifies which runner tags should run the job
only / except / rules -> Controls when jobs run
allow_failure / retry / -> timeout Control failure/retries/timeouts
artifacts -> Saves build outputs
services -> Start extra containers (DBs etc.)
dependencies -> Controls job dependencies
parallel matrix -> Run jobs in parallel with variations
coverage -> Parse test coverage output
environment & deployment actions -> Deployment environments and manual stops
when: manual / always -> Manual/always-run jobs

## Some explanations

```yml
artifacts:
  paths:
    - dist/
  expire_in: 1 hour
```

Explanation:

Artifacts are files that GitLab saves after a
job finishes (like build results, test reports, etc.).

expire_in defines how long GitLab keeps those artifacts.

After 1 hour, GitLab will automatically delete them.

```yml
expire_in: 1 hour
expire_in: 30 minutes
expire_in: 2 days
expire_in: 1 week
expire_in: never
```

### A) only and except (Old Style, Simple)

```yml
job-name:
  script: echo "Running job"
  only:
    - main # Run only on 'main' branch
    - tags # Run only on tags
  except:
    - dev # Skip on 'dev' branch
    - schedules # Skip on scheduled pipelines
```

```yml
deploy-prod:
  stage: deploy
  script:
    - ./deploy.sh
  when: manual
  allow_failure: true
```

This way, pipeline won’t be marked as failed if you don’t run the manual job!

# Cheat-sheet of common rules use cases (MRs, tags, branches)

1️⃣ Run Job Only on Specific Branch
Use Case:
Run a job only on the main branch.

yaml
Copy
Edit
job-name:
script: echo "Running on main branch"
rules: - if: '$CI_COMMIT_BRANCH == "main"'
when: always
Explanation:
The job runs only when the commit is on the main branch.

2️⃣ Skip Job for Specific Branch
Use Case:
Skip the job on a branch like dev or staging.

yaml
Copy
Edit
job-name:
script: echo "Not running on dev branch"
rules: - if: '$CI_COMMIT_BRANCH != "dev"'
when: always
Explanation:
The job will not run on the dev branch.

3️⃣ Run Job Only on Merge Requests (MRs)
Use Case:
Run a job only for merge requests.

yaml
Copy
Edit
job-name:
script: echo "Running on Merge Request"
rules: - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
when: always
Explanation:
The job runs only when a merge request event occurs.

4️⃣ Run Job Only on Tags
Use Case:
Run a job only when a tag is pushed.

yaml
Copy
Edit
job-name:
script: echo "Running on tag"
rules: - if: '$CI_COMMIT_TAG'
when: always
Explanation:
The job runs only when a tag is pushed, not for regular commits.

5️⃣ Run Job Except for Tags
Use Case:
Run a job on all commits except tags.

yaml
Copy
Edit
job-name:
script: echo "Running on commits, but not on tags"
rules: - if: '$CI_COMMIT_TAG == null'
when: always
Explanation:
The job will not run on tags but will run on regular commits.

6️⃣ Run Job Only on a Specific Commit Message
Use Case:
Run a job only when the commit message contains a certain word.

yaml
Copy
Edit
job-name:
script: echo "Running job because of special commit message"
rules: - if: '$CI_COMMIT_MESSAGE =~ /Deploy/'
when: always
Explanation:
The job runs only if the commit message contains the word "Deploy".

7️⃣ Skip Job for Merge Requests with Specific Labels
Use Case:
Run a job only when a merge request has a specific label.

yaml
Copy
Edit
job-name:
script: echo "Running for specific MR label"
rules: - if: '$CI_MERGE_REQUEST_LABELS =~ /deploy-to-prod/'
when: always
Explanation:
The job runs only when the merge request has the label "deploy-to-prod".

8️⃣ Run Job for Push Events (Commits)
Use Case:
Run a job only when a commit is pushed.

yaml
Copy
Edit
job-name:
script: echo "Running on commit push"
rules: - if: '$CI_PIPELINE_SOURCE == "push"'
when: always
Explanation:
The job runs only when a commit is pushed (not for merge requests or tags).

9️⃣ Manual Trigger Job (Run on Demand)
Use Case:
Run a job only when triggered manually.

yaml
Copy
Edit
job-name:
script: echo "Running manually"
rules: - when: manual
Explanation:
The job will wait for manual trigger via GitLab UI (▶️ Play button).

🔟 Run Job for All Branches Except One (E.g., main)
Use Case:
Run a job for all branches except main.

yaml
Copy
Edit
job-name:
script: echo "Running for branches except main"
rules: - if: '$CI_COMMIT_BRANCH != "main"'
when: always
Explanation:
The job will run on all branches except the main branch.

1️⃣1️⃣ Run Job on Specific Branch and Tag Combo
Use Case:
Run a job only when both a specific branch and tag are present.

yaml
Copy
Edit
job-name:
script: echo "Running on main with a specific tag"
rules: - if: '$CI_COMMIT_BRANCH == "main" && $CI_COMMIT_TAG == "v1.0"'
when: always
Explanation:
The job will run only when the commit is on the main branch and the tag is v1.0.

1️⃣2️⃣ Run Job Based on Variables (e.g., environment)
Use Case:
Run a job based on a custom variable.

yaml
Copy
Edit
job-name:
script: echo "Running job for environment"
rules: - if: '$CI_JOB_VARIABLE == "production"'
when: always
Explanation:
The job runs only if CI_JOB_VARIABLE is set to production.

1️⃣3️⃣ Run Job for All Pipeline Events Except Merge Requests
Use Case:
Run a job for all events except merge requests.

yaml
Copy
Edit
job-name:
script: echo "Running for all pipeline events except MRs"
rules: - if: '$CI_PIPELINE_SOURCE != "merge_request_event"'
when: always
Explanation:
The job runs on any event except merge request events.

1️⃣4️⃣ Use Multiple rules with OR/AND Logic
Use Case:
Run a job if any of the following conditions are true (branch is main or commit message contains Deploy).

yaml
Copy
Edit
job-name:
script: echo "Running for main branch or deploy commit"
rules: - if: '$CI_COMMIT_BRANCH == "main" || $CI_COMMIT_MESSAGE =~ /Deploy/'
when: always
Explanation:
The job runs if the branch is main OR if the commit message contains "Deploy".

🌟 Quick Recap of rules Syntax
Condition Usage Example
Branch $CI_COMMIT_BRANCH == "main"
Tag $CI_COMMIT_TAG
Merge Requests $CI_PIPELINE_SOURCE == "merge_request_event"
Commit Message $CI_COMMIT_MESSAGE =~ /Deploy/
Pipeline Source (push, merge) $CI_PIPELINE_SOURCE == "push"
Variables $CI_JOB_VARIABLE == "production"
💡 Want me to apply these examples to your specific pipeline or integrate with your current .gitlab-ci.yml file?
Just let me know! 😊
