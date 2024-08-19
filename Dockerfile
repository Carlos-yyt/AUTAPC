FROM registry.cn-shanghai.aliyuncs.com/carlos1999/gcc:11.2.0


# RUN apt-get -qq update \
#     && apt-get -qq install --no-install-recommends openssh-server \
#     && apt-get -qq install --no-install-recommends sudo \
#     && apt-get -qq install --no-install-recommends cmake \
#     && apt-get -qq install --no-install-recommends rsync \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# RUN result=$(apt-cache policy)  
# 使用echo输出变量  
# RUN echo "$result"
# 替换apt源为阿里源  
COPY sources.list /etc/apt/sources.list  
# RUN apt-get clean
# 更新apt源列表  
RUN apt-get update --allow-insecure-repositories

RUN apt-get install -y --allow-unauthenticated --no-install-recommends openssh-server  
RUN apt-get install -y --allow-unauthenticated --no-install-recommends sudo  
RUN apt-get install -y --allow-unauthenticated --no-install-recommends cmake  
RUN apt-get install -y --allow-unauthenticated --no-install-recommends rsync  
RUN apt-get clean  
RUN rm -rf /var/lib/apt/lists/*  

# setup ssh for use ubuntu, password 1234
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 ubuntu 
RUN  echo 'ubuntu:1234' | chpasswd
RUN service ssh start
EXPOSE 22

# install google test
WORKDIR /usr/src/libraries
RUN git clone --depth=1 -b main https://github.com/google/googletest.git
WORKDIR /usr/src/libraries/googletest/build
RUN cmake .. \
  && make \
  && make install

# build the project
WORKDIR /usr/src/app
COPY . .
RUN rm -rf build
RUN mkdir build
WORKDIR /usr/src/app/build
RUN cmake ..
RUN make

# CMD ["/usr/sbin/sshd","-D"]
CMD ["./main"]