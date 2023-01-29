FROM archlinux:latest
RUN pacman -Sy --noconfirm && pacman -S sudo --noconfirm
RUN groupadd sudo
RUN useradd -ms /bin/bash -G sudo -u 1001 dupka
RUN echo 'dupka:dupa' | chpasswd
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /home/dupka
USER dupka
COPY . .

CMD ["sleep","inf"]

