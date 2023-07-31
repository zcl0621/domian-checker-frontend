npm run build && \
docker buildx build --platform linux/amd64 -t dns-frontend:20 . && \
docker save -o frontend-20.tar dns-frontend:20 && \
scp frontend-20.tar dns_vps:/tmp/frontend-20.tar && \
rm -rf frontend-20.tar && \
docker rmi dns-frontend:20