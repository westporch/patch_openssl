#!/bin/bash
# Hyun-gwan Seo(westporch@debianusers.or.kr)

SRC_DIR="/usr/local/src"
LATEST_OPENSSL_FNAME="openssl-1.1.1t.tar.gz"  # 최신 OpenSSL 소스 파일(참고: https://www.openssl.org/source)
LATEST_OPENSSL_DNAME="${LATEST_OPENSSL_FNAME:0:14}" # LATEST_OPENSSL_FNAME을 압축 해제한 후의 디렉터리 이름(예를 들어 openssl-1.1.1t)


# OpenSSL을 소스컴파일 하는 데 필요한 패키지(gcc, make, perl) 설치 확인
function check_pkg_dependency()
{
  if ! [ -x "$(command -v gcc)" ]; then
    echo "Gcc is not installed."
    exit 1
  fi
  
  if ! [ -x "$(command -v make)" ]; then
    echo "Make is not installed."
    exit 1
  fi
  
  if ! [ -x "$(command -v perl)" ]; then
    echo "Perl is not installed."
    exit 1
  fi 
}


function prepare_compilation()
{
  # SRC_DIR이 존재하지 않으면, SRC_DIR 디렉터리 생성
  if ! [ -d $SRC_DIR ]; then
    mkdir -p $SRC_DIR
  fi

  # LATEST_OPENSSL_FNAME이 존재하지 않으면, 프로그램(patch_openssl.sh) 종료
  if ! [ -f $SRC_DIR/$LATEST_OPENSSL_FNAME ]; then
    echo "$LATEST_OPENSSL_FNAME does not exits in $SRC_DIR."
    exit 1
  fi
}


# OpenSSL 소스 컴파일
function compile_openssl()
{
  lib_list=("libssl.so.1.1" "libcrypto.so.1.1")
  
  tar xvf $SRC_DIR/$LATEST_OPENSSL_FNAME -C $SRC_DIR
  
  $SRC_DIR/$LATEST_OPENSSL_DNAME/./config --openssldir=/usr/local/ssl
  make && make install
  
  ln -sf /usr/local/bin/openssl /usr/bin/openssl
  
  # OenSSL을 사용하는 데 필요한 라이브러리 복사
  for ((idx=0; idx < ${#lib_list[@]}; idx++))
  do
    cp /usr/local/lib64/${lib_list[$idx]} /usr/lib64/${lib_list[$idx]}
  done
}


# OpenSSL의 버전 확인
function get_openssl_version()
{
  openssl version
}


check_pkg_dependency
prepare_compilation
compile_openssl
get_openssl_version
