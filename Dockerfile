FROM swift:latest

WORKDIR /usr/app

RUN apt-get update
RUN apt-get install -y git build-essential
RUN git clone https://github.com/vapor/toolbox.git
WORKDIR /usr/app/toolbox
RUN git fetch origin && git checkout 18.2.2
RUN make install

WORKDIR /usr/app
COPY Sources ./Sources
COPY Tests ./Tests
COPY Web ./Web
COPY Package.swift ./Package.swift
COPY .env.development ./.env.development

# expose the port the server is listening on
EXPOSE 8080

# run the server
CMD [ "vapor", "--help" ]

