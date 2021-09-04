docker build -t vattcarter/multi-client:latest -t vattcarter/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t vattcarter/multi-server:latest -t vattcarter/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t vattcarter/multi-worker:latest -t vattcarter/multi-worker:$SHA -f ./worker/Dockerfile ./worker

docker push vattcarter/multi-client:latest
docker push vattcarter/multi-server:latest
docker push vattcarter/multi-worker:latest

docker push vattcarter/multi-client:$SHA
docker push vattcarter/multi-server:$SHA
docker push vattcarter/multi-worker:$SHA

kubectl apply -f k8s
kubectl set image deployments/client-deployment client=vattcarter/multi-client:$SHA
kubectl set image deployments/server-deployment server=vattcarter/multi-server:$SHA
kubectl set image deployments/worker-deployment worker=vattcarter/multi-worker:$SHA

