FROM nginx:1.21

COPY entrypoint.sh entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.template.conf

VOLUME [ "/certs" ]

EXPOSE 443

ENTRYPOINT [ "./entrypoint.sh" ]