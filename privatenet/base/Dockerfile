FROM archlinux/base

RUN pacman -Syu --noconfirm
RUN pacman -S iputils inetutils net-tools sudo git make gcc go procps --noconfirm

# Create a user to run the ethereum node
RUN useradd --create-home euser
RUN echo "euser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN mkdir -p /home/euser/.ethereum/devchain/keystore
RUN chown -R euser:euser /home/euser/.ethereum
USER euser
WORKDIR /home/euser

# Install go-ethereum
RUN git clone https://github.com/ethereum/go-ethereum.git /home/euser/go-ethereum
RUN cd /home/euser/go-ethereum && make all

RUN sudo cp /home/euser/go-ethereum/build/bin/* /usr/local/bin/

ENV networkID="13"

# Setup Genesis block
COPY genesis.json /home/euser/eth-config/genesis.json
RUN /usr/local/bin/geth --datadir="/home/euser/.ethereum/devchain" --networkid=$networkID init /home/euser/eth-config/genesis.json