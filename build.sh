npm run build && \
docker buildx build --platform linux/amd64 -t dns-frontend:22 . && \
docker save -o frontend-22.tar dns-frontend:22 && \
scp frontend-22.tar dns_vps:/tmp/frontend-22.tar && \
rm -rf frontend-22.tar && \
docker rmi dns-frontend:22