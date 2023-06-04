#FROM node:14.18.2-buster AS build-dist
#
#RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
#
#RUN apt-get update
#
#ADD ./ /workspace
#
#WORKDIR workspace
#
#RUN npm install
#
#RUN npx browserslist@latest --update-db
#
#RUN npm run build


FROM nginx:stable-alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk add --no-cache -U tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
COPY dist /etc/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
