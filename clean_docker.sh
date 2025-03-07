docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker system prune -a --volumes
docker volume rm $( docker volume ls -q --filter dangling=true )

