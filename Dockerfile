FROM nginx:1.21

COPY entrypoint.sh entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.template.conf
COPY nginx.site.conf /etc/nginx/nginx.site.template.conf

RUN mkdir -p /certs /etc/nginx/sites.d

VOLUME [ "/certs", "/etc/nginx/sites.d" ]

EXPOSE 443

ENTRYPOINT [ "./entrypoint.sh" ]