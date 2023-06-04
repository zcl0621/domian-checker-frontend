npm run build && \
docker buildx build --platform linux/amd64 -t dns-frontend:17 . && \
docker save -o frontend-17.tar dns-frontend:17 && \
scp frontend-17.tar dns_vps:/tmp/frontend-17.tar && \
rm -rf frontend-17.tar && \
docker rmi dns-frontend:17