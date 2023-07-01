npm run build && \
docker buildx build --platform linux/amd64 -t dns-frontend:18 . && \
docker save -o frontend-18.tar dns-frontend:18 && \
scp frontend-18.tar dns_vps:/tmp/frontend-18.tar && \
rm -rf frontend-18.tar && \
docker rmi dns-frontend:18