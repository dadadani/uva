FROM debian:bookworm
RUN apt update && apt upgrade -y
RUN /bin/sh -c mkdir /nimsrc && cd /nimsrc && wget https://nim-lang.org/download/nim-2.0.0.tar.xz && tar -xvf nim-2.0.0 && cd nim-2.0.0 && nim c koch && ./koch tools && ln -s `pwd`/bin/nimble /bin/nimble &&    ln -s `pwd`/bin/nimsuggest /bin/nimsuggest &&    ln -s `pwd`/bin/testament /bin/testament && rm -rf /nimsrc/nim-2.0.0.tar.xz


 mkdir /nimsrc && cd /nimsrc && wget https://nim-lang.org/download/nim-2.0.0.tar.xz && tar -xvf nim-2.0.0.tar.xz && cd nim-2.0.0 && sh build.sh && nim c koch && ./koch tools && ln -s `pwd`/bin/nimble /bin/nimble &&    ln -s `pwd`/bin/nimsuggest /bin/nimsuggest &&    ln -s `pwd`/bin/testament /bin/testament && rm -rf ../nim-2.0.0.tar.xz