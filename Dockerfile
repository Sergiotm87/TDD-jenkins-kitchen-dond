FROM jenkins/jenkins:lts
MAINTAINER sergioteranmonge@gmail.com

# needed for install pre-requisites
USER root

ENV DEBIAN_FRONTEND="noninteractive" \
    TZ="Europe/Madrid"

RUN apt update -qq && \
		apt install -qq -y\
		apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -qq -y install docker-ce

RUN apt update  -qq && \
    apt install -qq -y \
    build-essential \
    git \
    openssh-client \
    dirmngr \
    libreadline-dev \
    libssl-dev \
    lsb-release \
#    rbenv \
    ruby \
    ruby-dev \
    rubygems \
    wget \
    zlib1g-dev

COPY kitchen-docker-2.6.1.pre.gem /tmp/gems/kitchen-docker-2.6.1.pre.gem

# http://kitchen.ci/
RUN gem install rake \
      --no-document \
      --quiet && \
    gem install bundler \
      --no-document \
      --quiet && \
    gem install kitchen-ansible \
      --no-document \
      --quiet && \
#    gem install kitchen-docker \
# using modified gem: https://github.com/k4mmin/kitchen-docker
    gem install --local /tmp/gems/kitchen-docker-2.6.1.pre.gem \
      --no-document \
      --quiet && \
    gem install kitchen-docker_cli \
      --no-document \
      --quiet && \
    gem install kitchen-inspec \
      --no-document \
      --quiet && \
    gem install kitchen-verifier-serverspec \
      --no-document \
      --quiet && \
    gem install test-kitchen \
      --no-document \
      --quiet && \
    gem install kitchen-ansible \
      --no-document \
      --quiet

# dont use ipv6 inside container
#!!!check this in next build (actually in entrypoint.sh, look for a better approach)
#RUN sed -i '/#precedence ::ffff:0:0\/96  100/d' /etc/gai.conf && \
#     sed -i 's/#precedence ::ffff:0:0\/96  10/precedence ::ffff:0:0\/96  100/' /etc/gai.conf

# let jenkins use docker socket
RUN usermod -a -G docker jenkins

#!!!check this in next build (build the image with correct permisions to not use root at all)
# let jenkins run kitchen with sudo to access ruby gems
RUN echo "jenkins ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/jenkins && \
    chmod 0440 /etc/sudoers.d/jenkins

RUN mkdir /opt/projects

# container runs in privileged mode by non-root user
USER jenkins

ADD assets /assets

COPY assets/plugins/plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt

#!!!check this in next build (are they all needed?)
VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock" ]

ENTRYPOINT ["/sbin/tini", "--", "/assets/bin/entrypoint.sh"]
