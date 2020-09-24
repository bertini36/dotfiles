# Commands

## Utilities

##### Too long to read
    tldr [COMMAND]

##### Iteractive results
    ls | fzf
    docker ps | fzf


## Git

##### Clone repostory
    git clone [REPOSITORY]
    git remote -v -> Checks where is local repository pointing (remote)

##### Download changes
    git pull
    git pull --rebase
    git pull --rebase --autostash

##### Fetch
    git fetch origin -> Makes visible created new branches
    git fetch -ap -> Delete references of not existent branches

##### Change branch
    git checkout [BRANCH]

##### Add changes
    git add .
    git add -A
    git add -u -> Add just changes in files that git knows

##### Commit changes
    git commit -m "[DESCRIPTION]
    git commit -am "[DESCRIPTION]"  -> With add included
    git commit --ammend --no-edit -> Add stuff in staging area to last commit

##### Revert
    git revert -m 1 [HASH]
    git revert @ === git revert HEAD~1

##### Reset
    git reset --hard -> Go to previous branch state before all your changes
    git reset --hard [HASH] -> Go to a previous commit state
    git reset --hard origin/[BRANCH] -> Delete local commits over a branch and restore repository state
    git reset HEAD~1 --mixed -> Delete last command but not changes (git undo)
    (git discard)

##### Branches
    git branch -> Check current branch
    git branch [BRANCHNAME] -> Create a branch (without checkout) === git checkout -b [BRANCHNAME]
    git branch -a -> List remote branches

##### Merge
    git merge [BRANCH]
    git merge --no-ff [BRANCH] (just add one commit to history)

##### Rebase
    git rebase [BRANCHNAME]
    Configure pull as fetch+rebase instead of fetch+merge: git config --global pull.rebase true
    git rebase -i HEAD~3 -> Interactive rebase to 3 commits in the past
    git rebase --continue
    git rebase --abort

##### Push
    git push
    git push --force -> When we rewrite the history

##### Tags
    git tag "v1.0.0" -> Creates a tag for current commit
    git tag -> List tags

##### Logs
    git log ->  Shows HEAD (current branch)
    git log --graph --abbrev-commit --oneline
    git log master feature-with-merge -> Shows history of selected branches
    git log --all -> Shows history of all branches
    git log master..feature-with-merge -> Shows commits of feature-with-merge which master has not
    git log --left-right master...feature-with-merge -> Shows commits differences between the 2 branches
    git log --oneline
    git log --grep $string

##### Current changes
    git status

##### Check differences
    git diff [BRANCH]..[BRANCH2]
    git diff master..origin/master
    git diff [hash]..develop
    git diff HEAD..origin/master
    git diff origin/develop
    git diff [BRANCH] --stat (current branch against specific branch)
    git diff [BRANCH] [FILE]
    git diff HEAD~1 (diff after pull)

##### Apply patch
    git apply [PATCH]

##### Stash changes
    git stash === IntellIJ shelves
    git stash pop
    git stash drop stash@{1}
    git stash list

##### Set personal .gitignore
    vim ~/.gitignore_global (check ~/.gitconfig)

##### Download git submodule
    git submodule update --init --recursive

##### Rename branch pushed:
    git branch -m [OLDNAME] [NEWNAME]
    git push origin --delete [OLDNAME]
    git push origin [NEWNAME]

##### Cherry pick
    git cherry-pick [COMMIT_HASH]

##### Generate hash
    git hash-object --stdin


## Manage files

##### Create file
    touch [file]

##### Edit file
    vim [file]
    code [file]

##### Deletions
    rm [file]
    rm -rf [folder]

##### Change permisions
    chmod ugo+rwx

##### Print file
    cat [filename]

##### Show files in a folder
    ls -l
    ls -la | fzf (interative)

##### Change folder owner
    chown [user]:[user2] .docker -R
    Current folder: chown -R $UID:$UID .

##### Look file changes real time
    tail -f [file]

##### Find
    find [directory] -type [filetype] -print -name '*.txt' -maxdepth [num]

##### Searches
    ag --py [criteria]
    ag --[fileextension] -i [criteria]  -c
    grep [word] [file] -i (case insensitive) -E (for regex)

##### Copy file
    cp .env-sample .env


## SSH

##### Connect to server
    ssh -p [port] -i [pemfile] [user]@[domain|ip]
    
##### Create alias in .ssh/config
    Host [alias]
        Hostname [domain|ip]
        Port [port]
        User [user]
        
##### Get files from server
    scp -P[port] [user]@[domain|ip]:[filepath] [filepath]
    
##### Execute commands in multiple servers
    dsh -c -M -g [project] -- "zegrep -i 2t525h3qq2\/registrar /var/log/www/project_uwsgi.log*"
    dsh -c -M -g [project] -- "grep 2t525h3qq2 /var/log/www/project_uwsgi.log"


## Screen

##### Create session
    screen [command]
    
##### Detach session
    CTL+A+D
    
##### List sessions
    screen -ls
    
##### Connect to existent session
    screen -r [name]

## Manage proceses

##### List
    htop
    top
    ps aux
    
##### Filter
    ps aux | grep sleep
    pgrep sleep
    
##### Kill (send signals to processes)
    kill -[signal] [pid]
    killall -[signal] [name]
    kill -SIGKILL [pid] (real kill)
    kill -9 [pid]
    CTL-Z (SIGSTOP)
    
##### Filter
    pgrep -l  (with name)
    pgrep -a  (all)
    
##### Run command in backround
     [command] &
     
##### Bring background program 
    fg
    
##### Open last command executed in editor
    fc


## Compression
    gunzip -c [gzfile] -d [destination]
    unzip [zipfile] -d [destination]


## Postgres

##### Connect
    psql --host=[host] --username=[user] --password=[password] or (--no-password)
    
##### Show most heavy tables in DB
    SELECT
        relname as "Table",
        pg_size_pretty(pg_total_relation_size(relid)) As "Size",
        pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as "External Size"
        FROM pg_catalog.pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC;
    
##### Show DB indexes
    SELECT
        tablename,
        indexname,
        indexdef
    FROM
        pg_indexes
    WHERE
        schemaname = 'public'
    ORDER BY
        tablename,
        indexname;
        
##### Show tabla indexes
    SELECT * FROM pg_indexes WHERE tablename = '[tablename';
    
##### Explain query Postgres (check indexes usage) This command doesn't execute the query
    EXPLAIN SELECT id FROM [tablename] WHERE id=500;
    
##### Gets lanning and execution times (executes query)
    EXPLAIN ANALYZE SELECT id FROM [tablename] WHERE id=500;
    
##### Column names
    SELECT *
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name   = '[tablename]'
        ;
        
##### Create autofield/serial
    CREATE TABLE teams
        (
            id SERIAL UNIQUE,
            ad SERIAL UNIQUE,
            name VARCHAR(90)
        );


## System status

##### Status sistema
    sudo systemctl status [service]
    sudo service status [service]
##### Check open ports
    sudo lsof -i -P -n | grep LISTEN
##### Disk ussage
    df -h
    df -BG

## Docker

##### Run container (each execution creates a new container using image specified) (-it interactive mode)
    docker run -it [image]
    
##### List running containers
    docker ps
    docker ps -a (Stopped containers also)
    
##### List logs of a container
    docker log [containerId]
    docker log -f [containerId] (follow)
    
##### Stop container
    docker stop [containerId]   (SIGTERM)
        
##### Start stopped container
    docker start [containerId]
    
##### Remove container
    docker rm [containerId]
    
##### Check downloaded images (Docker hub: Docker images repository)
    docker images
    
##### Delete image
    docker rmi [imageId]
    
##### Build image
    docker build -t "imageName" . (route where is Dockerfile)

##### Project name
    COMPOSE_PROJECT_NAME=[projectname]
    
##### Add user to docker group
    sudo usermod -a -G docker $USER
    
##### Other
    docker-compose --project-name [projectname] up
    docker-compose --project-name [projectname] restart
    docker-compose --project-name [projectname] stop
    docker-compose --project-name [projectname] ps
    docker-compose --project-name [projectname] kill
    docker-compose --project-name [projectname] run --rm (delete when finish) --entrypoint [command]
    docker-compose --project-name [projectname] logs -f --tail 100 [container]
    docker rm $(docker ps -aq)
    
##### If you want to reexecute Docker file you need to delete Docker image
    docker rmi <nombre-o-id-de-la-imagen>
    
##### Delete multiple containers:
    docker rm $(docker ps -aq)


## Other

##### Define alias (.bashrc)
    alias [alias]='[command]'
    
##### Define environ variable (.bashrc)
    export [VARNAME]=[value]
##### Reload bash
    source .bashrc
##### Return command each 2 seconds
    watch
##### Calendar:
    cal
##### xargs (takes lines from stin and converts them into command line arguments)
    echo "Dropbox/" | xargs ls
    Replace foo with bar in all .txt files: find . -name '*.txt' | xargs sed -i s/foo/bar/g

## IPDB
    TODO SAMU