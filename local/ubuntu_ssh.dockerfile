FROM ubuntu:latest

# set the container timezone (used in tzdata when installing openssh-server)
ENV TZ=Europe/Tallinn
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y openssh-server
#RUN echo 'root:mypassword' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
CMD ["service", "ssh", "start"]
