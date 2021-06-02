FROM quay.io/comp-bio-aging/rstudio:master
ADD install.R /tmp/
RUN R -f /tmp/install.R
ADD src /home/rstudio/
USER root
RUN chmod -R 777 /var/run/
RUN chmod -R 777 /usr/local/lib/R
RUN chmod -R 777 /home/rstudio/
RUN chmod -R 777 /init
RUN chmod -R 777  /etc/R
RUN ln -s /init /s6-init
#USER rstudio
CMD ["/s6-init"]