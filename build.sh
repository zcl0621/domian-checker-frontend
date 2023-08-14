npm run build && \
docker buildx build --platform linux/amd64 -t dns-frontend:21 . && \
docker save -o frontend-21.tar dns-frontend:21 && \
scp frontend-21.tar dns_vps:/tmp/frontend-21.tar && \
rm -rf frontend-21.tar && \
docker rmi dns-frontend:21