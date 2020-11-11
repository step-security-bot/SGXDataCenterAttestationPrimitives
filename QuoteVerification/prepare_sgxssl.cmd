
Rem
Rem Copyright (C) 2011-2020 Intel Corporation. All rights reserved.
Rem
Rem Redistribution and use in source and binary forms, with or without
Rem modification, are permitted provided that the following conditions
Rem are met:
Rem
Rem   * Redistributions of source code must retain the above copyright
Rem     notice, this list of conditions and the following disclaimer.
Rem   * Redistributions in binary form must reproduce the above copyright
Rem     notice, this list of conditions and the following disclaimer in
Rem     the documentation and/or other materials provided with the
Rem     distribution.
Rem   * Neither the name of Intel Corporation nor the names of its
Rem     contributors may be used to endorse or promote products derived
Rem     from this software without specific prior written permission.
Rem
Rem THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
Rem "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
Rem LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
Rem A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
Rem OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
Rem SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
Rem LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
Rem DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
Rem THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
Rem (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
Rem OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
Rem
Rem

set PFM=%1
set CFG=%2

set top_dir=%~dp0
set sgxssl_dir=%top_dir%\sgxssl

set openssl_out_dir=%sgxssl_dir%\openssl_source
set openssl_ver_name=openssl-1.1.1g
set sgxssl_github_archive=https://github.com/intel/intel-sgx-ssl/archive
set sgxssl_ver_name=win_2.9_1.1.1g
set sgxssl_ver=win_2.9_1.1.1g
set build_script=%sgxssl_dir%\Windows\build_package.cmd
set server_url_path=https://www.openssl.org/source/
set full_openssl_url=%server_url_path%/%openssl_ver_name%.tar.gz
set sgxssl_chksum=09813f1d31fa0a7a6412925f4c1c88f8f530e05d5bf6bd23fd90b102958135cf
set openssl_chksum=ddb04774f1e32f0c49751e21b67216ac87852ceb056b75209af2443400636d46

if not exist %sgxssl_dir% (
	mkdir %sgxssl_dir%
)

if not exist %build_script% (
	call powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-WebRequest -URI %sgxssl_github_archive%/%sgxssl_ver_name%.zip -OutFile %sgxssl_dir%\%sgxssl_ver_name%.zip"
	7z.exe x -y %sgxssl_dir%\%sgxssl_ver_name%.zip -o%sgxssl_dir%
    xcopy /y "%sgxssl_dir%\intel-sgx-ssl-%sgxssl_ver%" %sgxssl_dir% /e
	del /f /q %sgxssl_dir%\%sgxssl_ver_name%.zip
	rmdir /s /q %sgxssl_dir%\intel-sgx-ssl-%sgxssl_ver%
)

if not exist %openssl_out_dir%\%openssl_ver_name%.tar.gz (
	call powershell -Command "Invoke-WebRequest -URI %full_openssl_url% -OutFile %openssl_out_dir%\%openssl_ver_name%.tar.gz"
)

if not exist %sgxssl_dir%\Windows\package\lib\%PFM%\%CFG%\libsgx_tsgxssl.lib (
	cd %sgxssl_dir%\Windows\
	start /WAIT cmd /C call %build_script% %PFM%_%CFG% %openssl_ver_name% no-clean SIM || exit /b 1
    xcopy /E /H /y %sgxssl_dir%\Windows\package %top_dir%\package\

	cd ..\
)

cd %top_dir%
exit /b 0
