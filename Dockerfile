FROM centos:7

RUN yum install -y epel-release && yum install -y python-pip

COPY requirements.txt /
RUN pip install -r /requirements.txt

ENV APP_ROOT /validator

COPY validator ${APP_ROOT}

WORKDIR ${APP_ROOT}
ENTRYPOINT [ "./validate.py" ]
