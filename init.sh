#!/bin/bash

repo="alist-org/alist"
latest=$(curl -s https://api.github.com/repos/$repo/releases/latest)
version=$(echo $latest | jq -r '.tag_name')
# echo $version
# echo alist-${version#v}
wget https://github.com/$repo/archive/refs/tags/$version.tar.gz
wget https://github.com/alist-org/alist-web/releases/latest/download/dist.tar.gz
tar -zxf $version.tar.gz
tar -zxf dist.tar.gz
rm -rf alist-${version#v}/public/dist/*
cp dist/index.html alist-${version#v}/public/dist

# Install dependencies
# sudo snap install zig --classic --beta
docker pull crazymax/xgo:latest
go install github.com/crazy-max/xgo@latest
# sudo apt update
# sudo apt install upx
repo="upx/upx"
latest=$(curl -s https://api.github.com/repos/$repo/releases/latest)
version=$(echo $latest | jq -r '.tag_name')
wget https://github.com/$repo/releases/latest/download/upx-${version#v}-amd64_linux.tar.xz
tar -xf upx-${version#v}-amd64_linux.tar.xz
sudo mv upx-${version#v}-amd64_linux/upx /usr/local/bin/
sudo chmod +x /usr/local/bin/upx

# linux-musl-cross
BASE="https://musl.nn.ci/"
FILES=(x86_64-linux-musl-cross aarch64-linux-musl-cross mips-linux-musl-cross mips64-linux-musl-cross mips64el-linux-musl-cross mipsel-linux-musl-cross powerpc64le-linux-musl-cross s390x-linux-musl-cross)
for i in "${FILES[@]}"; do
  url="${BASE}${i}.tgz"
  curl -L -o "${i}.tgz" "${url}"
  sudo tar xf "${i}.tgz" --strip-components 1 -C /usr/local
  rm -f "${i}.tgz"
done

# build
bash build.sh release
bash build.sh release linux_musl
