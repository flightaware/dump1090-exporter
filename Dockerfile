FROM python:3.6
MAINTAINER Chris Laws <clawsicus@gmail.com>
COPY requirements.txt /tmp/
RUN pip install pip -U
RUN pip install -r /tmp/requirements.txt
WORKDIR /tmp
RUN pip install dump1090exporter
EXPOSE 9105
ENTRYPOINT ["dump1090exporter"]
CMD ["--help"]
